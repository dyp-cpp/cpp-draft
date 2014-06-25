<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
		xmlns:lxir="http://www.latex-lxir.org">

<!--
Restructures bnfkeywordtab environments.

I found the bnfkeywordtab quite tricky to convert to useful XML:
It uses forced line breaks (\\) and spaces (\>) to separate tokens.
In latex, I output empty elements <br-hint/> and <next-keyword/> respectively.
This XSLTransformation transforms those flat hints to a proper tree:

<bnfkeywordtab>
	<defines>..</defines>
	<line-hint>
		<keyword>..</keyword>
		<keyword>..</keyword>
	</line-hint>
</bnfkeywordtab>
-->

<xsl:template match="bnfkeywordtab">
	<xsl:copy>
		<xsl:apply-templates select="@*"/>
		
		<xsl:variable name="first-br-pos" select="count(./br-hint[1]/preceding-sibling::*)"/>
		<defines>
			<xsl:apply-templates select="*[count(preceding-sibling::*) &lt; $first-br-pos]"/>
		</defines>
		
		<xsl:for-each select="br-hint">
			<line-hint>
				<xsl:apply-templates select="following-sibling::next-keyword[1]" mode="collect-line"/>
			</line-hint>
		</xsl:for-each>
	</xsl:copy>
</xsl:template>

	<xsl:template match="next-keyword" mode="collect-line">
		<keyword>
			<xsl:apply-templates select="following-sibling::*[1]" mode="collect-keyword"/>
		</keyword>
		<xsl:apply-templates select="(following-sibling::br-hint | following-sibling::next-keyword)[1]"
		                     mode="collect-line"/>
	</xsl:template>

	<xsl:template match="br-hint" mode="collect-line"/><!-- end recursion -->
	<xsl:template match="next-keyword | br-hint" mode="collect-keyword"/><!-- end recursion -->


	<xsl:template match="* | @* | text()" mode="collect-line">
		<xsl:param name="mode"/>
		<xsl:copy>
			<xsl:apply-templates select="@* | * | text()"/>
		</xsl:copy>
		<xsl:apply-templates select="following-sibling::*[1]" mode="collect-line"/>
	</xsl:template>
	

	<xsl:template match="* | @* | text()" mode="collect-keyword">
		<xsl:param name="mode"/>
		<xsl:copy>
			<xsl:apply-templates select="@* | * | text()"/>
		</xsl:copy>
		<xsl:apply-templates select="following-sibling::*[1]" mode="collect-keyword"/>
	</xsl:template>


<xsl:template match="* | @* | text()">
	<xsl:copy>
		<xsl:apply-templates select="@* | * | text()"/>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
