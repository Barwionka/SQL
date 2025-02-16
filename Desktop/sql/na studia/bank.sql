create TABLE dane_osobowe (
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

CREATE TABLE typy_kont (
    id_typu INT AUTO_INCREMENT PRIMARY KEY,
    nazwa_typu VARCHAR(50) NOT NULL,
    opis TEXT
);

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

CREATE TABLE logowanie (
    id_logowania INT AUTO_INCREMENT PRIMARY KEY,
    id_osoby INT NOT NULL,
    login VARCHAR(50) UNIQUE NOT NULL,
    haslo VARCHAR(255) NOT NULL,
    FOREIGN KEY (id_osoby) REFERENCES dane_osobowe(id_osoby)
);

CREATE or replace TABLE kredyty (
    id_kredytu INT AUTO_INCREMENT PRIMARY KEY,
    id_konta INT NOT NULL,
    kwota DECIMAL(15,2) NOT NULL,
    oprocentowanie DECIMAL(5,2) NOT NULL,
    data_rozpoczecia DATE default CURRENT_DATE,
    data_zakonczenia DATE,
    liczba_rat INT,
    rata_miesieczna DECIMAL(15,2),
    do_splaty DECIMAL(15,2),
    status VARCHAR(20) DEFAULT 'Aktywny',
    FOREIGN KEY (id_konta) REFERENCES konta(id_konta)
);


CREATE or replace TABLE lokaty (
    id_lokaty INT AUTO_INCREMENT PRIMARY KEY,
    id_konta INT NOT NULL,
    kwota DECIMAL(15,2) NOT NULL,
    oprocentowanie DECIMAL(5,2) NOT NULL,
    liczba_kapitalizacji INT DEFAULT 1,
    data_start DATE NOT NULL,
    data_koniec DATE,
    zrealizowana INTEGER DEFAULT 0,
    FOREIGN KEY (id_konta) REFERENCES konta(id_konta)
);

CREATE OR REPLACE TABLE przelewy_miedzybankowe (
    id_przelewu INT AUTO_INCREMENT PRIMARY KEY,
    numer_konta_nadawcy VARCHAR(26) NOT NULL,
    numer_konta_odbiorcy VARCHAR(26) NOT NULL,
    tytul VARCHAR(255),
    opis TEXT,
    kwota DECIMAL(15, 2) NOT NULL,
    waluta VARCHAR(10) DEFAULT 'PLN',
    data_przelewu DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE TABLE przelewy_bankowe (
    id_przelewu INT AUTO_INCREMENT PRIMARY KEY,
    numer_konta_nadawcy VARCHAR(26) NOT NULL,
    numer_konta_odbiorcy VARCHAR(26) NOT NULL,
    tytul VARCHAR(255),
    opis TEXT,
    kwota DECIMAL(15, 2) NOT NULL,
    waluta VARCHAR(10) DEFAULT 'PLN',
    data_przelewu DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE karty (
    id_karty INT AUTO_INCREMENT PRIMARY KEY,
    id_konta INT NOT NULL,
    numer_karty VARCHAR(16) UNIQUE NOT NULL,
    cvv CHAR(3) NOT NULL,
    data_waznosci DATE NOT NULL,
    typ_karty VARCHAR(50),
    FOREIGN KEY (id_konta) REFERENCES konta(id_konta)
);

CREATE TABLE wplaty_wyplaty (
    id_operacji INT AUTO_INCREMENT PRIMARY KEY,
    id_konta INT NOT NULL,
    typ_operacji VARCHAR(50) NOT NULL,
    kwota DECIMAL(15,2) NOT NULL,
    data_operacji DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_konta) REFERENCES konta(id_konta)
);

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


INSERT INTO dane_osobowe (imie, nazwisko, pesel, adres, telefon, email, data_urodzenia)
VALUES
('Jan', 'Kowalski', '12345678901', 'ul. Zielona 15, Warszawa', '500100200', 'jan.kowalski@example.com', '1985-03-12'),
('Anna', 'Nowak', '23456789012', 'ul. Cicha 5, Kraków', '600300400', 'anna.nowak@example.com', '1990-07-25'),
('Piotr', 'Wiśniewski', '34567890123', 'ul. Słoneczna 10, Wrocław', '700400500', 'piotr.wisniewski@example.com', '1978-12-08');

INSERT INTO typy_kont (nazwa_typu, opis)
VALUES
('Osobiste', 'Konto osobiste do codziennego użytku'),
('Firmowe', 'Konto dla firm i działalności gospodarczych');
 
INSERT INTO konta (numer_konta, id_osoby, id_typu, saldo)
VALUES
('12345678901234567890123456', 1, 1, 1500.00),
('23456789012345678901234567', 2, 2, 10000.00),
('34567890123456789012345678', 3, 2, 5000.00),
('11111111111111111111111111', 1, 1, 200000.00);

INSERT INTO logowanie (id_osoby, login, haslo)
VALUES
(1, 'jan_kowalski', 'haslo123'),
(2, 'anna_nowak', 'tajnehaslo'),
(3, 'piotr_wisniewski', 'trudnehaslo');

INSERT INTO lokaty (id_konta, kwota, oprocentowanie, liczba_kapitalizacji, data_start, data_koniec)
VALUES
(2, 5000.00, 2.5, 12, '2023-03-01', '2024-03-01'),
(3, 15000.00, 3.0, 4, '2023-01-01', '2025-01-01'),
(1, 20000.00, 2.5, 4, '2023-01-01', '2026-01-01');

INSERT INTO karty (id_konta, numer_karty, cvv, data_waznosci, typ_karty)
VALUES
(1, '1111222233334444', '123', '2026-12-31', 'Debetowa'),
(2, '5555666677778888', '456', '2027-03-31', 'Kredytowa');

INSERT INTO wplaty_wyplaty (id_konta, typ_operacji, kwota)
VALUES
(1, 'Wpłata', 1000.00),
(1, 'Wypłata', 200.00),
(3, 'Wpłata', 3000.00);



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
AFTER INSERT ON przelewy_bankowe
FOR EACH ROW
BEGIN
    DECLARE id_nadawcy INT;
    DECLARE id_odbiorcy INT;

    SELECT id_konta INTO id_nadawcy 
    FROM konta 
    WHERE numer_konta = NEW.numer_konta_nadawcy;
    
    SELECT id_konta INTO id_odbiorcy 
    FROM konta 
    WHERE numer_konta = NEW.numer_konta_odbiorcy;

    UPDATE konta
    SET saldo = saldo - NEW.kwota
    WHERE numer_konta = NEW.numer_konta_nadawcy;

    INSERT INTO historia (id_konta, typ_zdarzenia, opis, kwota, saldo_po_zdarzeniu)
    SELECT 
        id_nadawcy,
        'Przelew wychodzący',
        CASE 
            WHEN NEW.opis IS NOT NULL AND NEW.opis != '' 
            THEN CONCAT(NEW.tytul, ': ', NEW.opis)
            ELSE NEW.tytul
        END,
        -NEW.kwota,
        saldo
    FROM konta 
    WHERE numer_konta = NEW.numer_konta_nadawcy;

    UPDATE konta
    SET saldo = saldo + NEW.kwota
    WHERE numer_konta = NEW.numer_konta_odbiorcy;

    INSERT INTO historia (id_konta, typ_zdarzenia, opis, kwota, saldo_po_zdarzeniu)
    SELECT 
        id_odbiorcy,
        'Przelew przychodzący',
        CASE 
            WHEN NEW.opis IS NOT NULL AND NEW.opis != '' 
            THEN CONCAT(NEW.tytul, ': ', NEW.opis)
            ELSE NEW.tytul
        END,
        NEW.kwota,
        saldo
    FROM konta 
    WHERE numer_konta = NEW.numer_konta_odbiorcy;
END;

-- sprawdzenie 
INSERT INTO przelewy_bankowe (numer_konta_nadawcy, numer_konta_odbiorcy, kwota, waluta) VALUES (12345678901234567890123456, 23456789012345678901234567, 50.00, 'PLN' );
SELECT * FROM konta
SELECT saldo FROM konta WHERE id_konta = 2;
select * from historia
select * from przelewy_bankowe

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
INSERT INTO wplaty_wyplaty (id_konta, typ_operacji, kwota) VALUES (1, 'Wypłata', 200000.00);
insert into wplaty_wyplaty (id_konta, typ_operacji, kwota) values (1, 'Wypłata', 10.00);
select saldo from konta where id_konta=1
select * from historia

CREATE INDEX idx_lokaty_zrealizowana ON lokaty (zrealizowana);
CREATE INDEX idx_lokaty_id_konta ON lokaty (id_konta);
CREATE INDEX idx_konta_id_konta ON konta (id_konta);
CREATE INDEX idx_konta_numer_konta ON konta (numer_konta);

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

-- sprawdzenie
select * from lokaty
select * from aktywne_lokaty

CREATE INDEX idx_kredyty_data_zakonczenia ON kredyty (data_zakonczenia);
CREATE INDEX idx_kredyty_id_konta ON kredyty (id_konta);

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

-- sprawdzenie
select * from kredyty
select * from aktywne_kredyty


CREATE or replace INDEX idx_przelewy_numer_konta_nadawcy ON przelewy_bankowe (numer_konta_nadawcy);
CREATE or replace INDEX idx_przelewy_numer_konta_odbiorcy ON przelewy_bankowe (numer_konta_odbiorcy);

CREATE OR REPLACE VIEW szczegoly_przelewow AS
SELECT 
    p.id_przelewu,
    k_nad.numer_konta AS konto_nadawcy,
    k_odb.numer_konta AS konto_odbiorcy,
    p.kwota,
    p.waluta,
    p.data_przelewu
FROM przelewy_bankowe p
JOIN konta k_nad ON p.numer_konta_nadawcy = k_nad.numer_konta
JOIN konta k_odb ON p.numer_konta_odbiorcy = k_odb.numer_konta;

-- sprawdzenie
select * from przelewy_bankowe

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

end;

-- sprawdzenie
CALL tworzenie_konta('Konrad','Konicki','031122233','ul. Zielona 15, Nowy Sącz',
                     '500100200','k.kon@hotmail.com','2001-03-12','22222222222222222222222211',1,2.00);
select * from dane_osobowe
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
CALL aktualizuj_dane_osobowe(3,'Krzysztof','Korzeniewski','ul. Nowa 10, Warszawa','600123456','k.kor@hotmail.com');
select * from dane_osobowe

-- to nizej jest po to zeby wlaczyc eventy (u mnie nie dzialalo bez tego)
SET GLOBAL event_scheduler=ON

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
select * from historia
select saldo from konta

CREATE OR REPLACE EVENT sprawdz_waznosc_kart
ON SCHEDULE EVERY 1 MINUTE
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    INSERT INTO historia (id_konta, typ_zdarzenia, opis)
    SELECT 
        k.id_konta,
        'ODNOWIENIE KARTY',
        CONCAT('Automatyczne odnowienie karty. Poprzednia data ważności: ', k.data_waznosci)
    FROM karty k
    WHERE k.data_waznosci < CURDATE();

	update karty
    SET 
        data_waznosci = DATE_ADD(CURDATE(), INTERVAL 3 YEAR),
        cvv = LPAD(FLOOR(RAND() * 999), 3, '0')
    WHERE data_waznosci < CURDATE();
END;

-- sprawdzenie
INSERT INTO karty (id_konta, numer_karty, cvv, data_waznosci, typ_karty)
VALUES
(1, '111122223333444', '123', '2024-12-31', 'Debetowa'),
(2, '555566667778888', '456', '2024-03-31', 'Kredytowa');
select * from karty
select * from historia

CREATE OR REPLACE PROCEDURE dodaj_kredyt(
    IN p_id_konta INT,
    IN kwota DECIMAL(10,2),
    IN oprocentowanie DECIMAL(5,2),
    IN okres_lat INT
)
BEGIN
    DECLARE rata_miesieczna DECIMAL(10,2);
    DECLARE liczba_rat INT;
    DECLARE data_zakonczenia DATETIME;
    DECLARE data_rozpoczecia DATETIME;
    DECLARE saldo_konta DECIMAL(10,2);
    DECLARE czy_ma_aktywny_kredyt INT;
    DECLARE laczna_kwota_do_splaty DECIMAL(10,2);

    SELECT COUNT(*) INTO czy_ma_aktywny_kredyt
    FROM kredyty
    WHERE id_konta = p_id_konta
    AND status = 'Aktywny';

    IF czy_ma_aktywny_kredyt > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Klient posiada już aktywny kredyt i nie może wziąć kolejnego.';
    END IF;

    SET liczba_rat = okres_lat * 12;

    SET rata_miesieczna = kwota * (oprocentowanie/1200 * POW(1 + oprocentowanie/1200, liczba_rat)) 
                          / (POW(1 + oprocentowanie/1200, liczba_rat) - 1);

    SET laczna_kwota_do_splaty = rata_miesieczna * liczba_rat;

    SET data_zakonczenia = DATE_ADD(NOW(), INTERVAL okres_lat YEAR);
    SET data_rozpoczecia = NOW();

    SELECT saldo INTO saldo_konta
    FROM konta
    WHERE id_konta = p_id_konta
    LIMIT 1;

    IF saldo_konta IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Konto nie istnieje.';
    END IF;

    INSERT INTO kredyty (id_konta, kwota, oprocentowanie, liczba_rat, rata_miesieczna, data_zakonczenia, data_rozpoczecia, status, do_splaty)
    VALUES (p_id_konta, kwota, oprocentowanie, liczba_rat, rata_miesieczna, data_zakonczenia, data_rozpoczecia, 'Aktywny', laczna_kwota_do_splaty);

    UPDATE konta
    SET saldo = saldo + kwota
    WHERE id_konta = p_id_konta;

    INSERT INTO historia (id_konta, typ_zdarzenia, opis, kwota, saldo_po_zdarzeniu, data_zdarzenia)
    VALUES (p_id_konta, 'Przyznanie kredytu', CONCAT('Przyznano kredyt w wysokości ', kwota), kwota, saldo_konta + kwota, NOW());

    SELECT CONCAT('Kredyt przyznany! Kwota kredytu: ', kwota, ', Miesięczna rata: ', rata_miesieczna);
END;

CREATE OR REPLACE EVENT rata_kredytu
ON SCHEDULE EVERY 1 month
DO
BEGIN
    UPDATE kredyty kr
    SET 
        kr.do_splaty = 0,
        kr.status = 'Zakończony'
    WHERE kr.do_splaty <= 1
    AND kr.status = 'Aktywny';

    UPDATE konta k
    INNER JOIN kredyty kr ON k.id_konta = kr.id_konta
    SET k.saldo = k.saldo - kr.rata_miesieczna,
        kr.do_splaty = kr.do_splaty - kr.rata_miesieczna
    WHERE kr.data_zakonczenia >= NOW()
      AND kr.data_rozpoczecia <= NOW()
      AND k.saldo >= kr.rata_miesieczna
      AND kr.status = 'Aktywny';

    INSERT INTO historia (id_konta, typ_zdarzenia, opis, kwota, saldo_po_zdarzeniu, data_zdarzenia)
    SELECT 
        kr.id_konta,
        'Spłata raty kredytu',
        CONCAT('Spłacono ratę kredytu w wysokości: ', kr.rata_miesieczna, ' zł'),
        kr.rata_miesieczna,
        k.saldo,
        NOW()
    FROM kredyty kr
    INNER JOIN konta k ON k.id_konta = kr.id_konta
    WHERE kr.data_zakonczenia >= NOW()
      AND kr.data_rozpoczecia <= NOW()
      AND k.saldo >= kr.rata_miesieczna
      AND kr.status = 'Aktywny';

    UPDATE kredyty kr
    INNER JOIN konta k ON k.id_konta = kr.id_konta
    SET 
        kr.rata_miesieczna = ROUND(kr.rata_miesieczna * 1.02, 2),
        kr.data_zakonczenia = DATE_ADD(kr.data_zakonczenia, INTERVAL 1 MONTH),
        kr.do_splaty = ROUND(
            (kr.rata_miesieczna + kr.rata_miesieczna * 0.02) * 
            (kr.liczba_rat - (
                SELECT COUNT(*) 
                FROM historia h 
                WHERE h.id_konta = kr.id_konta 
                AND h.typ_zdarzenia = 'Spłata raty kredytu'
                AND h.data_zdarzenia >= kr.data_rozpoczecia
            )), 
            2)
    WHERE kr.data_zakonczenia >= NOW()
      AND kr.data_rozpoczecia <= NOW()
      AND k.saldo < kr.rata_miesieczna
      AND kr.status = 'Aktywny';

    INSERT INTO historia (id_konta, typ_zdarzenia, opis, kwota, saldo_po_zdarzeniu, data_zdarzenia)
    SELECT 
        kr.id_konta,
        'Nieudana spłata raty',
        CONCAT('Brak środków na spłatę raty. Naliczono odsetki karne 2%. ',
               'Nowa rata: ', kr.rata_miesieczna, ' zł. ',
               'Pozostało do spłaty: ', kr.do_splaty, ' zł. ',
               'Pozostało rat: ', (
                   kr.liczba_rat - (
                       SELECT COUNT(*) 
                       FROM historia h 
                       WHERE h.id_konta = kr.id_konta 
                       AND h.typ_zdarzenia = 'Spłata raty kredytu'
                       AND h.data_zdarzenia >= kr.data_rozpoczecia
                   )
               )),
        0,
        k.saldo,
        NOW()
    FROM kredyty kr
    INNER JOIN konta k ON k.id_konta = kr.id_konta
    WHERE kr.data_zakonczenia >= NOW()
      AND kr.data_rozpoczecia <= NOW()
      AND k.saldo < kr.rata_miesieczna
      AND kr.status = 'Aktywny';

    INSERT INTO historia (id_konta, typ_zdarzenia, opis, kwota, saldo_po_zdarzeniu, data_zdarzenia)
    SELECT 
        kr.id_konta,
        'Zakończenie kredytu',
        'Kredyt został zakończony (spłacony)',
        0,
        k.saldo,
        NOW()
    FROM kredyty kr
    INNER JOIN konta k ON k.id_konta = kr.id_konta
    WHERE kr.status = 'Zakończony'
    AND NOT EXISTS (
        SELECT 1 
        FROM historia h 
        WHERE h.id_konta = kr.id_konta 
        AND h.typ_zdarzenia = 'Zakończenie kredytu'
    );
END;


CREATE OR REPLACE TRIGGER kredyt_zakonczony_historia
AFTER UPDATE ON kredyty
FOR EACH ROW
BEGIN
    IF OLD.status = 'Aktywny' AND NEW.status = 'Zakończony' THEN
        INSERT INTO historia (id_konta, typ_zdarzenia, opis, kwota, saldo_po_zdarzeniu, data_zdarzenia)
        SELECT 
            NEW.id_konta,
            'Zakończenie kredytu',
            'Kredyt został zakończony',
            0,
            (SELECT saldo FROM konta WHERE id_konta = NEW.id_konta),
            NOW();
    END IF;
END;

-- sprawdzenie
call dodaj_kredyt(2, 2000, 3, 1)
select saldo from konta where id_konta=2
select * from historia
select * from kredyty

-- lokaty
CREATE OR REPLACE PROCEDURE aktywacja_lokaty(
IN p_id_konta INT,
IN p_kwota DECIMAL(15,2),
IN p_oprocentowanie DECIMAL(5,2),
IN p_liczba_kapitalizacji INT,
IN p_data_start DATE,
IN p_data_koniec DATE
)
BEGIN
    DECLARE v_saldo DECIMAL(15,2);
    SELECT saldo INTO v_saldo
    FROM konta
    WHERE id_konta = p_id_konta;

    IF v_saldo < p_kwota THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Brak wystarczających środków na koncie';
    ELSE
        UPDATE konta
        SET saldo = saldo - p_kwota
        WHERE id_konta = p_id_konta;

        INSERT INTO lokaty (id_konta, kwota, oprocentowanie, liczba_kapitalizacji, data_start, data_koniec)
        VALUES (p_id_konta, p_kwota, p_oprocentowanie, p_liczba_kapitalizacji, p_data_start, p_data_koniec);

        INSERT INTO historia (id_konta, typ_zdarzenia, opis, kwota, saldo_po_zdarzeniu)
        VALUES (p_id_konta, 'Aktywacja lokaty', 'Założenie lokaty', p_kwota, v_saldo - p_kwota);
    END IF;
END;


CALL aktywacja_lokaty(1, 5000.00, 3.00, 12, '2025-01-01', '2026-01-01');
CALL aktywacja_lokaty(2, 100.00, 2.50, 4, '2025-01-01', '2025-12-31');


CREATE or replace EVENT aktualizacja_lokaty
ON SCHEDULE EVERY 1 minute
DO
BEGIN
    UPDATE lokaty
    SET zrealizowana = 1
    WHERE data_koniec <= CURRENT_DATE AND zrealizowana = 0;
END;

CREATE OR REPLACE EVENT nalicz_odsetki
ON SCHEDULE EVERY 1 MINUTE
STARTS '2024-01-01 00:00:00'
DO
BEGIN
    UPDATE lokaty
    SET zrealizowana = 1
    WHERE zrealizowana = 0 AND data_koniec <= CURRENT_DATE;

    UPDATE lokaty l
    JOIN konta k ON l.id_konta = k.id_konta
    SET k.saldo = k.saldo + l.kwota + ROUND(
        l.kwota * POWER(1 + (l.oprocentowanie / 100) / l.liczba_kapitalizacji,
        l.liczba_kapitalizacji * DATEDIFF(l.data_koniec, l.data_start) / 365.0) - l.kwota,
        2)
    WHERE l.zrealizowana = 1;

    INSERT INTO historia (id_konta, typ_zdarzenia, opis, kwota, saldo_po_zdarzeniu)
    SELECT
        l.id_konta,
        'Lokata - zakończenie',
        CONCAT(
            'Zakończenie lokaty. Kwota lokaty: ', l.kwota,
            ' zł, naliczone odsetki: ',
            ROUND(
                l.kwota * POWER(1 + (l.oprocentowanie / 100) / l.liczba_kapitalizacji,
                l.liczba_kapitalizacji * DATEDIFF(l.data_koniec, l.data_start) / 365.0) - l.kwota,
                2),
            ' zł.'
        ),
        l.kwota + ROUND(
            l.kwota * POWER(1 + (l.oprocentowanie / 100) / l.liczba_kapitalizacji,
            l.liczba_kapitalizacji * DATEDIFF(l.data_koniec, l.data_start) / 365.0) - l.kwota,
            2),
        k.saldo
    FROM lokaty l
    JOIN konta k ON l.id_konta = k.id_konta
    WHERE l.zrealizowana = 1;

    UPDATE lokaty
    SET zrealizowana = 3
    WHERE zrealizowana = 1;
END;

-- sprawdzenie
call aktywacja_lokaty(2, 1000.00, 5.00, 3, '2024-01-01', '2025-01-01')
select * from lokaty
select * from historia where id_konta = 2

select * from konta
select * from historia h 
select * from przelewy_bankowe 










