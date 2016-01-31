<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" encoding="ISO-8859-1" indent="yes"
 doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
 doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

<xsl:include href="/TIME_TOKEN/xsl/UI.xsl" />

<xsl:template match="Campaign">
    <html>
        <xsl:apply-templates select="." mode="header" />
        <body class="CharacterOuterDiv FullPageSheet">
            <div id="{@key}Container" class="{@key}Multiple container" style="text-align:left;">
                <xsl:apply-templates select="." mode="controlBar" />
                <xsl:apply-templates select="." mode="campaignTabLinks" />
                <div class="span-24 last" id="{@key}CampaignTabs">
                    <xsl:apply-templates select="." mode="inCombatTab" />
                </div>
            </div>
            <script type="text/javascript" language="javascript">
                $('inCombatActivator').addClassName('Active');
            </script>
        </body>
    </html>
</xsl:template>

<xsl:template name="crap">
    <div class="span-8 CombatantDiv CharacterSections" id="{@key}">
    </div>
</xsl:template>

</xsl:stylesheet>
