<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xo="http://panax.io/xover"
  xmlns:data="http://panax.io/data"
  xmlns:state="http://panax.io/state"
  xmlns:datatype="http://panax.io/datatype"
  xmlns:env="http://panax.io/state/environment"
  exclude-result-prefixes="xo xsl"
>
	<xsl:import href="functions.xslt"/>

	<xsl:key name="data_type" match="path-to-attrib" use="'type'"/>
	<xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'" />
	<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />

	<xsl:template mode="class" match="*|@*"></xsl:template>
	<xsl:template mode="styles" match="*|@*"></xsl:template>

	<xsl:template mode="styles" match="*[@color]|*[@color]/@*" priority="1">
		background:<xsl:value-of select="ancestor-or-self::*/@color"/> !important; color: white;
	</xsl:template>

	<xsl:template mode="value" match="@status">
		<xsl:value-of select="concat(translate(substring(.,1,1),$lowercase,$uppercase), substring(.,2))"/>
	</xsl:template>

	<xsl:template mode="value" match="@*">
		<xsl:value-of select="../@id"/>
	</xsl:template>

	<xsl:template mode="value" match="fecha/@*">
		<xsl:value-of select="../@mes"/>
	</xsl:template>

	<xsl:template mode="key" match="@*">
		<xsl:text>::</xsl:text>
		<xsl:value-of select="name(..)"/>
		<xsl:text>:</xsl:text>
		<xsl:value-of select="../@id"/>
	</xsl:template>

	<xsl:template mode="key" match="fecha/@*">
		<xsl:text>::</xsl:text>
		<xsl:value-of select="name(..)"/>
		<xsl:text>:</xsl:text>
		<xsl:value-of select="../@mes"/>
	</xsl:template>

	<xsl:template mode="dimension-attribute" match="@*">
		<xsl:attribute name="{name(..)}">
			<xsl:apply-templates mode="value" select="."/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template mode="dimension-attribute" match="razon_social/@*">
		<xsl:attribute name="rs">
			<xsl:apply-templates mode="value" select="."/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template mode="dimension-attribute" match="producto/@*">
		<xsl:attribute name="prod">
			<xsl:apply-templates mode="value" select="."/>
		</xsl:attribute>
	</xsl:template>

	<xsl:template mode="button" match="*|@*">
		<xsl:variable name="element" select="ancestor-or-self::*[1]"/>
		<xsl:variable name="active" select="$element/@state:checked='true'"/>
		<xsl:variable name="style">
			<xsl:if test="$active">
				<xsl:text>active</xsl:text>
			</xsl:if>
		</xsl:variable>
		<button type="button" class="btn btn-outline-secondary {$style}" xo-slot="state:checked" onclick="scope.toggle('true');" style="white-space: nowrap;">
			<xsl:choose>
				<xsl:when test="//model/@env:store='#razones_financieras'"></xsl:when>
				<xsl:when test="$active">
					<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-x-square" viewBox="0 0 16 16" style="margin-right: 5pt" onclick="scope.remove(); event.stopPropagation(); return false" xo-slot="state:checked">
						<path d="M14 1a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1h12zM2 0a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V2a2 2 0 0 0-2-2H2z"/>
						<path d="M4.646 4.646a.5.5 0 0 1 .708 0L8 7.293l2.646-2.647a.5.5 0 0 1 .708.708L8.707 8l2.647 2.646a.5.5 0 0 1-.708.708L8 8.707l-2.646 2.647a.5.5 0 0 1-.708-.708L7.293 8 4.646 5.354a.5.5 0 0 1 0-.708z"/>
					</svg>
				</xsl:when>
				<xsl:otherwise>
					<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-square" viewBox="0 0 16 16" style="margin-right: 5pt" onclick="scope.set('true'); event.stopPropagation(); return false;" xo-slot="state:checked">
						<path d="M14 1a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1h12zM2 0a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V2a2 2 0 0 0-2-2H2z"/>
					</svg>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates mode="headerText" select="."/>
		</button>
	</xsl:template>

	<xsl:key name="datatype" match="*/@datatype:*" use="concat(.,':',local-name())"/>
	<xsl:template match="key('data_type', 'money')|@*[key('datatype', concat('money:',name()))]">
		<xsl:call-template name="format">
			<xsl:with-param name="value" select="."></xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="key('data_type', 'percent')|@*[key('datatype', concat('percent:',name()))]">
		<xsl:call-template name="format-percent">
			<xsl:with-param name="value" select="."></xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="key('data_type', 'number')|@*[key('datatype', concat('number:',name()))]">
		<xsl:call-template name="format">
			<xsl:with-param name="value" select="number(.)"></xsl:with-param>
			<xsl:with-param name="mask">###,##0.00;-###,##0.00</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="key('data_type', 'integer')|@*[key('datatype', concat('integer:',name()))]">
		<xsl:call-template name="format">
			<xsl:with-param name="value" select="number(.)"></xsl:with-param>
			<xsl:with-param name="mask">###,##0;-###,##0</xsl:with-param>
		</xsl:call-template>
	</xsl:template>

	<xsl:template match="key('data_type', 'date')|@*[key('datatype', concat('date:',name()))]">
		<xsl:value-of select="substring(.,1,4)"/>
		<xsl:text>-</xsl:text>
		<xsl:value-of select="substring(.,5,2)"/>
		<xsl:if test="substring(.,7,2)!=''">
			<xsl:text>-</xsl:text>
			<xsl:value-of select="substring(.,7,2)"/>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>