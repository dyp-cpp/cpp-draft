<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
		xmlns:lxir="http://www.latex-lxir.org">

<!--
Simplifies footnotes, footnote calls and adds back-references.
Every footnote gets a list of footnote call elements that reference it
(as a list of IDs).
-->

<!--
	I don't like this solution. A (La)Tex solution would be better, but it seems some additional
	customization package would be required, and that could interfer with the lxir tagging.
	So, for now, we just remove the formatting via XSL.
-->
<xsl:template match="footnoteMark/superscript">
	<!-- drop the element, keep the children -->
	<xsl:apply-templates select="* | text()"/>
</xsl:template>

<xsl:template match="  footnoteCall/@lxir:page | footnote/@lxir:page | footnoteMark/@lxir:page
                     | footnoteMark/@lxir:idFootnote"/>

<!--
	When multiple footnote marks shall refer to the same footnote,
	something like \addtocounter{footnote}{-1}\footnotemark\ is used.
	Lxir converts this to a footnoteMark without a footnoteCall.
-->
<xsl:template match="footnoteMark[not(ancestor::footnoteCall) and not(ancestor::footnote)]">
	<xsl:element name="footnoteCall">
		<xsl:call-template name="footnoteCall-attr"/>
		
		<xsl:copy>
			<xsl:apply-templates select="* | text()"/>
		</xsl:copy>
	</xsl:element>
</xsl:template>

<xsl:template match="footnoteCall"><!-- default case -->
	<xsl:copy>
		<xsl:call-template name="footnoteCall-attr"/>
		<xsl:apply-templates select="* | text()"/>
	</xsl:copy>
</xsl:template>

<xsl:template name="footnoteCall-attr">
	<xsl:attribute name="idref">
		<xsl:value-of select="footnoteMark/@lxir:idFootnote"/>
		<xsl:value-of select="@lxir:idFootnote"/>
	</xsl:attribute>
	<xsl:apply-templates select="@*"/>
	<xsl:attribute name="id"><xsl:value-of select="generate-id(.)"/></xsl:attribute>
</xsl:template>

<xsl:template match="footnote">
	<xsl:variable name="own-id" select="@lxir:idFootnote"/>
	<xsl:copy>
		<xsl:apply-templates select="@*"/>
		
		<xsl:for-each select="  //footnoteCall[footnoteMark/@lxir:idFootnote = $own-id]
                              | //footnoteMark[     not(ancestor::footnote)
		                                        and not(ancestor::footnoteCall)
		                                        and @lxir:idFootnote = $own-id  ]">
			<footnoteBackref idref="{generate-id(.)}"/>
		</xsl:for-each>
		
		<xsl:apply-templates select="* | text()"/>
	</xsl:copy>
</xsl:template>

<xsl:template match="footnote/@lxir:idFootnote">
	<xsl:attribute name="id"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>


<xsl:template match="* | @* | text()">
	<xsl:copy>
		<xsl:apply-templates select="@* | * | text()"/>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
