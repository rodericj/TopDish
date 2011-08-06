package com.topdish.comms;

import android.app.ProgressDialog;
import android.os.Handler;
import android.os.Message;
import android.widget.ProgressBar;

public abstract class ResponseHandler extends Handler {

	public ProgressDialog progressDiag;
	protected ProgressBar progressBar;
	protected boolean killswitch = false;

	@Override
	public void handleMessage(Message msg) {
		if (!killswitch)
			switch (msg.what) {
			case HTTPComms.START:
				doStart(msg);
				break;
			case HTTPComms.SUCCESS:
				doSuccess(msg);
				break;
			case HTTPComms.ERROR:
				doError(msg);
				break;
			default:
				break;
			}
		// super.handleMessage(msg);
	}

	/**
	 * Handle Start
	 * 
	 * @param msg
	 */
	public abstract void doStart(Message msg);

	/**
	 * Handle Success
	 * 
	 * @param msg
	 */
	public abstract void doSuccess(Message msg);

	/**
	 * Handle Error
	 * 
	 * @param msg
	 */
	public abstract void doError(Message msg);

}
