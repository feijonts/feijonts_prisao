CREATE TABLE `feijonts_prisao` (
	`user_id` INT(11) NOT NULL,
	`tempo` INT(11) NULL DEFAULT NULL,
	PRIMARY KEY (`user_id`) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
;