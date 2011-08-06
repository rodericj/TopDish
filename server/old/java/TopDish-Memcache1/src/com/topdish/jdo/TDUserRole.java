package com.topdish.jdo;

import java.util.HashMap;


/**
 * Roles associated with a User
 * 
 * 
 */
public class TDUserRole {
	
	public HashMap<Integer,String> roleMap;
	
	/**
	 * Standard User <br>
	 * 
	 */
	public final static int ROLE_STANDARD = 0;
	
	/**
	 * Advanced User <br>
	 * 
	 */
	public final static int ROLE_ADVANCED = 1;
	
	/**
	 * Admin User <br>
	 * 
	 */
	public final static int ROLE_ADMIN = 2;
	
	
	/**
	 * Standard Name = "Standard"
	 */
	public final static String STANDARD_ROLE_NAME = "Standard";
	
	/**
	 * Advanced Name = "Advanced"
	 */
	public final static String ADVANCED_ROLE_NAME = "Advanced";
	
	/**
	 * Admin Name = "Admin"
	 */
	public final static String ADMIN_ROLE_NAME = "Admin";
	
	
	public HashMap<Integer,String> getTDUserRoles()
	{
		roleMap=new HashMap<Integer,String>();
		roleMap.put(ROLE_STANDARD, STANDARD_ROLE_NAME);
		roleMap.put(ROLE_ADVANCED, ADVANCED_ROLE_NAME);
		roleMap.put(ROLE_ADMIN, ADMIN_ROLE_NAME);
		return roleMap;
	}
	
	
	public String getRoleName(int key)
	{
		if(roleMap!=null)
			return this.roleMap.get(key);
		else
			return null;
	}

}
