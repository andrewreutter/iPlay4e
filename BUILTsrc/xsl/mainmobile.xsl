<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" encoding="ISO-8859-1" indent="yes"
 doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
 doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

<xsl:include href="/143371090575/xsl/UIMobile.xsl" />

<xsl:template match="Page">
    <html>
        <xsl:call-template name="headtag">
            <xsl:with-param name="title"><xsl:value-of select="@title" /></xsl:with-param>
        </xsl:call-template>
        <body id="jPint" class="InIframe" onload="pageAuth();makeLinksInternal();">
            <div class="jPintPageSet">
                <xsl:call-template name="header">
                    <xsl:with-param name="title"><xsl:value-of select="@title" /></xsl:with-param>
                </xsl:call-template>
                <div class="jPintPage EdgedList HasTitle" id="main">
                    <div class="mainplaintext" style="position:relative;clear:both;">
                        <img src="/apple-touch-icon.png" style="float:right;" />
                        <xsl:copy-of select="Intro/node()" />
                    </div>
                    <xsl:apply-templates select="Section" />
                </div>
            </div>
        </body>
    </html>
</xsl:template>

<xsl:template match="Section">
    <h2>
        <xsl:value-of select="@title" />
    </h2>
    <ul>
        <xsl:apply-templates select="Item" />
    </ul>
</xsl:template>

<xsl:template match="Item">
    <li>
        <div class="mainplaintext">
            <xsl:copy-of select="node()" />
        </div>
    </li>
</xsl:template>

</xsl:stylesheet>
