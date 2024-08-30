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
		<xsl:comment>debug:info</xsl:comment>
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

	<xsl:template mode="widget" match="*[@navbar:filter='daterange']" priority="1">
		<xsl:variable name="default_date">
			<xsl:choose>
				<xsl:when test="../fechas/@state:current_date_er">
					<xsl:value-of select="../fechas/@state:current_date_er"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="../fechas/@key">
						<xsl:sort order="descending" select="."/>
						<xsl:if test="position()=1">
							<xsl:value-of select="."/>
						</xsl:if>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="curr_month" select="../fechas/row[@mes=$default_date]/@mes"/>
		<xsl:variable name="start_week" select="../fechas/@state:start_week"/>
		<xsl:variable name="end_week" select="../fechas/@state:end_week"/>
		<div class="input-group">
			<input class="form-control" name="fecha_inicio" type="date" pattern="yyyy-mm-dd" xo-slot="state:fecha_inicio" value="{@state:fecha_inicio}"/>
			<input class="form-control" name="fecha_fin" type="date" pattern="yyyy-mm-dd" xo-slot="state:fecha_fin" value="{@state:fecha_fin}"/>
		</div>
	</xsl:template>
</xsl:stylesheet>
