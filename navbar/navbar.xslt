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

	<xsl:key name="filters" match="model/*[@navbar:control]" use="'*'"/>
	<xsl:key name="filters" match="model/*[@navbar:position]" use="'*'"/>
	<xsl:key name="filters" match="model/*[@navbar:position or @navbar:control]" use="string(@navbar:position)"/>

	<xsl:key name="filter" match="model/*[@navbar:control]" use="''"/>
	<xsl:key name="filter" match="model/*[@navbar:control]" use="name()"/>
	<xsl:key name="filter" match="model/*[@navbar:position]" use="@navbar:position"/>

	<xsl:key name="filter" match="model/*[@navbar:control][not(@navbar:position)]" use="generate-id(@navbar:control)"/>
	<!--<xsl:key name="filter" match="*[@navbar:control][not(@navbar:position)]" use="generate-id(@navbar:control)"/>-->

	<xsl:template match="/">
		<span class="page-menu">
			<xsl:apply-templates mode="widget" select="*"/>
		</span>
	</xsl:template>

	<xsl:template mode="navbar:headerText" match="*" priority="1">
		<xsl:comment>debug:info</xsl:comment>
		<xsl:apply-templates mode="headerText" select="."/>
	</xsl:template>

	<xsl:template mode="navbar:headerText" match="*[key('filters',@navbar:position)[2]]" priority="1">
		<xsl:param name="position" select="position()"/>
		<xsl:variable name="state:filterBy" select="//*/@state:*[local-name()=concat('filterBy_',$position)]"/>
		<xsl:comment>debug:info</xsl:comment>
		<!--<xsl:for-each select="key('filter',$state:filterBy)[1]">-->
		<select style="font-weight: bold; padding: 1px 5px;" class="form-select" onchange="this.scope.dispatch('changeFilter', {$position}, this.value)">
			<xsl:for-each select="key('filters',$position)">
				<option value="{name()}">
					<xsl:if test="not($state:filterBy) and position()=1 or $state:filterBy=name()">
						<xsl:attribute name="selected"/>
					</xsl:if>
					<xsl:apply-templates mode="headerText" select="."/>
				</option>
			</xsl:for-each>
		</select>
		<!--</xsl:for-each>-->
		<xsl:if test="not(key('filter',$state:filterBy))">
			<script>xover.state.filterBy=''</script>
		</xsl:if>
	</xsl:template>

	<xsl:template mode="navbar:widget" match="*|@*">
		<xsl:variable name="current" select="."/>
		<xsl:variable name="position" select="position()"/>
		<xsl:variable name="state:filterBy" select="//*/@state:*[local-name()=concat('filterBy_',$position)]"/>
		<script src="navbar.js"/>
		<style>
			:root { --sections-filter-height: 86px; }
			filter_by option {
			font-size: 16pt;
			}
		</style>
		<fieldset class="mutually-exclusive" xo-scope="inherit">
			<legend style="text-transform:capitalize">
				<xsl:apply-templates mode="navbar:headerText" select=".">
					<xsl:with-param name="position" select="$position"/>
				</xsl:apply-templates>
			</legend>
			<xsl:variable name="filters" select="key('filter',$position)|self::*[not(@navbar:position)]"/>
			<xsl:apply-templates mode="widget" select="$filters[not($state:filterBy) and position()=1 or $state:filterBy=name()]"/>
			<xsl:for-each select="$filters[not((not($state:filterBy) and position()=1 or $state:filterBy=name()))]">
				<input type="hidden" name="{name()}" value="{@state:selected}"/>
			</xsl:for-each>
			<!--<xsl:apply-templates mode="widget" select="key('filter',generate-id())|key('filter',$state:filterBy)[@navbar:position=$position][1]|key('filter',$position)[1][count(key('filter',$state:filterBy))=0]"/>-->
		</fieldset>
	</xsl:template>

	<xsl:template mode="widget" match="model/*">
		<xsl:variable name="value" select="@state:selected"/>
		<input type="text" class="form-control" name="{name()}" xo-slot="state:selected" value="{$value}"/>
	</xsl:template>

	<xsl:template mode="widget" match="*[row]|*[@xsi:nil]" priority="1">
		<xsl:variable name="value" select="@state:selected"/>
		<xsl:apply-templates mode="combobox:widget" select=".">
			<xsl:with-param name="dataset" select="row/@desc"/>
			<xsl:with-param name="xo-slot">state:selected</xsl:with-param>
			<xsl:with-param name="selected-value" select="$value"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template mode="combobox:option-clear" match="@*">
		<option class="data-row non-filterable" value="" text="" style="color: red">- QUITAR SELECCIÓN -</option>
	</xsl:template>

	<xsl:template mode="widget" match="*[@navbar:control='daterange']" priority="1">
		<xsl:variable name="slot_name">state:selected</xsl:variable>
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
		<px-daterange name="{name()}" class="input-group" value="{@*[name()=$slot_name]}" xo-slot="{$slot_name}">
			<xsl:attribute name="max">{{new Date().toISOString().slice(0,10)}}</xsl:attribute>
		</px-daterange>
	</xsl:template>

	<xsl:template mode="widget" match="model">
		<xsl:comment>debug:info</xsl:comment>
		<xsl:apply-templates mode="navbar:widget" select="key('filters','*')[count(key('filters',string(@navbar:position))[1]|.)=1]">
			<xsl:sort select="number(boolean(../@navbar:position))" data-type="number" order="descending"/>
			<xsl:sort select="../@navbar:position" data-type="number"/>
			<xsl:sort select="position()" data-type="number"/>
		</xsl:apply-templates>
	</xsl:template>
</xsl:stylesheet>
