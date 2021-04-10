-- --------------------------------------------------------
-- Host:                         localhost
-- Versión del servidor:         10.5.4-MariaDB-log - mariadb.org binary distribution
-- SO del servidor:              Win64
-- HeidiSQL Versión:             11.0.0.5919
-- --------------------------------------------------------

CREATE TABLE IF NOT EXISTS `nexus_ck` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(50) NOT NULL,
  `code` int(6) NOT NULL,
  `reason` varchar(50) NOT NULL DEFAULT '',
  `charId` int(3) NOT NULL,
  `by` varchar(50) NOT NULL,
  `used` int(11) NOT NULL DEFAULT 0,
  `date` timestamp NULL DEFAULT current_timestamp(),
  `updated` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


-- Volcando estructura para tabla apzombies.nexus_punishments
CREATE TABLE IF NOT EXISTS `nexus_punishments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(50) NOT NULL DEFAULT '0',
  `punisher` varchar(255) NOT NULL,
  `target` varchar(255) NOT NULL,
  `reason` varchar(255) NOT NULL DEFAULT 'Sanción no determinada, su apelación es válida.',
  `expires` datetime DEFAULT NULL,
  `appeal` int(11) NOT NULL DEFAULT 0,
  `unbanned` int(11) NOT NULL DEFAULT 0,
  KEY `id` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=latin1;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla apzombies.users_identifiers
CREATE TABLE IF NOT EXISTS `users_identifiers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(255) NOT NULL DEFAULT '0',
  `license` varchar(255) DEFAULT NULL,
  `steam` varchar(255) NOT NULL,
  `name` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `fivem` varchar(255) DEFAULT NULL,
  `xbl` varchar(255) DEFAULT NULL,
  `live` varchar(255) DEFAULT NULL,
  `discord` varchar(255) DEFAULT NULL,
  `kuid` varchar(255) DEFAULT NULL,
  `ip` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `identifier` (`identifier`)
) ENGINE=InnoDB AUTO_INCREMENT=307 DEFAULT CHARSET=latin1;

