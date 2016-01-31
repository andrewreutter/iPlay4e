<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" encoding="ISO-8859-1" indent="yes"
 doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
 doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

<xsl:include href="/TIME_TOKEN/xsl/UI.xsl" />

<xsl:template match="sections">
    <html>
        <head>
            <title>iplay4e: <xsl:value-of select="@title" /></title>

            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
            <meta http-equiv="Content-Style-Type" content="text/css" />
            <meta name="viewport" content="user-scalable=no, width=device-width" />

            <link rel="stylesheet" href="/TIME_TOKEN/css/combo.css" type="text/css" media="screen, projection" />
            <link rel="stylesheet" href="/TIME_TOKEN/css/blueprint/print.css" type="text/css" media="print" />
            <!--[if lt IE 8]><link rel="stylesheet" href="/TIME_TOKEN/css/blueprint/ie.css" type="text/css" media="screen, projection" /><![endif]-->

            <script type="text/javascript" language="javscript" src="/TIME_TOKEN/js/combo.js"></script>
            <style>
            body.Page .FAQAnswer a { text-decoration:underline; }
            </style>
        </head>
        <body class="Page" style="overflow:auto;">
            <div id="pagesBar">
                <nobr>
                </nobr>
            </div>
        
            <div id="userBar" width="100%;">
                <nobr>
                    <b id="nicknameDisplay"></b>
                    <xsl:text>&#xA;</xsl:text>
                    <a class="SignInOut last" href="#">Sign In</a>
                </nobr>
            </div>
    
            <div class="container">
                <div class="span-24 last" style="position:relative;">
                        <img id="pageLogo" src="/TIME_TOKEN/images/iPlay4e.Logo.230x50.png" />
                </div>
                <xsl:call-template name="AdBar" />
                <div id="searchBar" class="span-24 last" style="margin-bottom:1em;">
                    <xsl:value-of select="@title" />
                </div>
                <xsl:if test="@TOC='TOC'">
                    <xsl:apply-templates select="." mode="TOC" />
                </xsl:if>
                <xsl:apply-templates select="section" />
                <div class="span-24 last" style="text-align:center;">
                    <a target="terms" href="/terms/">Terms of Use</a>
                    |
                    <a target="privacy" href="/privacy/">Privacy Policy</a>
                </div>
            </div>

        </body>
    </html>
</xsl:template>

<xsl:template match="sections" mode="TOC">
    <div class="span-24 last" style="margin-bottom:1em;">
        <h3>Table of Contents</h3>
        <xsl:apply-templates select="section" mode="TOC" />
    </div>
</xsl:template>

<xsl:template match="section" mode="TOC">
    <a href="#{@linktitle}">
        <b><xsl:value-of select="@title" /></b>
    </a>
    <ul style="margin:0 0 .5em 1.5em;">
        <xsl:apply-templates select="item" mode="TOC" />
    </ul>
</xsl:template>

<xsl:template match="item" mode="TOC">
    <li>
        <xsl:copy-of select="title/node()" />
    </li>
</xsl:template>

<xsl:template match="section">
    <div class="span-24 last" style="margin-bottom:1em;">
        <a name="{@linktitle}" />
        <h3><xsl:value-of select="@title" /></h3>
        <xsl:apply-templates select="item" />
    </div>
</xsl:template>

<xsl:template match="item">
    <div class="FAQQuestion">
        <xsl:copy-of select="title/node()" />
    </div>
    <div class="FAQAnswer">
        <xsl:copy-of select="content/node()" />
    </div>
</xsl:template>

</xsl:stylesheet>
