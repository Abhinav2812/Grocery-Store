#create database
CREATE DATABASE gstore;

#user creation and permission setting
DROP USER IF EXISTS 'gsuser'@'localhost'; 
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
    Manufacturer_Name varchar(100) NOT NULL UNIQUE
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
CREATE TABLE G_ORDER(
    Order_id INT PRIMARY KEY AUTO_INCREMENT,
    Payment_Method ENUM('Cash','Net Banking','Credit Card','Debit Card') DEFAULT 'Cash' NOT NULL,
    Order_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Billing_id INT UNIQUE,
    Amount DOUBLE NOT NULL DEFAULT 0,
    Shipping_id INT UNIQUE,
    Address_id INT,
    user_id varchar(20) NOT NULL,
    FOREIGN KEY (Address_id) REFERENCES ADDRESS(Address_id),
    FOREIGN KEY (user_id) REFERENCES USER(user_id)
);
CREATE TABLE PRODUCT_ORDER(
    Product_id INT,
    Order_id INT,
    Quantity INT DEFAULT 0,
    price DOUBLE DEFAULT 0,
    FOREIGN KEY (Product_id) REFERENCES PRODUCT(Product_id),
    FOREIGN KEY (Order_id) REFERENCES G_ORDER(Order_id),
    UNIQUE (Product_id,Order_id)
);

#triggers

#to check that product quantity never goes below zero
DELIMITER //
CREATE TRIGGER pqty_ins BEFORE INSERT ON PRODUCT
FOR EACH ROW
BEGIN
    IF NEW.Units < 0 THEN
        SIGNAL SQLSTATE '12345' 
        SET MESSAGE_TEXT = 'No of available products cannot be less than 0';
    END IF;
END;//
CREATE TRIGGER pqty_upd BEFORE UPDATE ON PRODUCT
FOR EACH ROW
BEGIN
    IF NEW.Units < 0 THEN
        SIGNAL SQLSTATE '12345' 
        SET MESSAGE_TEXT = 'No of available products cannot be less than 0';
    END IF;
END;//
DELIMITER ;

#verify email id is in correct format
DELIMITER //
CREATE TRIGGER email_update_check BEFORE UPDATE ON USER
FOR EACH ROW
BEGIN
    IF NOT(SELECT NEW.Email_id REGEXP '^[^@]+@[^@]+\.[^@]{2,}$') THEN
        SIGNAL SQLSTATE '40001'
        SET MESSAGE_TEXT = "Invalid Email Id!";
    END IF;
END;
//
CREATE TRIGGER email_insert_check BEFORE INSERT ON USER
FOR EACH ROW
BEGIN
    IF NOT(SELECT NEW.Email_id REGEXP '^[^@]+@[^@]+\.[^@]{2,}$') THEN
        SIGNAL SQLSTATE '40001'
        SET MESSAGE_TEXT = "Invalid Email Id!";
    END IF;
END;
//
DELIMITER ;

#verify pin code uniquely determines city and state
DELIMITER //
CREATE TRIGGER verify_zip_code_insert BEFORE INSERT ON ADDRESS
FOR EACH ROW
BEGIN
    DECLARE vcity varchar(100) DEFAULT NULL;
    DECLARE vstate varchar(100) DEFAULT NULL;
    SELECT city, state INTO vcity, vstate FROM ADDRESS WHERE zip_code = NEW.zip_code LIMIT 1;
    IF vcity IS NOT NULL AND vstate IS NOT NULL THEN
        IF NOT (vcity = NEW.city AND vstate = NEW.state) THEN
            SIGNAL SQLSTATE '13232'
            SET MESSAGE_TEXT = "Pin codes do not match to city/state";
        END IF;
    END IF;
END;//
CREATE TRIGGER verify_zip_code_update BEFORE UPDATE ON ADDRESS
FOR EACH ROW
BEGIN
    DECLARE vcity varchar(100) DEFAULT NULL;
    DECLARE vstate varchar(100) DEFAULT NULL;
    SELECT city, state INTO vcity, vstate FROM ADDRESS WHERE zip_code = NEW.zip_code AND (NOT address_id = NEW.address_id)  LIMIT 1;
    IF vcity IS NOT NULL AND vstate IS NOT NULL THEN
        IF NOT (vcity = NEW.city AND vstate = NEW.state) THEN
            SIGNAL SQLSTATE '13232'
            SET MESSAGE_TEXT = "Pin codes do not match to city/state";
        END IF;
    END IF;
END;//
DELIMITER ;

#generate billing and shipping id for order
DELIMITER //
CREATE TRIGGER genbillshipid BEFORE INSERT ON G_ORDER
FOR EACH ROW
BEGIN
    DECLARE OID INT DEFAULT 0;
    SELECT auto_increment INTO OID FROM information_schema.TABLES WHERE table_name = 'G_ORDER' AND table_schema = 'gstore';
    IF(NEW.Billing_Id IS NULL) THEN
        SET NEW.Billing_id = OID + 123;
    END IF;
    IF(NEW.Shipping_Id IS NULL) THEN
        SET NEW.Shipping_id = OID + 456;
    END IF;
END;//
DELIMITER ;

#Check that Quantity available in cart is valid
DELIMITER //
CREATE TRIGGER rem_cart_update BEFORE UPDATE ON CART
FOR EACH ROW
BEGIN
    IF NEW.QUANTITY <= 0 THEN
        SIGNAL SQLSTATE '14000'
        SET MESSAGE_TEXT = 'Incorrect quantity entered';
    END IF;
END;//
CREATE TRIGGER rem_cart_insert BEFORE INSERT ON CART
FOR EACH ROW
BEGIN
    IF NEW.QUANTITY < 0 THEN
        SIGNAL SQLSTATE '14000'
        SET MESSAGE_TEXT = 'Incorrect quantity entered';
    END IF;
END;//
DELIMITER ;

#insert a product into order
DELIMITER //
CREATE TRIGGER ins_po BEFORE INSERT ON PRODUCT_ORDER
FOR EACH ROW
BEGIN
    DECLARE cost DOUBLE DEFAULT NULL;
    SELECT price INTO cost FROM PRODUCT WHERE product_id = NEW.Product_id;
    SET NEW.Price = cost; 
    UPDATE PRODUCT SET Units = Units - NEW.Quantity Where PRODUCT.Product_id = NEW.Product_id;
    UPDATE G_ORDER SET amount = amount + (NEW.Price)*(NEW.Quantity) WHERE Order_id = NEW.Order_id;
END;//
CREATE TRIGGER upd_po BEFORE UPDATE ON PRODUCT_ORDER
FOR EACH ROW
BEGIN
    UPDATE PRODUCT SET Units = Units - NEW.Quantity + OLD.Quantity Where PRODUCT.Product_id = NEW.Product_id;
    UPDATE G_ORDER SET amount = amount + (NEW.Price)*(NEW.Quantity-OLD.Quantity) WHERE Order_id = NEW.Order_id;
END;//
DELIMITER ;

#procedures

DELIMITER //
CREATE PROCEDURE PLACEORDER(IN username varchar(100),IN pay_method varchar(100),IN address_id INT)
BEGIN
    DECLARE ord INT DEFAULT 0;
    DECLARE done INT DEFAULT FALSE;
    DECLARE pid INT DEFAULT 0;
    DECLARE Qty INT DEFAULT 0;
    DECLARE avlQty INT DEFAULT 0;
    DECLARE cur CURSOR FOR SELECT Product_id,Quantity FROM CART WHERE user_id = username;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE exit handler for sqlexception
    BEGIN
        -- ERROR
        SIGNAL SQLSTATE '10000' SET MESSAGE_TEXT = "ERROR IN PROCEDURE";
        ROLLBACK;
    END;
    DECLARE exit handler for sqlwarning
    BEGIN
        -- WARNING
        SIGNAL SQLSTATE '10000' SET MESSAGE_TEXT = "WARNING IN PROCEDURE";
        ROLLBACK;
    END;
    OPEN cur;
    START TRANSACTION;
    SELECT auto_increment INTO ord FROM information_schema.TABLES WHERE table_name = 'G_ORDER' AND table_schema = 'gstore';
    INSERT INTO G_ORDER (Payment_Method, Address_id, user_id) VALUES (pay_method, address_id,username);
    read_loop : LOOP
        FETCH cur INTO pid,Qty;
        IF done THEN
            LEAVE read_loop;
        END IF;
        INSERT INTO PRODUCT_ORDER(Product_id, Order_id, Quantity) VALUES (pid,ord,qty);
    END LOOP;
    DELETE FROM CART WHERE user_id = username;
    COMMIT;
END;//
DELIMITER ;

#insertions
INSERT INTO `MANUFACTURER`(`Manufacturer_Name`) VALUES ('Patanjali'),('Ayur'),('Head & Shoulder'),('Himalaya'),('Park Avenue'),('Amway'),('Haldiram'),('Dettol'),('Savlon'),('Lux'),('Pears'),('Dove'),('Khadi'),('Lifebuoy'),('Pantene'),('Aakash'),('Cadbury'),('Ferrero'),('Gits'),('Roopji'),('MTR'),('Chings'),('Knorr'),('Sunfeast');

INSERT INTO `PRODUCT`(`Product_name`, `Units`, `Picture`, `Weight`, `Category_id`, `Price`, `Product_description`, `Manufacturer_id`) VALUES ('Dettol Skincare Soap',75,'Dettol_skincare.jpg',75,2,25,'The same effectiveness of the Original Dettol Soap in a different package',8),('Dove Beauty Bar Soap',75,'Dove_Beauty_Bar_Soap.jpg',100,2,60,'Feel the feather touch when you bath with dove beauty soap',12),VALUES ('Dove Daily Shine Shampoo', '92', 'Dove_Daily_Shine_Shampoo.jpg', '100', '2', '110', 'Your hair : smoother.', '12');