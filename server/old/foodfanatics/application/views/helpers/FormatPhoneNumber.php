<?php 
class Zend_View_Helper_formatPhoneNumber extends Zend_View_Helper_Abstract{
	public function formatPhoneNumber($phone){
		$pattern = '/(\d{3})(\d{3})(\d{4})/';
		$replacement = '($1) $2-$3';
		return preg_replace($pattern, $replacement, $phone);	
	}
}