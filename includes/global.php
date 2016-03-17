<?php
/**
 * @package HelpDeskZ
 * @website: http://www.helpdeskz.com
 * @community: http://community.helpdeskz.com
 * @author Evolution Script S.A.C.
 * @since 1.0.0
 */
session_start();
error_reporting(E_ALL & ~E_NOTICE);
define('ROOTPATH', dirname(dirname(__FILE__)).'/');
define('INCLUDES', ROOTPATH . 'includes/');
define('CONTROLLERS', ROOTPATH . 'controllers/');
define('TEMPLATES', ROOTPATH . 'views/');
define('CLIENT_TEMPLATE', TEMPLATES . 'client/');
define('STAFF_TEMPLATE', TEMPLATES . 'staff/');
define('ADMIN_TEMPLATE', TEMPLATES . 'admin/');
define('UPLOAD_DIR', ROOTPATH . 'uploads/');

require_once INCLUDES.'classes/classRegistry.php';
require_once INCLUDES.'classes/classInput.php';
require_once INCLUDES.'classes/classMailer.php';
require_once INCLUDES.'functions.php';
require_once INCLUDES.'timezone.inc.php';
// DB Connection
$helpdeskz = new Registry();
$input = new Input_Cleaner();
if(CONF_DB_TYPE == 'mysqli'){
	require_once INCLUDES.'classes/classMysqli.php';
	$db = new MySQLIDB();
}
elseif(CONF_DB_TYPE == 'PDO'){
	require_once INCLUDES.'classes/PDODB.class.php';
	$db = new PDODB;
}
else{
	exit("No valid DB connection type found?");
}
$db->connect(CONF_DB_DATABASE, CONF_DB_HOST, CONF_DB_USERNAME, CONF_DB_PASSWORD);

$settings = array();
$q = $db->query("SELECT * FROM ".TABLE_PREFIX."settings");
while($r = $db->fetch_array($q)){
	$settings[$r['field']] = $r['value'];
}
if(in_array($settings['timezone'], $timezone)){
	date_default_timezone_set($settings['timezone']);
}
