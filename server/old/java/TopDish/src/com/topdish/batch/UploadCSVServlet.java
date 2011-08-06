package com.topdish.batch;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.Charset;
import java.util.HashSet;
import java.util.Set;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.fileupload.FileItemIterator;
import org.apache.commons.fileupload.FileItemStream;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.fileupload.util.Streams;

import com.csvreader.CsvReader;
import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.datastore.KeyFactory;
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.util.Datastore;
import com.topdish.util.TDUserService;
import com.topdish.util.TagUtils;

public class UploadCSVServlet extends HttpServlet {
	private static final long serialVersionUID = 1675645634L;

	public void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException,
			ServletException {
		Key creator;
		Restaurant rest = null;
		ByteArrayInputStream csvIS = null;
		try {
			creator = TDUserService.getUser(req.getSession()).getKey();
		} catch (UserNotFoundException e) {
			throw new ServletException(e);
		} catch (UserNotLoggedInException e) {
			throw new ServletException(e);
		}

		// Process multipart/form-data
		// Check that we have a file upload request
		boolean isMultipart = ServletFileUpload.isMultipartContent(req);
		if (!isMultipart) {
			throw new ServletException("Only multipart/form-data POST allowed!");
		}

		try {
			ServletFileUpload upload = new ServletFileUpload();
			FileItemIterator iter = upload.getItemIterator(req);

			while (iter.hasNext()) {
				FileItemStream item = iter.next();
				InputStream stream = item.openStream();

				// Form elements can be posted in any order
				// make no assumptions about the order of fields
				// This causes some headaches as each item must be fully read
				// before processing the next element.
				if (item.isFormField()) {
					String field = item.getFieldName();
					String fieldVal = Streams.asString(stream);
					if (field.equals("restID")) {
						try {
							long restID = Long.parseLong(fieldVal);

							rest = Datastore.get(KeyFactory.createKey(
									Restaurant.class.getSimpleName(), restID));
						} catch (NumberFormatException e) {
							throw new ServletException("Bad restID: '" + fieldVal + "'");
						}
					}
				} else {
					// Process file data - store for later use
					byte[] fileCon = new byte[100 * 1024];
					int len = stream.read(fileCon);
					csvIS = new ByteArrayInputStream(fileCon, 0, len);
				}
			}
		} catch (Exception ex) {
			throw new ServletException(ex);
		}

		if (csvIS == null) {
			throw new ServletException("CSV file missing from upload");
		}
		if (rest == null) {
			throw new ServletException("Restaurant ID is not set:" + rest);
		}

		/*
		 * Read the uploaded CSV file and construct Dish object
		 */
		CsvReader csvRdr = new CsvReader(csvIS, Charset.forName("UTF-8"));

		csvRdr.readHeaders();
		while (csvRdr.readRecord()) {
			// construct dish object
			String tags = csvRdr.get("tags");
			Set<Key> tagsList = new HashSet<Key>(TagUtils.getTagKeysByName(tags.split(",")));
			String dishName = csvRdr.get("name");
			String dishDesc = csvRdr.get("description");
			if (dishName == null || dishDesc == null) {
				// Silently skip zombie dishes
				continue;
			}

			// This will not detect duplicates, should not be an issue as
			// CSV uploads are enabled only for restaurant users (who are
			// clueful!?)
			Dish dish = new Dish(dishName, dishDesc, rest, creator, tagsList);
			Datastore.put(dish);
		}
		csvRdr.close();

		resp.sendRedirect("/uploadCSV.jsp");
	}
}
