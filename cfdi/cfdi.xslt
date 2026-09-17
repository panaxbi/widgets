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
	<xsl:include href="sections/catalogos.xslt"/>
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
		<div class="xover-widget xover-widget-cfdi cfdi-sat cfdi-reference" data-widget="widgets/cfdi" data-cfdi-version="{@Version}">
			<link rel="stylesheet" href="cfdi.css?v=260917_01" />
			<xsl:apply-templates select="." mode="cfdi:header"/>
			<main class="cfdi-body">

				<xsl:apply-templates select="cfdi:Complemento/pago20:Pagos" mode="cfdi:pagos20"/>
				<xsl:apply-templates select="cfdi:Conceptos" mode="cfdi:conceptos"/>
				<xsl:if test="cfdi:Impuestos"><details class="cfdi-global-tax-details"><summary>Ver desglose global de impuestos</summary><xsl:apply-templates select="cfdi:Impuestos" mode="cfdi:impuestos"/></details></xsl:if>
				<div class="cfdi-settlement"><section class="cfdi-payment-method" aria-label="Condiciones de pago"><xsl:call-template name="cfdi-field"><xsl:with-param name="label">Moneda:</xsl:with-param><xsl:with-param name="value"><xsl:apply-templates select="@Moneda" mode="cfdi:catalog-label"/></xsl:with-param></xsl:call-template><xsl:call-template name="cfdi-field"><xsl:with-param name="label">Forma de pago:</xsl:with-param><xsl:with-param name="value"><xsl:apply-templates select="@FormaPago" mode="cfdi:catalog-label"/></xsl:with-param></xsl:call-template><xsl:call-template name="cfdi-field"><xsl:with-param name="label">M&#233;todo de pago:</xsl:with-param><xsl:with-param name="value"><xsl:apply-templates select="@MetodoPago" mode="cfdi:catalog-label"/></xsl:with-param></xsl:call-template><xsl:if test="@TipoCambio and not(@Moneda='MXN' and number(@TipoCambio)=1)"><xsl:call-template name="cfdi-field"><xsl:with-param name="label">Tipo de cambio:</xsl:with-param><xsl:with-param name="value"><xsl:apply-templates select="@TipoCambio" mode="cfdi:exchange-rate"/></xsl:with-param></xsl:call-template></xsl:if></section><xsl:apply-templates select="." mode="cfdi:totales"/></div>
<section class="cfdi-reference-seals" aria-label="Sellos digitales"><xsl:apply-templates select="." mode="cfdi:sello-cfd"/><xsl:apply-templates select="cfdi:Complemento/tfd:TimbreFiscalDigital" mode="cfdi:sello-sat"/></section>
<section class="cfdi-reference-certification" aria-label="Certificaci&#243;n digital">
<xsl:apply-templates select="cfdi:Complemento/tfd:TimbreFiscalDigital" mode="cfdi:qr"/>
<div><xsl:apply-templates select="cfdi:Complemento/tfd:TimbreFiscalDigital" mode="cfdi:cadena-original"/><xsl:apply-templates select="cfdi:Complemento/tfd:TimbreFiscalDigital" mode="cfdi:timbre"/></div>
</section><footer class="cfdi-print-note">Este documento es una representaci&#243;n impresa de un CFDI</footer>
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
			<xsl:when test="number($value) = 0"><xsl:text>0.00</xsl:text></xsl:when>
			<xsl:when test="string($value) != ''">
				<xsl:value-of select="format-number(number($value), '#,##0.00', 'mxn')"/>
			</xsl:when>
			<xsl:otherwise>&#8212;</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="cfdi-rate">
        <xsl:param name="value"/>
        <xsl:param name="factor" select="@TipoFactor | @TipoFactorDR | @TipoFactorP"/>
        <xsl:choose>
            <xsl:when test="string($value) = ''">-</xsl:when>
            <xsl:when test="$factor = 'Tasa'">
                <xsl:value-of select="format-number(number($value) * 100, '0.00##')"/>
                <xsl:text>%</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="format-number(number($value), '0.000000')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
