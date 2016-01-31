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
                <xsl:choose>
                    <xsl:when test="@wikiUrl=''">
                        <div class="span-24 last {@safe-key}OwnerOnly" id="{@key}CampaignTabs">
                            <div class="span-24 CombatantContent last" id="{@key}CampaignTabLinks" style="font-size:1.2em;">
                                <div style="margin-left:8px;">
                                    Please use Google Sites to set up a Site for use as a Wiki.
                                </div>
                                <xsl:apply-templates select="." mode="configWiki" />
                                <div class="{@safe-key}NotOwner" style="display:none; margin-left:8px;">
                                    Please inform the owner of this campaign.
                                </div>
        
                            </div>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <div class="span-24 last" id="{@key}CampaignTabs">
                            <div class="span-24 last" id="{@key}CampaignTabLinks" style="font-size:1.2em;">
                                <div style="margin-left:8px;">
                                    <span class="FAQQuestion">
                                        <u><a target="wiki" href="https://sites.google.com/site/{@wikiUrl}">https://sites.google.com/site/<xsl:value-of select="@wikiUrl" /></a></u>
                                        <span class="{@safe-key}OwnerOnly" style="display:none;">
                                            |
                                            <a style="margin-left:4px;" href="#"
                                             onclick="new Effect.toggle('configWiki', 'blind', {{duration:.3}});return false;"
                                            ><u>Change</u>  <span style="font-size:.7em;">&#9660;</span></a>
                                        </span>
                                    </span>
                                </div>
                                <div id="configWiki" style="display:none;">
                                    <xsl:apply-templates select="." mode="configWiki" />
                                </div>
                            </div>
                            <div class="span-24 CombatantContent last">
                                <iframe name="innerTool" id="innerTool" class="FAQAnswer" src="https://sites.google.com/site/{@wikiUrl}" style="height:500px; width:100%; margin:0; padding:0;">
                                </iframe>
                            </div>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
            <script type="text/javascript" language="javascript">
                $('wikiActivator').addClassName('Active');
            </script>
        </body>
    </html>
</xsl:template>

<xsl:template match="Campaign" mode="configWiki">
                                <div class="{@safe-key}OwnerOnly" style="margin:16px; margin-top:0; display:none;">
                                        <hr style="margin-bottom:8px;"/>
                                        <div class="FAQAnswer">
                                            <form style="margin-0; display:inline;" method="POST" action="/campaigns/save">
                                                https://sites.google.com/site/
                                                <input type="text" name="wikiUrl" value="{@wikiUrl}" width="20" />
                                                <input type="hidden" name="key" value="{@key}"/>
                                                <input type="submit" value="Save" />
                                            </form>
                                        </div>
                                        <div class="FAQAnswer">
                                            <u><a target="googlesites" 
                                                href="https://sites.google.com/site/sites/system/app/pages/meta/dashboard/create-new-site"
                                            >Create a Google Site</a></u>
                                            |
                                            <u><a target="googlesites" href="http://sites.google.com">Google Sites Home</a></u>
                                            |
                                            <form style="margin-0; display:inline;" method="GET" target="googlesites"
                                             action="https://sites.google.com/site/sites/system/app/pages/meta/search">
                                            Search Google Sites:
                                                <input type="text" name="q" />
                                                <input type="hidden" name="scope" value="all" />
                                                <input type="submit" value="Search" />
                                            </form>
                                        </div>
                                </div>
</xsl:template>

</xsl:stylesheet>
