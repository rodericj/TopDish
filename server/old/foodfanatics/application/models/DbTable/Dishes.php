<?php
class Model_DbTable_Dishes extends Zend_Db_Table_Abstract
{
    protected $_name = 'dishes';
    
    protected $_referenceMap    = array(
        'Category' => array(
            'columns'           => 'fooditem_id',
            'refTableClass'     => 'Model_DbTable_FoodItems',
            'refColumns'        => 'id'
        ),
        'Restaurant' => array(
        	'columns'			=> 'restaurant_id',
        	'refTableClass'		=> 'Model_DbTable_Restaurants',
        	'refColumns'		=> 'id'
        ),
        'Review' => array(
        	'columns'			=> 'id',
        	'refTableClass'		=> 'Model_DbTable_Reviews',
        	'refColumns'		=> 'dish_id'
        )
    );
    
    public function getDish($id)
    {
        $id = (int)$id;
        $row = $this->fetchRow('id = ' . $id);
        if (!$row) {
            throw new Exception("Count not find row $id");
        }
        return $row->toArray();    
    }
    
    public function addDish($name, $restaurantID, $fooditemID)
    {
        $data = array(
            'name' => $name,
        	'restaurant_id' => $restaurantID,
        	'fooditem_id' => $fooditemID
        );
        $this->insert($data);
    }
    
    public function updateDish($id, $name, $restaurantID, $fooditemID)
    {
        $data = array(
            'name' => $name,
        	'restaurant_id' => $restaurantID,
        	'fooditem_id' => $fooditemID
        );
        $this->update($data, 'id = '. (int)$id);
    }
    
    public function deleteDish($id)
    {
        $this->delete('id =' . (int)$id);
    }
}