<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns="http://www.w3.org/1999/xhtml"
xmlns:session="http://panax.io/session"
xmlns:data="http://panax.io/data"
xmlns:state="http://panax.io/state"
xmlns:group="http://panax.io/state/group"
xmlns:filter="http://panax.io/state/filter"
xmlns:visible="http://panax.io/state/visible"
xmlns:dummy="http://panax.io/dummy"
xmlns:env="http://panax.io/state/environment"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:datagrid="http://panaxbi.com/widget/datagrid"
xmlns:xo="http://panax.io/xover"
>
	<xsl:import href="../functions.xslt"/>
	<xsl:key name="state:hidden" match="@*[namespace-uri()!='']" use="name()"/>
	<xsl:key name="state:collapsed" match="*[@state:collapsed]" use="@key"/>

	<xsl:key name="state:hidden" match="@xo:*" use="."/>
	<xsl:key name="state:hidden" match="@state:*" use="."/>
	<xsl:key name="state:hidden" match="@xsi:*" use="."/>

	<xsl:key name="data:filter" match="@filter:*" use="local-name()"/>
	<xsl:key name="data_type" match="node-expected/@*" use="'type'"/>

	<xsl:key name="facts" match="node-expected" use="name()"/>
	<xsl:key name="data" match="node-expected" use="concat(generate-id(),'::',name())"/>
	<xsl:key name="data" match="/model/*[not(row)]/@state:record_count" use="'*'"/>

	<xsl:key name="data:group" match="node-expected/@key" use="name(../..)"/>
	<xsl:key name="data:group" match="node-expected" use="'*'"/>

	<xsl:key name="data:group" match="*[row]/@group:*" use="'*'"/>
	<xsl:key name="data:group" match="*[row]/@group:*" use="name()"/>
	<xsl:key name="data:group" match="group:*/row/@desc" use="name(../..)"/>

	<xsl:key name="data:group" match="/model/*[not(row)]/@state:record_count" use="'*'"/>

	<xsl:key name="x-dimension" match="node-expected/@*[namespace-uri()='']" use="name(..)"/>
	<xsl:key name="y-dimension" match="node-expected/*" use="name(..)"/>

	<xsl:param name="state:groupBy">*</xsl:param>

	<xsl:template mode="datagrid:widget" match="*|@*">
		<xsl:param name="x-dimensions" select="(@*[namespace-uri()='']|@*[namespace-uri()='http://panax.io/state/group'])[not(key('data:group', concat('group:',name())))]"/>
		<xsl:param name="y-dimensions" select="key('y-dimension', name(ancestor-or-self::*[1]))"/>
		<xsl:param name="groups" select="key('data:group',$state:groupBy)"/>
		<xsl:variable name="data" select="key('data',node)"/>
		<style>
			<![CDATA[
        table td.freeze {
          background-color: white;
        }

        table thead.freeze > tr td, table thead.freeze > tr th {
          position: sticky;
        }

        table > thead.freeze > tr:nth-child(1) > td, table > thead.freeze > tr:nth-child(1) > th {
          top: 0px;
        }

        table > thead.freeze > tr:nth-child(2) > td, table > thead.freeze > tr:nth-child(2) > th {
          top: 20px;
        }

        table > thead.freeze > tr:nth-child(3) > td, table > thead.freeze > tr:nth-child(3) > th {
          top: 40px;
        }

        table > thead.freeze > tr:nth-child(4) > td, table > thead.freeze > tr:nth-child(4) > th {
          top: 60px;
        }

        table > thead.freeze > tr:nth-child(5) > td, table > thead.freeze > tr:nth-child(5) > th {
          top: 80px;
        }

        table tr.freeze td.freeze, table tr.freeze th.freeze {
          z-index: 911;
        }

        table tr.freeze td.freeze img, table tr.freeze th.freeze img {
          z-index: 912;
        }

        table thead.freeze tr {
          background-color: white;
        }
		
		.datagrid tr.header th {
			background-color: var(--datagrid-tr-header-bg, silver);
			color:  var(--datagrid-tr-header-color, white);
		}
		
		.sticky {
			position: sticky;
			top: var(--sticky-top, 45px);
			background-color: var(--sticky-bg-color, white);
		}
		
		.sticky.header-level-2 {
			top: calc(var(--sticky-top, 45px)* 2);
		}
		
		.sticky.header-level-3 {
			top: calc(var(--sticky-top, 45px)* 3);
		}
		
		.sticky.header-level-4 {
			top: calc(var(--sticky-top, 45px)* 4);
		}
		
		.sticky.header-level-5 {
			top: calc(var(--sticky-top, 45px)* 5);
		}
		
		.header-level-2 th {
			background-color: var(--datagrid-tr-header-bg-level-2, silver) !important;
		}
		
		.header-level-3 th {
			background-color: var(--datagrid-tr-header-bg-level-3, silver) !important;
		}
		
		.header-level-4 th {
			background-color: var(--datagrid-tr-header-bg-level-4, silver) !important;
		}
		
		.header-level-5 th {
			background-color: var(--datagrid-tr-header-bg-level-5, silver) !important;
		}
		
		div:has(>table) {
			width: fit-content;
		}
			
		table {
			margin-right: 50px;
			max-width: max-content;
		}
			]]>
		</style>
		<style>
			<![CDATA[
				table tbody td span.filterable { cursor: pointer }
				table tbody td span.groupable { cursor: pointer }

				table .sortable { cursor: pointer }
				table .groupable { cursor: pointer }
				
				table thead {
					text-wrap: nowrap;
				}
				
				table tfoot .money
				, table tbody .money
				, table tbody .number
				, table tfoot .number
				{
					text-align: end;
				}
				
				td[xo-slot=amt],td[xo-slot=qtym],td[xo-slot=qtys],td[xo-slot=qty_rcv],td[xo-slot=trb],td[xo-slot=upce] {
					text-align: end;
				}
				
				tfoot {
					font-weight: bolder;
				}
				
				:root {
					--sticky-top: 34px;
				}
				
				.datagrid a {
					text-decoration: none;
					color: inherit;
					cursor: pointer;
				}
				
				tbody .header th[scope="row"] {
					text-align: right;
				}
				
				.arrow {
					width: 0;
					height: 0;
					border-left: 5px solid transparent;
					border-right: 5px solid transparent;
					border-top: 10px solid red;
					display: none;
					position: absolute;
				}
			]]>
		</style>
		<script src="datagrid.js" fetchpriority="high"/>
		<table class="table table-striped selection-enabled datagrid">
			<xsl:apply-templates mode="datagrid:colgroup" select=".">
				<xsl:with-param name="x-dimension" select="$x-dimensions"/>
			</xsl:apply-templates>
			<thead class="freeze">
				<xsl:apply-templates mode="datagrid:header-row" select=".">
					<xsl:with-param name="x-dimension" select="$x-dimensions"/>
					<xsl:with-param name="groups" select="$groups"/>
				</xsl:apply-templates>
			</thead>
			<xsl:apply-templates mode="datagrid:tbody" select="$groups[1]">
				<xsl:with-param name="x-dimension" select="$x-dimensions"/>
				<xsl:with-param name="y-dimension" select="$y-dimensions"/>
			</xsl:apply-templates>
			<tfoot>
				<xsl:apply-templates mode="datagrid:footer-row" select=".">
					<xsl:with-param name="x-dimension" select="$x-dimensions"/>
					<xsl:with-param name="groups" select="$groups"/>
				</xsl:apply-templates>
			</tfoot>
		</table>
	</xsl:template>

	<xsl:template mode="datagrid:tbody" match="*|@*">
		<xsl:param name="dimensions" select="."/>
		<xsl:param name="x-dimension" select="node-expected"/>
		<xsl:param name="y-dimension" select="node-expected"/>
		<xsl:param name="groups" select="ancestor-or-self::*[1]/@group:*"/>
		<xsl:param name="parent-groups" select="dummy:node-expected"/>

		<xsl:variable name="key">
			<xsl:choose>
				<xsl:when test="self::*">*</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="current" select="current()"/>
		<xsl:variable name="rows" select="$y-dimension[self::*]|self::*[not(*)]/@state:record_count|$y-dimension[not(self::*)][.=$current]/.."/>
		<xsl:if test="self::* or not(self::*) and $rows">
			<tbody class="table-group-divider">
				<xsl:apply-templates mode="datagrid:tbody-header" select=".">
					<xsl:with-param name="x-dimension" select="$x-dimension"/>
					<xsl:with-param name="rows" select="$rows"/>
					<xsl:with-param name="groups" select="$groups"/>
					<xsl:with-param name="parent-groups" select="$parent-groups"/>
				</xsl:apply-templates>
				<xsl:choose>
					<xsl:when test="$groups">
						<xsl:apply-templates mode="datagrid:tbody" select="$groups[1]">
							<xsl:with-param name="x-dimension" select="$x-dimension"/>
							<xsl:with-param name="y-dimension" select="$rows"/>
							<xsl:with-param name="groups" select="$groups"/>
							<xsl:with-param name="parent-groups" select="$parent-groups|."/>
						</xsl:apply-templates>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates mode="datagrid:row" select="$rows">
							<xsl:with-param name="x-dimension" select="$x-dimension"/>
							<xsl:with-param name="parent-groups" select="$parent-groups|."/>
						</xsl:apply-templates>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:apply-templates mode="datagrid:tbody-footer" select=".">
					<xsl:with-param name="x-dimension" select="$x-dimension"/>
					<xsl:with-param name="rows" select="$rows"/>
					<xsl:with-param name="groups" select="$groups"/>
					<xsl:with-param name="parent-groups" select="$parent-groups"/>
				</xsl:apply-templates>
			</tbody>
		</xsl:if>
	</xsl:template>

	<xsl:template mode="datagrid:tbody" match="@group:*">
		<xsl:param name="dimensions" select="."/>
		<xsl:param name="x-dimension" select="node-expected"/>
		<xsl:param name="y-dimension" select="node-expected"/>
		<xsl:param name="groups" select="ancestor-or-self::*[1]/@group:*"/>
		<xsl:param name="parent-groups" select="dummy:node-expected"/>

		<xsl:comment>debug:info</xsl:comment>
		<xsl:variable name="group" select="key('data:group',name())"/>
		<xsl:variable name="rows" select="$y-dimension/@*[name()=local-name(current())]"/>
		<!--$y-dimension/@*[name()=local-name(current())]-->
		<xsl:apply-templates mode="datagrid:tbody" select="$group[$rows]">
			<xsl:sort select="." data-type="text"/>
			<xsl:with-param name="x-dimension" select="$x-dimension"/>
			<xsl:with-param name="y-dimension" select="$rows"/>
			<xsl:with-param name="groups" select="$groups[not(position()=1)]"/>
			<xsl:with-param name="parent-groups" select="$parent-groups"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template mode="datagrid:tbody" match="@state:record_count">
		<tr>
			<td colspan="100" style="text-align: left; padding-inline: 5rem;">
				<button class="btn btn-success text-nowrap" onclick="mostrarRegistros.call(this)" style="max-height: 38px; align-self: end;">
					Mostrar los <xsl:value-of select="."/> resultados
				</button>
			</td>
		</tr>
	</xsl:template>

	<xsl:template mode="datagrid:tbody" match="@state:record_count[.=0]">
		<tr>
			<td colspan="100" style="text-align: left; padding-inline: 5rem;">
				<h5 class="text-danger">
					No se encontraron resultados para su consulta
				</h5>
			</td>
		</tr>
	</xsl:template>

	<xsl:template mode="datagrid:tbody-header" match="*|@*"/>
	<xsl:template mode="datagrid:tbody-footer" match="*|@*"/>

	<xsl:template mode="datagrid:colgroup" match="*">
		<xsl:param name="x-dimension" select="@*[not(key('state:hidden',name()))]"/>
		<colgroup>
			<col width="50"/>
			<xsl:apply-templates mode="datagrid:colgroup-col" select="$x-dimension"/>
		</colgroup>
	</xsl:template>

	<xsl:template mode="datagrid:colgroup-col" match="@*">
		<xsl:comment>
			<xsl:value-of select="name()"/>
		</xsl:comment>
		<col width="100"/>
	</xsl:template>

	<xsl:template mode="datagrid:colgroup-col" match="key('data_type','description')">
		<xsl:comment>
			<xsl:value-of select="name()"/>
		</xsl:comment>
		<col width="280"/>
	</xsl:template>

	<xsl:template mode="datagrid:row" match="*">
		<xsl:param name="x-dimension" select="@*[not(key('state:hidden',name()))]"/>
		<xsl:param name="parent-groups" select="node-expected"/>
		<tr>
			<th scope="row">
				<xsl:value-of select="position()"/>
			</th>
			<xsl:apply-templates mode="datagrid:cell" select="$x-dimension">
				<xsl:sort select="namespace-uri()" order="descending"/>
				<xsl:with-param name="row" select="."/>
			</xsl:apply-templates>
		</tr>
	</xsl:template>

	<xsl:template mode="datagrid:row" match="@*">
		<xsl:param name="x-dimension" select="node-expected"/>
		<xsl:param name="y-dimension" select="node-expected"/>
		<xsl:param name="parent-groups" select="node-expected"/>
		<xsl:comment>debug:info</xsl:comment>
		<xsl:apply-templates mode="datagrid:row" select="parent::*">
			<xsl:with-param name="x-dimension" select="$x-dimension"/>
			<xsl:with-param name="y-dimension" select="$y-dimension"/>
			<xsl:with-param name="parent-groups" select="$parent-groups"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template mode="datagrid:row" match="row[key('state:collapsed', @Account)]"/>

	<xsl:template mode="datagrid:header-row" match="*">
		<xsl:param name="x-dimension" select="node-expected"/>
		<tr>
			<th scope="col">
				#
			</th>
			<xsl:apply-templates mode="datagrid:header-cell" select="$x-dimension">
				<xsl:sort select="namespace-uri()" order="descending"/>
			</xsl:apply-templates>
		</tr>
	</xsl:template>

	<xsl:template mode="datagrid:footer-row" match="*">
		<xsl:param name="x-dimension" select="node-expected"/>
		<tr>
			<th></th>
			<xsl:apply-templates mode="datagrid:footer-cell" select="$x-dimension"/>
		</tr>
	</xsl:template>

	<xsl:template mode="datagrid:cell-class-by-type" match="key('data_type', 'number')">
		<xsl:text/> number<xsl:text/>
	</xsl:template>

	<xsl:template mode="datagrid:cell-class-by-type" match="key('data_type', 'money')">
		<xsl:text/> money number<xsl:text/>
	</xsl:template>

	<xsl:template mode="datagrid:cell-class-by-type" match="key('data_type', 'percent')">
		<xsl:text/> percent number<xsl:text/>
	</xsl:template>

	<xsl:template mode="datagrid:cell-class-by-type" match="key('data_type', 'integer')">
		<xsl:text/> integer number<xsl:text/>
	</xsl:template>

	<xsl:template mode="datagrid:cell" match="@*">
		<xsl:param name="row" select="ancestor-or-self::*[1]"/>
		<xsl:variable name="cell" select="$row/@*[name()=local-name(current())]"/>
		<xsl:variable name="text-filter">
			<xsl:if test="key('data:filter',local-name())">bg-info</xsl:if>
		</xsl:variable>
		<xsl:variable name="classes">
			<xsl:apply-templates mode="datagrid:cell-class" select="."/>
			<xsl:apply-templates mode="datagrid:cell-class-by-type" select="."/>
		</xsl:variable>
		<td xo-scope="inherit" xo-slot="{local-name()}" class="text-nowrap {$text-filter} {$classes} cell domain-{local-name()}">
			<xsl:apply-templates mode="datagrid:cell-content" select="$cell"/>
		</td>
	</xsl:template>

	<xsl:template mode="datagrid:cell-content" match="@*">
		<span class="filterable">
			<xsl:apply-templates select="."/>
		</span>
	</xsl:template>

	<xsl:template mode="datagrid:header-cell" match="@*">
		<xsl:variable name="classes">
			<xsl:apply-templates mode="datagrid:header-cell-classes" select="."/>
		</xsl:variable>
		<th scope="col" draggable="true" class="drag-group-headers drag-group-dim">
			<div class="d-flex flex-nowrap">
				<xsl:apply-templates mode="datagrid:header-cell-options" select="."/>
				<label class="{$classes}">
					<xsl:apply-templates mode="datagrid:header-cell-content" select="."/>
				</label>
				<xsl:apply-templates mode="datagrid:header-cell-icons" select="."/>
			</div>
		</th>
	</xsl:template>

	<xsl:template mode="datagrid:header-cell-options" match="@*">
		<div class="dropdown">
			<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-caret-down-square dropdown-toggle" data-bs-toggle="dropdown" viewBox="0 0 16 16">
				<path d="M3.626 6.832A.5.5 0 0 1 4 6h8a.5.5 0 0 1 .374.832l-4 4.5a.5.5 0 0 1-.748 0z"/>
				<path d="M0 2a2 2 0 0 1 2-2h12a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2zm15 0a1 1 0 0 0-1-1H2a1 1 0 0 0-1 1v12a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1z"/>
			</svg>
			<ul class="dropdown-menu">
				<li>
					<a class="dropdown-item" href="#">Action</a>
				</li>
				<li>
					<a class="dropdown-item" href="#">Another action</a>
				</li>
				<li>
					<a class="dropdown-item" href="#">Something else here</a>
				</li>
			</ul>
		</div>
	</xsl:template>

	<xsl:template mode="datagrid:headerText" match="@*">
		<xsl:apply-templates mode="headerText" select="."/>
	</xsl:template>

	<xsl:template mode="datagrid:headerText" match="@group:*">
		<xsl:apply-templates mode="headerText" select="../@*[name()=local-name(current())]"/>
	</xsl:template>

	<xsl:template mode="datagrid:header-cell-options" match="@*">
	</xsl:template>

	<xsl:template mode="datagrid:header-cell-content" match="@*">
		<xsl:apply-templates mode="datagrid:headerText" select="."/>
	</xsl:template>

	<xsl:template mode="datagrid:header-cell-classes" match="@*">
		<xsl:text/>sortable<xsl:text/>
	</xsl:template>

	<xsl:template mode="datagrid:header-cell-icons" match="@*">
	</xsl:template>

	<xsl:template mode="datagrid:header-cell-icons" match="@group:*">
		<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-stack ms-2 button" viewBox="0 0 16 16" onclick="dispatch('ungroup')">
			<path d="m14.12 10.163 1.715.858c.22.11.22.424 0 .534L8.267 15.34a.6.6 0 0 1-.534 0L.165 11.555a.299.299 0 0 1 0-.534l1.716-.858 5.317 2.659c.505.252 1.1.252 1.604 0l5.317-2.66zM7.733.063a.6.6 0 0 1 .534 0l7.568 3.784a.3.3 0 0 1 0 .535L8.267 8.165a.6.6 0 0 1-.534 0L.165 4.382a.299.299 0 0 1 0-.535z"></path>
			<path d="m14.12 6.576 1.715.858c.22.11.22.424 0 .534l-7.568 3.784a.6.6 0 0 1-.534 0L.165 7.968a.299.299 0 0 1 0-.534l1.716-.858 5.317 2.659c.505.252 1.1.252 1.604 0z"></path>
		</svg>
	</xsl:template>

	<xsl:template mode="datagrid:footer-cell" match="@*" priority="-1">
		<td>
			<xsl:comment>
				<xsl:value-of select="name()"/>
			</xsl:comment>
		</td>
	</xsl:template>

	<xsl:template mode="datagrid:footer-cell" match="key('data_type', 'number')">
		<td class="number">
			<xsl:call-template name="format">
				<xsl:with-param name="value">
					<xsl:apply-templates mode="datagrid:aggregate" select="."/>
				</xsl:with-param>
				<xsl:with-param name="mask">###,##0.00;-###,##0.00</xsl:with-param>
			</xsl:call-template>
		</td>
	</xsl:template>

	<xsl:template mode="datagrid:footer-cell" match="key('data_type', 'integer')">
		<td>
			<xsl:call-template name="format">
				<xsl:with-param name="value">
					<xsl:apply-templates mode="datagrid:aggregate" select="."/>
				</xsl:with-param>
				<xsl:with-param name="mask">###,##0;-###,##0</xsl:with-param>
			</xsl:call-template>
		</td>
	</xsl:template>

	<xsl:template mode="datagrid:footer-cell" match="key('data_type', 'money')">
		<td class="money">
			<xsl:call-template name="format">
				<xsl:with-param name="value">
					<xsl:apply-templates mode="datagrid:aggregate" select="."/>
				</xsl:with-param>
				<xsl:with-param name="mask">$###,##0.00;-$###,##0.00</xsl:with-param>
			</xsl:call-template>
		</td>
	</xsl:template>

	<xsl:template mode="datagrid:aggregate" match="@*">
		<xsl:value-of select="count(key('facts',name()))"/>
	</xsl:template>

	<xsl:template mode="datagrid:aggregate" match="key('data_type', 'money')|key('data_type', 'integer')|key('data_type', 'number')">
		<xsl:value-of select="sum(key('facts',name()))"/>
	</xsl:template>

	<xsl:template mode="datagrid:footer-cell" match="key('data_type', 'avg')">
		<td>
			<xsl:call-template name="format">
				<xsl:with-param name="value" select="sum(key('facts',name()))"/>
				<xsl:with-param name="mask">$###,##0.00;-$###,##0.00</xsl:with-param>
			</xsl:call-template>
		</td>
	</xsl:template>

	<xsl:template match="@*[starts-with(.,'*')]">
		<xsl:value-of select="substring-after(.,'*')"/>
	</xsl:template>

	<xsl:key name="datagrid:group" use="'collapsed'" match="row[@state:collapsed='true']/@*" />

	<xsl:template mode="datagrid:group-buttons" match="@*">
		<!--<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-dash-square" viewBox="0 0 16 16" style="cursor:pointer;" xo-slot="state:collapsed" onclick="scope.toggle('true')">
			<path d="M14 1a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1h12zM2 0a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V2a2 2 0 0 0-2-2H2z"></path>
			<path d="M4 8a.5.5 0 0 1 .5-.5h7a.5.5 0 0 1 0 1h-7A.5.5 0 0 1 4 8z"></path>
		</svg>-->
	</xsl:template>

	<xsl:template mode="datagrid:group-buttons" match="row[@state:collapsed='true']/@*" priority="1">
		<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-plus-square" viewBox="0 0 16 16" style="cursor:pointer;" xo-slot="state:collapsed" onclick="scope.remove()">
			<path d="M14 1a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1h12zM2 0a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V2a2 2 0 0 0-2-2H2z"></path>
			<path d="M8 4a.5.5 0 0 1 .5.5v3h3a.5.5 0 0 1 0 1h-3v3a.5.5 0 0 1-1 0v-3h-3a.5.5 0 0 1 0-1h3v-3A.5.5 0 0 1 8 4z"></path>
		</svg>
	</xsl:template>

	<xsl:template mode="datagrid:tbody-header" match="@*">
	</xsl:template>

	<xsl:template mode="datagrid:tbody-header" match="@*">
		<xsl:param name="dimensions" select="."/>
		<xsl:param name="x-dimension" select="node-expected"/>
		<xsl:param name="y-dimension" select="node-expected"/>
		<xsl:param name="groups" select="node-expected"/>
		<xsl:param name="parent-groups" select="node-expected"/>
		<xsl:param name="rows" select="key('data',.)"/>
		<tr class="header sticky header-level-{count($parent-groups) + 1}">
			<th scope="row" colspan="{count($parent-groups) + 1}">
				<xsl:apply-templates mode="datagrid:group-buttons" select="."/>
			</th>
			<th style="white-space: nowrap;" colspan="{count($groups) + 1}">
				<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-stack ms-2 button" viewBox="0 0 16 16" onclick="dispatch('ungroup')">
					<path d="m14.12 10.163 1.715.858c.22.11.22.424 0 .534L8.267 15.34a.6.6 0 0 1-.534 0L.165 11.555a.299.299 0 0 1 0-.534l1.716-.858 5.317 2.659c.505.252 1.1.252 1.604 0l5.317-2.66zM7.733.063a.6.6 0 0 1 .534 0l7.568 3.784a.3.3 0 0 1 0 .535L8.267 8.165a.6.6 0 0 1-.534 0L.165 4.382a.299.299 0 0 1 0-.535z"/>
					<path d="m14.12 6.576 1.715.858c.22.11.22.424 0 .534l-7.568 3.784a.6.6 0 0 1-.534 0L.165 7.968a.299.299 0 0 1 0-.534l1.716-.858 5.317 2.659c.505.252 1.1.252 1.604 0z"/>
				</svg>
				<strong>
					<xsl:apply-templates select="../@desc"/>
				</strong>
			</th>
			<!--<xsl:apply-templates mode="datagrid:header-cell" select="$x-dimension[not(key('data:group',concat('group:',name())))]">
				
			
			</xsl:apply-templates>-->
			<xsl:apply-templates mode="datagrid:tbody-header-cell" select="$x-dimension[namespace-uri()='']">
				<xsl:with-param name="rows" select="$rows"/>
			</xsl:apply-templates>
			<!--<th colspan="{count($x-dimension)-2}">
			</th>-->
			<!--<th class="money">
				<strong>
					<xsl:variable name="last_field" select="name($x-dimension[last()])"/>
					<xsl:call-template name="format">
						<xsl:with-param name="value" select="sum($rows/@*[name()=$last_field][.!=''])"/>
					</xsl:call-template>
				</strong>
			</th>-->
		</tr>
	</xsl:template>

	<xsl:template mode="datagrid:tbody-header-cell" match="@*">
		<th></th>
	</xsl:template>

	<xsl:template mode="datagrid:tbody-header-cell" match="key('data_type', 'money')">
		<xsl:param name="rows" select="node-expected"/>
		<xsl:variable name="field" select="current()"/>
		<th class="money">
			<xsl:call-template name="format">
				<xsl:with-param name="value" select="sum($rows/@*[name()=name($field)])"/>
			</xsl:call-template>
		</th>
	</xsl:template>

	<xsl:template mode="datagrid:tbody-header-cell" match="key('data_type', 'number')">
		<xsl:param name="rows" select="node-expected"/>
		<xsl:variable name="field" select="current()"/>
		<th class="money">
			<xsl:call-template name="format">
				<xsl:with-param name="value" select="sum($rows/@*[name()=name($field)])"/>
				<xsl:with-param name="mask">###,##0.00;-###,##0.00</xsl:with-param>
			</xsl:call-template>
		</th>
	</xsl:template>

	<xsl:template mode="datagrid:tbody-header-cell" match="key('data_type', 'integer')">
		<xsl:param name="rows" select="node-expected"/>
		<xsl:variable name="field" select="current()"/>
		<th class="money">
			<xsl:call-template name="format">
				<xsl:with-param name="value" select="sum($rows/@*[name()=name($field)])"/>
				<xsl:with-param name="mask">###,##0;-###,##0</xsl:with-param>
			</xsl:call-template>
		</th>
	</xsl:template>

	<!--<xsl:template mode="datagrid:tbody-header-cell" match="key('data_type', 'money')">
		<xsl:param name="rows" select="node-expected"/>
		<xsl:variable name="field" select="current()"/>
		<th class="money">
			<xsl:call-template name="format">
				<xsl:with-param name="value" select="sum($rows/@*[name()=name($field)])"/>
			</xsl:call-template>
		</th>
	</xsl:template>

	<xsl:template mode="datagrid:tbody-header-cell" match="@*" priority="-1">
		<th>
			<xsl:comment>
				<xsl:value-of select="name()"/>
			</xsl:comment>
		</th>
	</xsl:template>

	<xsl:template mode="datagrid:tbody-header-cell" match="key('data_type', 'number')">
		<th class="number">
			<xsl:call-template name="format">
				<xsl:with-param name="value">
					<xsl:apply-templates mode="datagrid:aggregate" select="."/>
				</xsl:with-param>
				<xsl:with-param name="mask">###,##0.00;-###,##0.00</xsl:with-param>
			</xsl:call-template>
		</th>
	</xsl:template>

	<xsl:template mode="datagrid:tbody-header-cell" match="key('data_type', 'integer')">
		<th>
			<xsl:call-template name="format">
				<xsl:with-param name="value">
					<xsl:apply-templates mode="datagrid:aggregate" select="."/>
				</xsl:with-param>
				<xsl:with-param name="mask">###,##0;-###,##0</xsl:with-param>
			</xsl:call-template>
		</th>
	</xsl:template>

	<xsl:template mode="datagrid:tbody-header-cell" match="key('data_type', 'money')">
		<th class="money">
			<xsl:call-template name="format">
				<xsl:with-param name="value">
					<xsl:apply-templates mode="datagrid:aggregate" select="."/>
				</xsl:with-param>
				<xsl:with-param name="mask">$###,##0.00;-$###,##0.00</xsl:with-param>
			</xsl:call-template>
		</th>
	</xsl:template>

	<xsl:template mode="datagrid:tbody-header-cell" match="key('data_type', 'number')">
		<xsl:param name="rows" select="node-expected"/>
		<xsl:variable name="field" select="current()"/>
		<th class="money">
			<xsl:call-template name="format">
				<xsl:with-param name="value" select="sum($rows/@*[name()=name($field)])"/>
			</xsl:call-template>
		</th>
	</xsl:template>-->
</xsl:stylesheet>