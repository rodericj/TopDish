<?php
class Model_DbTable_DishesComplete extends Zend_Db_Table_Abstract
{
    protected $_name = 'dish_complete';
    protected $_primary = 'dish_id';
    
    protected $_referenceMap    = array(
        'Category' => array(
            'columns'           => 'fooditem_id',
            'refTableClass'     => 'Model_DbTable_FoodItems',
            'refColumns'        => 'id'
        ),
        'Review' => array(
        	'columns'			=> 'dish_id',
        	'refTableClass'		=> 'Model_DbTable_Reviews',
        	'refColumns'		=> 'dish_id'
        ),
        'Restaurant' => array(
        	'columns'			=> 'rest_id',
        	'refTableClass'		=> 'Model_DbTable_Restaurants',
        	'refColumns'		=> 'id'
        ),
    );
    
    public function getDish($id) 
    {
        $id = (int)$id;
        $row = $this->fetchRow('dish_id = ' . $id);
        if (!$row) {
            throw new Exception("Count not find row $id");
        }
        return $row->toArray();    
    }
}