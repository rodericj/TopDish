package com.topdish.jdo;

import java.io.Serializable;
import java.util.Date;

import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.Link;
import com.topdish.util.TDQueryUtils;

/**
 * Object for things that are {@link Source}d from other sites
 * 
 * @author Salil
 * 
 */
@PersistenceCapable
public class Source implements TDPersistable, Serializable {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * The datastore key of this object
	 */
	@PrimaryKey
	@Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
	private Key key;

	/**
	 * Source's name
	 */
	@Persistent
	private String name;

	/**
	 * Source's {@link Link}
	 */
	@Persistent
	private Link url;

	/**
	 * The date this restaurant was created
	 */
	@Persistent
	private Date dateCreated;

	/**
	 * The date this restaurant was last modified
	 */
	@Persistent
	private Date dateModified;

	/**
	 * The key of the creator of this object
	 */
	@Persistent
	private Key creator;

	/**
	 * The key of the last editor of this object
	 */
	@Persistent
	private Key lastEditor;

	/**
	 * Constructor to create a {@link Source} with a name
	 * 
	 * @param name
	 *            - the name of the source
	 */
	public Source(String name) {
		this(name, null);
	}

	/**
	 * Constructor to create a Source with a name and {@link Link}
	 * 
	 * @param name
	 *            - the name of source
	 * @param url
	 *            - the {@link Link} or the source
	 */
	public Source(String name, Link url) {
		this.name = name.toLowerCase();
		this.url = url;
		this.creator = TDQueryUtils.getDefaultUser();
		this.dateCreated = new Date();
		this.dateModified = new Date();
		this.lastEditor = TDQueryUtils.getDefaultUser();
	}

	/**
	 * Get the {@link Key}
	 * 
	 * @return the {@link Source}'s {@link Key}
	 */
	public Key getKey() {
		return this.key;
	}

	/**
	 * Get the name
	 * 
	 * @return the {@link Source}'s name
	 */
	public String getName() {
		return this.name;
	}

	/**
	 * Get {@link Link}
	 * 
	 * @return
	 */
	public Link getUrl() {
		return this.url;
	}

	@Override
	public boolean equals(Object obj) {
		return (obj instanceof Source && ((Source) obj).getName()
				.equalsIgnoreCase(this.name));
	}

	@Override
	public Key getCreator() {
		
		if(null == this.creator)
			this.creator = TDQueryUtils.getDefaultUser();
		
		return this.creator;
	}

	@Override
	public Date getDateCreated() {
		return this.dateCreated;
	}

	@Override
	public Date getDateModified() {
		return this.dateModified;
	}

	@Override
	public Key getLastEditor() {
		return this.lastEditor;
	}

	@Override
	public void setDateModified(Date dateModified) {
		this.dateModified = dateModified;
	}

	@Override
	public void setLastEditor(Key lastEditor) {
		this.lastEditor = lastEditor;
	}

}
