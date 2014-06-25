<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	xmlns:lxir="http://www.latex-lxir.org"
	xmlns:mathml="http://www.w3.org/1998/Math/MathML">

<!--
Perform various cleanup operations on <text> elements and their contents.
* add the xml:space="preserve" attribute
* drop attributes for single-space text elements <text> </text> to make them mergeable
* drop <text> elements inside inline elements

Text merging is performed in the xml-cleaner program.
Two text elements are only merged if their attributes are compatible.
-->

<xsl:template match="text[text() = ' ' and count(*) = 0]">
	<xsl:copy>
		<xsl:attribute name="xml:space">preserve</xsl:attribute>
		<xsl:apply-templates select="* | text()"/><!-- drop attributes -->
	</xsl:copy>
</xsl:template>

<xsl:template match="text">
	<xsl:copy>
		<xsl:attribute name="xml:space">preserve</xsl:attribute>
		<xsl:apply-templates select="@* | * | text()"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="  term | tcode | defnx | doccite | grammarterm | nonterminal | terminal
                     | nonterminal-definition | emph | placeholder">
	<xsl:variable name="test" select="concat('text: ]', text,
	                                         '[ count(text): ', count(text), ' count(*): ', count(*))"/>
	<xsl:copy>
		<xsl:copy-of select="@*"/>
		<xsl:choose>
			<!-- todo: maybe check count(XY) -->
			<xsl:when test="text | mathml:math">
				<xsl:attribute name="xml:space">preserve</xsl:attribute>
				<xsl:apply-templates select="*" mode="inline"/>
			</xsl:when>
			<xsl:otherwise>
				<error name="supposed inline node contains no text" value="{$test}"/>
				<xsl:apply-templates select="* | text()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:copy>
</xsl:template>

<xsl:template match="text" mode="inline">
	<!-- Drop text element and its attributes. In theory, the formatting should be expressed
		 through the surrounding inline element -->
	<xsl:apply-templates select="* | text()"/>
</xsl:template>

<!-- this lxir feature unfortunately gets in the way of things like ^= -->
<xsl:template match="node[@type = 'textaccent']"/>

<xsl:template match="ICS/@lxir:index | ICS/@lxir:arg">
	<xsl:attribute name="{local-name(.)}">
		<xsl:value-of select="."/>
	</xsl:attribute>
</xsl:template>


<xsl:template match="* | @* | text()">
	<xsl:copy>
		<xsl:apply-templates select="@* | * | text()"/>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
