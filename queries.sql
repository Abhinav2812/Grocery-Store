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

CREATE TABLE ADDRESS(
    Address_id INT PRIMARY KEY AUTO_INCREMENT,
    Address_1 varchar(100) NOT NULL,
    Address_2 varchar(100),
    zip_code INT NOT NULL,
    city varchar(100) NOT NULL,
    state varchar(100) NOT NULL,
    user_id varchar(100) NOT NULL,
    FOREIGN KEY (User_id) REFERENCES USER(User_id),
    UNIQUE( `Address_1`, `Address_2`, `zip_code`, `city`, `state`, `user_id`)
);

CREATE TABLE CATEGORY(
    Category_id INT PRIMARY KEY AUTO_INCREMENT,
    Category_Name varchar(100) NOT NULL UNIQUE,
    Category_Description text default NULL
);
CREATE TABLE MANUFACTURER(
    Manufacturer_id INT PRIMARY KEY AUTO_INCREMENT,
    Manufacturer_Name varchar(100) NOT NULL
);
CREATE TABLE PRODUCT(
    Product_id INT PRIMARY KEY AUTO_INCREMENT,
    Product_name varchar(100) NOT NULL,
    Units INT DEFAULT 0 NOT NULL,
    Picture varchar(100) DEFAULT "No_image_available.svg" NOT NULL,
    Weight DOUBLE NOT NULL,
    Category_id INT NOT NULL,
    Price DOUBLE NOT NULL,
    Product_description text,
    Manufacturer_id INT NOT NULL,
    FOREIGN KEY (Category_id) REFERENCES CATEGORY(Category_id),
    FOREIGN KEY (Manufacturer_id) REFERENCES MANUFACTURER(Manufacturer_id)
);
CREATE TABLE CART(
    user_id varchar(20) NOT NULL,
    Product_id INT NOT NULL,
    QUANTITY INT DEFAULT 1 NOT NULL,
    FOREIGN KEY (user_id) REFERENCES USER(user_id),
    FOREIGN KEY (Product_id) REFERENCES PRODUCT(Product_id),
    UNIQUE( `user_id`, `Product_id`)
);

#insertions
INSERT INTO `MANUFACTURER`(`Manufacturer_Name`) VALUES ('Patanjali'),('Ayur'),('Head & Shoulder'),('Himalaya'),('Park Avenue'),('Amway'),('Haldiram'),('Dettol'),('Savlon'),('Lux'),('Pears'),('Dove'),('Khadi'),('Lifebuoy'),('Pantene'),('Aakash'),('Cadbury'),('Ferrero'),('Gits'),('Roopji'),('MTR'),('Chings'),('Knorr'),('Sunfeast');
