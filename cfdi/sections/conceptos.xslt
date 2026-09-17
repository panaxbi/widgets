<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" exclude-result-prefixes="cfdi" xmlns:cfdi="http://www.sat.gob.mx/cfd/4">
  <xsl:template match="cfdi:Conceptos" mode="cfdi:conceptos">
    <section class="cfdi-panel cfdi-conceptos" aria-label="Conceptos">
      <h2>Conceptos</h2>
      <xsl:for-each select="cfdi:Concepto">
        <article class="cfdi-concept-card">
          <div class="cfdi-table-wrap">
            <table class="cfdi-table cfdi-concept-table">
              <thead>
                <tr>
                  <th>Clave prod/serv</th>
                  <th>No. identificación</th>
                  <th>Cantidad</th>
                  <th>Clave unidad</th>
                  <th>Unidad</th>
                  <th>Valor unitario</th>
                  <th>Importe</th>
                  <th>Descuento</th>
                  <th>Objeto imp.</th>
                </tr>
              </thead>
              <tbody>
                <xsl:apply-templates select="." mode="cfdi:concepto-row" />
              </tbody>
            </table>
          </div>
          <div class="cfdi-concept-detail-grid">
            <div class="cfdi-concept-description">
              <strong>Descripción</strong>
              <p>
                <xsl:value-of select="@Descripcion" />
              </p>
            </div>
            <xsl:apply-templates select="." mode="cfdi:concepto-tax-detail" />
          </div>
        </article>
      </xsl:for-each>
    </section>
  </xsl:template>
  <xsl:template match="cfdi:Concepto" mode="cfdi:concepto-row">
    <tr>
      <td>
        <xsl:value-of select="@ClaveProdServ" />
      </td>
      <td>
        <xsl:value-of select="@NoIdentificacion" />
      </td>
      <td class="cfdi-number">
        <xsl:value-of select="@Cantidad" />
      </td>
      <td>
        <xsl:value-of select="@ClaveUnidad" />
      </td>
      <td>
        <xsl:value-of select="@Unidad" />
      </td>
      <td class="cfdi-money">
        <xsl:call-template name="cfdi-money">
          <xsl:with-param name="value" select="@ValorUnitario" />
        </xsl:call-template>
      </td>
      <td class="cfdi-money">
        <xsl:call-template name="cfdi-money">
          <xsl:with-param name="value" select="@Importe" />
        </xsl:call-template>
      </td>
      <td class="cfdi-money">
        <xsl:call-template name="cfdi-money">
          <xsl:with-param name="value" select="@Descuento" />
        </xsl:call-template>
      </td>
      <td>
        <xsl:apply-templates select="@ObjetoImp" mode="cfdi:catalog-label" />
      </td>
    </tr>
  </xsl:template>
  <xsl:template match="cfdi:Concepto" mode="cfdi:concepto-tax-detail">
    <xsl:if test="cfdi:Impuestos/*/*">
      <div class="cfdi-table-wrap cfdi-inline-taxes">
        <table class="cfdi-table cfdi-small-table">
          <caption class="cfdi-visually-hidden">Impuestos del concepto</caption>
          <thead>
            <tr>
              <th scope="col">Impuesto</th>
              <th scope="col">Tipo</th>
              <th scope="col">Base</th>
              <th scope="col">Tipo factor</th>
              <th scope="col">Tasa o cuota</th>
              <th scope="col">Importe</th>
            </tr>
          </thead>
          <tbody>
            <xsl:apply-templates select="cfdi:Impuestos/cfdi:Traslados/cfdi:Traslado | cfdi:Impuestos/cfdi:Retenciones/cfdi:Retencion" mode="cfdi:tax-row" />
          </tbody>
        </table>
      </div>
    </xsl:if>
  </xsl:template>
  <xsl:template match="cfdi:Traslado | cfdi:Retencion" mode="cfdi:tax-row">
    <tr>
      <td>
        <xsl:apply-templates select="@Impuesto" mode="cfdi:catalog-label" />
      </td>
      <td>
        <xsl:choose>
          <xsl:when test="self::cfdi:Traslado">Traslado</xsl:when>
          <xsl:otherwise>Retención</xsl:otherwise>
        </xsl:choose>
      </td>
      <td class="cfdi-money">
        <xsl:call-template name="cfdi-money">
          <xsl:with-param name="value" select="@Base" />
        </xsl:call-template>
      </td>
      <td>
        <xsl:value-of select="@TipoFactor" />
      </td>
      <td class="cfdi-number">
        <xsl:call-template name="cfdi-rate">
          <xsl:with-param name="value" select="@TasaOCuota" />
        </xsl:call-template>
      </td>
      <td class="cfdi-money">
        <xsl:call-template name="cfdi-money">
          <xsl:with-param name="value" select="@Importe" />
        </xsl:call-template>
      </td>
    </tr>
  </xsl:template>
</xsl:stylesheet>