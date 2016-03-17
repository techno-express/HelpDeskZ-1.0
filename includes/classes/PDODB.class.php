<?php

class PDODB {

	protected $oDb_connection; //DB Connectie Object
	protected $sqlError = ''; //String with SQL error (connectie of SELECT/INSERT fout)
	protected $sqlResult = array(); //array with result from fetchall()
	protected $insertedId; //ID of row (if there's a key/autoincrement in the tabel) with the last insert query
	protected $rows_affected = 0; //not really in use, maybe in future?
	protected $statement;
	protected $cantConnect = 0;

	//DB credentials
	protected $database_name;
	protected $user_name;
	protected $password;
	protected $host;

	//Query
	protected $sqlstring = '';
	protected $args = array();

	/**
	 * Constructor.
	 *
	 * @access public
	 * @param mixed $dbname (default: null)
	 * @param mixed $username (default: null)
	 * @param mixed $password (default: null)
	 * @param mixed $hostname (default: null)
	 * @return void
	 */
	public function __construct($dbname = null, $username = null, $password = null, $hostname = null) {
		$this->database_name = is_null($dbname) ? CONF_DB_DATABASE : $dbname;
		$this->user_name = is_null($username) ? CONF_DB_USERNAME : $username;
		$this->password = is_null($password) ? CONF_DB_PASSWORD : $password;
		$this->host = is_null($hostname) ? CONF_DB_HOST : $hostname;
		$this->dbconn();
	}

	/**
	 * Destructor. Closes the DB connection.
	 *
	 * @access public
	 * @return void
	 */
	public function __destruct() {
		$this->closeDBConnection();
	}

	/**
	 * Gets the error as a array
	 *
	 * @access public
	 * @return array
	 */
	public function getError() {
		if( is_array($this->sqlError) ) {
			return implode(',',$this->sqlError);
		}
		else {
			return $this->sqlError;
		}
	}

	/**
	 * Sets the mysql error. .
	 *
	 * @access private
	 * @param mixed $error
	 * @param mixed $sqlquery (default: null)
	 * @return void
	 */
	private function setSqlError($error, $sqlquery = null) {
		if( !is_array($error) ){
			$error_string = $error;
			$error = array();
			$error[0] = 'DB000';
			$error[1] = 9001;
			$error[2] = $error_string;
		}
		if($sqlquery != null) {
			$error['query'] = $sqlquery;
		}
		if( ($error[0] == 'HY093') && ($error[1] == '') ) {
			$error[2] = 'Invalid parameter number: number of bound variables does not match number of tokens';
			$strace = debug_backtrace();
			$strace2 = $strace[1];
			unset($strace);
			$error['strace']['file'] = $strace2['file'];
			$error['strace']['line'] = $strace2['line'];
			$error['strace']['function'] = $strace2['function'];
			$error['strace']['class'] = $strace2['class'];
		}
		if(isset($this->args)) {
			$error['args'] = print_r($this->args,true);
		}
/*
			if (strpos($error,"Can't connect to MySQL server on") !== false) {
				$this->closeDBConnection();
				sleep(3);
				//Geen connectie
				$this->cantConnect++;
				if( $this->cantConnect > 5 ) {
					sleep(60);
					die();
				}
			}
	*/
		$this->sqlError = $error;
	}

	/**
	 * Fetch request for direct result from the Database.
	 *
	 * @access public
	 * @return array
	 */
	public function fetch() {
			return $this->statement->fetch();
	}

	/**
	 * Returns how many rows were affected with the last query
	 *
	 * @access public
	 * @return int
	 */
	public function getRowsAffected() {
		return $this->rows_affected;
	}

	/**
	 * Gets SQL result count.
	 *
	 * @access public
	 * @param bool $one_result (default: false) if you expect only one result.
	 * @return int
	 */
	public function getResultCount($one_result = false) {
		if(!$one_result) {
			return count($this->sqlResult); //can have multiple arrays
		}
		else {
			if(isset($this->sqlResult[0])) {
				return count($this->sqlResult[0]); //Just 1 array
			}
			else {
				return 0; //empty
			}
		}
	}

	/**
	 * Gets SQL result in array form.
	 *
	 * @access public
	 * @param bool $one_result (default: false) if you expect only one result.
	 * @return array
	 */
	public function getResult($one_result = false) {
		if(!$one_result) {
			return $this->sqlResult; //can have multiple arrays
		}
		else {
			if(isset($this->sqlResult[0])) {
				return $this->sqlResult[0]; //Just 1 array
			}
			else {
				return array(); //empty
			}
		}
	}

	/**
	 * Sets the result into $sqlresult
	 *
	 * @access private
	 * @param array $sqlresult
	 * @return void
	 */
	private function setSqlResult($sqlresult) {
		//$sqlresult = $this->integrify($sqlresult);
		$this->sqlResult = $sqlresult;
	}

	/**
	 * Alias for dbconn(). Connects to the DB
	 *
	 * @access public
	 * @return boolean
	 */
	public function connect() {
		return $this->dbconn();
	}

	/**
	 * Connects to the DB. returns true/false if it can connect and sets error if false.
	 *
	 * @access public
	 * @return boolean
	 */
	public function dbconn() {
		if ($this->oDb_connection) {
			return $this->oDb_connection;
		}
		else {
			try {
				if( $this->database_name == 'false' ) {
					$this->oDb_connection = new PDO('mysql:host='.$this->host,$this->user_name,$this->password,
          	array(
	          	PDO::MYSQL_ATTR_INIT_COMMAND => 'SET NAMES utf8',
							PDO::ATTR_PERSISTENT => false, //True = bug = MySQL server has gone away....
							//PDO::ATTR_EMULATE_PREPARES => false,
							//PDO::ATTR_TIMEOUT => 5 //seconds
						)
					);
					//$this->oDb_connection->setAttribute(PDO::ATTR_ORACLE_NULLS, PDO::NULL_EMPTY_STRING); // Empty string is converted to NULL.
				}
				else {
					$this->oDb_connection = new PDO('mysql:dbname='.$this->database_name.';host='.$this->host,$this->user_name,$this->password,
						array(
							PDO::MYSQL_ATTR_INIT_COMMAND => 'SET NAMES utf8',
							PDO::ATTR_PERSISTENT => false, //True = bug = MySQL server has gone away....
							//PDO::ATTR_EMULATE_PREPARES => false,
							//PDO::ATTR_TIMEOUT => 5 //seconds
							)
					);
					//$this->oDb_connection->setAttribute(PDO::ATTR_ORACLE_NULLS, PDO::NULL_EMPTY_STRING); // Empty string is converted to NULL.
				}
				return $this->oDb_connection;
			}
			catch(\Exception $e) {
				$this->setSqlError($e->getMessage());
				$this->oDb_connection = null;
				return false;
			}
			catch (\PDOException $e) {
				$this->setSqlError($e->getMessage());
				$this->oDb_connection = null;
				return false;
			}
		}
	}

	/**
	 * Do something with the query string + arguments. Log them to a file or echo them.
	 *
	 * @access private
	 * @param string $sqlstring
	 * @param array $args
	 * @return void
	 */
	private function logSQLDebug($sqlstring,$args) {
		$this->sqlstring = $sqlstring;
		$this->args = $args;
	}

	/**
	 * Use this function to prepare your query. Fetch it with fetch()
	 *
	 * @access public
	 * @param string $sqlstring
	 * @param array $arg (default: null)
	 * @return boolean
	 */
	public function prepareQuery($sqlstring,$arg = null) {
		$this->logSQLDebug($sqlstring,$arg);

		$this->statement = $this->oDb_connection->prepare($sqlstring);
		$this->statement->setFetchMode(PDO::FETCH_ASSOC); //associated array. (Named array)

		if($this->statement->execute($arg)) {
			return true;
		}
		else {
			$this->setSqlError($this->statement->errorInfo(), $this->statement->queryString);
			$this->setSqlResult( array() );
			return false;
		}
	}

	/**
	 * Get the primary key of the insert query
	 *
	 * @access public
	 * @return mixed (string/int, depending on what the primary key is)
	 */
	public function getLastInsertedId() {
		if(is_int($this->insertedId)) {
			return intval($this->insertedId);
		}
		else {
			return $this->insertedId;
		}
	}

	/**
	 * getRows function.
	 *
	 * @access public
	 * @return void
	 */
	public function getRows() {
		return $statement->fetch(PDO::FETCH_NUM);
	}

	/**
	 * selectDbQuery function. Alias for just query()
	 *
	 * @access public
	 * @param string $sqlstring
	 * @param array $arg (default: null)
	 * @return boolean
	 */
	public function selectQuery($sqlstring,$arg = null) {
		//Er kan memcached ingebouwd worden. md5 string van query + arg --> 1min cache?
		return $this->query($sqlstring, $arg);
	}

	/**
	 * insertDbQuery function. Alias for just query()
	 *
	 * @access public
	 * @param string $sqlstring
	 * @param array $arg (default: null)
	 * @return boolean
	 */
	public function insertQuery($sqlstring, $arg = null) {
		// https://dev.mysql.com/doc/refman/5.0/en/insert-on-duplicate.html
		return $this->query($sqlstring, $arg);
	}

	/**
	 * updateQuery function. Builds a query with just tablename, arguments, where.
	 *
	 * @access public
	 * @param string $table
	 * @param array $arg (default: array)
	 * @param array $where (default: array)
	 * @return boolean
	 */
	public function updateQuery($table, $args = array(), $where = array(), $condition = 'AND') {
		$sqlstring = 'UPDATE `'.$table.'` SET ';

		$update_args = array();
		$fields = array();
		$where_args = array();

		foreach($args AS $key => $arg) {
			//remove : in case it's used.
			$key = str_replace(':','',$key);
			$fields[] = '`'.$key.'` = :'.$key;
			$update_args[':'.$key] = $arg;
		}
		$sqlstring .= implode(', ', $fields);

		$sqlstring .= ' WHERE ';

		$where_array = array();
		foreach($where AS $key => $arg) {
			$key = str_replace(':','',$key);
			$where_array[] = '`'.$key.'` = :'.$key;
			$where_args[':'.$key] = $arg;
		}
		$sqlstring .= implode(' '.$condition.' ', $where_array);

		$args = array_merge($update_args, $where_args);

		return $this->query($sqlstring, $args);
	}

	/**
	 * Query, returns true/false if it succeeded. Sets result in setSqlResult(), pick it up with getResult()
	 *
	 * @access public
	 * @param string $sqlstring
	 * @param array $arg (default: array())
	 * @param int $connection_count (default: 0) max try of 3x to connect with a "Server has gone away" error
	 * @return boolean
	 */
	public function query($sqlstring, $arg = array(), $connection_count = 0) {
		$this->logSQLDebug($sqlstring,$arg);

		try {
			if(!is_object($this->oDb_connection)) {
				//No connection? Make connection.
				$this->connect();
			}
			if(is_object($this->oDb_connection)) {
				$statement = $this->oDb_connection->prepare($sqlstring);
				$statement->setFetchMode(PDO::FETCH_ASSOC);
				if( $count = $statement->execute($arg) ) {
					$this->rows_affected = $count;
					$this->insertedId = $this->oDb_connection->lastInsertId();
					$this->setSqlResult( $statement->fetchAll() );
					return true;
				}
				else {
					$this->setSqlResult( array() );
					$error = $statement->errorInfo();
					$this->insertedId = null;

					//Check if the error has connection lost (MySQL server has gone away) Try again:
					if( ($error[0] == 'HY000') && ($error[1] == 2006) ) {
						if( $connection_count > 3 ){
							return false;
						}
						else {
							$this->closeDBConnection();
							sleep(0.1);
							$this->dbconn();
							sleep(0.1);
							return $this->query($sqlstring, $arg, $connection_count++);
						}
					}
					else {
						$this->setSqlError($error, $statement->queryString);
					}
					return false;
				}
			}
			else {
				return false;
			}
		}
		catch( \Exception $e) {
			$this->setSqlError($e->getMessage());
			$this->oDb_connection = null;
			return false;
		}
		catch (\PDOException $e) {
			$this->setSqlError($e->getMessage());
			$this->oDb_connection = null;
			return false;
		}
	}

	/**
	 * Closed the database.
	 *
	 * @access public
	 * @return void
	 */
	public function closeDBConnection() {
		$this->oDb_connection = null;
	}

	public function close() {
		$this->closeDBConnection();
	}

	public function disconnect() {
		$this->closeDBConnection();
	}
}


?>
