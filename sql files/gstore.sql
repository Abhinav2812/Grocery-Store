-- phpMyAdmin SQL Dump
-- version 4.7.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Nov 14, 2017 at 04:55 PM
-- Server version: 10.1.25-MariaDB
-- PHP Version: 5.6.31

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";

DROP DATABASE IF EXISTS gstore;
CREATE DATABASE gstore;
DROP USER IF EXISTS 'gsuser'@'localhost'; 
CREATE USER 'gsuser'@'localhost' IDENTIFIED BY 'gspass';
GRANT ALL ON gstore.* TO 'gsuser'@'localhost';
FLUSH PRIVILEGES;
USE gstore;

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `gstore`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `PLACEORDER` (IN `username` VARCHAR(100), IN `pay_method` VARCHAR(100), IN `address_id` INT)  BEGIN
    DECLARE ord INT DEFAULT 0;
    DECLARE done INT DEFAULT FALSE;
    DECLARE pid INT DEFAULT 0;
    DECLARE Qty INT DEFAULT 0;
    DECLARE avlQty INT DEFAULT 0;
    DECLARE cur CURSOR FOR SELECT Product_id,Quantity FROM CART WHERE user_id = username;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    DECLARE exit handler for sqlexception
    BEGIN
                SIGNAL SQLSTATE '10000' SET MESSAGE_TEXT = "ERROR IN PROCEDURE";
        ROLLBACK;
    END;
    DECLARE exit handler for sqlwarning
    BEGIN
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
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `ADDRESS`
--

CREATE TABLE `ADDRESS` (
  `Address_id` int(11) NOT NULL,
  `Address_1` varchar(100) NOT NULL,
  `Address_2` varchar(100) DEFAULT NULL,
  `zip_code` int(11) NOT NULL,
  `city` varchar(100) NOT NULL,
  `state` varchar(100) NOT NULL,
  `user_id` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `ADDRESS`
--

INSERT INTO `ADDRESS` (`Address_id`, `Address_1`, `Address_2`, `zip_code`, `city`, `state`, `user_id`) VALUES
(15, '507-E', 'Hostel Building,IIT Indore', 452020, 'Indore', 'Madhya Pradesh', 'kritik'),
(16, '508-C, IITI', 'Simrol', 452020, 'indore', 'Madhya Pradesh', 'kr_abhinav'),
(14, '508-D, Boys\' Hostel,IIT Indore,Simrol', '', 453552, 'Indore', 'Madhya Pradesh', 'kr_abhinav');

--
-- Triggers `ADDRESS`
--
DELIMITER $$
CREATE TRIGGER `verify_zip_code_insert` BEFORE INSERT ON `ADDRESS` FOR EACH ROW BEGIN
	DECLARE vcity varchar(100) DEFAULT NULL;
    DECLARE vstate varchar(100) DEFAULT NULL;
    SELECT city, state INTO vcity, vstate FROM ADDRESS WHERE zip_code = NEW.zip_code LIMIT 1;
    IF vcity IS NOT NULL AND vstate IS NOT NULL THEN
    	IF NOT (vcity = NEW.city AND vstate = NEW.state) THEN
        	SIGNAL SQLSTATE '13232'
            SET MESSAGE_TEXT = "Pin codes do not match to city/state";
        END IF;
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `verify_zip_code_update` BEFORE UPDATE ON `ADDRESS` FOR EACH ROW BEGIN
    DECLARE vcity varchar(100) DEFAULT NULL;
    DECLARE vstate varchar(100) DEFAULT NULL;
    SELECT city, state INTO vcity, vstate FROM ADDRESS WHERE zip_code = NEW.zip_code AND (NOT address_id = NEW.address_id)  LIMIT 1;
    IF vcity IS NOT NULL AND vstate IS NOT NULL THEN
        IF NOT (vcity = NEW.city AND vstate = NEW.state) THEN
            SIGNAL SQLSTATE '13232'
            SET MESSAGE_TEXT = "Pin codes do not match to city/state";
        END IF;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `CART`
--

CREATE TABLE `CART` (
  `user_id` varchar(20) NOT NULL,
  `Product_id` int(11) NOT NULL,
  `QUANTITY` int(11) NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `CART`
--

INSERT INTO `CART` (`user_id`, `Product_id`, `QUANTITY`) VALUES
('kr_abhinav', 25, 1),
('kr_abhinav', 89, 1);

--
-- Triggers `CART`
--
DELIMITER $$
CREATE TRIGGER `rem_cart_insert` BEFORE INSERT ON `CART` FOR EACH ROW BEGIN
    IF NEW.QUANTITY < 0 THEN
        SIGNAL SQLSTATE '14000'
        SET MESSAGE_TEXT = 'Incorrect quantity entered';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `rem_cart_update` BEFORE UPDATE ON `CART` FOR EACH ROW BEGIN
    IF NEW.QUANTITY <= 0 THEN
        SIGNAL SQLSTATE '14000'
        SET MESSAGE_TEXT = 'Incorrect quantity entered';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `CATEGORY`
--

CREATE TABLE `CATEGORY` (
  `Category_id` int(11) NOT NULL,
  `Category_Name` varchar(100) NOT NULL,
  `Category_Description` text
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `CATEGORY`
--

INSERT INTO `CATEGORY` (`Category_id`, `Category_Name`, `Category_Description`) VALUES
(1, 'Biscuits', 'food items'),
(2, 'Personal Hygiene', 'Washroom item'),
(3, 'Chamanprash', 'Health item'),
(4, 'Tea', NULL),
(5, 'Spices', 'Domestic product'),
(6, 'Sweets', 'packed food item'),
(7, 'Toothpaste', 'Tooth health item'),
(8, 'Daily use product', 'Daily household product'),
(9, 'Worship goods', 'spritual things'),
(10, 'Noodle', 'fast food');

-- --------------------------------------------------------

--
-- Table structure for table `G_ORDER`
--

CREATE TABLE `G_ORDER` (
  `Order_id` int(11) NOT NULL,
  `Payment_Method` enum('Cash','Net Banking','Credit Card','Debit Card') NOT NULL DEFAULT 'Cash',
  `Order_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `Billing_id` int(11) DEFAULT NULL,
  `Amount` double NOT NULL DEFAULT '0',
  `Shipping_id` int(11) DEFAULT NULL,
  `Address_id` int(11) DEFAULT NULL,
  `user_id` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `G_ORDER`
--

INSERT INTO `G_ORDER` (`Order_id`, `Payment_Method`, `Order_time`, `Billing_id`, `Amount`, `Shipping_id`, `Address_id`, `user_id`) VALUES
(19, 'Cash', '2017-11-12 19:28:00', 142, 35, 475, 14, 'kr_abhinav'),
(26, 'Cash', '2017-11-13 02:09:12', 149, 15, 482, 16, 'kr_abhinav'),
(27, 'Cash', '2017-11-13 02:17:37', 150, 60, 483, 14, 'kr_abhinav'),
(28, 'Credit Card', '2017-11-13 02:20:17', 151, 15, 484, 16, 'kr_abhinav'),
(29, 'Credit Card', '2017-11-14 18:39:35', 152, 30, 485, 14, 'kr_abhinav'),
(30, 'Credit Card', '2017-11-14 20:52:41', 153, 15, 486, 15, 'kritik');

--
-- Triggers `G_ORDER`
--
DELIMITER $$
CREATE TRIGGER `genbillshipid` BEFORE INSERT ON `G_ORDER` FOR EACH ROW BEGIN
    DECLARE OID INT DEFAULT 0;
    SELECT auto_increment INTO OID FROM information_schema.TABLES WHERE table_name = 'G_ORDER' AND table_schema = 'gstore';
    IF(NEW.Billing_Id IS NULL) THEN
        SET NEW.Billing_id = OID + 123;
    END IF;
    IF(NEW.Shipping_Id IS NULL) THEN
        SET NEW.Shipping_id = OID + 456;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `MANUFACTURER`
--

CREATE TABLE `MANUFACTURER` (
  `Manufacturer_id` int(11) NOT NULL,
  `Manufacturer_Name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `MANUFACTURER`
--

INSERT INTO `MANUFACTURER` (`Manufacturer_id`, `Manufacturer_Name`) VALUES
(16, 'Aakash'),
(6, 'Amway'),
(2, 'Ayur'),
(41, 'Bajaj'),
(25, 'britannia'),
(17, 'Cadbury'),
(22, 'Chings'),
(42, 'Clinic all Clear'),
(35, 'close up'),
(34, 'colgate'),
(32, 'Crystamin'),
(36, 'Dabur'),
(8, 'Dettol'),
(27, 'devdarshan'),
(12, 'Dove'),
(38, 'Everest'),
(18, 'Ferrero'),
(19, 'Gits'),
(7, 'Haldiram'),
(3, 'Head & Shoulder'),
(4, 'Himalaya'),
(43, 'Himani'),
(13, 'Khadi'),
(23, 'Knorr'),
(14, 'Lifebuoy'),
(39, 'Lipton'),
(10, 'Lux'),
(28, 'mangaldeep'),
(40, 'MDH'),
(29, 'moksha'),
(21, 'MTR'),
(31, 'Nestle'),
(15, 'Pantene'),
(44, 'Parachute'),
(5, 'Park Avenue'),
(26, 'parle'),
(1, 'Patanjali'),
(11, 'Pears'),
(37, 'Pepsodent'),
(20, 'Roopji'),
(9, 'Savlon'),
(24, 'Sunfeast'),
(33, 'Tata');

-- --------------------------------------------------------

--
-- Table structure for table `PRODUCT`
--

CREATE TABLE `PRODUCT` (
  `Product_id` int(11) NOT NULL,
  `Product_name` varchar(100) NOT NULL,
  `Units` int(11) NOT NULL DEFAULT '0',
  `Picture` varchar(100) NOT NULL DEFAULT 'No_image_available.svg',
  `Weight` double NOT NULL,
  `Category_id` int(11) NOT NULL,
  `Price` double NOT NULL,
  `Product_description` text,
  `Manufacturer_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `PRODUCT`
--

INSERT INTO `PRODUCT` (`Product_id`, `Product_name`, `Units`, `Picture`, `Weight`, `Category_id`, `Price`, `Product_description`, `Manufacturer_id`) VALUES
(1, 'Dettol Original Soap', 80, 'Dettol_original.jpg', 75, 2, 26, 'The original Dettol Soap', 8),
(2, 'Skincare ', 75, 'Dettol_skincare.jpg', 75, 2, 25, 'The same effectiveness of the Original Dettol Soap in a different package', 8),
(3, 'Beauty Bar', 73, 'Dove_Beauty_Bar_Soap.jpg', 100, 2, 60, 'Feel the feather touch when you bath with dove beauty soap', 12),
(4, 'Daily Shine ', 92, 'Dove_Daily_Shine_Shampoo.jpg', 100, 2, 110, 'Your hair : smoother.', 12),
(5, 'Dant Kanti', 200, 'Dant_Kanti_Advance_Dental_toothpaste.jpg', 75, 7, 60, 'Herbal Toothpaste', 1),
(6, 'Alovera shampoo', 205, 'Patanjali_Aloe_Vera_Hair_shampoo.jpg', 110, 2, 95, 'Aloevera shampoo', 1),
(7, 'Alovera kranti soap', 210, 'Patanjali_Aloe_Vera_Kranti_Soap.jpg', 60, 2, 30, 'Alovera kranti daily wathing soap ', 1),
(8, 'Amla chamanprash', 180, 'Patanjali_Amla_Candy_Chamanprash.jpg', 250, 3, 550, 'Amla candy taste chamanprash', 1),
(9, 'chatpata chamanprash', 170, 'Patanjali_Amla_Chatpata_Candy_Chamanprash.jpg', 250, 3, 599, 'Amla candy chatpata spicy taste chamanprash', 1),
(10, 'badam chamanprash', 244, 'Patanjali_Badam_Pak_Chamanprash.jpeg', 500, 3, 575, 'patanjali ayurvedic badam chamaprsh', 1),
(11, 'gulkand chamanprash', 268, 'patanjali_gulkand_chamanprash.jpg', 500, 3, 585, 'patanjali ayurvedic gulkand flavour chamanprash', 1),
(12, 'hing chamanprash', 285, 'patanjali_hing_chamanprash.jpg', 500, 3, 581, 'patanjali pure ayurvedic hing chamanprash', 1),
(13, 'pachak hingpeda chamanprash', 782, 'patanjali_pachak_hingpeda_chamanprash.jpg', 500, 3, 589, 'patanjali pure ayurvedic pachak chamanprash with hing ingredients', 1),
(14, '50-50 maska chaska', 1111, 'britannia_50_50_maska_chaska_biscuit.jpg', 50, 1, 10, 'britannia 50 50 maska chaska biscuit', 25),
(15, 'britannia bourbon', 781, 'britannia_bourbon_chocolate_flavor_cream_biscuit.jpg', 100, 1, 10, 'britannia bourbon chocalte flavour cream biscuit with extra sugar ', 25),
(16, 'Good day chocolate', 412, 'britannia_good_day_cookies_choco_nut_biscuit.jpg', 100, 1, 30, 'britannia good day cookies chocolate flavour', 25),
(17, 'Good day elaichi', 458, 'britannia_good_day_nuts_elaichi_biscuit.jpg', 100, 1, 10, 'britannia good day nuts elaichi biscuit', 25),
(18, 'Little heart', 986, 'britannia_little_hearts_biscuit.jpg', 50, 1, 10, 'britannia heart shape namkeen and sweet little biscuits', 25),
(19, 'Marrie gold', 582, 'britannia_marie_gold_biscuit.jpg', 100, 1, 10, 'britannia marrie gold simple tea suppliment biscuit', 25),
(20, 'Milk bikis', 862, 'britannia_milk_bikis_biscuit.jpg', 100, 1, 10, 'britannia original milk bikis biscuit', 25),
(21, 'Cream Milk bikis', 472, 'britannia_milk_bikis_cream_biscuit.jpg', 150, 1, 25, 'britannia milk bikis with extra milk flavour cream', 25),
(22, 'coconut biscuit', 185, 'britannia_nice_time_sugar_showered_coconut_biscuit.jpg', 100, 1, 10, 'britannia coconut with sugar added showred biscuit', 25),
(23, 'Nutri fibre', 147, 'britannia_nutri_choice_hi_fibre_digestive_biscuit.jpg', 250, 1, 50, 'britannia nuticious high fibre digestive biscuit', 25),
(24, 'jim-jam', 235, 'britannia_treat_jim_jam_biscuit.jpg', 150, 1, 20, 'britannia treat jim jam biscuit', 25),
(25, 'cadbury oreo', 186, 'cadbury_oreo_choco_creme_biscuit.jpg', 100, 1, 15, 'cadbury oreo chocolate biscuit with milk flavor cream', 17),
(26, 'Hide and Seek', 752, 'parle_and_hide_seek_chocolate_biscuit.jpg', 150, 1, 25, 'parle hide and seek chocolate biscuit with extra granules of chocolates ', 26),
(27, 'krack-jack', 142, 'parle_krack_jack_biscuit.jpg', 100, 1, 10, 'parle crack jack sweet bhi and salti bhi', 26),
(28, 'Sandalwood agarbatti', 145, 'devdarshan_aura_sandalwood_agarbatti.jpg', 50, 9, 14, 'devdarshan aura snadalwood fragrance agarbatti', 27),
(29, 'Deep-sandal agarbatti', 87, 'devdarshan_deep_sandal_puja_agarbatti.jpg', 40, 9, 85, '', 27),
(30, 'Dhoop agarbatti', 73, 'devdarshan_lavender_dhoop_agarbatti.jpg', 60, 9, 55, 'devdarshan lavender fragrance dhoop agarbatti', 27),
(31, 'Bouquet agarbatti', 46, 'mangaldeep_bouquet_agarbatti.jpg', 40, 9, 49, 'mandaldeep classic bouquet agarbatti moderate fragrance', 28),
(32, 'Temple agarbatti', 186, 'mangaldeep_temple_gold_agarbatti.jpg', 60, 9, 80, 'maggaldeep gold agarbatti especially for temple purpose', 28),
(33, 'Darvesh agarbatti', 74, 'moksha_darvesh_agarbatti.jpg', 70, 9, 110, 'moksha classic darvesh agarbatti', 29),
(34, 'Royal agarbatti', 80, 'moksha_exotic_royal_agarbatti.jpg', 30, 9, 240, NULL, 29),
(35, 'Swarn kalash agarbatti', 120, 'moksha_swarn_kalash_agarbatti.jpg', 80, 9, 50, 'moksha swarn kalash moderate fragrance agarbatti', 29),
(36, 'Swarn-mogra agarbatti', 110, 'moksha_swarna_mogara_agarbatti.jpg', 90, 9, 45, 'moksha mogra fragrance exotic agarbatti', 29),
(37, 'swarn night-queen agarbatti', 214, 'moksha_swarna_night_queen_agarbatti.jpg', 100, 9, 65, 'moksha light fragrance night use agarbatti ', 29),
(40, 'swarn-chandan agarbatti', 78, 'moksha_swarna_chandan_agarbatti.jpg', 80, 9, 80, 'moksha swarna chnandan moderate fragrance daily use agarbatti', 29),
(41, 'Swarna-purple agarbatti', 98, 'moksha_swarna_purple_jewel_dhoop_agarbatti.jpg', 90, 9, 280, 'moksha premium category occassional use purple agarbatti', 29),
(46, 'singapore_noodle', 782, 'chings_singapore_noodle.jpg', 70, 10, 10, 'chings noodles of singapore style', 22),
(47, 'mast masala noodle', 80, 'knorr_mast_masala_noodle.jpg', 70, 10, 12, 'Knorr indian style mast masala noodle', 23),
(48, 'Maggi Amritsari achari noodle', 450, 'maggi_amritsari_achari_noodle.jpg', 70, 10, 12, 'Maagi with Amritsari style noodel', 31),
(49, 'Maggi Bengali masala noodle', 450, 'maggi_bengali_masala_noodle.jpg', 70, 10, 12, 'Maggi in favourte west bengal style', 31),
(50, 'Maggi Hot head peri-peri noodle', 340, 'maggi_hot_heads_peri_peri_noodles.jpg', 70, 10, 22, 'Maggi in your favorite peri peri style', 31),
(51, 'maggi masala noodle', 641, 'maggi_masala_noodle.jpg', 150, 10, 25, 'maggi orininal masala noodle', 31),
(52, 'Maggi Mumbaiya noodle', 422, 'maggi_mumbaiya_noodle.jpg', 70, 10, 12, 'maggi famous mumbai style noodle', 31),
(53, 'yippee magic masala', 491, 'sunfeast_magic_masala_noodle.jpg', 180, 10, 25, 'Yipee magic masala noodle pack of 2', 24),
(54, 'Yippee noodle', 319, 'Sunfeast_Yipee_normal_noodle.jpg', 75, 10, 10, 'Yipee normal classic noodle', 24),
(55, 'Yippee classic masala', 211, 'sunfeast_yippee_classic_masala_noodle.jpg', 180, 10, 25, 'Yipee Claasic spicy noodle pack of 2', 24),
(56, 'Classic rock salt', 143, 'crystamin_classic_rock_salt.jpg', 200, 8, 30, 'Crystamin classic pure rock salt powder', 32),
(57, 'Natural Himalayan pink rock salt', 120, 'crystamin_natural_himalyan_pink_rock_salt.jpg', 150, 8, 50, 'Pure himalyan pink rock salt powder', 32),
(58, 'Tata lite', 850, 'tata_lite_salt.jpg', 500, 8, 18, 'Tata lite salt', 33),
(59, 'Tata salt', 898, 'tata_salt.jpg', 500, 8, 16, 'Tata original salt', 33),
(60, 'Sohan papdi', 450, 'aakash_sohan_papdi.jpg', 250, 6, 140, 'aakash classic sohan papdi', 16),
(61, 'miniature milk silk', 218, 'cadbury_miniatures_dairy_milk_silk_chocolate.jpg', 400, 6, 840, 'Cadbury miniatures dairy milk silk chocolate', 17),
(62, 'rocher 6 pack', 280, 'ferrero_rocher_6pack_chocolate.jpg', 240, 6, 480, 'Ferrero rocher 6 pack chocolate', 18),
(63, 'Rocher 25 pack', 185, 'ferrero_rocher_premium_chocolate.jpg', 500, 6, 1250, 'Ferrerp rocher premium chocolate family pack', 18),
(64, 'Rasmalai', 637, 'gits_rasmalai.jpg', 500, 6, 240, 'Gits homemade rasmali powder', 19),
(65, 'Petha', 855, 'haldiram_agra_wale_petha.jpg', 250, 6, 85, 'Haldiram petha of Agra', 7),
(66, 'Gold sohanpapdi', 450, 'haldiram_gold_sohanpapdi.jpg', 250, 6, 330, 'Haldiram Gold premium sohanpapdi', 7),
(67, 'Gulabjamun', 889, 'haldiram_gulab_jamun.jpg', 500, 6, 250, 'Haldiram gulab jamun', 7),
(68, 'Sweets pack', 264, 'haldiram_pack_fest_special_sweet.jpg', 1250, 6, 1450, 'Haldiram festival special settes pack', 7),
(69, 'Rasgulla', 878, 'haldiram_rasgulla.jpg', 500, 6, 250, 'Haldiram rasgulla', 7),
(70, 'Sohan papdi', 980, 'haldiram_soan_papdi.jpg', 250, 6, 90, 'Haldiram classic sohan padi', 7),
(71, 'Gulabjamun powder', 580, 'mtr_gulab_jamun.jpg', 500, 6, 80, 'MTR premium gulab jamun powder', 21),
(72, 'Rasgulla', 336, 'roopji_rasgulla.jpg', 500, 6, 190, 'Roopji rasgulla', 20),
(73, 'Dabur red', 580, 'dabur_red_ayurvedic_toothpaste.jpg', 100, 7, 60, 'Dabur red ayurvedic toothpaste', 36),
(74, 'Close-up everfresh', 410, 'close_up_ever_fresh_red_hot_gel_toothpaste.jpg', 110, 7, 40, 'Close-up everfresh red hot gel toothpaste', 35),
(75, 'Colgate Active salt', 380, 'colgate_active_salt_minerals_toothpaste.jpg', 100, 7, 42, 'Colgate active salt mineral toothpaste', 34),
(76, 'Colgate barbie', 196, 'colgate_barbie_strawberry_kids_toothpaste.jpg', 100, 7, 76, 'Colgate barbie strawberry kids toothpaste', 34),
(77, 'Colgate maxfresh gel', 435, 'colgate_maxfresh_spicy_red_gel_toothpaste.jpg', 200, 7, 96, 'Colgate maxfresh spicy red gel toothpaste', 34),
(78, 'Naturak herbal', 96, 'colgate_natural_herbal_toothpaste.jpg', 100, 7, 64, 'Colgate natural herbal toothpaste', 34),
(79, 'Total charcoal', 112, 'colgate_total_charcoal_toothpaste.jpg', 100, 7, 125, 'Colgate total charcoal toothpaste', 34),
(80, 'Dabur meswak', 45, 'dabur_meswak_toothpaste.jpg', 100, 7, 65, 'Dabur meswak toothpaste', 36),
(81, 'Dant kanti Regular', 225, 'patanjali_dant_kanti_regular_toothpaste.jpg', 100, 7, 85, 'Patanjali dant kanti regular toothpaste', 1),
(82, 'Pepsodent salt', 89, 'pepsodent_clove_and_salt_toothpaste.jpg', 100, 7, 44, 'Pepsodent clove and salt toothpaste', 37),
(83, 'Pepsodent germicheck', 129, 'pepsodent_germicheck_toothpaste.jpg', 100, 7, 65, 'Pepsodent germicheck toothpaste', 37),
(84, 'Himalaya Active care', 110, 'himalaya_active_fresh_gel_toothpaste.jpg', 100, 7, 80, 'Himalaya active fresh gel toothpaste', 4),
(85, 'Complete care', 63, 'himalaya_complete_care_toothpaste.jpg', 100, 7, 65, 'Himalaya complete care toothpaste', 4),
(86, 'Ambay santique', 54, 'ambay_satinique_shampoo.jpg', 80, 2, 112, 'Ambay santique shampoo', 6),
(87, 'Ayur natural', 887, 'ayur_natural_shampoo.jpg', 150, 2, 185, 'Ayur natural shampoo', 2),
(88, 'Dove intense repair', 229, 'dove_intense_repair_Conditioner.jpg', 100, 2, 114, 'Dove intense repair conditioner', 12),
(89, 'Head and shoulder', 365, 'head_and_shoulder_shampoo.jpg', 120, 2, 135, 'Head and shoulder lemon shampoo', 3),
(90, 'Neem soap', 234, 'himalaya_neem_soap.jpg', 50, 2, 23, 'Himalaya neem soap', 4),
(91, 'Chandan soap', 87, 'khadi_chandan_soap.jpg', 40, 2, 20, 'Khadi chandan soap', 13),
(92, 'Neem soap', 68, 'khadi_neem_soap.jpg', 40, 2, 20, 'Khadi neem soap', 13),
(93, 'Lifebuoy lemonfresh', 653, 'lifebuoy_lemonfresh_soap.jpg', 60, 2, 24, 'Lifebuoy lemonfresh soap', 14),
(94, 'Fresh splesh', 235, 'lux_fresh_splash_soap.jpg', 60, 2, 18, 'Lux fresh splash soap', 10),
(95, 'Soft touch', 326, 'lux_soft_touch_soap.jpg', 60, 2, 18, 'Lux soft touch soap', 10),
(96, 'Beer shampoo', 529, 'park_avenue_beer_shampoo.jpg', 120, 2, 540, 'Park avenue beer shampoo pack of two', 5),
(97, 'Savlon', 68, 'savlon_soap.jpg', 50, 2, 22, 'Savlon medicare soap', 9),
(98, 'Pantene shiny', 236, 'pantene_shiny_shampoo.jpg', 120, 2, 108, 'Pantene shiny shampoo', 15),
(99, 'masala chai', 163, 'everest_masala_tea.jpg', 50, 4, 20, 'Everest masala tea', 38),
(100, 'Darjeeling tea', 349, 'lipton_darjeeling_tea.jpg', 100, 4, 35, 'Lipton darjeeling tea', 39),
(101, 'Green tea', 486, 'lipton_green_tea.jpg', 100, 4, 58, 'Lipton green tea', 39),
(102, 'Agni', 124, 'tata_tea_agni.jpg', 50, 4, 18, 'Tata tea agni', 33),
(103, 'Agni leaf', 163, 'tata_tea_agni_leaf.jpg', 100, 4, 28, 'Tata tea agni leaf', 33),
(104, 'Chakra Gold', 138, 'tata_tea_chakra_gold_dust_tea.jpg', 250, 4, 180, 'Tata tea chakra gold dust tea', 33),
(105, 'Elaichi tea', 182, 'tata_tea_elaichi_chai.jpg', 150, 4, 60, 'Tata tea elaichi chai', 33),
(106, 'Gold leaf', 94, 'tata_tea_gold_leaf.jpg', 50, 4, 28, 'Tata tea gold leaf', 33),
(107, 'Premium leaf', 138, 'tata_tea_premium_leaf.jpg', 200, 4, 290, 'Tata tea premium leaf', 33),
(108, 'Darjeeling leaf', 167, 'tata_tea_premium_darjeeling_leaf.jpg', 100, 4, 35, 'Tata tea premium darjeeling leaf', 33),
(139, 'Garam masala', 143, 'mdh_masala_garam.jpg', 50, 5, 50, 'MDH garam masala', 40),
(140, 'coriander', 234, 'mtr_powder_coriander.jpg', 100, 5, 80, 'MTR corinder powder', 21),
(141, 'Turmeric', 416, 'mtr_powder_turmeric.jpg', 100, 5, 40, 'MTR turmeric powder', 21),
(142, 'Ajwain', 423, 'mtr_royal_ajwain_whole.jpg', 100, 5, 60, 'MTR royal ajwain whole', 21),
(143, 'Green elaichi', 764, 'mtr_royal_cardamomelaichi_green.jpg', 100, 5, 85, 'MTR royal cardamomelaichi_green', 21),
(144, 'Dalchini', 438, 'mtr_royal_cinnamon_dalchini.jpg', 80, 5, 45, 'MTR royal cinnamon dalchini', 21),
(145, 'Laung', 726, 'mtr_royal_cloves_launga.jpg', 50, 5, 16, 'MTR royal cloves launga', 21),
(146, 'Methi', 462, 'mtr_royal_fenugreek_methi.jpg', 100, 4, 40, 'MTR royal fenugreek methi', 21),
(147, 'Sounf', 249, 'mtr_royal_sounf_green.jpg', 50, 5, 12, 'MTR royal green sonf', 21),
(148, 'Rai', 483, 'mtrroyal_mustard_rai_small.jpg', 100, 5, 30, 'MTR royal mustard small rai', 21),
(149, 'Bajaj Almond drop', 435, 'bajaj_almond_drops_hair_oil.jpg', 100, 8, 85, 'Bajaj almond drops hair oil', 41),
(150, 'Brahmi Amla', 248, 'bajaj_brahmi_amla_ayurvedic_hair_oil.jpg', 80, 8, 40, 'Bajaj brahmi amla ayurvedic hair oil', 41),
(151, 'Anti dandruff oil', 236, 'himalaya_anti_dandruff_hair_oil.jpg', 100, 8, 90, 'Himalaya Anti-dandruff hair oil', 4);

--
-- Triggers `PRODUCT`
--
DELIMITER $$
CREATE TRIGGER `pqty_ins` BEFORE INSERT ON `PRODUCT` FOR EACH ROW BEGIN
	IF NEW.Units < 0 THEN
    	SIGNAL SQLSTATE '12345' 
        SET MESSAGE_TEXT = 'No of available products cannot be less than 0';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `pqty_upd` BEFORE UPDATE ON `PRODUCT` FOR EACH ROW BEGIN
	IF NEW.Units < 0 THEN
    	SIGNAL SQLSTATE '12345' 
        SET MESSAGE_TEXT = 'No of available products cannot be less than 0';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `PRODUCT_ORDER`
--

CREATE TABLE `PRODUCT_ORDER` (
  `Product_id` int(11) DEFAULT NULL,
  `Order_id` int(11) DEFAULT NULL,
  `Quantity` int(11) DEFAULT '0',
  `price` double DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `PRODUCT_ORDER`
--

INSERT INTO `PRODUCT_ORDER` (`Product_id`, `Order_id`, `Quantity`, `price`) VALUES
(14, 19, 1, 10),
(15, 19, 1, 10),
(25, 19, 1, 15),
(25, 26, 1, 15),
(25, 27, 4, 15),
(25, 28, 1, 15),
(25, 29, 2, 15),
(25, 30, 1, 15);

--
-- Triggers `PRODUCT_ORDER`
--
DELIMITER $$
CREATE TRIGGER `ins_po` BEFORE INSERT ON `PRODUCT_ORDER` FOR EACH ROW BEGIN
    DECLARE cost DOUBLE DEFAULT NULL;
    SELECT price INTO cost FROM PRODUCT WHERE product_id = NEW.Product_id;
    SET NEW.Price = cost; 
    UPDATE PRODUCT SET Units = Units - NEW.Quantity Where PRODUCT.Product_id = NEW.Product_id;
    UPDATE G_ORDER SET amount = amount + (NEW.Price)*(NEW.Quantity) WHERE Order_id = NEW.Order_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `upd_po` BEFORE UPDATE ON `PRODUCT_ORDER` FOR EACH ROW BEGIN
    UPDATE PRODUCT SET Units = Units - NEW.Quantity + OLD.Quantity Where PRODUCT.Product_id = NEW.Product_id;
    UPDATE G_ORDER SET amount = amount + (NEW.Price)*(NEW.Quantity-OLD.Quantity) WHERE Order_id = NEW.Order_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `USER`
--

CREATE TABLE `USER` (
  `user_id` varchar(20) NOT NULL,
  `email_id` varchar(100) NOT NULL,
  `password` varchar(200) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `mobile_no` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `USER`
--

INSERT INTO `USER` (`user_id`, `email_id`, `password`, `first_name`, `last_name`, `mobile_no`) VALUES
('kritik', 'sharmakritikmukesh@gmail.com', '$2y$10$KyYruzMQNTMzRhc2H7njZuGI58BE.6/krAWn6q80c7kuaCg6o2aqC', 'kritik', 'sharma', '9537073595'),
('kr_abhi', 'jlnlknf@gmail.com', '$2y$10$ghkOi5kSEVJfo4o2lniKU.JKTUyRJrd0yUMT.rH23ydmJ9.kkUD4W', 'kfnjdkv', 'jlxgnsn', '9545467532'),
('kr_abhinav', 'krabhinav2812@gmail.com', '$2y$10$3i1p7awc7oTY5oWs/iBpZehTO22gOikiQ6pmWeWaKskPJAS6oSE4q', 'Kumar', 'Abhinav', '8851096873'),
('kr_abhinav2', 'abhi.genius.cool@gmail.com', '$2y$10$3i1p7awc7oTY5oWs/iBpZehTO22gOikiQ6pmWeWaKskPJAS6oSE4q', 'Kumr', 'ksnf', '8674364356');

--
-- Triggers `USER`
--
DELIMITER $$
CREATE TRIGGER `email_insert_check` BEFORE INSERT ON `USER` FOR EACH ROW BEGIN
    IF NOT(SELECT NEW.Email_id REGEXP '^[^@]+@[^@]+.[^@]{2,}$') THEN
    	SIGNAL SQLSTATE '40001'
        SET MESSAGE_TEXT = "Invalid Email Id!";
   	END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `email_update_check` BEFORE UPDATE ON `USER` FOR EACH ROW BEGIN
    IF NOT(SELECT NEW.Email_id REGEXP '^[^@]+@[^@]+.[^@]{2,}$') THEN
    	SIGNAL SQLSTATE '40001'
        SET MESSAGE_TEXT = "Invalid Email Id!";
   	END IF;
END
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `ADDRESS`
--
ALTER TABLE `ADDRESS`
  ADD PRIMARY KEY (`Address_id`),
  ADD UNIQUE KEY `Address_1` (`Address_1`,`Address_2`,`zip_code`,`city`,`state`,`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `CART`
--
ALTER TABLE `CART`
  ADD UNIQUE KEY `user_id` (`user_id`,`Product_id`),
  ADD KEY `Product_id` (`Product_id`);

--
-- Indexes for table `CATEGORY`
--
ALTER TABLE `CATEGORY`
  ADD PRIMARY KEY (`Category_id`),
  ADD UNIQUE KEY `Category_Name` (`Category_Name`);

--
-- Indexes for table `G_ORDER`
--
ALTER TABLE `G_ORDER`
  ADD PRIMARY KEY (`Order_id`),
  ADD UNIQUE KEY `Shipping_id` (`Shipping_id`),
  ADD UNIQUE KEY `Billing_id` (`Billing_id`),
  ADD KEY `Address_id` (`Address_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `MANUFACTURER`
--
ALTER TABLE `MANUFACTURER`
  ADD PRIMARY KEY (`Manufacturer_id`),
  ADD UNIQUE KEY `Manufacturer_Name` (`Manufacturer_Name`);

--
-- Indexes for table `PRODUCT`
--
ALTER TABLE `PRODUCT`
  ADD PRIMARY KEY (`Product_id`),
  ADD KEY `Category_id` (`Category_id`),
  ADD KEY `Manufacturer_id` (`Manufacturer_id`);

--
-- Indexes for table `PRODUCT_ORDER`
--
ALTER TABLE `PRODUCT_ORDER`
  ADD UNIQUE KEY `Product_id` (`Product_id`,`Order_id`),
  ADD KEY `Order_id` (`Order_id`);

--
-- Indexes for table `USER`
--
ALTER TABLE `USER`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `email_id` (`email_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `ADDRESS`
--
ALTER TABLE `ADDRESS`
  MODIFY `Address_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;
--
-- AUTO_INCREMENT for table `CATEGORY`
--
ALTER TABLE `CATEGORY`
  MODIFY `Category_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT for table `G_ORDER`
--
ALTER TABLE `G_ORDER`
  MODIFY `Order_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;
--
-- AUTO_INCREMENT for table `MANUFACTURER`
--
ALTER TABLE `MANUFACTURER`
  MODIFY `Manufacturer_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;
--
-- AUTO_INCREMENT for table `PRODUCT`
--
ALTER TABLE `PRODUCT`
  MODIFY `Product_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=152;
--
-- Constraints for dumped tables
--

--
-- Constraints for table `ADDRESS`
--
ALTER TABLE `ADDRESS`
  ADD CONSTRAINT `ADDRESS_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `USER` (`user_id`);

--
-- Constraints for table `CART`
--
ALTER TABLE `CART`
  ADD CONSTRAINT `CART_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `USER` (`user_id`),
  ADD CONSTRAINT `CART_ibfk_2` FOREIGN KEY (`Product_id`) REFERENCES `PRODUCT` (`Product_id`);

--
-- Constraints for table `G_ORDER`
--
ALTER TABLE `G_ORDER`
  ADD CONSTRAINT `G_ORDER_ibfk_1` FOREIGN KEY (`Address_id`) REFERENCES `ADDRESS` (`Address_id`),
  ADD CONSTRAINT `G_ORDER_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `USER` (`user_id`);

--
-- Constraints for table `PRODUCT`
--
ALTER TABLE `PRODUCT`
  ADD CONSTRAINT `PRODUCT_ibfk_1` FOREIGN KEY (`Category_id`) REFERENCES `CATEGORY` (`Category_id`),
  ADD CONSTRAINT `PRODUCT_ibfk_2` FOREIGN KEY (`Manufacturer_id`) REFERENCES `MANUFACTURER` (`Manufacturer_id`);

--
-- Constraints for table `PRODUCT_ORDER`
--
ALTER TABLE `PRODUCT_ORDER`
  ADD CONSTRAINT `PRODUCT_ORDER_ibfk_1` FOREIGN KEY (`Product_id`) REFERENCES `PRODUCT` (`Product_id`),
  ADD CONSTRAINT `PRODUCT_ORDER_ibfk_2` FOREIGN KEY (`Order_id`) REFERENCES `G_ORDER` (`Order_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
