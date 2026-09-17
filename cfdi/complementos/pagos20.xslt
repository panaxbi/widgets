<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" exclude-result-prefixes="pago20 cfdi" xmlns:cfdi="http://www.sat.gob.mx/cfd/4" xmlns:pago20="http://www.sat.gob.mx/Pagos20">
  <xsl:template match="pago20:Pagos" mode="cfdi:pagos20">
    <section class="cfdi-panel cfdi-pagos20" aria-label="Complemento de pagos 2.0">
      <h2>Complemento para recepción de pagos 2.0</h2>
      <xsl:apply-templates select="pago20:Pago" mode="cfdi:pagos20-pago" />
      <xsl:apply-templates select="pago20:Totales" mode="cfdi:pagos20-totales" />
    </section>
  </xsl:template>
  <xsl:template match="pago20:Totales" mode="cfdi:pagos20-totales">
    <article class="cfdi-payment-totals">
      <h3>Totales del complemento</h3>
      <div class="cfdi-data-grid">
        <xsl:if test="@TotalRetencionesIVA">
          <xsl:call-template name="cfdi-field">
            <xsl:with-param name="label" select="'Total retenciones IVA'" />
            <xsl:with-param name="value">
              <xsl:call-template name="cfdi-money">
                <xsl:with-param name="value" select="@TotalRetencionesIVA" />
              </xsl:call-template>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="@TotalRetencionesISR">
          <xsl:call-template name="cfdi-field">
            <xsl:with-param name="label" select="'Total retenciones ISR'" />
            <xsl:with-param name="value">
              <xsl:call-template name="cfdi-money">
                <xsl:with-param name="value" select="@TotalRetencionesISR" />
              </xsl:call-template>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="@TotalRetencionesIEPS">
          <xsl:call-template name="cfdi-field">
            <xsl:with-param name="label" select="'Total retenciones IEPS'" />
            <xsl:with-param name="value">
              <xsl:call-template name="cfdi-money">
                <xsl:with-param name="value" select="@TotalRetencionesIEPS" />
              </xsl:call-template>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="@TotalTrasladosBaseIVA16">
          <xsl:call-template name="cfdi-field">
            <xsl:with-param name="label" select="'Total traslados base IVA 16%'" />
            <xsl:with-param name="value">
              <xsl:call-template name="cfdi-money">
                <xsl:with-param name="value" select="@TotalTrasladosBaseIVA16" />
              </xsl:call-template>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="@TotalTrasladosImpuestoIVA16">
          <xsl:call-template name="cfdi-field">
            <xsl:with-param name="label" select="'Total traslados impuesto IVA 16%'" />
            <xsl:with-param name="value">
              <xsl:call-template name="cfdi-money">
                <xsl:with-param name="value" select="@TotalTrasladosImpuestoIVA16" />
              </xsl:call-template>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="@TotalTrasladosBaseIVA8">
          <xsl:call-template name="cfdi-field">
            <xsl:with-param name="label" select="'Total traslados base IVA 8%'" />
            <xsl:with-param name="value">
              <xsl:call-template name="cfdi-money">
                <xsl:with-param name="value" select="@TotalTrasladosBaseIVA8" />
              </xsl:call-template>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="@TotalTrasladosImpuestoIVA8">
          <xsl:call-template name="cfdi-field">
            <xsl:with-param name="label" select="'Total traslados impuesto IVA 8%'" />
            <xsl:with-param name="value">
              <xsl:call-template name="cfdi-money">
                <xsl:with-param name="value" select="@TotalTrasladosImpuestoIVA8" />
              </xsl:call-template>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="@TotalTrasladosBaseIVA0">
          <xsl:call-template name="cfdi-field">
            <xsl:with-param name="label" select="'Total traslados base IVA 0%'" />
            <xsl:with-param name="value">
              <xsl:call-template name="cfdi-money">
                <xsl:with-param name="value" select="@TotalTrasladosBaseIVA0" />
              </xsl:call-template>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="@TotalTrasladosImpuestoIVA0">
          <xsl:call-template name="cfdi-field">
            <xsl:with-param name="label" select="'Total traslados impuesto IVA 0%'" />
            <xsl:with-param name="value">
              <xsl:call-template name="cfdi-money">
                <xsl:with-param name="value" select="@TotalTrasladosImpuestoIVA0" />
              </xsl:call-template>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="@TotalTrasladosBaseIVAExento">
          <xsl:call-template name="cfdi-field">
            <xsl:with-param name="label" select="'Total traslados base IVA exento'" />
            <xsl:with-param name="value">
              <xsl:call-template name="cfdi-money">
                <xsl:with-param name="value" select="@TotalTrasladosBaseIVAExento" />
              </xsl:call-template>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="@MontoTotalPagos">
          <xsl:call-template name="cfdi-field">
            <xsl:with-param name="label" select="'Monto total pagado (MXN)'" />
            <xsl:with-param name="value">MXN <xsl:call-template name="cfdi-money">
                <xsl:with-param name="value" select="@MontoTotalPagos" />
              </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="class" select="'cfdi-total-field'" />
          </xsl:call-template>
        </xsl:if>
      </div>
    </article>
  </xsl:template>
  <xsl:template match="pago20:Pago" mode="cfdi:pagos20-pago">
    <article class="cfdi-payment">
      <h3>Pago <xsl:number count="pago20:Pago" />
      </h3>
      <div class="cfdi-data-grid">
        <xsl:call-template name="cfdi-field">
          <xsl:with-param name="label" select="'Fecha de pago'" />
          <xsl:with-param name="value" select="@FechaPago" />
        </xsl:call-template>
        <xsl:call-template name="cfdi-field">
          <xsl:with-param name="label" select="'Forma de pago'" />
          <xsl:with-param name="value">
            <xsl:apply-templates select="@FormaDePagoP" mode="cfdi:payment-label" />
          </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="cfdi-field">
          <xsl:with-param name="label" select="'Moneda'" />
          <xsl:with-param name="value">
            <xsl:apply-templates select="@MonedaP" mode="cfdi:payment-label" />
          </xsl:with-param>
        </xsl:call-template>
        <xsl:if test="@TipoCambioP and not(@MonedaP='MXN' and number(@TipoCambioP)=1)">
          <xsl:call-template name="cfdi-field">
            <xsl:with-param name="label" select="'Tipo cambio'" />
            <xsl:with-param name="value"><xsl:apply-templates select="@TipoCambioP" mode="cfdi:exchange-rate"/></xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="cfdi-field">
          <xsl:with-param name="label" select="'Monto'" />
          <xsl:with-param name="value">
            <xsl:call-template name="cfdi-money">
              <xsl:with-param name="value" select="@Monto" />
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:if test="@NumOperacion">
          <xsl:call-template name="cfdi-field">
            <xsl:with-param name="label" select="'No. operación'" />
            <xsl:with-param name="value" select="@NumOperacion" />
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="@RfcEmisorCtaOrd">
          <xsl:call-template name="cfdi-field">
            <xsl:with-param name="label" select="'RFC emisor cuenta ordenante'" />
            <xsl:with-param name="value" select="@RfcEmisorCtaOrd" />
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="@CtaOrdenante">
          <xsl:call-template name="cfdi-field">
            <xsl:with-param name="label" select="'Cuenta ordenante'" />
            <xsl:with-param name="value" select="@CtaOrdenante" />
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="@RfcEmisorCtaBen">
          <xsl:call-template name="cfdi-field">
            <xsl:with-param name="label" select="'RFC emisor cuenta beneficiario'" />
            <xsl:with-param name="value" select="@RfcEmisorCtaBen" />
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="@CtaBeneficiario">
          <xsl:call-template name="cfdi-field">
            <xsl:with-param name="label" select="'Cuenta beneficiario'" />
            <xsl:with-param name="value" select="@CtaBeneficiario" />
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="@TipoCadPago">
          <xsl:call-template name="cfdi-field">
            <xsl:with-param name="label" select="'Tipo cadena pago'" />
            <xsl:with-param name="value" select="@TipoCadPago" />
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="@CertPago">
          <xsl:call-template name="cfdi-field">
            <xsl:with-param name="label" select="'Certificado pago'" />
            <xsl:with-param name="value" select="@CertPago" />
            <xsl:with-param name="class" select="'cfdi-wide'" />
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="@CadPago">
          <xsl:call-template name="cfdi-field">
            <xsl:with-param name="label" select="'Cadena pago'" />
            <xsl:with-param name="value" select="@CadPago" />
            <xsl:with-param name="class" select="'cfdi-wide'" />
          </xsl:call-template>
        </xsl:if>
        <xsl:if test="@SelloPago">
          <xsl:call-template name="cfdi-field">
            <xsl:with-param name="label" select="'Sello pago'" />
            <xsl:with-param name="value" select="@SelloPago" />
            <xsl:with-param name="class" select="'cfdi-wide'" />
          </xsl:call-template>
        </xsl:if>
      </div>
      <div class="cfdi-table-wrap">
        <table class="cfdi-table cfdi-documents-table">
          <caption>Documentos relacionados</caption>
          <thead>
            <tr>
              <th scope="col">Folio / Serie</th>
              <th scope="col">Documento / UUID</th>
              <th scope="col">Moneda</th>
              <th scope="col">Parcialidad</th>
              <th scope="col">Saldo anterior</th>
              <th scope="col">Importe pagado</th>
              <th scope="col">Saldo insoluto</th>
            </tr>
          </thead>
          <tbody>
            <xsl:apply-templates select="pago20:DoctoRelacionado" mode="cfdi:pagos20-docto" />
          </tbody>
        </table>
      </div>
      <xsl:apply-templates select="pago20:ImpuestosP" mode="cfdi:pagos20-impuestos" />
    </article>
  </xsl:template>
  <xsl:template match="pago20:DoctoRelacionado" mode="cfdi:pagos20-docto">
    <tr class="cfdi-document-row">
      <td>
        <xsl:value-of select="@Folio" />
        <small>
          <xsl:value-of select="@Serie" />
        </small>
      </td>
      <td>
        <small>Documento relacionado <xsl:number count="pago20:DoctoRelacionado" />
        </small>
        <xsl:value-of select="@IdDocumento" />
        <small>Objeto de impuesto: <xsl:apply-templates select="@ObjetoImpDR" mode="cfdi:payment-label" />
        </small>
      </td>
      <td>
        <xsl:value-of select="@MonedaDR" />
        <xsl:if test="@EquivalenciaDR">
          <small>Equivalencia: <xsl:value-of select="@EquivalenciaDR" />
          </small>
        </xsl:if>
      </td>
      <td class="cfdi-number">
        <xsl:value-of select="@NumParcialidad" />
      </td>
      <td class="cfdi-money">
        <xsl:call-template name="cfdi-money">
          <xsl:with-param name="value" select="@ImpSaldoAnt" />
        </xsl:call-template>
      </td>
      <td class="cfdi-money">
        <xsl:call-template name="cfdi-money">
          <xsl:with-param name="value" select="@ImpPagado" />
        </xsl:call-template>
      </td>
      <td class="cfdi-money">
        <xsl:call-template name="cfdi-money">
          <xsl:with-param name="value" select="@ImpSaldoInsoluto" />
        </xsl:call-template>
      </td>
    </tr>
    <xsl:if test="pago20:ImpuestosDR">
      <tr class="cfdi-document-taxes">
        <td colspan="7">
          <xsl:apply-templates select="pago20:ImpuestosDR" mode="cfdi:pagos20-impuestos-dr" />
        </td>
      </tr>
    </xsl:if>
  </xsl:template>
  <xsl:template match="pago20:ImpuestosDR" mode="cfdi:pagos20-impuestos-dr">
    <div class="cfdi-payment-tax-detail">
      <xsl:if test="pago20:RetencionesDR/pago20:RetencionDR">
        <h5>Retenciones DR</h5>
        <xsl:call-template name="cfdi-pagos20-tax-table">
          <xsl:with-param name="nodes" select="pago20:RetencionesDR/pago20:RetencionDR" />
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="pago20:TrasladosDR/pago20:TrasladoDR">
        <h5>Traslados DR</h5>
        <xsl:call-template name="cfdi-pagos20-tax-table">
          <xsl:with-param name="nodes" select="pago20:TrasladosDR/pago20:TrasladoDR" />
        </xsl:call-template>
      </xsl:if>
    </div>
  </xsl:template>
  <xsl:template match="pago20:ImpuestosP" mode="cfdi:pagos20-impuestos">
    <section class="cfdi-payment-tax-detail">
      <h4>Impuestos del pago</h4>
      <xsl:if test="pago20:RetencionesP/pago20:RetencionP">
        <h5>Retenciones P</h5>
        <xsl:call-template name="cfdi-pagos20-tax-table">
          <xsl:with-param name="nodes" select="pago20:RetencionesP/pago20:RetencionP" />
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="pago20:TrasladosP/pago20:TrasladoP">
        <h5>Traslados P</h5>
        <xsl:call-template name="cfdi-pagos20-tax-table">
          <xsl:with-param name="nodes" select="pago20:TrasladosP/pago20:TrasladoP" />
        </xsl:call-template>
      </xsl:if>
    </section>
  </xsl:template>
  <xsl:template name="cfdi-pagos20-tax-table">
    <xsl:param name="nodes" />
    <div class="cfdi-table-wrap">
      <table class="cfdi-table cfdi-small-table">
        <thead>
          <tr>
            <th>Base</th>
            <th>Impuesto</th>
            <th>Tipo factor</th>
            <th>Tasa o cuota</th>
            <th>Importe</th>
          </tr>
        </thead>
        <tbody>
          <xsl:for-each select="$nodes">
            <tr>
              <td class="cfdi-money">
                <xsl:call-template name="cfdi-pagos20-optional-money">
                  <xsl:with-param name="value" select="@BaseDR | @BaseP" />
                </xsl:call-template>
              </td>
              <td>
                <xsl:apply-templates select="@ImpuestoDR | @ImpuestoP" mode="cfdi:payment-label" />
              </td>
              <td>
                <xsl:value-of select="@TipoFactorDR | @TipoFactorP" />
              </td>
              <td class="cfdi-number">
                <xsl:call-template name="cfdi-rate">
                  <xsl:with-param name="value" select="@TasaOCuotaDR | @TasaOCuotaP" />
                </xsl:call-template>
              </td>
              <td class="cfdi-money">
                <xsl:call-template name="cfdi-pagos20-optional-money">
                  <xsl:with-param name="value" select="@ImporteDR | @ImporteP" />
                </xsl:call-template>
              </td>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
    </div>
  </xsl:template>
  <xsl:template name="cfdi-pagos20-optional-money">
    <xsl:param name="value" />
    <xsl:choose>
      <xsl:when test="string($value) != ''">
        <xsl:call-template name="cfdi-money">
          <xsl:with-param name="value" select="$value" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>&#8212;</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="@FormaDePagoP" mode="cfdi:payment-label">
    <xsl:value-of select="." />
    <xsl:choose>
      <xsl:when test=".='01'"> - Efectivo</xsl:when>
      <xsl:when test=".='02'"> - Cheque nominativo</xsl:when>
      <xsl:when test=".='03'"> - Transferencia electrónica de fondos</xsl:when>
      <xsl:when test=".='04'"> - Tarjeta de crédito</xsl:when>
      <xsl:when test=".='28'"> - Tarjeta de débito</xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="@MonedaP | @MonedaDR" mode="cfdi:payment-label">
    <xsl:value-of select="." />
    <xsl:choose>
      <xsl:when test=".='MXN'"> - Peso mexicano</xsl:when>
      <xsl:when test=".='USD'"> - Dólar estadounidense</xsl:when>
      <xsl:when test=".='EUR'"> - Euro</xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="@ObjetoImpDR" mode="cfdi:payment-label">
    <xsl:value-of select="." />
    <xsl:choose>
      <xsl:when test=".='01'"> - No objeto de impuesto</xsl:when>
      <xsl:when test=".='02'"> - Sí objeto de impuesto</xsl:when>
      <xsl:when test=".='03'"> - Sí objeto del impuesto y no obligado al desglose</xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="@ImpuestoDR | @ImpuestoP" mode="cfdi:payment-label">
    <xsl:value-of select="." />
    <xsl:choose>
      <xsl:when test=".='001'"> - ISR</xsl:when>
      <xsl:when test=".='002'"> - IVA</xsl:when>
      <xsl:when test=".='003'"> - IEPS</xsl:when>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>