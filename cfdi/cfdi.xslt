<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cfdi="http://www.sat.gob.mx/cfd/4"
    xmlns:tfd="http://www.sat.gob.mx/TimbreFiscalDigital"
    xmlns:pago20="http://www.sat.gob.mx/Pagos20"
    exclude-result-prefixes="cfdi tfd pago20"
    xmlns:factura="http://panax.io/widget/factura"
		xmlns="http://www.w3.org/1999/xhtml"
>

	<xsl:output method="html" encoding="UTF-8" indent="yes"/>
	<xsl:strip-space elements="*"/>
	<xsl:decimal-format name="mxn" decimal-separator="." grouping-separator=","/>

	<xsl:include href="sections/header.xslt"/>
	<xsl:include href="sections/parties.xslt"/>
	<xsl:include href="sections/comprobante.xslt"/>
	<xsl:include href="sections/conceptos.xslt"/>
	<xsl:include href="sections/impuestos.xslt"/>
	<xsl:include href="sections/totales.xslt"/>
	<xsl:include href="sections/timbre.xslt"/>
	<xsl:include href="sections/qr.xslt"/>
	<xsl:include href="sections/sellos.xslt"/>
	<xsl:include href="complementos/pagos20.xslt"/>

	<xsl:template match="/">
		<xsl:apply-templates mode="factura:widget"/>
	</xsl:template>

	<xsl:template match="*[not(*)]" mode="factura:widget"/>

	<xsl:template match="cfdi:Comprobante" mode="factura:widget">
		<div class="xover-widget xover-widget-cfdi cfdi-sat" data-widget="widgets/cfdi" data-cfdi-version="{@Version}">
			<link rel="stylesheet" href="cfdi.css?v=270127_2356" />
			<xsl:apply-templates select="." mode="cfdi:header"/>
			<main class="cfdi-body">
				<section class="cfdi-main-grid" aria-label="Datos principales del comprobante">
					<xsl:apply-templates select="." mode="cfdi:parties"/>
					<xsl:apply-templates select="." mode="cfdi:comprobante"/>
				</section>
				<xsl:apply-templates select="cfdi:Conceptos" mode="cfdi:conceptos"/>
				<xsl:apply-templates select="cfdi:Impuestos" mode="cfdi:impuestos"/>
				<xsl:apply-templates select="cfdi:Complemento/pago20:Pagos" mode="cfdi:pagos20"/>
				<xsl:apply-templates select="." mode="cfdi:totales"/>
				<section class="cfdi-certification-grid" aria-label="Certificación digital">
					<xsl:apply-templates select="cfdi:Complemento/tfd:TimbreFiscalDigital" mode="cfdi:timbre"/>
					<xsl:apply-templates select="cfdi:Complemento/tfd:TimbreFiscalDigital" mode="cfdi:qr"/>
				</section>
				<xsl:apply-templates select="." mode="cfdi:sellos"/>
			</main>
		</div>
	</xsl:template>

	<xsl:template name="cfdi-field">
		<xsl:param name="label"/>
		<xsl:param name="value"/>
		<xsl:param name="class"/>
		<div>
			<xsl:attribute name="class">
				<xsl:text>cfdi-field</xsl:text>
				<xsl:if test="string($class) != ''">
					<xsl:text> </xsl:text>
					<xsl:value-of select="$class"/>
				</xsl:if>
			</xsl:attribute>
			<span class="cfdi-label">
				<xsl:value-of select="$label"/>
			</span>
			<span class="cfdi-value">
				<xsl:choose>
					<xsl:when test="string($value) != ''">
						<xsl:value-of select="$value"/>
					</xsl:when>
					<xsl:otherwise>-</xsl:otherwise>
				</xsl:choose>
			</span>
		</div>
	</xsl:template>

	<xsl:template name="cfdi-money">
		<xsl:param name="value"/>
		<xsl:choose>
			<xsl:when test="string($value) != ''">
				<xsl:value-of select="format-number(number($value), '#,##0.00', 'mxn')"/>
			</xsl:when>
			<xsl:otherwise>0.00</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="cfdi-rate">
		<xsl:param name="value"/>
		<xsl:choose>
			<xsl:when test="string($value) != ''">
				<xsl:value-of select="format-number(number($value), '0.000000')"/>
			</xsl:when>
			<xsl:otherwise>-</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
