<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
		xmlns:lxir="http://www.latex-lxir.org">

<!--
clean up definition paragraphs
* drop the surrounding paragraph
* introduce a proper <defines> node
* move the label to an appropriate place
* drop the initial <br/>
* replace the remaining <br/>s with <alt-name/> and <explanation/> markers

From lxir, we get something like:

<par>
	<br/>
	<definition>argument</definition>
	<label/>
	
	<br/>
	actual argument
	
	<br/>
	actual parameter
	
	<br/>
	&lt;function call expression&gt;
	expression in the comma-separated list bounded by the parentheses
</par>

The result shall be:

<definition>
	<defines>argument</defines>
	<alt-name>actual argument</alt-name>
	<alt-name>actual parameter</alt-name>
	<explanation>
		&lt;function call expression&gt;
		expression in the comma-separated list bounded by the parentheses
	</explanation>
</definition>
-->

<xsl:template match="par[definition]">
	<definition>
		<xsl:apply-templates select="definition/@*" mode="in-definition"/>
		<xsl:attribute name="id"><xsl:value-of select="label/@lxir:idlabel"/></xsl:attribute>
		
		<defines>
			<xsl:copy-of select="definition/text/text()"/>
		</defines>
		
		<xsl:variable name="expl-br"
		              select="br[   count(following-sibling::br) = 0
		                         or count(following-sibling::br) =
		                            count(following-sibling::br[   'note'    = name(following-sibling::*[1])
		                                                        or 'example' = name(following-sibling::*[1])
		                                                       ]
		                                 )
		                        ][1]
		                     "/>
		<xsl:variable name="expl-br-pos" select="count($expl-br/preceding-sibling::br)"/>
		
		<xsl:for-each select="definition/following-sibling::br[count(preceding-sibling::br) &lt; $expl-br-pos]">
			<xsl:variable name="next-br-pos" select="count(following-sibling::br[1]/preceding-sibling::*)"/>
			<alt-name>
				<xsl:apply-templates select="following-sibling::*[count(preceding-sibling::*) &lt; $next-br-pos]"
				                     mode="in-definition"/>
			</alt-name>
		</xsl:for-each>
		
		<explanation>
			<xsl:apply-templates select="$expl-br/following-sibling::*" mode="in-definition"/>
		</explanation>
	</definition>
</xsl:template>

	<xsl:template match="label" mode="in-definition"/>

	<xsl:template match="@lxir:position" mode="in-definition">
		<xsl:attribute name="position"><xsl:value-of select="."/></xsl:attribute>
	</xsl:template>

	<xsl:template match="@lxir:level" mode="in-definition">
		<xsl:attribute name="level"><xsl:value-of select="."/></xsl:attribute>
	</xsl:template>
	
	<!-- not sure what to do with the remaining <br/>s -->
	<!--<xsl:template match="par[definition]/br" mode="in-definition"/>-->

	<xsl:template match="text[name(preceding-sibling::*[1]) = 'definition' and text() = ' ']"
	              mode="in-definition"/>

	<xsl:template match="* | @* | text()" mode="in-definition">
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
