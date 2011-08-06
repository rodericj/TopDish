<?php

class UserController extends Zend_Controller_Action
{

    public function init()
    {
    }

    public function indexAction()
    {
        $this->view->title = "Users";
		$this->view->headTitle($this->view->title, 'PREPEND');
        $users = new Model_DbTable_Users();
        $this->view->users = $users->fetchAll();
    }

    public function addAction()
    {
        $this->view->title = "New User";
		$this->view->headTitle($this->view->title, 'PREPEND');
        $form = new Form_User();
        $form->submit->setLabel('Sign Up');
        $this->view->form = $form;
                                    
        if ($this->getRequest()->isPost()) {
        	$formData = $this->getRequest()->getPost();
			
        	if ($form->isValid($formData)) {
            	$first = $form->getValue('first');
                $last = $form->getValue('last');
                $email = $form->getValue('email');
                $password = $form->getValue('password1');
                $users = new Model_DbTable_Users();
                $users->addUser($first, $last, $email, $password);
                
                //auto log-in user and redirect to home page
                // Setup DbTable adapter
				$dbAdapter = Zend_Db_Table::getDefaultAdapter();  
				$authAdapter = new Zend_Auth_Adapter_DbTable($dbAdapter);
				$authAdapter->setTableName('users')
					->setIdentityColumn('email')
					->setCredentialColumn('password');
					
		        $authAdapter->setIdentity($email)
		        		->setCredential(hash('SHA256',$password));
		        		
		        // authentication attempt
		        $auth = Zend_Auth::getInstance();
		        $result = $auth->authenticate($authAdapter);
		        
		        $userInfo = $authAdapter->getResultRowObject(null, 'password');
				    
			    // the default storage is a session with namespace Zend_Auth  
			    $authStorage = $auth->getStorage();
			    $authStorage->write($userInfo);
				
			    $this->_redirect('/index'); 
                                
           } else {
           		$form->populate($formData);
           }
    	}
    }

    public function profileAction()
    {
    	//firstly, check that user is editing own profile, if not send to error
  		$authStorage = Zend_Auth::getInstance()->getStorage();
	    $userInfo = $authStorage->read();
	    $userID = $userInfo->id;
	    $request = $this->getRequest();
	    $reqID = $request->id;

	    if($userID != $reqID){
	    	$request->setControllerName('error')
              	->setActionName('denied');
	    }else{
	    	//user editing own profile, proceed as usual
	        $this->view->title = "My Profile";
			$this->view->headTitle($this->view->title, 'PREPEND');
	                                
	        $form = new Form_UserProfile();
	        $form->submit->setLabel('Update');
	        $this->view->form = $form;
	        $this->view->userID = $userID;
	                                
	        if ($this->getRequest()->isPost()) {
	        	$formData = $this->getRequest()->getPost();
	            if ($form->isValid($formData)) {
	            	$id = (int)$form->getValue('id');
	                $first = $form->getValue('first');
	                $last = $form->getValue('last');
	                $email = $form->getValue('email');
	                $users = new Model_DbTable_Users();
	                $users->updateUser($id, $first, $last, $email);
	                $this->view->statusMessage = "Profile updated successfully!";
	                
					//update auth storage with new info.
					$authStorage = Zend_Auth::getInstance()->getStorage();
	    			$userInfo = $authStorage->read();
	    			$userInfo->first = $first;
	    			$userInfo->last = $last;
	    			$userInfo->email = $email;
	    			$authStorage->write($userInfo);
	           	} else {
	           		$form->populate($formData);
	            }
	        }else {
	        	$id = $this->_getParam('id', 0);
	            if ($id > 0) {
	            	$users = new Model_DbTable_Users();
	                $form->populate($users->getUser($id));
	            }
	    	}
	    }
    }

    public function deleteAction()
    {
        $this->view->title = "Delete User";
        $this->view->headTitle($this->view->title, 'PREPEND');
                                
        if ($this->getRequest()->isPost()) {
        	$del = $this->getRequest()->getPost('del');
            if ($del == 'Yes') { 
            	$id = $this->getRequest()->getPost('id');
                $users = new Model_DbTable_Users();
                $users->deleteUser($id);
            }
           	$this->_redirect('/user');
        } else {
        	$id = $this->_getParam('id', 0);
            $users = new Model_DbTable_Users();
            $this->view->user = $users->getUser($id);
    	}
    }

    public function loginAction()
    {
		$form = new Form_UserLogin;
        $this->view->form = $form;
        
        if ($this->getRequest()->isPost()) {
        	$formData = $this->getRequest()->getPost();
        	
        	if ($form->isValid($formData)) {
        		$email = $form->getValue('email');
        		$password = $form->getValue('password');
        		
		        // Setup DbTable adapter
				$dbAdapter = Zend_Db_Table::getDefaultAdapter();  
				$authAdapter = new Zend_Auth_Adapter_DbTable($dbAdapter);
				$authAdapter->setTableName('users')
					->setIdentityColumn('email')
					->setCredentialColumn('password');
					
		        $authAdapter->setIdentity($email)
		        		->setCredential(hash('SHA256',$password));
		        		
		        // authentication attempt
		        $auth = Zend_Auth::getInstance();
		        $result = $auth->authenticate($authAdapter);
		        
		        // authentication succeeded
		        if ($result->isValid()) {
					// get all info about this user from the login table  
				    // ommit only the password, we don't need that  
				    $userInfo = $authAdapter->getResultRowObject(null, 'password');
				    
				    // the default storage is a session with namespace Zend_Auth  
				    $authStorage = $auth->getStorage();
				    $authStorage->write($userInfo);
					
				    $request = $this->getRequest();
					$uri = $request->getRequestUri();
				    				    
				    if($uri != "/user/login"){
				    	//send the user to their intended destination
				    	$this->_redirect($uri);
				    }else{
				    	//just send them to the front page
						$this->_redirect('/dish/toprated'); 
				    }
				    
		        } else { // or not! Back to the login page!
		            $this->view->errorMessage = "Incorrect email or password. Please try again.";
		        }
        	}
        } else {
			$this->view->loginForm = $form;
        }   
    }

    public function logoutAction()
    {
	    // clear everything - session is cleared also!  
	    Zend_Auth::getInstance()->clearIdentity();  
	    $this->_redirect('/index'); 
    }
    
    public function passwordAction(){
        $this->view->title = "Change Password";
		$this->view->headTitle($this->view->title, 'PREPEND');
    
    	$form = new Form_UserPassword;
        $this->view->form = $form;
        
        if ($this->getRequest()->isPost()) {
        	$formData = $this->getRequest()->getPost();
        	
        	if ($form->isValid($formData)) {
        		$oldPass = $form->getValue('old_password');
        		$newPass = $form->getValue('password1');
        		
				$authStorage = Zend_Auth::getInstance()->getStorage();
	    		$userInfo = $authStorage->read();
				$userID = $userInfo->id;

				//check that old password is the same as found in db
				$users = new Model_DbTable_Users();
				$curUser = $users->getUser($userID);
		        
		        if ($curUser['password'] == hash('SHA256', $oldPass)){
		        	//change stored password to new password
	                $users->passwordUser($userID, $newPass);
	                
	                //TODO: send user to profile page with below status message
	                $this->_redirect("/user/profile/id/{$userID}");
	                //$this->view->statusMessage = "Password updated successfully!";
		        }
		        else{
		        	$this->view->statusMessage = "Old password is incorrect.  Please try again.";
		        }
        	}
    	} else {
			$this->view->form = $form;
        }
    }
}