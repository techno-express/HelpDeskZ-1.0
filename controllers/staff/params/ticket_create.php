<?php



function display_parent_cats($parent_category,$level){
	global $parent_cat, $kbselector;
	$level = $level;
	$nextlevel = $level+1;
	for($i=1;$i<=$level;$i++){
		$spaces .= "&nbsp; &nbsp;";
	}
	if(is_array($parent_category)){
		foreach($parent_category as $parent){
			$selector .= '<optgroup label="'.$spaces.$parent['name'].'">';
			if(is_array($kbselector[$parent['id']])){
				foreach($kbselector[$parent['id']] as $kb){
					$selector .= $kb;
				}
			}
			if(is_array($parent_cat[$parent['id']])){
				$selector .= display_parent_cats($parent_cat[$parent['id']],$nextlevel);
			}
			$selector .= '</optgroup>';
		}
	}
	return $selector;
}


$ticket_status = array();
$q = $db->query("SELECT id, langstring FROM ".TABLE_PREFIX."ticket_status ORDER BY id ASC");
while($r = $db->fetch_array($q)){
	$ticket_status[$r['id']] = $LANG[$r['langstring']];
}

if($params[1] == 'new'){
		$template = $twig->loadTemplate('create_ticket.html');
		echo $template->render($template_vars);
}
if($params[1] == 'send'){

	$from_email = $staff['email'];
	$from_name = $staff['fullname'];

	if(verifyToken('ticket', $input->p['csrfhash']) !== true){
		$error_msg = $LANG['CSRF_ERROR'];
	}elseif(empty($input->p['message'])){
		$error_msg = $LANG['ENTER_YOUR_MESSAGE'];
	}elseif(empty($input->p['customer_email'])){
		$error_msg = 'Enter a customer email address!';
	}elseif(empty($input->p['subject'])){
		$error_msg = 'Enter a subject!';
	}else{
		$uploaddir = UPLOAD_DIR.'tickets/';
		if($_FILES['attachment']['error'] == 0){
			$ext = pathinfo($_FILES['attachment']['name'], PATHINFO_EXTENSION);
			$filename = md5($_FILES['attachment']['name'].time()).".".$ext;
			$fileuploaded[] = array('name' => $_FILES['attachment']['name'], 'enc' => $filename, 'size' => formatBytes($_FILES['attachment']['size']), 'filetype' => $_FILES['attachment']['type']);
			$uploadedfile = $uploaddir.$filename;
			if (!move_uploaded_file($_FILES['attachment']['tmp_name'], $uploadedfile)) {
				$error_msg = $LANG['ERROR_UPLOADING_FILE'];
			}
		}
	}

	if($error_msg != ''){
		$template_vars['custom_fieldsdb'] = $custom_fieldsdb;
		$template_vars['custom_vars'] = $custom_vars;
		$template_vars['cannedList'] = $cannedList;
		$template_vars['selector'] = $selector;
		$template_vars['error_msg'] = $error_msg;
		$template = $twig->loadTemplate('view_ticket.html');
		echo $template->render($template_vars);
		//header('location: '.getUrl($controller, $action, array('view',$ticketid,'replied')));
		exit;
	}

	if($error_msg == ''){
		$datenow = time();

		$department = $db->fetchRow("SELECT id, name FROM ".TABLE_PREFIX."departments WHERE autoassign=1 LIMIT 1");
		$subject = $input->p['subject'];

		$user = $db->fetchRow("SELECT COUNT(id) AS total, id FROM ".TABLE_PREFIX."users WHERE email='".$db->real_escape_string($input->p['customer_email'])."'");
		if($user['total'] == 0){
			$password = substr((md5(time().$input->p['customer_email'])),5,7);
			$data = array(
				'fullname' => $input->p['customer_email'],
				'email' => $input->p['customer_email'],
				'password' => Password::create($password),
			);

			$db->insert(TABLE_PREFIX."users", $data);
			$user_id = $db->lastInsertId();

			/* Mailer */
			$data_mail = array(
				'id' => 'new_user',
				'to' => $input->p['customer_email'],
				'to_mail' => $input->p['customer_email'],
				'vars' => array('%client_name%' => $input->p['customer_email'], '%client_email%' => $input->p['customer_email'], '%client_password%' => $password),
			);
			$mailer = new Mailer($data_mail);
		}
		else {
			$user_id = $user['id'];
		}

		$ticket_id = Ticket::generateId($input->p['customer_email']);
		$previewcode = substr((md5(microtime().$input->p['customer_email'])),2,12);

		$data = array(
			'code' => $ticket_id,
			'department_id' => $department['id'],
			'priority_id' => 1,
			'user_id' => $user_id,
			'fullname' => $from_name,
			'email' => $input->p['customer_email'],
			'subject' => $subject,
			'date' => $datenow,
			'last_update' => $datenow,
			'previewcode' => $previewcode,
			'last_replier' => $from_name,
		);

		$db->insert(TABLE_PREFIX.'tickets', $data);
		$ticketid = $db->lastInsertId();

		$ticket = $data;
		//$ticket = $db->fetchRow("SELECT *, count(id) as total FROM ".TABLE_PREFIX."tickets WHERE id=$ticketid");

		$data = array('ticket_id' => $ticketid,
			'date' => $datenow,
			'customer' => '0',
			'name' => $staff['fullname'],
			'message' => $input->p['message']."\n\n".$staff['signature'],
			'ip' => $_SERVER['REMOTE_ADDR'],
			'email' => $staff['email'],
			'email_to' => $input->p['customer_email']
		);
		$db->insert(TABLE_PREFIX.'tickets_messages',$data);
		$message_id = $db->lastInsertId();

		$db_ticket_status = $db->fetchRow("SELECT id FROM ".TABLE_PREFIX."ticket_status WHERE langstring = 'AWAITING_REPLY' LIMIT 1");

		$status = $db_ticket_status['id'];
		$db->query("UPDATE ".TABLE_PREFIX."tickets SET last_update='$datenow', status='$status', replies=replies+1, last_replier='".$db->real_escape_string($staff['fullname'])."' WHERE id=$ticketid");
		if(is_array($fileuploaded)){
			foreach($fileuploaded as $f){
				$data = array('name' => $f['name'], 'enc' => $f['enc'], 'filesize' => $f['size'], 'ticket_id' => $ticketid, 'msg_id' => $message_id, 'filetype' => $f['filetype']);
				$db->insert(TABLE_PREFIX."attachments", $data);
			}
		}
		// Mailer
		$data_mail = array(
		'id' => 'staff_reply',
		'to' => $ticket['fullname'],
		'to_mail' => $input->p['customer_email'],
		'attachement' => (is_array($fileuploaded)?1:0),
		'attachement_type' => 'tickets',
		'attachement_files' => $fileuploaded,
		'vars' => array('%client_name%' => $ticket['fullname'],
						'%client_email%' => $ticket['email'],
						'%ticket_id%' => $ticket['code'],
						'%ticket_subject%' => $ticket['subject'],
						'%ticket_department%' => $departments[$ticket['department_id']],
						'%ticket_status%' => $ticket_status[$status],
						'%ticket_priority%' => $priority[$ticket['priority_id']]['name'],
						'%message%' => $input->p['message']."\n\n".$staff['signature'],
						),

		);

		$mailer = new Mailer($data_mail);
		header('location: '.getUrl($controller, $action, array('view',$ticketid,'replied')));
		exit;
	}

	//header('location: '.getUrl($controller, $action, array())); //$action = 'tickets'
	exit();
}

$db->close();
die();



?>
