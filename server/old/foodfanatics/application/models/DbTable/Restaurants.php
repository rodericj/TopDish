<?php
class Model_DbTable_Restaurants extends Zend_Db_Table_Abstract
{
    protected $_name = 'restaurants';
    protected $_dependentTables = array('Model_DbTable_Dishes');
    
    public function getRestaurant($id) 
    {
        $id = (int)$id;
        $row = $this->fetchRow('id = ' . $id);
        if (!$row) {
            throw new Exception("Count not find row $id");
        }
        return $row->toArray();    
    }
    
    public function addRestaurant($name, $street, $city, $state, $zip, $phone)
    {
        $data = array(
            'name' => $name,
        	'street' => $street,
        	'city' => $city,
        	'state' => $state,
        	'zip' => $zip,
        	'phone' => $phone
        );
        $this->insert($data);
    }
    
    public function updateRestaurant($id, $name, $street, $city, $state, $zip, $phone)
    {
        $data = array(
            'name' => $name,
            'street' => $street,
        	'city' => $city,
        	'state' => $state,
        	'zip' => $zip,
        	'phone' => $phone
        );
        $this->update($data, 'id = '. (int)$id);
    }
    
    public function deleteRestaurant($id)
    {
        $this->delete('id =' . (int)$id);
    }
}