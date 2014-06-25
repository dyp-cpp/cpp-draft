<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	xmlns:lxir="http://www.latex-lxir.org">

<!--
Simplify and restructure figures.
Figures are external images that will later have to be linked to actual files;
potentially here's a problem with file type compatibility:
For pdflatex, we can use .pdf; but that's not a good idea for HTML output.
This intermediary XML format doesn't impose any such restrictions itself.
-->

<xsl:template match="float[@lxir:floatType = 'figure']">
	<figure>
		<xsl:attribute name="id"><xsl:value-of select="par/label/@lxir:idlabel"/></xsl:attribute>
		<xsl:attribute name="position">
			<xsl:apply-templates select="par/caption/captionMark/*"/>
		</xsl:attribute>
		<caption>
			<xsl:apply-templates select="par/caption/captionText/*"/>
		</caption>
		<xsl:apply-templates select="*" mode="in-figure"/>
	</figure>
</xsl:template>

<xsl:template match="float/par" mode="in-figure">
	<xsl:apply-templates select="*" mode="in-figure"/>
</xsl:template>

<xsl:template match="importgraphic" mode="in-figure">
	<xsl:copy>
		<xsl:apply-templates select="@* | * | text()" mode="in-figure"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="text[preceding-sibling::importgraphic and text() = ' ']" mode="in-figure"/>

<xsl:template match="par/caption | label" mode="in-figure"/>

<xsl:template match="* | @* | text()" mode="in-figure">
	<xsl:copy>
		<xsl:apply-templates select="@* | * | text()"/>
	</xsl:copy>
</xsl:template>


<xsl:template match="* | @* | text()">
	<xsl:copy>
		<xsl:apply-templates select="@* | * | text()"/>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
