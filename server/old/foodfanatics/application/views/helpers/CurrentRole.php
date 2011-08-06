<?php 
//class for quickly determining logged-in user's role

class Zend_View_Helper_currentRole extends Zend_View_Helper_Abstract{
	public function currentRole(){	
		$authStorage = Zend_Auth::getInstance()->getStorage();
	    $userInfo = $authStorage->read();
	    if($userInfo != '')
	    	$role = $userInfo->role;
	    else
	    	$role = MyAcl::ROLE_GUEST;
	    return $role;
	}
}