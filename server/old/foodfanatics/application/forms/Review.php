<?php
class Form_Review extends Zend_Form
{
    public function __construct($options = null)
    {
        parent::__construct($options);
        $this->setName('review');
        $id = new Zend_Form_Element_Hidden('id');
        $id->removeDecorator('Label');
        $dishID = new Zend_Form_Element_Hidden('dish_id');
        $dishID ->removeDecorator('Label')
              	->addFilter('StripTags')
             	->addFilter('StringTrim')
              	->addValidator('NotEmpty');
        $userID = new Zend_Form_Element_Hidden('user_id');
        $userID ->removeDecorator('Label')
      		  	->setRequired(true)
              	->addFilter('StripTags')
              	->addFilter('StringTrim')
              	->addValidator('NotEmpty');
        $rating = new Zend_Form_Element_Radio('rating');
        $rating ->setLabel('Rating')
              ->addMultiOptions(array(
              	'neg' => 'Negative',
              	'pos'  => 'Positive'))
              ->setAttrib('for', '') 
              ->setRequired(true);
        $comments = new Zend_Form_Element_Text('comments');
        $comments ->setLabel('Comments')
              ->addFilter('StripTags')
              ->addFilter('StringTrim');
        $submit = new Zend_Form_Element_Submit('submit');
        $submit->setAttrib('id', 'submitbutton');
        $this->addElements(array($id, $userID, $dishID, $rating, $comments, $submit));
    }
}