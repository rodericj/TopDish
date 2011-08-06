package com.topdish;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import uk.ac.shef.wit.simmetrics.similaritymetrics.Levenshtein;

import com.beoui.geocell.model.Point;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.topdish.jdo.Restaurant;
import com.topdish.jdo.TDPoint;
import com.topdish.util.PMF;
import com.topdish.util.TDQueryUtils;
import com.topdish.util.TDUserService;

public class RestaurantAutoCompleteServlet extends HttpServlet {
	private static final long serialVersionUID = -1492815565845836404L;

	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {
		String yelpAPIKey = "uQ-6pLlOtEUcb07XzN-eSw";
		String name = req.getParameter("q");
		String latS = req.getParameter("lat"); // can return ""
		String lngS = req.getParameter("lng");
		double lat = 0;
		double lng = 0;
		int maxResults = 6;
		int maxDistance = 0; // meters //a 0 value will search until max # of
		// results is reached
		PersistenceManager pm = PMF.get().getPersistenceManager();
		Point p = null;
		boolean yelp = true;

		try {
			lat = Double.valueOf(latS);
			lng = Double.valueOf(lngS);
		} catch (Exception e) {
			if (TDUserService.getUserLoggedIn())
				p = ((TDPoint)req.getSession().getAttribute("userLocationPoint")).getPoint();
				//p = TDUserService.getUserLocation(req);
			
		}

		if (p != null) {
			lat = p.getLat();
			lng = p.getLon();
		}

		String[] queryWords = name.split(" ");

		List<Restaurant> searchResults = TDQueryUtils.searchGeoItems(
				queryWords, new Point(lat, lng), maxResults, maxDistance,
				new Restaurant());

		name = name.replace(" ", "+");
		int totalSize = searchResults.size();
		Gson gson = new Gson();
		JsonArray jsa = null;

		if (yelp) {
			URL url = new URL(
					"http://api.yelp.com/business_review_search?term=" + name
							+ "&category=restaurants+nightlife+food&lat=" + lat
							+ "&long=" + lng + "&radius=" + maxDistance
							+ "&limit=" + maxResults + "&ywsid=" + yelpAPIKey);

			// Make connection
			URLConnection con = url.openConnection();
			con.setDoOutput(true);

			// get result
			BufferedReader br = new BufferedReader(new InputStreamReader(
					con.getInputStream()));

			JsonElement jse = null;
			jse = new JsonParser().parse(br);
			br.close();

			jsa = jse.getAsJsonObject().getAsJsonArray("businesses");
			totalSize += jsa.size();

			if (jsa.size() == 0) {
				System.out.println("YELP API QUOTA EXCEEDED");
			}
		}

		// Google API
		// String googleResults = doGoogleApiSearch(lat, lng);

		resp.getWriter().print("[\n");
		if (totalSize > 0) {
			try {
				ArrayList<String> restNamesFound = new ArrayList<String>();

				for (int i = 0; i < searchResults.size(); i++) {
					Restaurant r = searchResults.get(i);
					restNamesFound.add(r.getName());
					String json = gson.toJson(r);
					resp.getWriter().print(json);
					if (i < totalSize - 1) {
						resp.getWriter().print(",\n");
					} else {
						resp.getWriter().print("\n");
					}
				}

				if (yelp) {
					for (int i = 0; i < jsa.size(); i++) {
						JsonElement jobj = jsa.get(i);
						String json = gson.toJson(jobj);

						// check if this item is already in our results
						JsonObject jso = (JsonObject) jsa.get(i);
						JsonElement nameElement = jso.get("name");
						String restName = nameElement.getAsString();
						Levenshtein lev = new Levenshtein();
						boolean matchFound = false;

						// System.out.println("Yelp name: " + restName);

						for (String foundName : restNamesFound) {
							// System.out.println("Found name: " + foundName +
							// " lev dist: " + lev.getSimilarity(foundName,
							// restName));

							if (lev.getSimilarity(foundName, restName) > .8) {
								matchFound = true;
								// System.out.println("FUZZY name match found!");
								break;
							}
						}

						if (!matchFound) {
							resp.getWriter().print(json);
							if (i < jsa.size() - 1) {
								resp.getWriter().print(",\n");
							} else {
								resp.getWriter().print("\n");
							}
						}
					}
				}
			} finally {
				pm.close();
			}
		}
		resp.getWriter().print("]");
	}
	/*
	 * public String doGoogleApiSearch(double lat, double lng) { //
	 * System.out.println("DOING GOOGLE SEARCH\t" // +
	 * this.getClass().getCanonicalName()); // ScriptEngineManager manager = new
	 * ScriptEngineManager(); // ScriptEngine engine =
	 * manager.getEngineByName("js"); // try { // final InputStream inputStream
	 * = this.getClass() // .getResourceAsStream("topdish.localsearch.js"); //
	 * final Reader inputReader = new InputStreamReader(inputStream); // //
	 * FileReader reader = new FileReader(inputReader); // Invocable invoke =
	 * (Invocable) engine.eval(inputReader); //
	 * System.out.println(invoke.invokeFunction("localSearch", lat, lng)); // //
	 * reader.close(); // inputReader.close(); // } catch (Exception e) { //
	 * e.printStackTrace(); // } // return "WHEEE"; try { final URL url = new
	 * URL( "http://localhost:8888/quickSearch.jsp");
	 * 
	 * InputStreamReader isr = new InputStreamReader(url.openStream());
	 * BufferedReader budd = new BufferedReader(isr); String cur; String total =
	 * ""; while(null != (cur = budd.readLine())) { System.out.println(cur);
	 * total += cur; }
	 * 
	 * } catch (Exception e) { e.printStackTrace(); } return null; }
	 * 
	 * public void getFromFbook(double lat, double lon, HttpServletRequest req)
	 * {
	 * 
	 * FacebookJsonRestClient fjc =
	 * FacebookLoginServlet.getFacebookJsonRestClient(req); // fjc.
	 * 
	 * }
	 */

}