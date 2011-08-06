<?php

class ReviewController extends Zend_Controller_Action
{

    public function init()
    {

    }

    public function indexAction()
    {
    	$this->view->title = "Reviews";
        $this->view->headTitle($this->view->title, 'PREPEND');
        $reviews = new Model_DbTable_ReviewsComplete();
    	$this->view->reviews = $reviews->fetchAll();
    }

    public function addAction()
    {
    	$auth = Zend_Auth::getInstance();
    	$authStorage = $auth->getStorage();
    	$userInfo = $authStorage->read();
    	$userID = $userInfo->id;
    	
    	$id = $this->_getParam('id', 0);
    	$dir = $this->_getParam('dir', 0);
    	
    	$dishes = new Model_DbTable_Dishes();
    	$itemsRowset = $dishes->find($id);
    	$thisDish = $itemsRowset->current();
    	$dishName = $thisDish['name'];
    		
    	$restaurants = new Model_DbTable_Restaurants();
    	$itemsRowset = $restaurants->find($thisDish['restaurant_id']);
    	$thisRest = $itemsRowset->current();
    	$restName = $thisRest['name'];
    		
    	$this->view->title = "Add Review for " . $dishName . " at " . $restName;
		$this->view->headTitle($this->view->title, 'PREPEND');
		
		$form = new Form_Review();
		$form->getElement('dish_id')->setValue($id);
		$form->getElement('user_id')->setValue($userID);
		if($dir != '0')
			$form->getElement('rating')->setValue($dir);
		
		$form->submit->setLabel('Add');
		$this->view->form = $form;
                    
		if ($this->getRequest()->isPost()) {
			$formData = $this->getRequest()->getPost();
			if ($form->isValid($formData)) {
				$userID = $form->getValue('user_id');
				$dishID = $form->getValue('dish_id');
				$rating = $form->getValue('rating');
				$ratVal = 0;
				if($rating == 'pos' ? $ratVal = 1 : $ratVal = -1);
				$comments = $form->getValue('comments');
				$reviews = new Model_DbTable_Reviews();
				$reviews->addReview($userID, $dishID, $ratVal, $comments);
                $this->_redirect('/dish/detail/id/' . $id);
                
            } else {
            	$form->populate($formData);
            }
    	}
    }

    public function editAction()
    {
        $this->view->title = "Edit review";
		$this->view->headTitle($this->view->title, 'PREPEND');
                
        $form = new Form_Review();
        $form->submit->setLabel('Save');
        $this->view->form = $form;
                
        if ($this->getRequest()->isPost()) {
        	$formData = $this->getRequest()->getPost();
            if ($form->isValid($formData)) {
            	$id = (int)$form->getValue('id');
                $userID = (int)$form->getValue('user_id');
                $dishID = (int)$form->getValue('dish_id');
                $rating = $form->getValue('rating');
                $comments = $form->getValue('comments');
              	$reviews = new Model_DbTable_Reviews();
				$reviews->updateReview($id, $userID, $dishID, $rating, $comments);
                $this->_redirect('/review');
            } else {
                	$form->populate($formData);
            }
        }else {
			$id = $this->_getParam('id', 0);
            if ($id > 0) {
            	$reviews = new Model_DbTable_Reviews();
            	$form->populate($reviews->getReview($id));
            	$thisReview = $reviews->getReview($id);
            	$ratVal = $thisReview['rating'];
            	$rating = 0;
            	if($ratVal == 1 ? $rating = 'pos' : $rating = 'neg');
            	$form->getElement('rating')->setValue($rating);
            }
    	}
    }

    public function deleteAction()
    {
        $this->view->title = "Delete Review";
        $this->view->headTitle($this->view->title, 'PREPEND');
                
        if ($this->getRequest()->isPost()) {
        	$del = $this->getRequest()->getPost('del');
            if ($del == 'Yes') { 
            	$id = $this->getRequest()->getPost('id');
                $reviews = new Model_DbTable_Reviews();
                $reviews->deleteReview($id);
            }
            $this->_redirect('/review');
        } else {
			$id = $this->_getParam('id', 0);
			$reviews = new Model_DbTable_Reviews();
            $this->view->review = $reviews->getReview($id);
    	}
    }
}