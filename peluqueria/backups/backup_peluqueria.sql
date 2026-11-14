-- MySQL dump 10.13  Distrib 8.4.3, for Win64 (x86_64)
--
-- Host: localhost    Database: peluqueria
-- ------------------------------------------------------
-- Server version	8.4.3

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `appointment_service`
--

DROP TABLE IF EXISTS `appointment_service`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointment_service` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `appointment_id` bigint unsigned NOT NULL,
  `service_id` bigint unsigned NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `appointment_service_appointment_id_service_id_unique` (`appointment_id`,`service_id`),
  KEY `appointment_service_service_id_foreign` (`service_id`),
  CONSTRAINT `appointment_service_appointment_id_foreign` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`),
  CONSTRAINT `appointment_service_service_id_foreign` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointment_service`
--

LOCK TABLES `appointment_service` WRITE;
/*!40000 ALTER TABLE `appointment_service` DISABLE KEYS */;
INSERT INTO `appointment_service` VALUES (1,1,1,25000.00,'2026-11-14 05:33:50','2026-11-14 05:33:50');
/*!40000 ALTER TABLE `appointment_service` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `appointments`
--

DROP TABLE IF EXISTS `appointments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `appointments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `client_id` bigint unsigned NOT NULL,
  `stylist_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `date` date NOT NULL,
  `time` time NOT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pendiente',
  `notes` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `appointments_client_id_foreign` (`client_id`),
  KEY `appointments_stylist_id_foreign` (`stylist_id`),
  KEY `appointments_user_id_foreign` (`user_id`),
  CONSTRAINT `appointments_client_id_foreign` FOREIGN KEY (`client_id`) REFERENCES `clients` (`id`),
  CONSTRAINT `appointments_stylist_id_foreign` FOREIGN KEY (`stylist_id`) REFERENCES `stylists` (`id`),
  CONSTRAINT `appointments_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `appointments`
--

LOCK TABLES `appointments` WRITE;
/*!40000 ALTER TABLE `appointments` DISABLE KEYS */;
INSERT INTO `appointments` VALUES (1,1,2,1,'2026-11-18','18:00:00','cancelado',NULL,'2026-11-14 05:33:50','2026-11-14 05:34:15');
/*!40000 ALTER TABLE `appointments` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_appointments_after_insert` AFTER INSERT ON `appointments` FOR EACH ROW BEGIN
                INSERT INTO audits (table_name, record_id, action, old_status, new_status)
                VALUES ('appointments', NEW.id, 'crear', NULL, NEW.status);
            END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_appointments_after_update` AFTER UPDATE ON `appointments` FOR EACH ROW BEGIN
                DECLARE v_accion VARCHAR(20);

                IF NEW.status = 'cancelado' AND OLD.status <> 'cancelado' THEN
                    SET v_accion = 'cancelar';
                ELSEIF NEW.status = 'atendido' AND OLD.status <> 'atendido' THEN
                    SET v_accion = 'atender';
                ELSE
                    SET v_accion = 'modificar';
                END IF;

                INSERT INTO audits (table_name, record_id, action, old_status, new_status)
                VALUES ('appointments', NEW.id, v_accion, OLD.status, NEW.status);
            END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `audits`
--

DROP TABLE IF EXISTS `audits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audits` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `table_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `record_id` bigint unsigned NOT NULL,
  `action` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `old_status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `new_status` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `audits_record_id_foreign` (`record_id`),
  CONSTRAINT `audits_record_id_foreign` FOREIGN KEY (`record_id`) REFERENCES `appointments` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audits`
--

LOCK TABLES `audits` WRITE;
/*!40000 ALTER TABLE `audits` DISABLE KEYS */;
INSERT INTO `audits` VALUES (1,'appointments',1,'crear',NULL,'pendiente','2026-11-14 05:33:50'),(2,'appointments',1,'cancelar','pendiente','cancelado','2026-11-14 05:34:15');
/*!40000 ALTER TABLE `audits` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categories` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `categories_name_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (1,'Cabello','2026-11-14 05:26:14','2026-11-14 05:26:14'),(2,'Barba','2026-11-14 05:26:14','2026-11-14 05:26:14'),(3,'Uñas','2026-11-14 05:26:14','2026-11-14 05:26:14');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clients`
--

DROP TABLE IF EXISTS `clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clients` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clients`
--

LOCK TABLES `clients` WRITE;
/*!40000 ALTER TABLE `clients` DISABLE KEYS */;
INSERT INTO `clients` VALUES (1,'Ana Martínez','3151112233','ana@correo.com','2026-11-14 05:26:14','2026-11-14 05:26:14'),(2,'Juan Pérez','3204445566',NULL,'2026-11-14 05:26:14','2026-11-14 05:26:14'),(3,'Sofía Herrera','3186667788','sofia@correo.com','2026-11-14 05:26:14','2026-11-14 05:26:14'),(4,'Andrés Londoño','3002223344',NULL,'2026-11-14 05:26:14','2026-11-14 05:26:14'),(5,'Camila Ospina','3119990011','camila@correo.com','2026-11-14 05:26:14','2026-11-14 05:26:14'),(6,'Ana Gutiérrez','3145556677',NULL,'2026-11-14 05:26:14','2026-11-14 05:26:14');
/*!40000 ALTER TABLE `clients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'2014_10_12_000000_create_users_table',1),(2,'2014_10_12_100000_create_password_resets_table',1),(3,'2019_08_19_000000_create_failed_jobs_table',1),(4,'2019_12_14_000001_create_personal_access_tokens_table',1),(5,'2026_11_01_232352_create_roles_table',1),(6,'2026_11_01_233132_add_role_id_to_users_table',1),(7,'2026_11_01_233200_create_clients_table',1),(8,'2026_11_01_233226_create_stylists_table',1),(9,'2026_11_01_233303_create_categories_table',1),(10,'2026_11_01_233324_create_payment_methods_table',1),(11,'2026_11_01_233347_create_schedules_table',1),(12,'2026_11_01_233407_create_services_table',1),(13,'2026_11_01_233440_create_service_stylist_table',1),(14,'2026_11_01_233505_create_appointments_table',1),(15,'2026_11_01_233533_create_appointment_service_table',1),(16,'2026_11_01_233550_create_payments_table',1),(17,'2026_11_01_233609_create_audits_table',1),(18,'2026_11_02_181200_create_appointment_audit_triggers',1),(19,'2026_11_06_225644_create_stylist_income_procedure',1);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_resets`
--

DROP TABLE IF EXISTS `password_resets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_resets` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_resets`
--

LOCK TABLES `password_resets` WRITE;
/*!40000 ALTER TABLE `password_resets` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_resets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_methods`
--

DROP TABLE IF EXISTS `payment_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_methods` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `payment_methods_name_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_methods`
--

LOCK TABLES `payment_methods` WRITE;
/*!40000 ALTER TABLE `payment_methods` DISABLE KEYS */;
INSERT INTO `payment_methods` VALUES (1,'Efectivo','2026-11-14 05:26:14','2026-11-14 05:26:14'),(2,'Tarjeta','2026-11-14 05:26:14','2026-11-14 05:26:14'),(3,'Nequi','2026-11-14 05:26:14','2026-11-14 05:26:14');
/*!40000 ALTER TABLE `payment_methods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `appointment_id` bigint unsigned NOT NULL,
  `payment_method_id` bigint unsigned NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `paid_at` datetime NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `payments_appointment_id_foreign` (`appointment_id`),
  KEY `payments_payment_method_id_foreign` (`payment_method_id`),
  CONSTRAINT `payments_appointment_id_foreign` FOREIGN KEY (`appointment_id`) REFERENCES `appointments` (`id`),
  CONSTRAINT `payments_payment_method_id_foreign` FOREIGN KEY (`payment_method_id`) REFERENCES `payment_methods` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint unsigned NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
INSERT INTO `personal_access_tokens` VALUES (1,'App\\Models\\User',1,'sesion','b763f3ee50d31dee026208dbf2a8a2f291c61d9e837758b405ab50c6b23be857','[\"*\"]','2026-11-14 05:34:17',NULL,'2026-11-14 05:32:08','2026-11-14 05:34:17');
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `roles_name_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'administrador','2026-11-14 05:26:14','2026-11-14 05:26:14'),(2,'recepcionista','2026-11-14 05:26:14','2026-11-14 05:26:14'),(3,'estilista','2026-11-14 05:26:14','2026-11-14 05:26:14');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schedules`
--

DROP TABLE IF EXISTS `schedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `schedules` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `stylist_id` bigint unsigned NOT NULL,
  `day_of_week` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `schedules_stylist_id_foreign` (`stylist_id`),
  CONSTRAINT `schedules_stylist_id_foreign` FOREIGN KEY (`stylist_id`) REFERENCES `stylists` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schedules`
--

LOCK TABLES `schedules` WRITE;
/*!40000 ALTER TABLE `schedules` DISABLE KEYS */;
INSERT INTO `schedules` VALUES (1,1,'lunes','08:00:00','17:00:00','2026-11-14 05:26:14','2026-11-14 05:26:14'),(2,2,'lunes','10:00:00','19:00:00','2026-11-14 05:26:14','2026-11-14 05:26:14'),(3,1,'martes','08:00:00','17:00:00','2026-11-14 05:26:14','2026-11-14 05:26:14'),(4,2,'martes','10:00:00','19:00:00','2026-11-14 05:26:14','2026-11-14 05:26:14'),(5,1,'miércoles','08:00:00','17:00:00','2026-11-14 05:26:14','2026-11-14 05:26:14'),(6,2,'miércoles','10:00:00','19:00:00','2026-11-14 05:26:14','2026-11-14 05:26:14'),(7,1,'jueves','08:00:00','17:00:00','2026-11-14 05:26:14','2026-11-14 05:26:14'),(8,2,'jueves','10:00:00','19:00:00','2026-11-14 05:26:14','2026-11-14 05:26:14'),(9,1,'viernes','08:00:00','17:00:00','2026-11-14 05:26:14','2026-11-14 05:26:14'),(10,2,'viernes','10:00:00','19:00:00','2026-11-14 05:26:14','2026-11-14 05:26:14'),(11,3,'martes','09:00:00','18:00:00','2026-11-14 05:26:14','2026-11-14 05:26:14'),(12,3,'jueves','09:00:00','18:00:00','2026-11-14 05:26:14','2026-11-14 05:26:14'),(13,3,'sábado','09:00:00','18:00:00','2026-11-14 05:26:14','2026-11-14 05:26:14'),(14,4,'lunes','08:00:00','14:00:00','2026-11-14 05:26:14','2026-11-14 05:26:14'),(15,4,'miércoles','08:00:00','14:00:00','2026-11-14 05:26:14','2026-11-14 05:26:14'),(16,4,'viernes','08:00:00','14:00:00','2026-11-14 05:26:14','2026-11-14 05:26:14'),(17,4,'sábado','08:00:00','14:00:00','2026-11-14 05:26:14','2026-11-14 05:26:14');
/*!40000 ALTER TABLE `schedules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_stylist`
--

DROP TABLE IF EXISTS `service_stylist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `service_stylist` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `service_id` bigint unsigned NOT NULL,
  `stylist_id` bigint unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `service_stylist_service_id_stylist_id_unique` (`service_id`,`stylist_id`),
  KEY `service_stylist_stylist_id_foreign` (`stylist_id`),
  CONSTRAINT `service_stylist_service_id_foreign` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`),
  CONSTRAINT `service_stylist_stylist_id_foreign` FOREIGN KEY (`stylist_id`) REFERENCES `stylists` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_stylist`
--

LOCK TABLES `service_stylist` WRITE;
/*!40000 ALTER TABLE `service_stylist` DISABLE KEYS */;
INSERT INTO `service_stylist` VALUES (1,1,1,'2026-11-14 05:26:14','2026-11-14 05:26:14'),(2,5,1,'2026-11-14 05:26:14','2026-11-14 05:26:14'),(3,6,1,'2026-11-14 05:26:14','2026-11-14 05:26:14'),(4,1,2,'2026-11-14 05:26:14','2026-11-14 05:26:14'),(5,2,2,'2026-11-14 05:26:14','2026-11-14 05:26:14'),(6,3,2,'2026-11-14 05:26:14','2026-11-14 05:26:14'),(7,4,2,'2026-11-14 05:26:14','2026-11-14 05:26:14'),(8,1,3,'2026-11-14 05:26:14','2026-11-14 05:26:14'),(9,5,3,'2026-11-14 05:26:14','2026-11-14 05:26:14'),(10,6,3,'2026-11-14 05:26:14','2026-11-14 05:26:14'),(11,7,4,'2026-11-14 05:26:14','2026-11-14 05:26:14'),(12,8,4,'2026-11-14 05:26:14','2026-11-14 05:26:14'),(13,9,4,'2026-11-14 05:26:14','2026-11-14 05:26:14'),(14,3,4,'2026-11-14 05:26:14','2026-11-14 05:26:14');
/*!40000 ALTER TABLE `service_stylist` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `services`
--

DROP TABLE IF EXISTS `services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `services` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `category_id` bigint unsigned NOT NULL,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `duration_minutes` int NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `services_category_id_foreign` (`category_id`),
  CONSTRAINT `services_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `services`
--

LOCK TABLES `services` WRITE;
/*!40000 ALTER TABLE `services` DISABLE KEYS */;
INSERT INTO `services` VALUES (1,1,'Corte de cabello',25000.00,30,'2026-11-14 05:26:14','2026-11-14 05:26:14'),(2,1,'Tinte',80000.00,90,'2026-11-14 05:26:14','2026-11-14 05:26:14'),(3,1,'Cepillado',30000.00,40,'2026-11-14 05:26:14','2026-11-14 05:26:14'),(4,1,'Keratina',150000.00,120,'2026-11-14 05:26:14','2026-11-14 05:26:14'),(5,2,'Arreglo de barba',15000.00,20,'2026-11-14 05:26:14','2026-11-14 05:26:14'),(6,2,'Afeitado clásico',20000.00,30,'2026-11-14 05:26:14','2026-11-14 05:26:14'),(7,3,'Manicure',20000.00,45,'2026-11-14 05:26:14','2026-11-14 05:26:14'),(8,3,'Pedicure',25000.00,50,'2026-11-14 05:26:14','2026-11-14 05:26:14'),(9,3,'Uñas acrílicas',70000.00,90,'2026-11-14 05:26:14','2026-11-14 05:26:14');
/*!40000 ALTER TABLE `services` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stylists`
--

DROP TABLE IF EXISTS `stylists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `stylists` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stylists`
--

LOCK TABLES `stylists` WRITE;
/*!40000 ALTER TABLE `stylists` DISABLE KEYS */;
INSERT INTO `stylists` VALUES (1,'Carlos Gómez','3001234567',1,'2026-11-14 05:26:14','2026-11-14 05:26:14'),(2,'Laura Restrepo','3109876543',1,'2026-11-14 05:26:14','2026-11-14 05:26:14'),(3,'Mateo Zapata','3125558899',1,'2026-11-14 05:26:14','2026-11-14 05:26:14'),(4,'Valentina Ríos','3017773344',1,'2026-11-14 05:26:14','2026-11-14 05:26:14');
/*!40000 ALTER TABLE `stylists` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role_id` bigint unsigned NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  KEY `users_role_id_foreign` (`role_id`),
  CONSTRAINT `users_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Administrador','admin@peluqueria.test',NULL,'$2y$10$ncL9/Q.6bhDbG8Cg8dL.ae501x0nLBtdOnYWvR9axr3CNHF1.y4xa',1,NULL,'2026-11-14 05:26:14','2026-11-14 05:26:14');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'peluqueria'
--
/*!50003 DROP PROCEDURE IF EXISTS `sp_ingresos_por_estilista` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ingresos_por_estilista`(IN p_desde DATE, IN p_hasta DATE)
BEGIN
                DECLARE v_fin INT DEFAULT 0;
                DECLARE v_id BIGINT;
                DECLARE v_nombre VARCHAR(100);
                DECLARE v_total DECIMAL(10,2);

                
                DECLARE cur_estilistas CURSOR FOR
                    SELECT id, name FROM stylists WHERE active = 1;

                
                DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_fin = 1;

               
                DROP TEMPORARY TABLE IF EXISTS tmp_ingresos;
                CREATE TEMPORARY TABLE tmp_ingresos (estilista VARCHAR(100), total DECIMAL(10,2));

                OPEN cur_estilistas;

                recorrer: LOOP
                    FETCH cur_estilistas INTO v_id, v_nombre;

                    IF v_fin = 1 THEN
                        LEAVE recorrer;
                    END IF;

                    
                    SELECT COALESCE(SUM(p.amount), 0) INTO v_total
                    FROM payments p
                    JOIN appointments a ON a.id = p.appointment_id
                    WHERE a.stylist_id = v_id
                      AND a.date BETWEEN p_desde AND p_hasta;

                    INSERT INTO tmp_ingresos VALUES (v_nombre, v_total);
                END LOOP;

                CLOSE cur_estilistas;

                SELECT * FROM tmp_ingresos ORDER BY total DESC;
            END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-14 15:00:44
