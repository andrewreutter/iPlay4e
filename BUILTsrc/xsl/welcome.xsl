<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" encoding="ISO-8859-1" indent="yes"
 doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
 doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>


<xsl:include href="/143371090575/xsl/UI.xsl" />

<xsl:template match="Welcome">
    <html>
    <head>
        <title><xsl:value-of select="@title" /></title>
    
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta http-equiv="Content-Style-Type" content="text/css" />
    
        <link rel="stylesheet" href="/143371090575/css/combo.css" type="text/css" media="screen, projection" />
        <link rel="stylesheet" href="/143371090575/css/blueprint/print.css" type="text/css" media="print" />
        <!--[if lt IE 8]><link rel="stylesheet" href="/143371090575/css/blueprint/ie.css" type="text/css" media="screen, projection" /><![endif]-->
    
        <script type="text/javascript" language="javascript" src="/143371090575/js/combo.js"></script>
    
    </head>
    
    <body class="Page">
        <div class="container ">
            <xsl:apply-templates select="." mode="searchBar" />
            <xsl:call-template name="AdBar" />
            <xsl:apply-templates select="." mode="paginationBar" />
        </div>
    </body>
    </html>
</xsl:template>

<xsl:template match="Welcome" mode="searchBar">
    <div id="searchBar" class="span-24 last">
        <div class="span-24 last" style="text-align:center;">
            Welcome to iPlay4e
        </div>
    </div> <!-- END searchBar -->
</xsl:template>

<xsl:template match="Welcome" mode="paginationBar">
    <div id="paginationBar" class="span-24 last" style="text-align:center;">
        <xsl:text>&#xA;</xsl:text>
    </div> <!-- END paginationBar -->
</xsl:template>

</xsl:stylesheet>
