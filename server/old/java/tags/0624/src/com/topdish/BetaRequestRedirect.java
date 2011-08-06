package com.topdish;

import java.io.IOException;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class BetaRequestRedirect extends HttpServlet{
	
	private static final long serialVersionUID = 1061436163855481482L;

	public void doGet(HttpServletRequest req, HttpServletResponse resp)
		throws IOException{
		resp.sendRedirect("https://spreadsheets.google.com/a/topdish.com/viewform?hl=en&pli=1&formkey=dFFQUmswaHMzUGdEV2VDUE5rdWttNmc6MQ#gid=0");
	}
}