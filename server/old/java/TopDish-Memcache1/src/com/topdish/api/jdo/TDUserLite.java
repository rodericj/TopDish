package com.topdish.api.jdo;

import com.topdish.jdo.TDUser;

public class TDUserLite {

	String id;
	String nickname;
	String email;
	String ApiKey;

	/**
	 * Create the Lite version of a TDUser
	 * 
	 * @param user
	 *            - user as a {@link TDUser}
	 */
	public TDUserLite(TDUser user) {
		this.id = String.valueOf(user.getKey().getId());
		this.nickname = user.getNickname();
		this.email = user.getEmail();
		this.ApiKey = user.getApiKey();
	}

}
