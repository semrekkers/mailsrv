CREATE TABLE `virtual_domains` (
    `id` int NOT NULL AUTO_INCREMENT,
    `name` varchar(50) NOT NULL,

    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `virtual_users` (
    `id` int NOT NULL AUTO_INCREMENT,
    `domain_id` int NOT NULL,
    `password` varchar(106) NOT NULL,
    `email` varchar(120) NOT NULL,

    PRIMARY KEY (`id`),
    UNIQUE KEY (`email`),
    KEY (`domain_id`),
    FOREIGN KEY (`domain_id`) REFERENCES `virtual_domains`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `virtual_aliases` (
    `id` int NOT NULL AUTO_INCREMENT,
    `domain_id` int NOT NULL,
    `source` varchar(100) NOT NULL,
    `destination` varchar(100) NOT NULL,

    PRIMARY KEY (`id`),
    KEY (`domain_id`),
    FOREIGN KEY (`domain_id`) REFERENCES `virtual_domains`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;