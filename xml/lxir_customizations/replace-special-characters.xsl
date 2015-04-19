<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	xmlns:lxir="http://www.latex-lxir.org">


<!--
This transformation replaces various special characters occuring in the raw
XML that lxir produces.
Some of these are arguably bugs in packages such as listings,
others could be considered incorrect even in the PDF output
(that is, their LaTeX source is problematic).
-->


<!--
	Replace special asterisk character
	The only known occurences are as multiline-comment markers,
	i.e. /* and */
	It is possible that this is unintended by the listings package.
	
	Replace special apostrophe character
	Use the ASCII apostrophe character instead.
-->
<xsl:variable name="ascii-apos">'</xsl:variable>
<xsl:template match="tcode/text() | terminal/text() | codeblock/text/text()">
	<xsl:value-of select="translate(., '∗’', concat('*', $ascii-apos))"/>
</xsl:template>


<xsl:template match="* | @*">
	<xsl:copy>
		<xsl:apply-templates select="* | @* | text()"/>
	</xsl:copy>
</xsl:template>


</xsl:stylesheet>
