<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
xmlns:session="http://panax.io/session"
xmlns:sitemap="http://panax.io/sitemap"
xmlns:shell="http://panax.io/shell"
xmlns:state="http://panax.io/state"
xmlns:source="http://panax.io/xover/binding/source"
xmlns:xlink="http://www.w3.org/1999/xlink"
>
  <xsl:output method="xml"
	   omit-xml-declaration="yes"
	   indent="yes"/>

  <xsl:template match="/" priority="-1">
    <section>
      <xsl:apply-templates mode="shell:widget"/>
    </section>
  </xsl:template>

  <xsl:template match="shell:shell" mode="shell:widget">
    <div id="shell" class="wrapper sitemap_collapsed">
      <script>
        <![CDATA[
				function toggleSidebar(show) {
					let sidebar = document.querySelector('.sidebar');
					if (!sidebar) return
					let width = Number.parseInt(sidebar.style.width);
					sidebar.closest('.wrapper').classList.toggle('sitemap_collapsed', !!width || show === false)
					sidebar.style.width = width || show === false ? 0 : '100%';
				}
				
				xover.listener.on('keyup', async function (event) {
					if (event.keyCode == 27) {
						toggleSidebar(false);
						event.stopPropagation();
					}
				})
				]]>
      </script>
      <style>
        <![CDATA[
				body {
					overflow-y: hidden;
				}
				
				#shell {
				    display: flex;
                    flex-direction: column;
                    height: 100vh !important;
	            }
				
				main { 
					padding-bottom: var(--padding-bottom, var(--footer-height));
					overflow-y: scroll;
					width: 100vw;
					flex: 1;
					
				}
				
				header h1 {
					color: var(--color-title-header);
					margin-bottom: 0;
					margin-left: 5px;
					text-align: center;
          position: fixed;
				}
				
				footer {
					border-top: 2px solid silver !important;
					/*position: fixed;*/
					bottom: 0;
					height: var(--footer-height);
					background-color: var(--bg-white) !important;
					width: 100%;
          transition: 0.5s;
					overflow: hidden;
				}
				
				nav.navbar .menu_toggle {
					color: silver; 
					cursor:wait;
				}
				]]>
      </style>
      <xsl:apply-templates mode="nav.title" select="."/>
      <nav class="navbar navbar-expand navbar-light" style="padding:.6rem 1.25rem; position: sticky;">
        <span class="menu_toggle" style="font-size:30px;" onclick="toggleSidebar()">
          &#9776; <img src=""/>
        </span>
        <div class="navbar-collapse collapse">
          <div>
            <!--Logo-->
            <a href="/" title="Ir a la página principal">
              <img id="logo" class="logo" src="assets/logo.png" height="40px"/>
            </a>
          </div>
          <div class="anteanter_section search"></div>
          <div class="">
            <ul class="navbar-nav ml-auto">
              <li class="nav-item dropdown">
                <a class="nav-icon dropdown-toggle d-inline-block d-sm-none" href="#" data-toggle="dropdown">
                  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-settings align-middle">
                    <circle cx="12" cy="12" r="3"></circle>
                    <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path>
                  </svg>
                </a>

                <span xo-source="#menu">
                </span>

              </li>
            </ul>
          </div>
        </div>
      </nav>
      <span class="page-menu" xo-source="active" xo-stylesheet="page_navbar.xslt"/>
      <main>
      </main>
      <footer class="d-flex flex-wrap justify-content-between align-items-center py-1 px-3 trash-zone">
        <div id="page_controls" xo-source="active" xo-stylesheet="page_controls.xslt" class="col-md-12 d-flex align-items-center">
        </div>
        <div id="offcanvas" xo-source="active" xo-stylesheet="page_controls.offcanvas.xslt" class="col-md-12 d-flex align-items-center">
        </div>
      </footer>
      <aside class="sidebar" xo-source="#sitemap" xo-stylesheet="sitemap.xslt" id="sitemap"/>
      <div class="settings" xo-source="#settings" xo-stylesheet="widgets/settings.xslt"/>
    </div>
  </xsl:template>

  <xsl:template mode="nav.search" match="*">
    <div class="anteanter_section search">
      <section class="section_nav navbar-form navbar-left hpadding0 hmargecontenidozul" method="GET" id="frmBuscador">
        <div id="sitemap_horizontal" xo-source="#sitemap" xo-stylesheet="sitemap_horizontal.xslt"/>
      </section>
    </div>
  </xsl:template>

  <xsl:template mode="nav.title" match="*">
    <header class="hpadding0">
      <h1 xo-source="active" xo-stylesheet="title.xslt"></h1>
    </header>
  </xsl:template>

</xsl:stylesheet>
