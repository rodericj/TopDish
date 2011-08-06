<?php
class Form_Restaurant extends Zend_Form
{
    public function __construct($options = null)
    {
        parent::__construct($options);
        $this->setName('restaurant');
        $id = new Zend_Form_Element_Hidden('id');
        $name = new Zend_Form_Element_Text('name');
        $name ->setLabel('Name')
        	  ->setRequired(true)
              ->addFilter('StripTags')
              ->addFilter('StringTrim')
              ->addValidator('NotEmpty');
		$street = new Zend_Form_Element_Text('street');
        $street ->setLabel('Street Address')
        	  ->setRequired(true)
              ->addFilter('StripTags')
              ->addFilter('StringTrim')
              ->addValidator('NotEmpty');
        $city = new Zend_Form_Element_Text('city');
        $city ->setLabel('City')
        	  ->setRequired(true)
              ->addFilter('StripTags')
              ->addFilter('StringTrim')
              ->addValidator('NotEmpty');
        $state = new Zend_Form_Element_Text('state');
        $state ->setLabel('State')
        	  ->setRequired(true)
              ->addFilter('StripTags')
              ->addFilter('StringTrim')
              ->addValidator('NotEmpty')
              ->addValidator('StringLength', 2, 2)
              ->addValidator('Alpha');
        $zip = new Zend_Form_Element_Text('zip');
        $zip ->setLabel('Zipcode')
        	  ->setRequired(true)
              ->addFilter('StripTags')
              ->addFilter('StringTrim')
              ->addFilter('Digits')
              ->addValidator('NotEmpty');
        $phone = new Zend_Form_Element_Text('phone');
        $phone ->setLabel('Phone')
        	  ->setRequired(true)
              ->addFilter('StripTags')
              ->addFilter('StringTrim')
              ->addFilter('Digits')
              ->addValidator('NotEmpty');
        $submit = new Zend_Form_Element_Submit('submit');
        $submit->setAttrib('id', 'submitbutton');
        $this->addElements(array($id, $name, $street, $city, $state, $zip, $phone, $submit));
    }
}