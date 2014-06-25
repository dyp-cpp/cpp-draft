<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
		xmlns:lxir="http://www.latex-lxir.org">

<!--
Restructures bnf and simplebnf environments.
Transforms flat <grammar-rule/> markers to <grammar-rule>..</grammar-rule> nodes.
-->

<xsl:template match="bnf | simplebnf">
	<xsl:element name="bnf">
		<xsl:attribute name="type"><xsl:value-of select="name(.)"/></xsl:attribute>
		<xsl:apply-templates select="@*"/>
		
		<defines>
			<xsl:choose>
				<xsl:when test="nontermdef">
					<xsl:apply-templates select="nontermdef"/>
				</xsl:when>
				<xsl:when test="name(.) = 'bnf' and nonterminal">
					<xsl:apply-templates select="nonterminal[1]"/>
				</xsl:when>
				<xsl:when test="name(.) = 'simplebnf'"/>
				<xsl:otherwise>
					<error>bnf without definition</error>
				</xsl:otherwise>
			</xsl:choose>
		</defines>
		
		<xsl:if test="not(grammar-rule)">
			<grammar-rule>
				<xsl:apply-templates select="*"/>
			</grammar-rule>
		</xsl:if>
		<xsl:for-each select="grammar-rule">
			<grammar-rule>
				<xsl:apply-templates select="following-sibling::*[1]" mode="collect-grammar-rule"/>
			</grammar-rule>
		</xsl:for-each>
	</xsl:element>
</xsl:template>

<xsl:template match="grammar-rule" mode="collect-grammar-rule"/><!-- end recursion -->

<xsl:template match="* | @* | text()" mode="collect-grammar-rule">
	<xsl:copy>
		<xsl:apply-templates select="@* | * | text()"/>
	</xsl:copy>
	<xsl:apply-templates select="following-sibling::*[1]" mode="collect-grammar-rule"/>
</xsl:template>


<xsl:template match="* | @* | text()">
	<xsl:copy>
		<xsl:apply-templates select="@* | * | text()"/>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
