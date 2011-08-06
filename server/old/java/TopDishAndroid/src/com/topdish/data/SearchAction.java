package com.topdish.data;

import android.content.Context;

public abstract class SearchAction {

	/**
	 * Current {@link Context}
	 */
	protected Context mContext;

	/**
	 * Constructor to take a {@link Context}
	 * 
	 * @param context
	 *            - current {@link Context}
	 */
	public SearchAction(Context context) {
		this.mContext = context;
	}

	/**
	 * Complete a specific Action post search <br>
	 * <b>Note:</b> You have access to {@link SearchAction}'s {@link #mContext}
	 * 
	 * @return true if successful, false otherwise
	 */
	public abstract boolean doAction();

}
