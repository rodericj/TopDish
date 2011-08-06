<?php
class Form_Dish extends Zend_Form
{
    public function __construct($options = null)
    {
        parent::__construct($options);
        $this->setName('dish');
        $id = new Zend_Form_Element_Hidden('id');
        $name = new Zend_Form_Element_Text('name');
        $name ->setLabel('Name')
        	  ->setRequired(true)
              ->addFilter('StripTags')
              ->addFilter('StringTrim')
              ->addValidator('NotEmpty');
		if($options != null){
			if($options['restID'] > 0){
				//restaurant ID given to form upon construction
				$restaurantID = new Zend_Form_Element_Hidden('restaurantID');
				$restaurantID->setValue($options['restID']);
			
			}else{
		        $restaurantID = new Zend_Form_Element_Text('restaurantID');
		        $restaurantID ->setLabel('Restaurant ID')
		              ->setRequired(true)
		              ->addFilter('StripTags')
		              ->addFilter('StringTrim')
		              ->addValidator('NotEmpty');
			}
		}

        $fooditemID = new Zend_Form_Element_Select('fooditemID');
        $fooditemID ->setLabel('Category')
        	  ->setMultiOptions($options['fooditems'])
              ->setRequired(true)
              ->addValidator('NotEmpty');
		
        $submit = new Zend_Form_Element_Submit('submit');
        $submit->setAttrib('id', 'submitbutton');
        $this->addElements(array($id, $name, $restaurantID, $fooditemID, $submit));
    }
}