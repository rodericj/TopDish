<?php
class Form_User extends Zend_Form
{
    public function __construct($options = null)
    {
        parent::__construct($options);
        
        $this->addElementPrefixPath('ZExt', 'ZExt/');
        
        $this->setName('user');
        $id = new Zend_Form_Element_Hidden('id');
        $first = new Zend_Form_Element_Text('first');
        $first ->setLabel('First Name')
        	  ->setRequired(true)
              ->addFilter('StripTags')
              ->addFilter('StringTrim')
              ->addValidator('NotEmpty')
              ->addValidator('Alpha');
        $last = new Zend_Form_Element_Text('last');
        $last ->setLabel('Last Name')
              ->setRequired(true)
              ->addFilter('StripTags')
              ->addFilter('StringTrim')
              ->addValidator('NotEmpty')
              ->addValidator('Alpha');
        $email = new Zend_Form_Element_Text('email');
        $email ->setLabel('Email')
              ->setRequired(true)
              ->addFilter('StripTags')
              ->addFilter('StringTrim')
              ->addValidator('NotEmpty')
              ->addValidator('EmailAddress');
        $password1 = new Zend_Form_Element_Password('password1');
        $password1 ->setLabel('Password')
              ->setRequired(true)
              ->addFilter('StripTags')
              ->addFilter('StringTrim')
              ->addValidator('NotEmpty')
              ->addValidator('IdenticalField', false, array('password2', 'Confirm Password'));
        $password2 = new Zend_Form_Element_Password('password2');
        $password2 ->setLabel('Confirm Password')
              ->setRequired(true)
              ->addFilter('StripTags')
              ->addFilter('StringTrim')
              ->addValidator('NotEmpty');
        $submit = new Zend_Form_Element_Submit('submit');
        $submit->setAttrib('id', 'submitbutton');
        $this->addElements(array($id, $first, $last, $email, $password1, $password2, $submit));
    }
}