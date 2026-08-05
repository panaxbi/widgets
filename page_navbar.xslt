<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml">
	<xsl:import href="navbar/navbar.xslt"/>
	<xsl:import href="combobox.xslt"/>

	<xsl:template match="/">
		<span class="page-menu">
			<style>
				.page-menu nav { width: 100%; padding: .25rem 1rem; }
				.page-menu nav > form { display: flex; flex: 0 1 auto; align-items: end; gap: 1rem; min-width: 0; }
				.page-menu nav fieldset { flex: 0 1 auto; min-width: 14rem; max-width: 24rem; margin: 0; padding: 0; border: 0; }
				.page-menu nav fieldset:first-of-type { min-width: 22rem; }
				.page-menu nav fieldset > :not(legend), .page-menu nav fieldset input, .page-menu nav fieldset select { max-width: 100%; }
				.page-menu .shell-buttons { flex: 0 0 auto; margin-left: auto; }
				@media (max-width: 767.98px) {
					.page-menu nav, .page-menu nav > form { align-items: stretch; flex-direction: column; }
					.page-menu nav fieldset, .page-menu nav fieldset:first-of-type { width: 100%; min-width: 0; max-width: none; flex-basis: auto; }
				}
			</style>
			<nav class="navbar navbar-expand-md">
				<form action="javascript:void(0);" onsubmit="section.source.fetch()">
					<xsl:apply-templates mode="navbar:widget" select="*"/>
				</form>
				<ul class="nav shell-buttons justify-content-end list-unstyled d-flex">
					<xsl:apply-templates mode="buttons" select="*"/>
				</ul>
			</nav>
		</span>
	</xsl:template>

	<xsl:template mode="buttons" match="*|@*"/>
</xsl:stylesheet>
