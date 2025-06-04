<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns="http://www.w3.org/1999/xhtml"
xmlns:session="http://panax.io/session"
xmlns:data="http://panax.io/data"
xmlns:state="http://panax.io/state"
xmlns:group="http://panax.io/state/group"
xmlns:page="http://panax.io/state/page"
xmlns:hidden="http://panax.io/state/hidden"
xmlns:collapse="http://panax.io/state/collapse"
xmlns:expand="http://panax.io/state/expand"
xmlns:filter="http://panax.io/state/filter"
xmlns:visible="http://panax.io/state/visible"
xmlns:datatype="http://panax.io/datatype"
xmlns:total="http://panax.io/total"
xmlns:dummy="http://panax.io/dummy"
xmlns:env="http://panax.io/state/environment"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xmlns:datagrid="http://widgets.panaxbi.com/datagrid"
xmlns:xo="http://panax.io/xover"
xmlns:debug="http://panax.io/debug"
>
	<xsl:import href="../functions.xslt"/>
	<xsl:import href="../common.xslt"/>
	<xsl:key name="state" match="node-expected" use="'hidden'"/>

	<xsl:key name="state:hidden" match="@*[namespace-uri()!='' and namespace-uri()!='http://panax.io/state/group']" use="name()"/>
	<xsl:key name="state:collapsed" match="*[@state:collapsed]" use="@key"/>

	<xsl:key name="state:hidden" match="@xo:*" use="."/>
	<xsl:key name="state:hidden" match="@state:*" use="."/>
	<xsl:key name="state:hidden" match="@xsi:*" use="."/>
	<xsl:key name="state:hidden" match="@hidden:*[not(.='false')]" use="local-name()"/>

	<xsl:key name="data:filter" match="@filter:*" use="local-name()"/>
	<xsl:key name="data_type" match="node-expected/@*" use="'type'"/>

	<xsl:key name="facts" match="node-expected" use="name()"/>
	<xsl:key name="data" match="node-expected" use="concat(generate-id(),'::',name())"/>
	<xsl:key name="data" match="/model/*[not(row)]/@state:record_count" use="'*'"/>

	<xsl:key name="data:group" match="*[row]/@group:*" use="'*'"/>
	<xsl:key name="data:group" match="group:*/row/@desc" use="name(../..)"/>
	<xsl:key name="data:group" match="/model/*[not(row)]/@state:record_count" use="'*'"/>

	<xsl:key name="datagrid:caption" match="@dummy" use="../@xo:id"/>

	<xsl:key name="x-dimension" match="node-expected/@*[namespace-uri()='']" use="name(..)"/>
	<xsl:key name="y-dimension" match="node-expected/*" use="name(..)"/>

	<xsl:key name="datatype" match="*/@datatype:*" use="concat(.,':',local-name())"/>

	<xsl:param name="state:groupBy">*</xsl:param>
	<xsl:param name="state:collapse_all"></xsl:param>
	<xsl:param name="state:hide_empty">false</xsl:param>
	<xsl:param name="state:hide_suggested">false</xsl:param>

	<xsl:key name="collapse:group" match="collapse:groups/row/@*[namespace-uri()='']" use="concat(name(),'::',.)"/>
	<xsl:key name="expand:group" match="expand:groups/row/@*[namespace-uri()='']" use="concat(name(),'::',.)"/>

	<xsl:template mode="datagrid:widget" match="*|@*">
		<xsl:param name="x-dimensions" select="@*[namespace-uri()=''][not(key('data:group', concat('group:',name())))]|@*[namespace-uri()='http://panax.io/state/group']"/>
		<xsl:param name="y-dimensions" select="key('y-dimension', name(ancestor-or-self::*[1]))"/>
		<xsl:param name="groups" select="key('data:group',$state:groupBy)"/>
		<style>
			<![CDATA[
		table .dropdown-item.active, .dropdown-item:active { background-color: white; }
		
		table colgroup col.hidden {
			width: 0 !important;
			visibility: collapse;
			display: table-column;
		}
		
        table td.freeze {
          background-color: white;
        }

        table thead.freeze > tr td, table thead.freeze > tr th {
          position: sticky;
        }
		
		table > thead th {
			vertical-align: middle;
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
			top: var(--sticky-group-height, 40px);
			background-color: var(--sticky-bg-color, white);
			height: var(--sticky-group-height, 40px);
		}
		
		.sticky.group-level-1 {
			top: calc(var(--sticky-headers-height, 46px) + var(--sticky-group-height, 40px)* 0);
		}
		
		.sticky.group-level-2 {
			top: calc(var(--sticky-headers-height, 46px) + var(--sticky-group-height, 40px)* 1);
		}
		
		.sticky.group-level-3 {
			top: calc(var(--sticky-headers-height, 46px) + var(--sticky-group-height, 40px)* 2);
		}
		
		.sticky.group-level-4 {
			top: calc(var(--sticky-headers-height, 46px) + var(--sticky-group-height, 40px)* 3);
		}
		
		.sticky.group-level-5 {
			top: calc(var(--sticky-headers-height, 46px) + var(--sticky-group-height, 40px)* 4);
		}
		
		.group-level-2 th {
			background-color: var(--datagrid-tr-header-bg-level-2, silver) !important;
		}
		
		.group-level-3 th {
			background-color: var(--datagrid-tr-header-bg-level-3, silver) !important;
		}
		
		.group-level-4 th {
			background-color: var(--datagrid-tr-header-bg-level-4, silver) !important;
		}
		
		.group-level-5 th {
			background-color: var(--datagrid-tr-header-bg-level-5, silver) !important;
		}
		
		div:has(>table) {
			width: fit-content;
		}
			
		table {
			margin-right: 50px;
			max-width: max-content;
		}]]>
		</style>
		<style>
			<![CDATA[
				table .dropdown-menu { box-shadow: 5px 7px 5px 0px rgba(0, 0, 0, 0.2); }
				table .dropdown-item.active, .dropdown-item:active { background-color: white; }
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
					--sticky-headers-height: 46px;
					--sticky-group-height: 40px;
				}
				
				.datagrid a {
					text-decoration: none;
					color: inherit;
					cursor: pointer;
				}
				
				/*tbody .header th[scope="row"] {
					text-align: right;
				}*/
				
				.arrow {
					width: 0;
					height: 0;
					border-left: 5px solid transparent;
					border-right: 5px solid transparent;
					border-top: 10px solid red;
					display: none;
					position: absolute;
					z-index: 1019;
				}
				
				.icon-btn {
					margin-right: 1rem;
				}
				
				th:has(tab-space) {
					padding: 0 !important;
				}
				
				tab-space {		
					position: relative;
					height: 40px;
					display: block;
				}

				tab-space:before {
					background: var(--group-child-indicator, cornsilk);
					bottom: auto;
					content: "";
					height: 8px;
					left: 23px;
					margin-top: 17px;
					position: absolute;
					right: auto;
					width: 8px;
					z-index: 1;
					border-radius: 50%;
				}

				tab-space:after {
					border-left: 1px solid var(--group-child-indicator, cornsilk);
					bottom: 0;
					content: "";
					left: 27px;
					position: absolute;
					top: 0;
				}
				
				tbody, td, tfoot, th, thead, tr {
					border-style: initial !important;
				}
				
				table.datagrid > caption {
				  caption-side: top;
				  text-align: start;
				  padding: 10px;
				  font-weight: bold;
				}
				
				:root {
					--progress-color: #3498db; /* Default progress color */
				}

				main.xo-loading::before {
					content: "";
					display: block;
					width: 100%;
					height: 2px; /* Thin line */
					background: linear-gradient(90deg, var(--progress-color), white);
					background-size: 200% 100%;
					animation: loading 3s linear infinite;
				}

				@keyframes loading {
					0% {
						background-position: 0% 0%;
					}
					100% {
						background-position: 100% 0%;
					}
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
					<xsl:with-param name="y-dimension" select="$y-dimensions"/>
					<xsl:with-param name="groups" select="$groups"/>
				</xsl:apply-templates>
			</thead>
			<xsl:apply-templates mode="datagrid:tbody" select="$groups[1]">
				<xsl:with-param name="x-dimension" select="$x-dimensions"/>
				<xsl:with-param name="y-dimension" select="$y-dimensions[not(@page:index)]"/>
			</xsl:apply-templates>
			<xsl:apply-templates mode="datagrid:tbody" select="$y-dimensions[@page:index]">
				<xsl:with-param name="x-dimension" select="$x-dimensions"/>
			</xsl:apply-templates>
			<tfoot>
				<xsl:apply-templates mode="datagrid:footer-row" select=".">
					<xsl:with-param name="x-dimension" select="$x-dimensions"/>
					<xsl:with-param name="y-dimension" select="$y-dimensions"/>
					<xsl:with-param name="groups" select="$groups"/>
				</xsl:apply-templates>
			</tfoot>
			<caption>
				<xsl:apply-templates mode="datagrid:caption" select="."/>
			</caption>
		</table>
	</xsl:template>

	<xsl:template mode="datagrid:tbody" match="*|@*">
		<xsl:param name="dimensions" select="."/>
		<xsl:param name="x-dimension" select="node-expected"/>
		<xsl:param name="y-dimension" select="node-expected"/>
		<xsl:param name="groups" select="ancestor-or-self::*[1]/@group:*"/>
		<xsl:param name="parent-groups" select="dummy:node-expected"/>
		<xsl:param name="rows" select="$y-dimension[self::*]|self::*[not(*)]/@state:record_count|$y-dimension[not(self::*)][.=current()]/.."/>
		<xsl:if test="self::* or not(self::*) and $rows">
			<tbody>
				<xsl:variable name="collapse:match" select="key('collapse:group', concat(local-name(current()/../..),'::',.))"/>
				<xsl:variable name="collapse">
					<xsl:for-each select="$collapse:match/parent::*[count(@*[namespace-uri()=''])=count($parent-groups|.)]">
						<xsl:for-each select="@*[namespace-uri()='']">
							<xsl:if test="position()=1">,</xsl:if>
							<xsl:choose>
								<xsl:when test="$rows/@*[name()=local-name(current())] = current()">1</xsl:when>
								<xsl:otherwise>0</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:for-each>
				</xsl:variable>
				<xsl:variable name="collapse_value">
					<xsl:for-each select="$parent-groups|.">
						<xsl:if test="position()=1">,</xsl:if>
						<xsl:text>1</xsl:text>
					</xsl:for-each>
				</xsl:variable>
				<!-- class="table-group-divider" -->
				<xsl:variable name="collapsed">
					<xsl:choose>
						<xsl:when test="not(//@group:*[1])">false</xsl:when>
						<xsl:when test="contains($collapse,$collapse_value)">true</xsl:when>
						<xsl:when test="not($groups) and $state:collapse_all = 'true'">
							<xsl:variable name="expand:match" select="key('expand:group', concat(local-name(current()/../..),'::',.))"/>
							<xsl:variable name="expand">
								<xsl:for-each select="$expand:match/parent::*[count(@*[namespace-uri()=''])=count($parent-groups|.)]">
									<xsl:for-each select="@*[namespace-uri()='']">
										<xsl:if test="position()=1">,</xsl:if>
										<xsl:choose>
											<xsl:when test="$rows/@*[name()=local-name(current())] = current()">1</xsl:when>
											<xsl:otherwise>0</xsl:otherwise>
										</xsl:choose>
									</xsl:for-each>
								</xsl:for-each>
							</xsl:variable>
							<xsl:variable name="expand_value">
								<xsl:for-each select="$parent-groups|.">
									<xsl:if test="position()=1">,</xsl:if>
									<xsl:text>1</xsl:text>
								</xsl:for-each>
							</xsl:variable>
							<xsl:choose>
								<xsl:when test="contains($expand,$expand_value)">false</xsl:when>
								<xsl:otherwise>true</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>false</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:apply-templates mode="datagrid:tbody-header" select=".">
					<xsl:with-param name="x-dimension" select="$x-dimension"/>
					<xsl:with-param name="rows" select="$rows"/>
					<xsl:with-param name="groups" select="$groups"/>
					<xsl:with-param name="parent-groups" select="$parent-groups"/>
					<xsl:with-param name="collapsed" select="$collapsed='true'"/>
				</xsl:apply-templates>
				<xsl:choose>
					<xsl:when test="$collapsed='true'"></xsl:when>
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

	<xsl:template mode="datagrid:tbody" match="*[@page:index]">
		<xsl:param name="x-dimension" select="node-expected"/>
		<xsl:variable name="page-size" select="@page:size"/>
		<tbody page-index="{@page:index}" page-size="{@page:size}">
			<tr class="skeleton">
				<td colspan="{count($x-dimension)}" style="text-align: left;">
					página <xsl:value-of select="@page:index"/>
				</td>
			</tr>
			<xsl:for-each select="(//@*)[position() &lt; $page-size]">
				<tr class="skeleton">
					<td colspan="{count($x-dimension)}" style="text-align: left;">&#160;</td>
				</tr>
			</xsl:for-each>
		</tbody>
	</xsl:template>

	<xsl:template mode="datagrid:tbody" match="@group:*">
		<xsl:param name="dimensions" select="."/>
		<xsl:param name="x-dimension" select="node-expected"/>
		<xsl:param name="y-dimension" select="node-expected"/>
		<xsl:param name="groups" select="ancestor-or-self::*[1]/@group:*"/>
		<xsl:param name="parent-groups" select="dummy:node-expected"/>

		<xsl:comment>debug:info</xsl:comment>
		<xsl:variable name="group" select="key('data:group',name())"/>
		<!--<xsl:variable name="rows" select="key('datagrid:record',$y-dimension/@xo:id)/@*[name()=local-name(current())]"/>-->
		<xsl:variable name="rows" select="$y-dimension/@*[name()=local-name(current())]"/>
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
		<xsl:param name="x-dimension" select="@*"/>
		<colgroup>
			<col width="50"/>
			<xsl:apply-templates mode="datagrid:colgroup-col" select="$x-dimension">
				<xsl:sort order="descending" select="namespace-uri()!=''"/>
			</xsl:apply-templates>
		</colgroup>
	</xsl:template>

	<xsl:attribute-set name="datagrid:colgroup-col-class">
		<xsl:attribute name="class">
			<xsl:if test="key('state:hidden',name())">hidden</xsl:if>
		</xsl:attribute>
	</xsl:attribute-set>

	<xsl:template mode="datagrid:colgroup-col" match="@*">
		<xsl:comment>
			<xsl:value-of select="name()"/>
		</xsl:comment>
		<xsl:element name="col" use-attribute-sets="datagrid:colgroup-col-class">
			<xsl:attribute name="width">100</xsl:attribute>
		</xsl:element>
	</xsl:template>

	<xsl:template mode="datagrid:colgroup-col" match="key('data_type','description')">
		<xsl:comment>
			<xsl:value-of select="name()"/>
		</xsl:comment>
		<xsl:element name="col" use-attribute-sets="datagrid:colgroup-col-class">
			<xsl:attribute name="width">200</xsl:attribute>
		</xsl:element>
	</xsl:template>

	<xsl:key name="datagrid:record" match="row" use="@xo:id"/>
	<xsl:key name="datagrid:record-data" match="row/@*" use="../@xo:id"/>

	<xsl:template mode="datagrid:row" match="*">
		<xsl:param name="row" select="key('datagrid:record',@xo:id)"/>
		<xsl:param name="data" select="key('datagrid:record-data',$row/@xo:id)"/>
		<xsl:param name="x-dimension" select="$row/@*[not(key('state:hidden',name()))]"/>
		<xsl:param name="parent-groups" select="node-expected"/>
		<tr>
			<th scope="row">
				<xsl:value-of select="position()"/>
			</th>
			<xsl:apply-templates mode="datagrid:cell" select="$x-dimension">
				<xsl:sort select="namespace-uri()" order="descending"/>
				<xsl:with-param name="row" select="$row"/>
				<xsl:with-param name="data" select="$data"/>
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

	<xsl:template mode="datagrid:header-row-config" match="*">
		<xsl:param name="fields" select="node-expected"/>
		<ul class="dropdown-menu">
			<xsl:if test="$state:hide_empty!=''">
				<li>
					<a class="dropdown-item" href="#" onclick="xo.state.hide_empty = !xo.state.hide_empty">
						<xsl:choose>
							<xsl:when test="$state:hide_empty='true'">Mostrar registros en ceros</xsl:when>
							<xsl:otherwise>Ocultar registros en ceros</xsl:otherwise>
						</xsl:choose>
					</a>
				</li>
			</xsl:if>
			<xsl:if test="//@group:*[1]|//@filter:*[1]">
				<li>
					<a class="dropdown-item" href="#" onclick="xo.stores.active.select(`//@group:*|//@filter:*`).remove()">Borrar filtros y agrupaciones</a>
				</li>
			</xsl:if>
			<xsl:if test="//@group:*[1]">
				<xsl:if test="$state:hide_suggested!=''">
					<li>
						<a class="dropdown-item" href="#" onclick="xo.state.hide_suggested = !xo.state.hide_suggested">
							<xsl:choose>
								<xsl:when test="$state:hide_suggested='true'">No ocultar todos campos sugeridos</xsl:when>
								<xsl:otherwise>Ocultar campos sugeridos</xsl:otherwise>
							</xsl:choose>
						</a>
					</li>
				</xsl:if>
				<li>
					<a class="dropdown-item" href="#" onclick="xo.state.collapse_all = true">
						<xsl:choose>
							<xsl:when test="$state:collapse_all = 'true'">
								<xsl:attribute name="onclick">xo.state.collapse_all = false</xsl:attribute>
								Expandir todo
							</xsl:when>
							<xsl:otherwise>Colapsar todo</xsl:otherwise>
						</xsl:choose>
					</a>
				</li>
			</xsl:if>
			<li>
				<hr class="dropdown-divider"/>
			</li>
			<div class="dropdown-item" style="height: 350px; overflow-y: scroll;">
				<ul class="list-group">
					<xsl:for-each select="$fields">
						<xsl:variable name="column" select="current()"/>
						<xsl:variable name="hidden" select="key('state:hidden',name())"/>
						<xsl:variable name="grouped" select="key('data:group',concat('group:',name()))"/>
						<li class="list-group-item" onclick="event.preventDefault(); return false;" draggable="true">
							<xsl:choose>
								<xsl:when test="key('data:group', concat('group:',name()))">
									<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-stack ms-2 button" viewBox="0 0 16 16" onclick="dispatch('ungroup')" xo-slot="group:cte">
										<path d="m14.12 10.163 1.715.858c.22.11.22.424 0 .534L8.267 15.34a.6.6 0 0 1-.534 0L.165 11.555a.299.299 0 0 1 0-.534l1.716-.858 5.317 2.659c.505.252 1.1.252 1.604 0l5.317-2.66zM7.733.063a.6.6 0 0 1 .534 0l7.568 3.784a.3.3 0 0 1 0 .535L8.267 8.165a.6.6 0 0 1-.534 0L.165 4.382a.299.299 0 0 1 0-.535z"></path>
										<path d="m14.12 6.576 1.715.858c.22.11.22.424 0 .534l-7.568 3.784a.6.6 0 0 1-.534 0L.165 7.968a.299.299 0 0 1 0-.534l1.716-.858 5.317 2.659c.505.252 1.1.252 1.604 0z"></path>
									</svg>
								</xsl:when>
								<xsl:otherwise>
									<xsl:variable name="checked" select="$grouped or not($hidden)"/>
									<input class="form-check-input me-1" type="checkbox" value="" id="{generate-id()}" xo-slot="hidden:{name()}">
										<xsl:if test="$checked">
											<xsl:attribute name="checked"/>
										</xsl:if>
										<xsl:choose>
											<xsl:when test="$grouped">
												<xsl:attribute name="disabled"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:attribute name="onclick">
													scope.set(<xsl:value-of select="$checked"/>)
												</xsl:attribute>
											</xsl:otherwise>
										</xsl:choose>
									</input>
								</xsl:otherwise>
							</xsl:choose>
							<label class="form-check-label" for="{generate-id()}">
								<xsl:apply-templates mode="headerText" select="."/>
							</label>
						</li>
					</xsl:for-each>
				</ul>
			</div>
		</ul>
	</xsl:template>

	<xsl:template mode="datagrid:header-row" match="*">
		<xsl:param name="x-dimension" select="node-expected"/>
		<tr>
			<th scope="col">
				<div class="dropdown xo-silent">
					<button class="btn btn-secondary dropdown-toggle btn-sm" type="button" data-bs-toggle="dropdown" aria-expanded="false">
						<svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" fill="currentColor" class="bi bi-gear-fill" viewBox="0 0 16 16">
							<path d="M9.405 1.05c-.413-1.4-2.397-1.4-2.81 0l-.1.34a1.464 1.464 0 0 1-2.105.872l-.31-.17c-1.283-.698-2.686.705-1.987 1.987l.169.311c.446.82.023 1.841-.872 2.105l-.34.1c-1.4.413-1.4 2.397 0 2.81l.34.1a1.464 1.464 0 0 1 .872 2.105l-.17.31c-.698 1.283.705 2.686 1.987 1.987l.311-.169a1.464 1.464 0 0 1 2.105.872l.1.34c.413 1.4 2.397 1.4 2.81 0l.1-.34a1.464 1.464 0 0 1 2.105-.872l.31.17c1.283.698 2.686-.705 1.987-1.987l-.169-.311a1.464 1.464 0 0 1 .872-2.105l.34-.1c1.4-.413 1.4-2.397 0-2.81l-.34-.1a1.464 1.464 0 0 1-.872-2.105l.17-.31c.698-1.283-.705-2.686-1.987-1.987l-.311.169a1.464 1.464 0 0 1-2.105-.872zM8 10.93a2.929 2.929 0 1 1 0-5.86 2.929 2.929 0 0 1 0 5.858z"/>
						</svg>
					</button>
					<xsl:apply-templates mode="datagrid:header-row-config" select=".">
						<xsl:with-param name="fields" select="$x-dimension/../@*[namespace-uri()='']"/>
					</xsl:apply-templates>
				</div>
			</th>
			<xsl:apply-templates mode="datagrid:header-cell" select="$x-dimension">
				<xsl:sort select="namespace-uri()" order="descending"/>
			</xsl:apply-templates>
		</tr>
	</xsl:template>

	<xsl:template mode="datagrid:caption" match="*">
		<xsl:apply-templates mode="datagrid:caption" select="key('datagrid:caption', @xo:id)"/>
	</xsl:template>

	<xsl:template mode="datagrid:caption" match="@*">
		<xsl:text>Vigencia de la información: </xsl:text>
		<xsl:apply-templates select="."/>
	</xsl:template>

	<xsl:template mode="datagrid:footer-row" match="*">
		<xsl:param name="x-dimension" select="node-expected"/>
		<xsl:param name="y-dimension" select="node-expected"/>
		<xsl:param name="data" select="key('datagrid:record-data',$y-dimension/@xo:id)"/>
		<tr>
			<th></th>
			<xsl:apply-templates mode="datagrid:footer-cell" select="$x-dimension">
				<xsl:sort select="namespace-uri()" order="descending"/>
				<xsl:with-param name="rows" select="$y-dimension"/>
				<xsl:with-param name="data" select="$data"/>
			</xsl:apply-templates>
		</tr>
	</xsl:template>

	<xsl:template mode="datagrid:cell-class-by-type" match="key('data_type', 'number')|@*[key('datatype', concat('number:',name()))]">
		<xsl:text/> number<xsl:text/>
	</xsl:template>

	<xsl:template mode="datagrid:cell-class-by-type" match="key('data_type', 'money')|@*[key('datatype', concat('money:',name()))]">
		<xsl:text/> money number<xsl:text/>
	</xsl:template>

	<xsl:template mode="datagrid:cell-class-by-type" match="key('data_type', 'percent')|@*[key('datatype', concat('percent:',name()))]">
		<xsl:text/> percent number<xsl:text/>
	</xsl:template>

	<xsl:template mode="datagrid:cell-class-by-type" match="key('data_type', 'integer')|@*[key('datatype', concat('integer:',name()))]">
		<xsl:text/> integer number<xsl:text/>
	</xsl:template>

	<xsl:template mode="datagrid:cell" match="@*">
		<xsl:param name="row" select="ancestor-or-self::*[1]"/>
		<xsl:param name="data" select="$row/@*"/>
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
			<xsl:choose>
				<xsl:when test="namespace-uri()='http://panax.io/state/group'">
					<!--<xsl:attribute name="style">max-width:5px; overflow: hidden;</xsl:attribute>-->
					<div class="d-flex flex-nowrap">
						<xsl:apply-templates mode="datagrid:header-cell-options" select="."/>
						<label class="{$classes}">
							<xsl:apply-templates mode="datagrid:header-cell-content" select="."/>
						</label>
						<xsl:apply-templates mode="datagrid:header-cell-icons" select="."/>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<div class="d-flex flex-nowrap">
						<xsl:apply-templates mode="datagrid:header-cell-options" select="."/>
						<label class="{$classes}">
							<xsl:apply-templates mode="datagrid:header-cell-content" select="."/>
						</label>
						<xsl:apply-templates mode="datagrid:header-cell-icons" select="."/>
					</div>
				</xsl:otherwise>
			</xsl:choose>
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
		<xsl:param name="rows" select="node-expected"/>
		<xsl:param name="data" select="@attributes-expected"/>
		<td>
			<xsl:comment>
				<xsl:value-of select="name()"/>
			</xsl:comment>
		</td>
	</xsl:template>

	<xsl:template mode="datagrid:footer-cell" match="@*[key('total', name())]">
		<xsl:param name="rows" select="node-expected"/>
		<xsl:param name="data" select="@attributes-expected"/>
		<td>
			<xsl:variable name="value">
				<xsl:apply-templates mode="datagrid:aggregate" select=".">
					<xsl:with-param name="data" select="$rows/@*[name()=local-name(current())]"/>
				</xsl:apply-templates>
			</xsl:variable>
			<xsl:call-template name="format">
				<xsl:with-param name="value" select="$value"/>
				<xsl:with-param name="mask">###,##0;-###,##0</xsl:with-param>
			</xsl:call-template>
		</td>
	</xsl:template>

	<xsl:template mode="datagrid:footer-cell" match="key('data_type', 'number')|@*[key('datatype', concat('number:',name()))]">
		<xsl:param name="rows" select="node-expected"/>
		<xsl:param name="data" select="@attributes-expected"/>
		<td class="number">
			<xsl:variable name="value">
				<xsl:apply-templates mode="datagrid:aggregate" select=".">
					<xsl:with-param name="data" select="$rows/@*[name()=local-name(current())]"/>
				</xsl:apply-templates>
			</xsl:variable>
			<xsl:call-template name="format">
				<xsl:with-param name="value" select="$value"/>
				<xsl:with-param name="mask">###,##0.00;-###,##0.00</xsl:with-param>
			</xsl:call-template>
		</td>
	</xsl:template>

	<xsl:template mode="datagrid:footer-cell" match="key('data_type', 'integer')|@*[key('datatype', concat('integer:',name()))]">
		<xsl:param name="rows" select="node-expected"/>
		<xsl:param name="data" select="@attributes-expected"/>
		<td>
			<xsl:variable name="value">
				<xsl:apply-templates mode="datagrid:aggregate" select=".">
					<xsl:with-param name="data" select="$rows/@*[name()=local-name(current())]"/>
				</xsl:apply-templates>
			</xsl:variable>
			<xsl:call-template name="format">
				<xsl:with-param name="value" select="$value"/>
				<xsl:with-param name="mask">###,##0;-###,##0</xsl:with-param>
			</xsl:call-template>
		</td>
	</xsl:template>

	<xsl:template mode="datagrid:footer-cell" match="key('data_type', 'money')|@*[key('datatype', concat('money:',name()))]">
		<xsl:param name="rows" select="node-expected"/>
		<xsl:param name="data" select="@attributes-expected"/>
		<td class="money">
			<xsl:variable name="value">
				<xsl:apply-templates mode="datagrid:aggregate" select=".">
					<xsl:with-param name="data" select="$data[name()=local-name(current())]"/>
				</xsl:apply-templates>
			</xsl:variable>
			<xsl:call-template name="format">
				<xsl:with-param name="value" select="$value"/>
				<xsl:with-param name="mask">$###,##0.00;-$###,##0.00</xsl:with-param>
			</xsl:call-template>
		</td>
	</xsl:template>

	<!--<xsl:template mode="datagrid:header-cell" match="key('state', 'hidden')" priority="2"/>
	<xsl:template mode="datagrid:cell" match="key('state', 'hidden')" priority="2"/>
	<xsl:template mode="datagrid:footer-cell" match="key('state', 'hidden')" priority="2"/>-->

	<xsl:template mode="datagrid:footer-cell" match="key('data_type', 'avg')">
		<td>
			<xsl:call-template name="format">
				<xsl:with-param name="value" select="sum(key('facts',name()))"/>
				<xsl:with-param name="mask">$###,##0.00;-$###,##0.00</xsl:with-param>
			</xsl:call-template>
		</td>
	</xsl:template>

	<xsl:template mode="datagrid:aggregate" match="@*">
		<xsl:value-of select="count(key('facts',name()))"/>
	</xsl:template>

	<xsl:template mode="datagrid:aggregate" match="key('data_type', 'money')|@*[key('datatype', concat('money:',name()))]|key('data_type', 'integer')|@*[key('datatype', concat('integer:',name()))]|key('data_type', 'number')|@*[key('datatype', concat('number:',name()))]">
		<xsl:param name="data" select="@attributes-expected"/>
		<xsl:value-of select="sum($data)"/>
	</xsl:template>

	<xsl:key name="total" match="@total:*" use="local-name()"/>
	<xsl:template mode="datagrid:aggregate" match="@*[key('total', name())]">
		<xsl:param name="data" select="@attributes-expected"/>
		<xsl:apply-templates select="key('total', name())">
			<xsl:with-param name="data" select="$data"/>
		</xsl:apply-templates>
	</xsl:template>

	<xsl:template match="@*[starts-with(.,'*')]">
		<xsl:value-of select="substring-after(.,'*')"/>
	</xsl:template>

	<xsl:key name="datagrid:group" use="'collapsed'" match="row[@state:collapsed='true']/@*" />

	<xsl:template mode="datagrid:group-buttons" match="@*">
		<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-dash-square icon-btn" viewBox="0 0 16 16" style="cursor:pointer;" onclick="dispatch('collapse')">
			<path d="M14 1a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1h12zM2 0a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V2a2 2 0 0 0-2-2H2z"></path>
			<path d="M4 8a.5.5 0 0 1 .5-.5h7a.5.5 0 0 1 0 1h-7A.5.5 0 0 1 4 8z"></path>
		</svg>
	</xsl:template>

	<xsl:template mode="datagrid:group-buttons" match="row[@state:collapsed='true']/@*" priority="1">
		<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-plus-square icon-btn" viewBox="0 0 16 16" style="cursor:pointer;" onclick="dispatch('expand')">
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
		<xsl:param name="collapsed" select="false()"/>

		<xsl:variable name="current" select="current()"/>
		<xsl:variable name="collapse:match" select="key('collapse:group', concat(local-name(current()/../..),'::',.))"/>
		<tr class="header sticky group-level-{count($parent-groups) + 1}">
			<th style="text-align: center;">
				&#160;
			</th>
			<xsl:for-each select="$parent-groups">
				<xsl:sort select="position()" order="descending"/>
				<th class="parent-group" xo-scope="{$rows/@xo:id}" xo-slot="{name($rows/@*[name()=local-name(current()/../..)])}">
					<tab-space style="padding-right: 4rem; margin-left: -10px;"></tab-space>
				</th>
			</xsl:for-each>
			<th scope="row" colspan="{count($groups) + 1}" style="white-space: nowrap;" xo-scope="{$rows/@xo:id}" xo-slot="{name($rows/@*[name()=local-name(current()/../..)])}">
				<xsl:choose>
					<xsl:when test="$collapsed">
						<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-plus-square icon-btn" viewBox="0 0 16 16" style="cursor:pointer;" onclick="dispatch('expand')">
							<path d="M14 1a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1h12zM2 0a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V2a2 2 0 0 0-2-2H2z"></path>
							<path d="M8 4a.5.5 0 0 1 .5.5v3h3a.5.5 0 0 1 0 1h-3v3a.5.5 0 0 1-1 0v-3h-3a.5.5 0 0 1 0-1h3v-3A.5.5 0 0 1 8 4z"></path>
						</svg>
					</xsl:when>
					<xsl:otherwise>
						<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-dash-square icon-btn" viewBox="0 0 16 16" style="cursor:pointer;" onclick="dispatch('collapse')">
							<path d="M14 1a1 1 0 0 1 1 1v12a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V2a1 1 0 0 1 1-1h12zM2 0a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V2a2 2 0 0 0-2-2H2z"></path>
							<path d="M4 8a.5.5 0 0 1 .5-.5h7a.5.5 0 0 1 0 1h-7A.5.5 0 0 1 4 8z"></path>
						</svg>
					</xsl:otherwise>
				</xsl:choose>
				<!--<xsl:apply-templates mode="datagrid:group-buttons" select="."/>-->
				<strong>
					<xsl:apply-templates select="../@desc"/>
				</strong>
			</th>
			<!--<th scope="row" colspan="{count($groups|$parent-groups) + 1}" style="white-space: nowrap;">
				<xsl:for-each select="$parent-groups|.">
					<xsl:sort select="namespace-uri()" order="descending"/>
					<xsl:choose>
						<xsl:when test="position()=last()">
							<xsl:apply-templates mode="datagrid:group-buttons" select="."/>
						</xsl:when>
						<xsl:otherwise>
							<tab-space style="padding-right: 4rem; margin-left: 5px;">|</tab-space>
						</xsl:otherwise>
					</xsl:choose>

				</xsl:for-each>
				<strong>
					<xsl:apply-templates select="../@desc"/>
				</strong>
			</th> TODO: Implementar esto cuando se quieran ocultar las columnas que están agrupando -->
			<xsl:apply-templates mode="datagrid:tbody-header-cell" select="$x-dimension[namespace-uri()=''][not(key('data:group',concat('group:',name())))]">
				<xsl:with-param name="rows" select="$rows"/>
			</xsl:apply-templates>
		</tr>
	</xsl:template>

	<xsl:template mode="datagrid:tbody-header-cell" match="@*">
		<th></th>
	</xsl:template>

	<xsl:template mode="datagrid:tbody-header-cell" match="@*[key('total', name())]">
		<xsl:param name="rows" select="node-expected"/>
		<xsl:param name="data" select="@attributes-expected"/>
		<th class="number">
			<xsl:variable name="value">
				<xsl:apply-templates mode="datagrid:aggregate" select=".">
					<xsl:with-param name="data" select="$rows/@*[name()=local-name(current())]"/>
				</xsl:apply-templates>
			</xsl:variable>
			<xsl:call-template name="format">
				<xsl:with-param name="value" select="$value"/>
				<xsl:with-param name="mask">###,##0;-###,##0</xsl:with-param>
			</xsl:call-template>
		</th>
	</xsl:template>

	<xsl:template mode="datagrid:tbody-header-cell" match="key('data_type', 'number')|@*[key('datatype', concat('number:',name()))]">
		<xsl:param name="rows" select="node-expected"/>
		<xsl:param name="data" select="@attributes-expected"/>
		<xsl:variable name="field" select="current()"/>
		<th class="number">
			<xsl:variable name="value">
				<xsl:apply-templates mode="datagrid:aggregate" select=".">
					<xsl:with-param name="data" select="$rows/@*[name()=local-name(current())]"/>
				</xsl:apply-templates>
			</xsl:variable>
			<xsl:call-template name="format">
				<xsl:with-param name="value" select="$value"/>
				<xsl:with-param name="mask">###,##0.00;-###,##0.00</xsl:with-param>
			</xsl:call-template>
			<xsl:comment>
				<xsl:value-of select="$value"/>
			</xsl:comment>
		</th>
	</xsl:template>

	<xsl:template mode="datagrid:tbody-header-cell" match="key('data_type', 'integer')|@*[key('datatype', concat('integer:',name()))]">
		<xsl:param name="rows" select="node-expected"/>
		<xsl:param name="data" select="@attributes-expected"/>
		<xsl:variable name="field" select="current()"/>
		<th class="number integer">
			<xsl:variable name="value">
				<xsl:apply-templates mode="datagrid:aggregate" select=".">
					<xsl:with-param name="data" select="$rows/@*[name()=local-name(current())]"/>
				</xsl:apply-templates>
			</xsl:variable>
			<xsl:call-template name="format">
				<xsl:with-param name="value" select="$value"/>
				<xsl:with-param name="mask">###,##0;-###,##0</xsl:with-param>
			</xsl:call-template>
		</th>
	</xsl:template>

	<xsl:template mode="datagrid:tbody-header-cell" match="key('data_type', 'money')|@*[key('datatype', concat('money:',name()))]">
		<xsl:param name="rows" select="node-expected"/>
		<xsl:param name="data" select="@attributes-expected"/>
		<xsl:variable name="field" select="current()"/>
		<th class="money">
			<xsl:variable name="value">
				<xsl:apply-templates mode="datagrid:aggregate" select=".">
					<xsl:with-param name="data" select="$rows/@*[name()=local-name(current())]"/>
				</xsl:apply-templates>
			</xsl:variable>
			<xsl:call-template name="format">
				<xsl:with-param name="value" select="$value"/>
				<xsl:with-param name="mask">$###,##0.00;-$###,##0.00</xsl:with-param>
			</xsl:call-template>
		</th>
	</xsl:template>
</xsl:stylesheet>