<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" encoding="ISO-8859-1" indent="yes"
 doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
 doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

<xsl:include href="/143371090575/xsl/UIMobile.xsl" />

<xsl:template match="SearchResults">
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
                    <xsl:apply-templates select="." mode="searchHeader" />
                    <ul>
                        <xsl:apply-templates select="*" />
                        <xsl:choose>
                            <xsl:when test="@numResults='0'">
                                <li>
                                    <div class="plaintext">
                                        <xsl:choose>
                                            <xsl:when test="contains(@pagelessUrl, 'user=')">
                                                <xsl:choose>
                                                    <xsl:when test="contains(@pagelessUrl, 'Character')">
                                                        You don't have any characters yet.  
                                                        <br />
                                                        <br />
                                                        Use the New link in a non-mobile web browser
                                                        to turn your <i>.dnd4e</i> files into iPlay4e characters.
                                                    </xsl:when>
                                                    <xsl:when test="contains(@pagelessUrl, 'Campaign')">
                                                        You don't have any campaigns yet.  
                                                        <br />
                                                        <br />
                                                        Use the New link in a non-mobile web browser
                                                        to create a new campaign and invite your friends.
                                                    </xsl:when>
                                                </xsl:choose>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                Sorry, but your search didn't generate any results.
                                                <br />
                                                <br />
                                                You might want to have a look at the 
                                                <a href="/help#search">search instructions</a>.
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </div>
                                </li>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="." mode="paginationBar" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </ul>
                </div>
            </div>
        </body>
    </html>
</xsl:template>

<xsl:template match="SearchResults" mode="searchHeader">
    <xsl:choose>
        <xsl:when test="@numResults='0'">
            <xsl:text>&#xA;</xsl:text>
        </xsl:when>
        <xsl:otherwise>
            <h2>
                <div>
                    Results
                    <b>
                        <xsl:value-of select="@firstOnPage" />
                        -
                        <xsl:value-of select="@lastOnPage" />
                    </b>
                    of
                    <xsl:value-of select="@numResults" />
                </div>
            </h2>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="SearchResults" mode="paginationBar">
    <xsl:variable name="numPages" select="@numPages" />
    <li style="text-align:center;">
        <span class="plaintext">

            <xsl:if test="@pageNumber &gt; 1">
                <a target="_top" class="PreviousNext" href="{@pagelessUrl}{@pageNumber - 1}"
                 style="margin-right:12px;">&#9668; Previous</a>
            </xsl:if>
    
            <xsl:if test="@numResults!='0'">
                <xsl:call-template name="numberedPageLink">
                    <xsl:with-param name="thisPage" select="1" />
                    <xsl:with-param name="pageNumber" select="@pageNumber" />
                    <xsl:with-param name="numPages" select="@numPages" />
                    <xsl:with-param name="pagelessUrl" select="@pagelessUrl" />
                </xsl:call-template>
            </xsl:if>
    
            <xsl:if test="@pageNumber &lt; @numPages">
                <a target="_top" class="PreviousNext" href="{@pagelessUrl}{@pageNumber + 1}">Next &#9658;</a>
            </xsl:if>
        </span>
    </li> <!-- END paginationBar -->
</xsl:template>

<xsl:template name="numberedPageLink">
    <xsl:param name="thisPage" />
    <xsl:param name="pageNumber" />
    <xsl:param name="numPages" />
    <xsl:param name="pagelessUrl" />

    <a target="_top" href="{@pagelessUrl}{$thisPage}" style="margin-right:12px;">
        <xsl:if test="$thisPage = $pageNumber">
            <xsl:attribute name="class">Active</xsl:attribute>
        </xsl:if>
        <xsl:value-of select="$thisPage" />
    </a>

    <xsl:if test="$numPages != 0">
        <xsl:if test="$thisPage &lt; $numPages">
            <xsl:call-template name="numberedPageLink">
                <xsl:with-param name="thisPage" select="$thisPage + 1" />
                <xsl:with-param name="pageNumber" select="$pageNumber" />
                <xsl:with-param name="numPages" select="$numPages" />
                <xsl:with-param name="pagelessUrl" select="$pagelessUrl" />
            </xsl:call-template>
        </xsl:if>
    </xsl:if>
</xsl:template>

<xsl:template match="SearchResults/*">
    <xsl:apply-templates select="." mode="listitem" />
</xsl:template>

</xsl:stylesheet>
