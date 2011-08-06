<?php
class Form_UserProfile extends Zend_Form
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
        $submit = new Zend_Form_Element_Submit('submit');
        $submit->setAttrib('id', 'submitbutton');
        $this->addElements(array($id, $first, $last, $email, $submit));
    }
}