<?php 
class MyAcl extends Zend_Acl
{	
	const ROLE_GUEST = 0;
	const ROLE_MEMBER = 1;
	const ROLE_MOD = 2;
	const ROLE_ADMIN = 3; 
	
	public function __construct(Zend_Auth $auth)
    {
        //Add one resource per controller
		$this->add(new Zend_Acl_Resource('cuisine'));
		$this->add(new Zend_Acl_Resource('dish'));
		$this->add(new Zend_Acl_Resource('fooditem'));
		$this->add(new Zend_Acl_Resource('index'));
		$this->add(new Zend_Acl_Resource('restaurant'));
		$this->add(new Zend_Acl_Resource('review'));
		$this->add(new Zend_Acl_Resource('user'));
		$this->add(new Zend_Acl_Resource('error'));

		//Add all roles. guest/member/mod/admin
        $this->addRole(new Zend_Acl_Role(MyAcl::ROLE_GUEST)); 
        //member is logged in, inherits from guest
        $this->addRole(new Zend_Acl_Role(MyAcl::ROLE_MEMBER), MyAcl::ROLE_GUEST);
        //mod has extra powers, inherits from member
        $this->addRole(new Zend_Acl_Role(MyAcl::ROLE_MOD), MyAcl::ROLE_MEMBER);
        //admin is god, inherits from mod
        $this->addRole(new Zend_Acl_Role(MyAcl::ROLE_ADMIN), MyAcl::ROLE_MOD);

		//Roles for Cuisine Controller
        $this->deny(MyAcl::ROLE_GUEST, 'cuisine');
        $this->allow(MyAcl::ROLE_GUEST, 'cuisine', 'index');	//guest can only view
        $this->deny(MyAcl::ROLE_MEMBER, 'cuisine');
        $this->allow(MyAcl::ROLE_MEMBER, 'cuisine', 'index');	//member can only view
        $this->allow(MyAcl::ROLE_MOD, 'cuisine');				//mod can edit
        $this->deny(MyAcl::ROLE_MOD, 'cuisine', 'delete');	//only admin can delete
        
        //Roles for Dish Controller
        $this->allow(MyAcl::ROLE_GUEST, 'dish');
        $this->deny(MyAcl::ROLE_GUEST, 'dish', 'add');
        $this->deny(MyAcl::ROLE_GUEST, 'dish', 'edit');
        $this->deny(MyAcl::ROLE_GUEST, 'dish', 'delete');		//add, edit for member only
        $this->allow(MyAcl::ROLE_MEMBER, 'dish');
        $this->deny(MyAcl::ROLE_MEMBER, 'dish', 'delete');	//member can add, edit own
        $this->allow(MyAcl::ROLE_MOD, 'dish');
        $this->deny(MyAcl::ROLE_MOD, 'dish', 'delete');		//only admin can delete
        
        //Roles for FoodItem Controller
        $this->allow(MyAcl::ROLE_GUEST, 'fooditem');
        $this->deny(MyAcl::ROLE_GUEST, 'fooditem', 'add');
        $this->deny(MyAcl::ROLE_GUEST, 'fooditem', 'edit');
        $this->deny(MyAcl::ROLE_GUEST, 'fooditem', 'delete');		//add, edit for mod only
        $this->allow(MyAcl::ROLE_MEMBER, 'fooditem');
        $this->deny(MyAcl::ROLE_MEMBER, 'fooditem', 'add');
        $this->deny(MyAcl::ROLE_MEMBER, 'fooditem', 'edit');
        $this->deny(MyAcl::ROLE_MEMBER, 'fooditem', 'delete');		//add, edit for mod only
        $this->allow(MyAcl::ROLE_MOD, 'fooditem');
        $this->deny(MyAcl::ROLE_MOD, 'fooditem', 'delete');		//only admin can delete

        //Roles for Index Controller
        $this->allow(MyAcl::ROLE_GUEST, 'index');
        
		//Roles for Restaurant Controller
        $this->allow(MyAcl::ROLE_GUEST, 'restaurant');
        $this->deny(MyAcl::ROLE_GUEST, 'restaurant', 'add');
        $this->deny(MyAcl::ROLE_GUEST, 'restaurant', 'edit');
        $this->deny(MyAcl::ROLE_GUEST, 'restaurant', 'delete');		//add, edit for mod only
        $this->allow(MyAcl::ROLE_MEMBER, 'restaurant');
        $this->deny(MyAcl::ROLE_MEMBER, 'restaurant', 'add');
        $this->deny(MyAcl::ROLE_MEMBER, 'restaurant', 'edit');
        $this->deny(MyAcl::ROLE_MEMBER, 'restaurant', 'delete');		//add, edit for mod only
        $this->allow(MyAcl::ROLE_MOD, 'restaurant');
        $this->deny(MyAcl::ROLE_MOD, 'restaurant', 'delete');		//only admin can delete
        
		//Roles for Review Controller
        $this->deny(MyAcl::ROLE_GUEST, 'review');
        $this->allow(MyAcl::ROLE_GUEST, 'review', 'index');
        $this->allow(MyAcl::ROLE_MEMBER, 'review');
        $this->deny(MyAcl::ROLE_MEMBER, 'review', 'delete');		//add, edit self-created only
        $this->allow(MyAcl::ROLE_MOD, 'review');
        $this->deny(MyAcl::ROLE_MOD, 'review', 'delete');		//only admin can delete
        
        //Roles for User Controller
        $this->deny(MyAcl::ROLE_GUEST, 'user');
        $this->allow(MyAcl::ROLE_GUEST, 'user', 'add');		//allow guest to sign up
        $this->allow(MyAcl::ROLE_GUEST, 'user', 'logout');
        $this->allow(MyAcl::ROLE_GUEST, 'user', 'login');
        $this->allow(MyAcl::ROLE_MEMBER, 'user');
        $this->deny(MyAcl::ROLE_MEMBER, 'user', 'add');
        $this->deny(MyAcl::ROLE_MEMBER, 'user', 'index');		//edit, delete self ok
        $this->allow(MyAcl::ROLE_MOD, 'user');
        $this->deny(MyAcl::ROLE_MEMBER, 'user', 'add');
        $this->deny(MyAcl::ROLE_MOD, 'user', 'index');		//edit, delete self ok
        
        //Roles for Error Controller
        $this->allow(MyAcl::ROLE_GUEST, 'error');
        
        //Admin has unrestricted access
        $this->allow(MyAcl::ROLE_ADMIN);

        //TODO: force only self edits/deletes for users, comments
        // Add authoring ACL check
        //$this->allow(MyAcl::ROLE_MEMBER, 'forum', 'update', new MyAcl_Forum_Assertion($auth));
        // NOTE: Dependency on auth object to allow getIdentity() for authenticated user object
    }
}
