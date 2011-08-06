package com.topdish.util;

import java.util.Calendar;


public class TDLogger {
	
	private static Calendar dateAndTime = Calendar.getInstance();
	
	/**
	 * Prints a message to the Console as a Logged Message
	 * @param message
	 */
	public static void log(String message) {
		
		dateAndTime = Calendar.getInstance();
		System.err.println("[ERROR - " + dateAndTime.getTime() + "] " + message);
		
	}

}
