package com.topdish.util;

import java.util.HashSet;
import java.util.Set;
import java.util.StringTokenizer;

import com.google.appengine.api.datastore.PostalAddress;

/**
 * A helper class to generate search terms.  
 * 
 * @author ralmand (Randy Almand)
 *
 */
public class SearchUtils {
	/**
	 * Returns a {@link Set} of strings representing partial words and whole words in the search query.  For example, "Charlie's Diner"
	 * will return a Set of strings like ["c", "ch", "cha", ... "charlie", "charlies", "charlie's", "d", "di", ..., "diner"] with elements of
	 * each word up to <code>maxStubLength</code> characters each.  Whole words are stored with and without punctuation to allow for a broad
	 * range of queries to match the generated list.   Whole words that are longer than <code>maxStubLength</code> characters are stored as well.  
	 * The main purpose of storing partial words starting at the first character is to provide a list of matches for an auto-complete function.
	 * 
	 * @param query the string used to generate search terms
	 * @param maxStubLength the maximum length of a partial word to return
	 * @return a {@link Set} containing the generated search terms
	 */
    public static Set<String> getSearchTerms(String query, int maxStubLength){
    	Set<String> returnSet = new HashSet<String>();
    	
    	query = query.replaceAll("/", " ");
    	query = query.replaceAll("&", " ");
    	
    	StringTokenizer st = new StringTokenizer(query, " ");
    	while(st.hasMoreTokens()){
    		String word = st.nextToken();
    		
    		for(int i = 1; i <= maxStubLength; i++){
    			if(i <= word.length()-1){
    				//add partial words for auto-complete
    				returnSet.add(word.substring(0, i).toLowerCase());
    			}
    		}
    		
    		returnSet.add(word.toLowerCase());
    		String newWord = word.replaceAll("'", "");
    		
    		if(!word.equals(newWord)){	
	    		returnSet.add(newWord.toLowerCase()); //add whole word to index
    		}
    	}
    	return returnSet;
    }
    
	/**
	 * Returns a {@link Set} of strings representing whole words in the address.  This function only uses the 
	 * city and state to generate search terms.  
	 * 
	 * @param address the {@link PostalAddress} used to generate search terms
	 * @return a {@link Set} containing the generated search terms
	 */
    @Deprecated
	public static Set<String> getAddressTerms(PostalAddress address) {
		Set<String> returnSet = new HashSet<String>();
		
		StringTokenizer st = new StringTokenizer(address.getAddress(), ", ");
		int i = 0;
		while(st.hasMoreTokens()){
			String word = st.nextToken();
			if(i > 0){
				//ignore first result which is street address
				returnSet.add(word.toLowerCase());
			}
			i++;
		}
		
		return returnSet;
	}
}