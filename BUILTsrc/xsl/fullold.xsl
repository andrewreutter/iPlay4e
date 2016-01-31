<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" encoding="ISO-8859-1" indent="yes"
 doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
 doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

<xsl:include href="/143371090575/xsl/UI.xsl" />

<xsl:template match="Campaign">
    <html>
        <xsl:apply-templates select="." mode="header" />
        <body class="CharacterOuterDiv FullPageSheet">
            <div id="{@key}Container" class="{@key}Multiple container" style="text-align:left;">
                <xsl:apply-templates select="." mode="controlBar" />
                <xsl:apply-templates select="." mode="campaignTabLinks" />
                <div class="span-24 last" id="{@key}CampaignTabs">
                    <xsl:apply-templates select="." mode="overviewTab" />
                </div>
            </div>
            <script type="text/javascript" language="javascript">
                var topDoc = null;
                try { topDoc = top.document; } catch (e) { topDoc = null; }
                try { topDoc.title = document.title } catch(e) {}

                $('overviewActivator').addClassName('Active');
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
            <script type="text/javascript" language="javascript" src="/143371090575/js/combo.js"></script>
            <xsl:apply-templates select="." mode="initscript" />
        </head>
        <body class="FullPageSheet">
            <xsl:apply-templates select="." mode="fulloldbody" />
            <script type="text/javascript" language="javascript">
                var topDoc = null;
                try { topDoc = top.document; } catch (e) { topDoc = null; }
                try { topDoc.title = document.title } catch(e) {}
            </script>
        </body>
    </html>
</xsl:template>

<xsl:template name="crap">
    <div class="span-8 CombatantDiv CharacterSections" id="{@key}">
    </div>
</xsl:template>

</xsl:stylesheet>
