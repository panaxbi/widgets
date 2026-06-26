<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cfdi="http://www.sat.gob.mx/cfd/4" xmlns:tfd="http://www.sat.gob.mx/TimbreFiscalDigital" exclude-result-prefixes="cfdi tfd">
    <xsl:template match="cfdi:Comprobante" mode="cfdi:header">
        <header class="cfdi-header">
            <div class="cfdi-header-brand"><div class="cfdi-sat-mark"><span class="cfdi-sat-title">SAT</span><span class="cfdi-sat-subtitle">Servicio de Administración Tributaria</span></div><div class="cfdi-document-title"><h1>Comprobante Fiscal Digital por Internet</h1><p>Versión <xsl:value-of select="@Version"/></p></div></div>
            <div class="cfdi-header-stamp">
                <div class="cfdi-stamp-row"><span>Folio fiscal</span><strong><xsl:value-of select="cfdi:Complemento/tfd:TimbreFiscalDigital/@UUID"/></strong></div>
                <div class="cfdi-stamp-row"><span>Fecha de emisión</span><strong><xsl:value-of select="@Fecha"/></strong></div>
                <div class="cfdi-stamp-row"><span>Fecha certificación</span><strong><xsl:value-of select="cfdi:Complemento/tfd:TimbreFiscalDigital/@FechaTimbrado"/></strong></div>
            </div>
        </header>
    </xsl:template>
</xsl:stylesheet>
