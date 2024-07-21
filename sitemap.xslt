<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns="http://www.w3.org/1999/xhtml"
xmlns:session="http://panax.io/session"
xmlns:sitemap="http://panax.io/sitemap"
xmlns:shell="http://panax.io/shell"
xmlns:state="http://panax.io/state"
xmlns:xo="http://panax.io/xover"
>
	<xsl:key name="sitemap-item" match="dummy" use="'#any'"/>
	<xsl:key name="sitemap-menu-item" match="dummy" use="'#any'"/>

	<xsl:template match="text()"/>

	<xsl:template match="/">
		<aside class="sidebar">
			<script>
				<![CDATA[xo.listener.on('click', function(event){ 
			    if (!event.srcElement.closest('aside,nav')) {
			        toggleSidebar(false);
				}
			})]]>
			</script>
			<style>
				<![CDATA[
body {
  font-family: "Lato", sans-serif;
}

.sidebar {
  height: 100%;
  width: 0;
  position: fixed;
  top: 0;
  left: 0;
  background-color: rgba(50, 62, 72, 0.9);
  overflow-x: hidden;
  transition: 0.5s;
  margin-top: var(--margin-top-sitemap);
  padding-top: var(--padding-top-sitemap) !important;
  padding-bottom: var(--margin-bottom);
  overflow-y: hidden;
}

aside * {
  <!--scrollbar-width: thin;-->
  scrollbar-color: rgba(50, 62, 72, 0.9);
}

/* Works on Chrome, Edge, and Safari */
aside *::-webkit-scrollbar {
  width: 12px;
}

aside *::-webkit-scrollbar-track {
  background: rgba(50, 62, 72, 0.9);
}

aside *::-webkit-scrollbar-thumb {
  background-color: orange;
  border-radius: 20px;
  border: 3px solid rgba(50, 62, 72, 0.9);
}

nav.navbar .menu_toggle {
	color:var(--menu-toggler); 
	cursor:pointer
}

.sitemap_collapsed nav.navbar .menu_toggle {
	color:unset
}

.sidebar a {
  padding: 8px 8px 8px 16px;
  text-decoration: none;
  font-size: 1rem;
  color: #818181;
  display: block;
  transition: 0.3s;
}

a.sidebar-brand {
  padding-right: 8px;
}

.sidebar a:hover {
  color: #f1f1f1;
}

.sidebar .closebtn {
  position: absolute;
  top: 0;
  right: 25px;
  font-size: 36px;
  margin-left: 50px;
}

@media screen and (max-height: 450px) {
  .sidebar {padding-top: 15px;}
  .sidebar a {font-size: 18px;}
}

.sidebar, .sidebar-content, .sidebar-link, a.sidebar-link {
    background-color: #2A3F54 !important;
}

.sidebar-nav {
	padding-bottom: 3.5rem;
    padding-left: 0;
    list-style: none;
}

.sidebar li.sidebar-item:not(.menu):before {
    background: #425668;
    bottom: auto;
    content: "";
    height: 8px;
    left: 23px;
    margin-top: 15px;
    position: absolute;
    right: auto;
    width: 8px;
    z-index: 1;
    border-radius: 50%;
}

.sidebar li.sidebar-item:not(.menu):after {
    border-left: 1px solid #425668;
    bottom: 0;
    content: "";
    left: 27px;
    position: absolute;
    top: 0;
}

.sidebar li.sidebar-item:not(.menu) a {
    border-right: 5px solid var(--border-right-sidebar);
}

.sidebar li.sidebar-item.menu:has(:scope > ul:not(.collapse)) a {
    border-right: 5px solid var(--border-right-sidebar);
}

li.sidebar-item {
	position: relative;
	white-space: nowrap
}

li.sidebar-item.menu > a {
	color: white
} 

.sidebar-link i, .sidebar-link svg, a.sidebar-link i, a.sidebar-link svg {
    margin-right: .75rem;
    color: #fff;
}

.sidebar-dropdown .sidebar-link {
    padding: .625rem 1.5rem .625rem 2.75rem;
    color: #adb5bd;
    background: #313b4c;
    font-weight: 400;
}

.sidebar [data-toggle=collapse]:before {
    content: " ";
    border: solid;
    border-width: 0 .1rem .1rem 0;
    display: inline-block;
    padding: 2px;
    -webkit-transform: rotate(45deg);
    transform: rotate(45deg);
    position: absolute;
    top: 1.2rem;
    right: 1.25rem;
    -webkit-transition: all .2s ease-out;
    transition: all .2s ease-out;
}
]]>
			</style>
			<div style="height:100%; overflow-y:scroll; margin-bottom: var(--margin-bottom)">
				<ul class="sidebar-nav">
					<xsl:apply-templates mode="sitemap:widget"/>
				</ul>
			</div>
		</aside>
	</xsl:template>

	<xsl:template match="key('sitemap-item','#any')" mode="sitemap:widget">
		<xsl:variable name="type">
			<xsl:if test="key('sitemap-menu-item',@xo:id)">menu</xsl:if>
		</xsl:variable>
		<xsl:variable name="collapsed_status">
			<xsl:if test="item">collapsed</xsl:if>
		</xsl:variable>
		<li class="sidebar-item {$type}">
			<a href="#" class="sidebar-link {$collapsed_status}" onclick="classList.toggle('collapsed'); parentElement.querySelector(':scope > ul').classList.toggle('show')">
				<xsl:choose>
					<xsl:when test="$type='menu'">
						<xsl:attribute name="data-toggle">collapse</xsl:attribute>
						<!--<xsl:attribute name="onclick">
					<xsl:apply-templates mode="sitemap:script" select="."/><![CDATA[;/*toggle_sidebar();*/]]>
				</xsl:attribute>-->
						<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-layout align-middle">
							<rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect>
							<line x1="3" y1="9" x2="21" y2="9"></line>
							<line x1="9" y1="21" x2="9" y2="9"></line>
						</svg>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates mode="sitemap:target-href" select="."/>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="@title"/>
			</a>
			<xsl:variable name="show_status">
				<xsl:if test="$collapsed_status!='collapsed'">show</xsl:if>
			</xsl:variable>
			<ul id="{generate-id()}" class="sidebar-dropdown list-unstyled collapse {$show_status}">
				<xsl:apply-templates mode="sitemap:widget"/>
			</ul>
		</li>
	</xsl:template>

	<xsl:template mode="sitemap:target-href" match="*">
		<xsl:attribute name="href">
			<xsl:value-of select="@target"/>
		</xsl:attribute>
	</xsl:template>
</xsl:stylesheet>
