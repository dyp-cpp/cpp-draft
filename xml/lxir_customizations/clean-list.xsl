<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
		xmlns:lxir="http://www.latex-lxir.org">

<!--
Various simplifications of lists.
-->

<!-- If this is not an enumeration, drop simple item marks like bullets or special dashes -->
<xsl:template match="list//itemMark">
	<xsl:if test="    ancestor::list[1]/@lxir:listType != 'enumerate'
	              and (string-length(./text) > 1 or count(*) != count(./text))">
		<xsl:copy>
			<xsl:apply-templates select="@* | * | text()"/>
		</xsl:copy>
	</xsl:if>
	<!-- else: just drop it -->
</xsl:template>

<xsl:template match="list//width"/>

<xsl:template match="list//par | indented/par">
	<xsl:choose>
		<xsl:when test="descendant::pnum">
			<error name="numbered paragraph inside list"/>
			<xsl:copy>
				<xsl:apply-templates select="@* | * | text()"/>
			</xsl:copy>
		</xsl:when>
		
		<xsl:otherwise>
			<!-- drop the par node, keep the contents -->
			<xsl:apply-templates select="* | text()"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="list/@lxir:listType">
	<xsl:attribute name="type">
		<xsl:value-of select="."/>
	</xsl:attribute>
</xsl:template>


<xsl:template match="* | @* | text()">
	<xsl:copy>
		<xsl:apply-templates select="@* | * | text()"/>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
