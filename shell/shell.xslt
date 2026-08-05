<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
xmlns:xo="http://panax.io/xover"
xmlns:session="http://panax.io/session"
xmlns:sitemap="http://panax.io/sitemap"
xmlns:shell="http://panax.io/shell"
xmlns:state="http://panax.io/state"
xmlns:source="http://panax.io/xover/binding/source"
xmlns:xlink="http://www.w3.org/1999/xlink"
>

	<xsl:template match="/" priority="-1">
		<script src="shell.js"/>
		<xsl:apply-templates mode="shell:widget"/>
	</xsl:template>

	<xsl:template match="*|@*" mode="shell:widget">
		<section id="shell" class="wrapper sitemap_collapsed" xo-silence="@aria-* @data-bs-*">
			<style>
				<![CDATA[
			@media print {
				/* Apply to all elements or specific classes/elements */
				body, 
				.element-with-background {
					-webkit-print-color-adjust: exact; /* For WebKit-based browsers */
					print-color-adjust: exact;         /* Standard property */
				}
			}
			
			body:has(:scope > iframe) {
				height: 100vh;
			}

			iframe {
				display: block;
				border: none;
				min-height: 100%;
				max-height: 100%;
				width: 100%;
			}
			
			menu.settings .offcanvas-header h6 {
				margin-left: 1rem;
			}			
			]]>
			</style>
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
				
				#shell > main { 
					/*padding-bottom: var(--padding-bottom, var(--footer-height));*/
					overflow-y: scroll;
					width: 100vw;
					flex: 1;
					
				}
				
				#shell > header h1 {
					color: var(--color-title-header);
					margin-bottom: 0;
					margin-left: 1.5rem;
					text-align: center;
                    position: fixed;
				}
				
				#shell > footer {
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

				#shell > nav.navbar .navbar-collapse > :last-child {
					margin-left: auto;
				}

				#shell > nav.navbar [xo-source="#menu"] {
					display: flex;
					align-items: center;
					margin-left: auto;
				}

				#shell > nav.navbar [xo-source="#menu"] > * {
					margin-left: auto;
				}

				#shell > nav.navbar .ml-auto {
					margin-left: auto !important;
				}
				
				#shell > * {
					z-index: 1020;
				}
				
				#shell > nav, #settings, #shell > .settings {
					z-index: 1021;
				}
				
				#shell > main {
					z-index: 1019;
				}
				
				[x\:publishsource="Excel"] table thead td {
					position:relative;
        }
        
        .page-menu {
					min-height: max-content;
        }
				
				nav .logo { max-height: 40px; }
				]]>
			</style>
			<xsl:apply-templates mode="shell:nav-title" select="."/>
			<nav class="navbar navbar-expand navbar-light" style="padding:.6rem 1.25rem; position: sticky;">
				<span class="menu_toggle" style="font-size:30px; margin-right: .5rem;" onclick="toggleSidebar()">
					&#9776;
				</span>
				<div class="navbar-collapse collapse">
					<div>
						<!--Logo-->
						<a href="/" title="Ir a la página principal">
							<img id="logo" class="logo" src="assets/logo.png" xo:use-attribute-sets="shell:logo"/>
						</a>
					</div>
					<div class="anteanter_section search"></div>
					<span xo-source="#menu">
					</span>
				</div>
			</nav>
			<span class="page-menu" xo-source="active" xo-stylesheet="../page_navbar.xslt"/>
			<main>
			</main>
			<footer class="d-flex flex-wrap justify-content-between align-items-center py-2 px-3 trash-zone">
				<div id="page_controls" xo-source="active" xo-stylesheet="../page_controls.xslt" class="col-md-8 d-flex align-items-center">
				</div>
				<ul id="shell_buttons" class="nav col-md-4 justify-content-end list-unstyled d-flex" xo-source="active" xo-stylesheet="../shell_buttons.xslt">
				</ul>
			</footer>
			<aside class="sidebar" xo-source="#sitemap" xo-stylesheet="../sitemap.xslt" id="sitemap"/>
			<div class="settings" xo-source="#settings" xo-stylesheet="../settings.xslt"/>
		</section>
	</xsl:template>

	<xsl:template mode="shell:nav-search" match="*">
		<div class="anteanter_section search">
			<section class="section_nav navbar-form navbar-left hpadding0 hmargecontenidozul" method="GET" id="frmBuscador">
				<div id="sitemap_horizontal" xo-source="#sitemap" xo-stylesheet="../sitemap_horizontal.xslt"/>
			</section>
		</div>
	</xsl:template>

	<xsl:template mode="shell:nav-title" match="*">
		<header>
			<h1 xo-source="#sitemap" xo-stylesheet="../title.xslt"></h1>
		</header>
	</xsl:template>

</xsl:stylesheet>
