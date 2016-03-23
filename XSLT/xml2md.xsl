<?xml version="1.0" encoding="UTF-8"?>
<!-- This XSLT transforms https://github.com/dret/sedola XML documents into github-friendly MD. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xpath-default-namespace="http://github.com/dret/sedola">
    <xsl:output name="md-text" method="text" encoding="UTF-8"/>
    <xsl:variable name="RFC" select="collection(concat('../IETF/RFC/','?select=*.xml'))"/>
    <xsl:variable name="I-D" select="collection(concat('../IETF/I-D/','?select=*.xml'))"/>
    <xsl:variable name="W3C" select="collection(concat('../W3C/','?select=*.xml'))"/>
    <xsl:variable name="allfiles" select="$RFC | $I-D | $W3C"/>
    <xsl:template match="/">
        <xsl:result-document href="../MD/specs.md" format="md-text">
            <xsl:text># Specifications&#xa;&#xa;Listing a total of </xsl:text>
            <xsl:value-of select="count(distinct-values($allfiles))"/>
            <xsl:text> specifications, which can be broken down into </xsl:text>
            <xsl:value-of select="count(distinct-values($allfiles/service[starts-with(@id, 'urn:ietf:')]))"/>
            <xsl:text> [IETF](http://www.ietf.org/ "Internet Engineering Taskforce") specifications and </xsl:text>
            <xsl:value-of select="count(distinct-values($allfiles/service[starts-with(@id, 'http://www.w3.org/TR/')]))"/>
            <xsl:text> [W3C](http://www.w3.org/ "World Wide Web Consortium") specifications.&#xa;&#xa;</xsl:text>
            <xsl:text>## IETF Specifications&#xa;&#xa;This list is split into stable RFC specifications, and work-in-progress I-D drafts.&#xa;&#xa;### IETF Request for Comments (RFC)&#xa;&#xa;</xsl:text>
            <xsl:for-each select="$allfiles/service[starts-with(@id, 'urn:ietf:rfc:')]">
                <xsl:sort select="title/text()"/>
                <xsl:text>* [</xsl:text>
                <xsl:value-of select="title/text()"/>
                <xsl:text> (RFC </xsl:text>
                <xsl:value-of select="substring-after(@id, 'urn:ietf:rfc:')"/>
                <xsl:text>)](http://tools.ietf.org/html/rfc</xsl:text>
                <xsl:value-of select="substring-after(@id, 'urn:ietf:rfc:')"/>
                <xsl:text>)&#xa;</xsl:text>
            </xsl:for-each>
            <xsl:text>&#xa;### IETF Internet Drafts (I-D)&#xa;&#xa;</xsl:text>
            <xsl:for-each select="$allfiles/service[starts-with(@id, 'urn:ietf:id:')]">
                <xsl:sort select="title/text()"/>
                <xsl:text>* [</xsl:text>
                <xsl:value-of select="title/text()"/>
                <xsl:text> (`draft-</xsl:text>
                <xsl:value-of select="substring-after(@id, 'urn:ietf:id:')"/>
                <xsl:text>`)](http://tools.ietf.org/html/draft-</xsl:text>
                <xsl:value-of select="substring-after(@id, 'urn:ietf:id:')"/>
                <xsl:text>)&#xa;</xsl:text>
            </xsl:for-each>
            <xsl:text>&#xa;## W3C Specifications&#xa;&#xa;</xsl:text>
            <xsl:for-each select="$allfiles/service[starts-with(@id, 'http://www.w3.org/TR/')]">
                <xsl:sort select="title/text()"/>
                <xsl:text>* [</xsl:text>
                <xsl:value-of select="title/text()"/>
                <xsl:text> (`</xsl:text>
                <xsl:value-of select="substring-after(@id, 'http://www.w3.org/TR/')"/>
                <xsl:text>`)](</xsl:text>
                <xsl:value-of select="@id"/>
                <xsl:text>)&#xa;</xsl:text>
            </xsl:for-each>
        </xsl:result-document>
        <xsl:result-document href="../MD/headers.md" format="md-text">
            <xsl:text># HTTP Header Fields&#xa;&#xa;The following </xsl:text>
            <xsl:value-of select="count(distinct-values($allfiles//http-header/@def))"/>
            <xsl:text> HTTP header field definitions were found in </xsl:text>
            <xsl:value-of select="count($allfiles)"/>
            <xsl:text> services (</xsl:text>
            <xsl:value-of select="count($W3C)"/>
            <xsl:text> [W3C](../W3C/), </xsl:text>
            <xsl:value-of select="count($RFC)"/>
            <xsl:text> [RFC](../IETF/RFC/), </xsl:text>
            <xsl:value-of select="count($I-D)"/>
            <xsl:text> [I-D](../IETF/I-D)). Please be advised that the table shown here is maintained and compiled from [Sedola](https://github.com/dret/sedola) sources. The [official HTTP Header Field registry](http://www.iana.org/assignments/message-headers/message-headers.xhtml) is maintained by [the *Internet Assigned Numbers Authority (IANA)*](http://www.iana.org/).&#xa;&#xa;Header Field | Specification/Description&#xa;-------: | :---------- | :---&#xa;</xsl:text>
            <xsl:for-each select="distinct-values($allfiles//http-header/@def)">
                <xsl:sort select="lower-case(.)"/>
                <xsl:text>`</xsl:text>
                <xsl:value-of select="."/>
                <xsl:text>` |</xsl:text>
                <xsl:for-each select="$allfiles//http-header[@def eq current()]">
                    <xsl:text> [**</xsl:text>
                    <xsl:choose>
                        <xsl:when test="starts-with(../documentation/@source, 'http://tools.ietf.org/html/rfc')">
                            <xsl:text>RFC </xsl:text>
                            <xsl:value-of select="substring-after(../documentation/@source, 'http://tools.ietf.org/html/rfc')"/>
                        </xsl:when>
                        <xsl:when test="starts-with(../documentation/@source, 'http://tools.ietf.org/html/draft')">
                            <xsl:value-of select="substring-after(../documentation/@source, 'http://tools.ietf.org/html/')"/>
                        </xsl:when>
                        <xsl:when test="starts-with(../documentation/@source, 'http://www.w3.org/TR/')">
                            <xsl:text>W3C TR </xsl:text>
                            <xsl:value-of select="if ( ends-with(../documentation/@source, '/') ) then substring-before(substring-after(../documentation/@source, 'http://www.w3.org/TR/'), '/') else substring-after(../documentation/@source, 'http://www.w3.org/TR/')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>??????</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>**](</xsl:text>
                    <xsl:value-of select="../documentation/@source"/>
                    <xsl:text> "</xsl:text>
                    <xsl:value-of select="replace(../title/text(), '&quot;', '&#x201d;')"/>
                    <xsl:text>" ): [</xsl:text>
                    <xsl:value-of select="documentation/text()"/>
                    <xsl:text>](</xsl:text>
                    <xsl:value-of select="documentation/@source"/>
                    <xsl:text>)</xsl:text>
                    <xsl:choose>
                        <xsl:when test="position() ne last()">
                            <xsl:text> &lt;br/></xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>&#xa;</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:result-document>
        <xsl:result-document href="../MD/mediatypes.md" format="md-text">
            <xsl:text># Media Types&#xa;&#xa;The following </xsl:text>
            <xsl:value-of select="count($allfiles//mediatype[exists(@def)])"/>
            <xsl:text> media type definitions were found in </xsl:text>
            <xsl:value-of select="count($allfiles)"/>
            <xsl:text> services (</xsl:text>
            <xsl:value-of select="count($W3C)"/>
            <xsl:text> [W3C](../W3C/), </xsl:text>
            <xsl:value-of select="count($RFC)"/>
            <xsl:text> [RFC](../IETF/RFC/), </xsl:text>
            <xsl:value-of select="count($I-D)"/>
            <xsl:text> [I-D](../IETF/I-D)):&#xa;&#xa;</xsl:text>
            <xsl:for-each select="$allfiles//mediatype[exists(@def)]">
                <xsl:sort select="@def"/>
                <xsl:text>* </xsl:text>
                <xsl:value-of select="@def"/>
                <!--
                <xsl:text>](</xsl:text>
                <xsl:value-of select="documentation/@source"/>
                <xsl:text> "</xsl:text>
                <xsl:value-of select="replace(documentation/text(), '&quot;', '&#x201d;')"/>
-->
                <xsl:text> : [</xsl:text>
                <xsl:value-of select="../title/text()"/>
                <xsl:text>](</xsl:text>
                <xsl:value-of select="../documentation/@source"/>
                <xsl:text> "</xsl:text>
                <xsl:value-of select="replace(../documentation/text(), '&quot;', '&#x201d;')"/>
                <xsl:text>" )&#xa;</xsl:text>
            </xsl:for-each>
        </xsl:result-document>
        <xsl:result-document href="../MD/linkrels.md" format="md-text">
            <xsl:text># Link Relations&#xa;&#xa;The following </xsl:text>
            <xsl:value-of select="count($allfiles//link[exists(@def)])"/>
            <xsl:text> link relation definitions were found in </xsl:text>
            <xsl:value-of select="count($allfiles)"/>
            <xsl:text> services (</xsl:text>
            <xsl:value-of select="count($W3C)"/>
            <xsl:text> [W3C](../W3C/), </xsl:text>
            <xsl:value-of select="count($RFC)"/>
            <xsl:text> [RFC](../IETF/RFC/), </xsl:text>
            <xsl:value-of select="count($I-D)"/>
            <xsl:text> [I-D](../IETF/I-D)):&#xa;&#xa;Relation | Description | Specification&#xa;-------: | :---------- | :---&#xa;</xsl:text>
            <xsl:for-each select="$allfiles//link[exists(@def)]">
                <xsl:sort select="@def"/>
                <xsl:text>`</xsl:text>
                <xsl:value-of select="@def"/>
                <xsl:text>` | "[</xsl:text>
                <xsl:value-of select="documentation/text()"/>
                <xsl:text>](</xsl:text>
                <xsl:value-of select="documentation/@source"/>
                <xsl:text>)" | [</xsl:text>
                <xsl:value-of select="../title/text()"/>
                <xsl:text>](</xsl:text>
                <xsl:value-of select="../documentation/@source"/>
                <xsl:text> "</xsl:text>
                <xsl:value-of select="replace(../documentation/text(), '&quot;', '&#x201d;')"/>
                <xsl:text>" )&#xa;</xsl:text>
            </xsl:for-each>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>