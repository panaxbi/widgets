<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" exclude-result-prefixes="cfdi" xmlns:cfdi="http://www.sat.gob.mx/cfd/4">
  <xsl:template match="cfdi:Comprobante" mode="cfdi:totales">
    <xsl:choose>
      <xsl:when test="@TipoDeComprobante='P'">
        <section class="cfdi-panel cfdi-receipt-total" aria-label="Total del comprobante">
          <div class="cfdi-total-line">
            <span>Total del comprobante (XXX)</span>
            <strong>
              <xsl:call-template name="cfdi-money">
                <xsl:with-param name="value" select="@Total" />
              </xsl:call-template>
            </strong>
          </div>
          <p>El monto recibido se muestra en los totales del complemento.</p>
        </section>
      </xsl:when>
      <xsl:otherwise>
        <section class="cfdi-panel cfdi-totales" aria-label="Totales">
          <h2>Totales</h2>
          <div class="cfdi-total-box">
            <div class="cfdi-total-line">
              <span>Subtotal</span>
              <strong>
                <xsl:call-template name="cfdi-money">
                  <xsl:with-param name="value" select="@SubTotal" />
                </xsl:call-template>
              </strong>
            </div>
            <xsl:if test="@Descuento">
              <div class="cfdi-total-line">
                <span>Descuento</span>
                <strong>
                  <xsl:call-template name="cfdi-money">
                    <xsl:with-param name="value" select="@Descuento" />
                  </xsl:call-template>
                </strong>
              </div>
            </xsl:if>
            <xsl:choose>
              <xsl:when test="cfdi:Impuestos/cfdi:Traslados/cfdi:Traslado">
                <xsl:for-each select="cfdi:Impuestos/cfdi:Traslados/cfdi:Traslado">
                  <div class="cfdi-total-line cfdi-tax-total-line">
                    <span>Traslado <xsl:apply-templates select="@Impuesto" mode="cfdi:catalog-label" />
                      <xsl:if test="@TasaOCuota">
                        <xsl:text> / </xsl:text>
                        <xsl:call-template name="cfdi-rate">
                          <xsl:with-param name="value" select="@TasaOCuota" />
                        </xsl:call-template>
                      </xsl:if>
                    </span>
                    <strong>
                      <xsl:call-template name="cfdi-money">
                        <xsl:with-param name="value" select="@Importe" />
                      </xsl:call-template>
                    </strong>
                  </div>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <div class="cfdi-total-line">
                  <span>Impuestos trasladados</span>
                  <strong>
                    <xsl:call-template name="cfdi-money">
                      <xsl:with-param name="value" select="cfdi:Impuestos/@TotalImpuestosTrasladados" />
                    </xsl:call-template>
                  </strong>
                </div>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
              <xsl:when test="cfdi:Impuestos/cfdi:Retenciones/cfdi:Retencion">
                <xsl:for-each select="cfdi:Impuestos/cfdi:Retenciones/cfdi:Retencion">
                  <div class="cfdi-total-line cfdi-tax-total-line">
                    <span>Retención <xsl:apply-templates select="@Impuesto" mode="cfdi:catalog-label" />
                      <xsl:if test="@TasaOCuota">
                        <xsl:text> / </xsl:text>
                        <xsl:call-template name="cfdi-rate">
                          <xsl:with-param name="value" select="@TasaOCuota" />
                        </xsl:call-template>
                      </xsl:if>
                    </span>
                    <strong>
                      <xsl:call-template name="cfdi-money">
                        <xsl:with-param name="value" select="@Importe" />
                      </xsl:call-template>
                    </strong>
                  </div>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <div class="cfdi-total-line">
                  <span>Impuestos retenidos</span>
                  <strong>
                    <xsl:call-template name="cfdi-money">
                      <xsl:with-param name="value" select="cfdi:Impuestos/@TotalImpuestosRetenidos" />
                    </xsl:call-template>
                  </strong>
                </div>
              </xsl:otherwise>
            </xsl:choose>
            <div class="cfdi-total-line cfdi-grand-total">
              <span>Total</span>
              <strong>
                <xsl:value-of select="@Moneda" />
                <xsl:text> </xsl:text>
                <xsl:call-template name="cfdi-money">
                  <xsl:with-param name="value" select="@Total" />
                </xsl:call-template>
              </strong>
            </div>
          </div>
        </section>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>