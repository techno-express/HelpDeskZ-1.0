<?php
/**
 * @package HelpDeskZ
 * @website: http://www.helpdeskz.com
 * @community: http://community.helpdeskz.com
 * @author Evolution Script S.A.C.
 * @since 1.0.0
 */
class Registry
{
	var $input;

	public function __construct() {
		$this->Registry();
	}

	function Registry(){
		define('CWD', (($getcwd = getcwd()) ? $getcwd : '.'));
		if (file_exists(INCLUDES.'config.php')) {
			if(filesize(INCLUDES.'config.php') < 10) {
				die('<br /><br /><strong>Configuration</strong>: includes/config.php exists, but is not in the correct format. Please convert your config file via the new config.php.new.');
			}
			include(INCLUDES.'config.php');
		}
		else {
			die('<br /><br /><strong>Configuration</strong>: includes/config.php does not exist. Please fill out the data in config.php.new and rename it to config.php');
		}
	}
}
?>
