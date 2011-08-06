package com.topdish.api;

import java.io.IOException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONArray;
import org.json.JSONObject;

import com.google.gson.Gson;
import com.topdish.api.jdo.TagLite;
import com.topdish.api.util.APIUtils;
import com.topdish.api.util.TagConstants;
import com.topdish.jdo.Tag;
import com.topdish.util.TagUtils;

/**
 * Class to feed initial data to the Mobile Phone <br>
 * To choose which {@link Tag}s are sent to the phone, simply add additional
 * {@link Tag} static integers to the "desiredTags" array <br>
 * Returns a {@link JSONArray} of {@link TagLite}s
 * 
 * @author Salil
 * 
 */
public class MobileInitServlet extends HttpServlet {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = 7130022365453837066L;

	/**
	 * DEBUG
	 */
	private static final boolean DEBUG = false;

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		// All desired Tags. To add more tags, look at the Tag file and check
		// the static int references
		final Integer[] desiredTags = new Integer[] { Tag.TYPE_MEALTYPE,
				Tag.TYPE_PRICE, Tag.TYPE_LIFESTYLE, Tag.TYPE_ALLERGEN, Tag.TYPE_CUISINE };

		final List<Tag> tagList = TagUtils.getTagsByType(desiredTags);
		
		// Array to be printed
		final JSONArray array = new JSONArray();

		// For each tag found, convert to JSON
		for(Tag t : tagList){
			final String jsonStr = new Gson().toJson(new TagLite(t));
			
			if(DEBUG)
				System.out.println("as json str: " + jsonStr);
			
			try{
				final JSONObject tagJson = new JSONObject(jsonStr);
				array.put(tagJson);
			}catch(Exception e){
				e.printStackTrace();
			}
		}

		if (DEBUG)
			System.out.println("Array: "
					+ APIUtils.generateJSONSuccessMessage(TagConstants.TAGS,
							array));

		if (array.length() > 0)
			// Write success to user
			resp.getOutputStream().print(
					APIUtils.generateJSONSuccessMessage(TagConstants.TAGS,
							array));
		else
			// Write failure to user
			resp.getOutputStream().print(
					APIUtils.generateJSONFailureMessage("No data found."));

	}
}
