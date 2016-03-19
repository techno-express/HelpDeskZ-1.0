<?php

class Password {

  public function __contruct() {

  }

  public static function create($password) {
    return hash('sha256', $password . CONF_UNIQUEHASH);
  }

  public static function isEqual($hashed, $plain) {
    if( self::create($plain) == $hashed ) {
      return true;
    }
    return false;
  }
}
