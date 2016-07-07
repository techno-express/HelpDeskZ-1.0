<?php

class Ticket {

  public static function generateId($variable) {

    //Original. Now sha256 instead of sha1
    $ticket_id = substr(strtoupper(hash('sha256', microtime().$variable)), 0, 11);
		$ticket_id = substr_replace($ticket_id, '-',3,0);
		$ticket_id = substr_replace($ticket_id, '-',7,0);

    //TODO: What about: 'OJK-235298' ?

    if(CONF_DB_TYPE == 'mysqli'){
      $db = new MySQLIDB();
    }
    elseif(CONF_DB_TYPE == 'PDO'){
      $db = new PDODB;
    }
    else{
      exit("No valid DB connection type found?");
    }
    $db->connect(CONF_DB_DATABASE, CONF_DB_HOST, CONF_DB_USERNAME, CONF_DB_PASSWORD);

    //Check if the ticket exists already? It could technically not be that unique. Performance issue.
    $result = $db->fetchOne("SELECT `code` FROM `".TABLE_PREFIX."tickets` WHERE `code` = '".$ticket_id."'");
    if($result != null) {
      return $this->generateId($variable);
    }
    return $ticket_id;
  }

  public static function isTicket($subject) {
    if(preg_match("/\#[[a-zA-Z0-9_]+\-[a-zA-Z0-9_]+\-[a-zA-Z0-9_]+\]/", $subject, $regs)) {
      $ticket_id = trim(preg_replace("/\[/", "", $regs[0]));
  		$ticket_id = trim(preg_replace("/\]/", "", $ticket_id));
  		$ticket_id = str_replace("#", "", $ticket_id);

      if(CONF_DB_TYPE == 'mysqli'){
        $db = new MySQLIDB();
      }
      elseif(CONF_DB_TYPE == 'PDO'){
        $db = new PDODB;
      }
      else{
        exit("No valid DB connection type found?");
      }
      $db->connect(CONF_DB_DATABASE, CONF_DB_HOST, CONF_DB_USERNAME, CONF_DB_PASSWORD);

      //Check if the ticket exists in the DB? It could technically not be OUR ticket ID. Performance issue.
      $result = $db->fetchOne("SELECT `code` FROM `".TABLE_PREFIX."tickets` WHERE `code` = '".$ticket_id."'");
      if($result == null) {
        //Ticket ID wasn't found:
        return false;
      }
      return $ticket_id;
    }
    return false;
  }
}
