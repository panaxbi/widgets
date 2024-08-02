<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xo="http://panax.io/xover"
	xmlns:px="http://panax.io/entity"
	xmlns:site="http://panax.io/site"
	xmlns:state="http://panax.io/state"
	xmlns:shell="http://panax.io/shell"
	xmlns:navbar="http://widgets.panaxbi.com/navbar"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:widget="http://panax.io/widget"
	xmlns:combobox="http://panax.io/widget/combobox"
>
	<xsl:output method="xml"
	   omit-xml-declaration="yes"
	   indent="yes"/>
	<xsl:param name="site:seed">''</xsl:param>

	<xsl:key name="filters" match="*[@xsi:type='dimension']/@navbar:filter" use="'*'"/>

	<xsl:template match="/">
		<span class="page-menu">
			<xsl:apply-templates mode="widget" select="*/@xo:id"/>
		</span>
	</xsl:template>

	<xsl:template mode="headerText" match="@navbar:filter" priority="1">
		<xsl:apply-templates mode="headerText" select=".."/>
	</xsl:template>

	<xsl:template mode="widget" match="model/@*">
		<xsl:comment>debug:info</xsl:comment>
		<xsl:apply-templates mode="widget" select="key('filters','*')"/>
	</xsl:template>

	<xsl:template mode="widget" match="@navbar:filter">
			<style>
				:root { --sections-filter-height: 86px; }
				filter_by option {
				font-size: 16pt;
				}
			</style>
			<fieldset>
				<legend style="text-transform:capitalize">
					<xsl:apply-templates mode="headerText" select="."/>
				</legend>
				<xsl:apply-templates mode="widget" select=".."/>
			</fieldset>
	</xsl:template>

	<xsl:template mode="widget" match="model/@*">
		<xsl:comment>debug:info</xsl:comment>
		<xsl:apply-templates mode="widget" select="key('filters','*')"/>
	</xsl:template>

	<xsl:template mode="widget" match="*[@navbar:filter='default']" priority="1">
		<xsl:apply-templates mode="combobox:widget" select=".">
			<xsl:with-param name="dataset" select="row/@desc"/>
			<xsl:with-param name="xo-slot">state:selected</xsl:with-param>
		</xsl:apply-templates>
	</xsl:template>
</xsl:stylesheet>
