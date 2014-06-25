<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	xmlns:lxir="http://www.latex-lxir.org">

<!--
This transformation changes the content of <codeblock>s.
* replaces <verbatimSpace/> nodes with nonbreakable space entities
* replaces <verbatimLineBreak/> nodes with newlines
* merges <text> nodes
-->

<xsl:template match="codeblock">
	<xsl:copy>
		<xsl:apply-templates select="@*"/>
		<xsl:apply-templates mode="in-codeblock" select="*"/>
	</xsl:copy>
</xsl:template>

<!-- inside codeblock -->
	<xsl:template match="par" mode="in-codeblock">
		<xsl:apply-templates mode="in-codeblock" select="*|text()"/>
	</xsl:template>

	<!--
		Even though there are different kinds of text (comment, <unspecified>, .., code),
		I think it's unlikely that we can differentiate them reliably,
		and it's not worth the trouble IMO.
	-->
	<xsl:template match="par/text" mode="in-codeblock">
		<xsl:copy>
			<!-- drop attributes -->
			<xsl:attribute name="xml:space">preserve</xsl:attribute>
			<xsl:apply-templates mode="in-codeblock" select="*|text()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="tcode" mode="in-codeblock">
		<xsl:copy>
			<xsl:apply-templates mode="in-codeblock" select="@* | * | text()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template name="verbatimSpace">
		<text xml:space="preserve"><xsl:text>&#xa0;</xsl:text></text>
	</xsl:template>

	<xsl:template name="verbatimLineBreak">
		<!-- insert a newline -->
		<text xml:space="preserve"><xsl:text>
</xsl:text></text>
	</xsl:template>

	<xsl:template match="verbatimSpace" mode="in-codeblock">
		<xsl:call-template name="verbatimSpace"/>
	</xsl:template>

	<xsl:template match="verbatimLineBreak" mode="in-codeblock">
		<xsl:call-template name="verbatimLineBreak"/>
	</xsl:template>
	
	
	<xsl:template match="*|@*" mode="in-codeblock">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="in-codeblock" select="*|text()"/>
		</xsl:copy>
	</xsl:template>
<!-- inside codeblock -->


<xsl:template match="verbatimSpace">
	<xsl:call-template name="verbatimSpace"/>
</xsl:template>

<xsl:template match="verbatimLineBreak">
	<xsl:call-template name="verbatimLineBreak"/>
</xsl:template>


<xsl:template match="*|@*">
	<xsl:copy>
		<xsl:apply-templates select="*|@*|text()"/>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
