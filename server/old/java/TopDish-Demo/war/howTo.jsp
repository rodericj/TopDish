<%@ page import="com.topdish.util.TDUserService" %>
<%@ page import="com.topdish.exception.UserNotLoggedInException" %>
<%@ page import="com.topdish.util.PMF" %>

<jsp:include page="header.jsp" />
<div class="colleft">
<!-- TODO: when the right column removed, the main/left column should fill entire space -->
	<div class="col2">
		<div class="about">
			<h1 class="about-header">How to Use TopDish</h1>
      			<ul class="about-line-item">
                <li>
                <object id="scPlayer" class="embeddedObject" width="543" height="331" type="application/x-shockwave-flash" data="http://content.screencast.com/users/sunilsubhedar/folders/Default/media/2821c23f-9dd3-4a09-8c43-228dcd251c47/mp4h264player.swf" > <param name="movie" value="http://content.screencast.com/users/sunilsubhedar/folders/Default/media/2821c23f-9dd3-4a09-8c43-228dcd251c47/mp4h264player.swf" /> <param name="quality" value="high" /> <param name="bgcolor" value="#FFFFFF" /> <param name="flashVars" value="thumb=http://content.screencast.com/users/sunilsubhedar/folders/Default/media/2821c23f-9dd3-4a09-8c43-228dcd251c47/FirstFrame.jpg&containerwidth=1186&containerheight=663&content=http://content.screencast.com/users/sunilsubhedar/folders/Default/media/2821c23f-9dd3-4a09-8c43-228dcd251c47/Beta%20Tester%20Walkthrough.mp4&blurover=false" /> <param name="allowFullScreen" value="true" /> <param name="scale" value="showall" /> <param name="allowScriptAccess" value="always" /> <param name="base" value="http://content.screencast.com/users/sunilsubhedar/folders/Default/media/2821c23f-9dd3-4a09-8c43-228dcd251c47/" /> <iframe type="text/html" frameborder="0" scrolling="no" style="overflow:hidden;" src="http://www.screencast.com/users/sunilsubhedar/folders/Default/media/2821c23f-9dd3-4a09-8c43-228dcd251c47/embed" height="331" width="543" ></iframe> </object>
                </li>
                </ul>
		</div>
	</div> <!-- col2 -->
</div> <!--  colleft -->
<jsp:include page="footer.jsp"/>