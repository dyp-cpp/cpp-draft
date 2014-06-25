<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	xmlns:lxir="http://www.latex-lxir.org">

<!--
Various simplifications and restructuring of tables and longtables.
-->

<xsl:template match="float[@lxir:floatType = 'table']">
	<xsl:element name="table">
		<xsl:attribute name="id">
			<!-- The simpletypetable and the floattable have their labels at different (relative) paths -->
			<xsl:value-of select="par/label/@lxir:idlabel"/>
			<xsl:value-of select="par/caption//label/@lxir:idlabel"/>
		</xsl:attribute>
		
		<xsl:attribute name="position">
			<xsl:value-of select="par/caption/captionMark"/>
		</xsl:attribute>
		
		<xsl:element name="caption">
			<xsl:apply-templates select="par/caption/captionText/*" mode="in-table"/>
		</xsl:element>
		
		<xsl:if test="par/longtable">
			<xsl:element name="continued-caption">
				<xsl:apply-templates select="par/tabular/rowGroup/row/cell/continuedcaption/*" mode="in-table"/>
			</xsl:element>
		</xsl:if>
		
		<xsl:apply-templates mode="in-table" select="par/*"/>
	</xsl:element>
</xsl:template>

<xsl:template match="caption | continuedcaption | longtable" mode="in-table"/>

<xsl:template match="  float[@lxir:floatType = 'table']/par/label
                     | float[@lxir:floatType = 'table']/par/caption//label"
              mode="in-table"/>

<xsl:template match="centering[count(*) = 0] | item[count(*) = 0] | itemMark[count(*) = 0]"
              mode="in-table"/>

<xsl:template match="vline | hline | cline" mode="in-table"/>

<!--
Table header rows do not differ from rows inside the table (data rows).
However, there is a <capsep/> element after the header.
This transformation moves table header rows into a <tableHeader> element.
-->
<xsl:template match="row" mode="in-table">
	<xsl:variable name="next-sibling" select="following-sibling::*[1]"/>
	<xsl:variable name="test" select="name($next-sibling) = 'row' and boolean($next-sibling/*[capsep])"/>
	<xsl:choose>
		<xsl:when test="$test">
			<xsl:element name="tableHeader">
				<!-- add header type information for longtables -->
				<xsl:if test="(ancestor::float)[1]/par/longtable">
<!--				<xsl:variable name="headerTypeElement"
							  select="($next-sibling/*[capsep][1]/capsep[1])/following-sibling::*[1]"/>-->
					<xsl:variable name="headerTypeElement"
								  select="($next-sibling/*/capsep)[1]/following-sibling::*[1]"/>

					<xsl:attribute name="headType">
						<xsl:choose>
							<xsl:when test="name($headerTypeElement) = 'endFirstHead'">
								<xsl:text>primary</xsl:text>
							</xsl:when>
							<xsl:when test="name($headerTypeElement) = 'endHead'">
								<xsl:text>continued</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>error: unknown header type (</xsl:text>
								<xsl:value-of select="name($headerTypeElement)"/>
								<xsl:text>)</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
				</xsl:if><!-- is longtable -->
				
				<xsl:copy>
					<xsl:apply-templates mode="in-table"/>
				</xsl:copy>
			</xsl:element>
		</xsl:when>
		
		<xsl:otherwise>
			<xsl:copy>
				<xsl:apply-templates mode="in-table"/>
			</xsl:copy>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="multirow/@lxir:rows" mode="in-table">
	<xsl:attribute name="rows"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="multicolumn/@lxir:span" mode="in-table">
	<xsl:attribute name="columns"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

<!-- remove empty rowGroups -->
<xsl:template match="tabular/rowGroup[1]/row[    count(cell) = 1
                                             and boolean(cell/text) and cell/text/text() = ' ']"
              mode="in-table"/>

<xsl:template match="multicolumn/text[text() = ' ']" mode="in-table"/>

<!-- not sure what this element is for :( -->
<xsl:template match="col[count(*) = 0 and not(ancestor::columnsModel)]" mode="in-table"/>

<xsl:template match="capsep | endFirstHead | endHead" mode="in-table"/>

<!--
support for multirow:
lxir only adds information to the cell that spans multiple rows,
not to the cells that are affected.
This information is very useful though, and added in this transformation.
For each cell, the corresponding cells in the previous rows are searched.
If one of them says that it spans multiple rows, it is checked whether the current cell is affected.
-->
<xsl:template match="tabular/rowGroup/row/cell" mode="in-table">
	<xsl:variable name="own-column-num" select="1 + count(preceding-sibling::cell)"/>
	<xsl:variable name="own-row" select=".."/>
	<xsl:variable name="own-rowGroup" select="../.."/>
	<xsl:variable name="prev-rowGroups-rowsCount"
	              select="count($own-row/../preceding-sibling::rowGroup/row)"/>
	<xsl:variable name="own-row-num"
	              select="count($own-row/preceding-sibling::row) + $prev-rowGroups-rowsCount"/>
	
	<xsl:copy>
		<!-- iterate through preceding rowGroups -->
		<xsl:for-each select="$own-rowGroup/preceding-sibling::rowGroup">
			<xsl:variable name="preceding-rowGroups" select="preceding-sibling::rowGroup"/>
			<!-- iterate through all rows -->
			<xsl:for-each select="row">
				<xsl:variable name="target-cell" select="cell[$own-column-num]"/>
				<xsl:variable name="cur-row-num" select="position() + count($preceding-rowGroups/row)"/>
				<xsl:variable name="required" select="1 + $own-row-num - $cur-row-num"/>
				<xsl:if test="    boolean($target-cell/multirow)
				              and $target-cell/multirow/@lxir:rows &gt; $required">
					<xsl:attribute name="multirow-target"><xsl:value-of select="cur-row-num"/></xsl:attribute>
				</xsl:if>
			</xsl:for-each>
		</xsl:for-each>
		
		<xsl:apply-templates select="@* | * | text()" mode="in-table"/>
	</xsl:copy>
</xsl:template>


<xsl:template match="* | @* | text()" mode="in-table">
	<xsl:copy>
		<xsl:apply-templates select="@* | * | text()" mode="in-table"/>
	</xsl:copy>
</xsl:template>


<xsl:template match="* | @* | text()">
	<xsl:copy>
		<xsl:apply-templates select="@* | * | text()"/>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
