package com.topdish.api.util;

import com.google.appengine.api.datastore.Blob;
import com.topdish.jdo.Photo;

/**
 * Constants related to {@link Photo}s
 * 
 * @author Salil
 * 
 */
public class PhotoConstants {

	/**
	 * Photo = "photo"
	 */
	public static final String PHOTO = "photo";
	
	/**
	 * Photo Id = "photoId"
	 */
	public static final String PHOTO_ID = "photoId";

	/**
	 * Description = "description" <br>
	 * Note: Points to {@link APIConstants}.DESCRIPTION
	 */
	public static final String DESCRIPTION = APIConstants.DESCRIPTION;

	/**
	 * Blob Key = "blobkey" <br>
	 * Note: Used for {@link Blob}Store {@link Photo} Uploads
	 */
	public static final String BLOB_KEY = "blobkey";

}
