<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
xmlns:xo="http://panax.io/xover"
xmlns:session="http://panax.io/session"
xmlns:sitemap="http://panax.io/sitemap"
xmlns:shell="http://panax.io/shell"
xmlns:state="http://panax.io/state"
xmlns:site="http://panax.io/site"
xmlns:meta="http://panax.io/site/meta"
				
xmlns:source="http://panax.io/xover/binding/source"
xmlns:js="http://panax.io/languages/javascript"
xmlns:login="http://panaxbi.com/widget/login"
>
	<xsl:output method="xml"
	   omit-xml-declaration="yes"
	   indent="yes"/>

	<xsl:param name="session:debug"/>
	
	<xsl:param name="session:user_login"/>
	<xsl:param name="session:status"/>
	<xsl:param name="session:connection_id"/>
	<xsl:param name="js:year">new Date().getFullYear()</xsl:param>
	<xsl:param name="js:secure"><![CDATA[location.protocol.indexOf('https')!=-1 || location.hostname=='localhost']]></xsl:param>
	<xsl:param name="site:seed"/>
	<xsl:param name="site:location-host"/>
	<xsl:param name="site:location-pathname"/>
	<xsl:param name="meta:google-signin-client_id"/>

	<xsl:template match="/*" priority="-1">
		<div class="login">
			<xsl:if test="$js:secure='true'">
				<link href="https://fonts.googleapis.com/css?family=Roboto" rel="stylesheet" type="text/css"/>
				<script src="https://accounts.google.com/gsi/client" async="" defer=""></script>
				<!--<script src="https://apis.google.com/js/platform.js" async="" defer=""></script>-->
			</xsl:if>
			<style>
				<![CDATA[
.login {
	display: -ms-flexbox;
	display: -webkit-box;
	display: flex;
	-ms-flex-align: center;
	-ms-flex-pack: center;
	-webkit-box-align: center;
	align-items: center;
	-webkit-box-pack: center;
	justify-content: center;
	padding-top: 40px;
	padding-bottom: 40px;
	background-color: #f5f5f5;
	height: 100vh;
	width: 100vw;
}

.form-signin {
	min-width: fit-content;
	max-width: 330px;
	padding: 15px;
	margin: 0 auto;
}

.form-signin .checkbox {
	font-weight: 400;
}

.form-signin .form-control {
	position: relative;
	box-sizing: border-box;
	height: auto;
	padding: 10px;
	font-size: 16px;
}

.form-signin .form-control:focus {
	z-index: 2;
}

.form-signin input[type="email"] {
	margin-bottom: -1px;
	border-bottom-right-radius: 0;
	border-bottom-left-radius: 0;
}

.form-signin input[type="password"] {
	margin-bottom: 10px;
	border-top-left-radius: 0;
	border-top-right-radius: 0;
}

.form-signin {
    text-align: center;
}

.form-signin #logo {
	max-height: 25vh;
	max-width: 25vw;
}
			]]>
			</style>
			<script src="login.js" fetchpriority="high"/>
			<form class="form-signin" onsubmit="var username=document.getElementById('username'); var password=document.getElementById('password'); xover.session.login( username, password, `{$session:connection_id}`);" action="javascript:void(0);">
				<xsl:if test="$session:status='authorized'">
					<xsl:attribute name="onsubmit"></xsl:attribute>
					<xsl:attribute name="action">#</xsl:attribute>
				</xsl:if>
				<img id="logo" src="./assets/logo.png" alt="" class="mx-auto" style="view-transition-name: transition;"/>
				<h1 class="h3 mb-3 font-weight-normal mx-auto">Bienvenido</h1>
				<xsl:choose>
					<xsl:when test="$js:secure='true'">
						<!--<label for="username" class="sr-only">Username</label>-->
						<input type="email" id="username" class="form-control" placeholder="Username" autocomplete="username" required="" autofocus="" oninvalid="this.setCustomValidity('Escriba su usuario')" oninput="this.setCustomValidity('')" value="{$session:user_login}" xo-slot="username">
							<xsl:if test="not($session:debug='true')">
								<xsl:attribute name="disabled"/>
							</xsl:if>
							<xsl:if test="@username">
								<xsl:attribute name="value">
									<xsl:value-of select="@username"/>
								</xsl:attribute>
							</xsl:if>
						</input>
						<!--<label for="password" class="sr-only">Password</label>
						<input type="password" id="password" class="form-control" placeholder="Password" autocomplete="current-password" required="" oninvalid="this.setCustomValidity('Escriba su contraseña')" oninput="this.setCustomValidity('')">
							<xsl:if test="$session:status='authorizing' or $session:status='authorized'">
								<xsl:attribute name="style">visibility:hidden;</xsl:attribute>
								<xsl:attribute name="readonly"></xsl:attribute>
							</xsl:if>
						</input>-->
						<xsl:apply-templates mode="login:button" select="."/>
						<div class="container" style="height: 60px;">
							<xsl:if test="$meta:google-signin-client_id!='' and $js:secure='true' and $session:status!='authorizing'">
								<div class="container" xo-static="self::*" style="height: 60px;">
									<!--<div class="g-signin2" data-onsuccess="onGoogleLogin" ></div>-->
									<div id="g_id_onload"
									data-client_id="{$meta:google-signin-client_id}"
									data-callback="onGoogleLogin"
									data-auto_prompt="true">
									</div>
									<div class="g_id_signin signup_button"
										 data-type="standard"
										 data-size="large"
										 data-theme="outline"
										 data-text="sign_in_with"
										 data-shape="rectangular"
										 data-logo_alignment="left">
									</div>
								</div>
							</xsl:if>
						</div>
						<p class="mt-5 mb-3 text-muted mx-auto">
							©Panax 2022 - <xsl:value-of select="$js:year"/>
						</p>
					</xsl:when>
					<xsl:otherwise>
						<h3>Visitar</h3>
						<xsl:variable name="url">
							<xsl:value-of select="concat('https://', $site:location-host, $site:location-pathname)"/>
						</xsl:variable>
						<h4>
							<a href="{$url}">
								<xsl:value-of select="$url"/>
							</a>
						</h4>
					</xsl:otherwise>
				</xsl:choose>
			</form>
			<!--<script>
				document.getElementById("username").addEventListener("animationstart", function() {
				// Username autofilled, do something
				console.log("Username autofilled");
				});

				document.getElementById("password").addEventListener("animationstart", function() {
				// Password autofilled, do something
				console.log("Password autofilled");
				});
			</script>-->
		</div>
	</xsl:template>

	<xsl:template mode="login:button" match="*|@*">
		<button class="btn btn-lg btn-primary btn-block color-orange" type="submit">
			<xsl:choose>
				<xsl:when test="$session:status='authorized'">
					<xsl:attribute name="type">button</xsl:attribute>
					<xsl:attribute name="onclick">
						<xsl:choose>
							<xsl:when test="$site:seed = '#login'">window.location='#'</xsl:when>
							<xsl:otherwise>xo.stores.seed.render()</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					Continuar
				</xsl:when>
				<xsl:when test="$meta:google-signin-client_id!=''">
					<xsl:attribute name="style">visibility:hidden !important;</xsl:attribute>
				</xsl:when>
				<xsl:when test="$session:status='authorizing'">
					Autorizando... <i class="fas fa-spinner fa-spin"></i>
				</xsl:when>
				<xsl:otherwise>Ingresar</xsl:otherwise>
			</xsl:choose>
		</button>
	</xsl:template>
</xsl:stylesheet>
