<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns="http://www.w3.org/1999/xhtml"
xmlns:js="http://panax.io/xover/javascript"
xmlns:session="http://panax.io/session"
xmlns:sitemap="http://panax.io/sitemap"
xmlns:shell="http://panax.io/shell"
xmlns:state="http://panax.io/state"
xmlns:xo="http://panax.io/xover"
xmlns:initial="http://panax.io/state/initial"
xmlns:prev="http://panax.io/state/prev"
exclude-result-prefixes="#default session sitemap shell xo state js"
>
	<xsl:output method="xml"
		 omit-xml-declaration="yes"
		 indent="yes"/>

	<xsl:template match="/">
		<div class="container-fluid">
			<xo-listener node="security"/>
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<xsl:key name="access" match="access/@level" use="concat(../@user,'::',../@module)"/>

	<xsl:key name="changes" match="access[@state:dirty='true']/@level" use="'*'"/>
	<xsl:key name="changes" match="access[@initial:level!=@level]/@level" use="'*'"/>

	<xsl:template match="model">
		<style>
			<![CDATA[
:root {
  --header-bg-color: black
}
      
table td.freeze, table th.freeze {
    background-color: white;
}

table thead tr.freeze td, table thead tr.freeze th {
    position: sticky;
    background-color: var(--header-bg-color);
}

table > thead > tr.freeze:nth-child(1) > td, table > thead > tr.freeze:nth-child(1) > th {
    top: 0px;
}

table > thead > tr.freeze:nth-child(2) > td, table > thead > tr.freeze:nth-child(2) > th {
    top: 20px;
}

table > thead > tr.freeze:nth-child(3) > td, table > thead > tr.freeze:nth-child(3) > th {
    top: 40px;
}

table > thead > tr.freeze:nth-child(4) > td, table > thead > tr.freeze:nth-child(4) > th {
    top: 60px;
}

table > thead > tr.freeze:nth-child(5) > td, table > thead > tr.freeze:nth-child(5) > th {
    top: 80px;
}

table tr.freeze td.freeze, table tr.freeze th.freeze {
    z-index: 911;
}

table tr.freeze td.freeze img, table tr.freeze th.freeze img {
    z-index: 912;
}

thead th, thead {
    outline: solid 2pt gray;
}

table
	{mso-displayed-decimal-separator:"\.";
	mso-displayed-thousand-separator:"\,";}
.xl153051
	{padding-top:1px;
	padding-right:1px;
	padding-left:1px;
	mso-ignore:padding;
	color:black;
	font-size:11.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:Calibri, sans-serif;
	mso-font-charset:0;
	mso-number-format:General;
	text-align:general;
	vertical-align:bottom;
	mso-background-source:auto;
	mso-pattern:auto;
	white-space:nowrap;}
.xl653051
	{padding-top:1px;
	padding-right:1px;
	padding-left:1px;
	mso-ignore:padding;
	color:white;
	font-size:14.0pt;
	font-weight:700;
	font-style:normal;
	text-decoration:none;
	font-family:Calibri, sans-serif;
	mso-font-charset:0;
	mso-number-format:General;
	text-align:general;
	vertical-align:bottom;
	border:.5pt solid windowtext;
	background:black;
	mso-pattern:black none;
	white-space:nowrap;}
.xl663051
	{padding-top:1px;
	padding-right:1px;
	padding-left:1px;
	mso-ignore:padding;
	color:#0563C1;
	font-size:11.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:underline;
	text-underline-style:single;
	font-family:Calibri, sans-serif;
	mso-font-charset:0;
	mso-number-format:General;
	text-align:general;
	vertical-align:bottom;
	border:.5pt solid windowtext;
	background:white;
	mso-pattern:black none;
	white-space:nowrap;}
.xl673051
	{padding-top:1px;
	padding-right:1px;
	padding-left:1px;
	mso-ignore:padding;
	color:#0563C1;
	font-size:11.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:underline;
	text-underline-style:single;
	font-family:Calibri, sans-serif;
	mso-font-charset:0;
	mso-number-format:General;
	text-align:general;
	vertical-align:bottom;
	border:.5pt solid windowtext;
	mso-background-source:auto;
	mso-pattern:auto;
	white-space:nowrap;}
.xl683051
	{padding-top:1px;
	padding-right:1px;
	padding-left:1px;
	mso-ignore:padding;
	color:black;
	font-size:11.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:Calibri, sans-serif;
	mso-font-charset:0;
	mso-number-format:General;
	text-align:general;
	vertical-align:bottom;
	border:.5pt solid windowtext;
	mso-background-source:auto;
	mso-pattern:auto;
	white-space:nowrap;}
.xl693051
	{padding-top:1px;
	padding-right:1px;
	padding-left:1px;
	mso-ignore:padding;
	color:black;
	font-size:11.0pt;
	font-weight:700;
	font-style:normal;
	text-decoration:none;
	font-family:Calibri, sans-serif;
	mso-font-charset:0;
	mso-number-format:General;
	text-align:center;
	vertical-align:middle;
	border:.5pt solid windowtext;
	background:#FFC000;
	mso-pattern:black none;
	white-space:nowrap;}
.xl703051
	{padding-top:1px;
	padding-right:1px;
	padding-left:1px;
	mso-ignore:padding;
	color:white;
	font-size:12.0pt;
	font-weight:700;
	font-style:normal;
	text-decoration:none;
	font-family:Calibri, sans-serif;
	mso-font-charset:0;
	mso-number-format:General;
	text-align:center;
	vertical-align:middle;
	border:.5pt solid windowtext;
	background:#4472C4;
	mso-pattern:black none;
	white-space:nowrap;}
.xl713051
	{padding-top:1px;
	padding-right:1px;
	padding-left:1px;
	mso-ignore:padding;
	color:white;
	font-size:14.0pt;
	font-weight:700;
	font-style:normal;
	text-decoration:none;
	font-family:Calibri, sans-serif;
	mso-font-charset:0;
	mso-number-format:General;
	text-align:center;
	vertical-align:bottom;
	border-top:none;
	border-right:.5pt solid windowtext;
	border-bottom:none;
	border-left:.5pt solid windowtext;
	background:black;
	mso-pattern:black none;
	white-space:nowrap;}
.xl723051
	{padding-top:1px;
	padding-right:1px;
	padding-left:1px;
	mso-ignore:padding;
	color:black;
	font-size:11.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:Calibri, sans-serif;
	mso-font-charset:0;
	mso-number-format:General;
	text-align:center;
	vertical-align:bottom;
	mso-background-source:auto;
	mso-pattern:auto;
	white-space:nowrap;}
.xl733051
	{padding-top:1px;
	padding-right:1px;
	padding-left:1px;
	mso-ignore:padding;
	color:black;
	font-size:11.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:Calibri, sans-serif;
	mso-font-charset:0;
	mso-number-format:General;
	text-align:center;
	vertical-align:bottom;
	background:limegreen;
	mso-pattern:black none;
	white-space:nowrap;}
.xl743051
	{padding-top:1px;
	padding-right:1px;
	padding-left:1px;
	mso-ignore:padding;
	color:black;
	font-size:11.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:Calibri, sans-serif;
	mso-font-charset:0;
	mso-number-format:General;
	text-align:center;
	vertical-align:bottom;
	background:var(--disabled-module,#dee2e6);
	mso-pattern:black none;
	white-space:nowrap;}
.xl753051
	{padding-top:1px;
	padding-right:1px;
	padding-left:1px;
	mso-ignore:padding;
	color:black;
	font-size:11.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:Calibri, sans-serif;
	mso-font-charset:0;
	mso-number-format:General;
	text-align:center;
	vertical-align:bottom;
	background:yellow;
	mso-pattern:black none;
	white-space:nowrap;}
.xl763051
	{padding-top:1px;
	padding-right:1px;
	padding-left:1px;
	mso-ignore:padding;
	color:white;
	font-size:14.0pt;
	font-weight:700;
	font-style:normal;
	text-decoration:none;
	font-family:Calibri, sans-serif;
	mso-font-charset:0;
	mso-number-format:General;
	text-align:center;
	vertical-align:bottom;
	border:.5pt solid windowtext;
	background:black;
	mso-pattern:black none;
	white-space:nowrap;}
.xl773051
	{padding-top:1px;
	padding-right:1px;
	padding-left:1px;
	mso-ignore:padding;
	color:white;
	font-size:12.0pt;
	font-weight:700;
	font-style:normal;
	text-decoration:none;
	font-family:Calibri, sans-serif;
	mso-font-charset:0;
	mso-number-format:General;
	text-align:center;
	vertical-align:middle;
	background:#4472C4;
	mso-pattern:black none;
	white-space:nowrap;}
.xl783051
	{padding-top:1px;
	padding-right:1px;
	padding-left:1px;
	mso-ignore:padding;
	color:black;
	font-size:11.0pt;
	font-weight:400;
	font-style:normal;
	text-decoration:none;
	font-family:Calibri, sans-serif;
	mso-font-charset:0;
	mso-number-format:General;
	text-align:center;
	vertical-align:bottom;
	background:#A5A5A5;
	mso-pattern:black none;
	white-space:nowrap;}
	]]>
		</style>
		<style>
			<![CDATA[
			table td, table th {
				padding-block:.3rem !important;
				padding-inline:.5rem !important;
			}
			
			.inherited {
				background: palegreen;
			}
			
			.revoked {
				background: red;
			}
			]]>
		</style>
		<script src="user_access.js"/>
		<xsl:variable name="users" select="users/user"/>
		<xsl:variable name="modules" select="modules/module"/>
		<div id="59b61e7f-95d1-44a5-8dc1-936f68a5e7bb_1101" align="left" >
			<table border="0" cellpadding="0" cellspacing="0" style='border-collapse:
 collapse;table-layout:fixed;'>
				<colgroup>
					<!--<col width="203" style='mso-width-source:userset;mso-width-alt:7424;width:152pt'/>-->
					<col width="262" style='mso-width-source:userset;mso-width-alt:9581;width:197pt'/>
					<col width="262" style='mso-width-source:userset;mso-width-alt:9581;width:100pt'/>
					<!--<col width="77" style='mso-width-source:userset;mso-width-alt:2816;width:58pt'/>-->
					<!--<col class="xl723051" width="79" span="3" style='mso-width-source:userset;
 mso-width-alt:2889;width:59pt'/>
				<col class="xl723051" width="107" style='mso-width-source:userset;mso-width-alt:
 3913;width:80pt'/>
				<col class="xl723051" width="73" style='mso-width-source:userset;mso-width-alt:
 2669;width:55pt'/>
				<col class="xl723051" width="101" style='mso-width-source:userset;mso-width-alt:
 3693;width:76pt'/>
				<col class="xl723051" width="73" style='mso-width-source:userset;mso-width-alt:
 2669;width:55pt'/>
				<col class="xl723051" width="99" style='mso-width-source:userset;mso-width-alt:
 3620;width:74pt'/>-->
					<col width='70' style="width:70px" span="{count(//modules/module)}"/>
				</colgroup>
				<!--<tr height="25" style='height:90.75pt; '>
					-->
				<!--<td height="25" class="xl153051" width="203" style='height:18.75pt;width:152pt'></td>-->
				<!--
					<td class="xl153051" width="203" style='height:18.75pt;width:152pt'></td>
					-->
				<!--<td class="xl153051" width="77" style='width:58pt'></td>-->
				<!--
					<xsl:for-each select='$modules'>
						<th class="xl763051 rotate" width="107" style='border-left:none;width:80pt'>
							<div>
								<span>
									<xsl:value-of select='@schema'/>
								</span>
							</div>
						</th>
					</xsl:for-each>
				</tr>-->
				<thead>
					<tr height="25" style='height:190.75pt;' class='freeze'>
						<!--<td height="25" class="xl653051" style='height:18.75pt'>Usuario</td>-->
						<td class="xl653051" style='border-left:none;margin-left:15px'>Correo</td>
						<td class="xl653051" style='border-left:none;margin-left:15px'>Rol</td>
						<!--<td class="xl653051" style='border-left:none'>División</td>-->
						<xsl:for-each select='$modules'>
							<th class="xl713051 rotate" style='border-left:none;'>
								<div>
									<xsl:apply-templates select="@name"/>
								</div>
							</th>
						</xsl:for-each>
					</tr>
				</thead>
				<tbody>
					<xsl:for-each select="$users">
						<xsl:variable name="user" select="@id"/>
						<xsl:variable name="role" select="@role"/>
						<tr height="20" style='height:15.0pt'>
							<!--<td height="20" class="xl683051" style='height:15.0pt;border-top:none'>
							BI ADMIN -
							Administrador
						</td>-->
							<td class="xl683051" style='border-top:none;border-left:none;'>
								<xsl:value-of select='@id'/>
							</td>
							<td class="xl683051" style='border-top:none;border-left:none;'>
								<xsl:value-of select='@role'/>
							</td>
							<!--<td class="xl683051" style='border-top:none;border-left:none'>Corporativo</td>-->
							<xsl:for-each select='$modules'>
								<xsl:variable name="module" select="@id"/>
								<xsl:variable name="access" select="key('access',concat($user,'::',$module))|key('access',concat($role,'::',$module))"/>
								<xsl:variable name="changed_style">
									<xsl:if test="$access/../@state:new or $access[../@user=$user] != $access/../@initial:level">outline: solid 2pt yellow;</xsl:if>
								</xsl:variable>
								<td class="xl743051" style="cursor:pointer; {$changed_style}">
									<xsl:variable name="access_value">
										<xsl:choose>
											<xsl:when test="$access[../@user=$user]=0">0</xsl:when>
											<xsl:when test="$access=1">1</xsl:when>
											<xsl:otherwise>0</xsl:otherwise>
										</xsl:choose>
									</xsl:variable>
									<xsl:choose>
										<xsl:when test="$access/../@user=$user">
											<xsl:attribute name="xo-scope">
												<xsl:value-of select="$access[../@user=$user]/../@xo:id"/>
											</xsl:attribute>
											<xsl:attribute name="xo-slot">level</xsl:attribute>
											<xsl:attribute name="onclick">
												<xsl:text>scope.set(</xsl:text>
												<xsl:choose>
													<xsl:when test="$access[../@user=$user]=0">''</xsl:when>
													<xsl:when test="$access=1 and not($access[.=1]/../@user=$user)">0</xsl:when>
													<xsl:when test="$access=1 and $access/../@initial:level=0">0</xsl:when>
													<xsl:when test="$access=1">''</xsl:when>
													<xsl:otherwise>1</xsl:otherwise>
												</xsl:choose>
												<xsl:text>)</xsl:text>
											</xsl:attribute>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="xo-scope">
												<xsl:value-of select="//security/@xo:id"/>
											</xsl:attribute>
											<xsl:attribute name="onclick">
												<xsl:text/>scope.append(newAccess(<xsl:value-of select="$module"/>, '<xsl:value-of select="$user"/>', 1-<xsl:value-of select="$access_value"/>))<xsl:text/>
											</xsl:attribute>
										</xsl:otherwise>
									</xsl:choose>

									<xsl:choose>
										<xsl:when test="$access=1 and not($access[../@user=$user]=0)">
											<!--<xsl:attribute name="onclick">scope.parentNode.filter("self::access[not(@state:new)]").forEach(node => node.set("state:dirty","")); scope.set(0); scope.parentNode.filter("self::access[@state:new]").remove();</xsl:attribute>-->
											<xsl:attribute name="class">
												<xsl:text>xl733051</xsl:text>
												<xsl:choose>
													<xsl:when test="not($access[.=1]/../@user=$user)"> inherited</xsl:when>
												</xsl:choose>
											</xsl:attribute>
											<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-check2-circle" viewBox="0 0 16 16">
												<path d="M2.5 8a5.5 5.5 0 0 1 8.25-4.764.5.5 0 0 0 .5-.866A6.5 6.5 0 1 0 14.5 8a.5.5 0 0 0-1 0 5.5 5.5 0 1 1-11 0z"/>
												<path d="M15.354 3.354a.5.5 0 0 0-.708-.708L8 9.293 5.354 6.646a.5.5 0 1 0-.708.708l3 3a.5.5 0 0 0 .708 0l7-7z"/>
											</svg>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="class">
												<xsl:text>xl743051</xsl:text>
												<xsl:choose>
													<xsl:when test="$access[.=0]/../@user=$user"> revoked</xsl:when>
												</xsl:choose>
											</xsl:attribute>
											<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-x-circle" viewBox="0 0 16 16">
												<path d="M8 15A7 7 0 1 1 8 1a7 7 0 0 1 0 14zm0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16z"/>
												<path d="M4.646 4.646a.5.5 0 0 1 .708 0L8 7.293l2.646-2.647a.5.5 0 0 1 .708.708L8.707 8l2.647 2.646a.5.5 0 0 1-.708.708L8 8.707l-2.646 2.647a.5.5 0 0 1-.708-.708L7.293 8 4.646 5.354a.5.5 0 0 1 0-.708z"/>
											</svg>
										</xsl:otherwise>
									</xsl:choose>
									<!--<xsl:value-of select="concat($user,'::',$module)"/>-->
									<!--<xsl:value-of select="$access[../@user=$user] != $access/../@initial:level"/>-->
								</td>
							</xsl:for-each>
						</tr>
					</xsl:for-each>
				</tbody>
				<footer>
					<xsl:variable name="changes" select="key('changes','*')"/>
					<xsl:if test="$changes">
						<button class="btn btn-success" style="position:fixed; right: 2.5rem; bottom: 4rem; filter: drop-shadow(5px 5px 4px #000);" onclick="xo.server.applyPermissions(scope.ownerDocument).then(()=>xover.stores.active.fetch())">
							<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-floppy" viewBox="0 0 16 16">
								<path d="M11 2H9v3h2z"/>
								<path d="M1.5 0h11.586a1.5 1.5 0 0 1 1.06.44l1.415 1.414A1.5 1.5 0 0 1 16 2.914V14.5a1.5 1.5 0 0 1-1.5 1.5h-13A1.5 1.5 0 0 1 0 14.5v-13A1.5 1.5 0 0 1 1.5 0M1 1.5v13a.5.5 0 0 0 .5.5H2v-4.5A1.5 1.5 0 0 1 3.5 9h9a1.5 1.5 0 0 1 1.5 1.5V15h.5a.5.5 0 0 0 .5-.5V2.914a.5.5 0 0 0-.146-.353l-1.415-1.415A.5.5 0 0 0 13.086 1H13v4.5A1.5 1.5 0 0 1 11.5 7h-7A1.5 1.5 0 0 1 3 5.5V1H1.5a.5.5 0 0 0-.5.5m3 4a.5.5 0 0 0 .5.5h7a.5.5 0 0 0 .5-.5V1H4zM3 15h10v-4.5a.5.5 0 0 0-.5-.5h-9a.5.5 0 0 0-.5.5z"/>
							</svg>
							Guardar cambios
						</button>
					</xsl:if>
				</footer>
			</table>
		</div>
	</xsl:template>

	<xsl:template match="@name">
		<xsl:value-of select="translate(.,'_',' ')"/>
	</xsl:template>

	<xsl:template match="@name[.='getUserAccess']" priority="1">
		<xsl:text>Acceso Usuarios</xsl:text>
	</xsl:template>
</xsl:stylesheet>