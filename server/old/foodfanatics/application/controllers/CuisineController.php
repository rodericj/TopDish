<?php

class CuisineController extends Zend_Controller_Action
{

    public function init()
    {
        /* Initialize action controller here */
    }

    public function indexAction()
    {
        $this->view->title = "Cuisines";
        $this->view->headTitle($this->view->title, 'PREPEND');
        $cuisines = new Model_DbTable_Cuisines();
        $this->view->cuisines = $cuisines->fetchAll(
        	$cuisines->select()
          			->order('name ASC'));
    }

    public function addAction()
    {
       	$this->view->title = "New Cuisine";
		$this->view->headTitle($this->view->title, 'PREPEND');
		$form = new Form_Cuisine();
		$form->submit->setLabel('Add Cuisine');
		$this->view->form = $form;
                    
		if ($this->getRequest()->isPost()) {
			$formData = $this->getRequest()->getPost();
			if ($form->isValid($formData)) {
				$name = $form->getValue('name');
				$cuisines = new Model_DbTable_Cuisines();
				$cuisines->addCuisine($name);
                $this->_redirect('/cuisine');
                
            } else {
            	$form->populate($formData);
            }
    	}
    }

    public function editAction()
    {
        $this->view->title = "Edit Cuisine";
		$this->view->headTitle($this->view->title, 'PREPEND');
                
        $form = new Form_Cuisine();
        $form->submit->setLabel('Update');
        $this->view->form = $form;
                
        if ($this->getRequest()->isPost()) {
        	$formData = $this->getRequest()->getPost();
            if ($form->isValid($formData)) {
            	$id = (int)$form->getValue('id');
                $name = $form->getValue('name');
                $cuisines = new Model_DbTable_Cuisines();
                $cuisines->updateCuisine($id, $name);
                $this->_redirect('/cuisine');
                } else {
                	$form->populate($formData);
                }
        }else {
			$id = $this->_getParam('id', 0);
            if ($id > 0) {
            	$cuisines = new Model_DbTable_Cuisines();
            	$form->populate($cuisines->getCuisine($id));
            }
    	}
    }

    public function deleteAction()
    {
        $this->view->title = "Delete Cuisine";
        $this->view->headTitle($this->view->title, 'PREPEND');
                
        if ($this->getRequest()->isPost()) {
        	$del = $this->getRequest()->getPost('del');
            if ($del == 'Yes') { 
            	$id = $this->getRequest()->getPost('id');
            	$cuisines = new Model_DbTable_Cuisines();
            	$cuisines->deleteCuisine($id);
            }
            $this->_redirect('/cuisine');
        } else {
			$id = $this->_getParam('id', 0);
			$cuisines = new Model_DbTable_Cuisines();
            $this->view->cuisine = $cuisines->getCuisine($id);
    	}
    }
}









