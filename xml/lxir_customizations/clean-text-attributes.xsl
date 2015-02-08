<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
		xmlns:lxir="http://www.latex-lxir.org">

<!--
Checks the attributes of <text> elements.
This XSLT adds <error> nodes if it encounters unexpected attributes,
and removes attribute "noise".

The initial idea was to find "unhandled" formatting, that is,
(la)tex text formatting implicitly or explicitly used in the latex sources
that has not yet been linked to a specific purpose.

For example, almost all changes to italic fonts are made through macros
like \term or \grammarterm, \defn etc. and those are transformed to specific XML elements.
-->

<xsl:template match="text">
	<xsl:variable name="default-font-and-series" select="@font = '15' and @lxir:series = 'm'"/>
	
	<xsl:variable name="is-list2-item" select="ancestor::list and ancestor::list[1]/ancestor::list"/>
	<xsl:variable name="list2-item-font-and-series"
	              select="    (@font = 16 or @font = 20 or @font = 17 or @font = '22')
	                      and @lxir:series = 'bx'"/>
	<xsl:variable name="list2-item" select="$is-list2-item and $list2-item-font-and-series"/>
	
	<xsl:variable name="footnoteText"
	              select="    ancestor::footnoteText
	                      and @lxir:series = 'm'"/>
	
	<xsl:variable name="sectionTitle"
	              select="name(ancestor::*[1]) = 'title' and name(ancestor::*[2]) = 'section'
	                      and @lxir:series = 'bx'"/>
	
	<xsl:variable name="codeblock"
	              select="    ancestor::codeblock
	                      and (    not(@lxir:family)
	                           or (@lxir:family = 'cmtt' and @lxir:series = 'm' and @lxir:shape = 'n'))"/>
	
	<xsl:variable name="shape-and-family" select="@lxir:family = 'cmr' and @lxir:shape = 'n'"/>
	
	<xsl:variable name="empty-or-preserve" select="count(@*) = 0 or count(@*) = 1 and @xml:space"/>
	
	<xsl:variable name="special-exceptions"
	              select="     $shape-and-family
	                      and ($default-font-and-series or $list2-item or $footnoteText or $sectionTitle)"/>
	
	<xsl:copy>
		<xsl:choose>
			<xsl:when test="$empty-or-preserve or $codeblock or $special-exceptions">
				<!-- todo: maybe check other possible attributes -->
				<xsl:apply-templates select="@*" mode="clean-attr"/>
				<xsl:apply-templates select="* | text()"/><!-- drop attributes -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="@*"/>
				<error value="{@*}">
					<xsl:text>unhandled formatting; </xsl:text>
					<xsl:value-of select="(@lxir:family = 'cmtt' and @lxir:series = 'm' and @lxir:shape = 'n')"/>
					<xsl:text>; </xsl:text>
					<xsl:value-of select="@lxir:family"/><xsl:text>; </xsl:text>
					<xsl:value-of select="@lxir:series"/><xsl:text>; </xsl:text>
					<xsl:value-of select="@lxir:shape"/><xsl:text>; </xsl:text>
				</error>
				<xsl:apply-templates select="* | text()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:copy>
</xsl:template>

<xsl:template match="@font | @lxir:series | @lxir:family | @lxir:shape" mode="clean-attr"/>

<xsl:template match="@*" mode="clean-attr">
	<xsl:copy><xsl:value-of select="."/></xsl:copy>
</xsl:template>


<xsl:template match="* | @* | text()">
	<xsl:copy>
		<xsl:apply-templates select="* | @* | text()"/>
	</xsl:copy>
</xsl:template>

</xsl:stylesheet>
