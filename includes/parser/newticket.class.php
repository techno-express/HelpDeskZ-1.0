<?php

class newticket {

	private $db = null;

	public function __construct() {
		require_once INCLUDES.'global.php';
		$this->db = $db;
	}

	public function parse($from_name, $from_email, $to_email, $password, $subject, $text, $attachments) {
		include_once(INCLUDES.'language/'.$settings['client_language'].'.php');

		$department = $this->db->fetchRow("SELECT id, name FROM ".TABLE_PREFIX."departments WHERE autoassign=1 LIMIT 1");
		if($department === null) {
			return false;
		}
		if($text == '') {
			return false;
		}

		$datenow = time();

		$user = $this->db->fetchRow("SELECT COUNT(id) AS total, id FROM ".TABLE_PREFIX."users WHERE email='".$this->db->real_escape_string($from_email)."'");

		if($user['total'] == 0){
			$password = substr((md5(time().$from_name)),5,7);
			$data = array(
				'fullname' => $from_name,
				'email' => $from_email,
				'password' => sha1($password),
			);

			$this->db->insert(TABLE_PREFIX."users", $data);
			$user_id = $this->db->lastInsertId();

			/* Mailer */
			$data_mail = array(
				'id' => 'new_user',
				'to' => $from_name,
				'to_mail' => $from_email,
				'vars' => array('%client_name%' => $from_name, '%client_email%' => $from_email, '%client_password%' => $password),
			);
			$mailer = new Mailer($data_mail);
		}
		else {
			$user_id = $user['id'];
		}
		$ticket_id = substr(strtoupper(sha1(time().$from_email)), 0, 11);
		$ticket_id = substr_replace($ticket_id, '-',3,0);
		$ticket_id = substr_replace($ticket_id, '-',7,0);
		$previewcode = substr((md5(time().$from_name)),2,12);
		$data = array(
			'code' => $ticket_id,
			'department_id' => $department['id'],
			'priority_id' => 1,
			'user_id' => $user_id,
			'fullname' => $from_name,
			'email' => $from_email,
			'subject' => $subject,
			'date' => $datenow,
			'last_update' => $datenow,
			'previewcode' => $previewcode,
			'last_replier' => $from_name,
		);

		$this->db->insert(TABLE_PREFIX.'tickets', $data);
		$ticketid = $this->db->lastInsertId();
		$data = array(
			'ticket_id' => $ticketid,
			'date' => time(),
			'message' => $text,
			'ip' => $_SERVER['REMOTE_ADDR'],
			'email' => $from_email,
		);
		$this->db->insert(TABLE_PREFIX.'tickets_messages', $data);
		$message_id = $this->db->lastInsertId();

		foreach($attachments as $filename => $content) {
			file_put_contents(
		    UPLOAD_DIR . $filename,
		    $content
			);

		  $filesize = @filesize(UPLOAD_DIR.$filename);
		  if($filesize){
			  $fileinfo = array('name' => $filename, 'size' => $filesize);
			  $fileverification = verifyAttachment($fileinfo);
			  if($fileverification['msg_code'] == 0){
					$ext = pathinfo($filename, PATHINFO_EXTENSION);
					$filename_encoded = md5($filename.time()).".".$ext;
					$data = array('name' => $filename, 'enc' => $filename_encoded, 'filesize' => $filesize, 'ticket_id' => $ticketid, 'msg_id' => $message_id, 'filetype' => $attachment->content_type);
					$this->db->insert(TABLE_PREFIX."attachments", $data);
					rename(UPLOAD_DIR.$filename, UPLOAD_DIR.'tickets/'.$filename_encoded);
			  }else{
					unlink(UPLOAD_DIR.$filename);
			  }
		  }
		}
		/* Mailer */
		$data_mail = array(
		'id' => 'new_ticket',
		'to' => $from_name,
		'to_mail' => $from_email,
		'vars' => array('%client_name%' => $from_name,
						'%client_email%' => $from_email,
						'%ticket_id%' => $ticket_id,
						'%ticket_subject%' => $subject,
						'%ticket_department%' => $department['name'],
						'%ticket_status%' => $LANG['OPEN'],
						'%ticket_priority%' => 'Low',
						),
		);
		$mailer = new Mailer($data_mail);

		if ($settings['email_piping_trigger_notification']){
			/* New ticket notification for staff */
			$q = $this->db->query("SELECT id, fullname, email, department FROM ".TABLE_PREFIX."staff WHERE newticket_notification=1 AND status='Enable'");
			while($r = $this->db->fetch_array($q))
			{
				$department_list = unserialize($r['department']);
				$department_list = (is_array($department_list)?$department_list:array());
				if(in_array($department['id'],$department_list))
				{
					/* Mailer */
					$data_mail = array(
						'id' => 'staff_ticketnotification',
						'to' => $r['fullname'],
						'to_mail' => $r['email'],
						'vars' => array('%staff_name%' => $r['fullname'],
							'%staff_name%' => $r['fullname'],
							'%ticket_id%' => $ticket_id,
							'%ticket_subject%' => $input->p['subject'],
							'%ticket_department%' => $department['name'],
							'%ticket_status%' => $LANG['OPEN'],
							'%ticket_priority%' => $priorityvar['name'],
						),
					);
					$mailer = new Mailer($data_mail);
				}
			}
		}
	}
}
