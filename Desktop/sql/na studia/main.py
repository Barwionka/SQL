import mariadb
from datetime import datetime

# Połączenie z bazą danych
conn = mariadb.connect(
    host="localhost",
    user="root",
    password="dupa",
    database="bank1",
    port=3307
)

cursor = conn.cursor()

# Funkcja do wykonania przelewu
def wykonaj_przelew(id_konta_nadawcy, id_konta_odbiorcy, kwota_przelewu):
    try:
        # Rozpoczęcie transakcji
        conn.begin()

        # Sprawdzenie salda na koncie nadawcy
        cursor.execute("SELECT saldo FROM konta WHERE id_konta = %s", (id_konta_nadawcy,))
        saldo_nadawcy = cursor.fetchone()

        if saldo_nadawcy is None:
            print("Konto nadawcy nie istnieje!")
            conn.rollback()  # Wycofanie transakcji, jeśli konto nie istnieje
            return

        saldo_nadawcy = saldo_nadawcy[0]

        # Sprawdzenie, czy saldo na koncie nadawcy jest wystarczające
        if saldo_nadawcy < kwota_przelewu:
            print("Błąd: saldo konta nadawcy jest za niskie, aby wykonać przelew!")
            conn.rollback()  # Wycofanie transakcji, jeśli saldo jest za niskie
            return

        # Dodanie rekordu do tabeli przelewy
        cursor.execute("""
            INSERT INTO przelewy (id_konta_nadawcy, id_konta_odbiorcy, kwota, data_przelewu, typ_przelewu) 
            VALUES (%s, %s, %s, %s, %s)
        """, (id_konta_nadawcy, id_konta_odbiorcy, kwota_przelewu, datetime.now(), "Standardowy"))

        # Zatwierdzenie transakcji
        conn.commit()
        print(f"Przelew o kwocie {kwota_przelewu} został wykonany.")

    except mariadb.Error as e:
        # W przypadku błędu wycofanie transakcji
        print(f"Błąd podczas wykonywania przelewu: {e}")
        conn.rollback()


# Przykład wywołania funkcji
# wykonaj_przelew(1, 2, 500)  # Wykonaj przelew 500 z konta o id 1 na konto o id 2

# Zamknięcie połączenia
cursor.close()
conn.close()


import mariadb
from datetime import date

# Połączenie z bazą danych
try:
    conn = mariadb.connect(
        host="localhost",
        user="root",
        password="dupa",
        database="bank1",
        port=3307
    )
    cursor = conn.cursor()
    print("Połączono z bazą danych!")
except mariadb.Error as e:
    print(f"Błąd połączenia z bazą danych: {e}")
    exit(1)

# Funkcja do obliczania odsetek i aktualizacji bazy danych
def oblicz_odsetki():
    try:
        # Pobierz zakończone lokaty (data_koniec <= CURRENT_DATE i zrealizowana = 1)
        query = """
        SELECT l.id_lokaty, l.id_konta, l.kwota, l.oprocentowanie, l.liczba_kapitalizacji, l.data_start, l.data_koniec, k.saldo
        FROM lokaty l
        JOIN konta k ON l.id_konta = k.id_konta
        WHERE l.data_koniec <= CURRENT_DATE AND l.zrealizowana = 1;
        """
        cursor.execute(query)
        lokaty = cursor.fetchall()

        if not lokaty:
            print("Brak lokat do przetworzenia.")
            return

        for lokata in lokaty:
            id_lokaty, id_konta, kwota, oprocentowanie, liczba_kapitalizacji, data_start, data_koniec, saldo = lokata

            # Oblicz liczbę lat (t)
            dni_trwania = (data_koniec - data_start).days
            liczba_lat = dni_trwania / 365.0

            # Konwersja na float
            kwota = float(kwota)
            r = float(oprocentowanie) / 100
            n = int(liczba_kapitalizacji)

            # Oblicz odsetki składane
            A = kwota * (1 + r / n) ** (n * liczba_lat)  # Kwota końcowa
            odsetki = round(A - kwota, 2)  # Tylko odsetki

            # Dodaj odsetki do salda konta
            nowe_saldo = float(saldo) + odsetki
            cursor.execute("UPDATE konta SET saldo = ? WHERE id_konta = ?", (nowe_saldo, id_konta))

            # Zaktualizuj lokatę (zmiana zrealizowana na 2)
            cursor.execute(
                "UPDATE lokaty SET zrealizowana = 2, naliczone_odsetki = ? WHERE id_lokaty = ?",
                (odsetki, id_lokaty)
            )

            # Dodaj zdarzenie do historii
            opis = f"Lokata zakończona. Naliczone odsetki: {odsetki} zł."
            cursor.execute("""
            INSERT INTO historia (id_konta, typ_zdarzenia, opis, kwota, saldo_po_zdarzeniu)
            VALUES (?, 'Lokata - zakończenie', ?, ?, ?)
            """, (id_konta, opis, odsetki, nowe_saldo))

        # Zatwierdź zmiany
        conn.commit()
        print("Odsetki naliczone i zaktualizowano bazę danych.")
    except mariadb.Error as e:
        print(f"Błąd podczas operacji: {e}")
        conn.rollback()




# Wywołanie funkcji
oblicz_odsetki()

# Zamknij połączenie
cursor.close()
conn.close()
print("Połączenie z bazą danych zamknięte.")











