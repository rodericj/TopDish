package com.topdish.api;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Properties;
import java.util.UUID;

import javax.mail.Address;
import javax.mail.Message;
import javax.mail.Session;
import javax.mail.Transport;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;

import com.topdish.api.util.APIConstants;
import com.topdish.api.util.APIUtils;
import com.topdish.api.util.UserConstants;
import com.topdish.jdo.TDUser;
import com.topdish.util.Datastore;
import com.topdish.util.TDQueryUtils;

/**
 * <code>FeedbackServlet</code> serves as an API end point for user feedback.
 * 
 * @author Alex Wood
 */
public class FeedbackServlet extends HttpServlet {

	/**
	 * Serial
	 */
	private static final long serialVersionUID = 7325318116582089340L;

	/**
	 * DEBUG Tag
	 */
	private static final String TAG = FeedbackServlet.class.getSimpleName();

	/**
	 * Feedback Email Address = "dev+feedback@topdish.com"
	 */
	private static final String FEEDBACK_EMAIL_ADDRESS = "dev+feedback@topdish.com";

	/**
	 * Platform = "platform"
	 */
	private static final String PLATFORM = "platform";

	/**
	 * Feedback = "feedback"
	 */
	private static final String FEEDBACK = "feedback";

	protected void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		final PrintWriter pw = resp.getWriter();

		try {

			String userId = req.getParameter(UserConstants.TDUSER_ID);
			String userEmail = req.getParameter(APIConstants.NAME);
			String userNick = req.getParameter(UserConstants.EMAIL);

			if (null != req.getParameter(APIConstants.API_KEY)) {
				TDUser user = Datastore.get(TDQueryUtils.getUserKeyByAPIKey(req
						.getParameter(APIConstants.API_KEY)));

				userId = String.valueOf(user.getKey().getId());
				userEmail = user.getEmail();
				userNick = user.getNickname();

			}

			final String ticketID = UUID.randomUUID().toString();

			final String fromAddress = "admin@topdish.com";
			final String platform = req.getParameter(PLATFORM);

			final String message = "Ticket ID: " + ticketID + "\nName: " + userNick + "\nEmail: "
					+ userEmail + "\nTDUserId: " + userId + "\nPlatform: " + platform
					+ "\nFeedback: " + req.getParameter(FEEDBACK);

			final Properties properties = new Properties();
			Session session = Session.getDefaultInstance(properties, null);

			final Message emailMessage = new MimeMessage(session);
			emailMessage.setFrom(new InternetAddress(fromAddress));
			emailMessage.setReplyTo(new Address[] { new InternetAddress(FEEDBACK_EMAIL_ADDRESS) });
			emailMessage.addRecipient(Message.RecipientType.TO, new InternetAddress(
					FEEDBACK_EMAIL_ADDRESS));
			emailMessage.setSubject("[Feedback] " + (null != platform ? platform : new String())
					+ " " + ticketID);
			emailMessage.setText(message);
			Transport.send(emailMessage);

			// Print to logger
			final ByteArrayOutputStream baos = new ByteArrayOutputStream();
			emailMessage.writeTo(baos);
			Logger.getLogger(TAG).info(baos.toString("UTF-8"));

			pw.write(APIUtils.generateJSONSuccessMessage());

		} catch (Exception e) {
			e.printStackTrace();
			Logger.getLogger(TAG).error(e.getMessage());
			pw.write(APIUtils.generateJSONFailureMessage(e));
		} finally {
			pw.flush();
			pw.close();
		}
	}
}
