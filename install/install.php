<?php
/**
 * @package HelpDeskZ
 * @website: http://www.helpdeskz.com
 * @community: http://community.helpdeskz.com
 * @author Evolution Script S.A.C.
 * @since 1.0.0
 */
error_reporting(E_ALL & ~E_NOTICE);
session_start();
require_once __DIR__.'/functions.php';
require_once HELPDESKZ_PATH.'includes/classes/PDODB.class.php';
require_once HELPDESKZ_PATH.'includes/classes/classMysqli.php';
require_once HELPDESKZ_PATH.'includes/classes/classInput.php';
$input = new Input_Cleaner();
function helpdeskz_getQuery($db_prefix, $admin_user, $admin_password, $db_charset, $db_collate){

	$sql_file_content = file_get_contents(__DIR__.'/install.sql');

	$replacements = array(
		'{{SITE_URL}}' => "http://". str_replace("/install/install.php", "",$_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI']),
		'{{DB_PREFIX}}' => $db_prefix,
		'{{DB_COLLATE}}' => $db_collate,
		'{{DB_CHARSET}}' => $db_charset,
		'{{HELPDESKZ_VERSION}}' => HELPDESKZ_VERSION,
		'{{ADMIN_USER}}' => $admin_user,
		'{{ADMIN_PASS}}' => Password::create($admin_password)
	);
	$sql_file_content = str_replace(array_keys($replacements), array_values($replacements), $sql_file);
	return $sql_file_content;
}

function helpdeskz_saveConfigFile($db_host, $db_name, $db_user, $db_password, $db_prefix, $db_type, $db_charset, $db_collate){

	//$hash = bin2hex(random_bytes(8)); //php 7
	$hash = bin2hex(openssl_random_pseudo_bytes(8));

	$content = '<?php

	define(\'CONF_DB_DATABASE\', \''.$db_name.'\');
	define(\'CONF_DB_USERNAME\', \''.$db_user.'\');
	define(\'CONF_DB_PASSWORD\', \''.str_replace("'","\\'", $db_password).'\');
	define(\'CONF_DB_HOST\', \''.$db_host.'\');
	define(\'TABLE_PREFIX\', \''.$db_prefix.'\');
	define(\'CONF_DB_TYPE\', \''.$db_type.'\');
	define(\'CONF_DB_CHARSET\', \''.$db_charset.'\');
	define(\'CONF_DB_COLLATE\', \''.$db_collate.'\');

	define(\'CONF_UNIQUEHASH\', \''.$hash.'\');
	?>';
	if ( ! file_put_contents(HELPDESKZ_PATH . 'includes/config.php', $content) )
	{
		return false;
	}else{
		return true;
	}
}


function helpdeskz_agreement(){
	helpdeskz_header();
?>
<h3>Welcome</h3>

<p>Welcome to HelpDeskZ installation process! This will be easy and fun. If you need help, take a look to the ReadMe documentation
(readme.html)</p>
    <p>If you have new ideas to improve the software, feel free to contact us:</p>
<ul>
<li><a href="http://community.helpdeskz.com/">Community</a></li>
    <li><a href="http://www.helpdeskz.com/help/submit_ticket">Helpdesk ticket</a></li>
</ul>


    	<form method="post" action="./install.php">


	<input type="hidden" name="license" value="agree" />
	<input type="submit" value="Continue" />

        </form>
<?php
	helpdeskz_footer();
}

function helpdeskz_checksetup(){
	$error_msg = array();
    if ( function_exists('version_compare') && version_compare(PHP_VERSION,'5.0.0','<') ){
		$error_msg[] = 'PHP version <b>5.0+</b> required, you are using: <b>' . PHP_VERSION . '</b>';
	}
	if ( ! function_exists('mysql_connect') && ! function_exists('mysqli_connect') ){
		$error_msg[] = 'MySQL is disabled.';
	}
	if ( ! is_writable(HELPDESKZ_PATH . 'includes/config.php') )
	{
		// -> try to CHMOD it
		if ( function_exists('chmod') )
		{
			@chmod(HELPDESKZ_PATH . 'includes/config.php', 0666);
		}

		// -> test again
		if ( ! is_writable(HELPDESKZ_PATH . 'includes/config.php') )
		{
			$error_msg[] = 'File <strong>includes/config.php</strong> is not writable by PHP.';
		}
	}

    $attach_dir = HELPDESKZ_PATH . 'uploads';
	if ( ! file_exists($attach_dir) )
	{
	    @mkdir($attach_dir, 0755);
	}

	if ( is_dir($attach_dir) )
    {
	    if ( ! is_writable($attach_dir) )
	    {
			@chmod($attach_dir, 0777);
			if ( ! is_writable($attach_dir) )
			{
				$error_msg[] = '>Folder <strong>/uploads</strong> is not writable by PHP.';
		   	}
	    }
	}
	else
	{
		$error_msg[] = 'Folder <strong>/uploads</strong> is missing.';
	}

    $attach_dir = HELPDESKZ_PATH . 'uploads/articles';
	if ( ! file_exists($attach_dir) )
	{
	    @mkdir($attach_dir, 0755);
	}

	if ( is_dir($attach_dir) )
    {
	    if ( ! is_writable($attach_dir) )
	    {
			@chmod($attach_dir, 0777);
			if ( ! is_writable($attach_dir) )
			{
				$error_msg[] = '>Folder <strong>/uploads/articles</strong> is not writable by PHP.';
		   	}
	    }
	}
	else
	{
		$error_msg[] = 'Folder <strong>/uploads/articles</strong> is missing.';
	}

    $attach_dir = HELPDESKZ_PATH . 'uploads/tickets';
	if ( ! file_exists($attach_dir) )
	{
	    @mkdir($attach_dir, 0755);
	}

	if ( is_dir($attach_dir) )
    {
	    if ( ! is_writable($attach_dir) )
	    {
			@chmod($attach_dir, 0777);
			if ( ! is_writable($attach_dir) )
			{
				$error_msg[] = '>Folder <strong>/uploads/tickets</strong> is not writable by PHP.';
		   	}
	    }
	}
	else
	{
		$error_msg[] = 'Folder <strong>/uploads/tickets</strong> is missing.';
	}

    if ( count($error_msg) ){
		helpdeskz_header();
		echo '<h3>Check Setup</h3>';
		echo '<div class="error_box">';
        foreach ($error_msg as $err)
        {
        	echo $err.'<br>';
        }
		echo '</div>';
		helpdeskz_footer();
	}else{
		helpdeskz_database();
	}
}

function helpdeskz_database($error_msg =null){
	helpdeskz_header();
	if($error_msg !== null){
		echo '<div class="error_box">'.$error_msg.'</div>';
	}
	?>
    <h3>Database settings</h3>
	<form action="install.php" method="post">
	<table>
	<tr>
	<td width="200">Database Host:</td>
	<td><input type="text" name="db_host" value="<?php echo ($_POST['db_host'] == ''?'localhost':htmlspecialchars($_POST['db_host']));?>" size="40" autocomplete="off" /></td>
	</tr>
	<tr>
	<td width="200">Database Name:</td>
	<td><input type="text" name="db_name" value="<?php echo htmlspecialchars($_POST['db_name']);?>" size="40" autocomplete="off" /></td>
	</tr>
	<tr>
	<td width="200">Database User (login):</td>
	<td><input type="text" name="db_user" value="<?php echo htmlspecialchars($_POST['db_user']);?>" size="40" autocomplete="off" /></td>
	</tr>
	<tr>
	<td width="200">User Password:</td>
	<td><input type="text" name="db_password" value="<?php echo htmlspecialchars($_POST['db_password']);?>" size="40" autocomplete="off" /></td>
	</tr>
		<tr>
			<td width="200">Table prefix:</td>
			<td><input type="text" name="db_prefix" value="<?php echo ($_POST['db_prefix'] == ''?'hdz_':htmlspecialchars($_POST['db_prefix']));?>" size="40" autocomplete="off" /></td>
		</tr>
		<tr>
			<td width="200">Database Charset:</td>
			<td><select name="sql_charset">
					<option value="utf8" <?php echo ($_POST['sql_charset'] == 'utf8'?'selected':'');?>>utf8</option>
					<option value="utf8mb4" <?php echo ($_POST['sql_charset'] == 'utf8mb4'?'selected':'');?>>utf8</option>
					<option value="latin1" <?php echo ($_POST['sql_charset'] == 'latin1'?'selected':'');?>>latin1</option>
				</select>
			</td>
			<td width="200">Database Collate:</td>
			<td><select name="sql_collate">
					<option value="utf8_unicode_ci" <?php echo ($_POST['sql_collate'] == 'utf8_unicode_ci'?'selected':'');?>>utf8</option>
					<option value="utf8mb4_unicode_ci" <?php echo ($_POST['sql_collate'] == 'utf8mb4_unicode_ci'?'selected':'');?>>utf8</option>
					<option value="latin1_general_ci" <?php echo ($_POST['sql_collate'] == 'latin1_general_ci'?'selected':'');?>>utf8</option>
				</select>
			</td>
		</tr>
    <tr>
    <td width="200">Use:</td>
    <td><select name="sql_type">
    <option value="mysqli" <?php echo ($_POST['sql_type'] == 'mysqli'?'selected':'');?>>MySQLi</option>
		<option value="PDO" <?php echo ($_POST['sql_type'] == 'PDO'?'selected':'');?> disabled>PDO</option>
    </select>
    </td>
    </tr>
    </table>
    <h3>Login details</h3>

    <p>Username and password you will use to login into HelpDeskZ administration.</p>
		<table>
		<tr>
		<td width="200">Choose a Username:</td>
		<td><input type="text" name="admin_user" value="<?php echo isset($_POST['admin_user']) ? htmlspecialchars($_POST['admin_user']) : 'Administrator'; ?>" size="40" autocomplete="off" /></td>
		</tr>
		<tr>
		<td width="200">Choose a Password:</td>
		<td><input type="text" name="admin_password" value="<?php echo isset($_POST['db_password']) ? htmlspecialchars($_POST['admin_password']) : ''; ?>" size="40" autocomplete="off" /></td>
		</tr>
		<tr>
        	<td></td>
            <td><input type="hidden" name="license" value="agree" />
            <input type="hidden" name="settings" value="install" />
            <input type="submit" name="btn" value="Install HelpDeskZ" /></td>
        </tr>
		</table>
    </form>
    <?php
	helpdeskz_footer();
}

function helpdeskz_completed(){
	helpdeskz_header();
?>
	<h3>Installation Completed</h3>
    <p>Installation has been successfully completed, <strong>do not forget to remove</strong> <strong style="color:red">/install</strong> folder</p>
    <p><a href="../?v=staff" target="_blank">Click here to open staff panel</a></p>
<?php
	helpdeskz_footer();
}
if($input->p['license'] == 'agree') {
	if($input->p['settings'] == 'install') {
		if($input->p['sql_type'] == 'mysqli') {
			$db = new MySQLIDB;
		}
		elseif($input->p['sql_type'] == 'PDO') {
			$db = new PDODB;
		}
		else {
			helpdeskz_database('No correct database type found/selected');
			exit;
		}
		$error_msg = $db->testconnect($input->p['db_name'], $input->p['db_host'], $input->p['db_user'], $input->p['db_password']);
		if($error_msg != ''){
			helpdeskz_database($error_msg);
		}elseif($input->p['admin_user'] == '' || $input->p['admin_password'] == ''){
			helpdeskz_database('Enter the HelpDeskZ login details.');
		}else{

			$db->connect($input->p['db_name'], $input->p['db_host'], $input->p['db_user'], $input->p['db_password'], $input->p['db_prefix']);
			$query = helpdeskz_getQuery($input->p['db_prefix'], $input->p['admin_user'], $input->p['admin_password'], $input->p['sql_charset'], $input->p['sql_collate']);
			$db->query($query);

			helpdeskz_saveConfigFile($input->p['db_host'], $input->p['db_name'], $input->p['db_user'], $input->p['db_password'], $input->p['db_prefix'], $input->p['sql_type'], $input->p['sql_charset']);
			header('location: install.php?result=completed');
			exit;
		}
	}
	helpdeskz_checksetup();
}else{
	if($input->g['result'] == 'completed'){
		helpdeskz_completed();
	}else{
		helpdeskz_agreement();
	}
}
?>
