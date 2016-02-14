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
                    <xsl:for-each select="Character">
                        var safeKey = '<xsl:value-of select="@safe-key" />';
                        var charKey = '<xsl:value-of select="@key" />';
                        initializeCharacter(charKey, safeKey, {noServer:true});
                    </xsl:for-each>
                    var keyList = '<xsl:value-of select="$keyList" />';
                    initializeCharacters(keyList);
                } );
            </script>
            <style>
                .SkillHeatmapRow .Roller { margin-right:-4px; -webkit-box-shadow:none;}
                .AbilityHeatmapRow .Roller {margin-left:2px;}
                #CampaignTabs .CampaignTabContent { margin-top:10px; }
                #CampaignTabs .CampaignTabContent h2 { overflow:hidden; }
                #CampaignTabs .CampaignTabContent .CombatantContent { margin-top:0; margin-bottom:0; }
                #CampaignTabs .CampaignTabContent .CombatantContent table { margin-bottom:0; }
            </style>
        </head>
        <body class="CharacterOuterDiv">
            <div class="container ">
                <div class="span-24 last CharacterOuterDiv" style="font-size:.9em;">
                    <div class="span-24 CombatantContent last CharacterTabLinks" id="campaignTabLinks">
                        <h2 style="font-size:.9em;">
                            <span class="Active">Combat</span>
                            <span style="margin-right:25px;">Build</span>
                            <span>Langs &amp; Profs</span>
                            <span style="margin-right:25px;">Feats</span>
                            <span style="margin-right:25px;">Powers</span>
                            <span>Notes</span>
                            <span>Appearance</span>
                            <span>Traits</span>
                            <span style="margin-right:25px;">Companions</span>
                            <span>Magic Items</span>
                            <span style="margin-right:25px;">Rituals</span>
                            <span>Equipment</span>
                            <span style="margin-right:25px;">Money</span>
                            <span>Skills &amp; Abilities</span>
                        </h2>
                    </div>
                    <div class="span-24 last" id="CampaignTabs">
                        <div class="span-24 last CampaignTabContent">
                            <xsl:for-each select="Character">
                                <div class="{@safe-key}Multiple">
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
                        <div class="span-24 last CampaignTabContent EqualHeightDivs" style="display:none;">
                            <xsl:apply-templates select="Character" mode="build" />
                        </div>
                        <div class="span-24 last CampaignTabContent EqualHeightDivs" style="display:none;font-size:.9em;">
                            <xsl:apply-templates select="Character" mode="langsAndProfs" />
                        </div>
                        <div class="span-24 last CampaignTabContent EqualHeightDivs" style="display:none;font-size:.9em;">
                            <xsl:apply-templates select="Character" mode="feats" />
                        </div>
                        <div class="span-24 last CampaignTabContent EqualHeightDivs" style="display:none;font-size:.9em;">
                            <xsl:apply-templates select="Character" mode="powers" />
                        </div>
                        <div class="span-24 last CampaignTabContent" style="display:none;">
                            <xsl:apply-templates select="Character" mode="notes" />
                        </div>
                        <div class="span-24 last CampaignTabContent" style="display:none;">
                            <xsl:apply-templates select="Character" mode="appearance" />
                        </div>
                        <div class="span-24 last CampaignTabContent" style="display:none;">
                            <xsl:apply-templates select="Character" mode="traits" />
                        </div>
                        <div class="span-24 last CampaignTabContent" style="display:none;">
                            <xsl:apply-templates select="Character" mode="companions" />
                        </div>
                        <div class="span-24 last CampaignTabContent EqualHeightDivs" style="display:none;font-size:.9em;">
                            <xsl:apply-templates select="Character" mode="magicItems" />
                        </div>
                        <div class="span-24 last CampaignTabContent EqualHeightDivs" style="display:none;font-size:.9em;">
                            <xsl:apply-templates select="Character" mode="rituals" />
                        </div>
                        <div class="span-24 last CampaignTabContent EqualHeightDivs" style="display:none;font-size:.9em;" >
                            <xsl:apply-templates select="Character" mode="loot" />
                        </div>
                        <div class="span-24 last CampaignTabContent" style="display:none;background:white;">
                            <xsl:apply-templates select="Character/Loot" mode="money" />
                        </div>
                        <div class="span-24 last CampaignTabContent" style="display:none;background:white;" id="skillsMatrix">
                            <xsl:apply-templates select="Character" mode="skill" />
                            <script type="text/javascript" language="javascript">
                                makeHeatmap('#skillsMatrix .SkillHeatmap .Roller', '#skillsMatrix .SkillHeatmap .SkillHeatmapRow');
                                makeHeatmap('#skillsMatrix .AbilityHeatmap .Roller', '#skillsMatrix .AbilityHeatmap .AbilityHeatmapRow');
                            </script>
                        </div>
                    </div>
                    <script type="text/javascript" language="javascript">
                        var keyList = '<xsl:value-of select="$keyList" />';
                        var linksInThisId = $$('#campaignTabLinks h2 span');
                        linksInThisId.invoke('observe', 'click', function(e)
                        {   
                            var linksInThisId = $$('#campaignTabLinks h2 span');
                            var contentDivsInThisId = $('CampaignTabs').childElements();
            
                            var linkIndex = linksInThisId.indexOf(e.element());
                            linksInThisId.invoke('removeClassName', 'Active');
                            linksInThisId[linkIndex].addClassName('Active');
            
                            contentDivsInThisId.invoke('hide');
                            var thisContentDiv = contentDivsInThisId[linkIndex];
                            thisContentDiv.show();

                            // Some divs need to have their content panels made the same height.
                            if (thisContentDiv.hasClassName('EqualHeightDivs'))
                                makeDivsEqualHeight(thisContentDiv.select('.CharacterSectionContent'));
                            sizeParentIframeToMyContainer();
                        });
                    </script>
                </div>
            </div>
            <xsl:apply-templates select="." mode="helpDiv" />
            <xsl:for-each select="Character">
                <div class="{@safe-key}Multiple CombatantContent CompendiumBrowserDiv" style="-webkit-box-shadow:none; border:none;height:auto;">
                    <xsl:apply-templates select="Build/*" mode="div" />
                    <xsl:apply-templates select="Skills/Skill" mode="div" />
                    <xsl:apply-templates select="Feats/Feat" mode="div" />
                    <xsl:apply-templates select="Loot/Item" mode="div" />
                    <xsl:apply-templates select="Powers/Power[starts-with(@actiontype, 'Immediate Reaction')]" mode="div" />
                    <xsl:apply-templates select="Powers/Power[starts-with(@actiontype, 'Immediate Interrupt')]" mode="div" />
                    <xsl:apply-templates select="Powers/Power[starts-with(@actiontype, 'Opportunity Action')]" mode="div" />
                    <xsl:apply-templates select="Powers/Power[starts-with(@actiontype, 'No Action')]" mode="div" />
                    <xsl:apply-templates select="Powers/Power[starts-with(@actiontype, 'Free Action')]" mode="div" />
                    <xsl:apply-templates select="Powers/Power[starts-with(@actiontype, 'Minor Action')]" mode="div" />
                    <xsl:apply-templates select="Powers/Power[starts-with(@actiontype, 'Move Action')]" mode="div" />
                    <xsl:apply-templates select="Powers/Power[starts-with(@actiontype, 'Standard Action')]" mode="div" />
                    <xsl:call-template name="helpDiv" />
                </div>
            </xsl:for-each>
        </body>
    </html>
</xsl:template>

<xsl:template match="MultipleKeys/Character" mode="skill">
<div class="{@safe-key}Multiple">
    <xsl:if test="position() mod 11 = 1">
        <div style="position:relative;"
            class="span-2 CombatantContent">
            <h2>Skill</h2>
            <div class="CharacterSectionContent" style="height:auto;overflow:visible;font-size:.9em;">
                <table style="margin:0;">
                    <xsl:for-each select="Skills/Skill">
                        <tr>
                            <xsl:apply-templates select="." mode="listitemLabel" />
                        </tr>
                        <xsl:if test="position() mod 3 = 0">
                            <tr>
                                <td style="height:1px;">
                                    <hr style="border-bottom:1px solid #BBB; width:950px;margin:0;position:relative;left:-6px;" />
                                </td>
                            </tr>
                        </xsl:if>
                    </xsl:for-each>
                </table>
            </div>
            <h2 style="margin-top:13px;">Ability</h2>
            <div class="CharacterSectionContent" style="height:auto;overflow:visible;font-size:.9em;">
                <table style="margin:0;">
                    <xsl:for-each select="AbilityScores/AbilityScore">
                        <tr>
                            <xsl:apply-templates select="." mode="listitemLabel" />
                        </tr>
                        <xsl:if test="position() = 3">
                            <tr>
                                <td style="height:1px;">
                                    <hr style="border-bottom:1px solid #BBB; width:950px;margin:0;position:relative;left:-6px;" />
                                </td>
                            </tr>
                        </xsl:if>
                    </xsl:for-each>
                </table>
            </div>
        </div>
    </xsl:if>
    <div style="position:relative; background:transparent; -webkit-box-shadow:none; border:none;">
        <xsl:attribute name="class">
            span-2 CombatantContent
            <xsl:value-of select="@key" />Multiple
            <xsl:if test="position() mod 11 = 0">last</xsl:if>
        </xsl:attribute>
        <h2 style="background:inherit;color:black;text-align:center;">
            <xsl:value-of select="@name" />
        </h2>
        <div class="CharacterSectionContent" 
         style="height:auto;overflow:hidden;font-size:.9em;padding-right:20px;">
            <table style="margin-right:20px;" class="SkillHeatmap">
                <xsl:for-each select="Skills/Skill">
                    <tr class="SkillHeatmapRow">
                        <xsl:apply-templates select="." mode="listitemValue" />
                    </tr>
                    <xsl:if test="position() mod 3 = 0">
                        <tr>
                            <td style="height:1px;"><hr style="border-bottom:1px solid #BBB; width:1px;margin:0;" /></td>
                        </tr>
                    </xsl:if>
            </xsl:for-each>
            </table>
        </div>
        <h2 style="overflow:hidden;background:inherit;color:black;text-align:center;margin-top:13px;">
            <xsl:value-of select="@name" />
        </h2>
        <div class="CharacterSectionContent" 
         style="height:auto;overflow:hidden;font-size:.9em;padding-right:20px;position:relative;">
            <table cellpadding="0" cellspacing="0" style="font-size:1.3em;width:160%;" class="AbilityHeatmap">
                <xsl:for-each select="AbilityScores/AbilityScore">
                    <tr class="AbilityHeatmapRow">
                        <xsl:apply-templates select="." mode="listitemValue" />
                    </tr>
                    <xsl:if test="position() = 3">
                        <tr>
                            <td style="height:1px;"><hr style="border-bottom:1px solid #BBB; width:1px;margin:0;" /></td>
                        </tr>
                    </xsl:if>
                </xsl:for-each>
            </table>
        </div>
    </div>
</div>
</xsl:template>

<xsl:template match="MultipleKeys/Character/Loot" mode="money">
<div class="{../@safe-key}Multiple">
    <xsl:if test="position() mod 7 = 1">
        <xsl:if test="position() != 1">
            <p style="height:4px;clear:both;"/> <!-- keeps the first one in each row left-aligned -->
        </xsl:if>
        <div style="position:relative;"
            class="span-3 CombatantContent">
            <h2>Carried</h2>
            <div class="CharacterSectionContent" style="height:auto;overflow:visible;">
                <table style="margin:0;">
                    <tr><td style="padding:0;height:20px;">Astral Diamonds</td></tr>
                    <tr><td style="padding:0;height:20px;">Platinum Pieces</td></tr>
                    <tr><td style="padding:0;height:20px;">Gold Pieces</td></tr>
                    <tr><td style="padding:0;height:20px;">Silver Pieces</td></tr>
                    <tr><td style="padding:0;height:20px;">Copper Pieces</td></tr>
                </table>
            </div>
            <h2 style="margin-top:13px;">Stored</h2>
            <div class="CharacterSectionContent" style="height:auto;overflow:visible;">
                <table style="margin:0;">
                    <tr><td style="padding:0;height:20px;">Astral Diamonds</td></tr>
                    <tr><td style="padding:0;height:20px;">Platinum Pieces</td></tr>
                    <tr><td style="padding:0;height:20px;">Gold Pieces</td></tr>
                    <tr><td style="padding:0;height:20px;">Silver Pieces</td></tr>
                    <tr><td style="padding:0;height:20px;">Copper Pieces</td></tr>
                </table>
            </div>
        </div>
    </xsl:if>
    <div style="position:relative; background:transparent; -webkit-box-shadow:none; border:none;">
        <xsl:attribute name="class">
            span-3 CombatantContent
            <xsl:value-of select="../@key" />Multiple
            <xsl:if test="position() mod 7 = 0">last</xsl:if>
        </xsl:attribute>
        <h2 style="overflow:hidden;background:inherit;color:black;">
            <xsl:value-of select="../@name" />
        </h2>
        <div class="CharacterSectionContent" 
         style="height:auto;overflow:hidden;padding-right:20px;">
            <table style="margin-right:20px;">
                <tr><td style="padding:0;height:20px;">
                    <a style="display:none;" class="{@safe-key}EditorOnly Button SecondaryButton" onclick="{@carried-ad-subtract-script}">-</a>
                    <a style="display:none;" class="{@safe-key}EditorOnly Button SecondaryButton" onclick="{@carried-ad-add-script}">+</a>
                    <span class="{@carried-ad-display-class}"><xsl:value-of select="@carried-ad" /></span>
                </td></tr>
                <tr><td style="padding:0;height:20px;">
                    <a style="display:none;" class="{@safe-key}EditorOnly Button SecondaryButton" onclick="{@carried-pp-subtract-script}">-</a>
                    <a style="display:none;" class="{@safe-key}EditorOnly Button SecondaryButton" onclick="{@carried-pp-add-script}">+</a>
                    <span class="{@carried-pp-display-class}"><xsl:value-of select="@carried-pp" /></span>
                </td></tr>
                <tr><td style="padding:0;height:20px;">
                    <a style="display:none;" class="{@safe-key}EditorOnly Button SecondaryButton" onclick="{@carried-gp-subtract-script}">-</a>
                    <a style="display:none;" class="{@safe-key}EditorOnly Button SecondaryButton" onclick="{@carried-gp-add-script}">+</a>
                    <span class="{@carried-gp-display-class}"><xsl:value-of select="@carried-gp" /></span>
                </td></tr>
                <tr><td style="padding:0;height:20px;">
                    <a style="display:none;" class="{@safe-key}EditorOnly Button SecondaryButton" onclick="{@carried-sp-subtract-script}">-</a>
                    <a style="display:none;" class="{@safe-key}EditorOnly Button SecondaryButton" onclick="{@carried-sp-add-script}">+</a>
                    <span class="{@carried-sp-display-class}"><xsl:value-of select="@carried-sp" /></span>
                </td></tr>
                <tr><td style="padding:0;height:20px;">
                    <a style="display:none;" class="{@safe-key}EditorOnly Button SecondaryButton" onclick="{@carried-cp-subtract-script}">-</a>
                    <a style="display:none;" class="{@safe-key}EditorOnly Button SecondaryButton" onclick="{@carried-cp-add-script}">+</a>
                    <span class="{@carried-cp-display-class}"><xsl:value-of select="@carried-cp" /></span>
                </td></tr>
            </table>
        </div>
        <h2 style="overflow:hidden;background:inherit;color:black;margin-top:13px;">
            <xsl:value-of select="../@name" />
        </h2>
        <div class="CharacterSectionContent" 
         style="height:auto;overflow:hidden;padding-right:20px;position:relative;">
            <table style="margin-right:20px;">
                <tr><td style="padding:0;height:20px;">
                    <a style="display:none;" class="{@safe-key}EditorOnly Button SecondaryButton" onclick="{@stored-ad-subtract-script}">-</a>
                    <a style="display:none;" class="{@safe-key}EditorOnly Button SecondaryButton" onclick="{@stored-ad-add-script}">+</a>
                    <span class="{@stored-ad-display-class}"><xsl:value-of select="@stored-ad" /></span>
                </td></tr>
                <tr><td style="padding:0;height:20px;">
                    <a style="display:none;" class="{@safe-key}EditorOnly Button SecondaryButton" onclick="{@stored-pp-subtract-script}">-</a>
                    <a style="display:none;" class="{@safe-key}EditorOnly Button SecondaryButton" onclick="{@stored-pp-add-script}">+</a>
                    <span class="{@stored-pp-display-class}"><xsl:value-of select="@stored-pp" /></span>
                </td></tr>
                <tr><td style="padding:0;height:20px;">
                    <a style="display:none;" class="{@safe-key}EditorOnly Button SecondaryButton" onclick="{@stored-gp-subtract-script}">-</a>
                    <a style="display:none;" class="{@safe-key}EditorOnly Button SecondaryButton" onclick="{@stored-gp-add-script}">+</a>
                    <span class="{@stored-gp-display-class}"><xsl:value-of select="@stored-gp" /></span>
                </td></tr>
                <tr><td style="padding:0;height:20px;">
                    <a style="display:none;" class="{@safe-key}EditorOnly Button SecondaryButton" onclick="{@stored-sp-subtract-script}">-</a>
                    <a style="display:none;" class="{@safe-key}EditorOnly Button SecondaryButton" onclick="{@stored-sp-add-script}">+</a>
                    <span class="{@stored-sp-display-class}"><xsl:value-of select="@stored-sp" /></span>
                </td></tr>
                <tr><td style="padding:0;height:20px;">
                    <a style="display:none;" class="{@safe-key}EditorOnly Button SecondaryButton" onclick="{@stored-cp-subtract-script}">-</a>
                    <a style="display:none;" class="{@safe-key}EditorOnly Button SecondaryButton" onclick="{@stored-cp-add-script}">+</a>
                    <span class="{@stored-cp-display-class}"><xsl:value-of select="@stored-cp" /></span>
                </td></tr>
            </table>
        </div>
    </div>
</div>
</xsl:template>

<xsl:template match="MultipleKeys/Character" mode="magicItems">
<div class="{@safe-key}Multiple">
    <xsl:if test="position() mod 8 = 1">
        <xsl:if test="position() != 1">
            <p style="height:4px;clear:both;"/> <!-- keeps the first one in each row left-aligned -->
        </xsl:if>
    </xsl:if>
    <div style="position:relative;">
        <xsl:attribute name="class">
            span-3 CombatantContent
            <xsl:value-of select="@key" />Multiple
            <xsl:if test="position() mod 8 = 0">last</xsl:if>
        </xsl:attribute>
        <h2>
            <xsl:value-of select="@name" />
        </h2>
        <div class="CharacterSectionContent" style="height:auto;overflow:hidden;">
            <xsl:apply-templates select="Loot" mode="magicItemsDiv" />
        </div>
    </div>
</div>
</xsl:template>

<xsl:template match="MultipleKeys/Character" mode="rituals">
<div class="{@safe-key}Multiple">
    <xsl:if test="position() mod 8 = 1">
        <xsl:if test="position() != 1">
            <p style="height:4px;clear:both;"/> <!-- keeps the first one in each row left-aligned -->
        </xsl:if>
    </xsl:if>
    <div style="position:relative;">
        <xsl:attribute name="class">
            span-3 CombatantContent
            <xsl:value-of select="@key" />Multiple
            <xsl:if test="position() mod 8 = 0">last</xsl:if>
        </xsl:attribute>
        <h2>
            <xsl:value-of select="@name" />
        </h2>
        <div class="CharacterSectionContent" style="height:auto;overflow:hidden;">
            <xsl:apply-templates select="Loot" mode="ritualsDiv" />
        </div>
    </div>
</div>
</xsl:template>

<xsl:template match="MultipleKeys/Character" mode="loot">
<div class="{@safe-key}Multiple">
    <xsl:if test="position() mod 8 = 1">
        <xsl:if test="position() != 1">
            <p style="height:4px;clear:both;"/> <!-- keeps the first one in each row left-aligned -->
        </xsl:if>
    </xsl:if>
    <div style="position:relative;">
        <xsl:attribute name="class">
            span-3 CombatantContent
            <xsl:value-of select="@key" />Multiple
            <xsl:if test="position() mod 8 = 0">last</xsl:if>
        </xsl:attribute>
        <h2>
            <xsl:value-of select="@name" />
        </h2>
        <div class="CharacterSectionContent" style="height:auto;overflow:hidden;">
            <xsl:apply-templates select="Loot" mode="lootDiv" />
        </div>
    </div>
</div>
</xsl:template>

<xsl:template match="MultipleKeys/Character" mode="feats">
<div class="{@safe-key}Multiple">
    <xsl:if test="position() mod 8 = 1">
        <xsl:if test="position() != 1">
            <p style="height:4px;clear:both;"/> <!-- keeps the first one in each row left-aligned -->
        </xsl:if>
    </xsl:if>
    <div style="position:relative;">
        <xsl:attribute name="class">
            span-3 CombatantContent
            <xsl:value-of select="@key" />Multiple
            <xsl:if test="position() mod 8 = 0">last</xsl:if>
        </xsl:attribute>
        <h2>
            <xsl:value-of select="@name" />
        </h2>
        <div class="CharacterSectionContent" style="height:auto;overflow:hidden;">
            <xsl:apply-templates select="Feats/Feat" mode="listitem" />
        </div>
    </div>
</div>
</xsl:template>

<xsl:template match="MultipleKeys/Character" mode="powers">
<div class="{@safe-key}Multiple">
    <xsl:if test="position() mod 8 = 1">
        <xsl:if test="position() != 1">
            <p style="height:4px;clear:both;"/> <!-- keeps the first one in each row left-aligned -->
        </xsl:if>
    </xsl:if>
    <div style="position:relative;">
        <xsl:attribute name="class">
            span-3 CombatantContent
            <xsl:value-of select="@key" />Multiple
            <xsl:if test="position() mod 8 = 0">last</xsl:if>
        </xsl:attribute>
        <h2>
            <xsl:value-of select="@name" />
        </h2>
        <div class="CharacterSectionContent" style="height:auto;overflow:hidden;">
            <xsl:call-template name="powerTable">
                <xsl:with-param name="columns" select="1" />
                <xsl:with-param name="height" select="'auto'" />
                <xsl:with-param name="showEmptyTitles" select="'show'" />
            </xsl:call-template>
        </div>
    </div>
</div>
</xsl:template>

<xsl:template match="MultipleKeys/Character" mode="notes">
<div class="{@safe-key}Multiple">
    <xsl:call-template name="descriptionNodeDiv">
        <xsl:with-param name="descriptionNode" select="Description/Notes" />
    </xsl:call-template>
</div>
</xsl:template>

<xsl:template match="MultipleKeys/Character" mode="appearance">
<div class="{@safe-key}Multiple">
    <xsl:call-template name="descriptionNodeDiv">
        <xsl:with-param name="descriptionNode" select="Description/Appearance" />
    </xsl:call-template>
</div>
</xsl:template>

<xsl:template match="MultipleKeys/Character" mode="traits">
<div class="{@safe-key}Multiple">
    <xsl:call-template name="descriptionNodeDiv">
        <xsl:with-param name="descriptionNode" select="Description/Traits" />
    </xsl:call-template>
</div>
</xsl:template>

<xsl:template match="MultipleKeys/Character" mode="companions">
<div class="{@safe-key}Multiple">
    <xsl:call-template name="descriptionNodeDiv">
        <xsl:with-param name="descriptionNode" select="Description/Companions" />
    </xsl:call-template>
</div>
</xsl:template>

<xsl:template name="descriptionNodeDiv">
    <xsl:param name="descriptionNode" />
    <xsl:if test="position() mod 3 = 1">
        <xsl:if test="position() != 1">
            <p style="height:4px;clear:both;"/> <!-- keeps the first one in each row left-aligned -->
        </xsl:if>
    </xsl:if>
    <div style="position:relative;">
        <xsl:attribute name="class">
            span-8 CombatantContent
            <xsl:value-of select="@key" />Multiple
            <xsl:if test="position() mod 3 = 0">last</xsl:if>
        </xsl:attribute>
        <h2>
            <xsl:value-of select="@name" />
        </h2>
        <div class="CharacterSectionContent" style="height:auto;overflow:hidden;font-size:.9em;">
            <xsl:apply-templates select="$descriptionNode" mode="listitem" />
        </div>
    </div>
</xsl:template>

<xsl:template match="MultipleKeys/Character" mode="langsAndProfs">
<div class="{@safe-key}Multiple">
    <xsl:if test="position() mod 8 = 1">
        <xsl:if test="position() != 1">
            <p style="height:4px;clear:both;"/> <!-- keeps the first one in each row left-aligned -->
        </xsl:if>
    </xsl:if>
    <div style="position:relative;">
        <xsl:attribute name="class">
            span-3 CombatantContent
            <xsl:value-of select="@key" />Multiple
            <xsl:if test="position() mod 8 = 0">last</xsl:if>
        </xsl:attribute>
        <h2>
            <xsl:value-of select="@name" />
        </h2>
        <div class="CharacterSectionContent" style="height:auto;overflow:hidden;">
            <div class="EqualSection1">
                <h3>Languages</h3>
                <xsl:apply-templates select="Languages/Language" mode="listitems" />
            </div>
            <xsl:apply-templates select="Proficiencies" mode="listitems" />
        </div>
    </div>
</div>
</xsl:template>

<xsl:template match="MultipleKeys/Character" mode="build">
<div class="{@safe-key}Multiple">
    <xsl:if test="position() mod 8 = 1">
        <xsl:if test="position() != 1">
            <p style="height:4px;clear:both;"/> <!-- keeps the first one in each row left-aligned -->
        </xsl:if>
    </xsl:if>
    <div style="position:relative;">
        <xsl:attribute name="class">
            span-3 CombatantContent
            <xsl:value-of select="@key" />Multiple
            <xsl:if test="position() mod 8 = 0">last</xsl:if>
        </xsl:attribute>
        <h2>
            <xsl:value-of select="@name" />
        </h2>
        <div class="CharacterSectionContent" style="height:auto;overflow:hidden;font-size:.9em;">
            <xsl:apply-templates select="Build" mode="talldiv" />
        </div>
    </div>
</div>
</xsl:template>

</xsl:stylesheet>
