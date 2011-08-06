package com.topdish.jdo;

import java.util.Date;
import java.util.List;

import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.datastore.Key;

@PersistenceCapable
public class Photo implements TDPersistable{
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
	
	/**
	 * Constructor for a Photo
	 * @param blobKey
	 * @param description
	 * @param creator
	 */
	public Photo(BlobKey blobKey, String description,
			Key creator) {
		this.blobKey = blobKey;
		this.description = description;
		this.dateCreated = new Date();
		this.creator = creator;
		this.degreesRotated = new Integer(0);
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
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public void setDateModified(Date dateModified) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void setLastEditor(Key lastEditor) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public Key getLastEditor() {
		// TODO Auto-generated method stub
		return null;
	}
}
