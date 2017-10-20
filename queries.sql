#create database
CREATE DATABASE gstore;

#user creation and permission setting
CREATE USER 'gsuser'@'localhost' IDENTIFIED BY 'gspass';
GRANT ALL ON gstore.* TO 'gsuser'@'localhost';
FLUSH PRIVILEGES;

#create the tables
CREATE TABLE USER
(
    user_id varchar(20) PRIMARY KEY,
    email_id varchar(20) UNIQUE NOT NULL,
    password varchar(20),
   	first_name varchar(50) NOT NULL,
    last_name varchar(50),
    mobile_no varchar(20)
);


