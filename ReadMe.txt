Banking System Script in SQL:

This database system includes multiple tables to manage customers, accounts, transactions, loans, and transfers efficiently.

Tables:

personal_data – Stores customer details (name, address, contact information, date of birth).
account_types – Defines different types of accounts (Savings, Checking, Business, Student, Joint).
account – Contains customer accounts with balances and creation dates.
login – Stores login credentials (username, password) linked to customers.
credit – Manages loans, tracking amounts, interest rates, payment status.
deposit – Stores fixed-term deposits with interest rates and maturity dates.
transfers – Handles internal transfers between customer accounts.
interbank_transfers – Manages transfers to/from external banks.
cards – Stores bank card details (card number, expiration, CVV, type).
transactions – Logs all transactions (deposits, withdrawals, transfers).
account_history – Tracks balance changes due to transactions, fees, and transfers.

Stored Procedures:

1. account_creation
Creates a new customer and an account at the same time.
Inserts personal details into personal_data.
Creates an account with an initial balance.
Links the account to the customer.

2. update_personal_data
Updates customer information.
If the customer does not exist, an error is triggered.

3. add_credit
Grants a loan to a customer if they don't already have one.
Checks if the account already has an active loan.
Calculates monthly installment amounts.
Deposits the loan into the customer’s account.
Creates a new entry in credit.

Triggers:

1. after_transaction
Automatically updates account balance after a deposit or withdrawal.
Deposit → Balance increases.
Withdrawal → Balance decreases.
Creates a history entry in account_history.

2. check_balance_before_withdrawal
Prevents overdrafts by checking available balance before withdrawal.
If a user tries to withdraw more than they have, the transaction is blocked.

3. after_transfer
Handles internal money transfers between accounts.
Deducts funds from the sender.
Increases funds for the recipient.
Logs both changes in account_history.

Events:

1. account_fee
Runs every month to deduct a $10 service fee from all accounts with enough balance.
If the account has less than $10, it is skipped.

2. check_card_expiration
Runs monthly to check for expired bank cards and automatically renew them.
Extends expiration date by 3 years.
Generates a new CVV.
Logs the renewal in account_history.
If any expired cards are found, they are renewed automatically.




Banking System Script in Python:

This script provides various banking functionalities using MariaDB, SQLAlchemy, pandas, and Scikit-learn for anomaly detection. It includes functions for bank transfers, interbank transfers, external transactions, and outlier detection.

get_db_connection() – Establishes a connection to the MariaDB database using the specified configuration. It returns an active database connection that allows interaction with the database.

make_a_transfer(s_number, r_number, transfer_amount, title, description="", currency="USD") – Performs a bank transfer between two accounts within the same bank. It checks if the sender has sufficient balance, updates the balances of both the sender and recipient, and records the transaction in the bank_transfers table.

make_interbank_transfer(s_number, r_number, transfer_amount, title, currency="USD") – Handles interbank transfers, meaning transactions between different banks. It verifies the sender's balance, deducts the amount from their account, determines whether the recipient is in the same bank or an external institution, and logs the transaction in the interbank_transfers table.

receive_external_transfer(r_number, s_number, transfer_amount, title, currency="USD") – Processes incoming transfers from external banks. If the recipient's account exists in the system, the function updates the balance, records the transaction in the account history, and logs the transfer in the interbank_transfers table. If the recipient's account is not found, the transfer is treated as an external transaction.

detect_outlier_transfers(contamination=0.05, output_file='outlier_transfers.csv') – Detects unusual or potentially fraudulent transactions using the Isolation Forest machine learning algorithm. It analyzes transactions for anomalies based on factors such as amount, balance, and account age. Detected anomalies are saved in a CSV file for further investigation.


