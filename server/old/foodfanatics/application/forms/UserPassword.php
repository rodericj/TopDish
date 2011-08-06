<?php
class Form_UserPassword extends Zend_Form
{
    public function __construct($options = null)
    {
        parent::__construct($options);
        
        $this->addElementPrefixPath('ZExt', 'ZExt/');
        
        $this->setName('user');
        $id = new Zend_Form_Element_Hidden('id');
        $oldPass = new Zend_Form_Element_Password('old_password');
        $oldPass ->setLabel('Old Password')
              ->setRequired(true)
              ->addFilter('StripTags')
              ->addFilter('StringTrim')
              ->addValidator('NotEmpty');
        $password1 = new Zend_Form_Element_Password('password1');
        $password1 ->setLabel('New Password')
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
        $this->addElements(array($id, $oldPass, $password1, $password2, $submit));
    }
}