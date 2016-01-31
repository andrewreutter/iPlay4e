<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" encoding="ISO-8859-1" indent="yes"
 doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
 doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

<xsl:template match="Page">
    <html>
    <head>
        <title><xsl:value-of select="@title" /></title>
    
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta http-equiv="Content-Style-Type" content="text/css" />
    
        <link rel="stylesheet" href="/143371090575/css/combo.css" type="text/css" media="screen, projection" />
        <link rel="stylesheet" href="/143371090575/css/blueprint/print.css" type="text/css" media="print" />
        <!--[if lt IE 8]><link rel="stylesheet" href="/143371090575/css/blueprint/ie.css" type="text/css" media="screen, projection" /><![endif]-->
    
        <script type="text/javascript" language="javascript" src="/143371090575/js/combo.js"></script>
        <script type="text/javascript" language="javascript">
            sizeTopToMyContainerOnLoad();
            connectQuestionsToAnswers();
        </script>
    </head>
    
    <body class="Page">
        <div class="container">
            <div class="span-24 last" id="searchBar">
                <div class="FirstLeft">
                    <xsl:value-of select="@title" />
                </div>
            </div>
            <div class="span-24 last prepend-top" style="margin-top:12px;">
                <xsl:copy-of select="Intro/node()" />
            </div>
            <div class="span-24 last prepend-top" style="margin-top:12px;">
                <xsl:apply-templates select="Section" />
            </div>
            <div class="span-24 last" id="paginationBar">
                <xsl:text>&#xA;</xsl:text>
            </div>
        </div>
    </body>
    
    </html>
</xsl:template>

<xsl:template match="Section">
    <div>
        <xsl:choose>
            <xsl:when test="position()=last()">
                <xsl:attribute name="class">span-8 CombatantContent last</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="class">span-8 CombatantContent</xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>

        <h2><xsl:value-of select="@title" /></h2>
        <div class="BragPanelContent">
            <ul>
                <xsl:apply-templates select="Item" />
            </ul>
        </div>
    </div>
</xsl:template>

<xsl:template match="Item">
    <li>
        <xsl:copy-of select="node()" />
    </li>
</xsl:template>

</xsl:stylesheet>
