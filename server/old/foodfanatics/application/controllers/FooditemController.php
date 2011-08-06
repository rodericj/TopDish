<?php

class FooditemController extends Zend_Controller_Action
{

    public function init()
    {

    }

    public function indexAction()
    {
        $this->view->title = "Food Categories";
        $this->view->headTitle($this->view->title, 'PREPEND');
        $fooditems = new Model_DbTable_FoodItems();
        $this->view->fooditems = $fooditems->fetchAll();
    }

    public function addAction()
    {
    	$id = $this->_getParam('id', 0);
        $this->view->title = "Add new food category";
        $this->view->headTitle($this->view->title, 'PREPEND');
        $form = new Form_Fooditem();
        $form->getElement('cuisine_id')->setValue($this->_request->getParam('id'));
        $form->submit->setLabel('Add');
        $this->view->form = $form;
                            
        if ($this->getRequest()->isPost()) {
        	$formData = $this->getRequest()->getPost();
        	if ($form->isValid($formData)) {
        		$name = $form->getValue('name');
				$note = $form->getValue('note');
				$cuisineID = $form->getValue('cuisine_id');
				$fooditems = new Model_DbTable_FoodItems();
				$fooditems->addFooditem($name, $note, $cuisineID);
				$this->_redirect('/fooditem/bycuisine/id/' . $id);
                        
			} else {
				$form->populate($formData);
			}
    	}
    }

    public function editAction()
    {
        $this->view->title = "Edit food category";
        $this->view->headTitle($this->view->title, 'PREPEND');
                        
		$form = new Form_Fooditem();
		$form->submit->setLabel('Save');
		$this->view->form = $form;
                        
		if ($this->getRequest()->isPost()) {
			$formData = $this->getRequest()->getPost();
			if ($form->isValid($formData)) {
				$id = (int)$form->getValue('id');
				$name = $form->getValue('name');
				$note = $form->getValue('note');
				$fooditems = new Model_DbTable_FoodItems();
				$fooditems->updateFooditem($id, $name, $note);
                                
				$this->_redirect('/fooditem');
			} else {
				$form->populate($formData);
			}
		}else {
			$id = $this->_getParam('id', 0);
			if ($id > 0) {
				$fooditems = new Model_DbTable_FoodItems();
				$form->populate($fooditems->getFooditem($id));
			}
		}
    }

    public function deleteAction()
    {
        $this->view->title = "Delete food category";
		$this->view->headTitle($this->view->title, 'PREPEND');
                        
		if ($this->getRequest()->isPost()) {
			$del = $this->getRequest()->getPost('del');
			if ($del == 'Yes') { 
				$id = $this->getRequest()->getPost('id');
				$fooditems = new Model_DbTable_FoodItems();
				$fooditems->deleteFooditem($id);
			}
		$this->_redirect('/fooditem');
		} else {
			$id = $this->_getParam('id', 0);
			$fooditems = new Model_DbTable_FoodItems();
			$this->view->fooditem = $fooditems->getFooditem($id);
		}
    }

    public function showdishesAction()
    {
        $id = $this->_getParam('id', 0);
		if($id > 0){
	        //show dishes in this category
            
			$fooditems = new Model_DbTable_FoodItems();
            $itemsRowset = $fooditems->find($id);
            $thisCategory = $itemsRowset->current();
            
            $catname = $thisCategory["name"];
            $this->view->catname = $catname;
            $this->view->title = "{$catname}s Found:";
            $this->view->headTitle($this->view->title, 'PREPEND');
            
            $dishesFound = $thisCategory->findModel_DbTable_DishesByCategory();
            $restaurants = new Model_DbTable_Restaurants();
            $foundRest = array();
            
            foreach($dishesFound as $dish){
	            $restRowset = $restaurants->find($dish["restaurant_id"]);
	            $curRest = $restRowset->current();
	            $foundRest[$curRest["id"]] = $curRest["name"];
	            //TODO: this should be replaced with a JOIN for more efficiency
            }
            $this->view->dishes = $dishesFound;
            $this->view->restaurants = $foundRest;
    	}
    }

    public function bycuisineAction()
    {
        $id = $this->_getParam('id',0);
        if($id > 0){
            //show food categories from this cuisine id
            $cuisines =  new Model_DbTable_Cuisines();
            $itemsRowset = $cuisines->find($id);
            $thisCuisine = $itemsRowset->current();
            
            $cuisineName = $thisCuisine['name'];
            $this->view->cuisineName = $cuisineName;
            $this->view->title = "{$cuisineName}";
            $this->view->headTitle($this->view->title, 'PREPEND');
            
            //$select = $fooditems->select() ->order('name DESC');
            $categoriesFound = $thisCuisine->findDependentRowset('Model_DbTable_FoodItems', 'Cuisine');//, $select);
        
            $this->view->categories = $categoriesFound;
    	}
    }
}

