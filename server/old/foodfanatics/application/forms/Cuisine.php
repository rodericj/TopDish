<?php
class Form_Cuisine extends Zend_Form
{
    public function __construct($options = null)
    {
        parent::__construct($options);
        $this->setName('cuisine');
        $id = new Zend_Form_Element_Hidden('id');
        $name = new Zend_Form_Element_Text('name');
        $name ->setLabel('Name')
        	  ->setRequired(true)
              ->addFilter('StripTags')
              ->addFilter('StringTrim')
              ->addValidator('NotEmpty');
        $submit = new Zend_Form_Element_Submit('submit');
        $submit->setAttrib('id', 'submitbutton');
        $this->addElements(array($id, $name, $submit));
    }
}