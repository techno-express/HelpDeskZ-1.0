<?php
//Calling the autoload function
require_once "PhpImap/__autoload.php";
use PhpImap\Mailbox as ImapMailbox;
use PhpImap\IncomingMail;
use PhpImap\IncomingMailAttachment;

include "Mail/mime.php";

/* Connect to imap folder (gmail already configured) */
$hostname = '{imap.gmail.com:993/imap/ssl}INBOX';
$username = '<username>@gmail.com';
$password = '<password>';

echo "\n";
$mailbox = new PhpImap\Mailbox($hostname, $username, $password);

//$mailsIds = $mailbox->searchMailbox('ALL');
$mailsIds = $mailbox->searchMailbox('UNSEEN');
if(!$mailsIds) {
	echo 0;
	die('Mailbox is empty');
}else{
    $descriptorspec = array(
        0 => array("pipe", "r"),  // stdin is a pipe that the child will read from
        1 => array("pipe", "w"),  // stdout is a pipe that the child will write to
        2 => array("file", dirname(__FILE__)."/mailerror.txt", "a") // stderr is a file to write to
     );
    for($countmail=0;$countmail<count($mailsIds);$countmail++){
        $mail = $mailbox->getRawMail($mailsIds[$countmail]);
        $process = proc_open('php -f '.dirname(__FILE__).'/pipe.php',$descriptorspec,$pipes);
	echo $mail;
        fwrite($pipes[0],$mail);
        fclose($pipes[0]);
        echo stream_get_contents($pipes[1]);        //Stampa il contenuto generato da pipe.php
        fclose($pipes[1]);
        $mailbox->markMailAsRead($mailsIds[$countmail]);
        $return_value = proc_close($process);
        echo "command returned $return_value\n";
    }
    echo count($mailsIds);
    echo "\n";
}
?>
