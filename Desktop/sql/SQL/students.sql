
SHOW DATABASES;

CREATE TABLE  students (
id INT AUTO_INCREMENT primary key,
first_name VARCHAR(50),
last_name VARCHAR(50),
age INT,
major VARCHAR(100)
);


select * from students

insert into students (first_name, last_name, age, major)
values
('John', 'Doe', 22, 'Computer science'),
('Jane', 'Smith', 21, 'Mathematics'),
('Emily', 'Johnson', 23, 'Biology'),
('Michael', 'Brown', 20, 'Physics');

select * from students

insert into students (first_name, last_name, major)
values
('John', 'Doe','Computer science')

INSERT INTO students (id, first_name, last_name, major) 
VALUES (1000, 'Andrew', 'Kenedy', 'Mathematics');

select * from students where id > 5
and AGE is null

delete from students where id > 999
rollback 

UPDATE students
SET age = 20
WHERE age is null;

select * from students
where age is not null

#klasy gdzie jest id

update students
SET last_name = UPPER(last_name);

CREATE TABLE  studentss (
id INT AUTO_INCREMENT primary key,
cosik VARCHAR(100)
);

select * from studentss

ALTER TABLE studentss
drop email;






