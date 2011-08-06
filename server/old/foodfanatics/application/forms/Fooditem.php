<?php
class Form_Fooditem extends Zend_Form
{
    public function __construct($options = null)
    {
        parent::__construct($options);
        $this->setName('fooditem');
        $id = new Zend_Form_Element_Hidden('id');
        $name = new Zend_Form_Element_Text('name');
        $name ->setLabel('Name')
        	  ->setRequired(true)
              ->addFilter('StripTags')
              ->addFilter('StringTrim')
              ->addValidator('NotEmpty');
        $note = new Zend_Form_Element_Text('note');
        $note ->setLabel('Note')
              ->setRequired(true)
              ->addFilter('StripTags')
              ->addFilter('StringTrim')
              ->addValidator('NotEmpty');
        $cuisineID = new Zend_Form_Element_Hidden('cuisine_id');
        $submit = new Zend_Form_Element_Submit('submit');
        $submit->setAttrib('id', 'submitbutton');
        $this->addElements(array($id, $name, $note, $cuisineID, $submit));
    }
}