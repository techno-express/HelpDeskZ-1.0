<?php

class Ticket {

  public function __contruct() {

  }

  public static function generateId($variable) {

    //Original. Now sha256 instead of sha1
    $ticket_id = substr(strtoupper(hash('sha256', microtime().$variable)), 0, 11);
		$ticket_id = substr_replace($ticket_id, '-',3,0);
		$ticket_id = substr_replace($ticket_id, '-',7,0);

    // What about: OJK-235298

    //TODO: Check if the ticket exists already? It could technically not be that unique. Performance issue.
    // $db = new DB;
    // SELECT `code` FROM `{{prefix}}tickets` WHERE `code` = :code" --> if result --> return self::createId($variable);

    return $ticket_id;
  }

  public static function isTicket($subject) {
    if(preg_match("/\#[[a-zA-Z0-9_]+\-[a-zA-Z0-9_]+\-[a-zA-Z0-9_]+\]/", $subject, $regs)) {
      $ticket_id = trim(preg_replace("/\[/", "", $regs[0]));
  		$ticket_id = trim(preg_replace("/\]/", "", $ticket_id));
  		$ticket_id = str_replace("#", "", $ticket_id);

      //TODO: Check if the ticket exists in the DB? It could technically not be OUR ticket ID. Performance issue.
      // $db = new DB;
      // SELECT `code` FROM `{{prefix}}tickets` WHERE `code` = :code" --> if !result --> return false;
      return $ticket_id;
    }
    return false;
  }
}
