<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" encoding="ISO-8859-1" indent="yes"
 doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
 doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

<xsl:include href="/145541695845/xsl/UI.xsl" />

<xsl:template match="SearchResults">
    <html>
    <head>
        <title><xsl:value-of select="@title" /></title>
    
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta http-equiv="Content-Style-Type" content="text/css" />
    
        <link rel="stylesheet" href="/145541695845/css/combo.css" type="text/css" media="screen, projection" />
        <link rel="stylesheet" href="/145541695845/css/blueprint/print.css" type="text/css" media="print" />
        <!--[if lt IE 8]><link rel="stylesheet" href="/145541695845/css/blueprint/ie.css" type="text/css" media="screen, projection" /><![endif]-->
    
        <script type="text/javascript" language="javascript" src="/145541695845/js/combo.js"></script>
        <script type="text/javascript" language="javascript">
            sizeTopToMyContainerOnLoad();
            connectQuestionsToAnswers();
            Event.observe(document, 'dom:loaded', function()
            {   
                pageAuth();
                protectMenusFromIE();
                $$('a.CharacterIframeOpener').each(function(a)
                {
                    a.observe('click', function(e)
                    {   // The very first time it's clicked, we can just note that because we don't have to mess with the URL.
                        if (!this.hasBeenClicked) 
                        {   this.hasBeenClicked = true;
                            return true; 
                        } 
                        if (this.href.indexOf('fullold')==-1) 
                        {   this.href = this.href.replace('combatbar', 'fullold');
                        }
                        else 
                        {   this.href = this.href.replace('fullold', 'combatbar');
                        }
                    }.bindAsEventListener(a));
                });
            } );
        </script>
    </head>
    
    <body class="Page">
        <div class="container ">
            <xsl:apply-templates select="." mode="searchBar" />
            <xsl:call-template name="AdBar" />
            <span class="CharacterIframeDivs">
                <xsl:apply-templates select="*" />
            </span>
            <xsl:if test="@numResults='0'">
                <div class="span-24 last">
                    <xsl:choose>
                        <xsl:when test="contains(@pagelessUrl, '/characters')">
                            <p style="margin-top:30px;">You don't have any characters yet.<br/>
                            Use the "New" link to turn your <i>.dnd4e</i> files into iPlay4e characters.</p>
                        </xsl:when>
                        <xsl:when test="contains(@pagelessUrl, 'campaign=')">
                            <p style="margin-top:30px;">There aren't any characters in this campaign yet.<br/>
                            You can add some using the link above.</p>
                        </xsl:when>
                        <xsl:when test="contains(@pagelessUrl, '/campaigns')">
                            <p style="margin-top:30px;">You don't have any campaigns yet.<br/>
                            Use the "New" link to create a new campaign and invite your friends.</p>
                        </xsl:when>
                        <xsl:otherwise>
                            <p style="margin-top:30px;">Sorry, but your search didn't generate any results.<br/>
                            You might want to have a look at the <a href="/help#search">search instructions</a>.</p>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
            </xsl:if>
            <xsl:apply-templates select="." mode="paginationBar" />
        </div>
    </body>
    </html>
</xsl:template>

<xsl:template match="SearchResults" mode="searchBar">
    <div id="searchBar" class="span-24 last">
        <div class="span-12">
            <div class="FirstLeft">
                <xsl:value-of select="@title" />
                <xsl:if test="@numResults!='0'">
                    <xsl:call-template name="masterControlIcons" />
                </xsl:if>
            </div>
        </div>
        <div class="span-12 last">
            <div class="LastRight">
                <xsl:choose>
                    <xsl:when test="@numResults='0'">
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        Results
                        <b>
                            <xsl:value-of select="@firstOnPage" />
                            -
                            <xsl:value-of select="@lastOnPage" />
                        </b>
                        of
                        <xsl:value-of select="@numResults" />
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>
    </div> <!-- END searchBar -->
</xsl:template>

<xsl:template match="SearchResults" mode="paginationBar">
    <xsl:variable name="numPages" select="@numPages" />
    <div id="paginationBar" class="span-24 last" style="text-align:center;">

        <xsl:if test="@pageNumber &gt; 1">
            <a target="_top" class="PreviousNext" href="{@pagelessUrl}{@pageNumber - 1}">&#9668; Previous</a>
                <xsl:text>&#xA;</xsl:text>
        </xsl:if>

        <xsl:if test="@numPages!='1'">
            <xsl:if test="@numResults!='0'">
                <xsl:call-template name="numberedPageLink">
                    <xsl:with-param name="thisPage" select="1" />
                    <xsl:with-param name="pageNumber" select="@pageNumber" />
                    <xsl:with-param name="numPages" select="@numPages" />
                    <xsl:with-param name="pagelessUrl" select="@pagelessUrl" />
                </xsl:call-template>
            </xsl:if>
        </xsl:if>

        <xsl:if test="@pageNumber &lt; @numPages">
            <a target="_top" class="PreviousNext" href="{@pagelessUrl}{@pageNumber + 1}">Next &#9658;</a>
        </xsl:if>
    </div> <!-- END paginationBar -->
</xsl:template>

<xsl:template name="numberedPageLink">
    <xsl:param name="thisPage" />
    <xsl:param name="pageNumber" />
    <xsl:param name="numPages" />
    <xsl:param name="pagelessUrl" />

    <a target="_top" href="{@pagelessUrl}{$thisPage}">
        <xsl:if test="$thisPage = $pageNumber">
            <xsl:attribute name="class">Active</xsl:attribute>
        </xsl:if>
        <xsl:value-of select="$thisPage" />
    </a>
    <xsl:text>&#xA;</xsl:text>

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
    <span class="SearchResult" id="{@key}result">
        <xsl:apply-templates select="." mode="controlBar" />
        <script type="text/javascript" language="javascript">
        Event.observe(document, 'dom:loaded', function()
        {   
            var thisKey = '<xsl:value-of select="@key" />';
            var safeKey = '<xsl:value-of select="@safe-key" />';
            var isOwner = '<xsl:value-of select="@isOwner" />';
            var classNameToShow = '#' + thisKey + 'result .' + safeKey + ((isOwner=='True') ? 'OwnerOnly' : 'NotOwner');
            $$(classNameToShow).invoke('show');
        });
        </script>
    </span>
</xsl:template>

<xsl:template match="SearchResults/*" mode="controlBar">
    <xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable> 
    <xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
    <div class="span-24 last CombatantDiv prepend-top" style="text-align:right;margin-top:1.75em;">
        <div class="CombatantHeader" style="float:left;">
            <a class="CharacterIframeOpener" href="/{translate(name(), $upper, $lower)}s/{@key}" target="_top">
                <!-- Enable expanding characters in a view of a campaign -->
                <xsl:if test="contains(../@pagelessUrl, 'campaign=')">
                    <xsl:attribute name="target"><xsl:value-of select="@key" />frame</xsl:attribute>
                    <xsl:attribute name="href">/view?xsl=fullold&amp;key=<xsl:value-of select="@key" /></xsl:attribute>
                </xsl:if>
                <u>
                    <span class="title"><xsl:value-of select="@title" /></span>
                </u>
                <xsl:if test="contains(../@pagelessUrl, 'campaign=')">
                    <small>&#9660;</small>
                </xsl:if>
            </a>
            <span class="SearchResultMenuLinks">
                <xsl:apply-templates select="." mode="controlIcons" />
            </span>
        </div>
        <span class="CombatantHeader ResultSubtitle" style="font-size:1.25em;white-space:nowrap;position:relative;">
            <xsl:apply-templates select="." mode="subtitle" />
        </span>
    </div>
</xsl:template>

</xsl:stylesheet>
