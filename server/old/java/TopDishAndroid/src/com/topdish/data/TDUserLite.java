package com.topdish.data;

public class TDUserLite {

	public String id;
	public String nickname;
	public String email;
	public String ApiKey;

	/**
	 * @param id
	 * @param nickname
	 * @param email
	 * @param apiKey
	 */
	public TDUserLite(String id, String nickname, String email, String apiKey) {
		super();
		this.id = id;
		this.nickname = nickname;
		this.email = email;
		ApiKey = apiKey;
	}

}
