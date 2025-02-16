import mariadb
from datetime import datetime
from sqlalchemy import create_engine
import pandas as pd
from sklearn.ensemble import IsolationForest
from sklearn.preprocessing import StandardScaler
import warnings
from decimal import Decimal
import pymysql

# Database connection configuration
db_config = {
    "host": "localhost",
    "port": 3306,
    "user": "root",
    "password": "db",
    "database": "protekt_1"
}

# Function to initialize the database connection
def get_db_connection():
    return mariadb.connect(**db_config)

# Function to make a bank transfer
def make_a_transfer(s_number, r_number, transfer_amount, title, description="", currency="USD"):
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        conn.begin()  # Start a transaction

        # Retrieve sender's balance
        print("Retrieving sender's balance...")
        cursor.execute("SELECT balance FROM account WHERE a_number = %s", (s_number,))
        sender_balance_result = cursor.fetchone()

        if sender_balance_result is None:
            print("Sender's account does not exist!")
            conn.rollback()
            return

        sender_balance = sender_balance_result[0]

        if sender_balance < transfer_amount:
            print("Error: Sender's account balance is too low to make the transfer!")
            conn.rollback()
            return

        # Retrieve recipient's balance
        print("Retrieving recipient's balance...")
        cursor.execute("SELECT balance FROM accounts WHERE a_number = %s", (r_number,))
        recipient_balance_result = cursor.fetchone()

        if recipient_balance_result is None:
            print("Recipient's account does not exist!")
            conn.rollback()
            return

        recipient_balance = recipient_balance_result[0]

        # Retrieve sender's account ID
        cursor.execute("SELECT id_a FROM accounts WHERE a_number = %s", (s_number,))
        sender_account_id = cursor.fetchone()

        if sender_account_id is None:
            print("Sender's account does not exist!")
            conn.rollback()
            return

        sender_account_id = sender_account_id[0]

        # Retrieve recipient's account ID
        cursor.execute("SELECT id_a FROM accounts WHERE a_number = %s", (r_number,))
        recipient_account_id = cursor.fetchone()

        if recipient_account_id is None:
            print("Recipient's account does not exist!")
            conn.rollback()
            return

        recipient_account_id = recipient_account_id[0]

        # Update account balances separately
        print("Updating account balances...")
        cursor.execute("""
            UPDATE accounts 
            SET balance = balance - %s 
            WHERE a_number = %s
        """, (transfer_amount, s_number))

        cursor.execute("""
            UPDATE accounts 
            SET balance = balance + %s 
            WHERE a_number = %s
        """, (transfer_amount, r_number))

        # Add record to bank transfers table
        print("Adding record to the bank transfers table...")

        # Get current date and time
        transfer_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

        # Insert a record for the transfer operation
        cursor.execute("""
            INSERT INTO bank_transfers 
            (s_number, r_number, amount, title, description, currency, transfer_date)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (s_number, r_number, transfer_amount, title, description, currency, transfer_date))
        
        # Commit the transaction
        print("Committing the transaction...")
        conn.commit()
        print(f"Transfer of {transfer_amount} has been successfully executed.")

    except mariadb.Error as e:
        if conn:
            conn.rollback()
        print(f"Error during transfer: {e}")

    finally:
        if conn:
            conn.close()

# Function to perform an interbank transfer
def make_interbank_transfer(s_number, r_number, transfer_amount, title, currency="USD"):
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Convert the transfer amount to Decimal
        transfer_amount = Decimal(transfer_amount)

        # Retrieve sender's account ID and balance
        cursor.execute("SELECT id_a, balance FROM accounts WHERE a_number = %s", (s_number,))
        sender_result = cursor.fetchone()

        if not sender_result:
            raise ValueError("Sender's account does not exist in your bank")

        sender_account_id = sender_result[0]
        sender_balance = Decimal(sender_result[1])

        if sender_balance < transfer_amount:
            raise ValueError("Insufficient funds in sender's account")

        # Update sender's balance
        new_sender_balance = sender_balance - transfer_amount
        cursor.execute("""
            UPDATE accounts 
            SET balance = %s 
            WHERE id_a = %s
        """, (new_sender_balance, sender_account_id))

        # Retrieve recipient's account ID (assuming it could be an external account)
        cursor.execute("SELECT id_a FROM accounts WHERE a_number = %s", (r_number,))
        recipient_result = cursor.fetchone()

        if recipient_result:
            recipient_account_id = recipient_result[0]
            transfer_type = 'Internal'
        else:
            recipient_account_id = None
            transfer_type = 'External'

        # Get current date and time
        transfer_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

        # Add record to interbank transfers table
        cursor.execute("""
            INSERT INTO interbank_transfers 
            (s_number, r_number, title, description, amount, currency, transfer_date)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (
            s_number,
            r_number,
            title,
            f"Transfer to: {r_number} - {title}",
            transfer_amount,
            currency,
            transfer_date
        ))

        # Add history record for the sender
        cursor.execute("""
            INSERT INTO history 
            (id_a, event_type, description, amount, balance_after_event)
            SELECT id_a, 'Outgoing Transfer', %s, %s, balance
            FROM accounts WHERE id_a = %s
        """, (
            f"Transfer to: {r_number} - {title}",
            -transfer_amount,
            sender_account_id
        ))

        # Add history record for the recipient (if it's an account within your bank)
        if recipient_account_id:
            cursor.execute("""
                INSERT INTO history 
                (id_a, event_type, description, amount, balance_after_event)
                SELECT id_a, 'Incoming Transfer', %s, %s, balance
                FROM accounts WHERE id_a = %s
            """, (
                f"Transfer from: {s_number} - {title}",
                transfer_amount,
                recipient_account_id
            ))

        conn.commit()
        print(f"Interbank transfer of {transfer_amount} has been successfully executed.")

    except (mariadb.Error, ValueError) as e:
        if conn:
            conn.rollback()
        print(f"Error during interbank transfer: {e}")

    finally:
        if conn:
            conn.close()

# Function to receive an external transfer
def receive_external_transfer(r_number, s_number, transfer_amount, title, currency="USD"):
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Convert the transfer amount to Decimal
        transfer_amount = Decimal(transfer_amount)

        # Retrieve recipient's account ID from your bank
        cursor.execute("SELECT id_a, balance FROM accounts WHERE a_number = %s", (r_number,))
        recipient_result = cursor.fetchone()

        if recipient_result:
            # Recipient's account is within your bank
            recipient_account_id = recipient_result[0]
            recipient_balance = Decimal(recipient_result[1])

            # Update recipient's balance
            new_recipient_balance = recipient_balance + transfer_amount
            cursor.execute("""
                UPDATE accounts 
                SET balance = %s 
                WHERE id_a = %s
            """, (new_recipient_balance, recipient_account_id))

            # Add record to recipient's history
            description = f"External transfer from {s_number}" if s_number else f"External transfer: {title}"
            cursor.execute("""
                INSERT INTO history 
                (id_a, event_type, description, amount, balance_after_event, event_date)
                VALUES (%s, %s, %s, %s, %s, %s)
            """, (
                recipient_account_id,  # Now using recipient_account_id
                'Incoming Transfer',
                description,
                transfer_amount,
                new_recipient_balance,
                datetime.now().strftime('%Y-%m-%d %H:%M:%S')  # event_date
            ))

            # Add record to interbank transfers table
            transfer_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            cursor.execute("""
                INSERT INTO interbank_transfers 
                (s_number, r_number, title, description, amount, currency, transfer_date)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """, (
                s_number,
                r_number,
                title,
                f"Transfer from: {s_number} - {title}",
                transfer_amount,
                currency,
                transfer_date
            ))

            print(f"External transfer of {transfer_amount} has been received.")

        else:
            # Recipient's account is not in your bank (external transfer)
            print(f"Recipient's account {r_number} is not in your bank. It will be treated as an external transfer.")
            # In this case, treat it as an interbank transfer
            # You can add additional operations related to external transfers (e.g., external table registration)

        conn.commit()

    except (mariadb.Error, ValueError) as e:
        if conn:
            conn.rollback()
        print(f"Error during receiving external transfer: {e}")

    finally:
        if conn:
            conn.close()

# Function to detect outlier transfers
def detect_outlier_transfers(contamination=0.05, output_file='outlier_transfers.csv'):
    """
    Detects outlier transfers for each account separately based on data from the MariaDB database
    and saves the results to a CSV file.

    Parameters:
    - contamination: float - Percentage of data treated as anomalies (default is 0.05).
    - output_file: str - Path to the file where anomalies will be saved (default is 'outlier_transfers.csv').

    Returns:
    - DataFrame with detected anomalies.
    """
    # Query to retrieve data from SQL tables
    query = """
    SELECT 
        p.id_transfer,
        p.s_number,
        p.r_number,
        p.amount,
        k.balance,
        TIMESTAMPDIFF(DAY, k.creation_date, p.transfer_date) AS days_since_creation
    FROM bank_transfers p
    JOIN accounts k ON p.s_number = k.a_number;
    """

    # Connect to the database
    warnings.filterwarnings("ignore", message="pandas only supports SQLAlchemy connectable")
    conn = get_db_connection()
    data = pd.read_sql(query, conn)

    # Prepare the data
    data['amount'] = data['amount'].astype(float)
    data['balance'] = data['balance'].astype(float)

    # Group the data by account number
    groups = data.groupby('s_number')

    # List to store results
    results = []

    # Scale the data
    scaler = StandardScaler()

    for account, group in groups:
        # Prepare features for the account
        X = group[['amount', 'balance', 'days_since_creation']]
        X_scaled = scaler.fit_transform(X)

        # Train Isolation Forest model for each account
        model = IsolationForest(n_estimators=100, contamination=contamination, random_state=42)
        group['anomaly_score'] = model.fit_predict(X_scaled)

        # Label anomalies
        group['is_anomaly'] = group['anomaly_score'] == -1

        # Add the results to the list
        results.append(group)

    # Combine all results
    final_results = pd.concat(results)

    # Filter out the anomalies
    anomalies = final_results[final_results['is_anomaly'] == True]

    # Save results to a CSV file
    try:
        anomalies.to_csv(output_file, index=False)
        print(f"Anomalies saved to file '{output_file}'.")
    except Exception as e:
        print(f"Error saving to file: {e}")

    return anomalies
