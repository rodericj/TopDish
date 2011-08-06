<?php
class Model_DbTable_Cuisines extends Zend_Db_Table_Abstract
{
    protected $_name = 'cuisines';
    
    protected $_referenceMap    = array(
        'Category' => array(
            'columns'           => 'cuisine_id',
            'refTableClass'     => 'Model_DbTable_FoodItems',
            'refColumns'        => 'id'
        )
    );
    
    
    public function getCuisine($id)
    {
        $id = (int)$id;
        $row = $this->fetchRow('id = ' . $id);
        if (!$row) {
            throw new Exception("Count not find row $id");
        }
        return $row->toArray();    
    }
    
    public function addCuisine($name)
    {
        $data = array(
            'name' => $name
        );
        $this->insert($data);
    }
    
    public function updateCuisine($id, $name)
    {
        $data = array(
            'name' => $name
        );
        $this->update($data, 'id = '. (int)$id);
    }
    
    public function deleteCuisine($id)
    {
        $this->delete('id =' . (int)$id);
    }
}