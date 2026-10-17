CREATE TABLE `codex_runs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `run_uid` char(32) NOT NULL,
  `username` varchar(64) NOT NULL DEFAULT '',
  `model` varchar(64) NOT NULL DEFAULT '',
  `effort` varchar(16) NOT NULL DEFAULT '',
  `instruction` mediumtext,
  `tool_calls` int NOT NULL DEFAULT '0',
  `elapsed_ms` bigint NOT NULL DEFAULT '0',
  `ok` tinyint NOT NULL DEFAULT '1',
  `error` text,
  `input_tokens` bigint NOT NULL DEFAULT '0',
  `output_tokens` bigint NOT NULL DEFAULT '0',
  `cache_read_tokens` bigint NOT NULL DEFAULT '0',
  `cache_write_tokens` bigint NOT NULL DEFAULT '0',
  `context_tokens` bigint NOT NULL DEFAULT '0',
  `cost_usd` decimal(12,6) NOT NULL DEFAULT '0.000000',
  `ts` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_run_uid` (`run_uid`),
  KEY `idx_ts` (`ts`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `codex_statement_audits` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `run_uid` char(32) NOT NULL,
  `problem_id` int NOT NULL,
  `username` varchar(64) NOT NULL DEFAULT '',
  `before_title` text,
  `before_description` mediumtext,
  `after_title` text,
  `after_description` mediumtext,
  `tags` varchar(1024) NOT NULL DEFAULT '',
  `time_ms` int NOT NULL DEFAULT '0',
  `mem_mb` int NOT NULL DEFAULT '0',
  `message` text,
  `ts` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_problem` (`problem_id`,`ts`),
  KEY `idx_run` (`run_uid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `contest_boards` (
  `contest_id` int NOT NULL,
  `board` mediumtext,
  `saved_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`contest_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `contest_registrations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `contest_id` int NOT NULL,
  `is_virtual` tinyint NOT NULL DEFAULT '0',
  `registered_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_user_contest` (`user_id`,`contest_id`),
  CONSTRAINT `contest_registrations_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE `contests` (
  `id` int NOT NULL,
  `content` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE `generators` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `code` mediumtext NOT NULL,
  `description` text,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `exe` longblob,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_generator_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `problem_generators` (
  `problem_id` int NOT NULL,
  `generator_id` int NOT NULL,
  `gen_count` int NOT NULL DEFAULT '0',
  `seed_base` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`problem_id`,`generator_id`),
  KEY `generator_id` (`generator_id`),
  CONSTRAINT `problem_generators_ibfk_1` FOREIGN KEY (`problem_id`) REFERENCES `problems` (`id`),
  CONSTRAINT `problem_generators_ibfk_2` FOREIGN KEY (`generator_id`) REFERENCES `generators` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
CREATE TABLE `problem_testcases` (
  `id` int NOT NULL AUTO_INCREMENT,
  `problem_id` int NOT NULL,
  `name` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `input` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `output` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_sample` tinyint NOT NULL DEFAULT '0',
  `sort` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_problem_testcase` (`problem_id`,`name`),
  CONSTRAINT `problem_testcases_ibfk_1` FOREIGN KEY (`problem_id`) REFERENCES `problems` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE `problems` (
  `id` int NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `description` mediumtext COLLATE utf8mb4_unicode_ci,
  `sample_in` mediumtext COLLATE utf8mb4_unicode_ci,
  `sample_out` mediumtext COLLATE utf8mb4_unicode_ci,
  `time_ms` int NOT NULL DEFAULT '1000',
  `mem_mb` int NOT NULL DEFAULT '256',
  `tags` text COLLATE utf8mb4_unicode_ci,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `std_code` mediumtext COLLATE utf8mb4_unicode_ci,
  `is_public` tinyint NOT NULL DEFAULT '1',
  `std_exe` longblob,
  `spj_code` mediumtext COLLATE utf8mb4_unicode_ci,
  `spj_exe` longblob,
  `entry_code` mediumtext COLLATE utf8mb4_unicode_ci,
  `entry_exe` longblob,
  `itf_template` mediumtext COLLATE utf8mb4_unicode_ci,
  `judge_mode` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE `sessions` (
  `token` char(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` int NOT NULL,
  `expires_at` datetime NOT NULL,
  PRIMARY KEY (`token`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE `submissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `problem_id` int NOT NULL,
  `contest_id` int NOT NULL DEFAULT '0',
  `verdict` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL,
  `detail` text COLLATE utf8mb4_unicode_ci,
  `time_ms` int DEFAULT NULL,
  `virtual` tinyint NOT NULL DEFAULT '0',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `wrong_count` int NOT NULL DEFAULT '0',
  `code` mediumtext COLLATE utf8mb4_unicode_ci,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_user_problem` (`user_id`,`problem_id`,`contest_id`),
  KEY `idx_contest_problem` (`contest_id`,`problem_id`),
  CONSTRAINT `submissions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` char(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `salt` char(32) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('admin','author','user') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'user',
  `nickname` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `avatar` mediumtext COLLATE utf8mb4_unicode_ci,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `email` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `name` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `school` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
