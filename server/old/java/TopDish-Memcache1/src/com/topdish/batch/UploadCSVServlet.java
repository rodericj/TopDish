package com.topdish.batch;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.Charset;
import java.util.Date;
import java.util.List;

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
import com.topdish.exception.UserNotFoundException;
import com.topdish.exception.UserNotLoggedInException;
import com.topdish.jdo.Dish;
import com.topdish.jdo.Restaurant;
import com.topdish.util.PMF;
import com.topdish.util.TDUserService;
import com.topdish.util.TagUtils;

public class UploadCSVServlet extends HttpServlet {
	private static final long serialVersionUID = 1675645634L;

	public void doPost(HttpServletRequest req, HttpServletResponse resp)
	throws IOException, ServletException {
		Key creator;
		Restaurant restID = null;
		ByteArrayInputStream csvIS = null;
		try {
			creator = TDUserService.getUser(PMF.get().getPersistenceManager()).getKey();
		} catch(UserNotFoundException e) {
			throw new ServletException(e);
		} catch(UserNotLoggedInException e) {
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
						try{
							restID = PMF.get().getPersistenceManager().getObjectById(Restaurant.class, Long.parseLong(fieldVal));
						}catch(NumberFormatException e){
							throw new ServletException("Bad restID: '" + fieldVal + "'");
						}
					}
				} else {
					// Process file data - store for later use
					byte[] fileCon = new byte[100*1024];
					int len = stream.read(fileCon);
					csvIS = new ByteArrayInputStream(fileCon, 0, len);
				}
			}
		}  catch (Exception ex) {
			throw new ServletException(ex);
		}

		if (csvIS == null) {
			throw new ServletException("CSV file missing from upload");
		}
		if (restID == null) {
			throw new ServletException("Restaurant ID is not set:" + restID);
		}
		
		/* Read the uploaded CSV file and construct
		 * Dish object
		 */
		CsvReader csvRdr = new CsvReader(csvIS, Charset.forName("US-ASCII"));

		csvRdr.readHeaders();
		while (csvRdr.readRecord()) {
			// construct dish object
			String tags = csvRdr.get("tags");
			List<Key> tagsList = TagUtils.getTagKeysByName(tags.split(","));
			String dishName = csvRdr.get("name");
			String dishDesc = csvRdr.get("description");
			if (dishName == null || dishDesc == null) {
				// Silently skip zombie dishes
				continue;
			}
			
			// This will not detect duplicates, should not be an issue as
			// CSV uploads are enabled only for restaurant users (who are clueful!?)
			Dish dish = new Dish(dishName,
					dishDesc,
					restID,
					new Date(),
					creator,
					tagsList);
			PMF.get().getPersistenceManager().makePersistent(dish);
		}
		csvRdr.close();

		resp.sendRedirect("/uploadCSV.jsp");
	}
}

