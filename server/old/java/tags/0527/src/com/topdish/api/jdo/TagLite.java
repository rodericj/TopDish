package com.topdish.api.jdo;

import com.topdish.jdo.Tag;

@SuppressWarnings("unused")
public class TagLite {
	private long id;
	private String name;
	private String type;
	private long order;
	
	public TagLite(Tag t){
		this.id = t.getKey().getId();
		this.name = t.getName();
		this.type = t.getTagTypeName();
		this.order = t.getManualOrder();
	}
}
