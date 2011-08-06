package com.topdish;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.jdo.PersistenceManager;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.datastore.Key;
import com.topdish.jdo.TDUser;
import com.topdish.jdo.Tag;
import com.topdish.util.PMF;

public class UpdateUserServlet extends HttpServlet {
	private static final long serialVersionUID = 632733181194368523L;

	public void doPost(HttpServletRequest req, HttpServletResponse resp) 
    	throws IOException {
		
		String nickname = req.getParameter("nickname");
		String email = req.getParameter("email").toLowerCase();
		String bio = req.getParameter("bio");
		if(bio.length() > 100){
			bio = bio.substring(0, 100);
		}
		Long userKey = Long.valueOf(req.getParameter("userKey"));
		
		String[] lifestyles = req.getParameterValues("lifestyle[]");
		List<Key> lifestyleKeys = new ArrayList<Key>();
		
		PersistenceManager pm = PMF.get().getPersistenceManager();
		
		if(lifestyles != null){
			for (String l : lifestyles){
				Integer i = Integer.parseInt(l);
				Tag t = (Tag)pm.getObjectById(Tag.class, i);
				lifestyleKeys.add(t.getKey());
			}
		}
		
		String[] allergens = req.getParameterValues("allergen[]");
		List<Key> allergenKeys = new ArrayList<Key>();
		
		if(allergens != null){
			for (String a : allergens){
				Integer i = Integer.parseInt(a);
				Tag t = (Tag)pm.getObjectById(Tag.class, i);
				allergenKeys.add(t.getKey());
			}
		}
		
		TDUser tdUser = pm.getObjectById(TDUser.class, userKey);
		
		try {
			tdUser.setEmail(email);
			tdUser.setNickname(nickname);
			tdUser.setBio(bio);
			tdUser.setLifestyles(lifestyleKeys);
			tdUser.setAllergens(allergenKeys);
			pm.makePersistent(tdUser);
		}
		finally {
			pm.close();
		}
		resp.sendRedirect("userProfile.jsp");
	}
}