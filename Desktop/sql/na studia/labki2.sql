
-- Tabela: dane_osobowe
CREATE TABLE dane_osobowe (
    id_osoby INT AUTO_INCREMENT PRIMARY KEY,
    imie VARCHAR(50) NOT NULL,
    nazwisko VARCHAR(50) NOT NULL,
    pesel CHAR(11) UNIQUE NOT NULL,
    adres VARCHAR(200),
    telefon VARCHAR(15),
    email VARCHAR(100),
    data_urodzenia DATE,
    data_utworzenia DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tabela: typy_kont
CREATE TABLE typy_kont (
    id_typu INT AUTO_INCREMENT PRIMARY KEY,
    nazwa_typu VARCHAR(50) NOT NULL,
    opis TEXT
);

-- Tabela: konta
CREATE TABLE konta (
    id_konta INT AUTO_INCREMENT PRIMARY KEY,
    numer_konta VARCHAR(26) UNIQUE NOT NULL,
    id_osoby INT NOT NULL,
    id_typu INT NOT NULL,
    saldo DECIMAL(15,2) DEFAULT 0.00,
    data_utworzenia DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_osoby) REFERENCES dane_osobowe(id_osoby),
    FOREIGN KEY (id_typu) REFERENCES typy_kont(id_typu)
);

-- Tabela: logowanie
CREATE TABLE logowanie (
    id_logowania INT AUTO_INCREMENT PRIMARY KEY,
    id_osoby INT NOT NULL,
    login VARCHAR(50) UNIQUE NOT NULL,
    haslo VARCHAR(255) NOT NULL,
    FOREIGN KEY (id_osoby) REFERENCES dane_osobowe(id_osoby)
);

-- Tabela: kredyty
CREATE TABLE kredyty (
    id_kredytu INT AUTO_INCREMENT PRIMARY KEY,
    id_konta INT NOT NULL,
    kwota DECIMAL(15,2) NOT NULL,
    oprocentowanie DECIMAL(5,2) NOT NULL,
    data_rozpoczecia DATE NOT NULL,
    data_zakonczenia DATE,
    FOREIGN KEY (id_konta) REFERENCES konta(id_konta)
);

-- Tabela: lokaty
CREATE TABLE lokaty (
    id_lokaty INT AUTO_INCREMENT PRIMARY KEY,
    id_konta INT NOT NULL,
    kwota DECIMAL(15,2) NOT NULL,
    oprocentowanie DECIMAL(5,2) NOT NULL,
    data_start DATE NOT NULL,
    data_koniec DATE,
    FOREIGN KEY (id_konta) REFERENCES konta(id_konta)
);

-- Tabela: przelewy
CREATE TABLE przelewy (
    id_przelewu INT AUTO_INCREMENT PRIMARY KEY,
    id_konta_nadawcy INT NOT NULL,
    id_konta_odbiorcy INT NOT NULL,
    kwota DECIMAL(15,2) NOT NULL,
    waluta VARCHAR(10) DEFAULT 'PLN',
    data_przelewu DATETIME DEFAULT CURRENT_TIMESTAMP,
    typ_przelewu VARCHAR(50),
    FOREIGN KEY (id_konta_nadawcy) REFERENCES konta(id_konta),
    FOREIGN KEY (id_konta_odbiorcy) REFERENCES konta(id_konta)
);

-- Tabela: karty
CREATE TABLE karty (
    id_karty INT AUTO_INCREMENT PRIMARY KEY,
    id_konta INT NOT NULL,
    numer_karty VARCHAR(16) UNIQUE NOT NULL,
    cvv CHAR(3) NOT NULL,
    data_waznosci DATE NOT NULL,
    typ_karty VARCHAR(50),
    FOREIGN KEY (id_konta) REFERENCES konta(id_konta)
);

-- Tabela: wplaty_wyplaty
CREATE TABLE wplaty_wyplaty (
    id_operacji INT AUTO_INCREMENT PRIMARY KEY,
    id_konta INT NOT NULL,
    typ_operacji VARCHAR(50) NOT NULL,
    kwota DECIMAL(15,2) NOT NULL,
    data_operacji DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_konta) REFERENCES konta(id_konta)
);

-- Zmieniamy kodowanie bazy danych
ALTER DATABASE projekt_1 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE dane_osobowe CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE karty CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE konta CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE kredyty CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE logowanie CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE lokaty CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE przelewy CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE typy_kont CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE wplaty_wyplaty CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;




-- Insert do tabeli dane_osobowe
INSERT INTO dane_osobowe (imie, nazwisko, pesel, adres, telefon, email, data_urodzenia)
VALUES
('Jan', 'Kowalski', '12345678901', 'ul. Zielona 15, Warszawa', '500100200', 'jan.kowalski@example.com', '1985-03-12'),
('Anna', 'Nowak', '23456789012', 'ul. Cicha 5, Kraków', '600300400', 'anna.nowak@example.com', '1990-07-25'),
('Piotr', 'Wiśniewski', '34567890123', 'ul. Słoneczna 10, Wrocław', '700400500', 'piotr.wisniewski@example.com', '1978-12-08');

-- Insert do tabeli typy_kont
INSERT INTO typy_kont (nazwa_typu, opis)
VALUES
('Osobiste', 'Konto osobiste do codziennego użytku'),
('Firmowe', 'Konto dla firm i działalności gospodarczych'),
('Oszczędnościowe', 'Konto oszczędnościowe z wysokim oprocentowaniem');

-- Insert do tabeli konta
INSERT INTO konta (numer_konta, id_osoby, id_typu, saldo)
VALUES
('12345678901234567890123456', 1, 1, 1500.00),
('23456789012345678901234567', 2, 3, 10000.00),
('34567890123456789012345678', 3, 2, 5000.00);

-- Insert do tabeli logowanie
INSERT INTO logowanie (id_osoby, login, haslo)
VALUES
(1, 'jan_kowalski', 'haslo123'),
(2, 'anna_nowak', 'tajnehaslo'),
(3, 'piotr_wisniewski', 'trudnehaslo');

-- Insert do tabeli kredyty
INSERT INTO kredyty (id_konta, kwota, oprocentowanie, data_rozpoczecia, data_zakonczenia)
VALUES
(1, 50000.00, 3.5, '2023-01-01', '2033-01-01'),
(3, 100000.00, 4.0, '2022-06-01', '2032-06-01');


-- Insert do tabeli lokaty
INSERT INTO lokaty (id_konta, kwota, oprocentowanie, data_start, data_koniec)
VALUES
(2, 5000.00, 2.5, '2023-03-01', '2024-03-01'),
(3, 15000.00, 3.0, '2023-01-01', '2025-01-01');

-- Insert do tabeli przelewy
INSERT INTO przelewy (id_konta_nadawcy, id_konta_odbiorcy, kwota, waluta, typ_przelewu)
VALUES
(1, 2, 250.00, 'PLN', 'Przelew własny'),
(3, 1, 500.00, 'PLN', 'Przelew zewnętrzny');

-- Insert do tabeli karty
INSERT INTO karty (id_konta, numer_karty, cvv, data_waznosci, typ_karty)
VALUES
(1, '1111222233334444', '123', '2026-12-31', 'Debetowa'),
(2, '5555666677778888', '456', '2027-03-31', 'Kredytowa');

-- Insert do tabeli wplaty_wyplaty
INSERT INTO wplaty_wyplaty (id_konta, typ_operacji, kwota)
VALUES
(1, 'Wpłata', 1000.00),
(1, 'Wypłata', 200.00),
(3, 'Wpłata', 3000.00);

select * from dane_osobowe 
select * from karty
select * from konta 
select * from logowanie
select * from lokaty 
-- rodzaj lokaty: miesięczna, kwartalna, roczna (kolejna kolumna)
-- jakaś jest trwająca i odsetki (kolejna kolumna - tylko odsetki) dodają się do kwoty (?) (kwota = kwota + odsetki)
select * from przelewy
-- tytuły przelewów (?)
select * from typy_kont 
select * from kredyty 
-- jakaś jest trwająca i kwota pozostała zmienia się (?)
-- ile zapłcone, ile pozostało i jak zostanie 0 to znika :o
select * from wplaty_wyplaty 

