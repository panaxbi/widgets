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
	<xsl:param name="state:filterBy"></xsl:param>

	<xsl:key name="filters" match="*/@navbar:filter" use="'*'"/>
	<xsl:key name="filters" match="*/@navbar:filter" use="../@navbar:position"/>

	<xsl:key name="filter" match="*[@navbar:filter]" use="''"/>
	<xsl:key name="filter" match="*[@navbar:filter]" use="name()"/>
	
	<xsl:key name="filter" match="*[@navbar:filter][not(@navbar:position)]" use="generate-id(@navbar:filter)"/>
	<!--<xsl:key name="filter" match="*[@navbar:filter][not(@navbar:position)]" use="generate-id(@navbar:filter)"/>-->

	<xsl:template match="/">
		<span class="page-menu">
			<xsl:apply-templates mode="widget" select="*/@xo:id"/>
		</span>
	</xsl:template>

	<xsl:template mode="headerText" match="@navbar:filter" priority="1">
		<xsl:comment>debug:info</xsl:comment>
		<xsl:apply-templates mode="headerText" select=".."/>
	</xsl:template>

	<xsl:template mode="headerText" match="*[@navbar:position]/@navbar:filter" priority="1">
		<xsl:comment>debug:info</xsl:comment>
		<xsl:for-each select="key('filter',$state:filterBy)[1]">
			<select style="font-weight: bold; padding: 1px 5px;" class="form-select" onchange="xo.state.filterBy=this.value">
				<xsl:for-each select="key('filters',@navbar:position)">
					<option value="{name(..)}">
						<xsl:if test="$state:filterBy='' and position()=1 or $state:filterBy=name(..)">
							<xsl:attribute name="selected"/>
						</xsl:if>
						<xsl:apply-templates mode="headerText" select=".."/>
					</option>
				</xsl:for-each>
			</select>
		</xsl:for-each>
	</xsl:template>

	<xsl:template mode="widget" match="@navbar:filter">
		<xsl:variable name="current" select="."/>
		<xsl:variable name="position" select="../@navbar:position"/>
		<script src="navbar.js"/>
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
			<xsl:apply-templates mode="widget" select="key('filter',generate-id())|key('filter',$state:filterBy)[@navbar:position=$position][1]"/>
		</fieldset>
	</xsl:template>

	<xsl:template mode="widget" match="model/@*">
		<xsl:comment>debug:info</xsl:comment>
		<xsl:apply-templates mode="widget" select="key('filters','*')[count(key('filters',../@navbar:position)[1]|.)=1]">
			<xsl:sort select="number(boolean(../@navbar:position))" data-type="number" order="descending"/>
			<xsl:sort select="../@navbar:position" data-type="number"/>
			<xsl:sort select="position()" data-type="number"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template mode="widget" match="*[@navbar:filter='default']" priority="1">
		<xsl:variable name="value" select="@state:*[local-name()=local-name(current())]"/>
		<input type="text" class="form-control" name="{name()}" xo-slot="state:{name()}" value="{$value}"/>
	</xsl:template>

	<xsl:template mode="widget" match="*[@xsi:type='dimension'][@navbar:filter='default']" priority="1">
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
