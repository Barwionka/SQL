-- creating tables
CREATE TABLE personal_data (
    id_p INT AUTO_INCREMENT PRIMARY KEY,
    f_name VARCHAR(50) NOT NULL,
    l_name VARCHAR(50) NOT NULL,
    address VARCHAR(200),
    phone_number VARCHAR(15),
    email_address VARCHAR(100),
    d_of_birth DATE,
    d_of_creation DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE account_types (
    id_type INT AUTO_INCREMENT PRIMARY KEY,
    tape_name VARCHAR(50) NOT NULL,
    description TEXT
);

CREATE TABLE account (
    id_a INT AUTO_INCREMENT PRIMARY KEY,
    a_number VARCHAR(26) UNIQUE NOT NULL,
    id_p INT NOT NULL,
    id_type INT NOT NULL,
    balance DECIMAL(15,2) DEFAULT 0.00,
    d_of_creation DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_p) REFERENCES personal_data(id_p),
    FOREIGN KEY (id_type) REFERENCES account_types(id_type)
);

CREATE TABLE login (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_p INT NOT NULL,
    login VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    FOREIGN KEY (id_p) REFERENCES personal_data(id_p)
);

CREATE TABLE credit (
    id_credit INT AUTO_INCREMENT PRIMARY KEY,
    id_a INT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    interest_rate DECIMAL(5,2) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    installment_count INT,
    monthly_installment DECIMAL(15,2),
    remaining_balance DECIMAL(15,2),
    status VARCHAR(20) DEFAULT 'Active',
    FOREIGN KEY (id_a) REFERENCES account(id_a)
);

CREATE TABLE deposit (
    id_d INT AUTO_INCREMENT PRIMARY KEY,
    id_a INT NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    interest_rate DECIMAL(5,2) NOT NULL,
    capitalization_count INT DEFAULT 1,
    start_date DATE NOT NULL,
    end_date DATE,
    completed INT DEFAULT 0,
    FOREIGN KEY (id_a) REFERENCES account(id_a)
);

CREATE OR REPLACE TABLE interbank_transfers (
    id_transfer INT AUTO_INCREMENT PRIMARY KEY,
    s_number VARCHAR(26) NOT NULL,
    r_number VARCHAR(26) NOT NULL,
    title VARCHAR(255),
    description TEXT,
    amount DECIMAL(15, 2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'PLN',
    transfer_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transfers (
    id_transfer INT AUTO_INCREMENT PRIMARY KEY,
    s_number VARCHAR(26) NOT NULL,
    r_number VARCHAR(26) NOT NULL,
    title VARCHAR(255),
    description TEXT,
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'USD',
    transfer_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE cards (
    id_card INT AUTO_INCREMENT PRIMARY KEY,
    id_a INT NOT NULL,
    card_n VARCHAR(16) UNIQUE NOT NULL,
    cvv CHAR(3) NOT NULL,
    expiration_date DATE NOT NULL,
    card_type VARCHAR(50),
    FOREIGN KEY (id_a) REFERENCES account(id_a)
);

CREATE TABLE transactions (
    id_transaction INT AUTO_INCREMENT PRIMARY KEY,
    id_a INT NOT NULL,
    transaction_type VARCHAR(50) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_a) REFERENCES account(id_a)
);

CREATE TABLE account_history (
    id_h INT AUTO_INCREMENT PRIMARY KEY,
    id_a INT,
    event_type VARCHAR(255),
    description TEXT,
    amount DECIMAL(15, 2),
    balance_after_event DECIMAL(15, 2),
    event_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_a) REFERENCES account(id_a)
);

-- inserts

INSERT INTO personal_data (f_name , l_name , address , phone_number , email_address , d_of_birth)
VALUES
('John', 'Smith', 'Elm St, Springfield, IL', '15551243', ': john.smith@example.com', '1994-05-14'),
('Sarah', 'Johnson', '456 Oak St, Chicago, IL', '600300400', 'sarah.johnson@example.com', '1990-07-25'),
('Michael', 'Brown', '789 Pine St, Los Angeles, CA', '600300400', 'michael.brown@example.com', '1990-07-25'),
('Emily', 'Johnson', '101 Maple St, Seattle, WA', '600300400', 'emily.johnson@example.com', '1990-07-25'),
('Daniel', 'Wilson', '202 Birch St, New York, NY', '600300400', 'daniel.wilson@example.com', '1990-07-25'),
('Laura', 'Moore', '303 Cedar St, Austin, TX', '600300400', 'laura.moore@example.com', '1990-07-25'),
('Olivia', 'Anderson', '404 Pine St, Miami, FL', '600300400', 'olivia.anderson@example.com', '1990-07-25'),
('James', 'Martinez', '505 Oak St, Boston, MA', '700400500', 'james.martines@example.com', '1978-12-08');

INSERT INTO account_types (tape_name, description) 
VALUES
('Savings', 'A type of account that earns interest on deposits and is typically used for saving money.'),
('Checking', 'A type of account that allows deposits and withdrawals for daily transactions.'),
('Business', 'An account specifically designed for business transactions and activities.'),
('Student', 'A special account for students, usually with lower fees and conditions.'),
('Joint', 'An account shared by two or more individuals, where all can access and manage the funds.');


INSERT INTO account (a_number, id_p, id_type, balance)
VALUES
('12345678901234567890123456', 1, 2, 1500.50),
('98765432109876543210987654', 2, 1, 5000.00),
('11111111111111111111111111', 3, 3, 1200.75),
('22222222222222222222222222', 4, 1, 300.25),
('33333333333333333333333333', 5, 4, 250.00),
('44444444444444444444444444', 6, 2, 1800.30),
('55555555555555555555555555', 7, 5, 6000.00),
('66666666666666666666666666', 8, 3, 950.00);

INSERT INTO login (id_p, login, password)
VALUES
(1, 'bear123', 'fkhassd4534G'),  
(2, 'dumpy54', 'sdgbuyR56'),  
(3, 'emergency25', 'agV4b%'),  
(4, 'briliantistic3', 'gdshjd6^&'),  
(5, 'dailypush597', 'w^vitG65n'),  
(6, 'strongwoman23', 'm35udtVG'),  
(7, 'ruinworld34', 'eydsij^&52'),  
(8, 'clasification62', 'GTsad6');

INSERT INTO deposit (id_a, amount, interest_rate, capitalization_count, start_date, end_date)
VALUES
(2, 10000.00, 3.50, 12, '2025-01-01', '2027-01-01'),
(3, 5000.00, 2.75, 4,  '2024-11-15', '2025-11-15'),
(5, 1500.00, 4.00, 12, '2025-03-10', '2027-03-10'),
(6, 20000.00, 2.50, 4,  '2024-07-01', '2025-07-01'),
(7, 3000.00, 3.25, 12, '2025-02-20', '2027-02-20');

INSERT INTO cards (id_a, card_n, cvv, expiration_date, card_type)
VALUES
(1, '1234567812345678', '123', '2027-12-31', 'Visa'),
(2, '2345678923456789', '234', '2026-06-30', 'MasterCard'),
(3, '3456789034567890', '345', '2025-09-15', 'American Express'),
(4, '4567890145678901', '456', '2024-11-01', 'Visa'),
(5, '5678901256789012', '567', '2025-05-20', 'MasterCard');

INSERT INTO transactions (id_a, transaction_type, amount)
VALUES
(1, 'Deposit', 1500.00),
(2, 'Withdrawal', 200.00),
(3, 'Transfer', 1200.00),
(4, 'Deposit', 5000.00),
(5, 'Withdrawal', 300.00),
(6, 'Transfer', 1500.50),
(7, 'Deposit', 2500.00),
(8, 'Withdrawal', 1000.00);

CREATE OR REPLACE TRIGGER after_transaction
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    IF NEW.transaction_type = 'Deposit' THEN
        UPDATE account
        SET balance = balance + NEW.amount
        WHERE id_a = NEW.id_a;

    ELSEIF NEW.transaction_type = 'Withdrawal' THEN
        UPDATE account
        SET balance = balance - NEW.amount
        WHERE id_a = NEW.id_a;
    END IF;

    INSERT INTO account_history (id_a, event_type, description , amount , balance_after_event)
    VALUES (
        NEW.id_a,
        NEW.transaction_type,
        CONCAT('Transaction: ', NEW.transaction_type, ', Amount: ', NEW.amount),
        CASE
            WHEN NEW.transaction_type = 'Deposit' THEN NEW.amount
            ELSE -NEW.amount
        END,
        (SELECT balance FROM account WHERE id_a = NEW.id_a)
    );
END;


-- checking
INSERT INTO transactions (id_a, transaction_type , amount) VALUES (1, 'Deposit', 200.00);
INSERT INTO transactions (id_a, transaction_type , amount) VALUES (1, 'Withdrawal', 500.00);
SELECT balance FROM account WHERE id_a = 1;


CREATE OR REPLACE TRIGGER after_transfer
AFTER INSERT ON transfers
FOR EACH ROW
BEGIN
    DECLARE id_s INT;
    DECLARE id_r INT;

    SELECT id_a INTO id_s
    FROM account
    WHERE a_number = NEW.s_number;

    SELECT id_a INTO id_r
    FROM account
    WHERE a_number = NEW.r_number;

    UPDATE account
    SET balance = balance - NEW.amount
    WHERE a_number = NEW.s_number;

    INSERT INTO account_history (id_a, event_type, description, amount, balance_after_event)
    SELECT
        id_s,
        'Outgoing transfer',
        CASE
            WHEN NEW.description IS NOT NULL AND NEW.description != ''
            THEN CONCAT(NEW.title, ': ', NEW.description)
            ELSE NEW.title
        END,
        -NEW.amount,
        balance
    FROM account
    WHERE a_number = NEW.s_number;

    UPDATE account
    SET balance = balance + NEW.amount
    WHERE id_a = NEW.r_number;

    INSERT INTO account_history (id_a, event_type, description, amount, balance_after_event)
    SELECT
        id_r,
        'Incoming transfer',
        CASE
            WHEN NEW.description IS NOT NULL AND NEW.description != ''
            THEN CONCAT(NEW.title, ': ', NEW.description)
            ELSE NEW.title
        END,
        NEW.amount,
        balance
    FROM account
    WHERE a_number = NEW.r_number;
END;


-- checking
INSERT INTO transfers (s_number , r_number , amount , currency) VALUES (12345678901234567890123456, 23456789012345678901234567, 100.00, 'USD');
SELECT balance FROM account a WHERE id_a = 1;
SELECT balance FROM account a WHERE id_a = 2;

CREATE OR REPLACE TRIGGER check_balance_before_withdrawal
BEFORE INSERT ON transactions
FOR EACH ROW
BEGIN
    IF NEW.transaction_type = 'Withdrawal' THEN
        IF (SELECT balance FROM account a WHERE id_a = NEW.id_a) < NEW.amount THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient funds in the account.';
        END IF;
    END IF;
END;

-- checking
INSERT INTO transactions (id_a, transaction_type , amount)
VALUES (1, 'Withdrawal', 200000.00);
insert into transactions (id_a, transaction_type , amount)
values (1, 'Withdrawal', 10.00);
select balance from account a where id_a=1

CREATE INDEX idx_deposits_completed ON deposit (completed);
CREATE INDEX idx_deposits_a_id ON deposit (id_a);
CREATE INDEX idx_account_a_id ON account (id_a);
CREATE INDEX idx_account_account_number ON account (a_number);

CREATE OR REPLACE VIEW active_deposits AS
SELECT 
    d.id_d,
    a.id_a,
    d.amount,
    d.interest_rate,
    d.start_date,
    d.end_date
FROM deposit d 
JOIN account a ON d.id_a = a.id_a
WHERE d.completed = 0;

select * from deposit
select * from active_deposits

CREATE INDEX idx_credits_end_date ON credit (end_date);
CREATE INDEX idx_credits_id_a ON credit (id_a);

CREATE OR REPLACE VIEW active_credits AS
SELECT 
    c.id_credit,
    a.a_number,
    c.amount,
    c.interest_rate,
    c.start_date,
    c.end_date
FROM credit c 
JOIN account a ON c.id_a = a.id_a
WHERE c.end_date IS NULL OR c.end_date > CURRENT_DATE;

select * from credit c 
select * from active_credits

CREATE OR REPLACE INDEX idx_bank_transfers_s_number ON transfers (s_number);
CREATE OR REPLACE INDEX idx_bank_transfers_r_number ON transfers (r_number);



CREATE TABLE transfers (
    id_transfer INT AUTO_INCREMENT PRIMARY KEY,
    s_number VARCHAR(26) NOT NULL,
    r_number VARCHAR(26) NOT NULL,
    title VARCHAR(255),
    description TEXT,
    amount DECIMAL(15,2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'USD',
    transfer_date DATETIME DEFAULT CURRENT_TIMESTAMP
);


CREATE OR REPLACE VIEW transfer_details t AS
SELECT 
    t.id_transfer,
    a_sen.a_number AS sender_account,
    a_rec.a_number AS recipient_account,
    t.amount,
    t.currency,
    t.transfer_date
FROM transfers t 
JOIN account a_sen ON t.s_number = a_sen.a_number
JOIN account a_rec ON t.r_number = a_rec.a_number;

select * from transfer_details

select * from account_history h 
SELECT * FROM account_history h WHERE id_a = 1;

CREATE or replace PROCEDURE account_creation(
    IN p_f_name VARCHAR(50),
    IN p_l_name VARCHAR(50),
    IN p_address VARCHAR(200),
    IN p_phone_number VARCHAR(15),
    IN p_email_address VARCHAR(100),
    IN p_d_of_birth DATE,
    IN p_a_number VARCHAR(26),
    IN p_id_type INT,
    IN p_balance DECIMAL(15,2)
)
BEGIN
    DECLARE id_p INT;

    INSERT INTO personal_data (f_name , l_name , address , phone_number , email_address , d_of_birth)
    VALUES (p_f_name,  p_l_name, p_address, p_phone_number, p_email_address, p_d_of_birth);

    SET id_p = LAST_INSERT_ID();

    INSERT INTO account (a_number , id_p , id_type , balance)
    VALUES (p_a_number, id_p, p_id_type, p_balance);

end; 

-- checking
CALL account_creation('Arnold','Smith','123 Maple Street Springfield, IL',
                     '500100200','a.smith@example.com','2001-03-12','22222222222222222222222211',1,200.00);
select * from account a 


CREATE or replace PROCEDURE update_personal_data(
    IN p_id_p INT,
    IN p_f_name VARCHAR(50),
    IN p_l_name VARCHAR(50),
    IN p_address VARCHAR(200),
    IN p_phone_number VARCHAR(15),
    IN p_email_address VARCHAR(100)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM personal_data WHERE id_p = p_id_p) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User with the given ID does not exist.';
    ELSE
        UPDATE personal_data 
        SET f_name = p_f_name,
            l_name = p_l_name,
            address = p_address,
            phone_number = p_phone_number,
            email_address = p_email_address
        WHERE id_p = p_id_p;
    END IF;
END;


-- checking
select * from personal_data pd 

CALL update_personal_data(9,'Kry','Cat','1234 Elm Street, Springfield, IL ','600123456','kry.cat@example.com');

select * from personal_data pd 
select * from account a 

CREATE OR REPLACE EVENT account_fee
ON SCHEDULE EVERY 1 MONTH
DO
BEGIN
    INSERT INTO account_history (id_a, event_type, description, amount, balance_after_event)
    select a.id_a, 'Account fee', 'Monthly account fee', 10, a.balance - 10
    FROM account a 
    WHERE a.balance >= 10;

    UPDATE account 
    SET balance = balance - 10
    WHERE balance >= 10;
END;


-- checking
SELECT * FROM account a WHERE id_a = 1;
SELECT * FROM credit c WHERE id_a = 1;

SET GLOBAL event_scheduler=ON 

CREATE OR REPLACE EVENT check_card_expiration
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_TIMESTAMP
DO
BEGIN
    INSERT INTO account_history (id_a, event_type, description)
    SELECT 
        c.id_a,
        'CARD RENEWAL',
        CONCAT('Automatic card renewal. Previous expiration date: ', c.expiration_date)
    FROM cards c
    WHERE c.expiration_date < CURDATE();

    UPDATE cards
    SET 
        expiration_date = DATE_ADD(CURDATE(), INTERVAL 3 YEAR),
        cvv = LPAD(FLOOR(RAND() * 999), 3, '0')
    WHERE expiration_date < CURDATE();
END;

-- Checking
INSERT INTO cards (id_a, card_n, cvv, expiration_date, card_type)
VALUES
(1, '111122223333444', '123', '2024-12-31', 'Debit'),
(2, '555566667778888', '456', '2024-03-31', 'Credit');
SELECT * FROM cards;
SELECT * FROM account_history;

CREATE OR REPLACE PROCEDURE add_credit(
    IN p_id_a INT,
    IN amount DECIMAL(10,2),
    IN interest_rate DECIMAL(5,2),
    IN term_years INT
)
BEGIN
    DECLARE monthly_installment DECIMAL(15,2);
    DECLARE installment_count INT;
    DECLARE end_date DATETIME;
    DECLARE start_date DATETIME;
    DECLARE a_balance DECIMAL(10,2);
    DECLARE has_active_credit INT;
    DECLARE total_remaining_balance DECIMAL(10,2);

    SELECT COUNT(*) INTO has_active_credit
    FROM credit
    WHERE id_a = p_id_a
    AND status = 'Active';

    IF has_active_credit > 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Customer already has an active loan and cannot take another one.';
    END IF;

    SET installment_count = term_years * 12;

    SET monthly_installment = amount * (interest_rate / 1200 * POW(1 + interest_rate / 1200, installment_count)) 
                              / (POW(1 + interest_rate / 1200, installment_count) - 1);

    SET total_remaining_balance = monthly_installment * installment_count;

    SET end_date = DATE_ADD(NOW(), INTERVAL term_years YEAR);
    SET start_date = NOW();

    SELECT balance INTO a_balance
    FROM account
    WHERE id_a = p_id_a
    LIMIT 1;

    IF a_balance IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Account does not exist.';
    END IF;

    INSERT INTO credit (id_a, amount, interest_rate, installment_count, monthly_installment, end_date, start_date, status, remaining_balance)
    VALUES (p_id_a, amount, interest_rate, installment_count, monthly_installment, end_date, start_date, 'Active', total_remaining_balance);

    UPDATE account
    SET balance = balance + amount
    WHERE id_a = p_id_a;

    INSERT INTO account_history (id_a, event_type, description, amount, balance_after_event, event_date)
    VALUES (p_id_a, 'Loan Approval', CONCAT('Loan granted in the amount of ', amount), amount, a_balance + amount, NOW());

    SELECT CONCAT('Loan granted! Loan amount: ', amount, ', Monthly installment: ', monthly_installment);
END;


CREATE OR REPLACE EVENT credit_installment
ON SCHEDULE EVERY 1 MONTH
DO
BEGIN
    UPDATE credit c
    SET 
        c.remaining_balance = 0,
        c.status = 'Completed'
    WHERE c.remaining_balance <= 1
    AND c.status = 'Active';

    UPDATE account a
    INNER JOIN credit c ON a.id_a = c.id_a
    SET a.balance = a.balance - c.monthly_installment,
        c.remaining_balance = c.remaining_balance - c.monthly_installment
    WHERE c.end_date >= NOW()
      AND c.start_date <= NOW()
      AND a.balance >= c.monthly_installment
      AND c.status = 'Active';

    INSERT INTO account_history (id_a, event_type, description, amount, balance_after_event, event_date)
    SELECT 
        c.id_a,
        'Loan installment payment',
        CONCAT('Paid loan installment of: ', c.monthly_installment, ' USD'),
        c.monthly_installment,
        a.balance,
        NOW()
    FROM credit c
    INNER JOIN account a ON a.id_a = c.id_a
    WHERE c.end_date >= NOW()
      AND c.start_date <= NOW()
      AND a.balance >= c.monthly_installment
      AND c.status = 'Active';

    UPDATE credit c
    INNER JOIN account a ON a.id_a = c.id_a
    SET 
        c.monthly_installment = ROUND(c.monthly_installment * 1.02, 2),
        c.end_date = DATE_ADD(c.end_date, INTERVAL 1 MONTH),
        c.remaining_balance = ROUND(
            (c.monthly_installment + c.monthly_installment * 0.02) * 
            (c.num_installments - (
                SELECT COUNT(*) 
                FROM account_history h 
                WHERE h.id_a = c.id_a 
                AND h.event_type = 'Loan installment payment'
                AND h.event_date >= c.start_date
            )), 
            2)
    WHERE c.end_date >= NOW()
      AND c.start_date <= NOW()
      AND a.balance < c.monthly_installment
      AND c.status = 'Active';

    INSERT INTO account_history (id_a, event_type, description, amount, balance_after_event, event_date)
    SELECT 
        c.id_a,
        'Failed loan installment payment',
        CONCAT('Insufficient funds to pay installment. Penal interest of 2% applied. ',
               'New installment: ', c.monthly_installment, ' USD. ',
               'Remaining to pay: ', c.remaining_balance, ' USD. ',
               'Remaining installments: ', (
                   c.num_installments - (
                       SELECT COUNT(*) 
                       FROM account_history h 
                       WHERE h.id_a = c.id_a 
                       AND h.event_type = 'Loan installment payment'
                       AND h.event_date >= c.start_date
                   )
               )),
        0,
        a.balance,
        NOW()
    FROM credit c
    INNER JOIN account a ON a.id_a = c.id_a
    WHERE c.end_date >= NOW()
      AND c.start_date <= NOW()
      AND a.balance < c.monthly_installment
      AND c.status = 'Active';

    INSERT INTO account_history (id_a, event_type, description, amount, balance_after_event, event_date)
    SELECT 
        c.id_a,
        'Loan completion',
        'Loan has been completed (paid off)',
        0,
        a.balance,
        NOW()
    FROM credit c
    INNER JOIN account a ON a.id_a = c.id_a
    WHERE c.status = 'Completed'
    AND NOT EXISTS (
        SELECT 1 
        FROM account_history h 
        WHERE h.id_a = c.id_a 
        AND h.event_type = 'Loan completion'
    );
END;


CREATE OR REPLACE TRIGGER credit_completed_account_history
AFTER UPDATE ON credit
FOR EACH ROW
BEGIN
    IF OLD.status = 'Active' AND NEW.status = 'Completed' THEN
        INSERT INTO account_history (id_a, event_type, description, amount, balance_after_event, event_date)
        SELECT 
            NEW.id_a,
            'Credit completion',
            'Credit has been completed',
            0,
            (SELECT balance FROM account WHERE id_a = NEW.id_a),
            NOW();
    END IF;
END;

-- Checking
CALL add_credit(2, 2000, 3, 1);
SELECT balance FROM account WHERE id_a = 2;
SELECT * FROM account_history;
SELECT * FROM credit;

-- Deposits
CREATE OR REPLACE PROCEDURE activate_deposit(
IN p_id_a INT,
IN p_amount DECIMAL(15,2),
IN p_interest_rate DECIMAL(5,2),
IN p_capitalization_count INT,
IN p_start_date DATE,
IN p_end_date DATE
)
BEGIN
    DECLARE v_balance DECIMAL(15,2);
    SELECT balance INTO v_balance
    FROM account
    WHERE id_a = p_id_a;

    IF v_balance < p_amount THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient funds in account';
    ELSE
        UPDATE account
        SET balance = balance - p_amount
        WHERE id_a = p_id_a;

        INSERT INTO deposit (id_a, amount, interest_rate, capitalization_count, start_date, end_date)
        VALUES (p_id_a, p_amount, p_interest_rate, p_capitalization_count, p_start_date, p_end_date);

        INSERT INTO account_history (id_a, event_type, description, amount, balance_after_event)
        VALUES (p_id_a, 'Deposit activation', 'Deposit creation', p_amount, v_balance - p_amount);
    END IF;
END;

CALL activate_deposit(1, 5000.00, 3.00, 12, '2025-01-01', '2026-01-01');
CALL activate_deposit(2, 100.00, 2.50, 4, '2025-01-01', '2025-12-31');

CREATE OR REPLACE EVENT update_deposit
ON SCHEDULE EVERY 1 MINUTE
DO
BEGIN
    UPDATE deposit
    SET completed = 1
    WHERE end_date <= CURRENT_DATE AND completed = 0;
END;
