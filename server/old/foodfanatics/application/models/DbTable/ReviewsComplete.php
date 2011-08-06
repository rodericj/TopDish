<?php
class Model_DbTable_ReviewsComplete extends Zend_Db_Table_Abstract
{
    protected $_name = 'review_complete';
    protected $_primary = 'id';
    
    protected $_referenceMap    = array(
        'Dish' => array(
            'columns'           => 'dish_id',
            'refTableClass'     => 'Model_DbTable_Dishes',
            'refColumns'        => 'id'
        ),
        'User' => array(
        	'columns'			=> 'user_id',
        	'refTableClass'		=> 'Model_DbTable_Users',
        	'refColumns'		=> 'id'
        )
    );
    
    public function getReview($id) 
    {
        $id = (int)$id;
        $row = $this->fetchRow('dish_id = ' . $id);
        if (!$row) {
            throw new Exception("Count not find row $id");
        }
        return $row->toArray();    
    }
}