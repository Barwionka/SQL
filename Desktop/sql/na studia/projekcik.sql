
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

ALTER TABLE lokaty ADD COLUMN zrealizowana INTEGER DEFAULT 0;
-- lokata niezrealizwana 0, lokata zrealizowana 1



CREATE TABLE historia_konta (
    id_historia INT AUTO_INCREMENT PRIMARY KEY,
    id_konta INT,
    typ_zdarzenia VARCHAR(255),
    opis TEXT,
    kwota DECIMAL(15, 2),
    saldo_po_zdarzeniu DECIMAL(15, 2),
    data_zdarzenia TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_konta) REFERENCES konta(id_konta)
);



select * from dane_osobowe 
select * from karty
select * from konta 
select * from logowanie
select * from lokaty 
select * from historia_konta
-- lokata na rok, kapitalizacja co miesiąc !!
-- lokata na rok, kapitalizacja kwartalna !!
-- jakaś jest trwająca i odsetki (kolejna kolumna - tylko odsetki) dodają się do kwoty (?) (kwota = kwota + odsetki)
select * from przelewy
-- tytuły przelewów (?)
select * from typy_kont 
select * from kredyty 
-- jakaś jest trwająca i kwota pozostała zmienia się (?)
-- ile zapłcone, ile pozostało i jak zostanie 0 to znika :o
select * from wplaty_wyplaty 

ALTER DATABASE protekt_1 CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
SELECT VERSION();

ALTER DATABASE projekcik CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

ALTER TABLE dane_osobowe CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
ALTER TABLE karty CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
ALTER TABLE konta CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
ALTER TABLE kredyty CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
ALTER table logowanie CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
ALTER TABLE lokaty CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
ALTER TABLE przelewy CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
ALTER TABLE typy_kont CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
ALTER TABLE wplaty_wyplaty CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

CREATE TABLE historia (
    id_historia INT AUTO_INCREMENT PRIMARY KEY,
    id_konta INT,
    typ_zdarzenia VARCHAR(255),
    opis TEXT,
    kwota DECIMAL(15, 2),
    saldo_po_zdarzeniu DECIMAL(15, 2),
    data_zdarzenia TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_konta) REFERENCES konta(id_konta)
);

CREATE OR REPLACE TRIGGER po_operacji
AFTER INSERT ON wplaty_wyplaty
FOR EACH ROW
BEGIN
    IF NEW.typ_operacji = 'Wpłata' THEN
        UPDATE konta
        SET saldo = saldo + NEW.kwota
        WHERE id_konta = NEW.id_konta;
    ELSEIF NEW.typ_operacji = 'Wypłata' THEN
        UPDATE konta
        SET saldo = saldo - NEW.kwota
        WHERE id_konta = NEW.id_konta;
    END IF;

    INSERT INTO historia (id_konta, typ_zdarzenia, opis, kwota, saldo_po_zdarzeniu)
    VALUES (
        NEW.id_konta,
        NEW.typ_operacji,
        CONCAT('Operacja: ', NEW.typ_operacji, ', Kwota: ', NEW.kwota),
        CASE
            WHEN NEW.typ_operacji = 'Wpłata' THEN NEW.kwota
            ELSE -NEW.kwota
        END,
        (SELECT saldo FROM konta WHERE id_konta = NEW.id_konta)
    );
END;


-- sprawdzenie
INSERT INTO wplaty_wyplaty (id_konta, typ_operacji, kwota) VALUES (1, 'Wypłata', 200.00);
INSERT INTO wplaty_wyplaty (id_konta, typ_operacji, kwota) VALUES (1, 'Wpłata', 500.00);
SELECT saldo FROM konta WHERE id_konta = 1;

CREATE OR REPLACE TRIGGER po_przelewie
AFTER INSERT ON przelewy
FOR EACH ROW
BEGIN
    UPDATE konta
    SET saldo = saldo - NEW.kwota
    WHERE id_konta = NEW.id_konta_nadawcy;

    INSERT INTO historia (id_konta, typ_zdarzenia, opis, kwota, saldo_po_zdarzeniu)
    VALUES (
        NEW.id_konta_nadawcy,
        'Przelew wychodzący',
        CONCAT('Przelew na konto: ', (SELECT numer_konta FROM konta WHERE id_konta = NEW.id_konta_odbiorcy)),
        -NEW.kwota,
        (SELECT saldo FROM konta WHERE id_konta = NEW.id_konta_nadawcy)
    );

    UPDATE konta
    SET saldo = saldo + NEW.kwota
    WHERE id_konta = NEW.id_konta_odbiorcy;

    INSERT INTO historia (id_konta, typ_zdarzenia, opis, kwota, saldo_po_zdarzeniu)
    VALUES (
        NEW.id_konta_odbiorcy,
        'Przelew przychodzący',
        CONCAT('Przelew od konta: ', (SELECT numer_konta FROM konta WHERE id_konta = NEW.id_konta_nadawcy)),
        NEW.kwota,
        (SELECT saldo FROM konta WHERE id_konta = NEW.id_konta_odbiorcy)
    );
END;

-- sprawdzenie 
INSERT INTO przelewy (id_konta_nadawcy, id_konta_odbiorcy, kwota, waluta, typ_przelewu) VALUES (1, 2, 100.00, 'PLN', 'Przelew własny');
SELECT saldo FROM konta WHERE id_konta = 1;
SELECT saldo FROM konta WHERE id_konta = 2;

CREATE OR REPLACE TRIGGER sprawdz_saldo_przy_wyplacie
BEFORE INSERT ON wplaty_wyplaty
FOR EACH ROW
BEGIN
    IF NEW.typ_operacji = 'Wypłata' THEN
        IF (SELECT saldo FROM konta WHERE id_konta = NEW.id_konta) < NEW.kwota THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Brak wystarczających środków na koncie';
        END IF;
    END IF;
END;

-- sprawdzenie
INSERT INTO wplaty_wyplaty (id_konta, typ_operacji, kwota)
VALUES (1, 'Wypłata', 200000.00);
insert into wplaty_wyplaty (id_konta, typ_operacji, kwota)
values (1, 'Wypłata', 10.00);
select saldo from konta where id_konta=1

CREATE OR REPLACE VIEW aktywne_lokaty AS
SELECT 
    l.id_lokaty,
    k.numer_konta,
    l.kwota,
    l.oprocentowanie,
    l.data_start,
    l.data_koniec
FROM lokaty l
JOIN konta k ON l.id_konta = k.id_konta
WHERE l.zrealizowana = 0;

select * from lokaty
select * from aktywne_lokaty

CREATE OR REPLACE VIEW aktywne_kredyty AS
SELECT 
    k.id_kredytu,
    c.numer_konta,
    k.kwota,
    k.oprocentowanie,
    k.data_rozpoczecia,
    k.data_zakonczenia
FROM kredyty k
JOIN konta c ON k.id_konta = c.id_konta
WHERE k.data_zakonczenia IS NULL OR k.data_zakonczenia > CURRENT_DATE;

select * from kredyty
select * from aktywne_kredyty

CREATE OR REPLACE VIEW szczegoly_przelewow AS
SELECT 
    p.id_przelewu,
    k_nad.numer_konta AS konto_nadawcy,
    k_odb.numer_konta AS konto_odbiorcy,
    p.kwota,
    p.waluta,
    p.data_przelewu,
    p.typ_przelewu
FROM przelewy p
JOIN konta k_nad ON p.id_konta_nadawcy = k_nad.id_konta
JOIN konta k_odb ON p.id_konta_odbiorcy = k_odb.id_konta;

select * from szczegoly_przelewow

select * from historia
SELECT * FROM historia WHERE id_konta = 1;

CREATE or replace PROCEDURE tworzenie_konta(
    IN p_imie VARCHAR(50),
    IN p_nazwisko VARCHAR(50),
    IN p_pesel CHAR(11),
    IN p_adres VARCHAR(200),
    IN p_telefon VARCHAR(15),
    IN p_email VARCHAR(100),
    IN p_data_urodzenia DATE,
    IN p_numer_konta VARCHAR(26),
    IN p_id_typu INT,
    IN p_saldo DECIMAL(15,2)
)
BEGIN
    DECLARE id_osoby INT;

    INSERT INTO dane_osobowe (imie, nazwisko, pesel, adres, telefon, email, data_urodzenia)
    VALUES (p_imie, p_nazwisko, p_pesel, p_adres, p_telefon, p_email, p_data_urodzenia);

    SET id_osoby = LAST_INSERT_ID();

    INSERT INTO konta (numer_konta, id_osoby, id_typu, saldo)
    VALUES (p_numer_konta, id_osoby, p_id_typu, p_saldo);

end 

-- sprawdzenie
CALL tworzenie_konta('Konrad','Konicki','031122233','ul. Zielona 15, Nowy Sącz',
                     '500100200','k.kon@hotmail.com','2001-03-12','22222222222222222222222211',1,2.00);
select * from konta


CREATE or replace PROCEDURE aktualizuj_dane_osobowe(
    IN p_id_osoby INT,
    IN p_imie VARCHAR(50),
    IN p_nazwisko VARCHAR(50),
    IN p_adres VARCHAR(200),
    IN p_telefon VARCHAR(15),
    IN p_email VARCHAR(100)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dane_osobowe WHERE id_osoby = p_id_osoby) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Użytkownik o podanym ID nie istnieje';
    ELSE
        UPDATE dane_osobowe
        SET imie = p_imie,
            nazwisko = p_nazwisko,
            adres = p_adres,
            telefon = p_telefon,
            email = p_email
        WHERE id_osoby = p_id_osoby;
    END IF;
END;

-- sprawdzenie
CALL aktualizuj_dane_osobowe(10,'Krzysztof','Korzeniewski','ul. Nowa 10, Warszawa','600123456','k.kor@hotmail.com');

select * from dane_osobowe


CREATE or replace PROCEDURE aktywacja_lokaty(
    IN p_id_konta INT,
    IN p_kwota DECIMAL(15,2),
    IN p_oprocentowanie DECIMAL(5,2),
    IN p_data_start DATE,
    IN p_data_koniec DATE
)
BEGIN
    DECLARE v_saldo DECIMAL(15,2);
    SELECT saldo
    INTO v_saldo
    FROM konta
    WHERE id_konta = p_id_konta;

    IF v_saldo < p_kwota THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Brak wystarczających środków na koncie';
    ELSE
        INSERT INTO lokaty (id_konta, kwota, oprocentowanie, data_start, data_koniec)
        VALUES (p_id_konta, p_kwota, p_oprocentowanie, p_data_start, p_data_koniec);

        UPDATE konta
        SET saldo = saldo - p_kwota
        WHERE id_konta = p_id_konta;

        INSERT INTO historia (id_konta, typ_zdarzenia, opis, kwota, saldo_po_zdarzeniu)
        SELECT p_id_konta, 'Aktywacja lokaty', 'Założenie lokaty', p_kwota, saldo - p_kwota
        FROM konta
        WHERE id_konta = p_id_konta;
    END IF;
END

-- sprawdzenie
select * from dane_osobowe
CALL aktywacja_lokaty(1, 5000.00, 3.00, '2025-01-01', '2026-01-01');
CALL aktywacja_lokaty(2, 3000.00, 3.00, '2025-01-01', '2026-01-01');
select * from lokaty
SELECT * FROM historia WHERE id_konta = 4


-- to nizej jest po to zeby wlaczyc eventy (u mnie nie dzialalo bez tego)
SET GLOBAL event_scheduler=ON

CREATE or replace EVENT aktualizacja_lokaty
ON SCHEDULE EVERY 1 DAY
DO
BEGIN
    UPDATE lokaty
    SET zrealizowana = 1, data_koniec = CURRENT_DATE
    WHERE data_koniec <= CURRENT_DATE AND zrealizowana = 0;
END;


CREATE OR REPLACE EVENT oplata_za_konto
ON SCHEDULE EVERY 1 month 
DO
BEGIN
    INSERT INTO historia (id_konta, typ_zdarzenia, opis, kwota, saldo_po_zdarzeniu)
    select k.id_konta, 'Opłata za konto', 'Miesięczna opłata za konto', 10, k.saldo - 10
    FROM konta k
    WHERE k.saldo >= 10;

    UPDATE konta
    SET saldo = saldo - 10
    WHERE saldo >= 10;
END;


-- sprawdzenie
SELECT * FROM konta WHERE id_konta = 1;
SELECT * FROM kredyty WHERE id_konta = 1;

select * from konta
select * from historia




