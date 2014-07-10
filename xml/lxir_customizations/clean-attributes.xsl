<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	xmlns:lxir="http://www.latex-lxir.org"
	xmlns:mathml="http://www.w3.org/1998/Math/MathML">

<!--
Clean up some attributes which aren't required and just introduce noise.
-->

<!-- drop -->
	<xsl:template match="text/@h | text/@v | text/@width"/>
	<xsl:template match="@lxir:id | @lxir:close-id"/>
	<xsl:template match="mathml:math/@begin-id | mathml:math/@end-id"/>

<!-- rename -->
	<xsl:template match="number/@lxir:value">
		<xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
	</xsl:template>

<!-- default -->
	<xsl:template match="* | @* | text()">
		<xsl:copy>
			<xsl:apply-templates select="* | @* | text()"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
