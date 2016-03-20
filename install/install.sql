SET NAMES {{DB_CHARSET}};
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
--  Table structure for `{{DB_PREFIX}}articles`
-- ----------------------------
DROP TABLE IF EXISTS `{{DB_PREFIX}}articles`;
CREATE TABLE `{{DB_PREFIX}}articles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(200) COLLATE {{DB_COLLATE}} NOT NULL,
  `content` text COLLATE {{DB_CHARSET}},
  `category` int(11) DEFAULT '0',
  `author` varchar(250) COLLATE {{DB_COLLATE}} NOT NULL,
  `date` int(11) NOT NULL,
  `views` int(11) NOT NULL DEFAULT '0',
  `public` int(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET={{DB_CHARSET}} COLLATE={{DB_COLLATE}};

-- ----------------------------
--  Table structure for `{{DB_PREFIX}}attachments`
-- ----------------------------
DROP TABLE IF EXISTS `{{DB_PREFIX}}attachments`;
CREATE TABLE `{{DB_PREFIX}}attachments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) COLLATE {{DB_COLLATE}} NOT NULL,
  `enc` varchar(200) COLLATE {{DB_COLLATE}} NOT NULL,
  `filetype` varchar(200) COLLATE {{DB_COLLATE}} DEFAULT NULL,
  `article_id` int(11) NOT NULL DEFAULT '0',
  `ticket_id` int(11) NOT NULL DEFAULT '0',
  `msg_id` int(11) NOT NULL DEFAULT '0',
  `filesize` varchar(100) COLLATE {{DB_COLLATE}} DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `article_id` (`article_id`),
  KEY `ticket_id` (`ticket_id`),
  KEY `msg_id` (`msg_id`)
) ENGINE=InnoDB DEFAULT CHARSET={{DB_CHARSET}} COLLATE={{DB_COLLATE}};

-- ----------------------------
--  Table structure for `{{DB_PREFIX}}canned_response`
-- ----------------------------
DROP TABLE IF EXISTS `{{DB_PREFIX}}canned_response`;
CREATE TABLE `{{DB_PREFIX}}canned_response` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE {{DB_COLLATE}} DEFAULT NULL,
  `message` text COLLATE {{DB_CHARSET}},
  `position` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET={{DB_CHARSET}} COLLATE={{DB_COLLATE}};

-- ----------------------------
--  Table structure for `{{DB_PREFIX}}custom_fields`
-- ----------------------------
DROP TABLE IF EXISTS `{{DB_PREFIX}}custom_fields`;
CREATE TABLE `{{DB_PREFIX}}custom_fields` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(100) COLLATE {{DB_COLLATE}} NOT NULL,
  `title` varchar(250) COLLATE {{DB_COLLATE}} NOT NULL,
  `value` text COLLATE {{DB_CHARSET}},
  `required` int(1) NOT NULL DEFAULT '0',
  `display` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET={{DB_CHARSET}} COLLATE={{DB_COLLATE}};

-- ----------------------------
--  Table structure for `{{DB_PREFIX}}departments`
-- ----------------------------
DROP TABLE IF EXISTS `{{DB_PREFIX}}departments`;
CREATE TABLE `{{DB_PREFIX}}departments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `dep_order` int(11) NOT NULL DEFAULT '0',
  `name` varchar(255) COLLATE {{DB_COLLATE}} NOT NULL,
  `type` int(2) NOT NULL DEFAULT '0',
  `autoassign` int(1) NOT NULL DEFAULT '0',
  `autoassign_web` int(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET={{DB_CHARSET}} COLLATE={{DB_COLLATE}};

INSERT INTO `{{DB_PREFIX}}departments` (`id`, `dep_order`, `name`, `type`, `autoassign`, `autoassign_web`) VALUES(1, 1, 'General', 0, 1, 1);

-- ----------------------------
--  Table structure for `{{DB_PREFIX}}emails`
-- ----------------------------
DROP TABLE IF EXISTS `{{DB_PREFIX}}emails`;
CREATE TABLE `{{DB_PREFIX}}emails` (
  `id` varchar(255) COLLATE {{DB_COLLATE}} NOT NULL,
  `orderlist` smallint(2) NOT NULL,
  `name` varchar(255) COLLATE {{DB_COLLATE}} NOT NULL,
  `subject` varchar(255) COLLATE {{DB_COLLATE}} NOT NULL,
  `message` text COLLATE {{DB_COLLATE}} NOT NULL,
  `enabled` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET={{DB_CHARSET}} COLLATE={{DB_COLLATE}};

BEGIN;
INSERT INTO `{{DB_PREFIX}}emails` (`id`, `orderlist`, `name`, `subject`, `message`) VALUES
('new_user', 1, 'Welcome email registration', 'Welcome to %company_name% helpdesk', 'This email is confirmation that you are now registered at our helpdesk.\n\nRegistered email: %client_email%\nPassword: %client_password%\n\nYou can visit the helpdesk to browse articles and contact us at any time: %helpdesk_url%\n\nThank you for registering!\n\n%company_name%\nHelpdesk: %helpdesk_url%'),
('lost_password', 2, 'Lost password confirmation', 'Lost password request for %company_name% helpdesk', 'We have received a request to reset your account password for the %company_name% helpdesk (%helpdesk_url%).\n\nYour new passsword is: %client_password%\n\nThank you,\n\n\n%company_name%\nHelpdesk: %helpdesk_url%'),
('new_ticket', 3, 'New ticket creation', '[#%ticket_id%] %ticket_subject%', 'Dear %client_name%,\n\nThank you for contacting us. This is an automated response confirming the receipt of your ticket. One of our agents will get back to you as soon as possible. For your records, the details of the ticket are listed below. When replying, please make sure that the ticket ID is kept in the subject line to ensure that your replies are tracked appropriately.\n\n		Ticket ID: %ticket_id%\n		Subject: %ticket_subject%\n		Department: %ticket_department%\n		Status: %ticket_status%\n                Priority: %ticket_priority%\n\n\nYou can check the status of or reply to this ticket online at: %helpdesk_url%\n\nRegards,\n%company_name%'),
('autoresponse', 4, 'New Message Autoresponse', '[#%ticket_id%] %ticket_subject%', 'Dear %client_name%,\n\nYour reply to support request #%ticket_id% has been noted.\n\n\nTicket Details\n---------------\n\nTicket ID: %ticket_id%\nDepartment: %ticket_department%\nStatus: %ticket_status%\nPriority: %ticket_priority%\n\n\nHelpdesk: %helpdesk_url%'),
('staff_reply', 5, 'Staff Reply', '[#%ticket_id%] %ticket_subject%', '%message%\n\n\nTicket Details\n---------------\n\nTicket ID: %ticket_id%\nDepartment: %ticket_department%\nStatus: %ticket_status%\nPriority: %ticket_priority%\n\n\nHelpdesk: %helpdesk_url%'),
('staff_ticketnotification', 6, 'New ticket notification to staff', 'New ticket notification', 'Dear %staff_name%,\r\n\r\nA new ticket has been created in department assigned for you, please login to staff panel to answer it.\r\n\r\n\r\nTicket Details\r\n---------------\r\n\r\nTicket ID: %ticket_id%\r\nDepartment: %ticket_department%\r\nStatus: %ticket_status%\r\nPriority: %ticket_priority%\r\n\r\n\r\nHelpdesk: %helpdesk_url%'),
('staff_ticketupdate_notification', 7, 'Ticket update notification to staff', '[#%ticket_id%] %ticket_subject% (Update)', 'Dear %staff_name%,\r\n\r\nA ticket has been updated in department assigned for you, please login to staff panel to answer it.\r\n\r\n\r\nTicket Details\r\n---------------\r\n\r\nTicket ID: %ticket_id%\r\nDepartment: %ticket_department%\r\nStatus: %ticket_status%\r\nPriority: %ticket_priority%\r\n\r\n\r\nHelpdesk: %helpdesk_url%\r\n\r\n%message%');
COMMIT;
-- ----------------------------
--  Table structure for `{{DB_PREFIX}}error_log`
-- ----------------------------
DROP TABLE IF EXISTS `{{DB_PREFIX}}error_log`;
CREATE TABLE `{{DB_PREFIX}}error_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `error` text COLLATE {{DB_CHARSET}},
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET={{DB_CHARSET}} COLLATE={{DB_COLLATE}};

-- ----------------------------
--  Table structure for `{{DB_PREFIX}}file_types`
-- ----------------------------
DROP TABLE IF EXISTS `{{DB_PREFIX}}file_types`;
CREATE TABLE `{{DB_PREFIX}}file_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(10) COLLATE {{DB_COLLATE}} DEFAULT NULL,
  `size` varchar(100) COLLATE {{DB_COLLATE}} NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET={{DB_CHARSET}} COLLATE={{DB_COLLATE}};

INSERT INTO `{{DB_PREFIX}}file_types` (`id`, `type`, `size`) VALUES
(1, 'gif', '0'),
(2, 'png', '0'),
(3, 'jpeg', '0'),
(4, 'jpg', '0'),
(5, 'ico', '0'),
(6, 'doc', '0'),
(7, 'docx', '0'),
(8, 'xls', '0'),
(9, 'xlsx', '0'),
(10, 'ppt', '0'),
(11, 'pptx', '0'),
(12, 'txt', '0'),
(13, 'htm', '0'),
(14, 'html', '0'),
(15, 'php', '0'),
(16, 'zip', '0'),
(17, 'rar', '0'),
(18, 'pdf', '0');

-- ----------------------------
--  Table structure for `{{DB_PREFIX}}knowledgebase_category`
-- ----------------------------
DROP TABLE IF EXISTS `{{DB_PREFIX}}knowledgebase_category`;
CREATE TABLE `{{DB_PREFIX}}knowledgebase_category` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) COLLATE {{DB_COLLATE}} NOT NULL,
  `position` int(11) NOT NULL,
  `parent` int(11) NOT NULL DEFAULT '0',
  `public` int(2) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET={{DB_CHARSET}} COLLATE={{DB_COLLATE}};

-- ----------------------------
--  Table structure for `{{DB_PREFIX}}login_attempt`
-- ----------------------------
DROP TABLE IF EXISTS `{{DB_PREFIX}}login_attempt`;
CREATE TABLE `{{DB_PREFIX}}login_attempt` (
  `ip` varchar(200) COLLATE {{DB_COLLATE}} NOT NULL,
  `attempts` int(2) NOT NULL DEFAULT '0',
  `date` int(11) NOT NULL DEFAULT '0',
  UNIQUE KEY `ip` (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET={{DB_CHARSET}} COLLATE={{DB_COLLATE}};

-- ----------------------------
--  Table structure for `{{DB_PREFIX}}login_log`
-- ----------------------------
DROP TABLE IF EXISTS `{{DB_PREFIX}}login_log`;
CREATE TABLE `{{DB_PREFIX}}login_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `date` int(11) NOT NULL,
  `staff_id` int(11) NOT NULL DEFAULT '0',
  `username` varchar(100) COLLATE {{DB_COLLATE}} NOT NULL,
  `fullname` varchar(255) COLLATE {{DB_COLLATE}} NOT NULL,
  `ip` varchar(255) COLLATE {{DB_COLLATE}} NOT NULL,
  `agent` varchar(255) COLLATE {{DB_COLLATE}} NOT NULL,
  PRIMARY KEY (`id`),
  KEY `date` (`date`),
  KEY `staff_id` (`staff_id`)
) ENGINE=InnoDB DEFAULT CHARSET={{DB_CHARSET}} COLLATE={{DB_COLLATE}};

-- ----------------------------
--  Table structure for `{{DB_PREFIX}}news`
-- ----------------------------
DROP TABLE IF EXISTS `{{DB_PREFIX}}news`;
CREATE TABLE `{{DB_PREFIX}}news` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(200) COLLATE {{DB_COLLATE}} NOT NULL,
  `content` text COLLATE {{DB_CHARSET}},
  `author` varchar(250) COLLATE {{DB_COLLATE}} NOT NULL,
  `date` int(11) NOT NULL,
  `public` int(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET={{DB_CHARSET}} COLLATE={{DB_COLLATE}};

-- ----------------------------
--  Table structure for `{{DB_PREFIX}}pages`
-- ----------------------------
DROP TABLE IF EXISTS `{{DB_PREFIX}}pages`;
CREATE TABLE `{{DB_PREFIX}}pages` (
  `id` varchar(255) COLLATE {{DB_COLLATE}} NOT NULL,
  `title` varchar(255) COLLATE {{DB_COLLATE}} DEFAULT NULL,
  `content` text COLLATE {{DB_CHARSET}},
  UNIQUE KEY `home` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET={{DB_CHARSET}} COLLATE={{DB_COLLATE}};

INSERT INTO `{{DB_PREFIX}}pages` (`id`, `title`, `content`) VALUES
('home', 'Welcome to the support & center', '<div class=\"introductory_display_texts\">\r\n<table style=\"height: 38px;\" width=\"100%\" cellspacing=\"4\">\r\n<tbody>\r\n<tr>\r\n<td style=\"vertical-align: top;\">\r\n<p><strong>New to HelpDeskZ?</strong></p>\r\n<ul>\r\n<li>If you are a customer, then you can login to our support center using the same login details that you use in your client panel.</li>\r\n<li>If you are <strong>not</strong> a customer, then you can submit a ticket, after this process you will receive a password to login to our support center.</li>\r\n</ul>\r\n</td>\r\n<td style=\"width: 50%; vertical-align: top;\">\r\n<p><strong>Do you need help?</strong></p>\r\n<ul>\r\n<li>Visit our knowledgebase at <a title=\"knowledgebase\" href=\"knowledgebase\">yoursite.com/knowledgebase</a></li>\r\n<li>Submit a&nbsp;<a href=\"submit_ticket\">support ticket</a> in English or Spanish.</li>\r\n</ul>\r\n</td>\r\n</tr>\r\n</tbody>\r\n</table>\r\n</div>');


-- ----------------------------
--  Table structure for `{{DB_PREFIX}}priority`
-- ----------------------------
DROP TABLE IF EXISTS `{{DB_PREFIX}}priority`;
CREATE TABLE `{{DB_PREFIX}}priority` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE {{DB_COLLATE}} NOT NULL,
  `color` varchar(10) COLLATE {{DB_COLLATE}} NOT NULL DEFAULT '#000000',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET={{DB_CHARSET}} COLLATE={{DB_COLLATE}};

INSERT INTO `{{DB_PREFIX}}priority` (`id`, `name`, `color`) VALUES
(1, 'Low', '#8A8A8A'),
(2, 'Medium', '#000000'),
(3, 'High', '#F07D18'),
(4, 'Urgent', '#E826C6'),
(5, 'Emergency', '#E06161'),
(6, 'Critical', '#FF0000');

-- ----------------------------
--  Table structure for `{{DB_PREFIX}}staff`
-- ----------------------------
DROP TABLE IF EXISTS `{{DB_PREFIX}}staff`;
CREATE TABLE `{{DB_PREFIX}}staff` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(255) COLLATE {{DB_COLLATE}} NOT NULL,
  `password` varchar(255) COLLATE {{DB_COLLATE}} NOT NULL,
  `fullname` varchar(100) COLLATE {{DB_COLLATE}} NOT NULL,
  `email` varchar(255) COLLATE {{DB_COLLATE}} DEFAULT NULL,
  `login` int(11) NOT NULL DEFAULT '0',
  `last_login` int(11) NOT NULL DEFAULT '0',
  `department` text COLLATE {{DB_CHARSET}},
  `timezone` varchar(255) COLLATE {{DB_COLLATE}} DEFAULT NULL,
  `signature` mediumtext COLLATE {{DB_CHARSET}},
  `newticket_notification` smallint(1) NOT NULL DEFAULT '0',
  `avatar` varchar(200) COLLATE {{DB_COLLATE}} DEFAULT NULL,
  `admin` int(1) NOT NULL DEFAULT '0',
  `status` enum('Enable','Disable') COLLATE {{DB_COLLATE}} NOT NULL DEFAULT 'Enable',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET={{DB_CHARSET}} COLLATE={{DB_COLLATE}};

INSERT INTO `{{DB_PREFIX}}staff` (`id`, `username`, `password`, `fullname`, `email`, `login`, `last_login`, `department`, `timezone`, `signature`, `avatar`, `admin`, `status`) VALUES
(1, '{{ADMIN_USER}}', '{{ADMIN_PASS}}', 'Administrator', 'support@mysite.com', 0, 0, 'a:1:{i:0;s:1:\"1\";}', '', 'Best regards,\r\nAdministrator', NULL, 1, 'Enable');

-- ----------------------------
--  Table structure for `{{DB_PREFIX}}ticket_status`
-- ----------------------------
DROP TABLE IF EXISTS `{{DB_PREFIX}}ticket_status`;
CREATE TABLE `{{DB_PREFIX}}ticket_status` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `langstring` varchar(100) COLLATE {{DB_COLLATE}} NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET={{DB_CHARSET}} COLLATE={{DB_COLLATE}};

INSERT INTO `{{DB_PREFIX}}ticket_status` VALUES ('1', 'OPEN'), ('2', 'ANSWERED'), ('3', 'AWAITING_REPLY'), ('4', 'IN_PROGRESS'), ('5', 'CLOSED');

-- ----------------------------
--  Table structure for `{{DB_PREFIX}}tickets`
-- ----------------------------
DROP TABLE IF EXISTS `{{DB_PREFIX}}tickets`;
CREATE TABLE `{{DB_PREFIX}}tickets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `code` varchar(255) CHARACTER SET {{DB_CHARSET}} NOT NULL,
  `department_id` int(11) NOT NULL DEFAULT '0',
  `priority_id` int(11) NOT NULL DEFAULT '0',
  `user_id` int(11) NOT NULL DEFAULT '0',
  `fullname` varchar(255) CHARACTER SET {{DB_CHARSET}} NOT NULL,
  `email` varchar(255) CHARACTER SET {{DB_CHARSET}} NOT NULL,
  `subject` varchar(255) CHARACTER SET {{DB_CHARSET}} NOT NULL,
  `api_fields` text CHARACTER SET {{DB_CHARSET}},
  `date` int(11) NOT NULL DEFAULT '0',
  `last_update` int(11) NOT NULL DEFAULT '0',
  `status` smallint(2) NOT NULL DEFAULT '1',
  `previewcode` varchar(12) CHARACTER SET {{DB_CHARSET}} DEFAULT NULL,
  `replies` int(11) NOT NULL DEFAULT '0',
  `last_replier` varchar(255) CHARACTER SET {{DB_CHARSET}} DEFAULT NULL,
  `custom_vars` text CHARACTER SET {{DB_CHARSET}},
  `trash` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET={{DB_CHARSET}} COLLATE={{DB_COLLATE}};

-- ----------------------------
--  Table structure for `{{DB_PREFIX}}tickets_messages`
-- ----------------------------
DROP TABLE IF EXISTS `{{DB_PREFIX}}tickets_messages`;
CREATE TABLE `{{DB_PREFIX}}tickets_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ticket_id` int(11) NOT NULL DEFAULT '0',
  `date` int(11) NOT NULL DEFAULT '0',
  `customer` int(2) NOT NULL DEFAULT '1',
  `name` varchar(255) CHARACTER SET {{DB_CHARSET}} DEFAULT NULL,
  `message` text CHARACTER SET {{DB_CHARSET}},
  `ip` varchar(255) CHARACTER SET {{DB_CHARSET}} DEFAULT NULL,
  `email` varchar(200) CHARACTER SET {{DB_CHARSET}} DEFAULT NULL,
  `email_to` varchar(200) COLLATE {{DB_COLLATE}} DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ticket_id` (`ticket_id`)
) ENGINE=InnoDB DEFAULT CHARSET={{DB_CHARSET}} COLLATE={{DB_COLLATE}};

-- ----------------------------
--  Table structure for `{{DB_PREFIX}}tickets_notes`
-- ----------------------------
DROP TABLE IF EXISTS `{{DB_PREFIX}}tickets_notes`;
CREATE TABLE `{{DB_PREFIX}}tickets_notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ticket_id` int(11) NOT NULL DEFAULT '0',
  `message` text CHARACTER SET {{DB_CHARSET}},
  `staff_id` int(11) DEFAULT NULL,
  `date` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `ticket_id` (`ticket_id`)
) ENGINE=InnoDB DEFAULT CHARSET={{DB_CHARSET}} COLLATE={{DB_COLLATE}};

-- ----------------------------
--  Table structure for `{{DB_PREFIX}}users`
-- ----------------------------
DROP TABLE IF EXISTS `{{DB_PREFIX}}users`;
CREATE TABLE `{{DB_PREFIX}}users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `salutation` int(1) NOT NULL DEFAULT '0',
  `fullname` varchar(250) COLLATE {{DB_COLLATE}} NOT NULL,
  `email` varchar(250) COLLATE {{DB_COLLATE}} NOT NULL,
  `password` varchar(150) COLLATE {{DB_COLLATE}} NOT NULL,
  `timezone` varchar(200) COLLATE {{DB_COLLATE}} DEFAULT NULL,
  `status` int(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET={{DB_CHARSET}} COLLATE={{DB_COLLATE}};

-- ----------------------------
--  Table structure for `{{DB_PREFIX}}companies`
-- ----------------------------
DROP TABLE IF EXISTS `{{DB_PREFIX}}companies`;
CREATE TABLE `{{DB_PREFIX}}companies` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET latin1 NOT NULL,
  `baseurl` varchar(255) COLLATE {{DB_COLLATE}} DEFAULT NULL,
  `logo` text CHARACTER SET latin1,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET={{DB_CHARSET}} COLLATE={{DB_COLLATE}};

-- ----------------------------
--  Records of `{{DB_PREFIX}}companies`
-- ----------------------------
BEGIN;
INSERT INTO `{{DB_PREFIX}}companies` VALUES
('1', 'Default', null, 'iVBORw0KGgoAAAANSUhEUgAAAP0AAAA8CAYAAACtgbztAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEgAACxIB0t1+/AAABBF0RVh0WE1MOmNvbS5hZG9iZS54bXAAPD94cGFja2V0IGJlZ2luPSIgICAiIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4KPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgNC4xLWMwMzQgNDYuMjcyOTc2LCBTYXQgSmFuIDI3IDIwMDcgMjI6Mzc6MzcgICAgICAgICI+CiAgIDxyZGY6UkRGIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+CiAgICAgIDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiCiAgICAgICAgICAgIHhtbG5zOnhhcD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wLyI+CiAgICAgICAgIDx4YXA6Q3JlYXRvclRvb2w+QWRvYmUgRmlyZXdvcmtzIENTMzwveGFwOkNyZWF0b3JUb29sPgogICAgICAgICA8eGFwOkNyZWF0ZURhdGU+MjAxNC0wOS0xMVQyMjowMDoyNlo8L3hhcDpDcmVhdGVEYXRlPgogICAgICAgICA8eGFwOk1vZGlmeURhdGU+MjAxNC0xMi0wM1QxMjozOTozNFo8L3hhcDpNb2RpZnlEYXRlPgogICAgICA8L3JkZjpEZXNjcmlwdGlvbj4KICAgICAgPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIKICAgICAgICAgICAgeG1sbnM6ZGM9Imh0dHA6Ly9wdXJsLm9yZy9kYy9lbGVtZW50cy8xLjEvIj4KICAgICAgICAgPGRjOmZvcm1hdD5pbWFnZS9wbmc8L2RjOmZvcm1hdD4KICAgICAgPC9yZGY6RGVzY3JpcHRpb24+CiAgIDwvcmRmOlJERj4KPC94OnhtcG1ldGE+CiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgDTbSkAAAABZ0RVh0Q3JlYXRpb24gVGltZQAwOS8xMS8xNBDvGT4AAAAYdEVYdFNvZnR3YXJlAEFkb2JlIEZpcmV3b3Jrc0+zH04AABvySURBVHic7V1vjB3XVf+dO+/trv/VL6UUQj54WwRNW6RsJceClei+bRKnbQJ2kUpAlfCaqqpoqbwBmS9IeCM+LiI2pS2oQmtToZL2g22RQptC9y2glVpbylb1B5BoeFFboKVR1k5s7+6bew4f7rkz982beW/e+nlj4/klzzNzZ+beM2/f754/99w7JCKoUKHCvQPzRgtQoUKFnUVF+goV7jHU3mgBdhpPPP+hBoCpbPlXnjzf2nlpHA4ePPhGNX3XgIgmAUxmitcvXbq0tuPC3OW450gP4CEAyznltNOCVCgPIjpmjFkgcn8mEYGItADMjrqtsU+MT+6d2DtnyDRqpj7l2iRQ8gvx+xT8aII96i0bDBdb6w6xSfqvSHjknl/Lt+xWK7Zx+9qZ9bNlWroXSV/hLgQRwRiDkPTMPPJ23nRi/9xP7nvr0tt/8mfx5t334b49DTjypgQnENz/Aanzd3uO8iE5e90HAgmIH3YHgh9e++HM9179Pu7/gwdOvfL6j2e3PrvZ7tdaRfoKdw2IKCH97cDYJ8Ynf6bxwNIj73wE9+1qAORpTWn7nsTJJk/XF5cUQwqOUqKrandUl5T+b9n7Frz7/nfjO/91ZfLF7724hAHWTxXIq3BXwBM++xkldo/vOfJzP/Xz2D+xHwxRFyIlmDOpGaLnIL7M/4fujzMQBn6Euu9jIK1TC7va0UJ1cZzVA8G7738XGrsazbFPjE/2e85K01e4a5Al+qhJb4gaDzTuBwsD0t0eidPyglB/e23r2CsQdIkUmOOlIV2efOLkK82DayQ59sQH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')
COMMIT;

-- ----------------------------
--  Table structure for `{{DB_PREFIX}}company_settings`
-- ----------------------------
DROP TABLE IF EXISTS `{{DB_PREFIX}}company_settings`;
CREATE TABLE `{{DB_PREFIX}}company_settings` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `company_id` int(11) NOT NULL,
  `field` varchar(255) COLLATE {{DB_COLLATE}} DEFAULT NULL,
  `value` varchar(255) COLLATE {{DB_COLLATE}} DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `field` (`field`,`company_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET={{DB_CHARSET}} COLLATE={{DB_COLLATE}};

INSERT INTO `{{DB_PREFIX}}company_settings` (`company_id`, `field`, `value`) VALUES
(1, 'use_captcha', '1'),
(1, 'email_ticket', 'support@mysite.com'),
(1, 'site_name', 'Support Center'),
(1, 'site_url', '{{SITE_URL}}'),
(1, 'windows_title', 'Support Center'),
(1, 'show_tickets', 'DESC'),
(1, 'ticket_reopen', '0'),
(1, 'tickets_page', '20'),
(1, 'timezone', 'America/Lima'),
(1, 'ticket_attachment', '1'),
(1, 'permalink', '0'),
(1, 'loginshare', '0'),
(1, 'loginshare_url', 'http://yoursite.com/loginshare/'),
(1, 'date_format', 'd F Y h:i a'),
(1, 'page_size', '25'),
(1, 'login_attempt', '3'),
(1, 'login_attempt_minutes', '5'),
(1, 'overdue_time', '72'),
(1, 'knowledgebase_columns', '2'),
(1, 'knowledgebase_articlesundercat', '2'),
(1, 'knowledgebase_articlemaxchar', '200'),
(1, 'knowledgebase_mostpopular', 'yes'),
(1, 'knowledgebase_mostpopulartotal', '4'),
(1, 'knowledgebase_newest', 'yes'),
(1, 'knowledgebase_newesttotal', '4'),
(1, 'knowledgebase', 'yes'),
(1, 'news', 'yes'),
(1, 'news_page', '4'),
(1, 'homepage', 'knowledgebase'),
(1, 'email_piping', 'yes'),
(1, 'smtp', 'no'),
(1, 'smtp_hostname', 'smtp.gmail.com'),
(1, 'smtp_port', '587'),
(1, 'smtp_ssl', 'tls'),
(1, 'smtp_username', 'mail@gmail.com'),
(1, 'smtp_password', 'password'),
(1, 'tickets_replies', '10'),
(1, 'helpdeskz_version', '{{HELPDESKZ_VERSION}}'),
(1, 'closeticket_time', '72'),
(1, 'client_language', 'english'),
(1, 'staff_language', 'english'),
(1, 'client_multilanguage', '0'),
(1, 'maintenance', '0'),
(1, 'facebookoauth', '0'),
(1, 'facebookappid', NULL),
(1, 'facebookappsecret', NULL),
(1, 'googleoauth', '0'),
(1, 'googleclientid', NULL),
(1, 'googleclientsecret', NULL),
(1, 'socialbuttonnews', '0'),
(1, 'socialbuttonkb', '0'),
(1, 'imap_host',''),
(1, 'imap_port','143'),
(1, 'imap_username',''),
(1, 'imap_password',''),
(1, 'imap_mail_downloader_processaction','move'),
(1, 'imap_mail_downloader_processaction_folder','processed'),
(1, 'email_piping_trigger_notification','no'),
(1, 'email_on_new_reply','no');

SET FOREIGN_KEY_CHECKS = 1;
