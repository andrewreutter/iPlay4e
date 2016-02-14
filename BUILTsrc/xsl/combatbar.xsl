<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" encoding="ISO-8859-1" indent="yes"
 doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
 doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

<xsl:include href="/145541695845/xsl/UI.xsl" />

<xsl:template match="Campaign">
    <html>
    <head>
        <title><xsl:value-of select="@name" /> - iplay4e</title>
        <xsl:apply-templates select="." mode="metatags" />
        <xsl:apply-templates select="." mode="cssfiles" />
        <script type="text/javascript" language="javascript" src="/145541695845/js/combo.js"></script>
        <script type="text/javascript" language="javascript">
            connectQuestionsToAnswers();
            Event.observe(document, 'dom:loaded', function() 
            {   
                pageAuth();
                protectMenusFromIE();
            } );
        </script>
    </head>
        <body class="CharacterOuterDiv FullPageSheet">
            <div id="{@key}Container" class="container" style="text-align:left;">
                <xsl:apply-templates select="." mode="controlBar" />
                <div class="span-24 last" id="{@key}CampaignTabs">
                    <xsl:apply-templates select="." mode="overviewTab" />
                </div>
            </div>
            <script type="text/javascript" language="javascript">
                var contextId = '<xsl:value-of select="@key" />';
                $(contextId + 'CampaignTabs').childElements()[0].setStyle({height:'auto'});
            </script>
        </body>
    </html>
</xsl:template>

<xsl:template match="Character">
    <html>
        <head>
            <title><xsl:value-of select="@name" /> - iplay4e</title>
            <xsl:apply-templates select="." mode="metatags" />
            <xsl:apply-templates select="." mode="cssfiles" />
            <script type="text/javascript" language="javascript" src="/145541695845/js/combo.js"></script>
            <xsl:apply-templates select="." mode="initscript" />
        </head>
        <body class="FullPageSheet">
            <div id="{@key}" class="CharacterOuterDiv">
                <div class="container ">
                    <xsl:apply-templates select="." mode="controlBar" />
                    <xsl:apply-templates select="." mode="combatBar" />
                </div>
            </div>
        </body>
    </html>
</xsl:template>


</xsl:stylesheet>
