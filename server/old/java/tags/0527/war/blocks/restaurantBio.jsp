<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Set" %>
<%@ page import="javax.jdo.PersistenceManager" %>
<%@ page import="javax.jdo.Query" %>
<%@ page import="com.google.appengine.api.datastore.Key" %>
<%@ page import="com.google.appengine.api.datastore.KeyFactory" %>
<%@ page import="com.topdish.util.PMF" %>
<%@ page import="com.topdish.util.Datastore" %>
<%@ page import="com.topdish.jdo.*" %>
<%@ page import="org.apache.commons.lang.StringEscapeUtils" %>
<%@ page import="javax.jdo.JDOObjectNotFoundException" %>
<%@include file="/includes/userTagIncludes.jsp" %>
<%
	long restID = Long.valueOf(request.getParameter("restID"));
	Restaurant r = Datastore.get(KeyFactory.createKey(Restaurant.class.getSimpleName(), restID));
	TDUser creator = Datastore.get(r.getCreator());
	Tag cuisine = null;
	if(null != r.getCuisine()){
		try{
			cuisine = Datastore.get(r.getCuisine());
		}catch(JDOObjectNotFoundException e){
			//tag must not exist any more
		}
	}
%>
<div class="rmenu_cont restaurant_detail restaurant_detail_box">
	<div class="restaurant_detail_inner">
	<table>
			<tbody>
			<tr>
					<td colspan=2>
<% 
    String name = r.getName().replace("\n", "");
	if(name.length() >30){
		name = name.substring(0, 28)+"..";
	}
%>
		<h3 id="restaurant_banner_name"><% out.print(name); %></h3>
		</td>
				<tr>
					<td>
						<div class="restaurant_address">
							<% out.print(r.getAddressLine1()); %>
						</div>
					</td>
					<td class="rightColl">
						<%
							if(null != r.getNeighborhood()){
								if(r.getNeighborhood().length()!=0){
									String neighborhood = r.getNeighborhood().replace("\n", "");
									if(neighborhood.length() >17){
										neighborhood = neighborhood.substring(0, 18)+"..";
									}
						%>
						<div class="restaurant_neighborhood">
							<b>Area:</b> <% out.print(neighborhood); %>
						</div>
						<%
								}
							}
						%>
					</td>
				</tr>
				<tr>
					<td>
						<div class="restaurant_city_state">
							<% out.print(r.getCity());
							out.print(" "+r.getState());%>
						</div>
					</td>
					<td class="rightColl">
						<%
							if(null != cuisine){
						%>
						<div class="cuisine_type">
							<b>Cuisine:</b> <% out.print(cuisine.getName()); %>
						</div>
						<%
							}
						%>
					</td>
				</tr>
				<tr>
					<td>
					<div class="restaurant_phone">
						<% out.print(r.getPhone().getNumber()); %>
					</div>
					</td>
					<td class="rightColl">
						<% 
							if(!r.getUrl().toString().equals("")){
						%>
								<div class="restaurant_url">
									<a href="<% out.print(r.getUrl().toString()); %>" target="_blank">Website</a>
											<user:isUserInRole roles="${administrator},${advanced},${standard}" restaurantId="${param.restID}">
												, <a href="editRestaurant.jsp?restID=<%out.print(r.getKey().getId());%>" style="fontSize=10px;">[Edit]</a>
											</user:isUserInRole>
								</div>
						
						<%		
							}
						%>
					</td>
				</tr>
			</tbody>
		</table>
		<!--<br />
		<p>Added by: <a href="userProfile.jsp?userID=<%=creator.getKey().getId()%>"><%=creator.getNickname() %></a>  -->
	</div>
	<span style="background-image: img/shadow.png" class="shadow"></span>
</div>