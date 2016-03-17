<?php

class replyticket {

	private $db = null;

	public function __construct($db, $settings) {
		$this->db = $db;
		$this->settings = $settings;
	}

	public function parse($regs, $LANG, $from_name, $from_email, $to_email, $password, $subject, $text, $attachments) {
		include_once(INCLUDES.'language/'.$this->settings['client_language'].'.php');

		$datenow = time();

		$code=trim(preg_replace("/\[/", "", $regs[0]));
		$code=trim(preg_replace("/\]/", "", $code));
		$code=str_replace("#","",$code);

		$ticket_status = array();
		$q = $this->db->query("SELECT id, langstring FROM ".TABLE_PREFIX."ticket_status ORDER BY id ASC");
		while($r = $this->db->fetch_array($q)){
			$ticket_status[$r['id']] = $LANG[$r['langstring']];
		}

		$ticket = $this->db->fetchRow("SELECT COUNT(id) AS total, id, status, fullname, code, department_id, priority_id, subject FROM ".TABLE_PREFIX."tickets WHERE email='".$this->db->real_escape_string($from_email)."' AND code='".$this->db->real_escape_string($code)."'");
		if($ticket['total'] != 0){
			$data = array(
							'ticket_id' => $ticket['id'],
							'date' => $datenow,
							'message' => $text,
							'ip' => 'IMAP',
							'email' => $from_email,
							'email_to' => $to_email
						);
			$this->db->insert(TABLE_PREFIX."tickets_messages", $data);
			$message_id = $this->db->lastInsertId();
			if($ticket['status'] == '5' || $ticket['status'] == '2'){
				$status_name = $LANG['AWAITING_REPLY'];
				$addquery = ", status='3'";
			}else{
				$status_name = $ticket_status[$ticket['status']];
			}
			$this->db->query("UPDATE ".TABLE_PREFIX."tickets SET last_update=".$datenow.", replies=replies+1, last_replier='{$ticket['fullname']}' {$addquery} WHERE id={$ticket['id']}");
			$this->db->update(TABLE_PREFIX."tickets", $data, "id={$tdetails['id']}");
			if(is_array($attachments)){
				foreach($attachments as $filename => $content) {
				  // get the attachment name

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
							$data = array('name' => $filename, 'enc' => $filename_encoded, 'filesize' => $filesize, 'ticket_id' => $ticket['id'], 'msg_id' => $message_id, 'filetype' => $attachment->content_type);
							$this->db->insert(TABLE_PREFIX."attachments", $data);
							rename(UPLOAD_DIR.$filename, UPLOAD_DIR.'tickets/'.$filename_encoded);
					  }
					  else{
							@unlink(UPLOAD_DIR.$filename);
					  }
				  }
				}
			}
			/* Mailer */
			$fullname = $from_name;
			$email = $from_email;
			$department_name = $this->db->fetchOne("SELECT name FROM ".TABLE_PREFIX."departments WHERE id={$ticket['department_id']}");
			$priority_name = $this->db->fetchOne("SELECT name FROM ".TABLE_PREFIX."priority WHERE id={$ticket['priority_id']}");
			$data_mail = array(
			'id' => 'autoresponse',
			'to' => $fullname,
			'to_mail' => $email,
			'vars' => array('%client_name%' => $fullname,
							'%client_email%' => $email,
							'%ticket_id%' => $ticket['code'],
							'%ticket_subject%' => $ticket['subject'],
							'%ticket_department%' => $department_name,
							'%ticket_status%' => $status_name,
							'%ticket_priority%' => $priority_name,
							),
			);
			$mailer = new Mailer($data_mail);

			if ($settings['email_piping_trigger_notification']){
				/* response  notification for staff */
				$q = $this->db->query("SELECT id, fullname, email, department FROM ".TABLE_PREFIX."staff WHERE newticket_notification=1 AND status='Enable'");
				while($r = $this->db->fetch_array($q))
				{
					$department_list = unserialize($r['department']);
					$department_list = (is_array($department_list)?$department_list:array());
					if(in_array($ticket['department_id'],$department_list))
					{
						/* Mailer */
						$data_mail = array(
							'id' => 'staff_ticketupdate_notification',
							'to' => $r['fullname'],
							'to_mail' => $r['email'],
							'vars' => array(
								'%staff_name%' => $r['fullname'],
								'%ticket_id%' => $ticket['code'],
								'%ticket_subject%' => $ticket['subject'],
								'%ticket_department%' => $department_name,
								'%ticket_status%' => $status_name,
								'%ticket_priority%' => $priority_name,
								'%message%' => $text
							),
						);
						$mailer = new Mailer($data_mail);
					}
				}
			}
		} else {
		//
		//	$staff = $this->db->fetchRow("SELECT COUNT(id) AS total, * FROM ".TABLE_PREFIX."staff WHERE email='".$this->db->real_escape_string($from_email)."'");
		//
		//	// if the email was sent from a staff member..
		//	if ($staff['total'] == 1){
		//
		//	}
		//
		//	$ticket = $this->db->fetchRow("SELECT COUNT(id) AS total, id, status, fullname, email, code, department_id, priority_id, subject FROM ".TABLE_PREFIX."tickets WHERE code='".$this->db->real_escape_string($code)."'");
		//	if($ticket['total'] != 0){
		//
		//		$staff = $this->db->fetchRow("SELECT * FROM ".TABLE_PREFIX."staff WHERE email='".$this->db->real_escape_string($from_email)."'");
		//
		//		$data = array(
		//			'ticket_id' => $ticket['id'],
		//			'date' => $datenow,
		//			'message' => $text,
		//			'ip' => $from_email,
		//			'customer' => 0,
		//			'name' => $staff['fullname']
		//		);
		//		$this->db->insert(TABLE_PREFIX."tickets_messages", $data);
		//		$message_id = $this->db->lastInsertId();
		////		if($ticket['status'] == '5' || $ticket['status'] == '2'){
		//			$status_name = $LANG['IN_PROGRESS'];
		//			$addquery = ", status='4'";
		////		}else{
		////			$status_name = $ticket_status[$ticket['status']];
		////		}
		//		$this->db->query("UPDATE ".TABLE_PREFIX."tickets SET last_update=".$datenow.", replies=replies+1, last_replier='{$ticket['fullname']}' {$addquery} WHERE id={$ticket['id']}");
		//		$this->db->update(TABLE_PREFIX."tickets", $data, "id={$tdetails['id']}");
		//		if(is_array($attachments)){
		//			$save_dir = UPLOAD_DIR;
		//			foreach($attachments as $attachment) {
		//				// get the attachment name
		//				$filename = $attachment->filename;
		//				// write the file to the directory you want to save it in
		//				if ($fp = fopen($save_dir.$filename, 'w')) {
		//					while($bytes = $attachment->read()) {
		//						fwrite($fp, $bytes);
		//					}
		//					fclose($fp);
		//				}
		//
		//				$filesize = @filesize(UPLOAD_DIR.$filename);
		//				if($filesize){
		//					$fileinfo = array('name' => $filename, 'size' => $filesize);
		//					$fileverification = verifyAttachment($fileinfo);
		//					if($fileverification['msg_code'] == 0){
		//						$ext = pathinfo($filename, PATHINFO_EXTENSION);
		//						$filename_encoded = md5($filename.time()).".".$ext;
		//						$data = array('name' => $filename, 'enc' => $filename_encoded, 'filesize' => $filesize, 'ticket_id' => $ticket['id'], 'msg_id' => $message_id, 'filetype' => $attachment->content_type);
		//						$this->db->insert(TABLE_PREFIX."attachments", $data);
		//						rename(UPLOAD_DIR.$filename, UPLOAD_DIR.'tickets/'.$filename_encoded);
		//					}else{
		//						unlink(UPLOAD_DIR.$filename);
		//					}
		//				}
		//			}
		//		}
		//		/* Mailer */
		//		$department_name = $this->db->fetchOne("SELECT name FROM ".TABLE_PREFIX."departments WHERE id={$ticket['department_id']}");
		//		$priority_name = $this->db->fetchOne("SELECT name FROM ".TABLE_PREFIX."priority WHERE id={$ticket['priority_id']}");
		//		$data_mail = array(
		//			'id' => 'staff_reply',
		//			'to' => $ticket['fullname'],
		//			'to_mail' => $ticket['email'],
		//			'vars' => array(
		//				'%client_name%' => $ticket['fullname'],
		//				'%client_email%' => $ticket['email'],
		//				'%ticket_id%' => $ticket['code'],
		//				'%ticket_subject%' => $ticket['subject'],
		//				'%ticket_department%' => $department_name,
		//				'%ticket_status%' => $status_name,
		//				'%ticket_priority%' => $priority_name,
		//				'%message%' => $text."\n\n".$staff['signature'],
		//			),
		//		);
		//		$mailer = new Mailer($data_mail);
		//	}

		}
	}
}
