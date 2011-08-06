package com.topdish;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.jdo.Query;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;
import com.topdish.jdo.TDBetaInvite;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.TDUserRole;
import com.topdish.jdo.Tag;
import com.topdish.util.PMF;

public class AddUserServlet extends HttpServlet {
	private static final long serialVersionUID = -2495174036563420120L;

	@SuppressWarnings("unchecked")
	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws IOException {

		PersistenceManager pm = PMF.get().getPersistenceManager();
		String token = req.getParameter("token");
		String nickname = req.getParameter("nickname");
		String email = req.getParameter("email").toLowerCase();
		String redirect = req.getParameter("redirect");

		// Set the Lifestyles
		String[] lifestyles = req.getParameterValues("lifestyle[]");
		List<Key> lifestyleKeys = new ArrayList<Key>();
		
		if(lifestyles != null){
			for (String l : lifestyles){
				Integer i = Integer.parseInt(l);
				Tag t = (Tag)pm.getObjectById(Tag.class, i);
				lifestyleKeys.add(t.getKey());
			}
		}		
		
		// Set the allergens
		String[] allergens = req.getParameterValues("allergen[]");
		List<Key> allergenKeys = new ArrayList<Key>();
		
		if(allergens != null){
			for (String a : allergens){
				Integer i = Integer.parseInt(a);
				Tag t = (Tag)pm.getObjectById(Tag.class, i);
				allergenKeys.add(t.getKey());
			}
		}		
		
		System.out.println("Looking for beta token: " + token);

		Query query = pm.newQuery(TDBetaInvite.class);
		query.setFilter("hashKey == hashParam");
		query.declareParameters("String hashParam");

		List<TDBetaInvite> invites = (List<TDBetaInvite>) query.execute(token);

		if (invites.size() > 0) {
			System.out.println("found beta token!");
			
			//activate beta token
			TDBetaInvite userInvite = invites.get(0);
			userInvite.setActive(true);
						
			UserService userService = UserServiceFactory.getUserService();
			User user = userService.getCurrentUser();
			TDUser tdUser=null;
			// checks if user is admin else creates with default role(standard)
			if(userService.isUserAdmin())
				 tdUser = new TDUser(user, nickname, email,TDUserRole.ROLE_ADMIN);
			else
				 tdUser = new TDUser(user, nickname, email);

			try {
				tdUser.setLifestyles(lifestyleKeys);
				tdUser.setAllergens(allergenKeys);
				pm.makePersistent(tdUser);
				pm.makePersistent(userInvite);
			} finally {
				pm.close();
			}
			resp.sendRedirect(redirect);
		} else {
			System.out.println("bad token?!?");
			resp.sendRedirect("betaLogin.jsp?status=notfound");
		}
	}
}