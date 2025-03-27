-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Mar 27, 2025 at 12:14 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `qwerty123_haaletus`
--

DELIMITER $$
--
-- Procedures
--
CREATE PROCEDURE `lisa_haaletajad` ()   BEGIN
DECLARE i INT DEFAULT 1;
DECLARE suva_nimi VARCHAR(100);
DECLARE suva_haal ENUM('poolt', 'vastu');

WHILE i <= 11 DO
       
        SET suva_nimi = CONCAT('Valija_', i, 'Eesnimi, ', 'Valija_', i, 'Perenimi');

        
        SET suva_haal = IF(RAND() > 0.5, 'poolt', 'vastu');

        
        INSERT INTO haaletus (nimi, otsus) VALUES (suva_nimi, suva_haal);

        
        SET i = i + 1;
END WHILE;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `haaletus`
--

CREATE TABLE `haaletus` (
  `haaletaja_id` int(11) NOT NULL,
  `nimi` varchar(100) NOT NULL,
  `aeg` timestamp NOT NULL DEFAULT current_timestamp(),
  `otsus` enum('poolt','vastu') NOT NULL,
  `arvestatud` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Triggers `haaletus`
--
DELIMITER $$
CREATE TRIGGER `after_update_log` AFTER UPDATE ON `haaletus` FOR EACH ROW BEGIN
    DECLARE first_vote_time DATETIME;

    SELECT MIN(aeg) INTO first_vote_time 
    FROM haaletus 
    WHERE haaletaja_id = NEW.haaletaja_id;

    IF first_vote_time IS NOT NULL AND TIMESTAMPDIFF(MINUTE, first_vote_time, NOW()) <= 5 THEN
        INSERT INTO logi(muutja_nimi, eelmine_haal, uus_haal)
        VALUES (NEW.nimi, OLD.otsus, NEW.otsus);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `haaletus_after_insert` AFTER INSERT ON `haaletus` FOR EACH ROW BEGIN

DECLARE first_vote_time DATETIME;

    SELECT MIN(aeg) INTO first_vote_time 
    FROM haaletus 
    WHERE haaletaja_id = NEW.haaletaja_id;

IF TIMESTAMPDIFF(MINUTE, NEW.aeg, NOW()) <= 5 and (select count(*) from haaletus) = 1 THEN
insert into tulemused (haaletanute_arv, h_alguse_aeg, h_lopu_aeg, poolte_haaled, vastu_haaled) VALUES ((select count(*) from haaletus), NEW.aeg, new.aeg + interval 5 minute, (select sum(otsus = "poolt") from haaletus), (select sum(otsus = "vastu") from haaletus));
ELSEIF TIMESTAMPDIFF(MINUTE, NEW.aeg, NOW()) <= 5 and (select count(*) from haaletus) > 1 THEN
update tulemused set haaletanute_arv = (select count(*) from haaletus),
poolte_haaled = (select sum(otsus = "poolt") from haaletus),
vastu_haaled = (select sum(otsus = "vastu") from haaletus);
end if;

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `haaletus_after_update` AFTER UPDATE ON `haaletus` FOR EACH ROW BEGIN

DECLARE first_vote_time DATETIME;

    SELECT MIN(aeg) INTO first_vote_time 
    FROM haaletus 
    WHERE haaletaja_id = NEW.haaletaja_id;

IF TIMESTAMPDIFF(MINUTE, NEW.aeg, NOW()) <= 5 and (select count(*) from haaletus) = 1 THEN
insert into tulemused (haaletanute_arv, h_alguse_aeg, poolte_haaled, vastu_haaled) VALUES ((select count(*) from haaletus), NEW.aeg, (select sum(otsus = "poolt") from haaletus), (select sum(otsus = "vastu") from haaletus));
ELSEIF TIMESTAMPDIFF(MINUTE, NEW.aeg, NOW()) <= 5 and (select count(*) from haaletus) > 1 THEN
update tulemused set haaletanute_arv = (select count(*) from haaletus),
poolte_haaled = (select sum(otsus = "poolt") from haaletus),
vastu_haaled = (select sum(otsus = "vastu") from haaletus);
end if;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `haaletus_before_insert` BEFORE INSERT ON `haaletus` FOR EACH ROW begin
    declare new_row_count int unsigned;
	
    set new_row_count = (select count(*) from haaletus);
    
    if new_row_count <= 11 then
    	set new.arvestatud = 1;
    end if;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `logi`
--

CREATE TABLE `logi` (
  `logi_id` int(11) NOT NULL,
  `muutja_nimi` varchar(100) NOT NULL,
  `muutmise_aeg` timestamp NOT NULL DEFAULT current_timestamp(),
  `eelmine_haal` enum('poolt','vastu') NOT NULL,
  `uus_haal` enum('poolt','vastu') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tulemused`
--

CREATE TABLE `tulemused` (
  `haaletuse_id` int(11) NOT NULL,
  `haaletanute_arv` int(11) NOT NULL,
  `h_alguse_aeg` timestamp NOT NULL,
  `h_lopu_aeg` timestamp NULL DEFAULT NULL,
  `poolte_haaled` int(11) NOT NULL,
  `vastu_haaled` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `haaletus`
--
ALTER TABLE `haaletus`
  ADD PRIMARY KEY (`haaletaja_id`);

--
-- Indexes for table `logi`
--
ALTER TABLE `logi`
  ADD PRIMARY KEY (`logi_id`);

--
-- Indexes for table `tulemused`
--
ALTER TABLE `tulemused`
  ADD PRIMARY KEY (`haaletuse_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `haaletus`
--
ALTER TABLE `haaletus`
  MODIFY `haaletaja_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `logi`
--
ALTER TABLE `logi`
  MODIFY `logi_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tulemused`
--
ALTER TABLE `tulemused`
  MODIFY `haaletuse_id` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
