package com.topdish.util;

import javax.jdo.JDOHelper;
import javax.jdo.PersistenceManagerFactory;

/**
 * A factory class for generating {@link PersistenceManagerFactory} objects
 * 
 * @author ralmand (Randy Almand)
 */
public class PMF {
	/**
	 * The {@link PersistanceManagerFactory} instance
	 */
    private static PersistenceManagerFactory pmfInstance = JDOHelper.getPersistenceManagerFactory("transactions-optional");

    /**
     * Constructor should not be used
     */
    private PMF() {}

    /**
     * Fetches the {@link PersistenceManagerFactory} instance
     * @return the {@link PersistenceManagerFactory} instance
     */
    public static PersistenceManagerFactory get() {
    	if(null == pmfInstance){
    		pmfInstance = JDOHelper.getPersistenceManagerFactory("transactions-optional");
    		return get();
    	}
        return pmfInstance;
    }
}