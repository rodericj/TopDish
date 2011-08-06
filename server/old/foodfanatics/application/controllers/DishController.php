<?php

class DishController extends Zend_Controller_Action
{

    public function init()
    {
    	
    }

    public function indexAction()
    {
        $this->view->title = "Dishes";
		$this->view->headTitle($this->view->title, 'PREPEND');
		$dishes = new Model_DbTable_Dishes();
		$this->view->dishes = $dishes->fetchAll();
    }

    public function addAction()
    {
        $restID = $this->_getParam('rest_id', 0);
        $fooditems = new Model_DbTable_FoodItems();
        $categories = $fooditems->fetchAll();
        $cat_list = array();
        foreach($categories as $cat){
        	$cat_list[$cat['id']] = $cat['name'];
        }
        
        $restaurants = new Model_DbTable_Restaurants();
        $itemsRowset = $restaurants->find($restID);
        $thisRest = $itemsRowset->current();
        $restName = $thisRest['name'];
        
        $this->view->title = "Add new dish at " . $restName;
        $this->view->headTitle($this->view->title, 'PREPEND');
                        
        $options = array('restID' => $restID, 'fooditems' => $cat_list);
        $form = new Form_Dish($options);
        $form->submit->setLabel('Add');
        $this->view->form = $form;
                            
        if ($this->getRequest()->isPost()) {
        	$formData = $this->getRequest()->getPost();
        	if ($form->isValid($formData)) {
        		$name = $form->getValue('name');
        		$restaurantID = $form->getValue('restaurantID');
        		$fooditemID = $form->getValue('fooditemID');
        		$dishes = new Model_DbTable_Dishes();
                        $dishes->addDish($name, $restaurantID, $fooditemID);
                                
                        $id = $this->_getParam('id', 0);
                        if($id > 0)
                        $this->_redirect('/fooditem/showdishes/id/' . $id);
        		else
                        $this->_redirect('/dish');
        	} else {
        		$form->populate($formData);
        	}
    	}
    }

    public function editAction()
    {
        $this->view->title = "Edit dish";
        $this->view->headTitle($this->view->title, 'PREPEND');
                        
		$form = new Form_Dish();
		$form->submit->setLabel('Save');
		$this->view->form = $form;
                        
		if ($this->getRequest()->isPost()) {
			$formData = $this->getRequest()->getPost();
			if ($form->isValid($formData)) {
				$id = (int)$form->getValue('id');
				$name = $form->getValue('name');
				$restaurantID = $form->getValue('restaurantID');
				$fooditemID = $form->getValue('fooditemID');
				$dishes = new Model_DbTable_Dishes();
				$dishes->updateDish($id,$name,$restaurantID, $fooditemID);
                                
				$this->_redirect('/dish');
			} else {
				$form->populate($formData);
			}
        } else {
        	$id = $this->_getParam('id', 0);
			if ($id > 0) {
				$dishes = new Model_DbTable_Dishes();
				$form->populate($dishes->getDish($id));
        	}
    	}
    }

    public function deleteAction()
    {
        $this->view->title = "Delete dish";
        $this->view->headTitle($this->view->title, 'PREPEND');
                        
        if ($this->getRequest()->isPost()) {
        	$del = $this->getRequest()->getPost('del');
        	if ($del == 'Yes') { 
        		$id = $this->getRequest()->getPost('id');
        		$dishes = new Model_DbTable_Dishes();
        		$dishes->deleteDish($id);
        	
        		$this->_redirect('/dish');
        	} else {
        		$id = $this->_getParam('id', 0);
        		$dishes = new Model_DbTable_Dishes();
        		$this->view->dish = $dishes->getDish($id);
            }
    	}
    }

    public function bycategoryAction()
    {
        $id = $this->_getParam('cat_id',0);
        if($id > 0){
            //show dishes from this category id
            $fooditems = new Model_DbTable_FoodItems();
            $itemsRowset = $fooditems->find($id);
            $thisCategory = $itemsRowset->current();
            $categoryID = $thisCategory['id'];
            
            $cuisineID = $thisCategory['cuisine_id'];
            $cuisines = new Model_DbTable_Cuisines();
            $itemsRowset = $cuisines->find($cuisineID);
            $thisCuisine = $itemsRowset->current();
            
            $categoryName = $thisCategory['name'];
            $cuisineName = $thisCuisine['name'];
            
            $this->view->catname = $categoryName;
            $this->view->catID = $categoryID;
            $this->view->title = "{$cuisineName}: {$categoryName}";
            $this->view->headTitle("{$categoryName}", 'PREPEND');
            
            $select = $fooditems->select() ->order('total_rating DESC');
            $dishesFound = $thisCategory->findDependentRowset('Model_DbTable_DishesComplete', 'Category', $select);
        
            $this->view->dishes = $dishesFound;
    	}
    }

    public function detailAction()
    {
		$id = $this->_getParam('id',0);
        if($id > 0){
            //show detailed view of this dish, its rating, and restaurant
            $dishesC = new Model_DbTable_DishesComplete();
            $itemsRowset = $dishesC->find($id);
            $thisDishC = $itemsRowset->current();
            $this->view->dish = $thisDishC;
            
            $restaurants = new Model_DbTable_Restaurants();
            $itemsRowset = $restaurants->find($thisDishC['rest_id']);
            $thisRest = $itemsRowset->current();
            $this->view->restaurant = $thisRest;
            
            $dishName = $thisDishC['dish_name'];
            $categoryID = $thisDishC['fooditem_id'];
            
            $fooditems = new Model_DbTable_FoodItems();
            $itemsRowset = $fooditems->find($categoryID);
            $thisCategory = $itemsRowset->current();
            
            $cuisineID = $thisCategory['cuisine_id'];
            $cuisines = new Model_DbTable_Cuisines();
            $itemsRowset = $cuisines->find($cuisineID);
            $thisCuisine = $itemsRowset->current();
            
            $categoryName = $thisCategory['name'];
            $cuisineName = $thisCuisine['name'];
            
            $this->view->title = "{$cuisineName}: {$categoryName}: {$dishName}";
            $this->view->headTitle("{$dishName}", 'PREPEND');
            
            $dishes = new Model_DbTable_Dishes();
            $itemsRowset = $dishes->find($id);
            $thisDish = $itemsRowset->current();
            
            $foundReviews = $thisDish->findDependentRowset('Model_DbTable_ReviewsComplete', 'Dish');
            $this->view->reviews = $foundReviews;
    	}
    }
    
    public function topratedAction(){
    	//$this->view->title = "Top 10 Dishes";
    	$this->view->headTitle("Top 10 Dishes", 'PREPEND');
    	
    	$dishes = new Model_DbTable_DishesComplete();
    	$rows = $dishes->fetchAll(
    			$dishes->select()
    					->order('total_rating DESC')
    					->limit(10,0)
    			);
		$this->view->dishes = $rows;
    }
    
    public function newadditionsAction(){
    	$this->view->title = "Newest Additions";
    	$this->view->headTitle("Newest Additions", 'PREPEND');
    	
    	$dishes = new Model_DbTable_DishesComplete();
    	$rows = $dishes->fetchAll(
    			$dishes->select()
    					->order('date_created DESC')
    					->limit(10,0)
    			);
		$this->view->dishes = $rows;
    }
    
    public function byrestaurantAction(){
        $id = $this->_getParam('rest_id',0);
        if($id > 0){
            //show dishes from this restaurant id
            $restaurants = new Model_DbTable_Restaurants();
            $itemsRowset = $restaurants->find($id);
            $thisRest = $itemsRowset->current();
            $restName = $thisRest['name'];
            $restID = $thisRest['id'];
            
            $this->view->restaurant_id = $restID;
            $this->view->title = "Dishes at {$restName}";
            $this->view->headTitle("{$restName}", 'PREPEND');
            
            $dishes = new Model_DbTable_DishesComplete();
            $dishesFound = $thisRest->findDependentRowset('Model_DbTable_DishesComplete', 'Restaurant');
        
            $this->view->dishes = $dishesFound;
    	}
    }
}

