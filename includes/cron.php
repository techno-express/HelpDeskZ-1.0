<?php

ini_set('error_reporting',E_ALL& ~E_NOTICE);

require_once(__DIR__.'/global.php');
include_once(INCLUDES.'language/'.$settings['client_language'].'.php');

if (version_compare(PHP_VERSION, '5.3.0', '<')) {
    echo "This script requires PHP version 5.3.0 or higher to work, sorry.";
    exit(1);
}

require_once(__DIR__.'/vendor/autoload.php');

$imapHost = $settings['imap_host'];
$imapPort = intval($settings['imap_port']);
$imapUsername = $settings['imap_username'];
$imapPassword = $settings['imap_password'];
$processing = $settings['imap_mail_downloader_processaction'];
$processed_folder = $settings['imap_mail_downloader_processaction_folder'];

use Ddeboer\Imap\Server;
$server = new Server(
    $imapHost,
    $imapPort,     // defaults to 993
    '/imap/notls/novalidate-cert'
);

// $connection is instance of \Ddeboer\Imap\Connection
$connection = $server->authenticate($imapUsername, $imapPassword);
$mailboxes = $connection->getMailboxes();
foreach ($mailboxes as $mailbox) {
	printf('Mailbox %s has %s messages', $mailbox->getName(), $mailbox->count());
	echo "\n";
}

$mailbox = $connection->getMailbox('INBOX');

$messages = $mailbox->getMessages();
foreach($messages AS $message) {

	if(!$message->isSeen()) {

		$attachments = $message->keepUnseen()->getAttachments();
		$own_attachments = array();
		foreach ($attachments as $attachment) {
			$filename = $attachment->getFilename();
		  $own_attachments[$filename] = $attachment->getDecodedContent();
		}

	  $attachments = $own_attachments;
    try {
  	  $text = $message->getBodyText();
  	  $html = $message->getBodyHtml();
    }
    catch(Ddeboer\Transcoder\Exception\IllegalCharacterException $e) {
      $text = 'Could not get body. IllegalCharacterException';
      $html = '';
    }
    catch(Ddeboer\Transcoder\Exception\UnsupportedEncodingException $e) {
      $text = 'Could not get body. UnsupportedEncodingException';
      $html = '';
    }
	  foreach( $message->getTo() AS $to_obj ) {
			$to = $to_obj->getMailbox().'@'.$to_obj->getHostname();
		}

	  $from = $message->getFrom();
	  $subject = $message->getSubject();

    $from_name = $from->getName();
    $from_email = $from->getMailbox().'@'.$from->getHostname();;

	  $datenow = time();

		if($processing == 'move') {
	  	$mailbox = $connection->getMailbox('INBOX.' . $processed_folder );
	  	$message->move($mailbox);
	  	$text2 = $message->getBodyText();
			echo $message->getId()." has been moved to INBOX." . $processed_folder."\n";
	  }
		if($processing == 'delete') {
	  	$message->delete();
			echo $message->getId()." has been deleted\n";
		}
  }
  //$mailbox->expunge();

  if($subject){
    if(preg_match("/\#[[a-zA-Z0-9_]+\-[a-zA-Z0-9_]+\-[a-zA-Z0-9_]+\]/", $subject, $regs)) {
      //Existing ticket?
      echo "reply ticket\n";
      //include_once(INCLUDES.'parser/reply_ticket.php');

			require_once(INCLUDES.'parser/replyticket.class.php');
			$replyticket = new replyticket($db, $settings);
			$replyticket->parse(
				$regs,
				$LANG,
				$from_name,
				$from_email,
				$to_email,
				$password,
				$subject,
				$text,
				$attachments
			);

    }
    else {
      //New Ticket
      echo "New ticket\n";
      //include_once(INCLUDES.'parser/new_ticket.php');

			require_once(INCLUDES.'parser/newticket.class.php');
			$newticket = new newticket($db, $settings);
			$newticket->parse(
				$from_name,
				$from_email,
				$to_email,
				$password,
				$subject,
				$text,
				$attachments
			);

    }
	}
	sleep(0.6);
}
if($processing == 'move') {
	$mailbox = $connection->getMailbox('INBOX.' . $processed_folder );
	$mailbox->expunge();
}

$mailbox = $connection->getMailbox('INBOX');
$mailbox->expunge();
