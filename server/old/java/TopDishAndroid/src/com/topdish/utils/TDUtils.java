package com.topdish.utils;

import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;

import org.json.JSONObject;

import android.app.Activity;
import android.app.Application;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnCancelListener;
import android.os.Looper;
import android.os.Message;
import android.util.Log;
import android.widget.Toast;

import com.topdish.TDApp;
import com.topdish.api.util.APIConstants;
import com.topdish.api.util.DishConstants;
import com.topdish.comms.HTTPComms;
import com.topdish.comms.ResponseHandler;
import com.topdish.data.Dish;
import com.topdish.data.SearchAction;

public class TDUtils {

	/**
	 * DEBUG Tag
	 */
	private static final String TAG = TDUtils.class.getSimpleName();

	/**
	 * UTF-8 Encoding
	 */
	private static final String UTF_8 = "UTF-8";

	/**
	 * {@link #UTF_8} decode a {@link String}
	 * 
	 * @param str
	 *            - the {@link String} to be decoded
	 * @return the {@link #UTF_8} decoded {@link String} or the original
	 *         {@link String} if the decoding failed
	 */
	public static String stringDecode(String str) {
		try {
			return URLDecoder.decode(str, UTF_8);
		} catch (UnsupportedEncodingException e) {
			return str;
		}
	}

	/**
	 * Create a Search {@link Dish} {@link HTTPComms}
	 * 
	 * @param from
	 *            - {@link Activity} you are coming from
	 * @param to
	 *            - {@link Activity} you want to go to
	 * @param mAppState
	 *            - the current {@link Application} state, {@link TDApp}
	 * @return an {@link HTTPComms} that handles {@link Dish} Search
	 */
	public static HTTPComms generateDishSearchComms(final Context from, final Class<?> to, final TDApp mAppState, final SearchAction action) {
		final HTTPComms comms = new HTTPComms();
		return comms.setHandler(new ResponseHandler() {

			@Override
			public void doStart(Message msg) {

				if (null == progressDiag) {

					progressDiag = new ProgressDialog(from);
					progressDiag.setTitle("Searching for Dishes");
					progressDiag.setMessage("Searching for dishes near you...");

					progressDiag.setOnCancelListener(new OnCancelListener() {

						@Override
						public void onCancel(DialogInterface dialog) {
							// Kills comms if it already happening
							try {
								comms.interrupt();
								Thread.currentThread().interrupt();
							} catch (Exception e) {
								e.printStackTrace();
							}
							killswitch = true;
							progressDiag.dismiss();
						}
					});

				}

				progressDiag.show();

			}

			@Override
			public void doSuccess(Message msg) {
				try {
					Looper.prepare();
					final JSONObject resultObject = new JSONObject(String.valueOf(msg.obj));
					if (!killswitch && HTTPComms.checkError(resultObject.getInt(APIConstants.RETURN_CODE))) {
						mAppState.dishes.clear();
						mAppState.dishes.putAll(DishUtils.convertJSONArrayToDishArray(resultObject
								.getJSONArray(DishConstants.DISHES)));
						Log.d(TAG, "Added " + mAppState.dishes.size() + " dishes.");

						if (!killswitch) {
							// Send off to Results
//							Intent intent = new Intent(from, to);
//							from.startActivity(intent);
							action.doAction();
						}
					} else {

						if (!killswitch)
							Toast.makeText(from.getApplicationContext(), "No dishes found, please expand your search.",
									Toast.LENGTH_SHORT).show();

					}

				} catch (Exception e) {
					e.printStackTrace();
				} finally {
					if (progressDiag.isShowing())
						progressDiag.dismiss();
					Looper.loop();
				}

			}

			@Override
			public void doError(Message msg) {
				Looper.prepare();
				if (progressDiag.isShowing())
					progressDiag.dismiss();
				Toast.makeText(from.getApplicationContext(), "No dishes found, please expand your search.",
						Toast.LENGTH_SHORT).show();
				Looper.loop();
			}
		});

	}
}
