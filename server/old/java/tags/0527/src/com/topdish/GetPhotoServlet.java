package com.topdish;

import java.io.IOException;
import java.io.OutputStream;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.images.Image;
import com.google.appengine.api.images.ImagesService;
import com.google.appengine.api.images.ImagesServiceFactory;
import com.google.appengine.api.images.Transform;
import com.google.apphosting.api.ApiProxy.ApiDeadlineExceededException;
import com.topdish.jdo.Photo;
import com.topdish.util.Datastore;

public class GetPhotoServlet extends HttpServlet {
	private static final long serialVersionUID = -1574206743806514698L;
	private BlobstoreService blobstoreService = BlobstoreServiceFactory
			.getBlobstoreService();

	public void doGet(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {

		long photoID = Long.parseLong(req.getParameter("id"));
		String widthS = req.getParameter("w");
		String heightS = req.getParameter("h");
		int width = 0;
		int height = 0;

		if (widthS != null && widthS != "") {
			try {
				width = Integer.parseInt(widthS);
			} catch (NumberFormatException e) {
				// not valid input
			}
		}

		if (heightS != null & heightS != "") {
			try {
				height = Integer.parseInt(heightS);
			} catch (NumberFormatException e) {
				// not valid input
			}
		}
		Photo p = Datastore.get(KeyFactory.createKey(Photo.class.getSimpleName(), photoID));
		ImagesService imagesService = ImagesServiceFactory.getImagesService();
		Image oldImage = null;
		if (null != p.getBlobKey()) {
			oldImage = ImagesServiceFactory.makeImageFromBlob(p.getBlobKey());
		}
		Image newImage = oldImage;
		if (width > 0 && height > 0) {
			Transform resize = ImagesServiceFactory.makeResize(width, height);
			try {
				newImage = imagesService.applyTransform(resize, oldImage);
			} catch (ApiDeadlineExceededException e) {
				// ignore this call if it took too long
			}
		}
		if (p.getRotateDegrees() > 0) {
			Transform rotate = ImagesServiceFactory.makeRotate(p
					.getRotateDegrees());
			newImage = imagesService.applyTransform(rotate, newImage);
		}
		byte[] newImageData = newImage.getImageData();
		if (newImageData != null) {
			resp.setContentType(newImage.getFormat().toString());
			OutputStream os = resp.getOutputStream();
			os.write(newImageData);
		} else {
			blobstoreService.serve(p.getBlobKey(), resp);
		}
	}
}