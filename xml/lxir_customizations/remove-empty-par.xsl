<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
		xmlns:lxir="http://www.latex-lxir.org">

<!--
Removing empty paragraphs.
This has to be done in a separate step after the "finalize" transformation,
since some paragraphs only become empty after removing unused nodes such as <ClassOrPackageUsed>
-->

<xsl:template match="par[count(*) = 0 and not(text())]"/><!-- drop the empty paragraph -->


<xsl:template match="* | @* | text()">
	<xsl:copy>
		<xsl:apply-templates select="@* | * | text()"/>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
