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
--  Table structure for `{{DB_PREFIX}}settings`
-- ----------------------------
DROP TABLE IF EXISTS `{{DB_PREFIX}}settings`;
CREATE TABLE `{{DB_PREFIX}}settings` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `field` varchar(255) COLLATE {{DB_COLLATE}} DEFAULT NULL,
  `value` varchar(255) COLLATE {{DB_COLLATE}} DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `field` (`field`)
) ENGINE=InnoDB DEFAULT CHARSET={{DB_CHARSET}} COLLATE={{DB_COLLATE}};

INSERT INTO `{{DB_PREFIX}}settings` (`field`, `value`) VALUES
('use_captcha', '1'),
('email_ticket', 'support@mysite.com'),
('site_name', 'Support Center'),
('site_url', '{{SITE_URL}}'),
('windows_title', 'Support Center'),
('show_tickets', 'DESC'),
('ticket_reopen', '0'),
('tickets_page', '20'),
('timezone', 'America/Lima'),
('ticket_attachment', '1'),
('permalink', '0'),
('loginshare', '0'),
('loginshare_url', 'http://yoursite.com/loginshare/'),
('date_format', 'd F Y h:i a'),
('page_size', '25'),
('login_attempt', '3'),
('login_attempt_minutes', '5'),
('overdue_time', '72'),
('knowledgebase_columns', '2'),
('knowledgebase_articlesundercat', '2'),
('knowledgebase_articlemaxchar', '200'),
('knowledgebase_mostpopular', 'yes'),
('knowledgebase_mostpopulartotal', '4'),
('knowledgebase_newest', 'yes'),
('knowledgebase_newesttotal', '4'),
('knowledgebase', 'yes'),
('news', 'yes'),
('news_page', '4'),
('homepage', 'knowledgebase'),
('email_piping', 'yes'),
('smtp', 'no'),
('smtp_hostname', 'smtp.gmail.com'),
('smtp_port', '587'),
('smtp_ssl', 'tls'),
('smtp_username', 'mail@gmail.com'),
('smtp_password', 'password'),
('tickets_replies', '10'),
('helpdeskz_version', '{{HELPDESKZ_VERSION}}'),
('closeticket_time', '72'),
('client_language', 'english'),
('staff_language', 'english'),
('client_multilanguage', '0'),
('maintenance', '0'),
('facebookoauth', '0'),
('facebookappid', NULL),
('facebookappsecret', NULL),
('googleoauth', '0'),
('googleclientid', NULL),
('googleclientsecret', NULL),
('socialbuttonnews', '0'),
('socialbuttonkb', '0'),
('imap_host',''),
('imap_port','143'),
('imap_username',''),
('imap_password',''),
('imap_mail_downloader_processaction','move'),
('imap_mail_downloader_processaction_folder','processed'),
('email_piping_trigger_notification','no'),
('email_on_new_reply','no');

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

SET FOREIGN_KEY_CHECKS = 1;
