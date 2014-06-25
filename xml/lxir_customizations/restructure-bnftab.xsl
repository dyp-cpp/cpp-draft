<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
		xmlns:lxir="http://www.latex-lxir.org">

<!--
Bnftabs use manual indentation.
For example, if a line is too long, it is broken manually and the continuing line is indented.
If there is a nontermdef, every rule (everything) is indented once,
so we look for <br/> followed by a single <indent/> to identify distinct grammar rules.
If there is no nontermdef, we look for a <br/> NOT followed by a <indent/>.
-->

<xsl:template match="bnftab[nontermdef]">
	<xsl:copy>
		<xsl:attribute name="type"><xsl:value-of select="name(.)"/></xsl:attribute>
		<xsl:apply-templates select="@*"/>
		
		<defines>
			<xsl:apply-templates select="nontermdef"/>
		</defines>
		
		<!--
			switching to manual depth-first traversal (recursive implementation),
			since the stateless automatic DFT of XSLT doesn't allow collecting
			nodes AFAIK
		-->
		<xsl:for-each select="indent[     name(following-sibling::*[1]) != 'indent'
		                              and name(preceding-sibling::*[1]) = 'br'      ]">
			<grammar-rule>
				<xsl:apply-templates select="following-sibling::*[1]" mode="collect-bnftab-grammar-rule"/>
			</grammar-rule>
		</xsl:for-each>
	</xsl:copy>
</xsl:template>

<xsl:template match="br[     name(following-sibling::*[1]) = 'indent'
                         and name(following-sibling::*[2]) != 'indent' ]"
              mode="collect-bnftab-grammar-rule"/><!-- end recursion -->

<xsl:template match="br" mode="collect-bnftab-grammar-rule">
	<br-hint/>
	<xsl:apply-templates select="following-sibling::*[name(.) != 'indent'][1]"
	                     mode="collect-bnftab-grammar-rule"/>
</xsl:template>

<xsl:template match="* | @* | text()" mode="collect-bnftab-grammar-rule">
	<xsl:copy>
		<xsl:apply-templates select="@* | * | text()"/>
	</xsl:copy>
	<xsl:apply-templates select="following-sibling::*[1]" mode="collect-bnftab-grammar-rule"/>
</xsl:template>


<xsl:template match="bnftab[not(nontermdef)]">
	<xsl:element name="bnftab">
		<xsl:attribute name="type"><xsl:value-of select="name(.)"/></xsl:attribute>
		<xsl:apply-templates select="@*"/>
		
		<grammar-rule>
			<xsl:apply-templates select="*[1]" mode="collect-simplebnftab-grammar-rule"/>
		</grammar-rule>
		
		<xsl:for-each select="br[name(following-sibling::*[1]) != 'indent']">
			<grammar-rule>
				<xsl:apply-templates select="following-sibling::*[1]"
				                     mode="collect-simplebnftab-grammar-rule"/>
			</grammar-rule>
		</xsl:for-each>
	</xsl:element>
</xsl:template>

<xsl:template match="br[name(following-sibling::*[1]) != 'indent']"
              mode="collect-simplebnftab-grammar-rule"/><!-- end recursion -->

<xsl:template match="br" mode="collect-simplebnftab-grammar-rule">
	<br-hint/>
	<xsl:apply-templates select="following-sibling::*[name(.) != 'indent']"
	                     mode="collect-simplebnftab-grammar-rule"/>
</xsl:template>

<xsl:template match="* | @* | text()" mode="collect-simplebnftab-grammar-rule">
	<xsl:copy>
		<xsl:apply-templates select="@* | * | text()"/>
	</xsl:copy>
	<xsl:apply-templates select="following-sibling::*[1]" mode="collect-simplebnftab-grammar-rule"/>
</xsl:template>


<xsl:template match="* | @* | text()">
	<xsl:copy>
		<xsl:apply-templates select="@* | * | text()"/>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
