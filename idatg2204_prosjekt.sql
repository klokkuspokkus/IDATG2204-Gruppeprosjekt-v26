-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: 23. Apr, 2026 08:34 AM
-- Tjener-versjon: 10.4.32-MariaDB
-- PHP Version: 8.2.12

DROP DATABASE IF EXISTS idatg2204_prosjekt; 
CREATE DATABASE idatg2204_prosjekt;
USE idatg2204_prosjekt;
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `idatg2204_prosjekt`
--

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `availability`
--

CREATE TABLE `availability` (
  `day` varchar(9) NOT NULL CHECK (`day` in ('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')),
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `tech_email` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dataark for tabell `availability`
--

INSERT INTO `availability` (`day`, `start_time`, `end_time`, `tech_email`) VALUES
('Friday', '07:00:00', '15:00:00', 'elin@ntnu.no'),
('Friday', '08:00:00', '16:00:00', 'steinar@ntnu.no'),
('Friday', '09:00:00', '17:00:00', 'rolf@ntnu.no'),
('Friday', '09:00:00', '17:00:00', 'dag.data@ntnu.no'),
('Friday', '10:00:00', '18:00:00', 'siv@ntnu.no'),
('Friday', '12:00:00', '20:00:00', 'vetle@stud.ntnu.no'),
('Monday', '07:00:00', '15:00:00', 'elin@ntnu.no'),
('Monday', '08:00:00', '16:00:00', 'steinar@ntnu.no'),
('Monday', '09:00:00', '17:00:00', 'rolf@ntnu.no'),
('Monday', '09:00:00', '17:00:00', 'dag.data@ntnu.no'),
('Monday', '10:00:00', '18:00:00', 'siv@ntnu.no'),
('Monday', '12:00:00', '20:00:00', 'vetle@stud.ntnu.no'),
('Thursday', '07:00:00', '15:00:00', 'elin@ntnu.no'),
('Thursday', '08:00:00', '16:00:00', 'steinar@ntnu.no'),
('Thursday', '09:00:00', '17:00:00', 'rolf@ntnu.no'),
('Thursday', '09:00:00', '17:00:00', 'dag.data@ntnu.no'),
('Thursday', '10:00:00', '18:00:00', 'siv@ntnu.no'),
('Thursday', '12:00:00', '20:00:00', 'vetle@stud.ntnu.no'),
('Tuesday', '07:00:00', '15:00:00', 'elin@ntnu.no'),
('Tuesday', '08:00:00', '16:00:00', 'steinar@ntnu.no'),
('Tuesday', '09:00:00', '17:00:00', 'rolf@ntnu.no'),
('Tuesday', '09:00:00', '17:00:00', 'dag.data@ntnu.no'),
('Tuesday', '10:00:00', '18:00:00', 'siv@ntnu.no'),
('Tuesday', '12:00:00', '20:00:00', 'vetle@stud.ntnu.no'),
('Wednesday', '07:00:00', '15:00:00', 'elin@ntnu.no'),
('Wednesday', '08:00:00', '16:00:00', 'steinar@ntnu.no'),
('Wednesday', '09:00:00', '17:00:00', 'rolf@ntnu.no'),
('Wednesday', '09:00:00', '17:00:00', 'dag.data@ntnu.no'),
('Wednesday', '10:00:00', '18:00:00', 'siv@ntnu.no'),
('Wednesday', '12:00:00', '20:00:00', 'vetle@stud.ntnu.no');

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `building`
--

CREATE TABLE `building` (
  `id` int(11) NOT NULL,
  `name` varchar(50) DEFAULT NULL,
  `address` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dataark for tabell `building`
--

INSERT INTO `building` (`id`, `name`, `address`) VALUES
(1, 'Atriet', 'Teknologiveien 22, Gjøvik'),
(2, 'Elektrohuset', 'Teknologiveien 22, Gjøvik'),
(3, 'Eureka', 'Teknologiveien 22, Gjøvik'),
(4, 'Helvin', 'Teknologiveien 22, Gjøvik'),
(5, 'Smaragd', 'Teknologiveien 22, Gjøvik'),
(6, 'Topas', 'Teknologiveien 22, Gjøvik'),
(7, 'Cyber City', 'Teknologiveien 22, Gjøvik'),
(8, 'Mustad', 'Hans mustad Gate 12, Gjøvik');

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `floor`
--

CREATE TABLE `floor` (
  `floor_nr` int(11) NOT NULL,
  `building_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dataark for tabell `floor`
--

INSERT INTO `floor` (`floor_nr`, `building_id`) VALUES
(0, 1),
(0, 2),
(0, 3),
(0, 4),
(0, 5),
(0, 6),
(0, 7),
(0, 8),
(1, 1),
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(1, 6),
(1, 7),
(1, 8),
(2, 1),
(2, 2),
(2, 3),
(2, 4),
(2, 5),
(2, 6),
(2, 7),
(3, 1),
(3, 2),
(3, 3),
(3, 5),
(4, 1),
(4, 2);

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `incident`
--

CREATE TABLE `incident` (
  `id` int(11) NOT NULL,
  `user_email` varchar(100) DEFAULT NULL,
  `reported_at` datetime NOT NULL,
  `severity_level` varchar(20) DEFAULT NULL CHECK (`severity_level` in ('Low','Medium','High','Critical')),
  `description` varchar(255) DEFAULT NULL,
  `category` varchar(20) NOT NULL,
  `status` varchar(20) NOT NULL CHECK (`status` in ('reported','verified','assigned','resolved','closed'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dataark for tabell `incident`
--

INSERT INTO `incident` (`id`, `user_email`, `reported_at`, `severity_level`, `description`, `category`, `status`) VALUES
(1, 'nicolai@stud.ntnu.no', '2026-04-01 09:30:00', 'High', 'Projector in lecture hall only plays cat videos', 'IT', 'closed'),
(2, 'martine@stud.ntnu.no', '2026-04-02 14:15:00', 'High', 'Coffee machine spews brown sludge – caffeine crisis', 'General', 'resolved'),
(3, 'ola.oops@stud.ntnu.no', '2026-04-03 11:00:00', 'Medium', 'Toilet on 3rd floor makes airplane landing noise', 'Plumbing', 'assigned'),
(4, 'kari.krasj@stud.ntnu.no', '2026-04-04 08:20:00', 'Low', 'Door handle greasy – feels like someone ate chips', 'General', 'closed'),
(5, 'plott@math.ntnu.no', '2026-04-05 16:45:00', 'High', 'Elevator stuck between floors – plays \"Never Gonna Give You Up\"', 'Electrical', 'resolved'),
(6, 'lars@stud.ntnu.no', '2026-04-06 10:10:00', 'High', 'Exam system offline – 300 students panicking', 'IT', 'closed'),
(7, 'finn.forsker@ntnu.no', '2026-04-07 13:30:00', 'Medium', 'AC blowing hot air – room smells of despair', 'HVAC', 'verified'),
(8, 'mona.mote@ntnu.no', '2026-04-08 12:00:00', 'Low', 'Loose floor tile sings when stepped on', 'Carpentry', 'reported'),
(9, 'henrik@stud.ntnu.no', '2026-04-09 09:00:00', 'High', 'Fire alarm triggered by burnt popcorn (again)', 'Electrical', 'assigned'),
(10, 'berit.bø@ntnu.no', '2026-04-10 11:20:00', 'Medium', 'Sink clogged with instant noodles and regret', 'Plumbing', 'closed'),
(11, 'lars.lift@ntnu.no', '2026-04-11 07:30:00', 'High', 'Wi-Fi named \"NTNU-gjest\" but requires password nobody knows', 'IT', 'assigned'),
(12, 'vera.vvs@ntnu.no', '2026-04-12 15:10:00', 'Medium', 'Heater rattles like skeleton doing laundry', 'HVAC', 'resolved'),
(13, 'dag.data@ntnu.no', '2026-04-13 10:45:00', 'Low', 'Sticky lock on group room – requires blood sacrifice', 'General', 'reported'),
(14, 'siv@ntnu.no', '2026-04-14 13:00:00', 'High', 'Ceiling leak creating indoor waterfall – students kayaking', 'Plumbing', 'verified'),
(15, 'siri.sokk@ntnu.no', '2026-04-15 08:40:00', 'High', 'Power outage in lab – backup generator just laughs', 'Electrical', 'assigned'),
(16, 'pedro@ntnu.no', '2026-04-16 16:30:00', 'Medium', 'Office chair spontaneously reclines into nap mode', 'Carpentry', 'closed'),
(17, 'tiril@stud.ntnu.no', '2026-04-17 09:15:00', 'High', 'Ventilation fan sounds like angry badger', 'HVAC', 'resolved'),
(18, 'erik@stud.ntnu.no', '2026-04-18 14:00:00', 'Low', 'Light bulb flickers in rhythm to \"Baby Shark\"', 'Electrical', 'closed'),
(19, 'guro@stud.ntnu.no', '2026-04-19 12:30:00', 'Medium', 'Toilet runs continuously – training for marathon', 'Plumbing', 'resolved'),
(20, 'simen@stud.ntnu.no', '2026-04-20 10:00:00', 'High', 'Server overheating – smells like burnt toast and failed exams', 'IT', 'closed'),
(21, 'anja@stud.ntnu.no', '2026-04-21 08:00:00', 'Low', 'Paper towel dispenser dispenses motivational quotes only', 'General', 'reported'),
(22, 'vetle@stud.ntnu.no', '2026-04-22 09:30:00', 'Medium', 'AC set to \"Sahara noon\" – waffles drying out', 'HVAC', 'assigned'),
(23, 'ida@stud.ntnu.no', '2026-04-23 14:15:00', 'High', 'Carpet wet from leak – now growing something sentient', 'Plumbing', 'verified'),
(24, 'nicolai@stud.ntnu.no', '2026-04-24 22:45:00', 'High', 'Lights flicker to form shadow puppets after dark', 'Electrical', 'reported'),
(25, 'martine@stud.ntnu.no', '2026-04-25 07:10:00', 'High', 'Printer prints only \"PC LOAD LETTER\" – no one knows what it means', 'IT', 'assigned'),
(26, 'ola.oops@stud.ntnu.no', '2026-04-26 13:00:00', 'High', 'Garbage disposal ate a fork and is now demanding dessert', 'Plumbing', 'verified'),
(27, 'kari.krasj@stud.ntnu.no', '2026-04-27 11:30:00', 'Medium', 'Vents whistle \"Pop Goes the Weasel\" at 3 AM', 'HVAC', 'assigned'),
(28, 'plott@math.ntnu.no', '2026-04-28 06:00:00', 'High', 'Control panel jammed with donut – now only plays elevator music', 'Electrical', 'assigned'),
(29, 'lars@stud.ntnu.no', '2026-04-29 16:20:00', 'Medium', 'Lightning struck building – now all clocks run backward', 'IT', 'resolved'),
(30, 'mona.mote@ntnu.no', '2026-04-30 12:00:00', 'Low', 'Anvil-shaped hole in roof – definitely not a cartoon', 'Carpentry', 'reported');

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `incident_history`
--

CREATE TABLE `incident_history` (
  `time_from` datetime NOT NULL,
  `time_to` datetime NOT NULL CHECK (`time_to` > `time_from`),
  `incident_id` int(11) NOT NULL,
  `status_type` varchar(20) NOT NULL CHECK (`status_type` in ('reported','verified','assigned','resolved','closed'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dataark for tabell `incident_history`
--

INSERT INTO `incident_history` (`time_from`, `time_to`, `incident_id`, `status_type`) VALUES
('2026-04-01 09:30:00', '2026-04-01 11:00:00', 1, 'reported'),
('2026-04-01 11:00:00', '2026-04-01 14:30:00', 1, 'verified'),
('2026-04-01 14:30:00', '2026-04-02 08:00:00', 1, 'assigned'),
('2026-04-02 08:00:00', '2026-04-02 17:00:00', 1, 'resolved'),
('2026-04-02 14:15:00', '2026-04-02 16:00:00', 2, 'reported'),
('2026-04-02 16:00:00', '2026-04-03 09:00:00', 2, 'verified'),
('2026-04-03 09:00:00', '2026-04-03 15:30:00', 2, 'assigned'),
('2026-04-03 11:00:00', '2026-04-03 13:00:00', 3, 'reported'),
('2026-04-03 13:00:00', '2026-04-03 16:30:00', 3, 'verified'),
('2026-04-04 08:20:00', '2026-04-04 10:00:00', 4, 'reported'),
('2026-04-04 10:00:00', '2026-04-04 13:00:00', 4, 'verified'),
('2026-04-04 13:00:00', '2026-04-05 09:00:00', 4, 'assigned'),
('2026-04-05 09:00:00', '2026-04-05 14:00:00', 4, 'resolved'),
('2026-04-05 16:45:00', '2026-04-05 18:30:00', 5, 'reported'),
('2026-04-05 18:30:00', '2026-04-06 08:00:00', 5, 'verified'),
('2026-04-06 08:00:00', '2026-04-06 12:00:00', 5, 'assigned'),
('2026-04-06 10:10:00', '2026-04-06 12:00:00', 6, 'reported'),
('2026-04-06 12:00:00', '2026-04-06 15:00:00', 6, 'verified'),
('2026-04-06 15:00:00', '2026-04-07 08:00:00', 6, 'assigned'),
('2026-04-07 08:00:00', '2026-04-07 18:00:00', 6, 'resolved'),
('2026-04-07 13:30:00', '2026-04-07 15:00:00', 7, 'reported'),
('2026-04-09 09:00:00', '2026-04-09 11:00:00', 9, 'reported'),
('2026-04-09 11:00:00', '2026-04-09 14:30:00', 9, 'verified'),
('2026-04-10 11:20:00', '2026-04-10 13:00:00', 10, 'reported'),
('2026-04-10 13:00:00', '2026-04-10 16:00:00', 10, 'verified'),
('2026-04-10 16:00:00', '2026-04-11 09:00:00', 10, 'assigned'),
('2026-04-11 09:00:00', '2026-04-11 16:00:00', 10, 'resolved'),
('2026-04-11 07:30:00', '2026-04-11 09:30:00', 11, 'reported'),
('2026-04-11 09:30:00', '2026-04-11 12:00:00', 11, 'verified'),
('2026-04-12 15:10:00', '2026-04-12 17:00:00', 12, 'reported'),
('2026-04-12 17:00:00', '2026-04-13 08:00:00', 12, 'verified'),
('2026-04-13 08:00:00', '2026-04-13 14:00:00', 12, 'assigned'),
('2026-04-14 13:00:00', '2026-04-14 15:30:00', 14, 'reported'),
('2026-04-15 08:40:00', '2026-04-15 10:30:00', 15, 'reported'),
('2026-04-15 10:30:00', '2026-04-15 14:00:00', 15, 'verified'),
('2026-04-16 16:30:00', '2026-04-16 18:00:00', 16, 'reported'),
('2026-04-16 18:00:00', '2026-04-17 09:00:00', 16, 'verified'),
('2026-04-17 09:00:00', '2026-04-17 14:00:00', 16, 'assigned'),
('2026-04-17 14:00:00', '2026-04-18 10:00:00', 16, 'resolved'),
('2026-04-17 09:15:00', '2026-04-17 11:00:00', 17, 'reported'),
('2026-04-17 11:00:00', '2026-04-17 15:00:00', 17, 'verified'),
('2026-04-17 15:00:00', '2026-04-18 08:00:00', 17, 'assigned'),
('2026-04-18 14:00:00', '2026-04-18 16:00:00', 18, 'reported'),
('2026-04-18 16:00:00', '2026-04-19 08:00:00', 18, 'verified'),
('2026-04-19 08:00:00', '2026-04-19 12:00:00', 18, 'assigned'),
('2026-04-19 12:00:00', '2026-04-19 17:00:00', 18, 'resolved'),
('2026-04-19 12:30:00', '2026-04-19 14:30:00', 19, 'reported'),
('2026-04-19 14:30:00', '2026-04-19 17:00:00', 19, 'verified'),
('2026-04-19 17:00:00', '2026-04-20 09:00:00', 19, 'assigned'),
('2026-04-20 10:00:00', '2026-04-20 12:00:00', 20, 'reported'),
('2026-04-20 12:00:00', '2026-04-20 15:00:00', 20, 'verified'),
('2026-04-20 15:00:00', '2026-04-21 08:00:00', 20, 'assigned'),
('2026-04-21 08:00:00', '2026-04-21 16:00:00', 20, 'resolved'),
('2026-04-22 09:30:00', '2026-04-22 11:00:00', 22, 'reported'),
('2026-04-22 11:00:00', '2026-04-22 14:30:00', 22, 'verified'),
('2026-04-23 14:15:00', '2026-04-23 16:00:00', 23, 'reported'),
('2026-04-25 07:10:00', '2026-04-25 09:00:00', 25, 'reported'),
('2026-04-25 09:00:00', '2026-04-25 12:00:00', 25, 'verified'),
('2026-04-26 13:00:00', '2026-04-26 15:00:00', 26, 'reported'),
('2026-04-27 11:30:00', '2026-04-27 13:30:00', 27, 'reported'),
('2026-04-27 13:30:00', '2026-04-27 16:00:00', 27, 'verified'),
('2026-04-28 06:00:00', '2026-04-28 08:00:00', 28, 'reported'),
('2026-04-28 08:00:00', '2026-04-28 11:00:00', 28, 'verified'),
('2026-04-29 16:20:00', '2026-04-29 18:00:00', 29, 'reported'),
('2026-04-29 18:00:00', '2026-04-30 08:00:00', 29, 'verified'),
('2026-04-30 08:00:00', '2026-04-30 14:00:00', 29, 'assigned');

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `incident_location`
--

CREATE TABLE `incident_location` (
  `incident_id` int(11) NOT NULL,
  `building_id` int(11) NOT NULL,
  `floor_nr` int(11) DEFAULT NULL,
  `room_nr` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dataark for tabell `incident_location`
--

INSERT INTO `incident_location` (`incident_id`, `building_id`, `floor_nr`, `room_nr`) VALUES
(1, 1, 0, 100),
(2, 2, 1, 200),
(3, 1, 2, 300),
(4, 3, 0, 100),
(5, 4, 1, 200),
(6, 5, 0, 100),
(7, 6, 1, 200),
(8, 7, 0, 100),
(9, 8, 0, 100),
(10, 1, 1, 200),
(11, 2, 2, 300),
(12, 3, 1, 200),
(13, 4, 0, 100),
(14, 5, 1, 200),
(15, 6, 0, 100),
(16, 7, 1, 200),
(17, 8, 0, 101),
(18, 1, 3, 400),
(19, 2, 0, 100),
(20, 3, 2, 300),
(21, 4, 1, 100),
(22, 5, 2, 300),
(23, 6, 2, 200),
(24, 7, 1, 100),
(25, 8, 1, 101),
(26, 1, 2, 301),
(27, 2, 3, 400),
(28, 3, 1, 101),
(29, 4, 0, 101),
(30, 5, 2, 201);

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `maintenance_task`
--

CREATE TABLE `maintenance_task` (
  `id` int(11) NOT NULL,
  `incident_id` int(11) NOT NULL,
  `type` varchar(20) NOT NULL CHECK (`type` in ('Inspection','Repair','Replacement','Preventive maintenance')),
  `priority` varchar(20) DEFAULT NULL CHECK (`priority` in ('Low','Medium','High')),
  `task_status` varchar(20) NOT NULL CHECK (`task_status` in ('Not started','In Progress','Finished','Aborted')),
  `estimated_duration` time NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime DEFAULT NULL CHECK (`end_time` is null or `end_time` > `start_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dataark for tabell `maintenance_task`
--

INSERT INTO `maintenance_task` (`id`, `incident_id`, `type`, `priority`, `task_status`, `estimated_duration`, `start_time`, `end_time`) VALUES
(1, 1, 'Repair', 'High', 'Finished', '02:00:00', '2026-04-03 10:00:00', '2026-04-03 12:00:00'),
(2, 2, 'Repair', 'Medium', 'Finished', '01:30:00', '2026-04-04 10:00:00', '2026-04-04 11:30:00'),
(3, 3, 'Inspection', 'Medium', 'In Progress', '01:00:00', '2026-04-05 09:00:00', NULL),
(4, 4, 'Repair', 'Low', 'Finished', '00:30:00', '2026-04-06 14:00:00', '2026-04-06 14:30:00'),
(5, 5, 'Repair', 'High', 'Finished', '02:00:00', '2026-04-07 09:00:00', '2026-04-07 11:00:00'),
(6, 6, 'Replacement', 'High', 'Finished', '03:00:00', '2026-04-08 08:00:00', '2026-04-08 11:00:00'),
(7, 7, 'Repair', 'Medium', 'Not started', '01:00:00', '2026-04-09 13:00:00', NULL),
(8, 8, 'Inspection', 'Low', 'Not started', '00:30:00', '2026-04-10 10:00:00', NULL),
(9, 9, 'Repair', 'High', 'Not started', '01:30:00', '2026-04-11 08:00:00', NULL),
(10, 10, 'Repair', 'Medium', 'Finished', '01:00:00', '2026-04-12 11:00:00', '2026-04-12 12:00:00'),
(11, 11, 'Inspection', 'High', 'Not started', '01:30:00', '2026-04-13 09:00:00', NULL),
(12, 12, 'Repair', 'Medium', 'Finished', '01:00:00', '2026-04-14 13:00:00', '2026-04-14 14:00:00'),
(13, 13, 'Repair', 'Low', 'Not started', '00:30:00', '2026-04-15 14:00:00', NULL),
(14, 14, 'Inspection', 'High', 'In Progress', '01:00:00', '2026-04-16 09:00:00', NULL),
(15, 14, 'Repair', 'High', 'Not started', '02:00:00', '2026-04-17 09:00:00', NULL),
(16, 15, 'Repair', 'High', 'Not started', '02:30:00', '2026-04-18 08:00:00', NULL),
(17, 16, 'Repair', 'Medium', 'Finished', '00:45:00', '2026-04-19 15:00:00', '2026-04-19 15:45:00'),
(18, 17, 'Repair', 'High', 'Finished', '01:00:00', '2026-04-20 10:00:00', '2026-04-20 11:00:00'),
(19, 18, 'Replacement', 'Low', 'Finished', '00:15:00', '2026-04-21 14:00:00', '2026-04-21 14:15:00'),
(20, 19, 'Repair', 'Medium', 'Finished', '01:00:00', '2026-04-22 09:00:00', '2026-04-22 10:00:00'),
(21, 20, 'Repair', 'High', 'Finished', '02:00:00', '2026-04-23 10:00:00', '2026-04-23 12:00:00'),
(22, 20, 'Inspection', 'High', 'Finished', '00:30:00', '2026-04-24 09:00:00', '2026-04-24 09:30:00'),
(23, 21, 'Repair', 'Low', 'Not started', '00:30:00', '2026-04-25 10:00:00', NULL),
(24, 22, 'Repair', 'Medium', 'Not started', '01:30:00', '2026-04-26 09:00:00', NULL),
(25, 23, 'Inspection', 'High', 'Not started', '01:00:00', '2026-04-27 08:00:00', NULL),
(26, 23, 'Repair', 'High', 'Not started', '02:00:00', '2026-04-28 08:00:00', NULL),
(27, 24, 'Inspection', 'High', 'Not started', '01:00:00', '2026-04-25 20:00:00', NULL),
(28, 25, 'Repair', 'High', 'Not started', '01:30:00', '2026-04-26 09:00:00', NULL),
(29, 26, 'Replacement', 'High', 'Not started', '02:30:00', '2026-04-27 08:00:00', NULL),
(30, 27, 'Inspection', 'Medium', 'Not started', '00:30:00', '2026-04-28 13:00:00', NULL),
(31, 28, 'Repair', 'High', 'Not started', '02:00:00', '2026-04-29 08:00:00', NULL),
(32, 29, 'Repair', 'Medium', 'Not started', '01:00:00', '2026-04-30 09:00:00', NULL),
(33, 30, 'Replacement', 'Low', 'Not started', '03:00:00', '2026-05-01 08:00:00', NULL);

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `resource`
--

CREATE TABLE `resource` (
  `id` int(11) NOT NULL,
  `building_id` int(11) NOT NULL,
  `floor_nr` int(11) NOT NULL,
  `room_nr` int(11) NOT NULL,
  `type` varchar(30) NOT NULL CHECK (`type` in ('tool','vehicle','equipment')),
  `availability_status` varchar(30) NOT NULL CHECK (`availability_status` in ('Available','Reserved','Not Available')),
  `description` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dataark for tabell `resource`
--

INSERT INTO `resource` (`id`, `building_id`, `floor_nr`, `room_nr`, `type`, `availability_status`, `description`) VALUES
(1, 1, 0, 101, 'tool', 'Available', 'Hammer of Gløshaugen (mostly for intimidation)'),
(2, 2, 1, 200, 'tool', 'Available', 'Voltage tester that also predicts rain (poorly)'),
(3, 2, 2, 300, 'equipment', 'Available', 'Server diagnostic kit – also makes instant noodles'),
(4, 3, 0, 100, 'vehicle', 'Available', 'Forklift with existential dread'),
(5, 4, 1, 200, 'tool', 'Reserved', 'Screwdriver set – each bit is slightly wrong size'),
(6, 5, 0, 100, 'equipment', 'Available', 'Terminal that only displays exam results (cruel)'),
(7, 1, 2, 300, 'equipment', 'Not Available', 'Pipe inspection camera – sees ghosts of previous leaks'),
(8, 2, 3, 400, 'tool', 'Available', 'Multimeter that mocks your readings'),
(9, 3, 1, 200, 'vehicle', 'Available', 'Maintenance cart with squeaky wheel (by design)'),
(10, 4, 0, 100, 'equipment', 'Available', 'Oscilloscope – shows dance music waveform'),
(11, 5, 1, 200, 'tool', 'Available', 'Hammer of Justice (also works as doorstop)'),
(12, 1, 3, 400, 'equipment', 'Reserved', 'Power drill that sings opera while running'),
(13, 2, 0, 100, 'vehicle', 'Available', 'Electric scooter that only goes in reverse'),
(14, 3, 2, 300, 'tool', 'Available', 'Wizard’s wand (for debugging – sparks guaranteed)'),
(15, 4, 1, 100, 'equipment', 'Available', 'Coffee machine repair kit (includes crying towel)'),
(16, 5, 2, 300, 'tool', 'Available', 'Batarang (multitool) – mostly for opening beer bottles'),
(17, 1, 1, 200, 'equipment', 'Available', 'Leak detector that cries when it finds water'),
(18, 2, 1, 200, 'vehicle', 'Available', 'Maintenance drone – easily distracted by shiny things'),
(19, 6, 0, 100, 'tool', 'Available', 'Acme Rocket-Powered Wrench (use at own risk)'),
(20, 6, 1, 200, 'equipment', 'Available', 'Portable hole – do not drop (no refunds)'),
(21, 7, 0, 100, 'tool', 'Reserved', 'Proton pack (for stubborn dust bunnies)'),
(22, 7, 1, 200, 'equipment', 'Available', 'PKE meter – beeps at bad vibes and group projects'),
(23, 8, 0, 100, 'vehicle', 'Available', 'Shuttlecraft – needs oil and positive thinking'),
(24, 6, 2, 300, 'tool', 'Available', 'Mithril crowbar (lightweight, still heavy)'),
(25, 7, 1, 100, 'equipment', 'Not Available', 'Donut removal tool (donut not included)');

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `resource_requirement`
--

CREATE TABLE `resource_requirement` (
  `resource_id` int(11) NOT NULL,
  `task_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dataark for tabell `resource_requirement`
--

INSERT INTO `resource_requirement` (`resource_id`, `task_id`) VALUES
(1, 1),
(1, 10),
(1, 17),
(2, 2),
(2, 5),
(2, 16),
(3, 6),
(3, 21),
(5, 4),
(7, 7),
(8, 3),
(8, 12),
(11, 4),
(11, 13),
(12, 15),
(16, 8),
(17, 20),
(19, 23),
(20, 25),
(21, 24),
(21, 30),
(22, 27),
(24, 29),
(25, 31);

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `resource_usage`
--

CREATE TABLE `resource_usage` (
  `resource_id` int(11) NOT NULL,
  `task_id` int(11) NOT NULL,
  `start_usage_time` datetime DEFAULT NULL,
  `end_usage_time` datetime DEFAULT NULL CHECK (`end_usage_time` is null or `end_usage_time` > `start_usage_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dataark for tabell `resource_usage`
--

INSERT INTO `resource_usage` (`resource_id`, `task_id`, `start_usage_time`, `end_usage_time`) VALUES
(1, 1, '2026-04-03 10:00:00', '2026-04-03 12:00:00'),
(1, 10, '2026-04-12 11:00:00', '2026-04-12 12:00:00'),
(2, 2, '2026-04-04 10:00:00', '2026-04-04 11:30:00'),
(2, 5, '2026-04-07 09:00:00', '2026-04-07 11:00:00'),
(3, 6, '2026-04-08 08:00:00', '2026-04-08 11:00:00'),
(5, 4, '2026-04-06 14:00:00', '2026-04-06 14:30:00'),
(7, 7, '2026-04-09 13:00:00', NULL),
(8, 3, '2026-04-05 09:00:00', NULL),
(11, 4, '2026-04-06 14:00:00', '2026-04-06 14:30:00'),
(12, 15, '2026-04-17 09:00:00', NULL),
(19, 23, '2026-04-25 10:00:00', NULL),
(21, 24, '2026-04-26 09:00:00', NULL),
(24, 29, '2026-04-27 08:00:00', NULL);

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `role`
--

CREATE TABLE `role` (
  `id` int(11) NOT NULL,
  `name` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dataark for tabell `role`
--

INSERT INTO `role` (`id`, `name`) VALUES
(1, 'administrator'),
(2, 'manager'),
(3, 'technician'),
(4, 'staff'),
(5, 'student'),
(6, 'public_user');

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `room`
--

CREATE TABLE `room` (
  `room_nr` int(11) NOT NULL,
  `floor_nr` int(11) NOT NULL,
  `building_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dataark for tabell `room`
--

INSERT INTO `room` (`room_nr`, `floor_nr`, `building_id`) VALUES
(100, 0, 1),
(100, 0, 2),
(100, 0, 3),
(100, 0, 4),
(100, 0, 5),
(100, 0, 6),
(100, 0, 7),
(100, 0, 8),
(101, 0, 1),
(101, 0, 2),
(101, 0, 3),
(101, 0, 4),
(101, 0, 5),
(101, 0, 6),
(101, 0, 7),
(101, 0, 8),
(200, 1, 1),
(200, 1, 2),
(200, 1, 3),
(200, 1, 4),
(200, 1, 5),
(200, 1, 6),
(200, 1, 7),
(201, 1, 1),
(201, 1, 2),
(201, 1, 3),
(201, 1, 5),
(300, 2, 1),
(300, 2, 2),
(300, 2, 5),
(301, 2, 1),
(301, 2, 2),
(400, 3, 1),
(400, 3, 2),
(401, 3, 1);

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `skill`
--

CREATE TABLE `skill` (
  `id` int(11) NOT NULL,
  `name` varchar(64) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dataark for tabell `skill`
--

INSERT INTO `skill` (`id`, `name`) VALUES
(1, 'Plumbing'),
(2, 'Electrical'),
(3, 'HVAC'),
(4, 'Carpentry'),
(5, 'IT/Networking'),
(6, 'General Maintenance');

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `skill_requirement`
--

CREATE TABLE `skill_requirement` (
  `task_id` int(11) NOT NULL,
  `skill_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `skill_requirement` (`task_id`, `skill_id`) VALUES
(1, 5), (1, 6),
(2, 6),
(3, 1),
(4, 6),
(5, 2),
(6, 5),
(7, 3),
(8, 4),
(9, 2),
(10, 1),
(11, 5),
(12, 3),
(13, 6),
(14, 1),
(15, 1), (15, 6),
(16, 2),
(17, 4),
(18, 3),
(19, 2),
(20, 1),
(21, 5),
(22, 5),
(23, 6),
(24, 3),
(25, 1),
(26, 1),
(27, 2),
(28, 5),
(29, 1), (29, 6),
(30, 3),
(31, 2), (31, 6),
(32, 5), (32, 6),
(33, 4), (33, 6);

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `status_history`
--

CREATE TABLE `status_history` (
  `task_id` int(11) NOT NULL,
  `time_started` datetime NOT NULL,
  `time_ended` datetime NOT NULL CHECK (`time_ended` > `time_started`),
  `type` varchar(20) NOT NULL CHECK (`type` in ('Not started','In Progress','Finished','Aborted'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dataark for tabell `status_history`
--

INSERT INTO `status_history` (`task_id`, `time_started`, `time_ended`, `type`) VALUES
(1, '2026-04-03 10:00:00', '2026-04-03 10:01:00', 'Not started'),
(1, '2026-04-03 10:01:00', '2026-04-03 11:59:00', 'In Progress'),
(2, '2026-04-04 10:00:00', '2026-04-04 10:01:00', 'Not started'),
(2, '2026-04-04 10:01:00', '2026-04-04 11:29:00', 'In Progress'),
(3, '2026-04-05 09:00:00', '2026-04-05 09:01:00', 'Not started'),
(4, '2026-04-06 14:00:00', '2026-04-06 14:01:00', 'Not started'),
(4, '2026-04-06 14:01:00', '2026-04-06 14:29:00', 'In Progress'),
(5, '2026-04-07 09:00:00', '2026-04-07 09:01:00', 'Not started'),
(5, '2026-04-07 09:01:00', '2026-04-07 10:59:00', 'In Progress'),
(6, '2026-04-08 08:00:00', '2026-04-08 08:01:00', 'Not started'),
(6, '2026-04-08 08:01:00', '2026-04-08 10:59:00', 'In Progress'),
(10, '2026-04-12 11:00:00', '2026-04-12 11:01:00', 'Not started'),
(10, '2026-04-12 11:01:00', '2026-04-12 11:59:00', 'In Progress'),
(12, '2026-04-14 13:00:00', '2026-04-14 13:01:00', 'Not started'),
(12, '2026-04-14 13:01:00', '2026-04-14 13:59:00', 'In Progress'),
(14, '2026-04-16 09:00:00', '2026-04-16 09:01:00', 'Not started'),
(17, '2026-04-19 15:00:00', '2026-04-19 15:01:00', 'Not started'),
(17, '2026-04-19 15:01:00', '2026-04-19 15:44:00', 'In Progress'),
(18, '2026-04-20 10:00:00', '2026-04-20 10:01:00', 'Not started'),
(18, '2026-04-20 10:01:00', '2026-04-20 10:59:00', 'In Progress'),
(19, '2026-04-21 14:00:00', '2026-04-21 14:01:00', 'Not started'),
(19, '2026-04-21 14:01:00', '2026-04-21 14:14:00', 'In Progress'),
(20, '2026-04-22 09:00:00', '2026-04-22 09:01:00', 'Not started'),
(20, '2026-04-22 09:01:00', '2026-04-22 09:59:00', 'In Progress'),
(21, '2026-04-23 10:00:00', '2026-04-23 10:01:00', 'Not started'),
(21, '2026-04-23 10:01:00', '2026-04-23 11:59:00', 'In Progress'),
(22, '2026-04-24 09:00:00', '2026-04-24 09:01:00', 'Not started'),
(22, '2026-04-24 09:01:00', '2026-04-24 09:29:00', 'In Progress');

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `technician`
--

CREATE TABLE `technician` (
  `tech_email` varchar(100) NOT NULL,
  `role` varchar(50) NOT NULL,
  `employement_status` varchar(30) NOT NULL,
  PRIMARY KEY (`tech_email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dataark for tabell `technician`
--

INSERT INTO `technician` (`tech_email`, `role`, `employement_status`) VALUES
('steinar@ntnu.no', 'IT Support', 'Full-time'),
('rolf@ntnu.no', 'Plumber', 'Full-time'),
('elin@ntnu.no', 'Electrician', 'Full-time'),
('vidar@ntnu.no', 'General Maintenance', 'Part-time'),
('kjell@ntnu.no', 'Coffee Machine Therapist', 'Contractor'),
('finn.forsker@ntnu.no', 'Elevator Whisperer', 'Full-time'),
('lars.lift@ntnu.no', 'Chief of Chaos', 'Full-time'),
('vera.vvs@ntnu.no', 'Heavy Door Opener', 'Full-time'),
('dag.data@ntnu.no', 'Cable Manager', 'Full-time'),
('siv@ntnu.no', 'Lost Property Finder', 'Part-time'),
('vetle@stud.ntnu.no', 'Mold Inspector', 'Part-time');

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `technician_skill`
--

CREATE TABLE `technician_skill` (
  `tech_email` varchar(100) NOT NULL,
  `skill_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dataark for tabell `technician_skill`
--

INSERT INTO `technician_skill` (`tech_email`, `skill_id`) VALUES
('steinar@ntnu.no', 5),
('steinar@ntnu.no', 6),
('rolf@ntnu.no', 1),
('rolf@ntnu.no', 6),
('elin@ntnu.no', 2),
('elin@ntnu.no', 6),
('vidar@ntnu.no', 4),
('vidar@ntnu.no', 6),
('kjell@ntnu.no', 3),
('finn.forsker@ntnu.no', 2),
('lars.lift@ntnu.no', 1),
('lars.lift@ntnu.no', 2),
('vera.vvs@ntnu.no', 4),
('vera.vvs@ntnu.no', 6),
('dag.data@ntnu.no', 5),
('dag.data@ntnu.no', 6),
('siv@ntnu.no', 6),
('vetle@stud.ntnu.no', 3);

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `technician_work`
--

CREATE TABLE `technician_work` (
  `tech_email` varchar(100) NOT NULL,
  `task_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dataark for tabell `technician_work`
--

INSERT INTO `technician_work` (`tech_email`, `task_id`) VALUES
('steinar@ntnu.no', 1),
('steinar@ntnu.no', 12),
('steinar@ntnu.no', 19),
('steinar@ntnu.no', 22),
('rolf@ntnu.no', 2),
('rolf@ntnu.no', 7),
('rolf@ntnu.no', 18),
('rolf@ntnu.no', 21),
('elin@ntnu.no', 4),
('elin@ntnu.no', 14),
('elin@ntnu.no', 17),
('elin@ntnu.no', 20),
('vidar@ntnu.no', 5),
('vidar@ntnu.no', 6),
('vidar@ntnu.no', 19),
('kjell@ntnu.no', 9),
('kjell@ntnu.no', 10),
('kjell@ntnu.no', 15),
('kjell@ntnu.no', 16),
('finn.forsker@ntnu.no', 11),
('finn.forsker@ntnu.no', 13),
('finn.forsker@ntnu.no', 23),
('finn.forsker@ntnu.no', 24),
('lars.lift@ntnu.no', 4),
('lars.lift@ntnu.no', 14),
('lars.lift@ntnu.no', 20),
('vera.vvs@ntnu.no', 3),
('vera.vvs@ntnu.no', 8),
('vera.vvs@ntnu.no', 17),
('dag.data@ntnu.no', 30),
('siv@ntnu.no', 25),
('siv@ntnu.no', 27),
('siv@ntnu.no', 28),
('siv@ntnu.no', 31),
('vetle@stud.ntnu.no', 26),
('vetle@stud.ntnu.no', 29),
('vetle@stud.ntnu.no', 32);

-- --------------------------------------------------------

--
-- Tabellstruktur for tabell `user`
--

CREATE TABLE `user` (
  `email` varchar(100) NOT NULL,
  `role_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dataark for tabell `user`
--

INSERT INTO `user` (`email`, `role_id`, `name`) VALUES
('rektor@ntnu.no', 1, 'Rektor Strålande'),
('britt.breiflabb@ntnu.no', 2, 'Britt Breiflabb'),
('steinar@ntnu.no', 3, 'IT-Steinar'),
('rolf@ntnu.no', 3, 'Rørlegger Rolf'),
('elin@ntnu.no', 3, 'Elektriker Elin'),
('vidar@ntnu.no', 3, 'Vaktmester Vidar'),
('kjell@ntnu.no', 3, 'Kaffemaskin Kjell'),
('finn.forsker@ntnu.no', 4, 'Foreleser Finn'),
('siri.sokk@ntnu.no', 4, 'Siri Sokk'),
('nicolai@stud.ntnu.no', 5, 'Nicolai Nerd'),
('martine@stud.ntnu.no', 5, 'Martine Matt'),
('ola.oops@stud.ntnu.no', 5, 'Ola Oops'),
('kari.krasj@stud.ntnu.no', 5, 'Kari Kræsj'),
('plott@math.ntnu.no', 4, 'Professor Plott'),
('lars@stud.ntnu.no', 5, 'Lars Laptop'),
('mona.mote@ntnu.no', 2, 'Mona Møte'),
('henrik@stud.ntnu.no', 5, 'Henrik Hull'),
('berit.bø@ntnu.no', 4, 'Berit Bø'),
('lars.lift@ntnu.no', 3, 'Lift Lars'),
('vera.vvs@ntnu.no', 3, 'VVS-Vera'),
('dag.data@ntnu.no', 3, 'Data Dag'),
('siv@ntnu.no', 3, 'Støvsuger-Siv'),
('pedro@ntnu.no', 4, 'Pedro Pedal'),
('tiril@stud.ntnu.no', 5, 'Tiril Trøtt'),
('erik@stud.ntnu.no', 5, 'Erik Eksamen'),
('guro@stud.ntnu.no', 5, 'Guro Grønn'),
('simen@stud.ntnu.no', 5, 'Simen Søvn'),
('anja@stud.ntnu.no', 5, 'Anja Anelse'),
('vetle@stud.ntnu.no', 5, 'Vetle Virus'),
('ida@stud.ntnu.no', 5, 'Ida Internett');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `availability`
--
ALTER TABLE `availability`
  ADD PRIMARY KEY (`day`,`start_time`,`end_time`,`tech_email`),
  ADD KEY `tech_email` (`tech_email`);

--
-- Indexes for table `building`
--
ALTER TABLE `building`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `floor`
--
ALTER TABLE `floor`
  ADD PRIMARY KEY (`floor_nr`,`building_id`),
  ADD KEY `building_id` (`building_id`);

--
-- Indexes for table `incident`
--
ALTER TABLE `incident`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_email` (`user_email`);

--
-- Indexes for table `incident_location`
--
ALTER TABLE `incident_location`
  ADD PRIMARY KEY (`incident_id`),
  ADD KEY `building_id` (`building_id`),
  ADD KEY `floor_nr` (`floor_nr`),
  ADD KEY `room_nr` (`room_nr`);

--
-- Indexes for table `maintenance_task`
--
ALTER TABLE `maintenance_task`
  ADD PRIMARY KEY (`id`),
  ADD KEY `incident_id` (`incident_id`);

--
-- Indexes for table `resource`
--
ALTER TABLE `resource`
  ADD PRIMARY KEY (`id`),
  ADD KEY `building_id` (`building_id`),
  ADD KEY `floor_nr` (`floor_nr`),
  ADD KEY `room_nr` (`room_nr`);

--
-- Indexes for table `resource_requirement`
--
ALTER TABLE `resource_requirement`
  ADD PRIMARY KEY (`resource_id`,`task_id`),
  ADD KEY `task_id` (`task_id`);

--
-- Indexes for table `resource_usage`
--
ALTER TABLE `resource_usage`
  ADD PRIMARY KEY (`resource_id`,`task_id`),
  ADD KEY `task_id` (`task_id`);

--
-- Indexes for table `role`
--
ALTER TABLE `role`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `room`
--
ALTER TABLE `room`
  ADD PRIMARY KEY (`room_nr`,`floor_nr`,`building_id`),
  ADD KEY `floor_nr` (`floor_nr`,`building_id`);

--
-- Indexes for table `skill`
--
ALTER TABLE `skill`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `skill_requirement`
--
ALTER TABLE `skill_requirement`
  ADD PRIMARY KEY (`task_id`,`skill_id`),
  ADD KEY `skill_id` (`skill_id`);

--
-- Indexes for table `technician`
--
ALTER TABLE `technician`
  ADD PRIMARY KEY (`tech_email`);

--
-- Indexes for table `technician_skill`
--
ALTER TABLE `technician_skill`
  ADD PRIMARY KEY (`tech_email`,`skill_id`),
  ADD KEY `skill_id` (`skill_id`);

--
-- Indexes for table `technician_work`
--
ALTER TABLE `technician_work`
  ADD PRIMARY KEY (`tech_email`,`task_id`),
  ADD KEY `task_id` (`task_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `building`
--
ALTER TABLE `building`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `incident`
--
ALTER TABLE `incident`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `maintenance_task`
--
ALTER TABLE `maintenance_task`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- AUTO_INCREMENT for table `resource`
--
ALTER TABLE `resource`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `role`
--
ALTER TABLE `role`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `skill`
--
ALTER TABLE `skill`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Begrensninger for dumpede tabeller
--

--
-- Begrensninger for tabell `availability`
--
ALTER TABLE `availability`
  ADD CONSTRAINT `availability_ibfk_1` FOREIGN KEY (`tech_email`) REFERENCES `technician` (`tech_email`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Begrensninger for tabell `floor`
--
ALTER TABLE `floor`
  ADD CONSTRAINT `floor_ibfk_1` FOREIGN KEY (`building_id`) REFERENCES `building` (`id`) ON DELETE CASCADE;

--
-- Begrensninger for tabell `incident`
--
ALTER TABLE `incident`
  ADD CONSTRAINT `incident_ibfk_1` FOREIGN KEY (`user_email`) REFERENCES `user` (`email`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Begrensninger for tabell `incident_location`
--
ALTER TABLE `incident_location`
  ADD CONSTRAINT `incident_location_ibfk_1` FOREIGN KEY (`incident_id`) REFERENCES `incident` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `incident_location_ibfk_2` FOREIGN KEY (`building_id`) REFERENCES `building` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `incident_location_ibfk_3` FOREIGN KEY (`floor_nr`) REFERENCES `floor` (`floor_nr`) ON UPDATE CASCADE,
  ADD CONSTRAINT `incident_location_room_nr` FOREIGN KEY (`room_nr`) REFERENCES `room` (`room_nr`) ON UPDATE CASCADE;

--
-- Begrensninger for tabell `maintenance_task`
--
ALTER TABLE `maintenance_task`
  ADD CONSTRAINT `maintenance_task_ibfk_1` FOREIGN KEY (`incident_id`) REFERENCES `incident` (`id`) ON UPDATE CASCADE;

--
-- Begrensninger for tabell `resource`
--
ALTER TABLE `resource`
  ADD CONSTRAINT `resource_building_id` FOREIGN KEY (`building_id`) REFERENCES `building` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `resource_floor_nr` FOREIGN KEY (`floor_nr`) REFERENCES `floor` (`floor_nr`) ON UPDATE CASCADE,
  ADD CONSTRAINT `resource_room_nr` FOREIGN KEY (`room_nr`) REFERENCES `room` (`room_nr`) ON UPDATE CASCADE;

--
-- Begrensninger for tabell `resource_requirement`
--
ALTER TABLE `resource_requirement`
  ADD CONSTRAINT `resource_requirements_ibfk_1` FOREIGN KEY (`resource_id`) REFERENCES `resource` (`id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `resource_requirements_ibfk_2` FOREIGN KEY (`task_id`) REFERENCES `maintenance_task` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Begrensninger for tabell `resource_usage`
--
ALTER TABLE `resource_usage`
  ADD CONSTRAINT `resource_usage_ibfk_1` FOREIGN KEY (`resource_id`) REFERENCES `resource` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE,
  ADD CONSTRAINT `resource_usage_ibfk_2` FOREIGN KEY (`task_id`) REFERENCES `maintenance_task` (`id`) ON DELETE NO ACTION ON UPDATE CASCADE;

--
-- Begrensninger for tabell `room`
--
ALTER TABLE `room`
  ADD CONSTRAINT `room_ibfk_1` FOREIGN KEY (`floor_nr`,`building_id`) REFERENCES `floor` (`floor_nr`, `building_id`) ON DELETE CASCADE;

--
-- Begrensninger for tabell `skill_requirement`
--
ALTER TABLE `skill_requirement`
  ADD CONSTRAINT `skill_requirement_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `maintenance_task` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `skill_requirement_ibfk_2` FOREIGN KEY (`skill_id`) REFERENCES `skill` (`id`) ON UPDATE CASCADE;

--
-- Begrensninger for tabell `technician`
--
ALTER TABLE `technician`
  ADD CONSTRAINT `technician_ibfk_1` FOREIGN KEY (`tech_email`) REFERENCES `user` (`email`) ON UPDATE CASCADE;

-- View incident stats without personal data
DROP VIEW IF EXISTS `public_view_stats`;
CREATE VIEW `public_view_stats` AS
SELECT 
    COUNT(*) AS total_incidents,
    SUM(CASE WHEN status NOT IN ('resolved', 'closed') THEN 1 ELSE 0 END) AS open_incidents,
    SUM(CASE WHEN status IN ('resolved', 'closed') THEN 1 ELSE 0 END) AS closed_incidents,
    SUM(CASE WHEN severity_level = 'Critical' THEN 1 ELSE 0 END) AS critical_count,
    SUM(CASE WHEN severity_level = 'High' THEN 1 ELSE 0 END) AS high_count,
    SUM(CASE WHEN category = 'IT' THEN 1 ELSE 0 END) AS it_count,
    SUM(CASE WHEN category = 'Plumbing' THEN 1 ELSE 0 END) AS plumbing_count,
    SUM(CASE WHEN category = 'Electrical' THEN 1 ELSE 0 END) AS electrical_count,
    SUM(CASE WHEN category = 'HVAC' THEN 1 ELSE 0 END) AS hvac_count,
    SUM(CASE WHEN category = 'General' THEN 1 ELSE 0 END) AS general_count
FROM `incident`;

-- View for students and staff (only their own incidents)
DROP VIEW IF EXISTS `user_incidents_view`;
CREATE VIEW `user_incidents_view` AS
SELECT i.id, i.user_email, i.reported_at, i.severity_level, i.description, i.category, i.status,
       b.name AS building_name, b.id AS building_id, il.floor_nr, il.room_nr,
       u.name AS reporter_name, u.email AS reporter_email
FROM incident i
LEFT JOIN incident_location il ON i.id = il.incident_id
LEFT JOIN building b ON il.building_id = b.id
LEFT JOIN user u ON i.user_email = u.email;

-- Technician tasks (only their assigned tasks)
DROP VIEW IF EXISTS `technician_tasks_view`;
CREATE VIEW `technician_tasks_view` AS
SELECT mt.id, mt.incident_id, mt.type, mt.priority, mt.task_status, mt.estimated_duration,
       mt.start_time, mt.end_time, tw.tech_email,
       i.category AS incident_category, i.severity_level, i.status AS incident_status,
       b.name AS building_name, il.floor_nr, il.room_nr,
       u.name AS technician_name
FROM maintenance_task mt
INNER JOIN technician_work tw ON mt.id = tw.task_id
INNER JOIN incident i ON mt.incident_id = i.id
LEFT JOIN incident_location il ON i.id = il.incident_id
LEFT JOIN building b ON il.building_id = b.id
LEFT JOIN user u ON tw.tech_email = u.email;

-- Manager view (all tasks with full info)
DROP VIEW IF EXISTS `manager_tasks_view`;
CREATE VIEW `manager_tasks_view` AS
SELECT mt.id, mt.incident_id, mt.type, mt.priority, mt.task_status, mt.estimated_duration,
       mt.start_time, mt.end_time, inc.category AS incident_category, inc.severity_level,
       b.name AS building_name, il.floor_nr, il.room_nr,
       GROUP_CONCAT(DISTINCT u.name SEPARATOR ', ') AS assigned_technicians,
       GROUP_CONCAT(DISTINCT u.email SEPARATOR ', ') AS tech_emails
FROM maintenance_task mt
JOIN incident inc ON mt.incident_id = inc.id
LEFT JOIN incident_location il ON inc.id = il.incident_id
LEFT JOIN building b ON il.building_id = b.id
LEFT JOIN technician_work tw ON mt.id = tw.task_id
LEFT JOIN user u ON tw.tech_email = u.email
GROUP BY mt.id;

-- Roles and permissions 
CREATE ROLE IF NOT EXISTS `pub_role`;
CREATE ROLE IF NOT EXISTS `ss_role`;
CREATE ROLE IF NOT EXISTS `tech_role`;
CREATE ROLE IF NOT EXISTS `mgr_role`;
CREATE ROLE IF NOT EXISTS `admn_role`;

-- Public privileges 
GRANT SELECT ON `public_view_stats` TO `pub_role`;
GRANT INSERT ON `incident` TO `pub_role`;
GRANT INSERT ON `incident_location` TO `pub_role`;

-- Student/staff privileges
GRANT SELECT ON `user_incidents_view` TO `ss_role`;

-- Technician privileges 
GRANT SELECT ON `technician_tasks_view` TO `tech_role`;
GRANT UPDATE ON `maintenance_task` TO `tech_role`;

-- Manager privileges
GRANT SELECT, INSERT, UPDATE, DELETE ON `maintenance_task` TO `mgr_role`;
GRANT SELECT, INSERT, UPDATE, DELETE ON `incident` TO `mgr_role`;
GRANT SELECT, INSERT, UPDATE, DELETE ON `incident_location` TO `mgr_role`;
GRANT SELECT, INSERT, UPDATE, DELETE ON `resource` TO `mgr_role`;
GRANT SELECT, INSERT, UPDATE, DELETE ON `resource_requirement` TO `mgr_role`;
GRANT SELECT, INSERT, UPDATE, DELETE ON `technician_work` TO `mgr_role`;
GRANT SELECT, INSERT, UPDATE, DELETE ON `availability` TO `mgr_role`;
GRANT SELECT ON `manager_tasks_view` TO `mgr_role`; 

-- Admin privileges
GRANT ALL PRIVILEGES ON `idatg2204project`.* TO `admn_role`;


COMMIT;




/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;