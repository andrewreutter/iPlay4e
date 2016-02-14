<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" encoding="ISO-8859-1" indent="yes"
 doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
 doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

<xsl:include href="/145541695845/xsl/UIMobile.xsl" />

<xsl:template match="sections">
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
                    <xsl:choose>
                        <xsl:when test="@flatten='flatten'">
                            <ul>
                                <xsl:apply-templates select="section/item" mode="flat" />
                            </ul>
                        </xsl:when>
                        <xsl:when test="not(@emphasize_first)">
                            <ul>
                                <xsl:apply-templates select="section" mode="listitem" />
                            </ul>
                        </xsl:when>
                        <xsl:otherwise>
                            <h2><xsl:value-of select="section[1]/@title" /></h2>
                            <ul>
                                <xsl:apply-templates select="section[1]/item" />
                            </ul>
                            <h2><xsl:value-of select="@emphasize_first" /></h2>
                            <ul>
                                <xsl:apply-templates select="section[position()!=1]" mode="listitem" />
                            </ul>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
                <xsl:choose>
                    <xsl:when test="@flatten='flatten'">
                    </xsl:when>
                    <xsl:when test="not(@emphasize_first)">
                        <xsl:apply-templates select="section" mode="page" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="section[position()!=1]" mode="page" />
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </body>
    </html>
</xsl:template>

<xsl:template match="section" mode="listitem">
    <li class="withArrow">
        <a href="#" onclick="var newPage = $('@{generate-id(@title)}');$$('.jPintPage').without(newPage).invoke('hide');newPage.show();return false;">
            <div class="primary">
                <xsl:value-of select="@title" />
            </div>
        </a>
    </li>
</xsl:template>

<xsl:template match="section" mode="page">
    <div class="jPintPage EdgedList HasTitle" id="@{generate-id(@title)}" style="display:none;">
        <ul>
            <li>
                <a href="#" onclick="var newPage = $('main');$$('.jPintPage').without(newPage).invoke('hide');newPage.show();return false;">
                    <img src="/145541695845/images/chevronback.png" style="margin-right:8px;border:0;" /> Back
                </a>
            </li>
        </ul>
        <h2><xsl:value-of select="@title" /></h2>
        <ul>
            <xsl:apply-templates select="item" />
        </ul>
    </div>
</xsl:template>

<xsl:template match="item">
    <li>
        <div class="primary">
            <xsl:copy-of select="title/node()" />
        </div>
        <div class="tertiary plaintext">
                <xsl:copy-of select="content/node()" />
        </div>
    </li>
</xsl:template>

<xsl:template match="item" mode="flat">
    <li>
        <div class="primary">
            <xsl:value-of select="../@title" />
        </div>
        <div class="tertiary plaintext">
                <xsl:copy-of select="content/node()" />
        </div>
    </li>
</xsl:template>

</xsl:stylesheet>
