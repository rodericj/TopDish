<?php
class Model_DbTable_Reviews extends Zend_Db_Table_Abstract
{
    protected $_name = 'reviews';
    protected $_referenceMap    = array(
        'User' => array(
            'columns'           => 'user_id',
            'refTableClass'     => 'Model_DbTable_Users',
            'refColumns'        => 'id'
        ),
        'Dish' => array(
        	'columns'			=> 'dish_id',
        	'refTableClass'		=> 'Model_DbTable_Dishes',
        	'refColumns'		=> 'id'
        )
    );
    
    public function getReview($id) 
    {
        $id = (int)$id;
        $row = $this->fetchRow('id = ' . $id);
        if (!$row) {
            throw new Exception("Count not find row $id");
        }
        return $row->toArray();    
    }
    
    public function addReview($userID, $dishID, $rating, $comments)
    {
        $data = array(
            'user_id' => $userID,
        	'dish_id' => $dishID,
        	'rating' => $rating,
        	'comments' => $comments
        );
        $this->insert($data);
    }
    
    public function updateReview($id, $userID, $dishID, $rating, $comments)
    {
        $data = array(
            'user_id' => $userID,
        	'dish_id' => $dishID,
        	'rating' => $rating,
        	'comments' => $comments
        );
        $this->update($data, 'id = '. (int)$id);
    }
    
    public function deleteReview($id)
    {
        $this->delete('id =' . (int)$id);
    }
}