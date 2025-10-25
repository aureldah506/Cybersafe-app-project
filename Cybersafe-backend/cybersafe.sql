-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : ven. 24 oct. 2025 à 09:14
-- Version du serveur : 9.1.0
-- Version de PHP : 8.3.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `cybersafe`
--

-- --------------------------------------------------------

--
-- Structure de la table `chat_logs`
--

DROP TABLE IF EXISTS `chat_logs`;
CREATE TABLE IF NOT EXISTS `chat_logs` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` int UNSIGNED DEFAULT NULL,
  `role` enum('user','bot') COLLATE utf8mb4_unicode_ci NOT NULL,
  `message` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_chat_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Structure de la table `scores`
--

DROP TABLE IF EXISTS `scores`;
CREATE TABLE IF NOT EXISTS `scores` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` int UNSIGNED NOT NULL,
  `module` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `level` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `score` int NOT NULL DEFAULT '0',
  `total` int NOT NULL DEFAULT '0',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_scores_user_module` (`user_id`,`module`),
  KEY `idx_scores_created` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `scores`
--

INSERT INTO `scores` (`id`, `user_id`, `module`, `level`, `score`, `total`, `created_at`, `updated_at`) VALUES
(1, 4, 'phishing', 'Débutant', 4, 4, '2025-10-24 08:47:52', '2025-10-24 08:47:52'),
(2, 6, 'instagram', 'guide', 1, 3, '2025-10-24 08:53:10', '2025-10-24 08:53:10'),
(3, 6, 'instagram', 'guide', 2, 3, '2025-10-24 08:53:10', '2025-10-24 08:53:10'),
(4, 6, 'instagram', 'guide', 3, 3, '2025-10-24 08:53:11', '2025-10-24 08:53:11'),
(5, 6, 'phishing', 'Avancé', 4, 4, '2025-10-24 08:54:29', '2025-10-24 08:54:29');

-- --------------------------------------------------------

--
-- Structure de la table `tips`
--

DROP TABLE IF EXISTS `tips`;
CREATE TABLE IF NOT EXISTS `tips` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `text` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `tips`
--

INSERT INTO `tips` (`id`, `text`, `active`, `created_at`) VALUES
(1, 'Vérifie le cadenas HTTPS avant d’acheter.', 1, '2025-10-14 11:38:01'),
(2, 'Active la double authentification (2FA).', 1, '2025-10-14 11:38:01'),
(3, 'Un mot de passe unique par site.', 1, '2025-10-14 11:38:01'),
(4, 'Méfie-toi des liens raccourcis inconnus.', 1, '2025-10-14 11:38:01');

-- --------------------------------------------------------

--
-- Structure de la table `users`
--

DROP TABLE IF EXISTS `users`;
CREATE TABLE IF NOT EXISTS `users` (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(190) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_users_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password_hash`, `created_at`) VALUES
(1, 'Qurel', NULL, NULL, '2025-10-24 08:13:04'),
(2, 'Aqurel', NULL, NULL, '2025-10-24 08:13:24'),
(3, 'Aurel', NULL, NULL, '2025-10-24 08:13:29'),
(4, 'Jean', NULL, NULL, '2025-10-24 08:29:01'),
(5, '?athieu', NULL, NULL, '2025-10-24 08:51:51'),
(6, 'Franc', NULL, NULL, '2025-10-24 08:52:48');

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `v_latest_scores`
-- (Voir ci-dessous la vue réelle)
--
DROP VIEW IF EXISTS `v_latest_scores`;
CREATE TABLE IF NOT EXISTS `v_latest_scores` (
`id` int unsigned
,`user_id` int unsigned
,`module` varchar(50)
,`level` varchar(50)
,`score` int
,`total` int
,`created_at` timestamp
,`updated_at` timestamp
);

-- --------------------------------------------------------

--
-- Doublure de structure pour la vue `v_user_percent`
-- (Voir ci-dessous la vue réelle)
--
DROP VIEW IF EXISTS `v_user_percent`;
CREATE TABLE IF NOT EXISTS `v_user_percent` (
`user_id` int unsigned
,`percent` decimal(36,0)
);

-- --------------------------------------------------------

--
-- Structure de la vue `v_latest_scores`
--
DROP TABLE IF EXISTS `v_latest_scores`;

DROP VIEW IF EXISTS `v_latest_scores`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_latest_scores`  AS SELECT `s`.`id` AS `id`, `s`.`user_id` AS `user_id`, `s`.`module` AS `module`, `s`.`level` AS `level`, `s`.`score` AS `score`, `s`.`total` AS `total`, `s`.`created_at` AS `created_at`, `s`.`updated_at` AS `updated_at` FROM (`scores` `s` join (select `scores`.`user_id` AS `user_id`,`scores`.`module` AS `module`,max(`scores`.`id`) AS `max_id` from `scores` group by `scores`.`user_id`,`scores`.`module`) `last` on((`last`.`max_id` = `s`.`id`))) ;

-- --------------------------------------------------------

--
-- Structure de la vue `v_user_percent`
--
DROP TABLE IF EXISTS `v_user_percent`;

DROP VIEW IF EXISTS `v_user_percent`;
CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_user_percent`  AS SELECT `v_latest_scores`.`user_id` AS `user_id`, ifnull(round(((sum(`v_latest_scores`.`score`) / nullif(sum(`v_latest_scores`.`total`),0)) * 100),0),0) AS `percent` FROM `v_latest_scores` GROUP BY `v_latest_scores`.`user_id` ;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `chat_logs`
--
ALTER TABLE `chat_logs`
  ADD CONSTRAINT `fk_chat_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Contraintes pour la table `scores`
--
ALTER TABLE `scores`
  ADD CONSTRAINT `fk_scores_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
