<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
		xmlns:lxir="http://www.latex-lxir.org">

<!--
Restructures bnf and simplebnf environments.
Transforms flat <grammar-rule/> markers to <grammar-rule>..</grammar-rule> nodes.
-->

<xsl:template name="make-grammar-rule">
	<xsl:param name="target" select="."/>
	<grammar-rule>
			<xsl:apply-templates select="$target" mode="collect-grammar-rule"/>
	</grammar-rule>
</xsl:template>

<xsl:template match="bnf">
	<bnf type="bnf">
		<xsl:apply-templates select="@*"/>
		
		<defines>
			<xsl:choose>
				<xsl:when test="nontermdef">
					<xsl:apply-templates select="nontermdef"/>
				</xsl:when>
				<xsl:when test="name(.) = 'bnf' and nonterminal">
					<error>bnf without nontermdef</error>
					<xsl:apply-templates select="nonterminal[1]"/>
				</xsl:when>
				<xsl:otherwise>
					<error>bnf without definition</error>
				</xsl:otherwise>
			</xsl:choose>
		</defines>
		
		<xsl:if test="not(grammar-rule)">
			<error>bnf without grammar-rule</error>
		</xsl:if>
		<xsl:for-each select="grammar-rule/following-sibling::*[1]">
			<xsl:call-template name="make-grammar-rule"/>
		</xsl:for-each>
	</bnf>
</xsl:template>

<xsl:template match="simplebnf">
	<bnf type="simplebnf">
		<xsl:apply-templates select="@*"/>
		
		<defines/>
		<xsl:if test="nontermdef">
			<error>simplebnf with definition</error>
		</xsl:if>
		
		<xsl:call-template name="make-grammar-rule">
			<xsl:with-param name="target" select="*[1]"/>
		</xsl:call-template>
		
		<xsl:for-each select="grammar-rule/following-sibling::*[1]">
			<xsl:call-template name="make-grammar-rule"/>
		</xsl:for-each>
	</bnf>
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
