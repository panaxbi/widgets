<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns="http://www.w3.org/1999/xhtml"
xmlns:data="http://panax.io/data"
xmlns:dummy="http://panax.io/dummy"
xmlns:state="http://panax.io/state"
xmlns:group="http://panax.io/state/group"
xmlns:collapse="http://panax.io/state/collapse"
xmlns:expand="http://panax.io/state/expand"
xmlns:datagrid="http://widgets.panaxbi.com/datagrid"
>
	<xsl:key name="collapse:group" match="collapse:groups/row/@*[namespace-uri()='']" use="concat(name(),'::',.)"/>
	<xsl:key name="expand:group" match="expand:groups/row/@*[namespace-uri()='']" use="concat(name(),'::',.)"/>

	<xsl:param name="state:collapse_all"></xsl:param>
	<xsl:key name="data:group" match="*[row]/@group:*" use="'*'"/>
	<xsl:key name="data:group" match="group:*/row/@desc" use="name(../..)"/>
	<xsl:template mode="datagrid:tbody" match="*|@*" priority="1">
		<xsl:param name="dimensions" select="."/>
		<xsl:param name="x-dimension" select="node-expected"/>
		<xsl:param name="y-dimension" select="node-expected"/>
		<xsl:param name="groups" select="ancestor-or-self::*[1]/@group:*"/>
		<xsl:param name="parent-groups" select="dummy:node-expected"/>
		<xsl:param name="rows" select="$y-dimension[self::*]|self::*[not(*)]/@state:record_count|$y-dimension[not(self::*)][.=current()]/.."/>
		<xsl:variable name="current" select="current()"/>
		<xsl:if test="self::* or not(self::*) and $rows">
			<tbody xo-scope="inherit" xo-swap="self::*">
				<xsl:for-each select="ancestor::group:*">
					<xsl:attribute name="{name()}">
						<xsl:value-of select="$current"/>
					</xsl:attribute>
				</xsl:for-each>
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
							<xsl:with-param name="parent-groups" select="$parent-groups"/>
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

	<xsl:template mode="datagrid:tbody" match="@group:*" priority="1">
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
</xsl:stylesheet>