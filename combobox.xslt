<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xo="http://panax.io/xover"
  xmlns:combobox="http://panax.io/widget/combobox"
>
	<xsl:template mode="combobox:widget" match="@*|*">
		<xsl:param name="dataset" select="."/>
		<xsl:param name="xo-context"/>
		<xsl:param name="xo-slot">
			<xsl:choose>
				<xsl:when test="self::*">combobox:selected</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="name()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:param>
		<xsl:param name="selected-value" select="(self::*[1]|current()[not(self::*)]/..)/@*[name()=$xo-slot]"/>
		<xsl:variable name="current" select="."/>
		<xsl:variable name="attribute"/>
		<!--<style><![CDATA[px-combobox > * {style:none}]]></style>-->
		<px-combobox xo-slot="{$xo-slot}" value="{$selected-value}">
			<xsl:attribute name="onmouseover">scope.dispatch('downloadCatalog')</xsl:attribute>
			<xsl:apply-templates mode="combobox:option-clear" select="$selected-value"/>
			<xsl:apply-templates mode="combobox:option" select="$dataset">
				<xsl:with-param name="selected-value" select="$selected-value"/>
			</xsl:apply-templates>
		</px-combobox>
	</xsl:template>

	<xsl:template mode="combobox:attributes" match="@*|*"/>
	<xsl:template mode="combobox:option-attributes" match="@*|*"/>

	<xsl:template mode="combobox:option-value" match="*[@key]/@*">
		<xsl:value-of select="../@key"/>
	</xsl:template>

	<xsl:template mode="combobox:option-value" match="*[@id]/@*">
		<xsl:value-of select="../@id"/>
	</xsl:template>

	<xsl:template mode="combobox:display-text" match="*"/>

	<xsl:template mode="combobox:display-text" match="@*">
		<xsl:param name="dataset" select="node-expected"/>
		<xsl:value-of select="normalize-space($dataset[../@id=current() or ../@key=current()])"/>
	</xsl:template>

	<xsl:template mode="combobox:option-selected" match="*[@id or @key]/@*">
		<xsl:param name="selected-value" select="node-expected|current()"/>
		<xsl:if test="../@id = $selected-value or ../@key = $selected-value">
			<xsl:attribute name="selected"/>
		</xsl:if>
	</xsl:template>

	<xsl:template mode="combobox:option" match="@*|*">
		<xsl:param name="selected-value" select="node-expected|current()"/>
		<xsl:param name="schema" select="current()"/>
		<xsl:variable name="current" select="current()"/>
		<xsl:variable name="value">
			<xsl:apply-templates mode="combobox:option-value" select="."></xsl:apply-templates>
		</xsl:variable>
		<option class="data-row">
			<xsl:if test="$selected-value=$value">
				<xsl:attribute name="selected"/>
			</xsl:if>
			<xsl:if test="$value!=.">
				<xsl:attribute name="value">
					<xsl:value-of select="$value"/>
				</xsl:attribute>
			</xsl:if>
			<!--<xsl:apply-templates mode="combobox:option-selected" select="."/>-->
			<xsl:apply-templates mode="combobox:option-text" select="."/>
			<xsl:apply-templates mode="combobox:option-attributes" select="."/>
		</option>
	</xsl:template>

	<xsl:template mode="combobox:option-clear" match="@*">
		<option class="data-row non-filterable" value="" style="color: red">- BORRAR SELECCIÓN -</option>
	</xsl:template>
</xsl:stylesheet>