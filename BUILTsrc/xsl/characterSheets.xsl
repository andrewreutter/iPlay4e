<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" encoding="ISO-8859-1" indent="yes"
 doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
 doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

<xsl:include href="/145541695845/xsl/UI.xsl" />

<xsl:template match="MultipleKeys">
    <xsl:variable name="keyList">
        <xsl:call-template name="join">
            <xsl:with-param name="valueList" select="Character/@key"/>
            <xsl:with-param name="separator" select="','"/>
        </xsl:call-template>
    </xsl:variable>
    <html>
        <head>
            <title><xsl:value-of select="Campaign/@name" /> - iplay4e</title>
            <xsl:apply-templates select="." mode="metatags" />
            <xsl:apply-templates select="." mode="cssfiles" />
            <script type="text/javascript" language="javascript" src="/145541695845/js/combo.js"></script>
            <!-- <xsl:apply-templates select="." mode="initscript" /> -->
            <script type="text/javascript" language="javascript">
                connectQuestionsToAnswers();
                Event.observe(document, 'dom:loaded', function() 
                {   
                    sizeParentIframeToMyContainer();
                    pageAuth();
                    initializeCampaign('<xsl:value-of select="Campaign/@key" />', '<xsl:value-of select="Campaign/@safe-key" />');
                    <xsl:for-each select="Character">
                        var safeKey = '<xsl:value-of select="@safe-key" />';
                        var charKey = '<xsl:value-of select="@key" />';
                        initializeCharacter(charKey, safeKey, {noServer:true});
                    </xsl:for-each>
                    var keyList = '<xsl:value-of select="$keyList" />';
                    initializeCharacters(keyList);
                    protectMenusFromIE();
                } );
            </script>
        </head>
        <body class="FullPageSheet">
            <xsl:for-each select="Campaign">
                <div id="{@key}Container" class="{@key}Multiple container" style="text-align:left;">
                    <xsl:apply-templates select="." mode="controlBar" />
                    <xsl:apply-templates select="." mode="campaignTabLinks" />
                    <script type="text/javascript" language="javascript">
                        $('characterSheetsActivator').addClassName('Active');
                    </script>
                    <div class="span-24 last CharacterOuterDiv">
                        <div class="span-24 CombatantContent last CharacterTabLinks" id="campaignTabLinks">
                            <h2 style="font-size:.9em;">
                                <span>
                                    Party Health
                                </span>
                                <xsl:for-each select="../Character">
                                    <span>
                                        <xsl:value-of select="@name" />
                                    </span>
                                </xsl:for-each>
                                <div class="IconHolder" style="display:inline;"><!-- because spans are switchers -->
                                    <a href="#" class="IconLink" style="text-decoration:none;"
                                     onclick="viewAllCharacters('fullold', {{newWindows:true}});return false;">
                                        <img src="/145541695845/images/eye.png" />
                                        <u>Open in separate windows</u>
                                    </a>
                                </div>
                            </h2>
                        </div>
                        <div class="span-24 last" id="CampaignTabs">
                            <div class="span-24 last CampaignTabContent" style="display:none;">
                                <xsl:for-each select="../Character">
                                    <div class="{@key}Multiple">
                                        <div class="span-24 last CombatantDiv ControlBar">
                                            <div class="span-24 CombatantHeader" style="z-index:999;">
                                                <span class="title">
                                                    <xsl:value-of select="@name" />
                                                </span>
                                            </div>
                                        </div>
                                        <xsl:apply-templates select="." mode="combatBar2" />
                                    </div>
                                </xsl:for-each>
                            </div>
                            <xsl:for-each select="../Character">
                                <div class="span-24 last CampaignTabContent" style="display:none;">
                                    <xsl:apply-templates select="." mode="fulloldbody" />
                                </div>
                            </xsl:for-each>
                        </div>
                        <script type="text/javascript" language="javascript">
                            var linksInThisId = $$('#campaignTabLinks h2 span');
                            document.activateLink = function(e, i)
                            {   
                                var linksInThisId = $$('#campaignTabLinks h2 span');
                                var contentDivsInThisId = $('CampaignTabs').childElements();
                
                                var linkIndex = (!e) ? i : linksInThisId.indexOf(e.element());
                                linksInThisId.invoke('removeClassName', 'Active');
                                linksInThisId[linkIndex].addClassName('Active');
                
                                contentDivsInThisId.invoke('hide');
                                var thisContentDiv = contentDivsInThisId[linkIndex];
                                thisContentDiv.show();
    
                                // Some divs need to have their content panels made the same height.
                                if (thisContentDiv.hasClassName('EqualHeightDivs'))
                                    makeDivsEqualHeight(thisContentDiv.select('.CharacterSectionContent'));
                                sizeParentIframeToMyContainer();
                            };
                            linksInThisId.invoke('observe', 'click', document.activateLink);
    
                            document.getKeyIndex = function(theKey)
                            {
                                var keyList = '<xsl:value-of select="$keyList" />';
                                return keyList.split(',').indexOf(theKey) + 1;
                            };
                            var innerKey = EwgCookie.getCookie('innerKey', '');
                            activeTabIndex = Math.max(0, (innerKey ? document.getKeyIndex(innerKey) : 0));
    
                            document.activateLink(null, activeTabIndex);
    
                            viewAllCharacters = function(styleSheet, options)
                            {   var options = options || {};
        
                                <xsl:for-each select="../Character">
                                    var thisKey = '<xsl:value-of select="@key" />';
                                    var theUrl = '/view?key=' + thisKey + '&amp;xsl=' + styleSheet;
                                    if (options.newWindows)
                                    {   window.open(theUrl, thisKey, options.windowOptions || '');
                                    }
                                    else
                                    {   $(thisKey+'frame').src = theUrl;
                                    }
                                </xsl:for-each>
                            };
                        </script>
                    </div>
                </div>
            </xsl:for-each>
            <div class="PowerContent leightbox" id="lightboxCompendium">
                <iframe name="compendiumBrowser" class="CompendiumBrowser" src="/fullpageInstructions.html" style="padding:0;" frameborder="no"></iframe>
            </div>
        </body>
    </html>
</xsl:template>


</xsl:stylesheet>
