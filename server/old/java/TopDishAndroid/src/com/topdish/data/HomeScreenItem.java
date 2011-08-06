package com.topdish.data;

import android.content.Context;
import android.graphics.drawable.Drawable;

public abstract class HomeScreenItem {

	public String title;
	public Drawable icon;

	public HomeScreenItem(String title, Drawable icon) {
		super();
		this.title = title;
		this.icon = icon;
	}

	public abstract void doAction(Context context);

}
