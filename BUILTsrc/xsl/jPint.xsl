<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" encoding="ISO-8859-1" indent="yes"
 doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
 doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

<xsl:include href="/145541695845/xsl/UIMobile.xsl" />

<!-- MAIN -->

<xsl:template match="Character | Campaign">
    <html>
        <head>
            <title><xsl:value-of select="@name" /> - iplay4e</title>

            <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />
            <meta name="viewport" content="user-scalable=no, width=device-width" />
            <meta name="apple-mobile-web-app-capable" content="yes" />

            <link rel="stylesheet" type="text/css" charset="utf-8" href="/145541695845/css/jPint.css" />
            <style>
                /* Header and Navigation */
                .IP4Sync { position:absolute; top:0; left:0; height:8px; width:100%; z-index: 1000; }
                .IP4Syncing { background:yellow; }
                .IP4SyncError{ background:red; }

                img.RightIcon
                {   cursor:pointer; z-index:2000; height:16px; width:16px; 
                    float:right; margin-left:6px;
                    position:relative; border:none;
                }
                img.IP4Manage { margin-right: 6px; margin-left:8px; cursor:pointer; float:left;}

                .TitlePageLinks 
                {   position:absolute; bottom:0; left:0;
                    clear:both; margin:10px 0 3px 0;
                    width:100%;
                }
                .OperaTitlePageLinks
                {   font-size:.3em; position:relative; top:10px;
                }
                .OperaTitlePageLinks a { margin-left:4px; padding:auto 1px; }
                .OperaTitlePageLinks a, .OperaTitlePageLinks a:active, .OperaTitlePageLinks a:link, .OperaTitlePageLinks a:visited 
                { color:white; background:transparent; }
                .OperaTitlePageLinks a.Active, .OperaTitlePageLinks a.Active:link,
                .OperaTitlePageLinks a.Active:visited, .OperaTitlePageLinks a.Active:active 
                { background:white; color:black; position:relative; top:2px; }

                .TitlePageLinks a { margin:0 6px; float:left; }
                .TitlePageLinks a, .TitlePageLinks a:active, .TitlePageLinks a:link, .TitlePageLinks a:visited { background:transparent; }
                .TitlePageLinks a.Active, .TitlePageLinks a.Active:link, .TitlePageLinks a.Active:visited, .TitlePageLinks a.Active:active
                {   position:relative; top:5px; background:white;
                }
                .TitlePageLinks a.Die { float:right; position:relative; top:6px; margin-right:14px;}
                .TitlePageLinks a img { border:none; }

                /* All Buttons */
                li input[type="button"] { position:relative; top:-3px; min-width:20px;}
                
                /* Buttons to the left and right of secondary text */
                /* Commented out because stupid IE doesn't do css3 so we do it the hard way below. */
                /* li .secondary input[type="button"] { margin-left:6px; margin-right:6px; } */
                input.SecondaryButton { margin-left:6px; margin-right:6px; }

                /* Buttons in the damage row */
                input.DamageButton, input.HealButton, input.UseSecondWindButton
                {   width:22%; margin-right: 1%; margin-left:6%;
                    font-size:.5em;
                }
                input.DescriptionButton { width:42%; }
                input.UnchangedButton { opacity:.4; text-decoration:line-through; }
                input.UseSecondWindButton { color:red; }

                /* Buttons in the rest row */
                div.Rest { width:60%; }
                input.RestButton { width:45%; margin-right:6px; }

                .Dying { color:red; }

                /* Edged List */
                .HelpH2Link { float:right; margin-right:10px; padding-top:1px; }
                .EdgedList ul li.noTop { border-top:none; }

                .EdgedList ul li.Roller
                {	background-image: url(/145541695845/images/d2024px.png); background-repeat: no-repeat; background-position: 97% 8px; 
                }
                .EdgedList ul li.Roller .secondary { margin-right:12%; }

                .EdgedList ul li.withHelp
                {	background-image: url(/145541695845/images/question_frame.png); background-repeat: no-repeat; background-position: 96% 12px; 
                }

                .EdgedList ul li.withHelp .secondary { margin-right:11%; margin-bottom:12px; }
                /* Skip IE */
                body:last-child .EdgedList ul li.withHelp .secondary { margin-bottom:auto; }

                #<xsl:value-of select="@key" />skills ul li.withHelp
                {	background-image: url(/145541695845/images/question_frame.png); background-repeat: no-repeat; background-position: 96% 0; 
                }

                .EdgedList ul li.ActiveLI,
                .EdgedList ul li#AddConditionLI
                {	cursor:pointer;
	                background-image: url(/145541695845/images/plus_circle.png); background-repeat: no-repeat; background-position: 96% 12px; 
                }
                .EdgedList ul li#AddConditionLI .secondary { margin-right:13%; }

                .EdgedList ul li.SometimesConditions { min-height:0; padding-top:0; padding-bottom:0; }
                .EdgedList ul li .<xsl:value-of select="Health/@conditions-display-class" /> { margin-top:0; }
                .CUR_ConditionsDelete
                {   padding-left:24px;
	                background-image: url(/145541695845/images/minus_circle.png); background-repeat: no-repeat; background-position: 0 0; 
                    cursor:pointer;
                    margin-top:3px; margin-bottom:3px;
                }

                .EdgedList ul li table { top:0; }
                /* Skip IE */
                body:last-child .EdgedList ul li table { position:relative; }

                .EdgedList ul li table tr th, .EdgedList ul li table tr td 
                    { font-weight:normal; text-align:center; white-space:nowrap; padding:0; margin:0; padding-right:8px; }
                .EdgedList ul li table tr th { font-size:10px; }
                .EdgedList ul li table tr td { font-size:16px; color:#324F85; padding-top:0;}
                /* Safari/iPhone only hacks */
                @media screen and (-webkit-min-device-pixel-ratio:0)
                {   .EdgedList ul li table { position:relative; top:-6px; }
                }

                .EdgedList ul li table#abilitiesTable { margin-left:8px; }
                .EdgedList ul li table#abilitiesTable tr th { font-weight:bold; font-size:20px;  }

                /* Factors and Conditions */
                .FactorModifier { float:left; min-width:24px; text-align:right; margin-right:4px; }
                .ConditionFactorWrapper { font-style:italic; }

                /* Bars and Health */
                .EdgedList ul li.HasBars { padding-top:0; }
                /* clear in IE only */
                .EdgedList ul li.withArrow .secondary { clear:both; }
                body:last-child .EdgedList ul li.withArrow .secondary { clear:none; }

                .CUR_HitPointsBar, .CUR_SurgesBar, .<xsl:value-of select="Health/@tempHP-bar-class" />
                { float:left; height: 8px; width: 1%; display:inline; font-size:0; }
                .<xsl:value-of select="Health/@tempHP-bar-class" />
                { float:right; clear:both;}

                .BloodiedMarker 
                {   position: absolute; right: 50%; top:12px;
                    padding: 14px 2px 0 0; margin-top:-12px;font-size:.6em;color:red;
	                border-right: 1px solid rgb( 167, 167, 167 );
                }

                /* Powers */
                .PowerPrefix { float:left; width:24px; text-align:center; left:-4px; position:relative; }
                input.UsePower { margin-left:10px; width:93%; }
                .Used { opacity:.3; text-decoration:line-through; }

            </style>

            <script type="text/javascript" language="javascript" src="/145541695845/js/combo.js" />
            <script type="text/javascript" language="javascript" src="/145541695845/js/jPint.js" />
            <script type="text/javascript" language="javascript">
                Event.observe(document, 'dom:loaded', function()
                {   
                    // Cause the die roller icon, and all drilldown links, to make all title nav links inactive.
                    var titleNavLinks = $$('#<xsl:value-of select="@key" /> .TitleNav');
                    $$('#<xsl:value-of select="@key" /> .TitlePageLinks .Die').invoke('observe', 'click', function()
                    {   titleNavLinks.invoke('removeClassName', 'Active');
                    });
                    $$('#<xsl:value-of select="@key" /> li.withArrow a').invoke('observe', 'click', function()
                    {   titleNavLinks.invoke('removeClassName', 'Active');
                    });

                    titleNavLinks.invoke('observe', 'click', function(e)
                    {   // Deactivate all title nav links.
                        titleNavLinks.invoke('removeClassName', 'Active');
                    
                        // Find the class name that's TitleNav*
                        var theseClassNames = $w(this.className);
                        var navClassName = null;
                        for (var i=0; i&lt;theseClassNames.length; i++)
                        {   var thisClassName = theseClassNames[i];
                            if (thisClassName != 'TitleNav' &amp;&amp; thisClassName.indexOf('TitleNav') == 0)
                            {   navClassName = thisClassName;
                                break;
                            }
                        }

                        // Activate that class name within each h1.
                        if (navClassName)
                        {   var activeNavLinks = $$('#<xsl:value-of select="@key" /> .' + navClassName);
                            activeNavLinks.invoke('addClassName', 'Active');
                        }

                        var theElement = e.element().up('a');
                        if (theElement &amp;&amp; theElement.blur) theElement.blur();
                    });

                    /* Fix Opera Mini */
		            if (navigator.userAgent.indexOf('Opera') != -1) 
                    {   
                        // The standard image links are too much.
                        $$('.TitlePageLinks').invoke('hide');
                        $$('.OperaTitlePageLinks').invoke('show');

                        // So is the logout link - they can get there via the iplay4e link.
                        $('loginLogoutLinks').hide();
                    }
                } );
                Event.observe(document, 'dom:loaded', function() 
                {   initializeCharacter('<xsl:value-of select="@key" />', '<xsl:value-of select="@safe-key" />');
                } );
                makeLinksInternal = function()
                {   $$('a').findAll(function(a)
                    {   return ((!a.onclick) &amp;&amp; (!a.target));
                    }).invoke('observe', 'click', function(e)
                    {   e.stop();
                        location.replace(e.findElement('a').href);
                    });
                };
            </script>

        </head>
        <xsl:apply-templates select="." mode="body" />
    </html>
</xsl:template>

<xsl:template match="Campaign" mode="body">
    <body id="jPint" class="InIframe" onload="pageAuth();makeLinksInternal();">
        <span id="{@key}">
            <span id="{@safe-key}">
                <xsl:call-template name="header">
                    <xsl:with-param name="title" select="@name" />
                </xsl:call-template>
                <div class="jPintPageSet">
                    <div style="display:none;" class="jPintPage EdgedList HasTitle" id="{@key}main">
                        <h2><div>Characters</div></h2>
                        <ul>
                            <xsl:apply-templates select="Characters/Character" mode="listitem" />
                        </ul>
                        <h2><div>Players</div></h2>
                        <ul>
                            <xsl:apply-templates select="Players/Player" mode="listitem" />
                        </ul>
                    </div>
                </div>
            </span>
        </span>
    </body>
</xsl:template>

<xsl:template match="Character" mode="body">
    <body id="jPint" class="InIframe">
        <span id="{@key}">
            <span id="{@safe-key}">
                <xsl:call-template name="h1">
                    <xsl:with-param name="character" select="." />
                </xsl:call-template>
                <div class="jPintPageSet">
                    <xsl:apply-templates select="Build" mode="div" />
                    <xsl:apply-templates select="." mode="divMain" />
                    <xsl:apply-templates select="." mode="divCombat" />
                    <xsl:apply-templates select="." mode="divDice" />
                    <xsl:apply-templates select="." mode="divRest" />
                    <xsl:apply-templates select="Health" mode="div" />
                    <xsl:apply-templates select="Defenses" mode="div" />
                    <xsl:apply-templates select="Movement" mode="div" />
                    <xsl:apply-templates select="Powers" mode="div" />
                    <xsl:apply-templates select="Skills" mode="div" />
                    <xsl:apply-templates select="Feats" mode="div" />
                    <xsl:apply-templates select="Loot" mode="div" />
                    <xsl:apply-templates select="Loot" mode="divCarriedMoney" />
                    <xsl:apply-templates select="Loot" mode="divStoredMoney" />
		    <xsl:apply-templates select="Loot" mode="divCarriedWeight" />
                    <xsl:apply-templates select="AbilityScores" mode="div" />
                    <xsl:apply-templates select="Proficiencies/WeaponProficiencies" mode="div" />
                    <xsl:apply-templates select="Powers/Power[starts-with(@actiontype, 'No Action')]" mode="div" />
                    <xsl:apply-templates select="Powers/Power[starts-with(@actiontype, 'Minor Action')]" mode="div" />
                    <xsl:apply-templates select="Powers/Power[starts-with(@actiontype, 'Standard Action')]" mode="div" />
                    <xsl:apply-templates select="Powers/Power[starts-with(@actiontype, 'Move Action')]" mode="div" />
                    <xsl:apply-templates select="Powers/Power[starts-with(@actiontype, 'Free Action')]" mode="div" />
                    <xsl:apply-templates select="Powers/Power[starts-with(@actiontype, 'Opportunity Action')]" mode="div" />
                    <xsl:apply-templates select="Powers/Power[starts-with(@actiontype, 'Immediate Reaction')]" mode="div" />
                    <xsl:apply-templates select="Powers/Power[starts-with(@actiontype, 'Immediate Interrupt')]" mode="div" />
                </div>
            </span>
        </span>
    </body>
</xsl:template>

<xsl:template match="Character" mode="divMain">
    <div style="display:none;" class="jPintPage EdgedList HasTitle" id="{@key}main">
                <h2><div>Ability Scores</div></h2>
                <ul>
                    <li class="withArrow">
                        <a href="#{@key}abilities">
                            <div class="secondary" style="float:left;">
                                <xsl:call-template name="tableAbilityScores" />
                            </div>
                        </a>
                    </li>
                    <li class="withArrow">
                        <a href="#{@key}feats">
                            <div class="primary">Feats</div>
                        </a>
                    </li>
                    <li class="withArrow">
                        <a href="#{@key}skills">
                            <div class="primary">Skills</div>
                            <div class="secondary">
                                <xsl:call-template name="tableSkills" />
                            </div>
                        </a>
                    </li>
                    <li>
                        <div class="primary">Alignment</div>
                        <div class="secondary"><xsl:value-of select="Build/@alignment" /></div>
                    </li>
                    <li>
                        <div class="primary">Deity</div>
                        <div class="secondary"><xsl:value-of select="Build/@deity" /></div>
                    </li>
                    <li>
                        <div class="primary">Gender</div>
                        <div class="secondary"><xsl:value-of select="Build/@gender" /></div>
                    </li>
                    <li>
                        <div class="primary">Vision</div>
                        <div class="secondary"><xsl:value-of select="Build/@vision" /></div>
                    </li>
                    <li>
                        <div class="primary">Size</div>
                        <div class="secondary"><xsl:value-of select="Build/@size" /></div>
                    </li>
                    <li>
                        <div class="primary">Languages</div>
                        <div class="tertiary">
                            <xsl:call-template name="commalist">
                                <xsl:with-param name="itemlist" select="Languages/Language" />
                            </xsl:call-template>
                        </div>
                    </li>
                    <xsl:apply-templates select="Proficiencies" mode="listitems" />
                    <xsl:apply-templates select="Description/*" mode="listitem" />
                </ul>
    </div>
</xsl:template>


<!-- COMBAT -->

<xsl:template match="Character" mode="divCombat">
    <div style="display:none;" class="jPintPage EdgedList HasTitle" id="{@key}combat">
                <h2><div>Fight</div></h2>
                <ul>
                    <li class="withArrow">
                        <a href="#{@key}movement">
                            <div class="primary">Init / Speed</div>
                            <div class="secondary">
                                +<xsl:value-of select="Movement/Initiative/@value" />
                                /
                                <xsl:value-of select="Movement/Speed/@value" />
                            </div>
                        </a>
                    </li>
                    <li class="withArrow">
                        <a href="#{@key}defenses">
                            <!--
                            <div class="primary">
                                AC
                                <xsl:if test="Defenses/Condition">
                                    <xsl:text>&#xA;</xsl:text>
                                    *
                                </xsl:if>
                            </div>
                            -->
                            <xsl:apply-templates select="Defenses" mode="table" />
                        </a>
                    </li>
                    <span class="{@safe-key}NotEditor" style="display:none;">
                        <li class="{@safe-key}MonitorOnly" style="display:none;">
                            <div class="primary">Conditions</div>
                        </li>
                    </span>
                    <li class="{@safe-key}EditorOnly" id="AddConditionLI" style="display:none;">
                        <div class="primary">Conditions</div>
                    </li>
                    <script type="text/javascript" language="javascript">
                        $('AddConditionLI').observe('click', function() 
                        {   
                            <xsl:value-of select="Health/@conditions-prompt-script" />
                        });
                    </script>
                    <li class="{@safe-key}MonitorOnly noTop SometimesConditions" style="display:none;">
                        <div class="tertiary {Health/@conditions-display-class}">
                        </div>
                    </li>
                    <li class="{@safe-key}MonitorOnly" style="display:none;">
                        <div class="primary">Temp HP</div>
                        <div class="secondary">
                            <input class="SecondaryButton" type="button" value="Set"
                             onclick="{Health/@tempHP-prompt-script}"/>
                            <span class="{Health/@tempHP-display-class}">0</span>
                        </div>
                    </li>
                    <li class="withArrow HasBars">
                        <div style="width:100%; background-color:green; opacity:0.15; display:none;" 
                         class="{@safe-key}MonitorOnly CUR_HitPointsBar">
                        </div>
                        <div style="display:none; width:1%; background-color:green;" class="{@safe-key}MonitorOnly {Health/@tempHP-bar-class}">
                        </div>
                        <a href="#{@key}hitpoints">
                            <div class="primary">HP</div>
                            <div class="secondary">
                                <span class="{@safe-key}MonitorOnly" style="display:none;">
                                    <span class="CUR_HitPoints"><xsl:value-of select="Health/MaxHitPoints/@value" /></span>
                                    <xsl:text> of </xsl:text>
                                </span>
                                <xsl:value-of select="Health/MaxHitPoints/@value" />
                            </div>
                            <div class="BloodiedMarker">
                                <xsl:value-of select="Health/BloodiedValue/@value" />
                            </div>
                        </a>
                    </li>
                    <li class="noTop {@safe-key}EditorOnly" style="display:none;">
                        <input class="DamageButton" type="button" value="Damage"
                         onclick="{Health/MaxHitPoints/@damage-prompt-script}" />
                        <input class="HealButton" type="button" value="Heal"
                         onclick="{Health/MaxHitPoints/@heal-prompt-script}" />
                        <input class="UseSecondWindButton {Powers/Power[@name='Second Wind']/@display-class}"
                         type="button" value="2nd Wind" onclick="{Powers/Power[@name='Second Wind']/@use-script}" />
                    </li>
		    <xsl:if test="count(./Resistances/@*) &gt; 0">
                    <li class="noTop">
                        <div class="primary">Resist</div>
                        <div class="secondary">
                            <xsl:for-each select="./Resistances/@*">
                                <xsl:value-of select="name()" /><xsl:text> </xsl:text>
                                <xsl:value-of select="." />
                                <xsl:if test="position()!=last()">
                                    <xsl:text>, </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </div>
                    </li>
		    </xsl:if>
                    <li class="{@safe-key}MonitorOnly noTop CUR_HitPointsDyingOrFailedSaves" style="display:none;">
                        <div class="primary Dying">Death Saves</div>
                        <div class="secondary">
                            <input class="{@safe-key}EditorOnly SecondaryButton" type="button" value=" + " style="display:none;"
                             onclick="{Health/@death-saves-add-script}" />
                            <input class="{@safe-key}EditorOnly SecondaryButton" type="button" value=" - " style="display:none;"
                             onclick="{Health/@death-saves-subtract-script}" />
                            <span class="{Health/@death-saves-display-class}"></span>
                        </div>
                    </li>
                    <li class="HasBars">
                        <div style="width:100%; background-color:yellow; opacity:0.15; display:none;" 
                         class="{@safe-key}MonitorOnly CUR_SurgesBar">
                        </div>
                        <div class="primary">Surges</div>
                        <div class="secondary">
                            <span class="{@safe-key}MonitorOnly" style="display:none;">
                                <input class="{@safe-key}EditorOnly SecondaryButton" type="button" value=" + " style="display:none;"
                                 onclick="{Health/MaxSurges/@add-script}" />
                                <input class="{@safe-key}EditorOnly SecondaryButton" type="button" value=" - " style="display:none;"
                                 onclick="{Health/MaxSurges/@subtract-script}" />
                                <span class="CUR_Surges"><xsl:value-of select="Health/MaxSurges/@value" /></span>
                                <xsl:text> of </xsl:text>
                            </span>
                            <xsl:value-of select="Health/MaxSurges/@value" />
                        </div>
                    </li>
                    <li class="noTop">
                        <div class="primary">Surge Value</div>
                        <div class="secondary">
                            <span class="{@safe-key}EditorOnly" style="display:none;">
                                <input class="SecondaryButton" type="button" value="Add to HP"
                                 onclick="{Health/SurgeValue/@toHitPoints-script}"/>
                                <xsl:text> </xsl:text>
                            </span>
                            <xsl:value-of select="Health/SurgeValue/@value" />
                        </div>
                    </li>
                    <li class="{@safe-key}EditorOnly withArrow" style="display:none;">
                        <a href="#{@key}rest">
                            <div class="primary">Rest</div>
                        </a>
                    </li>
		            <xsl:if test="Health/PowerPoints/@value &gt; 0">
                        <xsl:apply-templates select="Health" mode="powerPoints"/>
		            </xsl:if>
                </ul>
                <!-- IMMEDIATE Powers -->
                <xsl:apply-templates select="Powers" mode="list">
                    <xsl:with-param name="actiontype" select="'Immediate Interrupt'" />
                </xsl:apply-templates>
                <xsl:apply-templates select="Powers" mode="list">
                    <xsl:with-param name="actiontype" select="'Immediate Reaction'" />
                </xsl:apply-templates>
    </div>
</xsl:template>

<xsl:template match="Health" mode="powerPoints">
    <li>
        <div class="primary">Power Points</div>
        <div class="secondary">
            <span class="{../@safe-key}MonitorOnly" style="display:none;">
                <input class="{../@safe-key}EditorOnly SecondaryButton" type="button" value=" + " style="display:none;"
                 onclick="{./@power-points-add-script}" />
                <input class="{../@safe-key}EditorOnly SecondaryButton" type="button" value=" - " style="display:none;"
                 onclick="{./@power-points-subtract-script}" />
                <span class="CUR_PowerPoints"><xsl:value-of select="./PowerPoints" /></span>
                <xsl:text> of </xsl:text>
            </span>
            <xsl:value-of select="./PowerPoints/@value" />
        </div>
    </li>
</xsl:template>

<!-- REST -->

<xsl:template match="Character" mode="divRest">
    <div style="display:none;" class="jPintPage EdgedList HasTitle" id="{@key}rest">
        <h2><div>Rest</div></h2>
        <ul>
            <li class="ActiveLI">
                <a href="javascript:{Health/@short-rest-script}">
                    <div class="primary">Short Rest</div>
                    <div class="tertiary">
                        Resets encounter powers<br />
                        Clears temporary hit points<br />
                        Resets death saves<br />
                        Spend as many healing surges as you want
                    </div>
                </a>
            </li>
            <li class="ActiveLI">
                <a href="javascript:{@milestone-script}">
                    <div class="primary">Milestone</div>
                    <div class="tertiary">
                        Adds an action point<br />
                        Add a daily magic item use
                    </div>
                </a>
            </li>
            <li class="ActiveLI">
                <a href="javascript:{Health/@extended-rest-script}">
                    <div class="primary">Extended Rest</div>
                    <div class="tertiary">
                        Resets encounter powers<br />
                        Resets daily powers<br />
                        Clears temporary hit points<br />
                        Resets hit points<br />
                        Resets healing surges<br />
                        Resets death saves<br />
                        Resets action points<br />
                        Resets daily magic item uses
                    </div>
                </a>
            </li>
        </ul>
    </div>
</xsl:template>

<!-- HIT POINTS and SURGES -->

<xsl:template match="Health" mode="div">
    <div style="display:none;" class="jPintPage EdgedList HasTitle" id="{../@key}hitpoints">
                <ul>
                    <li>
                        <div class="primary">Hit Points</div>
                        <div class="secondary"><xsl:value-of select="MaxHitPoints/@value" /></div>
                        <div class="tertiary">
                            <xsl:apply-templates select="MaxHitPoints/Factor" />
                        </div>
                    </li>
                    <li>
                        <div class="primary">Healing Surges</div>
                        <div class="secondary"><xsl:value-of select="MaxSurges/@value" /></div>
                        <div class="tertiary">
                            <xsl:apply-templates select="MaxSurges/Factor" />
                        </div>
                    </li>
                    <li>
                        <div class="primary">Surge Value</div>
                        <div class="secondary"><xsl:value-of select="SurgeValue/@value" /></div>
                        <div class="tertiary">
                            <xsl:apply-templates select="SurgeValue/Factor" />
                        </div>
                    </li>
                </ul>
    </div>
</xsl:template>

<!-- POWERS -->

<xsl:template match="Powers" mode="div">
    <div style="display:none;" class="jPintPage EdgedList HasTitle" id="{../@key}powers">
                <xsl:if test="../Health/PowerPoints/@value &gt; 0">
                    <ul>
                        <xsl:apply-templates select="../Health" mode="powerPoints"/>
                    </ul>
                </xsl:if>
                <xsl:apply-templates select="." mode="list">
                    <xsl:with-param name="actiontype" select="'No Action'" />
                </xsl:apply-templates>
                <xsl:apply-templates select="." mode="list">
                    <xsl:with-param name="actiontype" select="'Minor Action'" />
                </xsl:apply-templates>
                <xsl:apply-templates select="." mode="list">
                    <xsl:with-param name="actiontype" select="'Standard Action'" />
                </xsl:apply-templates>
                <xsl:apply-templates select="." mode="list">
                    <xsl:with-param name="actiontype" select="'Move Action'" />
                </xsl:apply-templates>
                <xsl:apply-templates select="." mode="list">
                    <xsl:with-param name="actiontype" select="'Free Action'" />
                </xsl:apply-templates>
                <xsl:apply-templates select="." mode="list">
                    <xsl:with-param name="actiontype" select="'Immediate Reaction'" />
                </xsl:apply-templates>
                <xsl:apply-templates select="." mode="list">
                    <xsl:with-param name="actiontype" select="'Immediate Interrupt'" />
                </xsl:apply-templates>
                <xsl:apply-templates select="." mode="list">
                    <xsl:with-param name="actiontype" select="'Opportunity Action'" />
                </xsl:apply-templates>
    </div>
</xsl:template>

<xsl:template match="Powers" mode="list">
    <xsl:param name="actiontype" />
    <xsl:if test="Power[starts-with(@actiontype, $actiontype)]">
        <h2><div><xsl:value-of select="$actiontype" /></div></h2>
        <ul>
            <xsl:apply-templates select="Power[starts-with(@actiontype, $actiontype)]" mode="listitem" />
        </ul>
    </xsl:if>
</xsl:template>

<xsl:template match="Power" mode="colorstyle">
    <xsl:choose>
        <xsl:when test="starts-with(@powerusage, 'At-Will')">color:#619869;</xsl:when>
        <xsl:when test="starts-with(@powerusage, 'Encounter')">color:#961334;</xsl:when>
        <xsl:when test="starts-with(@powerusage, 'Daily')">color:#4D4D4F;</xsl:when>
        <xsl:otherwise>#BF4C00</xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="Power" mode="listitem">
    <li class="withArrow">
        <a href="#{../../@key}{generate-id(@name)}">
            <div class="primary">
                <xsl:attribute name="style">
                    <xsl:apply-templates select="." mode="colorstyle" />
                </xsl:attribute>
                <div class="PowerPrefix">
                    <xsl:choose>
                        <xsl:when test="starts-with(@actiontype, 'No Action')">&#8855;</xsl:when>
                        <xsl:when test="starts-with(@actiontype, 'Minor Action')">&#8226;</xsl:when>
                        <xsl:when test="starts-with(@actiontype, 'Standard Action')">&#9674;</xsl:when>
                        <xsl:when test="starts-with(@actiontype, 'Move Action')">&#8594;</xsl:when>
                        <xsl:when test="starts-with(@actiontype, 'Free Action')">&#927;</xsl:when>
                        <xsl:when test="starts-with(@actiontype, 'Opportunity Action')">&#8869;</xsl:when>
                        <xsl:when test="starts-with(@actiontype, 'Immediate Reaction')">&#8629;</xsl:when>
                        <xsl:when test="starts-with(@actiontype, 'Immediate Interrupt')">&#8596;</xsl:when>
                        <xsl:otherwise>?</xsl:otherwise>
                    </xsl:choose>
                </div>
                <span class="{@display-class}">
                    <xsl:value-of select="@name" />
                </span>
            </div>
            <xsl:if test="@name='Action Point'">
                <div class="secondary {@safe-key}MonitorOnly">
                    <span class="CUR_ActionPoints"></span>
                </div>
            </xsl:if>
        </a>
    </li>
</xsl:template>

<xsl:template match="Power" mode="div">
    <div style="display:none;" class="jPintPage EdgedList HasTitle" id="{../../@key}{generate-id(@name)}">
        <form class="NotesForm" style="display:inline;margin:0;padding:0;" >
                <ul>
                    <li class="withHelp">
                        <a class="CompendiumLink" target="{generate-id(@name)}" href="{@url}">
                            <div class="primary {@display-class}">
                                <span>
                                    <xsl:attribute name="style">
                                        <xsl:apply-templates select="." mode="colorstyle" />
                                    </xsl:attribute>
                                    <xsl:value-of select="@name" />
                                </span>
                            </div>
                            <div class="secondary">
                                <xsl:value-of select="@source"/>
                            </div>
                            <div class="tertiary">
                                <xsl:value-of select="@flavor"/>
                            </div>
                        </a>
                    </li>
                    <li style="display:none; cursor:pointer;"
                     onclick="Effect.toggle($(this).down('.tertiary'), 'blind', {{duration:.2}});">
                        <input type="hidden" name="name" value="{@name}" />
                        <div class="primary">
                            Notes
                        </div>
                        <div class="secondary">
                            <small>&#9660;</small>
                        </div>
                        <div class="tertiary">
                            <pre style="
                                white-space: pre-wrap; /* css-3 */
                                white-space: -moz-pre-wrap !important; /* Mozilla, since 1999 */
                                white-space: -pre-wrap; /* Opera 4-6 */
                                white-space: -o-pre-wrap; /* Opera 7 */
                                word-wrap: break-word; /* Internet Explorer 5.5+ */
                            ">
                            </pre>
                        </div>
                    </li>
                    <xsl:if test="@name='Action Point'">
                        <li>
                            <div class="primary">Points Remaining</div>
                            <div class="secondary">
                                <input class="SecondaryButton" type="button" value=" + " onclick="{../../@action-points-add-script}" />
                                <input class="SecondaryButton" type="button" value=" - " onclick="{../../@action-points-subtract-script}" />
                                <span class="CUR_ActionPoints"></span>
                            </div>
                        </li>
                    </xsl:if>
                    <li>
                        <div class="primary">Keywords</div>
                        <div class="secondary"><xsl:value-of select="@keywords" /></div>
                        <xsl:if test="@keywords='' or not(@keywords)">
                            <div class="tertiary">
                                <i>This dnd4e file lacks power card data.  Please save and export your character from the Character Builder to get the power card data, then use File - Upload Replacement to update this character.</i>
                            </div>
                        </xsl:if>
                    </li>
                    <li>
                        <div class="primary">Power Usage</div>
                        <div class="secondary"><xsl:value-of select="@powerusage" /></div>
                    </li>
                    <xsl:if test="@use-script">
                        <li class="{../../@safe-key}EditorOnly noTop" style="display:none;">
                            <input class="UsePower {@display-class}" type="button" value="Mark Used or Unused"
                             onclick="{@use-script}"/>
                        </li>
                    </xsl:if>
                    <li>
                        <div class="primary">Action Type</div>
                        <div class="secondary"><xsl:value-of select="@actiontype" /></div>
                    </li>
                    <li>
                        <div class="primary">Attack Type</div>
                        <div class="secondary"><xsl:value-of select="@attacktype" /></div>
                    </li>
                    <xsl:for-each select="PowerCardItem">
                        <li>
                            <div class="primary"><xsl:value-of select="Name/node()" /></div>
                            <div class="secondary"><xsl:value-of select="Description/node()" /></div>
                        </li>
                    </xsl:for-each>
                    <xsl:if test="Condition">
                        <li>
                            <div class="primary">Conditions</div>
                            <div class="tertiary">
                                <xsl:apply-templates select="Condition" />
                            </div>
                        </li>
                    </xsl:if>
                </ul>
                <xsl:apply-templates select="Weapon" mode="list" />
        </form>
    </div>
</xsl:template>

<xsl:template match="Weapon" mode="list">
    <xsl:choose>
        <xsl:when test="@enhancementurl">
            <h2>
                <div>
                    <a href="{@enhancementurl}" target="{generate-id(@name)}">
                        <div class="HelpH2Link"><img src="/145541695845/images/question_frame.png" /></div>
                        <xsl:value-of select="@name" />
                    </a>
                </div>
            </h2>
        </xsl:when>
        <xsl:otherwise>
            <h2>
                <div>
                    <a href="{@weaponurl}" target="{generate-id(@name)}">
                        <div class="HelpH2Link"><img src="/145541695845/images/question_frame.png" /></div>
                        <xsl:value-of select="@name" />
                    </a>
                </div>
            </h2>
        </xsl:otherwise>
    </xsl:choose>
    <ul>
        <xsl:if test="Condition">
            <li>
                <div class="primary">Conditions</div>
                <div class="tertiary">
                    <xsl:apply-templates select="Condition" />
                </div>
            </li>
        </xsl:if>
        <li class="Roller {Damage/@dice-class} {AttackBonus/@dice-class}#1 {AttackBonus/@dice-class}#2 {AttackBonus/@dice-class}#3 {AttackBonus/@dice-class}#4 {AttackBonus/@dice-class}#5 {AttackBonus/@dice-class}#6 {AttackBonus/@dice-class}#7 {AttackBonus/@dice-class}#8">
            <div class="primary">
                Roll All
            </div>
        </li>
        <li class="Roller {AttackBonus/@dice-class}">
            <div class="primary">
                <xsl:value-of select="@attackstat" />
                <xsl:text>&#xA;</xsl:text>
                (+<xsl:value-of select="AttackBonus/@value" />) vs.
                <xsl:text>&#xA;</xsl:text>
                <xsl:value-of select="@defense" />
            </div>
            <div class="tertiary">
                <xsl:apply-templates select="AttackBonus/Factor" />
                <xsl:apply-templates select="AttackBonus/Condition" />
            </div>
        </li>
        <li class="Roller {Damage/@dice-class}">
            <div class="primary">
                <xsl:value-of select="Damage/@value" />
                <xsl:text>&#xA;</xsl:text>
                <xsl:value-of select="Damage/@type" />
                <xsl:text>&#xA;</xsl:text>
                damage
            </div>
            <div class="tertiary">
                <xsl:apply-templates select="Damage/Factor" />
                <xsl:apply-templates select="Damage/Condition" />
            </div>
        </li>
    </ul>
</xsl:template>

<!-- MOVEMENT -->

<xsl:template match="Movement" mode="div">
    <div style="display:none;" class="jPintPage EdgedList HasTitle" id="{../@key}movement">
                <ul>
                    <li class="Roller {Initiative/@dice-class}">
                        <div class="primary">Initiative</div>
                        <div class="secondary">+<xsl:value-of select="Initiative/@value" /></div>
                        <div class="tertiary">
                            <xsl:apply-templates select="Initiative/Factor" />
                            <xsl:apply-templates select="Initiative/Condition" />
                        </div>
                    </li>
                    <li>
                        <div class="primary">Speed</div>
                        <div class="secondary"><xsl:value-of select="Speed/@value" /></div>
                        <div class="tertiary">
                            <xsl:apply-templates select="Speed/Factor" />
                            <xsl:apply-templates select="Speed/Condition" />
                        </div>
                    </li>
                </ul>
    </div>
</xsl:template>

<!-- DICE -->

<xsl:template match="Character" mode="divDice">
    <div style="display:none;" class="jPintPage EdgedList HasTitle" id="{@key}dice">
                <h2><div>Dice</div></h2>
                <ul>
                    <xsl:call-template name="liDie"><xsl:with-param name="dieSize" select="20" /></xsl:call-template>
                    <xsl:call-template name="liDie"><xsl:with-param name="dieSize" select="12" /></xsl:call-template>
                    <xsl:call-template name="liDie"><xsl:with-param name="dieSize" select="10" /></xsl:call-template>
                    <xsl:call-template name="liDie"><xsl:with-param name="dieSize" select="8" /></xsl:call-template>
                    <xsl:call-template name="liDie"><xsl:with-param name="dieSize" select="6" /></xsl:call-template>
                    <xsl:call-template name="liDie"><xsl:with-param name="dieSize" select="4" /></xsl:call-template>
                </ul>
    </div>
</xsl:template>

<xsl:template name="liDie">
    <xsl:param name="dieSize" />
    <li>
        <xsl:attribute name="class">Roller dice1d<xsl:value-of select="$dieSize" />Roll</xsl:attribute>
        <div class="primary">d<xsl:value-of select="$dieSize" /></div>
    </li>
</xsl:template>

<!-- DEFENSES -->

<xsl:template match="Defenses" mode="div">
    <div style="display:none;" class="jPintPage EdgedList HasTitle" id="{../@key}defenses">
                <ul>
                    <!-- Conditions that apply to all defenses -->
                    <xsl:if test="Condition">
                        <li>
                            <div class="primary">Conditions</div>
                            <div class="tertiary">
                                <xsl:apply-templates select="Condition" />
                            </div>
                        </li>
                    </xsl:if>
                    <xsl:apply-templates select="Defense" mode="listitem" />
                </ul>
    </div>
</xsl:template>

<xsl:template match="Defense" mode="listitem">
    <li>
        <div class="primary"><xsl:value-of select="@name" /></div>
        <div class="secondary"><xsl:value-of select="@value" /></div>
        <div class="tertiary">
            <xsl:apply-templates select="Factor" />
            <xsl:apply-templates select="Condition" />
        </div>
    </li>
</xsl:template>

<xsl:template match="Defenses" mode="table">
    <div class="primary">
        AC 
        <span style="color: #324F85;">
            <xsl:apply-templates select="Defense[@abbreviation='AC']" mode="cellcontent" />
        </span>
    </div>
    <div class="secondary">
        <table cellpadding="0" cellspacing="0">
            <tr>
                <th>Fort</th><th>Ref</th><th>Will</th>
                <th>P.I.</th><th>P.P.</th>
            </tr>
            <tr>
                <td><xsl:apply-templates select="Defense[@abbreviation='Fort']" mode="cellcontent" /></td>
                <td><xsl:apply-templates select="Defense[@abbreviation='Ref']" mode="cellcontent" /></td>
                <td><xsl:apply-templates select="Defense[@abbreviation='Will']" mode="cellcontent" /></td>
                <td><xsl:value-of select="../PassiveSkills/PassiveSkill[@name='Insight']/@value" /></td>
                <td><xsl:value-of select="../PassiveSkills/PassiveSkill[@name='Perception']/@value" /></td>
            </tr>
        </table>
    </div>
</xsl:template>

<xsl:template match="Defense" mode="cellcontent">
    <xsl:value-of select="@value" />
    <xsl:if test="Condition">
        <xsl:text>&#xA;</xsl:text>
        *
    </xsl:if>
</xsl:template>

<!-- SKILLS -->

<xsl:template name="tableSkills">
    <table cellpadding="0" cellspacing="0">
        <tr>
            <th>P. Ins</th><th>P. Per</th>
        </tr>
        <tr>
            <td><xsl:value-of select="PassiveSkills/PassiveSkill[@name='Insight']/@value" /></td>
            <td><xsl:value-of select="PassiveSkills/PassiveSkill[@name='Perception']/@value" /></td>
        </tr>
    </table>
</xsl:template>

<xsl:template match="Skills" mode="div">
    <div style="display:none;" class="jPintPage EdgedList HasTitle" id="{../@key}skills">
                <ul>
                    <xsl:apply-templates select="Skill" mode="listitem" />
                </ul>
    </div>
</xsl:template>

<xsl:template match="Skill" mode="listitem">
    <li class="Roller {@dice-class}">
        <div class="primary"><xsl:value-of select="@name" /></div>
        <div class="secondary"><xsl:value-of select="@value" /></div>
    </li>
    <li class="withHelp noTop">
        <a class="CompendiumLink" href="{@url}" target="{generate-id(@name)}">
            <div class="tertiary">
                <xsl:apply-templates select="Factor[@modifier!='+0']" />
                <xsl:apply-templates select="Condition" />
            </div>
        </a>
    </li>
    <li class="noTop" style="display:none; cursor:pointer; margin-top:-6px; padding-top:0;"
     onclick="Effect.toggle($(this).down('.tertiary'), 'blind', {{duration:.2}});">
        <form class="NotesForm" style="display:inline;margin:0;padding:0;" >
            <input type="hidden" name="name" value="{@name}" />
            <div class="secondary" style="float:left; margin-left:24px;">
                Notes
                <small>&#9660;</small>
            </div>
            <div class="tertiary">
                <pre style="
                    white-space: pre-wrap; /* css-3 */
                    white-space: -moz-pre-wrap !important; /* Mozilla, since 1999 */
                    white-space: -pre-wrap; /* Opera 4-6 */
                    white-space: -o-pre-wrap; /* Opera 7 */
                    word-wrap: break-word; /* Internet Explorer 5.5+ */
                ">
                </pre>
            </div>
        </form>
    </li>
</xsl:template>

<!-- LOOT -->

<xsl:template match="Loot" mode="div">
    <div style="display:none;" class="jPintPage EdgedList HasTitle" id="{../@key}loot">
                <h2><div>Money</div></h2>
                <ul>
                    <li class="withArrow">
                        <a href="#{../@key}CarriedMoney">
                            <div class="primary">Carried</div>
                            <div class="secondary">
                                <span class="{@carried-ad-display-class}"><xsl:value-of select="@carried-ad" /></span> AD,
                                <span class="{@carried-pp-display-class}"><xsl:value-of select="@carried-pp" /></span> PP,
                                <span class="{@carried-gp-display-class}"><xsl:value-of select="@carried-gp" /></span> GP,
                                <span class="{@carried-sp-display-class}"><xsl:value-of select="@carried-sp" /></span> SP,
                                <span class="{@carried-cp-display-class}"><xsl:value-of select="@carried-cp" /></span> CP
                            </div>
                        </a>
                    </li>
                    <li class="withArrow">
                        <a href="#{../@key}StoredMoney">
                            <div class="primary">Stored</div>
                            <div class="secondary">
                                <span class="{@stored-ad-display-class}"><xsl:value-of select="@stored-ad" /></span> AD,
                                <span class="{@stored-pp-display-class}"><xsl:value-of select="@stored-pp" /></span> PP,
                                <span class="{@stored-gp-display-class}"><xsl:value-of select="@stored-gp" /></span> GP,
                                <span class="{@stored-sp-display-class}"><xsl:value-of select="@stored-sp" /></span> SP,
                                <span class="{@stored-cp-display-class}"><xsl:value-of select="@stored-cp" /></span> CP
                            </div>
                        </a>
                    </li>
		    <li>
		      <div class="primary">Carried Weight</div>
		      <div class="secondary">
			<span><xsl:value-of select="@weightCarried" /></span> Lb
		      </div>
		    </li>
                </ul>
                    <h2><div>Magic Items</div></h2>
                    <ul>
                        <li class="{../@safe-key}MonitorOnly" style="display:none;">
                            <div class="primary">Daily Uses</div>
                            <div class="secondary">
                                <input class="{../@safe-key}EditorOnly SecondaryButton" type="button" value=" + " style="display:none;"
                                onclick="{@daily-use-add-script}" />
                                <input class="{../@safe-key}EditorOnly SecondaryButton" type="button" value=" - " style="display:none;"
                                onclick="{@daily-use-subtract-script}" />
                                <span class="{@daily-use-display-class}">
                                    <xsl:value-of select="@experience" />
                                </span>
                            </div>
                        </li>
                        <xsl:apply-templates select="Item[@type='Magic Item']" mode="listitem" />
                    </ul>
                <xsl:if test="Item[@type='Armor']">
                    <h2><div>Armor</div></h2>
                    <ul>
                        <xsl:apply-templates select="Item[@type='Armor']" mode="listitem" />
                    </ul>
                </xsl:if>
                <xsl:if test="Item[@type='Weapon']">
                    <h2><div>Weapons</div></h2>
                    <ul>
                        <xsl:apply-templates select="Item[@type='Weapon']" mode="listitem" />
                    </ul>
                </xsl:if>
                <xsl:if test="Item[@type='Ritual']">
                    <xsl:choose>
                        <xsl:when test="Item[@name='Ritual Book']">
                            <a href="{Item[@name='Ritual Book']/@url}" 
                             target="{generate-id(Item[@name='Ritual Book']/@name)}">
                                <h2>
                                    <div>
                                        <div class="HelpH2Link"><img src="/145541695845/images/question_frame.png" /></div>
                                        <xsl:value-of select="Item[@name='Ritual Book']/@name" />
                                    </div>
                                </h2>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <h2><div>Rituals</div></h2>
                        </xsl:otherwise>
                    </xsl:choose>
                    <ul>
                        <xsl:apply-templates select="Item[@type='Ritual']" mode="listitem" />
                    </ul>
                </xsl:if>
                <xsl:if test="Item[@type!='Armor' and @type!='Weapon' and @type!='Magic Item' and @type!='Ritual' and @name!='Ritual Book']">
                    <h2><div>Other</div></h2>
                    <ul>
                        <xsl:apply-templates select="Item[@type!='Armor' and @type!='Weapon' and @type!='Magic Item' and @type!='Ritual' and @name!='Ritual Book']" mode="listitem" />
                    </ul>
                </xsl:if>
    </div>
</xsl:template>

<xsl:template match="Loot" mode="divCarriedWeight">
  <div style="display:none;" class="jPintPage EdgedList HasTitle" id="{../@key}carriedWeight">
    <h2><div>Carried Weight</div></h2>
  </div>
</xsl:template>

<xsl:template match="Loot" mode="divCarriedMoney">
    <div style="display:none;" class="jPintPage EdgedList HasTitle" id="{../@key}CarriedMoney">
        <h2><div>Carried Money</div></h2>
        <ul>
            <li>
                <div class="primary">AD</div>
                <div class="secondary">
                    <span class="{@carried-ad-display-class}">
                        <xsl:value-of select="@carried-ad" />
                    </span>
                    <input class="SecondaryButton {../@safe-key}EditorOnly" style="display:none;" type="button" value=" + " onclick="{@carried-ad-add-script}" />
                    <input class="SecondaryButton {../@safe-key}EditorOnly" style="display:none;" type="button" value=" - " onclick="{@carried-ad-subtract-script}" />
                </div>
            </li>
            <li>
                <div class="primary">PP</div>
                <div class="secondary">
                    <span class="{@carried-pp-display-class}">
                        <xsl:value-of select="@carried-pp" />
                    </span>
                    <input class="SecondaryButton {../@safe-key}EditorOnly" style="display:none;" type="button" value=" + " onclick="{@carried-pp-add-script}" />
                    <input class="SecondaryButton {../@safe-key}EditorOnly" style="display:none;" type="button" value=" - " onclick="{@carried-pp-subtract-script}" />
                </div>
            </li>
            <li>
                <div class="primary">GP</div>
                <div class="secondary">
                    <span class="{@carried-gp-display-class}">
                        <xsl:value-of select="@carried-gp" />
                    </span>
                    <input class="SecondaryButton {../@safe-key}EditorOnly" style="display:none;" type="button" value=" + " onclick="{@carried-gp-add-script}" />
                    <input class="SecondaryButton {../@safe-key}EditorOnly" style="display:none;" type="button" value=" - " onclick="{@carried-gp-subtract-script}" />
                </div>
            </li>
            <li>
                <div class="primary">SP</div>
                <div class="secondary">
                    <span class="{@carried-sp-display-class}">
                        <xsl:value-of select="@carried-sp" />
                    </span>
                    <input class="SecondaryButton {../@safe-key}EditorOnly" style="display:none;" type="button" value=" + " onclick="{@carried-sp-add-script}" />
                    <input class="SecondaryButton {../@safe-key}EditorOnly" style="display:none;" type="button" value=" - " onclick="{@carried-sp-subtract-script}" />
                </div>
            </li>
            <li>
                <div class="primary">CP</div>
                <div class="secondary">
                    <span class="{@carried-cp-display-class}">
                        <xsl:value-of select="@carried-cp" />
                    </span>
                    <input class="SecondaryButton {../@safe-key}EditorOnly" style="display:none;" type="button" value=" + " onclick="{@carried-cp-add-script}" />
                    <input class="SecondaryButton {../@safe-key}EditorOnly" style="display:none;" type="button" value=" - " onclick="{@carried-cp-subtract-script}" />
                </div>
            </li>
        </ul>
    </div>
</xsl:template>

<xsl:template match="Loot" mode="divStoredMoney">
    <div style="display:none;" class="jPintPage EdgedList HasTitle" id="{../@key}StoredMoney">
        <h2><div>Stored Money</div></h2>
        <ul>
            <li>
                <div class="primary">AD</div>
                <div class="secondary">
                    <span class="{@stored-ad-display-class}">
                        <xsl:value-of select="@stored-ad" />
                    </span>
                    <input class="SecondaryButton {../@safe-key}EditorOnly" style="display:none;" type="button" value=" + " onclick="{@stored-ad-add-script}" />
                    <input class="SecondaryButton {../@safe-key}EditorOnly" style="display:none;" type="button" value=" - " onclick="{@stored-ad-subtract-script}" />
                </div>
            </li>
            <li>
                <div class="primary">PP</div>
                <div class="secondary">
                    <span class="{@stored-pp-display-class}">
                        <xsl:value-of select="@stored-pp" />
                    </span>
                    <input class="SecondaryButton {../@safe-key}EditorOnly" style="display:none;" type="button" value=" + " onclick="{@stored-pp-add-script}" />
                    <input class="SecondaryButton {../@safe-key}EditorOnly" style="display:none;" type="button" value=" - " onclick="{@stored-pp-subtract-script}" />
                </div>
            </li>
            <li>
                <div class="primary">GP</div>
                <div class="secondary">
                    <span class="{@stored-gp-display-class}">
                        <xsl:value-of select="@stored-gp" />
                    </span>
                    <input class="SecondaryButton {../@safe-key}EditorOnly" style="display:none;" type="button" value=" + " onclick="{@stored-gp-add-script}" />
                    <input class="SecondaryButton {../@safe-key}EditorOnly" style="display:none;" type="button" value=" - " onclick="{@stored-gp-subtract-script}" />
                </div>
            </li>
            <li>
                <div class="primary">SP</div>
                <div class="secondary">
                    <span class="{@stored-sp-display-class}">
                        <xsl:value-of select="@stored-sp" />
                    </span>
                    <input class="SecondaryButton {../@safe-key}EditorOnly" style="display:none;" type="button" value=" + " onclick="{@stored-sp-add-script}" />
                    <input class="SecondaryButton {../@safe-key}EditorOnly" style="display:none;" type="button" value=" - " onclick="{@stored-sp-subtract-script}" />
                </div>
            </li>
            <li>
                <div class="primary">CP</div>
                <div class="secondary">
                    <span class="{@stored-cp-display-class}">
                        <xsl:value-of select="@stored-cp" />
                    </span>
                    <input class="SecondaryButton {../@safe-key}EditorOnly" style="display:none;" type="button" value=" + " onclick="{@stored-cp-add-script}" />
                    <input class="SecondaryButton {../@safe-key}EditorOnly" style="display:none;" type="button" value=" - " onclick="{@stored-cp-subtract-script}" />
                </div>
            </li>
        </ul>
    </div>
</xsl:template>

<xsl:template match="Item" mode="listitem">
    <xsl:choose>
        <xsl:when test="Enhancement">
            <li class="withHelp">
                <a class="CompendiumLink" href="{Enhancement/@url}" target="generate-id(Enhancement/@name)">
                    <div class="primary"><xsl:value-of select="Enhancement/@name" /></div>
                    <div class="secondary">
                        <xsl:value-of select="@equippedcount" />
                        of
                        <xsl:value-of select="@count" />
                    </div>
                </a>
            </li>
            <li class="withHelp noTop">
                <a class="CompendiumLink" href="{@url}" target="generate-id(@name)">
                    <div class="secondary"><xsl:value-of select="@name" /></div>
                </a>
            </li>
        </xsl:when>
        <xsl:otherwise>
            <li class="withHelp">
                <a class="CompendiumLink" href="{@url}" target="generate-id(@name)">
                    <div class="primary"><xsl:value-of select="@name" /></div>
                    <div class="secondary">
                        <xsl:value-of select="@equippedcount" />
                        of
                        <xsl:value-of select="@count" />
                    </div>
                </a>
            </li>
        </xsl:otherwise>
    </xsl:choose>
    <li class="noTop" style="display:none; cursor:pointer; margin-top:-6px; padding-top:0;"
     onclick="Effect.toggle($(this).down('.tertiary'), 'blind', {{duration:.2}});">
        <form class="NotesForm" style="display:inline;margin:0;padding:0;" >
            <input type="hidden" name="name" value="{@name}" />
            <div class="secondary" style="float:left; margin-left:12px;">
                Notes
                <small>&#9660;</small>
            </div>
            <div class="tertiary">
                <pre style="
                    white-space: pre-wrap; /* css-3 */
                    white-space: -moz-pre-wrap !important; /* Mozilla, since 1999 */
                    white-space: -pre-wrap; /* Opera 4-6 */
                    white-space: -o-pre-wrap; /* Opera 7 */
                    word-wrap: break-word; /* Internet Explorer 5.5+ */
                ">
                </pre>
            </div>
        </form>
    </li>
</xsl:template>

<!-- ABILITIES -->

<xsl:template name="tableAbilityScores">
    <table id="abilitiesTable">
        <tr>
            <xsl:for-each select="AbilityScores/AbilityScore">
                <th><xsl:value-of select="@abbreviation" /></th>
            </xsl:for-each>
        </tr>
        <tr>
            <xsl:for-each select="AbilityScores/AbilityScore">
                <td><xsl:value-of select="AbilityModifier/@modifier" /></td>
            </xsl:for-each>
        </tr>
    </table>
</xsl:template>

<xsl:template match="AbilityScores" mode="div">
    <div style="display:none;" class="jPintPage EdgedList HasTitle" id="{../@key}abilities">
                <ul>
                    <xsl:apply-templates select="AbilityScore" mode="listitem" />
                </ul>
    </div>
</xsl:template>

<xsl:template match="AbilityScore" mode="listitem">
    <li class="Roller {AbilityModifier/@dice-class}">
        <div class="primary">
            <xsl:value-of select="@abbreviation" />
            <xsl:text>&#xA;</xsl:text>
            <span style="color: #324F85;">
                <xsl:value-of select="@value" />
            </span>
        </div>
        <div class="secondary">
            <xsl:value-of select="AbilityModifier/@modifier" />
            /
            <xsl:value-of select="AbilityModifier/@rollmodifier" />
        </div>
        <div class="tertiary">
            <xsl:apply-templates select="Factor[not(contains(@name, 'Level '))]" />
            <xsl:if test="Factor[contains(@name, 'Level ')]">
                <div>
                    <div class="FactorModifier">
                        +<xsl:value-of select="count(Factor[contains(@name, 'Level ')])" />
                    </div>
                    Level<xsl:if test="count(Factor[contains(@name, 'Level ')]) > 1">s</xsl:if>
                    <xsl:for-each select="Factor[contains(@name, 'Level ')]">
                        <xsl:text>&#xA;</xsl:text>
                        <xsl:value-of select="substring(@name, 6)" />
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>
                </div>
                <xsl:apply-templates select="Condition" />
            </xsl:if>
        </div>
    </li>
</xsl:template>

<!-- WEAPON PROFICIENCIES -->

<xsl:template match="Proficiencies" mode="listitems">
    <li>
        <xsl:if test="WeaponProficiencies/ProficiencyGroup">
            <xsl:attribute name="class">withArrow</xsl:attribute>
            <a href="#{../@key}weaponproficiencies">
                <div class="primary">Weapon Proficiencies</div>
                <div class="tertiary">
                    <xsl:for-each select="WeaponProficiencies/ProficiencyGroup">
                        <xsl:text>&#xA;</xsl:text>
                        <xsl:value-of select="@name" />
                        <xsl:text>&#xA;</xsl:text>
                            (<xsl:value-of select="@source" />)
                        <xsl:if test="position()!=last()">,</xsl:if>
                    </xsl:for-each>
                    <xsl:call-template name="proficiencycommalist">
                        <xsl:with-param name="proficienciesholder" select="WeaponProficiencies" />
                    </xsl:call-template>
                </div>
            </a>
        </xsl:if>
        <xsl:if test="not(count(WeaponProficiencies/ProficiencyGroup))">
            <div class="primary">Weapon Proficiencies</div>
            <div class="tertiary">
                <xsl:call-template name="proficiencycommalist">
                    <xsl:with-param name="proficienciesholder" select="WeaponProficiencies" />
                </xsl:call-template>
            </div>
        </xsl:if>
    </li>
    <li>
        <div class="primary">Armor Proficiencies</div>
        <div class="tertiary">
            <xsl:call-template name="proficiencycommalist">
                <xsl:with-param name="proficienciesholder" select="ArmorProficiencies" />
            </xsl:call-template>
        </div>
    </li>
    <xsl:if test="ShieldProficiencies/Proficiency">
        <li>
            <div class="primary">Shield Proficiencies</div>
            <div class="tertiary">
                <xsl:call-template name="proficiencycommalist">
                    <xsl:with-param name="proficienciesholder" select="ShieldProficiencies" />
                </xsl:call-template>
            </div>
        </li>
    </xsl:if>
</xsl:template>

<xsl:template name="proficiencycommalist">
    <xsl:param name="proficienciesholder" />
    <xsl:for-each select="$proficienciesholder/Proficiency">
        <xsl:text>&#xA;</xsl:text>
        <xsl:value-of select="@name" />
        <xsl:text>&#xA;</xsl:text>
        (<xsl:value-of select="@source" />)
        <xsl:if test="position()!=last()">,</xsl:if>
    </xsl:for-each>
</xsl:template>

<xsl:template match="WeaponProficiencies" mode="div">
    <div style="display:none;" class="jPintPage EdgedList HasTitle" id="{../../@key}weaponproficiencies">
                <ul>
                    <xsl:apply-templates select="ProficiencyGroup" mode="listitem" />
                    <xsl:apply-templates select="Proficiency" mode="listitem" />
                </ul>
    </div>
</xsl:template>

<xsl:template match="ProficiencyGroup" mode="listitem">
    <li>
        <div class="primary"><xsl:value-of select="@name" /></div>
        <div class="secondary"><xsl:value-of select="@source" /></div>
        <div class="tertiary">
            <xsl:for-each select="Proficiency">
                <xsl:text>&#xA;</xsl:text>
                <xsl:value-of select="@name" />
                <xsl:if test="position()!=last()">,</xsl:if>
            </xsl:for-each>
        </div>
    </li>
</xsl:template>

<xsl:template match="Proficiency" mode="listitem">
    <li>
        <div class="primary"><xsl:value-of select="@name" /></div>
        <div class="secondary"><xsl:value-of select="@source" /></div>
    </li>
</xsl:template>

<!-- BUILD -->

<xsl:template match="Build" mode="div">
    <div style="display:none;" class="jPintPage EdgedList HasTitle" id="{../@key}build">
        <h2>
            <div>
                <xsl:value-of select="@name" />
                        <xsl:text>&#xA;</xsl:text>
                <xsl:value-of select="@level" />
            </div>
        </h2>
        <ul>
            <li>
                <div class="primary">Level</div>
                <div class="secondary">
                    <xsl:value-of select="@level" />
                </div>
            </li>
            <li>
                <div class="primary">Experience</div>
                <div class="secondary">
                    <input style="display:none;" class="{../@safe-key}EditorOnly SecondaryButton" type="button" value="+" 
                     onclick="{@experience-prompt-script}" />
                    <span class="ExperiencePoints">
                        <xsl:value-of select="@experience" />
                    </span>
                </div>
            </li>
            <li>
                <div class="primary">Power Source</div>
                <div class="secondary"><xsl:value-of select="@powersource" /></div>
            </li>
            <li>
                <div class="primary">Role</div>
                <div class="secondary"><xsl:value-of select="@role" /></div>
            </li>
	    <li>
	      <div class="primary">Physical Build</div>
	      <div class="secondary"><xsl:value-of select="../Description/@weight" />, <xsl:value-of select="../Description/@height" /></div>
	    </li>
        </ul>
        <xsl:apply-templates select="*" mode="list" />
    </div>
</xsl:template>

<xsl:template match="Build/*" mode="list">
    <h2>
        <div>
            <a href="{@url}" target="{generate-id(@name)}">
                <div class="HelpH2Link"><img src="/145541695845/images/question_frame.png" /></div>
                <xsl:value-of select="@name" />
            </a>
        </div>
    </h2>
    <ul>
        <li style="display:none; cursor:pointer;"
         onclick="Effect.toggle($(this).down('.tertiary'), 'blind', {{duration:.2}});">
            <form class="NotesForm" style="display:inline;margin:0;padding:0;" >
                <input type="hidden" name="name" value="{@name}" />
                <div class="primary">
                    Notes
                </div>
                <div class="secondary">
                    <small>&#9660;</small>
                </div>
                <div class="tertiary">
                    <pre style="
                        white-space: pre-wrap; /* css-3 */
                        white-space: -moz-pre-wrap !important; /* Mozilla, since 1999 */
                        white-space: -pre-wrap; /* Opera 4-6 */
                        white-space: -o-pre-wrap; /* Opera 7 */
                        word-wrap: break-word; /* Internet Explorer 5.5+ */
                    ">
                    </pre>
                </div>
            </form>
        </li>

        <xsl:apply-templates select="Feature" mode="listitem" />
    </ul>
</xsl:template>

<xsl:template match="Feature" mode="listitem">
    <li onclick="Effect.toggle($(this).down('.tertiary'), 'blind', {{duration:.2}});">
        <div class="primary"><xsl:value-of select="@name" /></div>
        <xsl:if test="@description != ''">
            <div class="secondary">
                <small>&#9660;</small>
            </div>
            <div style="display:none;" class="tertiary"><xsl:value-of select="@description" /></div>
        </xsl:if>
    </li>
</xsl:template>

<!-- FEATS -->

<xsl:template match="Feats" mode="div">
    <div style="display:none;" class="jPintPage EdgedList HasTitle" id="{../@key}feats">
                <ul>
                    <xsl:apply-templates select="Feat" mode="listitem" />
                </ul>
    </div>
</xsl:template>

<xsl:template match="Feat" mode="listitem">
    <li class="withHelp">
        <a class="CompendiumLink" href="{@url}" target="{generate-id(@name)}">
            <div class="primary"><xsl:value-of select="@name" /></div>
            <div class="tertiary"><xsl:value-of select="@description" /></div>
        </a>
    </li>
    <li class="noTop" style="display:none; cursor:pointer; margin-top:-6px; padding-top:0;"
     onclick="Effect.toggle($(this).down('.tertiary'), 'blind', {{duration:.2}});">
        <form class="NotesForm" style="display:inline;margin:0;padding:0;" >
            <input type="hidden" name="name" value="{@name}" />
            <div class="secondary" style="float:left; margin-left:24px;">
                Notes
                <small>&#9660;</small>
            </div>
            <div class="tertiary">
                <pre style="
                    white-space: pre-wrap; /* css-3 */
                    white-space: -moz-pre-wrap !important; /* Mozilla, since 1999 */
                    white-space: -pre-wrap; /* Opera 4-6 */
                    white-space: -o-pre-wrap; /* Opera 7 */
                    word-wrap: break-word; /* Internet Explorer 5.5+ */
                ">
                </pre>
            </div>
        </form>
    </li>
</xsl:template>

<!-- FACTORS and CONDITIONS -->

<xsl:template match="Factor">
    <div>
        <div class="FactorModifier">
            <xsl:value-of select="@modifier" />
        </div>
        <xsl:text>&#xA;</xsl:text>
        <xsl:value-of select="@name" />
    </div>
</xsl:template>

<xsl:template match="Condition">
    <div class="ConditionFactorWrapper">
        <div class="FactorModifier">
            <xsl:value-of select="@modifier" />
        </div>
        <xsl:text>&#xA;</xsl:text>
        <xsl:value-of select="@name" />
    </div>
</xsl:template>

<!-- DESCRIPTION -->

<xsl:template match="Description/*" mode="listitem">
        <li>
            <div class="primary"><xsl:value-of select="name()" /></div>
            <div class="tertiary">
                <span class="{../../@safe-key}BeforeEditorKnown CUR_{name()}">
                    <xsl:call-template name="break">
                        <xsl:with-param name="text" select="node()" />
                    </xsl:call-template>
                </span>
                <span class="{../../@safe-key}NotEditor CUR_{name()}" style="display:none;">
                    <xsl:call-template name="break">
                        <xsl:with-param name="text" select="node()" />
                    </xsl:call-template>
                </span>
                <span class="{../../@safe-key}EditorOnly" style="display:none;">
                    <textarea wrap="hard" style="height:13em; width:95%;" class="CUR_{name()}"
                     onblur="var theChar = CHARACTER{../../@safe-key}; var newVal = $(this).value; var oldVal = theChar.get('CUR_{name()}'); var isChanged = (oldVal != newVal); $(this).up().select('input').invoke( isChanged ? 'removeClassName' : 'addClassName', 'UnchangedButton');"
                    ><xsl:value-of select="node()" /></textarea>
                    <input type="button" class="DamageButton DescriptionButton UnchangedButton" 
                     onclick="var theChar = CHARACTER{../../@safe-key}; var newVal = $(this).previous('textarea').value; theChar.set('CUR_{name()}', newVal); theChar.save();  $(this).up().select('input').invoke('addClassName', 'UnchangedButton'); return false;"
                     value="Save {name()}"
                    />
                    <input type="button" class="DamageButton DescriptionButton UnchangedButton" 
                     onclick="var theChar = CHARACTER{../../@safe-key}; $(this).previous('textarea').value = theChar.get('CUR_{name()}'); $(this).up().select('input').invoke('addClassName', 'UnchangedButton'); return false;"
                     value="Undo Changes"
                    />
                </span>
            </div>
        </li>
</xsl:template>

<!-- MISCELLANEOUS -->

<xsl:template name="commalist">
    <xsl:param name="itemlist" />
    <xsl:for-each select="$itemlist">
        <xsl:text>&#xA;</xsl:text>
        <xsl:value-of select="@name" />
        <xsl:if test="position()!=last()">,</xsl:if>
    </xsl:for-each>
</xsl:template>

<xsl:template name="h1">
    <xsl:param name="character" />
    <h1>
        <div class="IP4Sync IP4SyncPrompt">
        </div>

        <div class="Subtitle">
            <span id="loginLogoutLinks">
                <a href="#" class="IP4Login" style="display:none;">login</a>
                <a href="#" class="IP4Logout" style="display:none;">logout</a>
            </span>
            <a id="iplay4eLink" target="iplay4e" href="/characters/{$character/@key}">iplay4e</a>
            <script type="text/javascript" language="javascript">
                // The iplay4e link usually goes to the full character view,
                // but on mobile devices should go to main page instead.
                if (requestIsMobile())
                {   
                    $('iplay4eLink').observe('click', function(e)
                    {   e.stop();
                        document.location = '/';
                    });
                    //$('iplay4eLink').href = '/';
                    //$('iplay4eLink').target = '';
                }
            </script>
        </div>
        <span style="margin-left:12px;"><xsl:value-of select="$character/@name" /></span>

        <br />

        <div class="OperaTitlePageLinks" style="display:none;">
            <a class="Die" href="#{$character/@key}dice">Dice</a>
            <a class="TitleNav TitleNavBuild Active" href="#{$character/@key}build"
             title="Build (level, XP, race, class, paragon path, epic destiny)">Build</a>
            <a class="TitleNav TitleNavMain" href="#{$character/@key}main"
             title="Other (feats, skills, abilities, alignment, vision, size, languages, proficiencies)">Etc.</a>
            <a class="TitleNav TitleNavLoot" href="#{$character/@key}loot"
             title="Loot (money, daily magic item uses, armor, weapons, magic items, equipment)">Loot</a>
            <a class="TitleNav TitleNavCombat" href="#{$character/@key}combat"
             title="Combat (initiative, speed, defenses, conditions, HP, surges, rest, immediate actions)">Fight</a>
            <a class="TitleNav TitleNavPowers" href="#{$character/@key}powers"
             title="Powers (by action type and usage)">Powers</a>
            <xsl:text>&#160;</xsl:text>
        </div>

        <div class="TitlePageLinks">
            <a class="Die" href="#{$character/@key}dice"><img src="/145541695845/images/d2024px.png" /></a>
            <a class="TitleNav TitleNavBuild Active" href="#{$character/@key}build" style="margin-left:11px;"
             title="Build (level, XP, race, class, paragon path, epic destiny)"><img src="/145541695845/images/build.png" /></a>
            <a class="TitleNav TitleNavMain" href="#{$character/@key}main"
             title="Other (feats, skills, abilities, alignment, vision, size, languages, proficiencies)"><img src="/145541695845/images/lists.png" /></a>
            <a class="TitleNav TitleNavLoot" href="#{$character/@key}loot"
             title="Loot (money, daily magic item uses, armor, weapons, magic items, equipment)"><img src="/145541695845/images/loot.png" /></a>
            <a class="TitleNav TitleNavCombat" href="#{$character/@key}combat"
             title="Combat (initiative, speed, defenses, conditions, HP, surges, rest, immediate actions)"><img src="/145541695845/images/combat.png" /></a>
            <a class="TitleNav TitleNavPowers" href="#{$character/@key}powers"
             title="Powers (by action type and usage)"><img src="/145541695845/images/powers.png" /></a>
            <xsl:text>&#160;</xsl:text>
        </div>

    </h1>
</xsl:template>

<xsl:template name="break">
    <xsl:param name="text" select="."/>
    <xsl:choose>
    <xsl:when test="contains($text, '&#xa;')">
        <xsl:value-of select="substring-before($text, '&#xa;')"/>
        <br/>
        <xsl:call-template name="break">
            <xsl:with-param name="text" select="substring-after($text, '&#xa;')" />
        </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
    <xsl:value-of select="$text"/>
    </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
