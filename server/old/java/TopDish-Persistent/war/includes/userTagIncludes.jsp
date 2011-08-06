<%@ taglib uri="http://topdish.com/tags/user" prefix="user" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<c:set var="administrator" value="<%=com.topdish.jdo.TDUserRole.ROLE_ADMIN%>"/>
<c:set var="standard" value="<%=com.topdish.jdo.TDUserRole.ROLE_STANDARD%>"/>
<c:set var="advanced" value="<%=com.topdish.jdo.TDUserRole.ROLE_ADVANCED%>"/>
<c:set var="ACTION_SEARCH" value="<%=com.topdish.adminconsole.TopDishConstants.ACTION_SEARCH%>"/>
<c:set var="CALL_TYPE_AJAX" value="<%=com.topdish.adminconsole.TopDishConstants.CALL_TYPE_AJAX%>"/>
<c:set var="CALL_TYPE_NONAJAX" value="<%=com.topdish.adminconsole.TopDishConstants.CALL_TYPE_NONAJAX%>"/>
<c:set var="ACTION_EDIT" value="<%=com.topdish.adminconsole.TopDishConstants.ACTION_EDIT%>"/>
<c:set var="ENTITY_DISH" value="<%=com.topdish.adminconsole.TopDishConstants.ENTITY_DISH%>"/>
<c:set var="ENTITY_RESTAURANT" value="<%=com.topdish.adminconsole.TopDishConstants.ENTITY_RESTAURANT%>"/>
<c:set var="ACTION_RSTRDISHES" value="<%=com.topdish.adminconsole.TopDishConstants.ACTION_RSTRDISHES%>"/>
<c:set var="ACTION_DISHREVIEWS" value="<%=com.topdish.adminconsole.TopDishConstants.ACTION_DISHREVIEWS%>"/>
<c:set var="ENTITY_TAGS" value="<%=com.topdish.adminconsole.TopDishConstants.ENTITY_TAGS%>"/>
<c:set var="ENTITY_REVIEWS" value="<%=com.topdish.adminconsole.TopDishConstants.ENTITY_REVIEWS%>"/>
<c:set var="ACTION_VIEWDISHES" value="<%=com.topdish.adminconsole.TopDishConstants.ACTION_VIEWDISHES%>"/>
<c:set var="ACTION_VIEWRESTAURANT" value="<%=com.topdish.adminconsole.TopDishConstants.ACTION_VIEWRESTAURANT%>"/>
<c:set var="ACTION_VIEWREVIEW" value="<%=com.topdish.adminconsole.TopDishConstants.ACTION_VIEWREVIEW%>"/>
<c:set var="ACTION_VIEWPHOTO" value="<%=com.topdish.adminconsole.TopDishConstants.ACTION_VIEWPHOTO%>"/>



<c:set var="TYPE_GENERAL" value="<%=com.topdish.jdo.Tag.TYPE_GENERAL%>"/>
<c:set var="TYPE_CUISINE" value="<%=com.topdish.jdo.Tag.TYPE_CUISINE%>"/>
<c:set var="TYPE_LIFESTYLE" value="<%=com.topdish.jdo.Tag.TYPE_LIFESTYLE%>"/>
<c:set var="TYPE_PRICE" value="<%=com.topdish.jdo.Tag.TYPE_PRICE%>"/>
<c:set var="TYPE_LIFESTYLE" value="<%=com.topdish.jdo.Tag.TYPE_LIFESTYLE%>"/>
<c:set var="TYPE_MEALTYPE" value="<%=com.topdish.jdo.Tag.TYPE_MEALTYPE%>"/>
<c:set var="TYPE_INGREDIENT" value="<%=com.topdish.jdo.Tag.TYPE_INGREDIENT%>"/>
