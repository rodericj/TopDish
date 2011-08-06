package com.topdish.api;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;

import com.google.gson.Gson;
import com.topdish.api.util.APIUtils;
import com.topdish.geo.GeoUtils;
import com.topdish.jdo.TDPoint;

/**
 * Servlet that looks up user's IP and gets back their geo location
 * 
 * @author Salil
 * 
 */
public class LocateUserServlet extends HttpServlet {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = -4459643154562048225L;

	/**
	 * DEBUG
	 */
	private static boolean DEBUG = true;

	@Override
	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		// Get the writer
		PrintWriter writer = resp.getWriter();

		// Grab the IP Address from the Request
		final String ipAddress = req.getRemoteAddr();
		// final String ipAddress = "24.205.94.144";
		
		// Check that it is not null or empty
		if (null != ipAddress && !ipAddress.isEmpty()) {
			try {

				if (DEBUG)
					System.out.println("Looking up Ip: " + ipAddress);

				// Get the Address as a TDPoint
				final TDPoint point = GeoUtils.reverseIP(ipAddress);

				if (DEBUG)
					System.out.println(point.toString());

				// Convert to JSON Object
				final JSONObject json = new JSONObject(new Gson().toJson(point));

				// Send JSON to User
				writer.write(APIUtils.generateJSONSuccessMessage(json));
				writer.flush();
				writer.close();

			} catch (Exception e) {
				e.printStackTrace();
				writer.write(APIUtils.generateJSONFailureMessage(e));
				writer.flush();
				writer.close();
			}

		} else {

			// Inform user, IP Address was not found
			writer.write(APIUtils
					.generateJSONFailureMessage("No IpAddress Was Found"));
			writer.flush();
			writer.close();
		}

	}
}
