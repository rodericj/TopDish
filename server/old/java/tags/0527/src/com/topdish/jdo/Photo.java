package com.topdish.jdo;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

import org.apache.log4j.Logger;

import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.images.ImagesServiceFactory;
import com.topdish.util.Datastore;

@PersistenceCapable
public class Photo implements TDPersistable, Serializable {
	private static final long serialVersionUID = 1L;

	@PrimaryKey
	@Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
	private Key key;

	@Persistent
	private BlobKey blobKey;

	@Persistent
	private Integer degreesRotated;

	@Persistent
	private String description;

	@Persistent
	private Date dateCreated;

	@Persistent
	private Key creator;

	@Persistent
	private Integer numFlagsInappropriate;

	@Persistent
	private Integer numFlagsSpam;

	@Persistent
	private Integer numFlagsInaccurate;

	@Persistent
	private Integer numFlagsTotal;

	@Persistent
	private List<Key> flags;

	@Persistent(serialized = "true")
	private Map<Integer, String> urls;

	/**
	 * Constructor for a Photo
	 * 
	 * @param blobKey
	 * @param description
	 * @param creator
	 */
	public Photo(BlobKey blobKey, String description, Key creator) {
		this.blobKey = blobKey;
		this.description = description;
		this.dateCreated = new Date();
		this.creator = creator;
		this.degreesRotated = new Integer(0);
	}

	public Photo() {
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public Key getKey() {
		return key;
	}

	public Date getDateCreated() {
		return dateCreated;
	}

	public Key getCreator() {
		return creator;
	}

	public BlobKey getBlobKey() {
		return this.blobKey;
	}

	public void rotateImage() {
		if (this.degreesRotated == null) {
			this.degreesRotated = new Integer(0);
		}
		this.degreesRotated = (this.degreesRotated + 90) % 360;
	}

	public void setBlobKey(BlobKey bk) {
		this.blobKey = bk;
	}

	/**
	 * Get a serving URL for a particular size. The serving URL will last the
	 * life of the {@link BlobKey}.
	 * 
	 * @param size
	 *            Integer size in pixels of the longest side of the image. Will
	 *            scale preserving aspect ratio.
	 * @return a String URL.
	 */
	public String getURL(int size) {
		if (null == this.urls) {
			// urls not initiated yet
			this.urls = new HashMap<Integer, String>();
		}

		if (this.urls.containsKey(size)) {
			Logger.getLogger(this.getClass()).info(
					"found url for photo " + this.key.getId() + " with size " + size);
			return this.urls.get(size);
		} else {
			try {
				final String tempURL = ImagesServiceFactory.getImagesService().getServingUrl(
						this.getBlobKey(), size, true);
				this.urls.put(size, tempURL);
				Logger.getLogger(this.getClass()).info(
						"adding url for photo " + this.key.getId() + " with size " + size);
				Datastore.put(this);
				return tempURL;
			} catch (Exception e) {
				// occasionally ImagesService will barf, handle gracefully
				e.printStackTrace();
				return null;
			}
		}
	}
	
	public void addFlag(Flag flag) {
		if (this.numFlagsInaccurate == null) {
			this.numFlagsInaccurate = 0;
		}
		if (this.numFlagsInappropriate == null) {
			this.numFlagsInappropriate = 0;
		}
		if (this.numFlagsSpam == null) {
			this.numFlagsSpam = 0;
		}
		if (this.numFlagsTotal == null) {
			this.numFlagsTotal = 0;
		}

		switch (flag.getType()) {
		case Flag.INACCURATE:
			this.numFlagsInaccurate++;
			break;
		case Flag.INAPPROPRIATE:
			this.numFlagsInappropriate++;
			break;
		case Flag.SPAM:
			this.numFlagsSpam++;
			break;
		}
		this.numFlagsTotal++;
		this.flags.add(flag.getKey());
	}

	public Integer getNumFlagsInaccurate() {
		if (this.numFlagsInaccurate == null) {
			return 0;
		} else {
			return this.numFlagsInaccurate;
		}
	}

	public Integer getNumFlagsInappropriate() {
		if (this.numFlagsInappropriate == null) {
			return 0;
		} else {
			return this.numFlagsInappropriate;
		}
	}

	public Integer getRotateDegrees() {
		if (this.degreesRotated == null)
			this.degreesRotated = new Integer(0);
		return this.degreesRotated;
	}

	public Integer getNumFlagsSpam() {
		if (this.numFlagsSpam == null) {
			return 0;
		} else {
			return this.numFlagsSpam;
		}
	}

	public Integer getNumFlagsTotal() {
		if (this.numFlagsTotal == null) {
			return 0;
		} else {
			return this.numFlagsTotal;
		}
	}

	@Override
	public Date getDateModified() {
		// Photos cannot be modified, more or less.
		return this.dateCreated;
	}

	@Override
	public void setDateModified(Date dateModified) {
		// Photos cannot be modified, mostly.
	}

	@Override
	public void setLastEditor(Key lastEditor) {
		// Photos cannot be modified, mostly.
	}

	@Override
	public Key getLastEditor() {
		// Photos cannot be modified, mostly.
		return this.creator;
	}
}
