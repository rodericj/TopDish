<?php
class Form_UserLogin extends Zend_Form
{
    public function __construct($options = null)
    {
        parent::__construct($options);
        $this->setName('userLogin');
        $email = new Zend_Form_Element_Text('email');
        $email ->setLabel('Email')
              ->setRequired(true)
              ->addFilter('StripTags')
              ->addFilter('StringTrim')
              ->addValidator('NotEmpty')
              ->addValidator('EmailAddress');
        $password = new Zend_Form_Element_Password('password');
        $password ->setLabel('Password')
              ->setRequired(true)
              ->addFilter('StripTags')
              ->addFilter('StringTrim')
              ->addValidator('NotEmpty');
        $submit = new Zend_Form_Element_Submit('submit');
        $submit->setAttrib('id', 'submitbutton');
        $this->addElements(array($email, $password, $submit));
    }
}