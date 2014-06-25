<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
		xmlns:lxir="http://www.latex-lxir.org">

<!--
Encloses blocks of minipages with a <minipage-block> element.
Minipages are used to create multiple columns.
This transformation must be applied before merging non-numbered pars with numbered pars.
-->

<xsl:template match="par[minipage and count(minipage | text[text() = ' ']) = count(*)]">
	<xsl:copy><!-- the paragraphs are merged later by the xml cleaner program -->
		<minipage-block>
			<xsl:apply-templates select="*" mode="in-minipage"/>
		</minipage-block>
	</xsl:copy>
</xsl:template>

<!-- remove <text> </text> between minipages -->
<xsl:template match="par/text[not(../ancestor::par)]" mode="in-minipage"/>

<xsl:template match="* | @* | text()" mode="in-minipage">
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
