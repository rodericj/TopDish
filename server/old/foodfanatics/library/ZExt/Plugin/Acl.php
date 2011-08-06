<?php 
class ZExt_Plugin_Acl extends Zend_Controller_Plugin_Abstract {
  private $_acl = null;
 
  public function __construct(Zend_Acl $acl) {
    $this->_acl = $acl;
  }
 
  public function preDispatch(Zend_Controller_Request_Abstract $request) {
    //As in the earlier example, authed users will have the role user
    $role = MyAcl::ROLE_GUEST;
  	
  	if(Zend_Auth::getInstance()->hasIdentity()){
  		//logged in	    
  		$authStorage = Zend_Auth::getInstance()->getStorage();
	    $userInfo = $authStorage->read();
	    $role = $userInfo->role;		    
  	}
 
    //For this example, we will use the controller as the resource:
    $resource = $request->getControllerName();
    $action = $request->getActionName();
 
    if(!$this->_acl->isAllowed($role, $resource, $action)) {
      //If the user has no access we send him elsewhere by changing the request
      
      //if not logged in, show login page, otherwise error
      if($role == MyAcl::ROLE_GUEST){
      	$request->setControllerName('user')
              	->setActionName('login');
      }else{
      	$request->setControllerName('error')
              	->setActionName('denied');
      }
    }
  }
}