<?php
class Model_DbTable_Users extends Zend_Db_Table_Abstract
{
    protected $_name = 'users';
    
    public function getUser($id) 
    {
        $id = (int)$id;
        $row = $this->fetchRow('id = ' . $id);
        if (!$row) {
            throw new Exception("Count not find row $id");
        }
        return $row->toArray();    
    }
    
    public function addUser($first, $last, $email, $password)
    {
        $data = array(
            'first' => $first,
        	'last' => $last,
        	'email' => $email,
    		'password' => hash('SHA256', $password)
        );
        $this->insert($data);
    }
    
    public function updateUser($id, $first, $last, $email)
    {
        $data = array(
            'first' => $first,
        	'last' => $last,
        	'email' => $email
        );
        $this->update($data, 'id = '. (int)$id);
    }
    
    public function passwordUser($id, $password){
    	$data = array(
    		'password' => hash('SHA256', $password)
    	);
    	$this->update($data, 'id = ' . (int)$id);
    }
    
    public function deleteUser($id)
    {
        $this->delete('id =' . (int)$id);
    }
}