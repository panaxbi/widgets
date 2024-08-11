<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns="http://www.w3.org/1999/xhtml"
xmlns:site="http://panax.io/site"
xmlns:state="http://panax.io/state"
xmlns:px="http://panax.io/entity"
>
	<xsl:output method="xml"
	   omit-xml-declaration="yes"
	   indent="yes"/>
	<xsl:param name="site:seed"></xsl:param>

	<xsl:key name="title" match="item/@title" use="../@target"/>

	<xsl:template match="/">
		<h1>
			<xsl:apply-templates/>
		</h1>
	</xsl:template>

	<xsl:template match="*">
		<xsl:variable name="title">
			<xsl:value-of select="key('title',substring-before(concat($site:seed,'?'),'?'))"/>
		</xsl:variable>
		<script>window.document.title = `Panax BI - <xsl:value-of select="$title"/>`</script>
		<xsl:value-of select="$title"/>
		<!--<xsl:value-of select="substring-before(translate(concat($site:seed,'?'),'_#',' '),'?')"/>-->
	</xsl:template>

	<xsl:template match="model">
		<xsl:choose>
			<xsl:when test="$site:seed=''">
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="substring-before(translate(concat($site:seed,'?'),'_#',' '),'?')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[@headerText]">
		<xsl:apply-templates select="@headerText"/>
	</xsl:template>

	<xsl:template match="@headerText">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="@headerText[starts-with(.,'Tipo')]">
		<xsl:value-of select="concat(substring(.,1,5), 'de ', substring(.,6))"/>
	</xsl:template>
</xsl:stylesheet>
