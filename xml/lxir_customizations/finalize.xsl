<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
		xmlns:lxir="http://www.latex-lxir.org">

<!--
Various restructuring and removing unused nodes.
-->

<xsl:template match="/document">
	<xsl:element name="document"><!-- recreate the element to fix the namespace abbreviation -->
		<xsl:apply-templates select="*"/>
	</xsl:element>
</xsl:template>

<xsl:template match="/document/latex">
	<!-- drop the element, keep the children -->
	<xsl:apply-templates select="*"/>
</xsl:template>

<!-- removes various "noise", e.g. information about the LaTeX packages used -->
<xsl:template match="  setcolor | verbatimmath[count(*) = 0 and not(text())]
                     | ClassOrPackageUsed | TaggedWith | rule"/><!-- drop -->


<xsl:template match="* | @* | text()">
	<xsl:copy>
		<xsl:apply-templates select="@* | * | text()"/>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
