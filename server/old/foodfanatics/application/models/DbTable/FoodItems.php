<?php
class Model_DbTable_FoodItems extends Zend_Db_Table_Abstract
{
    protected $_name = 'fooditems';
    protected $_dependentTables = array('Model_DbTable_Dishes');
    protected $_referenceMap    = array(
        'Cuisine' => array(
            'columns'           => 'cuisine_id',
            'refTableClass'     => 'Model_DbTable_Cuisines',
            'refColumns'        => 'id'
        )
    );
    
    public function getFooditem($id) 
    {
        $id = (int)$id;
        $row = $this->fetchRow('id = ' . $id);
        if (!$row) {
            throw new Exception("Count not find row $id");
        }
        return $row->toArray();    
    }
    
    public function addFooditem($name, $note, $cuisineID)
    {
        $data = array(
            'name' => $name,
            'note' => $note,
        	'cuisine_id' => $cuisineID,
        );
        $this->insert($data);
    }
    
    public function updateFooditem($id, $name, $note, $cuisineID)
    {
        $data = array(
            'name' => $name,
            'note' => $note,
        );
        $this->update($data, 'id = '. (int)$id);
    }
    
    public function deleteFooditem($id)
    {
        $this->delete('id =' . (int)$id);
    }
}