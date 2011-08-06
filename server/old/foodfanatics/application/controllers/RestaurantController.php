<?php

class RestaurantController extends Zend_Controller_Action
{

    public function init()
    {

    }

    public function indexAction()
    {
        $this->view->title = "Restaurants";
        $this->view->headTitle($this->view->title, 'PREPEND');
        $restaurants = new Model_DbTable_Restaurants();
        $this->view->restaurants = $restaurants->fetchAll();
    }

    public function addAction()
    {
    	$this->view->title = "Add new restaurant";
		$this->view->headTitle($this->view->title, 'PREPEND');
		$form = new Form_Restaurant();
		$form->submit->setLabel('Add');
		$this->view->form = $form;
                    
		if ($this->getRequest()->isPost()) {
			$formData = $this->getRequest()->getPost();
			if ($form->isValid($formData)) {
				$name = $form->getValue('name');
				$street = $form->getValue('street');
				$city = $form->getValue('city');
				$state = $form->getValue('state');
				$zip = $form->getValue('zip');
				$phone = $form->getValue('phone');
				$restaurants = new Model_DbTable_Restaurants();
				$restaurants->addRestaurant($name, $street, $city, $state, $zip, $phone);
                $this->_redirect('/restaurant');
                
            } else {
            	$form->populate($formData);
            }
    	}
    }

    public function editAction()
    {
        $this->view->title = "Edit restaurant";
		$this->view->headTitle($this->view->title, 'PREPEND');
                
        $form = new Form_Restaurant();
        $form->submit->setLabel('Save');
        $this->view->form = $form;
                
        if ($this->getRequest()->isPost()) {
        	$formData = $this->getRequest()->getPost();
            if ($form->isValid($formData)) {
            	$id = (int)$form->getValue('id');
                $name = $form->getValue('name');
                $street = $form->getValue('street');
				$city = $form->getValue('city');
				$state = $form->getValue('state');
				$zip = $form->getValue('zip');
				$phone = $form->getValue('phone');
                $restaurants = new Model_DbTable_Restaurants();
				$restaurants->updateRestaurant($id, $name, $street, $city, $state, $zip, $phone);
                $this->_redirect('/restaurant');
                } else {
                	$form->populate($formData);
                }
        }else {
			$id = $this->_getParam('id', 0);
            if ($id > 0) {
            	$restaurants = new Model_DbTable_Restaurants();
            	$form->populate($restaurants->getRestaurant($id));
            }
    	}
    }

    public function deleteAction()
    {
        $this->view->title = "Delete restaurant";
        $this->view->headTitle($this->view->title, 'PREPEND');
                
        if ($this->getRequest()->isPost()) {
        	$del = $this->getRequest()->getPost('del');
            if ($del == 'Yes') { 
            	$id = $this->getRequest()->getPost('id');
                $restaurants = new Model_DbTable_Restaurants();
                $restaurants->deleteRestaurant($id);
            }
            $this->_redirect('/restaurant');
        } else {
			$id = $this->_getParam('id', 0);
			$restaurants = new Model_DbTable_Restaurants();
            $this->view->restaurant = $restaurants->getRestaurant($id);
    	}
    }
    
    public function searchAction(){
    	//$this->view->title = "Restaurants Near Me";
    	$this->view->headTitle("Restaurants Near Me", 'PREPED');
    }
}