<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	xmlns:lxir="http://www.latex-lxir.org">

<!--
Restructures the beginning and header of a section.
-->

<xsl:template match="sectionHeader">
	<xsl:attribute name="id">
		<xsl:value-of select="sectionTitle/label/@lxir:idlabel"/>
	</xsl:attribute>
	
	<xsl:attribute name="position">
		<xsl:value-of select="normalize-space(sectionMark)"/><!-- trim -->
	</xsl:attribute>
	
	<xsl:attribute name="level">
		<xsl:value-of select="@lxir:level"/>
	</xsl:attribute>
	
	<xsl:element name="title">
		<xsl:apply-templates select="sectionTitle/*"/>
	</xsl:element>
</xsl:template>


<xsl:template match="sectionTitle/label"/>


<!-- drop the first paragraph in a <section> if it contains only a white space -->
<xsl:template match="section/par[count(preceding-sibling::*) = 1 and count(*) = 1 and text and text/text() = ' ']">
	<!-- drop it -->
</xsl:template>


<xsl:template match="* | @* | text()">
	<xsl:copy>
		<xsl:apply-templates select="@* | * | text()"/>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
