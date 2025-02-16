import mariadb
from datetime import datetime
from sqlalchemy import create_engine
import pandas as pd
from sklearn.ensemble import IsolationForest

# Konfiguracja połączenia
db_config = {
    "host": "localhost",
    "port": 3306,
    "user": "root",
    "password": "db",
    "database": "protekt_1"
}

# Inicjalizacja połączenia z bazą danych
def get_db_connection():
    return mariadb.connect(**db_config)
import sqlite3
from datetime import datetime

# Funkcja wykonująca przelew
from datetime import datetime

from datetime import datetime
import mariadb
def wykonaj_przelew(numer_konta_nadawcy, numer_konta_odbiorcy, kwota_przelewu, tytul, opis="", waluta="PLN"):
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        conn.begin()  # Rozpoczęcie transakcji

        # Pobieranie salda nadawcy
        print("Pobieranie salda nadawcy...")
        cursor.execute("SELECT saldo FROM konta WHERE numer_konta = %s", (numer_konta_nadawcy,))
        wynik_nadawcy = cursor.fetchone()

        if wynik_nadawcy is None:
            print("Konto nadawcy nie istnieje!")
            conn.rollback()
            return

        saldo_nadawcy = wynik_nadawcy[0]

        if saldo_nadawcy < kwota_przelewu:
            print("Błąd: saldo konta nadawcy jest za niskie, aby wykonać przelew!")
            conn.rollback()
            return

        # Pobranie danych odbiorcy
        print("Pobieranie salda odbiorcy...")
        cursor.execute("SELECT saldo FROM konta WHERE numer_konta = %s", (numer_konta_odbiorcy,))
        wynik_odbiorcy = cursor.fetchone()

        if wynik_odbiorcy is None:
            print("Konto odbiorcy nie istnieje!")
            conn.rollback()
            return

        saldo_odbiorcy = wynik_odbiorcy[0]

        # Pobranie id_konta nadawcy
        cursor.execute("SELECT id_konta FROM konta WHERE numer_konta = %s", (numer_konta_nadawcy,))
        id_konta_nadawcy = cursor.fetchone()

        if id_konta_nadawcy is None:
            print("Konto nadawcy nie istnieje!")
            conn.rollback()
            return

        id_konta_nadawcy = id_konta_nadawcy[0]

        # Pobranie id_konta odbiorcy
        cursor.execute("SELECT id_konta FROM konta WHERE numer_konta = %s", (numer_konta_odbiorcy,))
        id_konta_odbiorcy = cursor.fetchone()

        if id_konta_odbiorcy is None:
            print("Konto odbiorcy nie istnieje!")
            conn.rollback()
            return

        id_konta_odbiorcy = id_konta_odbiorcy[0]

        # Aktualizacja sald kont osobno
        print("Aktualizowanie sald kont...")
        cursor.execute("""
            UPDATE konta 
            SET saldo = saldo - %s 
            WHERE numer_konta = %s
        """, (kwota_przelewu, numer_konta_nadawcy))

        cursor.execute("""
            UPDATE konta 
            SET saldo = saldo + %s 
            WHERE numer_konta = %s
        """, (kwota_przelewu, numer_konta_odbiorcy))

        # Dodanie wpisu do tabeli przelewy_bankowe
        print("Dodawanie wpisu do tabeli przelewy_bankowe...")

        # Pobierz bieżącą datę i czas
        data_przelewu = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

        # Przeprowadzamy operację insert dla obu kierunków przelewu
        cursor.execute("""
            INSERT INTO przelewy_bankowe 
            (numer_konta_nadawcy, numer_konta_odbiorcy, kwota, tytul, opis, waluta, data_przelewu)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (numer_konta_nadawcy, numer_konta_odbiorcy, kwota_przelewu, tytul, opis, waluta, data_przelewu))
        
        # Zatwierdzenie transakcji
        print("Zatwierdzanie transakcji...")
        conn.commit()
        print(f"Przelew o kwocie {kwota_przelewu} został wykonany.")

    except mariadb.Error as e:
        if conn:
            conn.rollback()
        print(f"Błąd podczas wykonywania przelewu: {e}")

    finally:
        if conn:
            conn.close()


from decimal import Decimal
from datetime import datetime
import mariadb

def wykonaj_przelew_miedzybankowy(numer_konta_nadawcy, numer_konta_odbiorcy, kwota_przelewu, tytul, waluta="PLN"):
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Zamiana kwoty przelewu na Decimal
        kwota_przelewu = Decimal(kwota_przelewu)

        # Pobranie id_konta nadawcy
        cursor.execute("SELECT id_konta, saldo FROM konta WHERE numer_konta = %s", (numer_konta_nadawcy,))
        wynik_nadawcy = cursor.fetchone()

        if not wynik_nadawcy:
            raise ValueError("Konto nadawcy nie istnieje w Twoim banku")

        id_konta_nadawcy = wynik_nadawcy[0]
        saldo_nadawcy = Decimal(wynik_nadawcy[1])

        if saldo_nadawcy < kwota_przelewu:
            raise ValueError("Niewystarczające środki na koncie nadawcy")

        # Aktualizacja salda nadawcy
        nowe_saldo_nadawcy = saldo_nadawcy - kwota_przelewu
        cursor.execute("""
            UPDATE konta 
            SET saldo = %s 
            WHERE id_konta = %s
        """, (nowe_saldo_nadawcy, id_konta_nadawcy))

        # Pobranie id_konta odbiorcy (zakładając, że może być to konto zewnętrzne)
        cursor.execute("SELECT id_konta FROM konta WHERE numer_konta = %s", (numer_konta_odbiorcy,))
        wynik_odbiorcy = cursor.fetchone()

        if wynik_odbiorcy:
            id_konta_odbiorcy = wynik_odbiorcy[0]
            typ_przelewu = 'Wewnętrzny'
        else:
            id_konta_odbiorcy = None
            typ_przelewu = 'Zewnętrzny'

        # Pobranie bieżącej daty i czasu
        data_przelewu = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

        # Dodanie wpisu do tabeli przelewy_miedzybankowe
        cursor.execute("""
            INSERT INTO przelewy_miedzybankowe 
            (numer_konta_nadawcy, numer_konta_odbiorcy, tytul, opis, kwota, waluta, data_przelewu)
            VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (
            numer_konta_nadawcy,
            numer_konta_odbiorcy,
            tytul,
            f"Przelew do: {numer_konta_odbiorcy} - {tytul}",
            kwota_przelewu,
            waluta,
            data_przelewu
        ))

        # Dodanie wpisu do historii dla nadawcy
        cursor.execute("""
            INSERT INTO historia 
            (id_konta, typ_zdarzenia, opis, kwota, saldo_po_zdarzeniu)
            SELECT id_konta, 'Przelew wychodzący', %s, %s, saldo
            FROM konta WHERE id_konta = %s
        """, (
            f"Przelew do: {numer_konta_odbiorcy} - {tytul}",
            -kwota_przelewu,
            id_konta_nadawcy
        ))

        # Dodanie wpisu do historii dla odbiorcy (jeśli jest to konto w Twoim banku)
        if id_konta_odbiorcy:
            cursor.execute("""
                INSERT INTO historia 
                (id_konta, typ_zdarzenia, opis, kwota, saldo_po_zdarzeniu)
                SELECT id_konta, 'Przelew przychodzący', %s, %s, saldo
                FROM konta WHERE id_konta = %s
            """, (
                f"Przelew od: {numer_konta_nadawcy} - {tytul}",
                kwota_przelewu,
                id_konta_odbiorcy
            ))

        conn.commit()
        print(f"Przelew międzybankowy o kwocie {kwota_przelewu} został wykonany.")

    except (mariadb.Error, ValueError) as e:
        if conn:
            conn.rollback()
        print(f"Błąd podczas wykonywania przelewu międzybankowego: {e}")

    finally:
        if conn:
            conn.close()





def odbierz_przelew_zewnetrzny(numer_konta_odbiorcy, numer_konta_nadawcy, kwota_przelewu, tytul, waluta="PLN"):
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Zamiana kwoty przelewu na Decimal
        kwota_przelewu = Decimal(kwota_przelewu)

        # Pobranie id_konta odbiorcy z Twojego banku
        cursor.execute("SELECT id_konta, saldo FROM konta WHERE numer_konta = %s", (numer_konta_odbiorcy,))
        wynik_odbiorcy = cursor.fetchone()

        if wynik_odbiorcy:
            # Konto odbiorcy jest w Twoim banku
            id_konta_odbiorcy = wynik_odbiorcy[0]
            saldo_odbiorcy = Decimal(wynik_odbiorcy[1])

            # Aktualizacja salda odbiorcy
            nowe_saldo_odbiorcy = saldo_odbiorcy + kwota_przelewu
            cursor.execute("""
                UPDATE konta 
                SET saldo = %s 
                WHERE id_konta = %s
            """, (nowe_saldo_odbiorcy, id_konta_odbiorcy))

            # Dodanie wpisu do historii odbiorcy
            opis = f"Przelew zewnętrzny od {numer_konta_nadawcy}" if numer_konta_nadawcy else f"Przelew zewnętrzny: {tytul}"
            cursor.execute("""
                INSERT INTO historia 
                (id_konta, typ_zdarzenia, opis, kwota, saldo_po_zdarzeniu, data_zdarzenia)
                VALUES (%s, %s, %s, %s, %s, %s)
            """, (
                id_konta_odbiorcy,  # Teraz używamy id_konta
                'Przelew przychodzący',
                opis,
                kwota_przelewu,
                nowe_saldo_odbiorcy,
                datetime.now().strftime('%Y-%m-%d %H:%M:%S')  # data_zdarzenia
            ))

            # Dodanie wpisu do tabeli przelewy_miedzybankowe
            data_przelewu = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            cursor.execute("""
                INSERT INTO przelewy_miedzybankowe 
                (numer_konta_nadawcy, numer_konta_odbiorcy, tytul, opis, kwota, waluta, data_przelewu)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
            """, (
                numer_konta_nadawcy,
                numer_konta_odbiorcy,
                tytul,
                f"Przelew od: {numer_konta_nadawcy} - {tytul}",
                kwota_przelewu,
                waluta,
                data_przelewu
            ))

            print(f"Przelew zewnętrzny o kwocie {kwota_przelewu} został odebrany.")

        else:
            # Konto odbiorcy nie jest w Twoim banku (przelew zewnętrzny)
            print(f"Konto odbiorcy {numer_konta_odbiorcy} nie jest w Twoim banku. Będzie traktowane jako przelew zewnętrzny.")
            # W tym przypadku, gdy konto nie jest w Twoim banku, traktujemy to jako przelew międzybankowy
            # Dodatkowe operacje dla przelewu zewnętrznego, jeżeli trzeba

            # Możesz dodać dodatkowe operacje związane z przelewem zewnętrznym (np. rejestracja w zewnętrznej tabeli)

        conn.commit()

    except (mariadb.Error, ValueError) as e:
        if conn:
            conn.rollback()
        print(f"Błąd podczas odbierania przelewu zewnętrznego: {e}")

    finally:
        if conn:
            conn.close()









import pandas as pd
from sklearn.ensemble import IsolationForest
from sklearn.preprocessing import StandardScaler

import pymysql
import pandas as pd
import warnings

def detekcja_odstajacych_przelewow(contamination=0.05, output_file='anomalie_przelewy.csv'):
    """
    Wykrywa odstające przelewy dla każdego konta osobno na podstawie danych z bazy danych MariaDB
    i zapisuje wyniki do pliku CSV.

    Parametry:
    - contamination: float - Procent danych, które są traktowane jako anomalie (domyślnie 0.05).
    - output_file: str - Ścieżka do pliku, w którym zapisane będą anomalie (domyślnie 'anomalie_przelewy.csv').

    Zwraca:
    - DataFrame z wykrytymi anomaliami.
    """
    # Pobranie danych z tabel SQL
    query = """
    SELECT 
        p.id_przelewu,
        p.numer_konta_nadawcy,
        p.numer_konta_odbiorcy,
        p.kwota,
        k.saldo,
        TIMESTAMPDIFF(DAY, k.data_utworzenia, p.data_przelewu) AS dni_od_utworzenia
    FROM przelewy_bankowe p
    JOIN konta k ON p.numer_konta_nadawcy = k.numer_konta;
    """

    # Łączenie z bazą danych (dostosuj dane logowania)
    warnings.filterwarnings("ignore", message="pandas only supports SQLAlchemy connectable")
    conn = get_db_connection()
    data = pd.read_sql(query, conn)

    # Przygotowanie danych
    data['kwota'] = data['kwota'].astype(float)
    data['saldo'] = data['saldo'].astype(float)

    # Grupowanie danych po numerze konta
    groups = data.groupby('numer_konta_nadawcy')

    # Lista do przechowywania wyników
    results = []

    # Skalowanie danych
    scaler = StandardScaler()

    for account, group in groups:
        # Przygotowanie cech dla danego konta
        X = group[['kwota', 'saldo', 'dni_od_utworzenia']]
        X_scaled = scaler.fit_transform(X)

        # Trening modelu Isolation Forest dla jednego konta
        model = IsolationForest(n_estimators=100, contamination=contamination, random_state=42)
        group['anomaly_score'] = model.fit_predict(X_scaled)

        # Oznaczenie anomalii
        group['is_anomaly'] = group['anomaly_score'] == -1

        # Dodanie wyników do listy
        results.append(group)

    # Scal wszystkie wyniki
    final_results = pd.concat(results)

    # Wyfiltrowanie anomalii
    anomalies = final_results[final_results['is_anomaly'] == True]

    # Zapisanie wyników do pliku CSV
    try:
        anomalies.to_csv(output_file, index=False)
        print(f"Anomalie zapisane do pliku '{output_file}'.")
    except Exception as e:
        print(f"Błąd podczas zapisywania do pliku: {e}")

    return anomalies
