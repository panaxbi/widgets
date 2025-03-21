<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns="http://www.w3.org/1999/xhtml"
xmlns:js="http://panax.io/languages/javascript"
xmlns:session="http://panax.io/session"
xmlns:sitemap="http://panax.io/sitemap"
xmlns:shell="http://panax.io/shell"
xmlns:state="http://panax.io/state"
>
	<xsl:output method="xml"
	   omit-xml-declaration="yes"
	   indent="yes"/>

	<xsl:template match="text()"/>
	<xsl:param name="session:debug">false</xsl:param>
	<xsl:param name="session:version"></xsl:param>
	<xsl:param name="state:hide_empty">false</xsl:param>
	<!--<xsl:param name="js:cache_name">xover.session.cache_name.replace(`${location.hostname}_`,'')</xsl:param>-->
	<xsl:key name="expanded" match="*[@state:expanded='true']" use="true()"/>

	<xsl:template match="*">
		<xsl:variable name="open">
			<xsl:if test="key('expanded',true())">open</xsl:if>
		</xsl:variable>
		<menu class="settings">
			<style>
				<![CDATA[
    .settings {
        font-family: sans-serif;
        display: none;
        position: fixed;
        top: 70px;
        right: 0;
        z-index: var(--z-index-side-bar,1090);
    }
	
	.settings a {
        text-decoration: none;
        color: black;
	}

    @media (min-width:600px) {
        .settings {
            display: flex;
            flex-direction: column;
            row-gap: 10px;
        }
    }

    .settings-toggle {
        background: #343a40;
        color: #fff;
        width: 46px;
        padding: .5rem;
        border-top-left-radius: .2rem;
        border-bottom-left-radius: .2rem;
        box-shadow: -5px 0 10px 0 rgba(0,0,0,.1);
        -webkit-transition: all .1s ease-in-out;
        transition: all .1s ease-in-out;
        cursor: pointer;
		align-self: end;
        z-index: 1002;
    }

    .settings-toggle:hover {
        width: 52px
    }

    .settings-toggle svg {
        width: 22px;
        height: 22px;
    }

    .settings-toggle svg.feather-settings {
        -webkit-animation-name: spin;
        animation-name: spin;
        -webkit-animation-duration: 4s;
        animation-duration: 4s;
        -webkit-animation-iteration-count: infinite;
        animation-iteration-count: infinite;
        -webkit-animation-timing-function: linear;
        animation-timing-function: linear
    }

    .settings-section {
        border-top: 1px solid #e5e9f2;
        padding: 1rem 1.5rem
    }

    .settings-theme {
        display: block;
        margin-bottom: 1rem;
        text-align: center;
        text-decoration: none;
        cursor: pointer
    }

    .settings-theme:last-child {
        margin-bottom: 0
    }

    .settings-theme:hover {
        text-decoration: none
    }

    .settings-theme img {
        border-radius: .2rem;
        border: 1px solid #ced4da;
        -webkit-transform: scale(1);
        transform: scale(1);
        -webkit-transition: all .1s ease-in-out;
        transition: all .1s ease-in-out
    }

    .settings-theme:hover img {
        -webkit-transform: scale(1.03);
        transform: scale(1.03)
    }
	
	.closebtn {
      position: absolute;
      top: 0;
      right: 25px;
      font-size: 36px;
      margin-left: 50px;
    }
	
	menu.settings .accordion-body menu { margin-top: 0; }
			]]>
			</style>
			<button type="button" class="settings-toggle toggle-settings" data-bs-toggle="offcanvas" data-bs-target="#settings-offcanvas" tabindex="-1">
				<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-settings align-middle">
					<circle cx="12" cy="12" r="3"></circle>
					<path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path>
				</svg>
			</button>
			<xsl:if test="$session:debug='true'">
				<button type="button" class="settings-toggle toggle-settings" onclick="xo.stores.active.render()" tabindex="-1">
					<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-arrow-clockwise" viewBox="0 0 16 16">
						<path fill-rule="evenodd" d="M8 3a5 5 0 1 0 4.546 2.914.5.5 0 0 1 .908-.417A6 6 0 1 1 8 2v1z"/>
						<path d="M8 4.466V.534a.25.25 0 0 1 .41-.192l2.36 1.966c.12.1.12.284 0 .384L8.41 4.658A.25.25 0 0 1 8 4.466z"/>
					</svg>
				</button>
				<button type="button" class="settings-toggle toggle-settings" onclick="xo.site.stylesheets.reload()" tabindex="-1">
					<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-book" viewBox="0 0 16 16">
						<path d="M1 2.828c.885-.37 2.154-.769 3.388-.893 1.33-.134 2.458.063 3.112.752v9.746c-.935-.53-2.12-.603-3.213-.493-1.18.12-2.37.461-3.287.811V2.828zm7.5-.141c.654-.689 1.782-.886 3.112-.752 1.234.124 2.503.523 3.388.893v9.923c-.918-.35-2.107-.692-3.287-.81-1.094-.111-2.278-.039-3.213.492V2.687zM8 1.783C7.015.936 5.587.81 4.287.94c-1.514.153-3.042.672-3.994 1.105A.5.5 0 0 0 0 2.5v11a.5.5 0 0 0 .707.455c.882-.4 2.303-.881 3.68-1.02 1.409-.142 2.59.087 3.223.877a.5.5 0 0 0 .78 0c.633-.79 1.814-1.019 3.222-.877 1.378.139 2.8.62 3.681 1.02A.5.5 0 0 0 16 13.5v-11a.5.5 0 0 0-.293-.455c-.952-.433-2.48-.952-3.994-1.105C10.413.809 8.985.936 8 1.783z"/>
					</svg>
				</button>
			</xsl:if>
			<div class="offcanvas offcanvas-end" tabindex="-1" id="settings-offcanvas" aria-labelledby="offcanvasLabel">
				<div class="offcanvas-header">
					<h5 class="offcanvas-title" id="offcanvasLabel">Herramientas</h5>
					<xsl:if test="$session:version!=''">
						<h6>v. <xsl:value-of select="$session:version"/></h6>
					</xsl:if>
					<button type="button" class="btn-close"  data-bs-dismiss="offcanvas" aria-label="Close"></button>
				</div>
				<div class="offcanvas-body">
					<div class="accordion" id="settings-accordion">
						<div class="accordion-item">
							<h2 class="accordion-header">
								<button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#settings-menu-One" aria-expanded="true" aria-controls="settings-menu-One">
									Edición
								</button>
							</h2>
							<div id="settings-menu-One" class="accordion-collapse collapse show" data-bs-parent="#settings-accordion">
								<div class="accordion-body">
									<menu class="list-group">
										<!--<button type="button" class="list-group-item list-group-item-action" onclick="xo.stores.active.undo()">Deshacer</button>
										<button type="button" class="list-group-item list-group-item-action" onclick="xo.stores.active.redo()">Rehacer</button>-->
										<button type="button" class="list-group-item list-group-item-action" onclick="document.dispatch('print')">Imprimir</button>
										<button type="button" class="list-group-item list-group-item-action" onclick="generateExcelFile(document.querySelector('table'),xover.stores.active.tag)">Enviar a excel...</button>
										<button type="button" class="list-group-item list-group-item-action" onclick="xover.session.saveSession();">Guardar sesión</button>
										<button type="button" class="list-group-item list-group-item-action" onclick="xo.stores.active.select(`//@group:*|//@filter:*`).remove()">Borrar filtros y agrupaciones</button>
										<xsl:if test="$state:hide_empty!=''">
											<button type="button" class="list-group-item list-group-item-action" onclick="xo.state.hide_empty = !xo.state.hide_empty">
												<xsl:choose>
													<xsl:when test="$state:hide_empty='true'">Mostrar registros en ceros</xsl:when>
													<xsl:otherwise>Ocultar registros en ceros</xsl:otherwise>
												</xsl:choose>
											</button>
										</xsl:if>
										<xsl:if test="$session:version!=''">
											<button type="button" class="list-group-item list-group-item-action" onclick="xover.session.clearCache();">Borrar caché</button>
										</xsl:if>
									</menu>
								</div>
							</div>
						</div>
						<div class="accordion-item">
							<h2 class="accordion-header">
								<button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#settings-menu-Two" aria-expanded="false" aria-controls="settings-menu-Two">
									Desarrollador
								</button>
							</h2>
							<div id="settings-menu-Two" class="accordion-collapse collapse" data-bs-parent="#settings-accordion">
								<div class="accordion-body">
									<menu class="list-group">
										<button type="button" class="list-group-item list-group-item-action" onclick="xo.stores.active.toClipboard();">Copiar fuente</button>
										<button type="button" class="list-group-item list-group-item-action">
											<xsl:choose>
												<xsl:when test="$session:debug='true'">
													<xsl:attribute name="onclick">xover.session.debug=false</xsl:attribute>
													Deshabilitar depurar
												</xsl:when>
												<xsl:otherwise>
													<xsl:attribute name="onclick">xover.session.debug=true</xsl:attribute>
													Depurar
												</xsl:otherwise>
											</xsl:choose>
										</button>
										<button type="button" class="list-group-item list-group-item-action" onclick="xo.stores.active.render()">Actualizar módulo</button>
										<button type="button" class="list-group-item list-group-item-action" onclick="xo.stores.active.sources.reload()">Actualizar librerías</button>
									</menu>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</menu>
	</xsl:template>

</xsl:stylesheet>
