<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
		xmlns:mm="http://www.w3.org/1998/Math/MathML"
		xmlns:lxir="http://www.latex-lxir.org">

<!--
Transforms the <ref/> elements to an lxir-agnostic format.
-->

<xsl:template match="ref">
	<xsl:copy>
		<xsl:attribute name="idref"><xsl:value-of select="@lxir:idref"/></xsl:attribute>
		<xsl:attribute name="positionref"><xsl:value-of select="refMark"/></xsl:attribute>
	</xsl:copy>
</xsl:template>

<xsl:template match="* | @* | text()">
	<xsl:copy>
		<xsl:apply-templates select="@* | * | text()"/>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
