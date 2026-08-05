<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns="http://www.w3.org/1999/xhtml"
xmlns:xo="http://panax.io/xover"
xmlns:px="http://panax.io/entity"
xmlns:site="http://panax.io/site"
xmlns:state="http://panax.io/state"
xmlns:initial="http://panax.io/state/initial"
xmlns:env="http://panax.io/state/environment"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
>
	<xsl:param name="site:seed">''</xsl:param>
	<xsl:param name="state:touched"/>

	<xsl:template match="/">
		<div id="page_controls">
			<style>
				<![CDATA[
        :root { --footer-height: 38px; }

        .filters-toggle {
          background: #343a40;
          color: #fff;
          position: fixed;
          bottom: var(--footer-height);
          z-index: 1002;
          right: 0;
          width: 46px;
          padding: .75rem;
          border-top-left-radius: .2rem;
          border-bottom-left-radius: .2rem;
          box-shadow: -5px 0 10px 0 rgba(0,0,0,.1);
          -webkit-transition: all .1s ease-in-out;
          transition: all .1s ease-in-out;
          cursor: pointer;
		  margin-right: var(--scrollbar-width,0);
        }

        .filters-toggle:hover {
          width: 52px;
        }

        .filters-toggle svg {
          width: 22px;
          height: 22px;
          -webkit-animation-name: spin;
          animation-name: spin;
          -webkit-animation-duration: 4s;
          animation-duration: 4s;
          -webkit-animation-iteration-count: infinite;
          animation-iteration-count: infinite;
          -webkit-animation-timing-function: linear;
          animation-timing-function: linear
        }
		
		footer [role=group] {
			max-width: 100%;
			overflow: auto;
		}
      ]]>
			</style>
			<script>
				<![CDATA[
        function filtersToggle() {
          let toggler = event.srcElement;
          let r = document.querySelector(':root');
          let rs = getComputedStyle(r);
          let current_footer_height = rs.getPropertyValue('--footer-height');
          if (parseInt(current_footer_height)) {
            xo.session.footer_height = current_footer_height;
            r.style.setProperty('--footer-height', '0px');
          } else {
            r.style.setProperty('--footer-height', xo.session.footer_height);
          }
        }]]>
			</script>
			<div is="selection-summary" summary="count" label="Conteo"></div>
			<div is="selection-summary" summary="sum" label="Suma"></div>
			<!--<div is="selection-summary" summary="avg" label="Promedio" format="$#,##0.0#"></div>-->
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<xsl:template match="text()"></xsl:template>
	<xsl:key name="archivo" match="archivos/@state:selected" use="'selected'"/>
	
	<xsl:template match="model">
		<!--<div class="filters-toggle toggle-filters" onclick="this.classList.toggle('closed'); filtersToggle();">
			<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-funnel" viewBox="0 0 16 16">
				<path d="M1.5 1.5A.5.5 0 0 1 2 1h12a.5.5 0 0 1 .5.5v2a.5.5 0 0 1-.128.334L10 8.692V13.5a.5.5 0 0 1-.342.474l-3 1A.5.5 0 0 1 6 14.5V8.692L1.628 3.834A.5.5 0 0 1 1.5 3.5v-2zm1 .5v1.308l4.372 4.858A.5.5 0 0 1 7 8.5v5.306l2-.666V8.5a.5.5 0 0 1 .128-.334L13.5 3.308V2h-11z"/>
			</svg>
		</div>-->
	</xsl:template>
</xsl:stylesheet>
