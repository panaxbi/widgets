<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xo="http://panax.io/xover"
>
	<xsl:template mode="xo:name" match="@*|*">
		<xsl:if test="position()!=1">, </xsl:if>
		<xsl:value-of select="name()"/>
	</xsl:template>

	<xsl:template mode="xo:value" match="@*|*">
		<xsl:if test="position()!=1">, </xsl:if>
		<xsl:value-of select="."/>
	</xsl:template>
	
</xsl:stylesheet>