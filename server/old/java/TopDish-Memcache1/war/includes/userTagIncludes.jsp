<%@ taglib uri="http://topdish.com/tags/user" prefix="user" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<c:set var="administrator" value="<%=com.topdish.jdo.TDUserRole.ROLE_ADMIN%>"/>
<c:set var="standard" value="<%=com.topdish.jdo.TDUserRole.ROLE_STANDARD%>"/>
<c:set var="advanced" value="<%=com.topdish.jdo.TDUserRole.ROLE_ADVANCED%>"/>