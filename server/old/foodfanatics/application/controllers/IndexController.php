<?php

class IndexController extends Zend_Controller_Action
{

    public function init()
    {
    	
    }

    public function indexAction()
    {
        // action body
        $this->_redirect('/dish/toprated'); 

    }
}



