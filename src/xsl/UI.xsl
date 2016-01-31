<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" encoding="ISO-8859-1" indent="yes"
 doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
 doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

<xsl:template name="ResultMenuLink">
    <xsl:param name="icon" select="''" />
    <xsl:param name="underline" select="'yes'" />
    <xsl:param name="copyTitle" select="''" />
    <xsl:param name="shortTitle" select="''" />
    <xsl:param name="longTitle" select="''" />
    <xsl:param name="content" select="''" />
    <xsl:param name="contentStyle" select="''" />
    <xsl:param name="titleStyle" select="''" />
    <xsl:param name="titleClass" select="''" />
    <xsl:param name="holderStyle" select="''" />
    <span class="IconHolder" style="{$holderStyle}">
        <a href="#" class="IconLink {$titleClass}" style="{$titleStyle}">
            <xsl:if test="$icon!=''">
                <img src="/TIME_TOKEN/images/{$icon}" />
            </xsl:if>
	    <!--<img src="{$icon}" />-->
            <xsl:choose>
                <xsl:when test="$underline='yes'">
                    <u><xsl:copy-of select="$copyTitle" /><xsl:value-of select="$shortTitle" /></u>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="$copyTitle" /><xsl:value-of select="$shortTitle" />
                </xsl:otherwise>
            </xsl:choose>
            <small>&#9660;</small>
        </a>
        <div class="CombatantContent" style="{$contentStyle}">
            <xsl:if test="$longTitle!=''">
                <h2>
                    <div class="LastRight" style="width:100%; text-align:left;">
                        <div class="FirstLeft" style="padding-left:.6em;">
                            <xsl:copy-of select="$longTitle" />
                        </div>
                    </div>
                </h2>
            </xsl:if>
            <xsl:copy-of select="$content" />
        </div>
    </span>
</xsl:template>

<xsl:template name="AdBar">
</xsl:template>

<xsl:template name="masterControlIcons">
    <span class="ResultMenuLinks" id="masterControlIcons">
        <span class="IconHolder">
            <a href="#" class="IconLink" 
             onclick="viewAllCharacters('fullold', {{newWindows:true}});return false;">
                <img src="/TIME_TOKEN/images/eye.png" />
                <u>Open in new windows</u>
            </a>
        </span>
    </span>
    <script type="text/javascript" language="javascript">
        viewAllCharacters = function(styleSheet, options)
        {   var options = options || {};

            <xsl:for-each select="*">
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
</xsl:template>

<xsl:template match="Campaign" mode="header">
    <head>
        <title><xsl:value-of select="@name" /> - iplay4e</title>
        <xsl:apply-templates select="." mode="metatags" />
        <xsl:apply-templates select="." mode="cssfiles" />
        <script type="text/javascript" language="javascript" src="/TIME_TOKEN/js/combo.js"></script>
        <script type="text/javascript" language="javascript">
            connectQuestionsToAnswers();
            Event.observe(document, 'dom:loaded', function() 
            {   
                pageAuth();
                initializeCampaign('<xsl:value-of select="@key" />', '<xsl:value-of select="@safe-key" />');
                protectMenusFromIE();
            } );
        </script>
    </head>
</xsl:template>

<xsl:template match="Campaign" mode="controlIcons">
<span class="NotNative">
    <span class="ResultMenuLinks" id="{@key}resultMenuLinks">
        <span class="{@safe-key}OwnerOnly" style="display:none;">
            <xsl:call-template name="ResultMenuLink">
                <xsl:with-param name="icon" select="'folder_open_document.png'" />
                <xsl:with-param name="shortTitle" select="'File'" />
                <xsl:with-param name="content">
                    <xsl:apply-templates select="." mode="deleteMenuItem" />
                    <xsl:if test="Characters/Character">
                        <xsl:apply-templates select="." mode="downloadAllMenuItem" />
                    </xsl:if>
                </xsl:with-param>
            </xsl:call-template>
        </span>
        <xsl:call-template name="ResultMenuLink">
            <xsl:with-param name="icon" select="'chain.png'" />
            <xsl:with-param name="shortTitle" select="'Link / Embed'" />
            <xsl:with-param name="content">
                <xsl:apply-templates select="." mode="epicWordsMenuItem" />
                <xsl:apply-templates select="." mode="keyMenuItem" />
                <xsl:apply-templates select="." mode="gadgetMenuItem" />
                <xsl:apply-templates select="." mode="anySiteMenuItem" />
                <xsl:apply-templates select="." mode="permalinkMenuItem" />
            </xsl:with-param>
        </xsl:call-template>
        <span class="{@safe-key}OwnerOnly" style="display:none;">
            <span class="{@safe-key}PublicOnly" style="display:none;">
                <xsl:call-template name="ResultMenuLink">
                    <xsl:with-param name="icon">lock-unlock.png</xsl:with-param>
                    <xsl:with-param name="shortTitle" select="'Share'" />
                    <xsl:with-param name="content">
                        <xsl:apply-templates select="." mode="visibilityMenuItem" />
                    </xsl:with-param>
                </xsl:call-template>
            </span>
            <span class="{@safe-key}PrivateOnly" style="display:none;">
               <xsl:call-template name="ResultMenuLink">
                <xsl:with-param name="icon">lock.png</xsl:with-param>
                <xsl:with-param name="shortTitle" select="'Share'" />
                <xsl:with-param name="content">
                  <xsl:apply-templates select="." mode="visibilityMenuItem" />
                </xsl:with-param>
               </xsl:call-template>
            </span>
        </span>
    </span>
    <xsl:apply-templates select="." mode="hostUrlScript" />
</span>
</xsl:template>

<xsl:template match="Campaign" mode="subtitle">
    <xsl:value-of select="@subtitle" />
</xsl:template>

<xsl:template match="Character" mode="subtitle">
    <xsl:value-of select="@subtitle" />
</xsl:template>

<xsl:template match="Character" mode="initscript">
    <script type="text/javascript" language="javascript">
        connectQuestionsToAnswers();
        Event.observe(document, 'dom:loaded', function() 
        {   
            protectMenusFromIE();
            sizeParentIframeToMyContainer();
            pageAuth();
            initializeCharacter(
                '<xsl:value-of select="@key" />', '<xsl:value-of select="@safe-key" />', {confirmRests: 1}); 
            initializeCompendiumBrowser();
        } );
    </script>
</xsl:template>

<xsl:template match="Character" mode="controlIcons">
<span class="NotNative">
    <span class="ResultMenuLinks" id="{@key}resultMenuLinks">
        <xsl:call-template name="ResultMenuLink">
            <xsl:with-param name="icon" select="'folder_open_document.png'" />
            <xsl:with-param name="shortTitle" select="'File'" />
            <xsl:with-param name="content">
                <span class="{@safe-key}OwnerOnly" style="display:none;">
                    <xsl:apply-templates select="." mode="uploadMenuItem" />
                </span>
                <xsl:apply-templates select="." mode="downloadMenuItem" />
                <xsl:apply-templates select="." mode="printMenuItem" />
                <xsl:apply-templates select="." mode="exportMenuItem" />
                <span class="{@safe-key}OwnerOnly" style="display:none;">
                    <xsl:apply-templates select="." mode="deleteMenuItem" />
                </span>
                <span class="AdminOnly" style="display:none;">
                    <xsl:apply-templates select="." mode="changeOwnerMenuItem" />
                </span>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="ResultMenuLink">
            <xsl:with-param name="icon" select="'chain.png'" />
            <xsl:with-param name="shortTitle" select="'Link / Embed'" />
            <xsl:with-param name="content">
                <xsl:apply-templates select="." mode="epicWordsMenuItem" />
                <xsl:apply-templates select="." mode="keyMenuItem" />
                <xsl:apply-templates select="." mode="gadgetMenuItem" />
                <xsl:apply-templates select="." mode="anySiteMenuItem" />
                <xsl:apply-templates select="." mode="permalinkMenuItem" />
            </xsl:with-param>
        </xsl:call-template>
        <span class="{@safe-key}OwnerOnly" style="display:none;">
            <span class="{@safe-key}PublicOnly" style="display:none;">
                    <xsl:call-template name="ResultMenuLink">
	              <xsl:with-param name="icon">lock-unlock.png</xsl:with-param>
	              <xsl:with-param name="shortTitle" select="'Share'" />
	              <xsl:with-param name="content">
		        <xsl:apply-templates select="." mode="visibilityMenuItem" />
	              </xsl:with-param>
                    </xsl:call-template>
            </span>
            <span class="{@safe-key}PrivateOnly" style="display:none;">
                    <xsl:call-template name="ResultMenuLink">
	              <xsl:with-param name="icon">lock.png</xsl:with-param>
	              <xsl:with-param name="shortTitle" select="'Share'" />
	              <xsl:with-param name="content">
		        <xsl:apply-templates select="." mode="visibilityMenuItem" />
	              </xsl:with-param>
                    </xsl:call-template>
            </span>
        </span>
    </span>
    <xsl:apply-templates select="." mode="hostUrlScript" />
</span>
</xsl:template>

<xsl:template match="Character | Campaign" mode="epicWordsMenuItem">
    <div class="FAQQuestion">
        Epic Words campaign manager...
    </div>
    <div class="FAQAnswer" style="display:none;">
        <a href="http://epicwords.com" target="epicwords">Visit Epic Words campaign manager</a>
        <br />
        Embed code:<br />
        <input style="width:99%;" value="[iplay4e]{@key}[/iplay4e]" />
    </div>
</xsl:template>

<xsl:template match="Character" mode="exportMenuItem">
    <div class="FAQQuestion">
        Export XML or forums code...
    </div>
    <div class="FAQAnswer" style="display:none;">
        <a href="/view?key={@key}" target="xslsheet{@key}">IP4XML for building your own XSL</a>
        <br />
        <a href="/view?key={@key}&amp;xsl=ddi" target="sapbpsheet{@key}">D&amp;D Insider forums code</a>
        <br />
        <a href="/view?key={@key}&amp;xsl=somethingawful" target="sapbpsheet{@key}">Something Awful forums code</a>
    </div>
</xsl:template>

<xsl:template match="Character" mode="downloadMenuItem">
    <div class="FAQQuestion">
        <a href="/download?key={@key}" 
         title="Download dnd4e file for the Character Builder">Download Character Builder file</a>
    </div>
    <div class="FAQAnswer" style="display:none;">
    </div>
</xsl:template>

<xsl:template match="Character" mode="printMenuItem">
    <div class="FAQQuestion">
        <a href="http://laughterforever.com/ip4/launcher.html?key={@key}&amp;action=shados" 
         target="shados"
         title="Print using Shado's Sheet Generator">Print using Shado's Sheet Generator</a>
    </div>
    <div class="FAQAnswer" style="display:none;">
    </div>
</xsl:template>

<xsl:template match="Character" mode="changeOwnerMenuItem">
    <div class="FAQQuestion">
        Change Owner...
    </div>
    <div class="FAQAnswer" style="display:none;">
        <form action="/changeowner" method="POST" enctype="multipart/form-data">
            <input type="hidden" name="key" value="{@key}" />
            <input type="text" name="owner" />
            <br />
            <input type="submit" value="Change Owner" />
        </form>
    </div>
</xsl:template>

<xsl:template match="Character" mode="uploadMenuItem">
    <div class="FAQQuestion">
        Upload replacement dnd4e file...
    </div>
    <div class="FAQAnswer" style="display:none;">
        <iframe id="{@key}uploadIframe" name="{@key}uploadIframe" frameborder="no"
         style="padding:0;display:none;"></iframe>
        <script type="text/javascript" language="javascript">
            doUploadReplace = function(theForm)
            {
                var fileInput = theForm.down('#dnd4eData');
                if (!fileInput.value)
                {   alert('First choose a file from Character Builder (.dnd4e) or Monster Builder (.rtf)');
                    fileInput.focus();
                    return false;
                }
                var termsCheckbox = theForm.down('#acceptTerms');
                if (!termsCheckbox.checked)
                {   alert('Please read and accept the iPlay4e Terms of Use');
                    return false;
                }
                theForm.down('.Replacing').show();
                theForm.submit();
            };
        </script>
        <form target="{@key}uploadIframe" action="/replace" method="POST" 
         enctype="multipart/form-data"
        >
            <input type="hidden" name="key" value="{@key}" />
            I have read and accepted the
            <a target="terms" href="/terms/">iPlay4e Terms of Use</a>
            <input type="checkbox" id="acceptTerms" name="acceptTerms" checked="true" />
            <br />
            Choose a file from Character Builder (.dnd4e) 
            <a target="help" href="/help#management">Help!</a>
            <br />
            <input type="file" id="dnd4eData" name="dnd4eData" 
             onchange="doUploadReplace($(this).up('form'));"
            />
            <br />
            <span class="Replacing" style="display:none;">
                <img src="/TIME_TOKEN/images/DivLoadingSpinner.gif"/> Uploading, please wait...
            </span>
        </form>
    </div>
</xsl:template>

<xsl:template match="Campaign" mode="downloadAllMenuItem">
    <div class="FAQQuestion">
        <a href="/download?key={@key}" 
         title="Download dnd4e files for the Character Builder">Download Character Builder files as zip</a>
    </div>
    <div class="FAQAnswer" style="display:none;">
    </div>
</xsl:template>

<xsl:template match="Character | Campaign" mode="deleteMenuItem">
    <div class="FAQQuestion">
        <a href="#" onclick="
            if (!confirm('Are you sure?')) return false;
            new Ajax.Request('/delete?key={@key}', {{method:'get'}});
            return false;
        ">Delete this <xsl:value-of select="name()" /> permanently</a>
    </div>
    <div class="FAQAnswer" style="display:none;">
    </div>
</xsl:template>

<xsl:template match="Character | Campaign" mode="hostUrlScript">
    <script type="text/javascript" language="javascript">
        var thisKey = '<xsl:value-of select="@key" />';
        hostUrl = 'http://' + document.location.host;
        $$('#' + thisKey + 'resultMenuLinks a').each(function(rml)
        {   rml.href = rml.href.replace('HOST_URL', hostUrl);
        });
        $$('#' + thisKey + 'resultMenuLinks input').each(function(rml)
        {   rml.value = rml.value.replace('HOST_URL', hostUrl);
        });
    </script>
</xsl:template>

<xsl:template match="Character | Campaign" mode="anySiteMenuItem">
    <div class="FAQQuestion">
        Any Site (copy-and-paste HTML)...
    </div>
    <div class="FAQAnswer" style="display:none;">
        <select onchange="var ggs = $$('.anySiteSection'); ggs.invoke('hide'); ggs[this.selectedIndex].show();">
            <option>Expanded view</option>
            <option>Collapsed view</option>
            <option>Mobile view</option>
        </select>
        Copy and paste this HTML into your page source:<br />
        <span class="anySiteSection">
            <input style="width:99%;" value="&lt;iframe src=&quot;HOST_URL/view?xsl=fullold&amp;key={@key}&quot; style=&quot;width:970px;border:none; height:645px; padding:0;&quot; frameborder=&quot;no&quot;&gt;&lt;/iframe&gt;" />
        </span>
        <span class="anySiteSection" style="display:none;">
            <input style="width:99%;" value="&lt;iframe src=&quot;HOST_URL/view?xsl=combatbar&amp;key={@key}&quot; style=&quot;width:970px;border:none; height:100px; padding:0;&quot; frameborder=&quot;no&quot;&gt;&lt;/iframe&gt;" />
        </span>
        <span class="anySiteSection" style="display:none;">
            <input style="width:99%;" value="&lt;iframe src=&quot;HOST_URL/view?xsl=jPint&amp;key={@key}&quot; style=&quot;width:335px;border:none; height:520px; padding:0;&quot; frameborder=&quot;no&quot;&gt;&lt;/iframe&gt;" />
        </span>
    </div>
</xsl:template>

<xsl:template match="Character | Campaign" mode="visibilityMenuItem">
    <!-- We have to do this twice; once for search results, once for embedded campaigns. -->
    <span class="{@safe-key}PublicOnly" style="display:none;">
        <div class="FAQQuestion">
            <u><a href="/privatize?key={@key}">Visibility: Public.  Make private...</a></u>
        </div>
        <div class="FAQAnswer" style="display:none;">
        </div>
    </span>
    <script type="text/javascript" language="javascript">
        doMakePublic = function(theForm)
        {
            var termsCheckbox = theForm.down('#acceptTerms');
            if (!termsCheckbox.checked)
            {   alert('Please read and accept the iPlay4e Terms of Use');
                return false;
            }
            return true;
        };
    </script>
    <span class="{@safe-key}PrivateOnly" style="display:none;">
        <div class="FAQQuestion">
            Visibility: Private. Make public...
        </div>
        <div class="FAQAnswer" style="display:none;">
            <form action="/publicize" method="POST" enctype="multipart/form-data"
             onsubmit="return doMakePublic(this);">
                Public items can be found using search.
                <br />

                <input type="checkbox" id="acceptTerms" name="acceptTerms" checked="true" />
                I have read and accepted the <a href="#">iPlay4e Terms of Use</a>
                <br />

                <input type="hidden" name="key" value="{@key}" />
                <input type="submit" value="Make public" />
            </form>
        </div>
    </span>
</xsl:template>

<xsl:template match="Character | Campaign" mode="keyMenuItem">
    <xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable> 
    <xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
    <div class="FAQQuestion">
        Key for Masterplan / other 3rd party tools...
    </div>
    <div class="FAQAnswer" style="display:none;">
        <a href="http://www.habitualindolence.net/masterplan/" target="masterplan">Visit Masterplan web site</a>
        <br />
        Cut and paste this <xsl:value-of select="translate(name(), $upper, $lower)" /> key:<br />
        <input style="width:99%;" value="{@key}" /><br />
        <i>Note: your <xsl:value-of select="translate(name(), $upper, $lower)" /> must 
           be public for most 3rd party tools to work</i>
    </div>
</xsl:template>

<xsl:template match="Character | Campaign" mode="permalinkMenuItem">
    <xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable> 
    <xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
    <div class="FAQQuestion">
        Permalink...
    </div>
    <div class="FAQAnswer" style="display:none;">
        Copy and paste this link into emails or posts:<br />
        <input style="width:99%;" value="HOST_URL/{translate(name(), $upper, $lower)}s/{@key}" />
    </div>
</xsl:template>

<xsl:template match="Character | Campaign" mode="gadgetMenuItem">
    <div class="FAQQuestion">
        Gadget for Google Wave, Google Desktop, or iGoogle...
    </div>
    <div class="FAQAnswer" style="display:none;">
        <div style="float:right">
            (<a target="iGoogle" href="http://www.google.com/ig/adde?moduleurl=HOST_URL/googleGadget%3Fkey%3D{@key}%26source%3Dimag">Add to iGoogle now</a>)
        </div>
        <span style="margin-right:300px">Gadget URL &#8595;</span>
        <br />
        <input style="width:99%;" value="HOST_URL/googleGadget?key={@key}" />
        <br />
        <i>
            Note: the Google Gadget displays the mobile interface by default on your iGoogle home page.<br/>
            It displays the expanded interface when you expand the Gadget.<br/>
            In Google Wave, the expanded interface is always displayed.<br/>
        </i>
    </div>
</xsl:template>

<xsl:template match="Character | Campaign" mode="metatags">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta http-equiv="Content-Style-Type" content="text/css" />
    <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />
    <meta name="viewport" content="user-scalable=no, width=device-width" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
</xsl:template>

<xsl:template match="Character | Campaign" mode="cssfiles">
    <link rel="stylesheet" href="/TIME_TOKEN/css/combo.css" type="text/css" media="screen, projection" />
    <link rel="stylesheet" href="/TIME_TOKEN/css/blueprint/print.css" type="text/css" media="print" />
    <!--[if lt IE 8]><link rel="stylesheet" href="/TIME_TOKEN/css/blueprint/ie.css" type="text/css" media="screen, projection" /><![endif]-->
</xsl:template>

<xsl:template match="Character" mode="initiativeAndSpeed">
            <span class="Button DamageButton {@safe-key}BeforeEditorKnown"
                style="float:none; font-weight:bold; margin:16px 4px 0 0; padding:2px;">
                Init
                <span class="WithFactors" >
                    <xsl:attribute name="title">
                        <xsl:apply-templates select="Movement/Initiative/Factor" />
                        <xsl:apply-templates select="Movement/Initiative/Condition" />
                        </xsl:attribute>
                    +<xsl:value-of select="Movement/Initiative/@value" />
                </span>
            </span>
            <span class="Button DamageButton {@safe-key}NotEditor"
                style="display:none; float:none; font-weight:bold; margin:16px 4px 0 0; padding:2px;">
                Init
                <span class="WithFactors" >
                    <xsl:attribute name="title">
                        <xsl:apply-templates select="Movement/Initiative/Factor" />
                        <xsl:apply-templates select="Movement/Initiative/Condition" />
                        </xsl:attribute>
                    +<xsl:value-of select="Movement/Initiative/@value" />
                </span>
            </span>
            <span class="Roller Button DamageButton {@safe-key}EditorOnly {Movement/Initiative/@dice-class}" 
                style="display:none;font-size:1em; float:none; font-weight:bold; margin:16px 4px 0 0; padding:2px;">
                Init
                <span class="WithFactors" >
                    <xsl:attribute name="title">
                        <xsl:apply-templates select="Movement/Initiative/Factor" />
                        <xsl:apply-templates select="Movement/Initiative/Condition" />
                        </xsl:attribute>
                    +<xsl:value-of select="Movement/Initiative/@value" />
                </span>
            </span>
            Speed
            <span class="WithFactors">
                <xsl:attribute name="title">
                    <xsl:apply-templates select="Movement/Speed/Factor" />
                    <xsl:apply-templates select="Movement/Speed/Condition" />
                </xsl:attribute>
                <xsl:value-of select="Movement/Speed/@value" />
            </span>
</xsl:template>

<xsl:template match="Character" mode="utilities">
    <div id="preloader">
        <img src="/TIME_TOKEN/images/DivLoadingSpinner.gif" />
        <img src="/TIME_TOKEN/images/exclamation-red-16.png" />
    </div>
    <div class="IP4Sync IP4SyncPrompt {@safe-key}EditorOnly" style="display:none;">
        <xsl:text>&#xA0;&#xA0;&#xA0;&#xA0;</xsl:text>
    </div>
    <span class="NotNative">
        |
        <span class="ResultMenuLinks">
            <xsl:call-template name="ResultMenuLink">
                <xsl:with-param name="icon" select="'eye.png'" />
                <xsl:with-param name="titleStyle" select="'margin-left:4px;'" />
                <xsl:with-param name="shortTitle" select="'View'" />
                <xsl:with-param name="contentStyle" select="'left:-140px;'" />
                <xsl:with-param name="content">
                    <span id="viewSwitchers">
                        <div class="FAQQuestion">
                            <a href="/view?xsl=fullold&amp;key={@key}" target="_blank">
                                Open in new window
                            </a>
                        </div>
                        <div class="FAQQuestion">
                            <a href="/view?xsl=jPint&amp;key={@key}" target="_blank">
                                Open mobile view in new window
                            </a>
                        </div>
                    </span>
    </xsl:with-param>
            </xsl:call-template>
        </span>
    </span>
    <span class="NotNative">
        <span> | </span>
        <xsl:call-template name="lightboxLink">
            <xsl:with-param name="lightboxObject" select="." />
            <xsl:with-param name="targetIframe" select="'iframeHelp'" />
            <xsl:with-param name="title" select="'Help!'" />
            <xsl:with-param name="titleClass" select="'HelpLink'" />
            <xsl:with-param name="titleStyle" select="'font-weight:bold;font-style:normal;text-decoration:underline;'" />
            <xsl:with-param name="divClass" select="''" />
            <xsl:with-param name="divStyle" select="'display:inline;margin-right:0;padding-right:0;text-decoration:none;'" />
        </xsl:call-template>
        <span class="ForeignOnly" style="display:none;">
            |
            <u><a class="SignInOut last" href="#">Sign In</a></u>
        </span>
    </span>
</xsl:template>

<xsl:template match="Character" mode="dice">
    <div class="span-8" style="position:relative;">
    <script>
        updateCustomRoller = function(theSelect) {
            var containerDiv = $(theSelect).up('div');

            var theSelects = containerDiv.select('select');
            var numDice = theSelects[0].options[theSelects[0].selectedIndex].innerHTML;
            var dieSize = theSelects[1].options[theSelects[1].selectedIndex].innerHTML;
            var plusAmount = containerDiv.select('.CustomRollBonus')[0].value;
            var theReason = containerDiv.down('.CustomRollDescription').value.replace(/ /g, '_') || 'Custom';

            var theRoller = containerDiv.down('.Roller');
            var rollerClassNames = $w(theRoller.className);
            for (var i=0; i&lt;rollerClassNames.length; i++) {{
                if (rollerClassNames[i].substring(0, 4) == 'dice')
                    theRoller.removeClassName(rollerClassNames[i]);
            }}
            theRoller.addClassName('dice' + numDice + 'd' + dieSize + 'plus' + plusAmount + theReason);
        };
    </script>
    <form action="#" onsubmit="$(this).down('.StraightDie').fire('click'); return false;">
        <img src="/TIME_TOKEN/images/d2016px.png"
            style="position:absolute; top:3px; left:3px;"
        />
        <input type="submit" value="Roll" class="StraightDie Roller dice1d20plus0Custom"
            style="clear:none; margin:0 8px 0 0; float:left; font-size:1.3em; font-weight:bold; padding:1px 6px 1px 20px;"
        />
        <select onchange="updateCustomRoller(this);">
            <option>1</option><option>2</option><option>3</option><option>4</option><option>5</option><option>6</option><option>7</option><option>8</option><option>9</option><option>10</option>
            <option>11</option><option>12</option><option>13</option><option>14</option><option>15</option><option>16</option><option>17</option><option>18</option><option>19</option><option>20</option>
            <option>21</option><option>22</option><option>23</option><option>24</option><option>25</option><option>26</option><option>27</option><option>28</option><option>29</option><option>30</option>
        </select>
        d
        <select onchange="updateCustomRoller(this);">
            <option>2</option><option>3</option><option>4</option><option>6</option><option>8</option><option>10</option><option>12</option><option selected="true">20</option><option>100</option>
        </select>
        +
        <input style="width:20px;" id="customRollBonus{@safe-key}" class="CustomRollBonus" name="customRollBonus" value="0"
            onchange="
                if (this.value.match(/[^0-9]/)) this.value = '0';
                updateCustomRoller(this);
            "
        />
        for
        <input style="width:45px;" id="customRollDescription{@safe-key}" class="CustomRollDescription" name="customRollDescription"
            onchange="updateCustomRoller(this);"
        />
    </form>
    </div>
    <div class="span-16 last" style="overflow-x:hidden; position:relative; white-space:nowrap;">
        <xsl:apply-templates select="." mode="dicehistory" />
    </div>
</xsl:template>

<xsl:template match="Character" mode="dicehistory">
    <a href="#" class="Button DamageButton" style="position:absolute; right:-3px; bottom:-4px; padding:0 4px; font-size:.8em; width:auto;"
        onclick="
            if ($(this).next('div').getStyle('whiteSpace') == 'nowrap') {{
                $(this).next('div').setStyle({{whiteSpace:'normal'}});
                $(this).innerHTML = 'Fewer Rolls...';
            }} else {{
                $(this).next('div').setStyle({{whiteSpace:'nowrap'}});
                $(this).innerHTML = 'More Rolls...';
            }}
        "
    >More Rolls...</a>
    <div class="DiceHistoryContainer{@safe-key}" style="white-space:nowrap; float:left;">
    </div>
</xsl:template>

<xsl:template match="Character" mode="hitPointBars">
        <div class="CUR_HitPointsBar" title="Hit Point and Temp HP Bars"
         style="width:100%; background:#324420; opacity:0.15; -moz-opacity:0.15; filter:alpha(opacity=15);" >
        </div>
        <div class="{@safe-key}MonitorOnly {Health/@tempHP-bar-class} " title="Hit Point and Temp HP Bars"
         style="width:10%; background:#317839" >
        </div>
        <div class="BloodiedMarker">
            <xsl:value-of select="Health/BloodiedValue/@value" />
        </div>
</xsl:template>

<xsl:template match="Resistances" mode="list">
  <!-- Find each form of resistance (cold, fire, etc.) -->
  <xsl:if test="count(@*) &gt; 0">
    <div>
      <b>Resist </b>
      <xsl:for-each select="@*">
	<xsl:value-of select="name()" /><xsl:text> </xsl:text>
	<xsl:value-of select="." />
	<xsl:if test="position()!=last()">
	  <xsl:text>, </xsl:text>
	</xsl:if>
      </xsl:for-each>
    </div>
  </xsl:if>
</xsl:template>

<xsl:template match="Character" mode="hitPointEditor">
            <span>
                <span class="{@safe-key}BeforeEditorKnown">
                    <div style="padding:6px; font-size:1.4em; font-weight:normal; text-align:left;">
                        <span class="WithFactors">
                            <xsl:attribute name="title">
                                <xsl:apply-templates select="Health/MaxHitPoints/Factor" />
                            </xsl:attribute>
                            <xsl:value-of select="Health/MaxHitPoints/@value" />
                        </span>
                        HP
                    </div>
                </span>
                <span class="{@safe-key}NotEditor" style="display:none;">
                    <div style="padding:6px; font-size:1.4em; font-weight:normal; text-align:left;">
                        <span class="{@safe-key}NotMonitor" style="display:none;">
                            <span class="WithFactors">
                                <xsl:attribute name="title">
                                    <xsl:apply-templates select="Health/MaxHitPoints/Factor" />
                                </xsl:attribute>
                                <xsl:value-of select="Health/MaxHitPoints/@value" />
                            </span>
                            HP
                        </span>
                        <span class="{@safe-key}MonitorOnly" style="display:none;">
                            <span class="CUR_HitPoints">
                                <xsl:value-of select="Health/MaxHitPoints/@value" />
                            </span>
                            <xsl:text> of </xsl:text>
                            <span class="WithFactors">
                                <xsl:attribute name="title">
                                    <xsl:apply-templates select="Health/MaxHitPoints/Factor" />
                                </xsl:attribute>
                                <xsl:value-of select="Health/MaxHitPoints/@value" />
                            </span>
                            HP 
                            <br/>
                            + <span class="{Health/@tempHP-display-class}">0</span> Temp HP
                        </span>
                    </div>
                </span>
                <span class="{@safe-key}EditorOnly" style="display:none;">
                            <div style="padding:6px; font-size:1.4em; font-weight:normal; text-align:left;">
                                <div style="text-align:left;">
                                    <span class="CUR_HitPoints">
                                        <xsl:value-of select="Health/MaxHitPoints/@value" />
                                    </span>
                                    <xsl:text> of </xsl:text>
                                    <span class="WithFactors">
                                        <xsl:attribute name="title">
                                            <xsl:apply-templates select="Health/MaxHitPoints/Factor" />
                                        </xsl:attribute>
                                        <xsl:value-of select="Health/MaxHitPoints/@value" />
                                    </span>
                                    HP 
                                    + <span class="{Health/@tempHP-display-class}">0</span> Temp HP
                                </div>
                                <a href="#" class="Button DamageButton" 
                                    style="*padding-bottom:4px; width:150px; margin-left:0px;"
                                    onclick="{Health/MaxHitPoints/@damage-prompt-script};hideMenus();return false;"
                                ><img src="/TIME_TOKEN/images/minus_circle_small.png"
                                  style="position:relative;top:0; margin-left:2px; margin-right:2px;"
                                 />Damage</a>
                                <a href="#" class="Button DamageButton" style="*padding-bottom:4px; width:150px;"
                                 onclick="{Health/@tempHP-prompt-script};hideMenus();return false;" 
                                >Set Temp</a>
                            </div>
                </span>
            </span>
</xsl:template>

<xsl:template match="Character" mode="surgesEditorNotEditor">
                <span class="WithFactors {@safe-key}BeforeMonitorKnown">
                    <xsl:attribute name="title">
                        <xsl:apply-templates select="Health/MaxSurges/Factor" />
                    </xsl:attribute>
                    <xsl:value-of select="Health/MaxSurges/@value" />
                </span>
                <span class="WithFactors {@safe-key}NotMonitor" style="display:none;">
                    <xsl:attribute name="title">
                        <xsl:apply-templates select="Health/MaxSurges/Factor" />
                    </xsl:attribute>
                    <xsl:value-of select="Health/MaxSurges/@value" />
                </span>
                <span class="{@safe-key}MonitorOnly" style="display:none;">
                    <span class="CUR_Surges">
                        <xsl:value-of select="Health/MaxSurges/@value" />
                    </span>
                    <xsl:text> of </xsl:text>
                    <span class="WithFactors">
                        <xsl:attribute name="title">
                            <xsl:apply-templates select="Health/MaxSurges/Factor" />
                        </xsl:attribute>
                        <xsl:value-of select="Health/MaxSurges/@value" />
                    </span>
                </span>
                Surges
                <br/>
                <span class="WithFactors">
                    <xsl:attribute name="title">
                        <xsl:apply-templates select="Health/SurgeValue/Factor" />
                    </xsl:attribute>
                    <xsl:value-of select="Health/SurgeValue/@value" />
                </span>
                Surge Value
</xsl:template>

<xsl:template match="Character" mode="surgesEditor">
    <div style="padding:6px; font-size:1.4em; font-weight:normal; text-align:left;">
            <span class="{@safe-key}BeforeEditorKnown">
                <xsl:apply-templates select="." mode="surgesEditorNotEditor"/>
            </span>
            <span class="{@safe-key}NotEditor" style="display:none;">
                <xsl:apply-templates select="." mode="surgesEditorNotEditor"/>
            </span>

            <span class="{@safe-key}EditorOnly" style="display:none;">
                <span class="CUR_Surges">
                    <xsl:value-of select="Health/MaxSurges/@value" />
                </span>
                <xsl:text> of </xsl:text>
                <span class="WithFactors">
                    <xsl:attribute name="title">
                        <xsl:apply-templates select="Health/MaxSurges/Factor" />
                    </xsl:attribute>
                    <xsl:value-of select="Health/MaxSurges/@value" />
                </span>
                Surges
                (Value
                <span class="WithFactors">
                    <xsl:attribute name="title">
                        <xsl:apply-templates select="Health/SurgeValue/Factor" />
                    </xsl:attribute>
                    <xsl:value-of select="Health/SurgeValue/@value" />
                </span>)
                <br/>

                <a href="#" class="Button DamageButton" style="*padding-bottom:4px; width:150px;"
                 onclick="
                    $$('.{@safe-key}HealDiv').each(function(hd)
                    {{  hd.visible() ? hd.hide() : hd.show();
                    }});
                    return false;
                    "
                ><img src="/TIME_TOKEN/images/plus_circle_small.png"
                  style="position:relative;top:0; margin-left:2px; margin-right:2px;"
                 />Heal<small>&#9660;</small>
                </a>

                <a href="#" class="Button DamageButton" 
                    style="*padding-bottom:4px; margin-left:4px;"
                    onclick="{Health/MaxSurges/@subtract-script};return false;"
                ><img src="/TIME_TOKEN/images/minus_circle_small.png"
                  style="position:relative;top:0; margin-left:2px; margin-right:2px;"
                 />Spend
                </a>

                <a href="#" class="Button DamageButton" style="*padding-bottom:4px;"
                 onclick="{Health/MaxSurges/@add-script};return false;"
                ><img src="/TIME_TOKEN/images/plus_circle_small.png"
                  style="position:relative;top:0; margin-left:2px; margin-right:2px;"
                 />Regain</a>
            </span>
    </div>
</xsl:template>

<xsl:template match="Character" mode="powerPointsNotEditor">
  <xsl:if test="Health/PowerPoints/@value &gt; 0">
  <div style="padding:6px; font-weight:normal; text-align:left;">

      <span class="WithFactors">
	<xsl:attribute name="title">
	  <xsl:apply-templates select="Health/PowerPoints/Factor" />
	</xsl:attribute>
	<xsl:value-of select="Health/PowerPoints/@value" />
      </span>
      <xsl:text> Power Points </xsl:text>

  </div>
  </xsl:if>
</xsl:template>

<xsl:template match="Character" mode="powerPointsEditor">
  <xsl:if test="Health/PowerPoints/@value &gt; 0">
  <div style="padding:6px; font-size:1.4em; font-weight:normal; text-align:left;">
    <span class="{@safe-key}BeforeEditorKnown">
      <xsl:apply-templates select="." mode="powerPointsNotEditor"/>
    </span>

    <span class="{@safe-key}NotEditor" style="display:none;">
      <xsl:apply-templates select="." mode="powerPointsNotEditor"/>
    </span>

    <span class="{@safe-key}EditorOnly" style="display:none;">
      <span class="{Health/@power-points-display-class}">
	<xsl:value-of select="Health/PowerPoints" />
      </span>
      <xsl:text> of </xsl:text>
      <span class="WithFactors">
	<xsl:attribute name="title">
	  <xsl:apply-templates select="Health/PowerPoints/Factor" />
	</xsl:attribute>
	<xsl:value-of select="Health/PowerPoints/@value" />
      </span>
      <xsl:text> Power Points </xsl:text>

      <a href="#" class="Button DamageButton"
	 style="*padding-bottom:4px; margin-left:0px;"
	 onclick="{Health/@power-points-subtract-script};return false;">
	Spend
      </a>

      <a href="#" class="Button DamageButton"
	 style="*padding-bottom:4px; margin-left:0px;"
	 onclick="{Health/@power-points-add-script};return false;">
	Gain
      </a>

    </span>
  </div>
  </xsl:if>
</xsl:template>

<xsl:template match="Character" mode="restEditor">
            <span class="{@safe-key}EditorOnly" style="display:none;">
                <div style="padding:6px; font-size:1.4em; font-weight:normal;">
                    Rest
                    <br/>
                    <a href="#" class="Button DamageButton"
                        style="margin-left:0px;"
                        onclick="{Health/@short-rest-script};return false;">Short</a>
                    <a href="#" class="Button DamageButton"
                        onclick="{@milestone-script};return false;">Milestone</a>
                    <a href="#" class="Button DamageButton"
                        onclick="{Health/@extended-rest-script};return false;">Extended</a>
                </div>

            </span>
</xsl:template>

<xsl:template match="Character" mode="conditionsEditor">
            <div class="{@safe-key}MonitorOnly noTop CUR_HitPointsDyingOrFailedSaves" 
                style="display:none; text-align:center; margin-bottom:8px;"
            >
                Death Saves<br/>
                <a href="#" class="Button SecondaryButton {@safe-key}EditorOnly" style="display:none;"
                 onclick="{Health/@death-saves-subtract-script};return false;">-</a>
                <span class="{Health/@death-saves-display-class}"></span>
                <a href="#" class="Button SecondaryButton {@safe-key}EditorOnly" style="display:none;"
                 onclick="{Health/@death-saves-add-script};return false;">+</a>
            </div>
            <div style="padding: 13px 6px 0; font-weight:normal;">
                Conditions
                <span class="{@safe-key}BeforeEditorKnown">
                    <div> --- </div>
                </span>
                <span class="{@safe-key}NotEditor" style="display:none;">
                    <div> --- </div>
                </span>
                <span class="{@safe-key}EditorOnly" style="display:none;">
                    <br/>
                    <a href="#" 
                       class="{@safe-key}EditorOnly {@safe-key}AddConditionHref AddConditionLI Button DamageButton" 
                       style="display:none; font-size:1.4em;">Add</a>
                    <script type="text/javascript" language="javascript">
                        var safeKey = '<xsl:value-of select="@safe-key" />';
                        var conditionAdders = $$('.' + safeKey + 'Multiple' +' .' + safeKey + 'AddConditionHref');
                        conditionAdders.each(function(ca)
                        {
                            if (!ca.isClickable) // Had to do this; was somehow being called multiple times...
                            {   ca.observe('click', function(e)
                                {   e.stop();
                                    <xsl:value-of select="Health/@conditions-prompt-script" />
                                });
                                ca.isClickable = 1;
                            }
                        });
                    </script>
                </span>
            </div>
</xsl:template>

<xsl:template match="Character" mode="combatBar">
    <xsl:apply-templates select="." mode="combatBar2" />
</xsl:template>

<xsl:template match="Character" mode="combatBar2">
    <div class="span-24 last CombatantSubheader" style="z-index:999;">
        <div class="span-12 CombatantDiv" style="position:relative; font-size:1.3em;">
            <div style="margin-left:6px;">
                <xsl:apply-templates select="Defenses" mode="line" />
            </div>
        </div>
        <div class="span-4" style="text-align:right;position:relative; font-size:1.3em;">
            <xsl:apply-templates select="." mode="initiativeAndSpeed"/>
        </div>

        <div class="span-8 last" style="text-align:right;z-index:999;">
            <div class="span-8 last">
                <xsl:apply-templates select="." mode="utilities"/>
            </div>
        </div>
    </div>
    <div class="span-24 last CombatantSubheader" style="z-index:999;padding:6px 0 10px; text-align:left;"
    >
            <xsl:apply-templates select="." mode="dice"/>
    </div>
    <div class="span-24 last CombatantContent" style="position:relative; padding-bottom:6px; padding-top:12px;-webkit-box-shadow: none; font-size:1.1em; text-align:center;">
        <xsl:apply-templates select="." mode="hitPointBars"/>
	
        <div class="span-24 last" style="margin-top:-10px;">
	  <div class="span-2 CombatantDiv" style="position:relative;z-index:999; text-align:left;">
	    <xsl:apply-templates select="." mode="conditionsEditor"/>
	  </div>
	  <div class="span-6 CombatantDiv" style="position:relative;z-index:999; text-align:right;">
	    <xsl:apply-templates select="." mode="hitPointEditor"/>
	  </div>
	  <div class="span-8 CombatantDiv" style="position:relative;z-index:999; text-align:left;">
	    <xsl:apply-templates select="." mode="surgesEditor"/>
	  </div>
	  <div class="span-8 last CombatantDiv" style="position:relative;z-index:999; text-align:left;">
	    <xsl:apply-templates select="." mode="restEditor"/>
	  </div>
        </div>
	<div class="span-8 last">
	</div>
        <div class="span-24 last" style="margin-top:-10px;">
            <div class="span-2">
                <xsl:text>&#xA0;</xsl:text>
            </div>
            <div class="span-6">
                <div style="padding:6px; font-size:1.4em; font-weight:normal; text-align:left;">
				    <xsl:apply-templates select="Resistances" mode="list" />
                </div>
            </div>
            <div class="span-16 last {@safe-key}HealDiv" style="display:none; text-align:left; margin-top:12px; font-size:1.2em;">
                <form style="margin-left:10px;" action="#"
                 onsubmit="
                    hideMenus();

                    var theChar = CHARACTER{@safe-key};
                    theChar.isSaving = true;

                    if ($(this).down('.SpendSurge').checked) {{

                        var curSurges = theChar.namesToVariables['CUR_Surges'].get();
                        {Health/MaxSurges/@subtract-script};
                        if (curSurges == theChar.namesToVariables['CUR_Surges'].get()) {{
                            alert('Sorry, you have no surges to spend.');
                            $(this).up('.{@safe-key}HealDiv').hide();

                            theChar.isSaving = false;
                            return false;
                        }}
                    }}

                    if ($(this).down('.RegainValue').checked)
                        {{ {Health/SurgeValue/@toHitPoints-script}; }}
                    if ($(this).down('.BonusHealing').checked)
                        {{ {Health/MaxHitPoints/@heal-prompt-script}; }}
                    theChar.isSaving = false;
                    theChar.save();

                    $(this).up('.{@safe-key}HealDiv').hide();
                    return false;
                 "
                >
                    <div style="margin-bottom:8px;">
                        <input type="checkbox" class="SpendSurge" id="spendSurge" value="spendSurge" checked="true"
                         onclick="$(this).up('div').next().down('.RegainValue').checked = this.checked;"/>
                        <label for="spendSurge">
                            Spend surge</label>
                    </div>

                    <div style="margin-bottom:8px;">
                        <input type="checkbox" class="RegainValue" id="regainValue" value="regainValue" checked="true" />
                        <label for="regainValue">
                            + Surge Value 
                            <span class="WithFactors">
                                <xsl:attribute name="title">
                                    <xsl:apply-templates select="Health/SurgeValue/Factor" />
                                </xsl:attribute>
                                <xsl:value-of select="Health/SurgeValue/@value" />
                            </span>
                        </label>
                    </div>

                    <div style="margin-bottom:8px;">
                        <input type="checkbox" class="BonusHealing" id="bonusHealing" value="bonusHealing" checked="true" />
                        <label for="bonusHealing">
                            + extra HP
                        </label>
                    </div>

                    <div style="margin-bottom:8px;">
                        <input value="Apply" type="submit"
                         class="Button DamageButton" style="margin-left:2px; *padding-bottom:4px;"
                        />
                    </div>
                </form>
            </div>
        </div>
        <div class="span-24 last {@safe-key}MonitorOnly" style="margin-top:-10px;">
            <div style="margin-top:12px; margin-left:15px;">
                <span class="{Health/@conditions-display-class}" style="">
                </span>
	  <div class="span-8 CombatantDiv" style="position:relative;z-index:999; text-align:right;">
	    <xsl:apply-templates select="." mode="powerPointsEditor"/>
	  </div>
            </div>
        </div>
    </div>
</xsl:template>

<xsl:template name="helpDiv">
    <xsl:call-template name="lightboxTarget">
        <xsl:with-param name="lightboxObject" select="." />
        <xsl:with-param name="title">Help!</xsl:with-param>
        <xsl:with-param name="body">
            <iframe class="NoWeapons" src="/fullpageInstructions.html" style="padding:0;" frameborder="no"
             name="iframeHelp" id="iframeHelp"
            ></iframe>
        </xsl:with-param>
    </xsl:call-template>
</xsl:template>

<xsl:template match="Power" mode="actioncolor">
    <xsl:choose>
        <xsl:when test="starts-with(@powerusage, 'At-Will')">#619869</xsl:when>
        <xsl:when test="starts-with(@powerusage, 'Encounter')">#961334</xsl:when>
        <xsl:when test="starts-with(@powerusage, 'Daily')">#4D4D4F</xsl:when>
        <xsl:otherwise>#BF4C00</xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="Powers" mode="list">
    <xsl:param name="actiontype" />
    <xsl:param name="actionTitle" select="'Action'" />
    <xsl:param name="isMore" select="''" />
    <xsl:param name="noTitle" select="''" />
    <xsl:param name="emptyValue" select="'...'" />
    <xsl:if test="$noTitle=''">
        <h3>
            <xsl:value-of select="substring-before($actiontype , ' Action')" />
            <xsl:text>&#xA0;</xsl:text>
            <xsl:value-of select="$actionTitle" />
        </h3>
    </xsl:if>
    <xsl:apply-templates select="Power[starts-with(@actiontype, $actiontype) and @isMore=$isMore]" mode="listitem" />
    <xsl:if test="$emptyValue!='' and count(Power[starts-with(@actiontype, $actiontype) and @isMore=$isMore]) = 0">
        <div class="primary">
            ---
        </div>
    </xsl:if>
</xsl:template>

<xsl:template match="Power" mode="listitem">
    <xsl:if test="string-length(@url)!=0">
        <a rel="lightbox{../../@safe-key}{generate-id(@name)}"
         id="powerlink{../../@safe-key}{generate-id(@name)}" 
         class="lbOn powerlink{../../@safe-key}{generate-id(@name)}" 
         href="{@url}" target="iframe{../../@safe-key}{generate-id(@name)}">
            <div class="PowerLink">
                <div class="primary {@display-class}">
                    <xsl:attribute name="style">
                        <xsl:choose>
                            <xsl:when test="@isMore='true'">
                                color: <xsl:apply-templates select="." mode="actioncolor" />;
                            </xsl:when>
                            <xsl:otherwise>
                                background:<xsl:apply-templates select="." mode="actioncolor" />;
                                color:white;
                            </xsl:otherwise>
                        </xsl:choose>
                        font-style:italic; margin-bottom:6px;
                        padding:4px 4px; font-size:1.3em;

	                    -webkit-border-radius: 8px;		 /* Round each corner of the created rectangle */
	                    -moz-border-radius: 8px;		 /* Round each corner of the created rectangle */
                    </xsl:attribute>
                    <span class="{@display-class}">
                        <xsl:value-of select="@name" />
                    </span>
                    <xsl:if test="@name='Action Point'">
                        <span class="{@safe-key}MonitorOnly" style="display:none;">
                            (<span class="CUR_ActionPoints"></span>)
                        </span>
                    </xsl:if>
                </div>
            </div>
        </a>
        <script type="text/javascript" language="javascript">
            var charId = '<xsl:value-of select="../../@safe-key" />';
            var powerId = '<xsl:value-of select="generate-id(@name)" />';
            var powerUrl = '<xsl:value-of select="@url" />';
            var autoLoad = 0;
            <xsl:if test="not(PowerCardItem) or @isMore!='' or @name='Action Point' or @name='Second Wind'">
                autoLoad = 1;
            </xsl:if>
            activatePowerLink(charId, powerId, powerUrl, autoLoad);
        </script>
    </xsl:if>
    <xsl:if test="string-length(@url)=0">
        <!-- No link if no URL -->
            <div class="PowerLink">
                <div class="primary">
                    <xsl:attribute name="style">
                        color:<xsl:apply-templates select="." mode="actioncolor" />;
                        font-style:italic; margin-bottom:6px;
                    </xsl:attribute>
                    <span class="{@display-class}">
                        <xsl:value-of select="@name" />
                    </span>name
                </div>
            </div>
    </xsl:if>
</xsl:template>

<xsl:template match="Power" mode="div">
    <div id="power{../../@safe-key}{generate-id(@name)}">
        <div class="PowerContent leightbox" id="lightbox{../../@safe-key}{generate-id(@name)}">
            <div class="Score">
                <span class="secondary" style="text-align:right;">
                    <xsl:if test="@source">
                        <p style="color:white; margin-bottom:4px;">
                            <xsl:value-of select="@source"/>
                        </p>
                    </xsl:if>
                    <xsl:if test="@use-script">
                        <a class="{../../@safe-key}EditorOnly Button UsePower" style="display:none; margin-right:0; font-size:1.2em;" 
                         onclick="{@use-script}">Use / Unuse</a>
                    </xsl:if>
                </span>
            </div>
            <h2>
                <xsl:attribute name="style">
                    padding-bottom:2px; padding-top:4px; min-height:24px;
                    background-color:<xsl:apply-templates select="." mode="actioncolor" />;
                </xsl:attribute>
                <span class="{@display-class}" style="font-size:1.2em;">
                    <xsl:value-of select="@name" />
                    <xsl:if test="contains(@actiontype, 'pecial')">
                        <xsl:text>&#xA;</xsl:text>
                        [<xsl:value-of select="@actiontype"/>]
                    </xsl:if>
                    <xsl:if test="contains(@powerusage, 'pecial')">
                        <xsl:text>&#xA;</xsl:text>
                        [<xsl:value-of select="@powerusage"/>]
                    </xsl:if>
                </span>
                <xsl:text>&#xA;</xsl:text>
                <xsl:if test="@packageurl and @packageurl!=''">
                    (<a target="iframe{generate-id(@name)}" href="{@packageurl}"><i><xsl:value-of select="@packagename" /> feature</i></a>)
                    <xsl:text>&#xA;</xsl:text>
                </xsl:if>
                <xsl:if test="@name='Action Point'">
                    - Action Points Remaining
                    <a style="display:none;" class="{../../@safe-key}EditorOnly Button SecondaryButton" onclick="{../../@action-points-subtract-script}">-</a>
                    <span class="CUR_ActionPoints"></span>
                    <a style="display:none;" class="{../../@safe-key}EditorOnly Button SecondaryButton" onclick="{../../@action-points-add-script}">+</a>
                </xsl:if>
                <xsl:if test="Weapon">
                    <select id="weapons{../../@safe-key}{generate-id(@name)}" onchange="changeWeapon('{../../@safe-key}{generate-id(@name)}');">
                        <xsl:for-each select="Weapon">
                            <option><xsl:value-of select="@name" /></option>
                        </xsl:for-each>
                    </select>
                </xsl:if>
                <xsl:text>&#xA;</xsl:text>
    
                <span class="{@display-class}">
                    <xsl:apply-templates select="Weapon" mode="selecttarget" />
                </span>
            </h2>
    
            <xsl:if test="Weapon">
                <script type="text/javascript" language="javascript">
                    Event.observe(document, 'dom:loaded', function() 
                    {   changeWeapon('<xsl:value-of select="../../@safe-key" /><xsl:value-of select="generate-id(@name)" />');
                    });
                </script>
            </xsl:if>

            <div style="overflow-x:hidden; position:relative; white-space:nowrap; margin-right:8px; margin-top:8px;">
                <xsl:apply-templates select="../.." mode="dicehistory" />
            </div>

            <div class="CampaignTabs" id="power{../../@safe-key}{generate-id(@name)}CampaignTabs" style="background-color:white;">
                <span style="font-size:1.2em;">
                    <div class="secondary powerCardRow" style="padding-bottom:8px; padding-top:4px;">
                        <a href="#" style="font-size:1.2em; margin-left:0; margin-right:12px;"
                         onclick="
                            var notesForm = $(this).next('.NotesForm');
                            var notesVisible = notesForm.visible();
                            if (notesVisible)
                            {{   notesForm.hide();
                                notesForm.previous().show();
                            }}
                            else
                            {{   notesForm.show();
                                notesForm.previous().hide();
                                notesForm.down('textarea').focus();
                            }}
                            return false;
                         ">Notes <small>&#9660;</small></a>
                        <xsl:text>&#xA;</xsl:text>
                        <a href="{@url}" id="href{../../@safe-key}{generate-id(@name)}" 
                         target="iframe{../../@safe-key}{generate-id(@name)}" style="font-size:1.2em;"
                         onclick="activateCompendiumLink($(this)); return false;"
                        >Compendium Entry <small>&#9660;</small></a>
                        <span id="linkreport{../../@safe-key}{generate-id(@name)}" style="font-size:.8em;">
                        </span>
                        <xsl:text>&#xA;</xsl:text>
                        <script type="text/javascript" language="javascript">
                                var charKey = '<xsl:value-of select="../../@safe-key"/>';
                                var powerId = '<xsl:value-of select="generate-id(@name)"/>';
                                var powerUrl = '<xsl:value-of select="@url"/>';
                                var powerName = '<xsl:call-template name="escapeJS"><xsl:with-param name="text" select="@name" /></xsl:call-template>';
                                var packageUrl = '<xsl:value-of select="@packageurl"/>';
                                var packageName = '<xsl:value-of select="@packagename"/>';
                   
                                // We used to store these in cookies, but they were getting out of control.  Clean them up.
                                EwgCookie.deleteCookie(
                                    powerUrl.replace(/\//g, 'SLASH').replace(/:/g, 'COLON').replace(/\?/g, 'QUESTION').replace(/=/g, 'EQUAL'));
                                registerReportUrl('linkreport'+charKey+powerId,
                                    { i:powerId, c:charKey, u:powerUrl, n:powerName, pu:packageUrl, pn:packageName })
                        </script>
                        <xsl:if test="@isMore!='' or @name='Action Point' or @name='Second Wind'">
                            <div class="secondary powerCardRow">
                                <b>
                                    <xsl:attribute name="style">
                                        color:<xsl:apply-templates select="." mode="actioncolor" />;
                                    </xsl:attribute>
                                    <xsl:value-of select="@powerusage"/>
                                </b>
                                <xsl:if test="@keywords!='' and @keywords">
                                    <b>
                                        <big><xsl:text>&#xA;&#9830;&#xA;</xsl:text></big>
                                        <xsl:value-of select="@keywords"/>
                                    </b>
                                </xsl:if>
        
                                <br/>
        
                                <b style="margin-right:100px;">
                                    <xsl:value-of select="@actiontype"/>
                                </b>
                                <b>
                                    <xsl:value-of select="substring-before(@attacktype, ' ')" />
                                </b>
                                <xsl:text>&#xA;</xsl:text>
                                <xsl:value-of select="substring-after(@attacktype, ' ')" />
                            </div>
                        </xsl:if>
                        <pre style="font-family:arial; font-size:.9em; padding:0; margin:2px 0 0;" name="note"
                        ></pre>
                        <form class="NotesForm" style="display:none;">
                            <input type="hidden" name="key" value="{../../@key}" />
                            <input type="hidden" name="name" value="{@name}" />
                            <textarea wrap="hard" style="width:586px;height:55px;" name="note"
                             onfocus="$(this).origValue = $(this).origValue || $(this).value;"
                             onkeydown="$(this).origValue = $(this).origValue || $(this).value;"
                             onkeyup="var isChanged = ($(this).value != $(this).origValue); $(this).up().select('a.SaveButton').invoke( isChanged ? 'removeClassName' : 'addClassName', 'UnchangedButton'); return false;"
                            ></textarea>
                            <a href="#" class="Button DamageButton UnchangedButton SaveButton"
                             onclick="
                                var serialForm = Form.serialize($(this).up());
                                new Ajax.Request('/savenotes', {{method:'POST', parameters:serialForm}});

                                var textArea = $(this).previous('textarea');
                                textArea.origValue = textArea.value;

                                var thisForm = $(this).up();
                                thisForm.previous().innerHTML = textArea.value.replace('\n', '&lt;br/&gt;');;
                                thisForm.select('a.SaveButton').invoke('addClassName', 'UnchangedButton');

                                thisForm.hide();
                                thisForm.previous().show();
                                return false;
                             "
                            >Save</a>
                            <a href="#" class="Button DamageButton" 
                             onclick="
                                $(this).previous('textarea').value = $(this).previous('textarea').origValue; 

                                var notesForm = $(this).up('.NotesForm');
                                notesForm.select('a.SaveButton').invoke('addClassName', 'UnchangedButton'); 

                                notesForm.hide();
                                notesForm.previous().show();
                                return false;
                             "
                            >Cancel</a>
                        </form>
                        <xsl:if test="not(PowerCardItem)">
                            <script type="text/javascript" language="javascript">
                                var charKey = '<xsl:value-of select="../../@safe-key"/>';
                                var powerId = '<xsl:value-of select="generate-id(@name)"/>';

                                var compendiumEntryLinkId = 'href' + charKey + powerId;
                                //activateCompendiumLink($(compendiumEntryLinkId), charKey, powerId);
                            </script>
                        </xsl:if>
                    </div>
                    <xsl:if test="(@isMore='' or not(@isMore)) and @name!='Action Point' and @name!='Second Wind'">
                        <xsl:choose>
                            <xsl:when test="(@flavor='' or not(@flavor))">
                                <xsl:if test="not(PowerCardItem)">
                                    <div class="secondary powerCardRow altColor" style="font-style:italic;">
                                        This dnd4e file lacks power card data.  
                                        Please save and export your character from the Character Builder
                                        to get the power card data, then use File - Upload Replacement
                                        to update this character.
                                    </div>
                                </xsl:if>
                            </xsl:when>
                            <xsl:otherwise>
                                <div class="secondary powerCardRow altColor" style="font-style:italic;">
                                    <xsl:value-of select="@flavor"/>
                                </div>
                            </xsl:otherwise>
                        </xsl:choose>
                        <div class="secondary powerCardRow">
                            <b>
                                <xsl:attribute name="style">
                                    color:<xsl:apply-templates select="." mode="actioncolor" />;
                                </xsl:attribute>
                                <xsl:value-of select="@powerusage"/>
                            </b>
                            <xsl:if test="@keywords!='' and @keywords">
                                <b>
                                    <big><xsl:text>&#xA;&#9830;&#xA;</xsl:text></big>
                                    <xsl:value-of select="@keywords"/>
                                </b>
                            </xsl:if>
    
                            <br/>
    
                            <b style="margin-right:100px;">
                                <xsl:value-of select="@actiontype"/>
                            </b>
                            <b>
                                <xsl:value-of select="substring-before(@attacktype, ' ')" />
                            </b>
                            <xsl:text>&#xA;</xsl:text>
                            <xsl:value-of select="substring-after(@attacktype, ' ')" />
                        </div>
                    </xsl:if>
                    <xsl:for-each select="PowerCardItem">
                        <div class="secondary powerCardRow">
                            <xsl:attribute name="class">
                                secondary powerCardRow
                                <xsl:if test="position() mod 2 != 0">
                                    altColor
                                </xsl:if>
                            </xsl:attribute>
                            <b>
                                <xsl:call-template name="leadingspace">
                                    <xsl:with-param name="text" select="Name/node()" />
                                </xsl:call-template>
                            </b>
                            <xsl:text>&#xA;</xsl:text>
                            <xsl:call-template name="formattedtext">
                                <xsl:with-param name="text" select="Description/node()" />
                            </xsl:call-template>
                        </div>
                    </xsl:for-each>
                </span>
            </div>
        </div>
    </div>
</xsl:template>

<xsl:template match="Weapon" mode="selecttarget">
    <div class="WeaponContent" style="display:none;">
        <div class="primary {../@display-class}">
            <span class="Roller {AttackBonus/@dice-class} WithFactors">
                <xsl:attribute name="title">
                    <xsl:if test="contains(@defense, ' ')">
                        <xsl:value-of select="substring-after(@defense, ' ')" />
                        <xsl:text>&#xA;</xsl:text>
                    </xsl:if>
                    <xsl:apply-templates select="AttackBonus/Factor" />
                    <xsl:apply-templates select="AttackBonus/Condition" />
                </xsl:attribute>
                <xsl:value-of select="@attackstat" />
                <xsl:text>&#xA;</xsl:text>
                (+<xsl:value-of select="AttackBonus/@value" />) vs.
                <xsl:text>&#xA;</xsl:text>
                <xsl:choose>
                    <xsl:when test="contains(@defense, ' ')">
                        <xsl:value-of select="substring-before(@defense, ' ')" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@defense" />
                    </xsl:otherwise>
                </xsl:choose>
            </span>
            <xsl:text>&#xA;</xsl:text>
            <span class="Roller {Damage/@dice-class} WithFactors">
                <xsl:attribute name="title">
                    <xsl:apply-templates select="Damage/Factor" />
                    <xsl:apply-templates select="Damage/Condition" />
                </xsl:attribute>
                <xsl:value-of select="Damage/@value" />
                <xsl:text>&#xA;</xsl:text>
                <xsl:value-of select="Damage/@type" />
                <xsl:text>&#xA;</xsl:text>
                damage
            </span>
            <xsl:text>&#xA;</xsl:text>
            <span id=""
             class="Roller {Damage/@dice-class} {AttackBonus/@dice-class}#1"
            >Roll Both vs.
            </span>
            <span style="color:white;">
                <input size="2" value="1" 
                    onblur="
                        var newValue = parseInt(this.value);
                        if (isNaN(newValue)) 
                        {{
                            alert('Please enter a number of targets');
                            this.value = '0';
                            this.focus();
                            return;
                        }}

                        var rollerButton = $(this).up('span').previous();
                        var rollerClassName = rollerButton.className;
                        rollerClassName = rollerClassName.split(' ');
                        rollerClassName = [rollerClassName[0], rollerClassName[1], rollerClassName[2]];

                        var attackClassTemplate = rollerClassName[2].substring(0, rollerClassName[2].length-1);
                        for (var a=2; a&lt;newValue+1; a++)
                            rollerClassName[rollerClassName.length] = attackClassTemplate + a;

                        rollerButton.className = rollerClassName.join(' ');
                        rollRoller(rollerButton);
                    "/>
                target(s)
            </span>
        </div>
        <div class="primary {../@display-class}">
            <xsl:apply-templates select="Condition" mode="roller" />
            <xsl:apply-templates select="../Condition" mode="roller" />
        </div>
    </div>
</xsl:template>

<!-- DICE -->

<xsl:template name="straightDie">
    <xsl:param name="dieSize" />
    <div style="clear:none;margin-bottom:4px;margin-left:12px;">
        <xsl:attribute name="class">StraightDie Roller dice1d<xsl:value-of select="$dieSize" />d<xsl:value-of select="$dieSize" /></xsl:attribute>
        d<xsl:value-of select="$dieSize" />
    </div>
</xsl:template>

<!-- DEFENSES -->

<xsl:template match="Defenses" mode="line">
        <span style="font-weight:bold;">
            AC
            <span class="WithFactors">
                <xsl:attribute name="title">
                    <xsl:apply-templates select="Defense[@abbreviation='AC']/Factor" />
                <xsl:apply-templates select="Defense[@abbreviation='AC']/Condition" />
                </xsl:attribute>
                <xsl:apply-templates select="Defense[@abbreviation='AC']" mode="cellcontent" />
            </span>
        </span>
        <xsl:text>&#160;</xsl:text>
        <xsl:text>&#160;</xsl:text>
        |
        <xsl:text>&#160;</xsl:text>
        Fort
        <span class="WithFactors">
            <xsl:attribute name="title">
                <xsl:apply-templates select="Defense[@abbreviation='Fort']/Factor" />
                <xsl:apply-templates select="Defense[@abbreviation='Fort']/Condition" />
            </xsl:attribute>
            <xsl:apply-templates select="Defense[@abbreviation='Fort']" mode="cellcontent" />
        </span>
        <xsl:text>&#160;</xsl:text>
        <xsl:text>&#160;</xsl:text>
        Ref
        <span class="WithFactors">
            <xsl:attribute name="title">
                <xsl:apply-templates select="Defense[@abbreviation='Ref']/Factor" />
                <xsl:apply-templates select="Defense[@abbreviation='Ref']/Condition" />
            </xsl:attribute>
            <xsl:apply-templates select="Defense[@abbreviation='Ref']" mode="cellcontent" />
        </span>
        <xsl:text>&#160;</xsl:text>
        <xsl:text>&#160;</xsl:text>
        Will
        <span class="WithFactors">
            <xsl:attribute name="title">
                <xsl:apply-templates select="Defense[@abbreviation='Will']/Factor" />
                <xsl:apply-templates select="Defense[@abbreviation='Will']/Condition" />
            </xsl:attribute>
            <xsl:apply-templates select="Defense[@abbreviation='Will']" mode="cellcontent" />
        </span>
        <xsl:text>&#160;</xsl:text>
        <xsl:text>&#160;</xsl:text>
        |
        <xsl:text>&#160;</xsl:text>
        Per
        <span class="Score WithFactors" >
            <xsl:attribute name="title">
                <xsl:apply-templates select="../PassiveSkills/PassiveSkill[@name='Perception']/Factor[@modifier!='+0']" />
                <xsl:apply-templates select="../PassiveSkills/PassiveSkill[@name='Perception']/Condition" />
            </xsl:attribute>
            <xsl:value-of select="../PassiveSkills/PassiveSkill[@name='Perception']/@value" />
        </span>
        <xsl:text>&#160;</xsl:text>
        <xsl:text>&#160;</xsl:text>
        Ins
        <span class="Score WithFactors" >
            <xsl:attribute name="title">
                <xsl:apply-templates select="../PassiveSkills/PassiveSkill[@name='Insight']/Factor[@modifier!='+0']" />
                <xsl:apply-templates select="../PassiveSkills/PassiveSkill[@name='Insight']/Condition" />
            </xsl:attribute>
            <xsl:value-of select="../PassiveSkills/PassiveSkill[@name='Insight']/@value" />
        </span>
</xsl:template>

<xsl:template match="Defenses" mode="table">
    <div style="font-weight:bold;" class="span-1">AC</div>
    <div class="span-1">Fort</div>
    <div class="span-1">Ref</div>
    <div class="span-1">Will</div>
    <div class="span-1">
        <xsl:text>&#160;</xsl:text>
    </div>
    <div class="span-1">Per.</div>
    <div class="span-1 last">Ins.</div>

    <div  class="span-1">
        <span class="WithFactors">
            <xsl:attribute name="title">
                <xsl:apply-templates select="Defense[@abbreviation='AC']/Factor" />
                <xsl:apply-templates select="Defense[@abbreviation='AC']/Condition" />
            </xsl:attribute>
            <span style="font-size:1.3em;">
                <xsl:apply-templates select="Defense[@abbreviation='AC']" mode="cellcontent" />
            </span>
        </span>
    </div>
    <div  class="span-1">
        <span class="WithFactors">
            <xsl:attribute name="title">
                <xsl:apply-templates select="Defense[@abbreviation='Fort']/Factor" />
                <xsl:apply-templates select="Defense[@abbreviation='Fort']/Condition" />
            </xsl:attribute>
            <xsl:apply-templates select="Defense[@abbreviation='Fort']" mode="cellcontent" />
        </span>
    </div>
    <div  class="span-1">
        <span class="WithFactors">
            <xsl:attribute name="title">
                <xsl:apply-templates select="Defense[@abbreviation='Ref']/Factor" />
                <xsl:apply-templates select="Defense[@abbreviation='Ref']/Condition" />
            </xsl:attribute>
            <xsl:apply-templates select="Defense[@abbreviation='Ref']" mode="cellcontent" />
        </span>
    </div>
    <div  class="span-1">
        <span class="WithFactors">
            <xsl:attribute name="title">
                <xsl:apply-templates select="Defense[@abbreviation='Will']/Factor" />
                <xsl:apply-templates select="Defense[@abbreviation='Will']/Condition" />
            </xsl:attribute>
            <xsl:apply-templates select="Defense[@abbreviation='Will']" mode="cellcontent" />
        </span>
    </div>
    <div class="span-1 last">
        <xsl:text>&#160;</xsl:text>
    </div>
    <xsl:apply-templates select="../PassiveSkills/PassiveSkill" mode="listitem" />
</xsl:template>

<xsl:template match="Defense" mode="cellcontent">
    <xsl:value-of select="@value" />
    <xsl:if test="Condition">*</xsl:if>
</xsl:template>

<!-- SKILLS -->

<xsl:template match="PassiveSkill" mode="listitem">
    <div class="span-1">
        <span class="Score WithFactors" >
            <xsl:attribute name="title">
                <xsl:apply-templates select="Factor[@modifier!='+0']" />
                <xsl:apply-templates select="Condition" />
            </xsl:attribute>
            <xsl:value-of select="@value" />
        </span>
    </div>
</xsl:template>

<xsl:template match="Skills/Skill" mode="listitemLabel">
        <td style="padding:0;height:20px;">
            <xsl:call-template name="lightboxLink">
                <xsl:with-param name="lightboxObject" select="." />
                <xsl:with-param name="title">
                    <xsl:choose>
                        <xsl:when test="@name='Dungeoneering'">
                            Dungeon
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@name" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
            </xsl:call-template>
        </td>
</xsl:template>

<xsl:template match="Skills/Skill" mode="listitemValue">
        <td style="padding:0;height:20px;text-align:right;" class="RollerCell">
            <div class="Score WithFactors Roller {@dice-class}"
             style="text-align:center;position:relative;left:-8px;">
                <xsl:attribute name="title">
                    <xsl:apply-templates select="Factor[@modifier!='+0']" />
                    <xsl:apply-templates select="Condition" />
                </xsl:attribute>
                <xsl:value-of select="@value" />
            </div>
            <xsl:if test="@trained='true'">
                <sup style="position:relative;left:-10px;top:4px;">T</sup>
            </xsl:if>
        </td>
</xsl:template>

<xsl:template match="Skills/Skill" mode="listitem">
    <tr>
        <xsl:apply-templates select="." mode="listitemLabel" />
        <xsl:apply-templates select="." mode="listitemValue" />
    </tr>
</xsl:template>

<xsl:template match="Skills/Skill" mode="div">
    <xsl:call-template name="lightboxTarget">
        <xsl:with-param name="lightboxObject" select="." />
        <xsl:with-param name="title">
            <xsl:value-of select="@name" />
        </xsl:with-param>
        <xsl:with-param name="body">
            <xsl:apply-templates select="Feature" mode="selecttarget" />
        </xsl:with-param>
    </xsl:call-template>
</xsl:template>

<!-- LOOT -->

<xsl:template match="Loot" mode="ritualsDiv">
    <xsl:choose>
        <xsl:when test="Item[@name='Ritual Book']">
            <a class="CompendiumLink" href="{Item[@name='Ritual Book']/@url}" target="compendiumBrowser">
                <h3>
                    <xsl:value-of select="Item[@name='Ritual Book']/@name" />
                </h3>
            </a>
        </xsl:when>
        <xsl:otherwise>
            <h3>Rituals</h3>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates select="Item[@type='Ritual']" mode="listitem" />
</xsl:template>

<xsl:template match="Loot" mode="lootDiv">
    <div>
        <div class="EqualSection1">
	  <form>
            <h3>Weapons and Implements</h3>
            <xsl:apply-templates select="Item[(@type='Weapon' or @type='Implement' or @type='Superior Implement') and Enhancement]" mode="listitem" />
            <xsl:apply-templates select="Item[(@type='Weapon' or @type='Implement' or @type='Superior Implement') and not(Enhancement)]" mode="listitem" />
	  </form>
        </div>
        <div class="EqualSection2">
            <h3>Armor</h3>
            <xsl:apply-templates select="Item[@type='Armor' and Enhancement]" mode="listitem" />
            <xsl:apply-templates select="Item[@type='Armor' and not(Enhancement)]" mode="listitem" />
        </div>
        <div class="EqualSection3">
            <h3>Magic Items</h3>
            <xsl:apply-templates select="Item[@type='Magic Item']" mode="listitem" />
            <xsl:if test="count(Item[@type='Magic Item']) = 0">
                <div class="primary">---</div>
            </xsl:if>
        </div>
        <div class="EqualSection3">
            <h3>Other</h3>
            <xsl:apply-templates select="Item[@type!='Armor' and @type!='Weapon' and @type!='Implement' and @type!='Superior Implement' and @type!='Magic Item' and @type!='Ritual' and @name!='Ritual Book']" mode="listitem" />
            <xsl:if test="count(Item[@type!='Armor' and @type!='Weapon' and @type!='Implement' and @type!='Superior Implement' and @type!='Magic Item' and @type!='Ritual' and @name!='Ritual Book']) = 0">
                <div class="primary">---</div>
            </xsl:if>
        </div>
    </div>
</xsl:template>

<xsl:template match="Loot" mode="moneyDiv">
    <div>
        <h3>
            Money
        </h3>
        <table class="MoneyTable" style="font-size:1.1em;">
            <tr>
                <th align="left">Coin Type</th>
                <th align="left">Carried Money</th>
                <th align="left">Stored Money</th>
            </tr>
            <tr>
                <td>Astral Diamonds</td>
                <td>
                    <a style="display:none;" class="{../@safe-key}EditorOnly Button SecondaryButton" onclick="{@carried-ad-subtract-script}">-</a>
                    <a style="display:none;" class="{../@safe-key}EditorOnly Button SecondaryButton" onclick="{@carried-ad-add-script}">+</a>
                    <span class="{@carried-ad-display-class}"><xsl:value-of select="@carried-ad" /></span>
                </td>
                <td>
                    <a style="display:none;" class="{../@safe-key}EditorOnly Button SecondaryButton" onclick="{@stored-ad-subtract-script}">-</a>
                    <a style="display:none;" class="{../@safe-key}EditorOnly Button SecondaryButton" onclick="{@stored-ad-add-script}">+</a>
                    <span class="{@stored-ad-display-class}"><xsl:value-of select="@stored-ad" /></span>
                </td>
            </tr>
            <tr>
                <td>Platinum Pieces</td>
                <td>
                    <a style="display:none;" class="{../@safe-key}EditorOnly Button SecondaryButton" onclick="{@carried-pp-subtract-script}">-</a>
                    <a style="display:none;" class="{../@safe-key}EditorOnly Button SecondaryButton" onclick="{@carried-pp-add-script}">+</a>
                    <span class="{@carried-pp-display-class}"><xsl:value-of select="@carried-pp" /></span>
                </td>
                <td>
                    <a style="display:none;" class="{../@safe-key}EditorOnly Button SecondaryButton" onclick="{@stored-pp-subtract-script}">-</a>
                    <a style="display:none;" class="{../@safe-key}EditorOnly Button SecondaryButton" onclick="{@stored-pp-add-script}">+</a>
                    <span class="{@stored-pp-display-class}"><xsl:value-of select="@stored-pp" /></span>
                </td>
            </tr>
            <tr>
                <td>Gold Pieces</td>
                <td>
                    <a style="display:none;" class="{../@safe-key}EditorOnly Button SecondaryButton" onclick="{@carried-gp-subtract-script}">-</a>
                    <a style="display:none;" class="{../@safe-key}EditorOnly Button SecondaryButton" onclick="{@carried-gp-add-script}">+</a>
                    <span class="{@carried-gp-display-class}"><xsl:value-of select="@carried-gp" /></span>
                </td>
                <td>
                    <a style="display:none;" class="{../@safe-key}EditorOnly Button SecondaryButton" onclick="{@stored-gp-subtract-script}">-</a>
                    <a style="display:none;" class="{../@safe-key}EditorOnly Button SecondaryButton" onclick="{@stored-gp-add-script}">+</a>
                    <span class="{@stored-gp-display-class}"><xsl:value-of select="@stored-gp" /></span>
                </td>
            </tr>
            <tr>
                <td>Silver Pieces</td>
                <td>
                    <a style="display:none;" class="{../@safe-key}EditorOnly Button SecondaryButton" onclick="{@carried-sp-subtract-script}">-</a>
                    <a style="display:none;" class="{../@safe-key}EditorOnly Button SecondaryButton" onclick="{@carried-sp-add-script}">+</a>
                    <span class="{@carried-sp-display-class}"><xsl:value-of select="@carried-sp" /></span>
                </td>
                <td>
                    <a style="display:none;" class="{../@safe-key}EditorOnly Button SecondaryButton" onclick="{@stored-sp-subtract-script}">-</a>
                    <a style="display:none;" class="{../@safe-key}EditorOnly Button SecondaryButton" onclick="{@stored-sp-add-script}">+</a>
                    <span class="{@stored-sp-display-class}"><xsl:value-of select="@stored-sp" /></span>
                </td>
            </tr>
            <tr>
                <td>Copper Pieces</td>
                <td>
                    <a style="display:none;" class="{../@safe-key}EditorOnly Button SecondaryButton" onclick="{@carried-cp-subtract-script}">-</a>
                    <a style="display:none;" class="{../@safe-key}EditorOnly Button SecondaryButton" onclick="{@carried-cp-add-script}">+</a>
                    <span class="{@carried-cp-display-class}"><xsl:value-of select="@carried-cp" /></span>
                </td>
                <td>
                    <a style="display:none;" class="{../@safe-key}EditorOnly Button SecondaryButton" onclick="{@stored-cp-subtract-script}">-</a>
                    <a style="display:none;" class="{../@safe-key}EditorOnly Button SecondaryButton" onclick="{@stored-cp-add-script}">+</a>
                    <span class="{@stored-cp-display-class}"><xsl:value-of select="@stored-cp" /></span>
                </td>
            </tr>
        </table>
	<h3>Weight carried: <xsl:value-of select="../Loot/@weightCarried" /></h3>
	<!--Cold resistance: <xsl:value-of select="../Resistances/@Cold" />-->
    </div>
</xsl:template>

<xsl:template match="Item" mode="listitem">
    <xsl:choose>
        <xsl:when test="Enhancement">
            <div style="padding-left:36px;position:relative; font-size:1.1em;">
                <span class="secondary" style="position:absolute;top:2px;left:0;">
                    <xsl:value-of select="@equippedcount" /> 
                    /
                    <xsl:value-of select="@count" />
                </span>
                <xsl:call-template name="lightboxLink">
                    <xsl:with-param name="lightboxObject" select="." />
                    <xsl:with-param name="title">
                        <div class="powerlink{../../@safe-key}{generate-id(Enhancement/@name)}">
                            <xsl:value-of select="Enhancement/@name" />
                            (<xsl:choose>
                                <xsl:when test="@type='Armor' and contains(@name, ' Armor')" >
                                    <xsl:value-of select="substring-before(@name , ' Armor')" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="@name" />
                                </xsl:otherwise>
                             </xsl:choose>)
                        </div>
                    </xsl:with-param>
                </xsl:call-template>
            </div>
        </xsl:when>
        <xsl:otherwise>
		<!--<div class="{@display-class}">-->
		<!--<xsl:if test="@count &gt; 0">-->
            <div style="font-size:1.1em;">
                <xsl:if test="@type!='Ritual'">
                    <xsl:attribute name="style">padding-left:36px;position:relative;</xsl:attribute>
                    <span class="secondary" style="position:absolute;top:2px;left:0;">
		      <!--<input type="checkbox" name="foo" value="bar"/>-->
                        <xsl:value-of select="@equippedcount" />
                        /
			<span class="{@display-class}">
                        <!--<xsl:value-of select="@count" />-->
			</span>
                    </span>
                </xsl:if>
                <xsl:call-template name="lightboxLink">
                    <xsl:with-param name="lightboxObject" select="." />
                    <xsl:with-param name="title">
                        <xsl:value-of select="@name" />
                    </xsl:with-param>
                </xsl:call-template>
			<!--<a style="display:none;" class="{../../@safe-key}EditorOnly Button SecondaryButton" onclick="{@subtract-script}">-</a>
			<a style="display:none;" class="{../../@safe-key}EditorOnly Button SecondaryButton" onclick="{@add-script}">+</a>-->
            </div>
		<!--</xsl:if>-->
		<!--</div>-->
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template match="Item" mode="div">
    <xsl:call-template name="lightboxTarget">
        <xsl:with-param name="lightboxObject" select="." />
        <xsl:with-param name="title">
            <xsl:choose>
                <xsl:when test="Enhancement">
                    <xsl:value-of select="Enhancement/@name" />
                    (<xsl:value-of select="@name" />)
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@name" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:with-param>
        <xsl:with-param name="body">
            <xsl:choose>
                <xsl:when test="Enhancement">
                    <iframe class="NoWeapons" src="/TIME_TOKEN/html/loadingSimple.html"
                     name="iframe{../../@safe-key}{generate-id(Enhancement/@name)}" 
                     id="iframe{../../@safe-key}{generate-id(Enhancement/@name)}" 
                     style="padding:0;height:241px;" frameborder="no"
                    />

                    <script type="text/javascript" language="javascript">
                        Event.observe(document, 'dom:loaded', function() 
                        {   
                            var charId = '<xsl:value-of select="../../@safe-key" />';
                            var powerId = '<xsl:value-of select="generate-id(@name)" />';
                            var powerUrl = '<xsl:value-of select="Enhancement/@url" />';
                            $('powerlink' + charId + powerId).observe('click', function()
                            {   
                                var enhancementId = '<xsl:value-of select="generate-id(Enhancement/@name)" />';
                                var powerUrl = $('enhancedpowerlink' + charKey + enhancementId).href;
                                if (IS_NATIVE_APP) {
                                    powerUrl = '/proxywotc/' + powerUrl;
                                    //alert(powerUrl);
                                }
                                var enhancementId = '<xsl:value-of select="generate-id(Enhancement/@name)" />';
                                var otherIframe = $('iframe' + charId + enhancementId);
                                otherIframe.src = powerUrl;
                            });
                            //activatePowerLink(charId, powerId, powerUrl);
                        });
                    </script>

                    <iframe class="NoWeapons" src="/TIME_TOKEN/html/loadingSimple.html"
                     name="iframe{../../@safe-key}{generate-id(@name)}" 
                     id="iframe{../../@safe-key}{generate-id(@name)}" 
                     style="padding:0;height:241px;" frameborder="no"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <iframe class="NoWeapons" src="/TIME_TOKEN/html/loadingSimple.html"
                     name="iframe{../../@safe-key}{generate-id(@name)}" 
                     id="iframe{../../@safe-key}{generate-id(@name)}" 
                     style="padding:0;" frameborder="no" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:with-param>
    </xsl:call-template>
</xsl:template>

<!-- ABILITIES -->

<xsl:template match="AbilityScores/AbilityScore" mode="listitemLabel">
        <td style="padding:0;height:20px;">
            <xsl:value-of select="@abbreviation" />
        </td>
</xsl:template>

<xsl:template match="AbilityScores/AbilityScore" mode="listitemValue">
        <td style="text-align:right;padding:0;height:20px;">
            <span class="WithFactors">
                <xsl:attribute name="title">
                    <xsl:apply-templates select="Factor[not(contains(@name, 'Level '))]" />
                    <xsl:if test="Factor[contains(@name, 'Level ')]">+<xsl:value-of select="count(Factor[contains(@name, 'Level ')])" /> (Level<xsl:if test="count(Factor[contains(@name, 'Level ')]) > 1">s</xsl:if>
                            <xsl:for-each select="Factor[contains(@name, 'Level ')]">
                                <xsl:value-of select="substring(@name, 6)" />
                                <xsl:if test="position()!=last()">,</xsl:if>
                            </xsl:for-each>)</xsl:if>
                    <xsl:apply-templates select="Condition" />
                </xsl:attribute>
                <xsl:value-of select="@value" />
            </span>
        </td>
        <td style="text-align:right;padding:0;">
            <xsl:value-of select="AbilityModifier/@modifier" />
        </td>
        <td style="padding:0;">
            <span class="Roller {AbilityModifier/@dice-class} AbilityPiece"
             style="margin-right:12px;font-size:.7em;">
                <xsl:value-of select="AbilityModifier/@rollmodifier" />
            </span>
        </td>
</xsl:template>

<xsl:template match="AbilityScores/AbilityScore" mode="listitem">
    <tr>
        <xsl:apply-templates select="." mode="listitemLabel" />
        <xsl:apply-templates select="." mode="listitemValue" />
    </tr>
</xsl:template>

<!-- WEAPON PROFICIENCIES -->

<xsl:template match="Proficiencies" mode="listitems">

    <div class="EqualSection2">
        <h3>Shield Proficiencies</h3>
        <div class="primary">
            <xsl:call-template name="proficiencycommalist">
                <xsl:with-param name="proficienciesholder" select="ShieldProficiencies" />
            </xsl:call-template>
            <xsl:if test="count(ShieldProficiencies/Proficiency) = 0">
                ---
            </xsl:if>
        </div>
    </div>

    <div class="EqualSection3">
        <h3>Armor Proficiencies</h3>
        <div class="primary">
            <xsl:call-template name="proficiencycommalist">
                <xsl:with-param name="proficienciesholder" select="ArmorProficiencies" />
            </xsl:call-template>
        </div>
    </div>

    <div class="EqualSection4">
        <h3>Weapon Proficiencies</h3>

        <xsl:for-each select="WeaponProficiencies/ProficiencyGroup">
            <div class="primary WithFactors"
             onclick="var detailsDiv = $(this).next(); detailsDiv.visible() ? detailsDiv.hide() : detailsDiv.show(); sizeParentIframeToMyContainer();">
                <xsl:if test="Proficiency">
                    <xsl:attribute name="style">cursor:pointer;<xsl:value-of select="@source" /></xsl:attribute>
                </xsl:if>
                <xsl:attribute name="title">Source: <xsl:value-of select="@source" /></xsl:attribute>
                <xsl:text>&#xA;</xsl:text>
                <xsl:value-of select="@name" />
                <xsl:if test="Proficiency">
                    <xsl:text>&#xA;</xsl:text>
                    <small>&#9660;</small>
                </xsl:if>
            </div>
            <div class="tertiary" style="display:none;">
                <xsl:for-each select="Proficiency"><xsl:text>&#xA;</xsl:text><xsl:value-of select="@name" /><xsl:if test="position()!=last()">,</xsl:if></xsl:for-each>
            </div>
        </xsl:for-each>
    
        <div class="primary">
            <xsl:call-template name="proficiencycommalist">
                <xsl:with-param name="proficienciesholder" select="WeaponProficiencies" />
            </xsl:call-template>
        </div>
    </div>
</xsl:template>

<xsl:template name="proficiencycommalist">
    <xsl:param name="proficienciesholder" />
    <xsl:for-each select="$proficienciesholder/Proficiency">
        <span class="WithFactors">
            <xsl:attribute name="title">Source: <xsl:value-of select="@source" /></xsl:attribute>
            <xsl:text>&#xA;</xsl:text>
            <xsl:value-of select="@name" />
        </span>
        <xsl:if test="position()!=last()">,</xsl:if>
    </xsl:for-each>
</xsl:template>

<!-- BUILD -->

<xsl:template match="Build" mode="title">
    <xsl:value-of select="Race/@name" />
        <xsl:text>&#xA;</xsl:text>
    <xsl:value-of select="@name" />
</xsl:template>

<xsl:template match="Build" mode="column1Content">
    <div style="overflow:auto;">
        <h3>
            Level
        </h3>
        <div class="primary">
            <xsl:value-of select="@level" />
        </div>

        <h3>
            XP
            <a style="display:none;float:none;" class="{../@safe-key}EditorOnly Button AddXPButton" onclick="{@experience-prompt-script}">+</a>
        </h3>
        <div class="primary">
            <span class="ExperiencePoints">
                <xsl:value-of select="@ExperienceNeeded" />
            </span>
	of <xsl:value-of select="@ExperienceNeeded" />
        </div>

        <xsl:apply-templates select="*" mode="list" />
    </div>
</xsl:template>

<xsl:template match="Build" mode="column2Content">
    <div style="overflow:auto;">
        <h3>Alignment</h3>
        <div class="primary"><xsl:if test="string-length(@alignment)=0">---</xsl:if><xsl:value-of select="@alignment" /></div>

        <h3>Deity</h3>
        <div class="primary"><xsl:if test="string-length(@deity)=0">---</xsl:if><xsl:value-of select="@deity" /></div>

        <h3>Gender</h3>
        <div class="primary"><xsl:if test="string-length(@gender)=0">---</xsl:if><xsl:value-of select="@gender" /></div>

	    <h3>Height / Weight</h3>
	    <div class="primary">
            <xsl:if test="string-length(../Description/@height)=0">---</xsl:if><xsl:value-of select="../Description/@height" />
            /
	        <xsl:if test="string-length(../Description/@weight)=0">---</xsl:if><xsl:value-of select="../Description/@weight" />
        </div>

        <h3>Vision</h3>
        <div class="primary"><xsl:if test="string-length(@vision)=0">---</xsl:if><xsl:value-of select="@vision" /></div>

        <h3>Size</h3>
        <div class="primary"><xsl:if test="string-length(@size)=0">---</xsl:if><xsl:value-of select="@size" /></div>
    </div>
</xsl:template>

<xsl:template match="Build" mode="talldiv">
    <table style="margin:0;" rows="1" cols="1">
        <tr>
            <td style="padding:0;vertical-align:top;">
                <xsl:apply-templates select="." mode="column1Content" />
                <xsl:apply-templates select="." mode="column2Content" />
            </td>
        </tr>
    </table>
</xsl:template>

<xsl:template match="Build" mode="div">
    <table style="margin:0;" rows="1" cols="2">
        <tr>
            <td style="padding:0;vertical-align:top;">
                <xsl:apply-templates select="." mode="column1Content" />
            </td>
            <td style="padding:0 0 0 4px;vertical-align:top;">
                <xsl:apply-templates select="." mode="column2Content" />
            </td>
        </tr>
    </table>
</xsl:template>

<xsl:template match="Build/*" mode="list">
    <h3>
        <xsl:choose>
            <xsl:when test="name()='ParagonPath'">
                Paragon Path
            </xsl:when>
            <xsl:when test="name()='EpicDestiny'">
                Epic Destiny
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="name()" />
            </xsl:otherwise>
        </xsl:choose>
    </h3>
    <xsl:call-template name="lightboxLink">
        <xsl:with-param name="lightboxObject" select="." />
        <xsl:with-param name="title">
            <xsl:value-of select="@name" />
        </xsl:with-param>
    </xsl:call-template>
</xsl:template>

<!-- You better also call lightboxTarget if you call this -->
<xsl:template name="lightboxLink">
    <xsl:param name="lightboxObject" />
    <xsl:param name="targetIframe" select="''" />
    <xsl:param name="title" />
    <xsl:param name="titleStyle" select="''" />
    <xsl:param name="titleClass" select="''" />
    <xsl:param name="divStyle" select="''" />
    <xsl:param name="divClass" select="''" />
    <xsl:variable name="finalIframe">
        <xsl:choose>
            <xsl:when test="$targetIframe!=''"><xsl:value-of select="$targetIframe" /></xsl:when>
            <xsl:otherwise>iframe<xsl:value-of select="$lightboxObject/../../@safe-key" /><xsl:value-of select="generate-id($lightboxObject/@name)" /></xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <div class="primary PowerLink {$divClass}" style="{$divStyle}">
        <a href="{$lightboxObject/@url}"
         rel="lightbox{$lightboxObject/../../@safe-key}{generate-id($lightboxObject/@name)}" 
         id="powerlink{$lightboxObject/../../@safe-key}{generate-id($lightboxObject/@name)}"
         target="{$finalIframe}"
         class="lbOn CompendiumLink {$titleClass}" style="{$titleStyle}"
        ><xsl:copy-of select="$title" /></a>
        <script type="text/javascript" language="javascript">
            var charId = '<xsl:value-of select="$lightboxObject/../../@safe-key" />';
            var powerId = '<xsl:value-of select="generate-id($lightboxObject/@name)" />';
            var powerUrl = '<xsl:value-of select="$lightboxObject/@url" />';

            if (powerUrl)
            {
                var autoLoad = 1;
                <xsl:if test="not(PowerCardItem) or @isMore!='' or @name='Action Point' or @name='Second Wind'">
                    autoLoad = 1;
                </xsl:if>

                activatePowerLink(charId, powerId, powerUrl, autoLoad);
            }
        </script>
    </div>
</xsl:template>

<xsl:template name="lightboxTarget">
    <xsl:param name="lightboxObject" />
    <xsl:param name="title" select="''" />
    <xsl:param name="body" />
    <div id="power{../../@safe-key}{generate-id(@name)}">
        <div class="PowerContent leightbox" id="lightbox{../../@safe-key}{generate-id(@name)}"
         style="background:#F0EDD2;"
         >
            <xsl:if test="$title != 'Help!'">
                <h2 style="padding-bottom:2px; padding-top:4px; min-height:24px; background-color:#619869; font-size:1.2em;">
                    <xsl:copy-of select="$title" />
                </h2>
                <div class="CampaignTabs" id="power{../../@safe-key}{generate-id(@name)}CampaignTabs" style="background-color:white;">
                    <span style="font-size:1.2em;">
                        <div class="secondary powerCardRow" style="padding-bottom:8px; padding-top:4px;">
                            <a href="#" style="font-size:1.2em; margin-left:0; margin-right:12px;"
                            onclick="
                                var notesForm = $(this).next('.NotesForm');
                                var notesVisible = notesForm.visible();
                                if (notesVisible)
                                {{   notesForm.hide();
                                    notesForm.previous().show();
                                }}
                                else
                                {{   notesForm.show();
                                    notesForm.previous().hide();
                                    notesForm.down('textarea').focus();
                                }}
                                return false;
                            ">Notes <small>&#9660;</small></a>
                            <xsl:text>&#xA;</xsl:text>
                            <a href="{@url}" id="href{../../@safe-key}{generate-id(@name)}" 
                                target="iframe{../../@safe-key}{generate-id(@name)}" 
                                style="display:none;font-size:1.2em;"
                                onclick="activateCompendiumLink($(this)); return false;"
                            >Compendium Entry <small>&#9660;</small></a>
                            <xsl:text>&#xA;</xsl:text>

                            <xsl:choose>
                                <xsl:when test="Enhancement">
                                    <a href="{Enhancement/@url}" style="display:none;"
                                        id="enhancedpowerlink{../../@safe-key}{generate-id(Enhancement/@name)}" 
                                    />
                                    <span
                                        id="enhancedlootlinkreport{../../@safe-key}{generate-id(Enhancement/@name)}" 
                                        style="font-size:.8em;"
                                    >
                                    </span>
                                    <xsl:text>&#xA;</xsl:text>
                                    <script type="text/javascript" language="javascript">
                                        var charKey = '<xsl:value-of select="../../@safe-key"/>';
                                        var powerId = '<xsl:value-of select="generate-id(Enhancement/@name)"/>';
                                        var powerUrl = '<xsl:value-of select="Enhancement/@url"/>';
                                        var powerName = '<xsl:call-template name="escapeJS"><xsl:with-param name="text" select="Enhancement/@name" /></xsl:call-template>';
                                        var packageUrl = '<xsl:value-of select="@packageurl"/>';
                                        var packageName = '<xsl:value-of select="@packagename"/>';
                        
                                        // We used to store these in cookies, but they were getting out of control.  Clean them up.
                                        EwgCookie.deleteCookie(
                                            powerUrl.replace(/\//g, 'SLASH').replace(/:/g, 'COLON').replace(/\?/g, 'QUESTION').replace(/=/g, 'EQUAL'));
                                        registerReportUrl('enhancedlootlinkreport'+charKey+powerId, {
                                            i:powerId, c:charKey, u:powerUrl, n:powerName, pu:packageUrl, pn:packageName 
                                        }, 'enhancedpowerlink' + charKey + powerId );
                                    </script>
                                </xsl:when>
                                <xsl:otherwise>
                                    <span id="lootlinkreport{../../@safe-key}{generate-id(@name)}" style="font-size:.8em;">
                                    </span>
                                    <xsl:text>&#xA;</xsl:text>
                                    <script type="text/javascript" language="javascript">
                                            var charKey = '<xsl:value-of select="../../@safe-key"/>';
                                            var powerId = '<xsl:value-of select="generate-id(@name)"/>';
                                            var powerUrl = '<xsl:value-of select="@url"/>';
                                            var powerName = '<xsl:call-template name="escapeJS"><xsl:with-param name="text" select="@name" /></xsl:call-template>';
                                            var packageUrl = '<xsl:value-of select="@packageurl"/>';
                                            var packageName = '<xsl:value-of select="@packagename"/>';
                            
                                            // We used to store these in cookies, but they were getting out of control.  Clean them up.
                                            EwgCookie.deleteCookie(
                                                powerUrl.replace(/\//g, 'SLASH').replace(/:/g, 'COLON').replace(/\?/g, 'QUESTION').replace(/=/g, 'EQUAL'));
                                            registerReportUrl('lootlinkreport'+charKey+powerId, {
                                                i:powerId, c:charKey, u:powerUrl, n:powerName, pu:packageUrl, pn:packageName 
                                            }, 'powerlink' + charKey + powerId );
                                    </script>
                                </xsl:otherwise>
                            </xsl:choose>
                            <pre style="font-family:arial; font-size:.9em; padding:0; margin:2px 0 0;" name="note"
                            ></pre>
                            <form class="NotesForm" style="display:none;">
                                <input type="hidden" name="key" value="{../../@key}" />
                                <input type="hidden" name="name" value="{@name}" />
                                <textarea wrap="hard" style="width:586px;height:55px;" name="note"
                                    onkeydown="$(this).origValue = $(this).origValue || $(this).value;"
                                    onkeyup="var isChanged = ($(this).value != $(this).origValue); $(this).up().select('a').invoke( isChanged ? 'removeClassName' : 'addClassName', 'UnchangedButton'); return false;"
                                ></textarea>
                                <a href="#" class="Button DamageButton UnchangedButton SaveButton"
                                 onclick="
                                    var serialForm = Form.serialize($(this).up());
                                    new Ajax.Request('/savenotes', {{method:'POST', parameters:serialForm}});
    
                                    var textArea = $(this).previous('textarea');
                                    textArea.origValue = textArea.value;
    
                                    var thisForm = $(this).up();
                                    thisForm.previous().innerHTML = textArea.value.replace('\n', '&lt;br/&gt;');;
                                    thisForm.select('a.SaveButton').invoke('addClassName', 'UnchangedButton');
    
                                    thisForm.hide();
                                    thisForm.previous().show();
                                    return false;
                                 "
                                >Save</a>
                                <a href="#" class="Button DamageButton" 
                                 onclick="
                                    $(this).previous('textarea').value = $(this).previous('textarea').origValue; 
    
                                    var notesForm = $(this).up('.NotesForm');
                                    notesForm.select('a.SaveButton').invoke('addClassName', 'UnchangedButton'); 
    
                                    notesForm.hide();
                                    notesForm.previous().show();
                                    return false;
                                 "
                                >Cancel</a>
                            </form>
                        </div>
                    </span>
                </div>
            </xsl:if>
            <div class="CampaignTabs" id="{../../@safe-key}{generate-id(@name)}CampaignTabs"
             style="background-color:white;">
                <span>
                    <xsl:copy-of select="$body" />
                </span>
                <span style="display:none;">
                    <div class="primary" style="margin-left:8px;padding-bottom:14px;">
                    </div>
                </span>
            </div>
        </div>
    </div>
</xsl:template>

<xsl:template match="Build/*" mode="div">
    <xsl:call-template name="lightboxTarget">
        <xsl:with-param name="lightboxObject" select="." />
        <xsl:with-param name="title">
            <xsl:if test="name()='Class'">
                <div class="Score">
                    <span class="secondary">
                        <xsl:value-of select="../@powersource" />
                        <xsl:text>&#xA;</xsl:text>
                        <xsl:value-of select="../@role" />
                    </span>
                </div>
                <xsl:value-of select="../@name" />
            </xsl:if>
            <xsl:if test="name()!='Class'">
                <xsl:value-of select="@name" />
            </xsl:if>
            <xsl:text>&#xA;</xsl:text>

            <xsl:if test="Feature">
                <select id="weapons{../../@safe-key}{generate-id(@name)}" onchange="changeWeapon('{../../@safe-key}{generate-id(@name)}');">
                    <xsl:for-each select="Feature">
                        <option><xsl:value-of select="@name" /></option>
                    </xsl:for-each>
                </select>
                <script type="text/javascript" language="javascript">
                    Event.observe(document, 'dom:loaded', function() 
                    {   changeWeapon('<xsl:value-of select="../../@safe-key" /><xsl:value-of select="generate-id(@name)" />');
                    });
                </script>
            </xsl:if>
        </xsl:with-param>
        <xsl:with-param name="body">
            <xsl:apply-templates select="Feature" mode="selecttarget" />
            <xsl:choose>
                <xsl:when test="@url = ''">
                    <div style="margin:6px;">
                        <xsl:value-of select="@description" />
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <iframe class="HasWeapons" style="padding:0;" frameborder="no"
                     src="/TIME_TOKEN/html/loadingSimple.html"
                     name="iframe{../../@safe-key}{generate-id(@name)}" 
                     id="iframe{../../@safe-key}{generate-id(@name)}" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:with-param>
    </xsl:call-template>
</xsl:template>

<xsl:template match="Feature" mode="selecttarget">
    <div class="WeaponContent" style="display:none;">
        <div class="tertiary" style="margin-left:6px;margin-right:6px;">
            <xsl:value-of select="@description" />
        </div>
    </div>
</xsl:template>

<!-- FEATS -->

<xsl:template match="Feat" mode="listitem">
    <xsl:call-template name="lightboxLink">
        <xsl:with-param name="lightboxObject" select="." />
        <xsl:with-param name="title">
            <xsl:value-of select="@name" />
        </xsl:with-param>
    </xsl:call-template>
    <div class="tertiary">
        <xsl:value-of select="@description" />
    </div>
</xsl:template>

<xsl:template match="Feat" mode="div">
    <xsl:call-template name="lightboxTarget">
        <xsl:with-param name="lightboxObject" select="." />
        <xsl:with-param name="title">
            <xsl:value-of select="@name" />
        </xsl:with-param>
        <xsl:with-param name="body">
        </xsl:with-param>
    </xsl:call-template>
</xsl:template>

<!-- FACTORS and CONDITIONS -->

<xsl:template match="Factor">
    <xsl:value-of select="@modifier" /> (<xsl:value-of select="@name" />)
</xsl:template>

<xsl:template match="Condition">
    <xsl:value-of select="@modifier" /> condition: <xsl:value-of select="@name" />
</xsl:template>

<xsl:template match="Condition" mode="roller">
    <p style="margin:8px 0;">
        <xsl:choose>
            <xsl:when test="@dice-class='' or not(@dice-class)">
                <span style="color:white;">
                    <xsl:value-of select="@name" />
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span class="Roller {@dice-class}">
                    <xsl:value-of select="@name" />
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </p>
</xsl:template>

<!-- DESCRIPTION -->

<xsl:template match="Description/*" mode="listitem">
    <div>
        <h3><xsl:value-of select="name()" /></h3>
    </div>
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
            <textarea wrap="hard" style="height:15em; width:96%;" class="CUR_{name()}"
             onkeyup="var theChar = CHARACTER{../../@safe-key}; var isChanged = ($(this).value != theChar.get('CUR_{name()}')); $(this).up().select('a').invoke( isChanged ? 'removeClassName' : 'addClassName', 'UnchangedButton'); return false;"
            ><xsl:value-of select="node()" /></textarea>
            <a href="#" class="Button DamageButton UnchangedButton" 
             onclick="var theChar = CHARACTER{../../@safe-key}; var newVal = $(this).previous('textarea').value; theChar.set('CUR_{name()}', newVal); theChar.save();  $(this).up().select('a').invoke('addClassName', 'UnchangedButton'); return false;"
            >Save <xsl:value-of select="name()" /></a>
            <a href="#" class="Button DamageButton UnchangedButton" 
             onclick="var theChar = CHARACTER{../../@safe-key}; $(this).previous('textarea').value = theChar.get('CUR_{name()}'); $(this).up().select('a').invoke('addClassName', 'UnchangedButton'); return false;"
            >Undo Changes</a>
        </span>
    </div>
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

<xsl:template match="Character" mode="powerContent">
    <div class="CombatantContent ShortCompendiumBrowserDiv">
        <div style="width:100%;overflow:hidden;">
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
    </div>
</xsl:template>

<xsl:template match="Languages/Language" mode="listitems">
    <div class="primary">
        <xsl:value-of select="@name" />
    </div>
</xsl:template>

<xsl:template match="Character" mode="skillTable">
    <table style="margin:0;" rows="1" cols="2">
        <tr>
            <td style="padding:0;vertical-align:top;">
                <div style="height:281px;overflow:auto;">
                    <h3 style="margin-bottom:2px;">Skills</h3>
                    <table style="margin:0;" cols="2">
                        <xsl:apply-templates select="Skills/Skill[position() &lt; 13]" mode="listitem" />
                    </table>
                </div>
            </td>
            <td style="padding:0 0 0 4px;vertical-align:top;height:281px;">
                <h3 style="margin-bottom:2px;">&#xA0;</h3>
                <table style="margin:0;" cols="2">
                    <xsl:apply-templates select="Skills/Skill[position() &gt; 12]" mode="listitem" />
                </table>

                <h3 style="margin-bottom:2px;margin-top:4px;">Ability Scores</h3>
                <table cellpadding="0" cellspacing="0" style="font-size:1.3em;">
                    <xsl:apply-templates select="AbilityScores/AbilityScore" mode="listitem" />
                </table>
            </td>
        </tr>
    </table>
</xsl:template>

<xsl:template name="CharacterSection">
    <xsl:param name="id" select="''" />
    <xsl:param name="class" select="'last'" />
    <xsl:param name="style" select="''" />
    <xsl:param name="width" />
    <xsl:param name="title" select="''" />
    <xsl:param name="multiplesActive" select="''" />
    <xsl:param name="titleStyle" select="''" />
    <xsl:param name="content" select="''" />
    <xsl:param name="contentStyle" select="'display:none;'" />

    <div class="span-{$width} CharacterTabLinks CombatantContent CharacterSection {$class}" id="{$id}"
     style="{$style}"
     onclick="
        var characterSectionContent = $(this).down('.CharacterSectionContent');
        if ($(this).up().hasClassName('CharacterSectionContent')) 
        {{  characterSectionContent = $(this).up();
        }}

        if (characterSectionContent.visible()) return;
        var visibleSection = $(this).up().select('.CharacterSection .CharacterSectionContent').find(function(s)
        {{  return s.visible();
        }});

        new Effect.Parallel(
        [   new Effect.BlindDown(characterSectionContent, {{sync:true}}),
            new Effect.BlindUp(visibleSection, {{sync:true}})
        ], {{duration:.2}});
    ">
        <xsl:if test="$title!=''">
            <h2 style="cursor:pointer;{$titleStyle}" >
                <xsl:copy-of select="$title" />
            </h2>
        </xsl:if>
        <div class="span-{$width} last CharacterSectionContent" style="{$contentStyle}">
            <xsl:copy-of select="$content" />
        </div>
    </div>
    <script type="text/javascript" language="javascript">
        var thisId = '<xsl:value-of select="$id" />';
        if (thisId)
        {
            var linksInThisId = $$('#' + thisId + ' h2 span');
            linksInThisId.invoke('observe', 'click', function(e)
            {   
                var contextId = '<xsl:value-of select="$id" />';
                var linksInThisId = $$('#' + contextId + ' h2 span');
                var contentDivsInThisId = $(contextId).down('.CharacterSectionContent').childElements();

                var linkIndex = linksInThisId.indexOf(e.element());
                <xsl:choose>
                    <xsl:when test="$multiplesActive!=''">
                        linksInThisId.invoke('removeClassName', 'Active');
                    </xsl:when>
                    <xsl:otherwise>
                        $$('.CharacterSection h2 span').invoke('removeClassName', 'Active');
                    </xsl:otherwise>
                </xsl:choose>
                linksInThisId[linkIndex].addClassName('Active');

                contentDivsInThisId.invoke('hide');
                contentDivsInThisId[linkIndex].show();

                sizeParentIframeToMyContainer();
            });
        }
        //sizeParentIframeToMyContainer();
    </script>
</xsl:template>

<xsl:template match="Campaign" mode="controlBar">
    <div class="span-24 last CombatantDiv EmbedOnly ControlBar" style="display:none;">
        <div class="span-14 CombatantHeader" style="z-index:999;">
            <span class="title">
                <xsl:value-of select="@name" />
            </span>
            <span class="SearchResultMenuLinks" style="z-index:999;">
                <xsl:apply-templates select="." mode="controlIcons" />
            </span>
        </div>
        <div class="span-10 CombatantHeader last" style="text-align:right;">
            <span class="ForeignOnly" style="display:none;">
                <b id="nicknameDisplay"></b>
                <script type="text/javascript" language="javascript">
                    registerAuthHandler(function(json)
                    {   var nameDisplay = null;
                        if (json.nickname) nameDisplay = json.nickname;
                        if (json.prefs &amp;&amp; json.prefs.handle)
                            nameDisplay = json.prefs.handle;
                        if (nameDisplay) $('nicknameDisplay').update(nameDisplay + ' | ');
                    });
                </script>
                <u><a class="SignInOut list" style="text-decoration:none;" href="#"><img src="/TIME_TOKEN/images/DivLoadingSpinner.gif"/></a></u>
                |
            </span>
            <xsl:value-of select="@world" /> 
        </div>
    </div>
</xsl:template>

<xsl:template match="Character" mode="controlBar">
    <div class="span-24 last CombatantDiv EmbedOnly ControlBar" style="display:none;">
        <div class="span-18 CombatantHeader" style="z-index:1000;">
            <span class="title">
                <xsl:value-of select="@name" />, 
                <xsl:text>&#xA;</xsl:text>
                <xsl:value-of select="Build/Race/@name" /> 
                <xsl:text>&#xA;</xsl:text>
                <xsl:value-of select="Build/@name" /> 
                <xsl:text>&#xA;</xsl:text>
                <xsl:value-of select="Build/@level" />
            </span>
            <span class="SearchResultMenuLinks" style="z-index:1000;">
                <xsl:apply-templates select="." mode="controlIcons" />
            </span>
        </div>
        <div class="span-6 CombatantHeader last" style="text-align:right;z-index:1000;">
            <xsl:value-of select="Build/@powersource" /> 
                <xsl:text>&#xA;</xsl:text>
            <xsl:value-of select="Build/@role" />
        </div>
    </div>
</xsl:template>

<xsl:template match="Campaign" mode="descriptionPanel">
            <div id="{@key}DescriptionDiv" class="span-8 CombatantContent last">
                <h2>Description</h2>
                <div class="primary" style="margin-left:6px;">
                    <span class="{@safe-key}BeforeEditorKnown">
                        <div class="secondary">Name</div>
                        <xsl:value-of select="@name" />
                        <div class="secondary">Campaign Setting</div>
                        <xsl:value-of select="@world" />

                        <div class="secondary">Description</div>
                        <xsl:call-template name="break">
                            <xsl:with-param name="text" select="Description/node()" />
                        </xsl:call-template>
                    </span>
                    <span class="{@safe-key}NotEditor" style="display:none;">
                        <div class="secondary">Name</div>
                        <xsl:value-of select="@name" />
                        <div class="secondary">Campaign Setting</div>
                        <xsl:value-of select="@world" />

                        <div class="secondary">Description</div>
                        <xsl:call-template name="break">
                            <xsl:with-param name="text" select="Description/node()" />
                        </xsl:call-template>
                    </span>
                    <span class="{@safe-key}EditorOnly" style="display:none;">
                        <form action="/campaigns/save" method="POST" style="margin:6px 4px;position:relative;">
                            <div class="secondary">Name</div>
                            <input type="text" name="name" value="{@name}" style="width:280px;padding-right:5px;padding-left:5px;" />

                            <div class="secondary">Campaign Setting</div>
                            <input type="text" name="world" value="{@world}" style="width:280px;padding-right:5px;padding-left:5px;" />

                            <div class="secondary">Description</div>
                            <textarea id="campaignDescriptionText" name="description" 
                            style="height:8em;width:280px;"><xsl:value-of select="Description/node()" /></textarea>

                            <div class="secondary">Character Editing</div>
                            <select name="editrule" id="{@safe-key}editrule">
                                <option id="{@safe-key}editruledmonly" value="dmonly">Character owner and DM</option>
                                <option id="{@safe-key}editruleplayers" value="players">Any player in the campaign</option>
                            </select>
                            <script>
                                var safeKey = '<xsl:value-of select="@safe-key" />';
                                var editrule = '<xsl:value-of select="@editrule" />' || 'dmonly';
                                $(safeKey + 'editrule' + editrule).selected = true;
                            </script>

                            <br/>
                            <input type="hidden" name="key" value="{@key}" />
                            <input type="submit" value="Save changes" style="margin-top:12px;" />
                        </form>
                    </span>
                </div>
            </div>
</xsl:template>

<xsl:template match="Campaign" mode="overviewPanel">
    <xsl:variable name="ownerName">
        <xsl:choose>
            <xsl:when test="Players/Player[position()=1]/@handle!=''"><xsl:value-of select="Players/Player[position()=1]/@handle" /></xsl:when>
            <xsl:otherwise><xsl:value-of select="Players/Player[position()=1]/@nickname" /></xsl:otherwise>
        </xsl:choose>
    </xsl:variable> 
    <div id="{@key}RosterDiv" class="span-16 CombatantContent">
        <h2>
            <span style="float:right;padding-right:4px;">Players</span>
            Characters
        </h2>
        <div class="span-16 last CampaignCharacterList">
            <h3 class="{@safe-key}OwnerOnly" style="display:none;float:right;margin:6px 6px;">
                <span 
                 style="padding-left:15px; background-image: url(/TIME_TOKEN/images/plus_circle_small.png); background-repeat: no-repeat; background-position: 0 2px; cursor:pointer;"
                 onclick="$(this).up('.CampaignCharacterList').next('.CampaignCharacterAdd').hide(); var next = $($(this).up('.CampaignCharacterList').next('.CampaignPlayerAdd')); (next.visible() ? next.hide() : next.show()); $('campaignPlayersText').focus(); sizeCampaignPanels();"
                >   
                Add players...
                </span>
            </h3>
            <h3 class="{@safe-key}MemberOnly" style="display:none;margin:6px 6px;">
                <span 
                 style="padding-left:15px; background-image: url(/TIME_TOKEN/images/plus_circle_small.png); background-repeat: no-repeat; background-position: 0 2px; cursor:pointer;"
                 onclick="$(this).up('.CampaignCharacterList').next('.CampaignPlayerAdd').hide(); var next = $($(this).up('.CampaignCharacterList').next('.CampaignCharacterAdd')); (next.visible() ? next.hide() : next.show()); sizeCampaignPanels();"
                >   
                Add characters...
                </span>
            </h3>
        </div>
        <div class="span-16 last CampaignPlayerAdd" style="display:none;overflow:hidden;">
            <div style="float:right;margin-right:6px; ">
                <form action="/campaigns/addplayers" method="POST" style="margin-bottom:6px;" target="addPlayerIframe">
                    Players may view all characters and add new ones.
                    <br/>
                    Enter one new player per line in the text box below.
                    <br/>
                You may use handles or Google account email addresses.
                    <br/>
                    <textarea id="campaignPlayersText" name="players" 
                    style="width:280px;height:6em;"></textarea>
                    <br/>
                    <input type="hidden" name="key" value="{@key}" />
                    <input type="submit" value="Add players" />
                </form>
                <div>
                    <iframe id="addPlayerIframe" name="addPlayerIframe" frameborder="no" 
                    style="display:none;height:0px;"></iframe>
                </div>
            </div>
        </div>
        <div class="span-16 last CampaignCharacterAdd" style="display:none;padding-left:6px;">
            <form action="/campaigns/addcharacters" method="POST" style="margin-bottom:6px;">
                You may add any character you own to the campaign.
                <br />
                The campaign owner 
                    (<xsl:value-of select="$ownerName" />)
                will be able to edit any characters you add.
                <br />
                Select the characters you would like to add:
                <div id="addCharactersDiv" style="margin-bottom:6px;">
                </div>
                <input type="hidden" name="key" value="{@key}" />
                <input type="submit" value="Add characters" />
            </form>
        </div>
        <div class="span-16 last CampaignCharacterList">
            <div class="span-16 last CampaignPlayerList">
                <xsl:apply-templates select="Players/Player" mode="withCharacters" />
            </div>
        </div>
    </div>
</xsl:template>

<xsl:template match="Campaign" mode="overviewTab">
    <div class="span-24 last" style="text-align:center;overflow:hidden;">
        <xsl:apply-templates select="." mode="overviewPanel" />
        <xsl:apply-templates select="." mode="descriptionPanel" />
        <script type="text/javascript" language="javascript">
            var thisKey = '<xsl:value-of select="@key"/>';
            $$('#'+thisKey+'Container .RemoveCharacterLink').invoke('observe', 'click', function(e)
            {   var playerLink = e.element();
                if (!confirm('Remove ' + playerLink.next().innerHTML + ' from this campaign?')) return;
                new Ajax.Request('/campaigns/removecharacter?key=' + thisKey + '&amp;character=' + playerLink.id, { method:'get' });
            });
            $$('#'+thisKey+'Container .RemovePlayerLink').invoke('observe', 'click', function(e)
            {   var playerLink = e.element();
                if (!confirm('Remove ' + playerLink.previous().innerHTML + ' from this campaign?  This will also remove any characters they have added.')) return;
                playerLink.up('.CampaignItem').remove();
                new Ajax.Request('/campaigns/removeplayer?key=' + thisKey + '&amp;player=' + playerLink.id, { method:'get' });
            });
            sizeCampaignPanels = function()
            {   var thisKey = '<xsl:value-of select="@key" />';
                var siblingDivs = [ $(thisKey + 'DescriptionDiv'), $(thisKey + 'RosterDiv') ]
                makeDivsEqualHeight(siblingDivs);
                sizeParentIframeToMyContainer();
            };
            Event.observe(document, 'dom:loaded', sizeCampaignPanels);
        </script>
    </div>
</xsl:template>

<xsl:template match="Campaign" mode="characterSheetsTab">
    <xsl:if test="Characters/Character">
        <div class="span-24 last" style="text-align:center;overflow:hidden;">
            <iframe scrolling="no" frameborder="no" id="{@key}characterSheetsFrame" name="{@key}characterSheetsFrame"
             style="height:100px;width:950px;position:relative;left:0;overflow:hidden;"
             src="/TIME_TOKEN/html/loading.html"
            > </iframe>
            <form id="{@key}characterSheetsForm" style="display:none;" target="{@key}characterSheetsFrame" action="/views">
                <input type="hidden" name="xsl" value="characterSheets" />
                <xsl:for-each select="Characters/Character">
                    <input type="hidden" name="key" value="{@key}" />
                </xsl:for-each>
            </form>
            <script type="text/javascript" language="javascript">
                var thisCampaignKey = '<xsl:value-of select="@key" />';
                document.getElementById(thisCampaignKey + 'characterSheetsForm').submit();
            </script>
        </div>
    </xsl:if>
</xsl:template>

<xsl:template match="Campaign" mode="partyToolsTab">
    <div class="span-24 last" style="text-align:center;overflow:hidden;">
        <iframe scrolling="no" frameborder="no" id="{@key}partyToolsFrame" name="{@key}partyToolsFrame"
         style="height:100px;width:950px;position:relative;left:0;overflow:hidden;"
         src="/TIME_TOKEN/html/loading.html"
        > </iframe>
        <form id="{@key}partyToolsForm" style="display:none;" target="{@key}partyToolsFrame" action="/views">
            <input type="hidden" name="xsl" value="partyTools" />
            <xsl:for-each select="Characters/Character">
                <input type="hidden" name="key" value="{@key}" />
            </xsl:for-each>
        </form>
        <script type="text/javascript" language="javascript">
            var thisCampaignKey = '<xsl:value-of select="@key" />';
            document.getElementById(thisCampaignKey + 'partyToolsForm').submit();
        </script>
    </div>
</xsl:template>

<xsl:template match="Campaign" mode="inCombatTab">
    <div class="span-24 last {@safe-key}OwnerOnly" style="overflow:hidden;">
        <iframe scrolling="auto" frameborder="no" id="{@key}inCombatFrame" name="{@key}inCombatFrame"
         style="height:745px;width:950px;position:relative;overflow:hidden;"
         src="/TIME_TOKEN/html/loading.html"
        > </iframe>
        <form id="{@key}inCombatForm" style="display:none;" target="{@key}inCombatFrame" method="POST"
         action="http://laughterforever.com/inCombat/ip4_inCombat.html"
        >
            <input type="hidden" name="key" value="{@key}" />
        </form>
        <script type="text/javascript" language="javascript">
            var thisCampaignKey = '<xsl:value-of select="@key" />';
            document.getElementById(thisCampaignKey + 'inCombatForm').submit();
        </script>
    </div>
</xsl:template>

<xsl:template match="Campaign" mode="campaignTabLinks">
    <div class="span-24 CombatantContent last CampaignTabLinks" id="{@key}CampaignTabLinks">
        <h2>
            <span id="overviewActivator">
                <a href="/view?key={@key}">
                    Home
                </a>
            </span>
            <xsl:choose>
                <xsl:when test="Characters/Character">
                    <span id="characterSheetsActivator" style="margin-left:35px;">
                        <a href="/views?key={@key}&amp;xsl=characterSheets&amp;usecharacters=1">
                            Characters
                        </a>
                    </span>
                    <!--
                    <span id="partySheetActivator">
                        <a href="/views?key={@key}&amp;xsl=partySheet">
                            Party
                        </a>
                    </span>
                    -->
                    <span id="inCombatActivator" style="margin-left:35px;">
                        <a href="/views?key={@key}&amp;xsl=inCombat">
                            inCombat
                        </a>
                    </span>

                    <xsl:apply-templates select="." mode="customCampaignTabs" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="." mode="customCampaignTabs" />
                    <div class="IconHolder" style="display:inline;"><!-- because spans are switchers -->
                        (More tabs will appear once characters have been added)
                    </div>
                </xsl:otherwise>
            </xsl:choose>
        </h2>
    </div>
</xsl:template>

<xsl:template match="Campaign" mode="customCampaignTabs">

    <div style="margin-left:35px;display:inline;">


        <!-- The group must be configured or you must be the owner for the tab to appear -->

        <!--
        <xsl:choose>
            <xsl:when test="@groupUrl!=''">
                <span id="groupActivator">
                    <a href="/view?key={@key}&amp;xsl=group">
                        Group
                    </a>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span class="{@safe-key}OwnerOnly" id="groupActivator" style="display:none;">
                    <a href="/view?key={@key}&amp;xsl=group">
                        <img src="/TIME_TOKEN/images/plus_circle_small.png" /> Add Group
                    </a>
                </span>
            </xsl:otherwise>
        </xsl:choose>
        -->

        <!-- The wiki must be configured or you must be the owner for the tab to appear -->
        <!--
        <xsl:choose>
            <xsl:when test="@wikiUrl!=''">
                <span id="wikiActivator" >
                    <a href="/view?key={@key}&amp;xsl=wiki">
                        Wiki
                    </a>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span class="{@safe-key}OwnerOnly" id="wikiActivator" style="display:none;">
                    <a href="/view?key={@key}&amp;xsl=wiki">
                        <img src="/TIME_TOKEN/images/plus_circle_small.png" /> Add Wiki
                    </a>
                </span>
            </xsl:otherwise>
        </xsl:choose>
        -->

        <!-- The blog must be configured or you must be the owner for the tab to appear -->
        <!--
        <xsl:choose>
            <xsl:when test="@blogUrl!=''">
                <span id="blogActivator">
                    <a href="/view?key={@key}&amp;xsl=blog">
                        Blog
                    </a>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span class="{@safe-key}OwnerOnly" id="blogActivator" style="display:none;">
                    <a href="/view?key={@key}&amp;xsl=blog">
                        <img src="/TIME_TOKEN/images/plus_circle_small.png" /> Add Blog
                    </a>
                </span>
            </xsl:otherwise>
        </xsl:choose>
        -->

        <div class="IconHolder" style="display:inline; margin-left:35px;"><!-- because spans are switchers -->
            <a href="#" class="IconLink" style="text-decoration:none;"
             onclick="$(this).up('h2').select('span a').each(function(a)
             {{     
                    window.open(a.href, a.innerHTML, '');
             }});">
                <img src="/TIME_TOKEN/images/eye.png" />
                <u>Open tabs in separate windows</u>
            </a>
        </div>
    </div>

</xsl:template>

<xsl:template match="Campaign/Characters/Character">
    <xsl:variable name="titleLine2">
        <xsl:call-template name="afterLastComma">
            <xsl:with-param name="text" select="@title" />
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="titleLine1" select="substring-before(@title, concat(',', $titleLine2))" />
    <span class="CampaignItem">
            <span class="{../../@safe-key}BeforeOwnerKnown">
                <div class="primary">
                    <a href="#" onclick="
                        EwgCookie.setCookie('innerKey', '{@key}'); document.location='/views?key={../../@key}&amp;xsl=characterSheets&amp;usecharacters=1';return false; " >
                        <xsl:value-of select="$titleLine1" /> <!-- Populates the javascript confirm -->
                    </a>
                </div>
                <div class="secondary">
                    <a href="#" onclick="
                        EwgCookie.setCookie('innerKey', '{@key}'); document.location='/views?key={../../@key}&amp;xsl=characterSheets&amp;usecharacters=1';return false; " >
                        <xsl:value-of select="$titleLine2" />
                    </a>
                </div>
            </span>
            <span class="{../../@safe-key}NotOwner" style="display:none;">
                <div class="primary">
                    <a href="#" onclick="
                        EwgCookie.setCookie('innerKey', '{@key}'); document.location='/views?key={../../@key}&amp;xsl=characterSheets&amp;usecharacters=1';return false; " >
                        <xsl:value-of select="$titleLine1" /> <!-- Populates the javascript confirm -->
                    </a>
                </div>
                <div class="secondary">
                    <a href="#" onclick="
                        EwgCookie.setCookie('innerKey', '{@key}'); document.location='/views?key={../../@key}&amp;xsl=characterSheets&amp;usecharacters=1';return false; " >
                        <xsl:value-of select="$titleLine2" />
                    </a>
                </div>
            </span>
            <span class="{../../@safe-key}OwnerOnly" style="display:none;">
                <div class="primary">
                    <span class="RemoveCharacterLink" id="{@key}"
                     style="padding-left:10px; cursor:pointer; background-image: url(/TIME_TOKEN/images/minus_circle_small.png); background-repeat: no-repeat; background-position: 0 2px;"
                    >
                        <xsl:text>&#xA0;</xsl:text>
                    </span>
                    <a href="#" onclick="
                        EwgCookie.setCookie('innerKey', '{@key}'); document.location='/views?key={../../@key}&amp;xsl=characterSheets&amp;usecharacters=1';return false; " >
                        <xsl:value-of select="$titleLine1" /> <!-- Populates the javascript confirm -->
                    </a>
                </div>
                <div class="secondary">
                    <a href="#" onclick="
                        EwgCookie.setCookie('innerKey', '{@key}'); document.location='/views?key={../../@key}&amp;xsl=characterSheets&amp;usecharacters=1';return false; " >
                        <xsl:value-of select="$titleLine2" />
                    </a>
                </div>
            </span>
        <a href="#" onclick="
            EwgCookie.setCookie('innerKey', '{@key}'); document.location='/views?key={../../@key}&amp;xsl=characterSheets&amp;usecharacters=1';return false; " >
            <xsl:value-of select="@subtitle" />
        </a>
    </span>
</xsl:template>

<xsl:template match="Campaign/Players/Player" mode="withCharacters">
    <xsl:variable name="id">
        <xsl:value-of select="@id" />
    </xsl:variable> 
    <xsl:variable name="displayname">
        <xsl:choose>
            <xsl:when test="@handle!=''"><xsl:value-of select="@handle" /></xsl:when>
            <xsl:otherwise><xsl:value-of select="@nickname" /></xsl:otherwise>
        </xsl:choose>
    </xsl:variable> 
    <xsl:variable name="campaignRole">
        <xsl:choose>
            <xsl:when test="position()=1">Campaign owner / master</xsl:when>
            <xsl:otherwise>Player</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <div class="CampaignItem" style="margin:0 6px;">
        <hr style="margin: 1px 0;" />
        <div style="float:right; clear:both; text-align:right;">
            <div class="primary" style="margin-right:0;">
                <span class="{../../@safe-key}BeforeOwnerKnown">
                    <xsl:value-of select="$displayname" />
                </span>
                <span class="{../../@safe-key}NotOwner" style="display:none;">
                    <xsl:value-of select="$displayname" />
                </span>
                <span class="{../../@safe-key}OwnerOnly" style="display:none;">
                    <span> <!-- Populates the javascript confirm -->
                        <xsl:value-of select="$displayname" />
                    </span>
                    <span class="RemovePlayerLink" id="{@id}"
                     style="margin-left: 4px; padding-left:10px; cursor:pointer; background-image: url(/TIME_TOKEN/images/minus_circle_small.png); background-repeat: no-repeat; background-position: 0% 100%; position:relative; top:-1px;"
                    >
                        <xsl:text>&#xA0;</xsl:text>
                    </span>
                </span>
            </div>
            <xsl:value-of select="$campaignRole" />
        </div>
        <xsl:apply-templates select="../../Characters/Character[@ownerid=$id]" />
    </div>
</xsl:template>

<xsl:template name="afterLastComma">
    <xsl:param name="text" select="."/>
    <xsl:choose>
        <xsl:when test="contains($text, ',')">
            <xsl:call-template name="afterLastComma">
                <xsl:with-param name="text" select="substring-after($text, ',')" />
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$text"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="escapeJS">
    <xsl:param name="text" select="."/>
    <xsl:variable name="apos" select='"&apos;"' />
    <xsl:choose>
        <xsl:when test="contains($text, $apos)">
            <xsl:value-of select="substring-before($text, $apos)"/>
            <xsl:call-template name="escapeJS">
                <xsl:with-param name="text" select="substring-after($text, $apos)" />
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$text"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="formattedtext">
    <xsl:param name="text" select="."/>
    <xsl:call-template name="break">
        <xsl:with-param name="text">
            <xsl:call-template name="indentation">
                <xsl:with-param name="text" select="$text"/>
            </xsl:call-template>
        </xsl:with-param>
    </xsl:call-template>
</xsl:template>

<xsl:template name="leadingspace">
    <xsl:param name="text" select="."/>
    <xsl:choose>
        <xsl:when test="contains($text, ' ')">
            <xsl:choose>
                <xsl:when test="substring-before($text, ' ')=''">
                    <xsl:value-of select="substring-before($text, ' ')"/>
                    <xsl:text>&#xA0;&#xA0;&#xA0;&#xA0;</xsl:text>
                    <xsl:value-of select="substring-after($text, ' ')" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$text"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$text"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>

<xsl:template name="indentation">
    <xsl:param name="text" select="."/>
    <xsl:choose>
        <xsl:when test="contains($text, '&#x09;')">
            <xsl:value-of select="substring-before($text, '&#x09;')"/>
            <xsl:text>&#xA0;&#xA0;&#xA0;&#xA0;</xsl:text>
            <xsl:call-template name="indentation">
                <xsl:with-param name="text" select="substring-after($text, '&#x09;')" />
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$text"/>
        </xsl:otherwise>
    </xsl:choose>
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

<xsl:template name="join" >
    <xsl:param name="valueList" select="''"/>
    <xsl:param name="separator" select="','"/>
    <xsl:for-each select="$valueList">
      <xsl:choose>
        <xsl:when test="position() = 1">
          <xsl:value-of select="."/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($separator, .) "/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
</xsl:template>

<xsl:template match="Character" mode="fulloldbody">
    <div id="{@key}" class="{@safe-key}Multiple CharacterOuterDiv">
        <div class="container ">
            <xsl:apply-templates select="." mode="powerContent" />
            <xsl:apply-templates select="." mode="controlBar" />
            <xsl:apply-templates select="." mode="combatBar2" />
            <div class="span-24 last" id="fulloldbrowser" style="margin-bottom:8px;">
                <div class="span-20 Sibling">
                    <xsl:call-template name="CharacterSection">
                        <xsl:with-param name="style" select="'background:#F0EDD2; border-bottom:none;'" />
                        <xsl:with-param name="multiplesActive" select="'yes'" />
                        <xsl:with-param name="id" select="concat(@key, 'buildLangProfFeat')" />
                        <xsl:with-param name="width" select="20" />
                        <xsl:with-param name="contentStyle">height:auto;min-height:520px;</xsl:with-param>
                        <xsl:with-param name="titleStyle">
                            font-size:1.4em; padding-top:6px;
                            border:none; border-bottom: 1px solid #bbb;
                        </xsl:with-param>
                        <xsl:with-param name="title">
                            <span class="Active" style="color:black; margin-right:12px;">Powers</span>
                            <span style="color:black; margin-right:12px;">Build</span>
                            <span style="color:black; margin-right:12px;">Loot</span>
                            <span style="color:black; margin-right:12px;">Notes</span>
                        </xsl:with-param>
                        <xsl:with-param name="content">
                            <div class="span-20 last">
                                <div class="span-20 last" style="background:#F0EDD2;">
                                    <table style="margin:0; padding-right:8px;" rows="1" cols="4">
                                        <tr>
                                            <td style="padding:0 0 0 4px;vertical-align:top;">
                                                <div style="height:overflow:auto;">
                                                    <p>
                                                        <xsl:apply-templates select="Powers" mode="list">
                                                            <xsl:with-param name="isMore" select="''" />
                                                            <xsl:with-param name="actiontype" select="'Standard Action'" />
								                            <xsl:with-param name="emptyValue" select="''" />
                                                        </xsl:apply-templates>
                                                    </p>
                                                    <p>
							                            <h3 style="cursor:pointer;"
             onclick="var detailsDiv = $(this).next(); detailsDiv.visible() ? detailsDiv.hide() : detailsDiv.show(); sizeParentIframeToMyContainer();">
                                                            More <small>&#9660;</small>
                                                        </h3>
                                                        <div style="display:none;">
                                                            <xsl:apply-templates select="Powers" mode="list">
                                                                <xsl:with-param name="isMore" select="'true'" />
							                                    <xsl:with-param name="noTitle" select="'noTitle'" />
                                                                <xsl:with-param name="actiontype" select="'Standard Action'" />
								                                <xsl:with-param name="emptyValue" select="''" />
                                                            </xsl:apply-templates>
                                                        </div>
                                                    </p>
                                                </div>
                                            </td>
                                            <td style="padding:0;vertical-align:top;">
								                <div style="height:overflow:auto;">
                                                    <p>
								                        <xsl:apply-templates select="Powers" mode="list">
								                            <xsl:with-param name="isMore" select="''" />
								                            <xsl:with-param name="actiontype" select="'Move Action'" />
								                            <xsl:with-param name="emptyValue" select="''" />
								                        </xsl:apply-templates>
								                        <xsl:apply-templates select="Powers" mode="list">
			                                                <xsl:with-param name="noTitle" select="'noTitle'" />
								                            <xsl:with-param name="isMore" select="'true'" />
								                            <xsl:with-param name="actiontype" select="'Move Action'" />
								                            <xsl:with-param name="emptyValue" select="''" />
								                        </xsl:apply-templates>
                                                    </p>
								                </div>
                                            </td>
                                            <td style="padding:0;vertical-align:top;">
								                <div style="height:overflow:auto;">
                                                    <p>
								                        <xsl:apply-templates select="Powers" mode="list">
								                            <xsl:with-param name="isMore" select="''" />
								                            <xsl:with-param name="actiontype" select="'Minor Action'" />
								                            <xsl:with-param name="emptyValue" select="''" />
								                        </xsl:apply-templates>
							                            <xsl:apply-templates select="Powers" mode="list">
			                                                <xsl:with-param name="noTitle" select="'noTitle'" />
								                            <xsl:with-param name="emptyValue" select="''" />
							                                <xsl:with-param name="isMore" select="'true'" />
							                                <xsl:with-param name="actiontype" select="'Minor Action'" />
							                            </xsl:apply-templates>
                                                       </p>
                                                       <p>
							                            <h3>Free Action</h3>
							                            <xsl:apply-templates select="Powers" mode="list">
							                                <xsl:with-param name="isMore" select="''" />
							                                <xsl:with-param name="noTitle" select="'noTitle'" />
							                                <xsl:with-param name="actiontype" select="'Free Action'" />
							                                <xsl:with-param name="emptyValue" select="''" />
							                            </xsl:apply-templates>
							                            <xsl:apply-templates select="Powers" mode="list">
							                                <xsl:with-param name="isMore" select="'true'" />
							                                <xsl:with-param name="noTitle" select="'noTitle'" />
							                                <xsl:with-param name="actiontype" select="'Free Action'" />
							                                <xsl:with-param name="emptyValue" select="''" />
							                            </xsl:apply-templates>
                                                       </p>
                                                       <p>
							                            <h3>No Action</h3>
							                            <xsl:apply-templates select="Powers" mode="list">
							                                <xsl:with-param name="isMore" select="''" />
							                                <xsl:with-param name="noTitle" select="'noTitle'" />
							                                <xsl:with-param name="actiontype" select="'No Action'" />
							                                <xsl:with-param name="emptyValue" select="''" />
							                            </xsl:apply-templates>
							                            <xsl:apply-templates select="Powers" mode="list">
							                                <xsl:with-param name="isMore" select="'true'" />
							                                <xsl:with-param name="noTitle" select="'noTitle'" />
							                                <xsl:with-param name="actiontype" select="'No Action'" />
							                                <xsl:with-param name="emptyValue" select="''" />
							                            </xsl:apply-templates>
								                        <xsl:if test="count(Powers/Power[starts-with(@actiontype, 'No Action')]) = 0">
                                                            <div class="primary">
                                                                ---
                                                            </div>
                                                        </xsl:if>
                                                       </p>
								                </div>
                                            </td>
                                            <td style="padding:0;vertical-align:top;">
								                <div style="height:overflow:auto;">
                                                    <p>
								                        <h3>Opportunity Action</h3>
							                            <xsl:apply-templates select="Powers" mode="list">
							                                <xsl:with-param name="isMore" select="''" />
							                                <xsl:with-param name="emptyValue" select="''" />
							                                <xsl:with-param name="noTitle" select="'noTitle'" />
							                                <xsl:with-param name="actiontype" select="'Opportunity Action'" />
							                            </xsl:apply-templates>
								                        <xsl:apply-templates select="Powers" mode="list">
								                            <xsl:with-param name="isMore" select="'true'" />
							                                <xsl:with-param name="emptyValue" select="''" />
								                            <xsl:with-param name="noTitle" select="'noTitle'" />
								                            <xsl:with-param name="actiontype" select="'Opportunity Action'" />
								                        </xsl:apply-templates>
                                                    </p>
								                    <p>
							                            <h3>Immediate Interrupt</h3>
							                            <xsl:apply-templates select="Powers" mode="list">
							                                <xsl:with-param name="isMore" select="''" />
							                                <xsl:with-param name="emptyValue" select="''" />
							                                <xsl:with-param name="noTitle" select="'noTitle'" />
							                                <xsl:with-param name="actiontype" select="'Immediate Interrupt'" />
							                            </xsl:apply-templates>
								                        <xsl:apply-templates select="Powers" mode="list">
								                            <xsl:with-param name="isMore" select="'true'" />
							                                <xsl:with-param name="emptyValue" select="''" />
								                            <xsl:with-param name="noTitle" select="'noTitle'" />
								                            <xsl:with-param name="actiontype" select="'Immediate Interrupt'" />
								                        </xsl:apply-templates>
								                        <xsl:if test="count(Powers/Power[starts-with(@actiontype, 'Immediate Interrupt')]) = 0">
                                                            <div class="primary">
                                                                ---
                                                            </div>
                                                        </xsl:if>
                                                    </p>
								                    <p>
							                            <h3>Immediate Reaction</h3>
							                            <xsl:apply-templates select="Powers" mode="list">
							                                <xsl:with-param name="isMore" select="''" />
							                                <xsl:with-param name="emptyValue" select="''" />
							                                <xsl:with-param name="noTitle" select="'noTitle'" />
							                                <xsl:with-param name="actiontype" select="'Immediate Reaction'" />
							                            </xsl:apply-templates>
								                        <xsl:apply-templates select="Powers" mode="list">
								                            <xsl:with-param name="isMore" select="'true'" />
							                                <xsl:with-param name="emptyValue" select="''" />
								                            <xsl:with-param name="noTitle" select="'noTitle'" />
								                            <xsl:with-param name="actiontype" select="'Immediate Reaction'" />
								                        </xsl:apply-templates>
								                    </p>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                            <div class="span-20 last" style="display:none;">
                                <div class="span-5">
                                    <div style="margin-left:6px;">
                                        <xsl:apply-templates select="Build" mode="talldiv" />
                                    </div>
                                </div>
                                <div class="span-10">
                                    <h3>Feats</h3>
                                    <xsl:apply-templates select="Feats/Feat" mode="listitem" />
                                </div>
                                <div class="span-5 last">
                                    <h3>Languages</h3>
                                    <xsl:apply-templates select="Languages/Language" mode="listitems" />
                                    <xsl:apply-templates select="Proficiencies" mode="listitems" />
                                </div>
                            </div>
                            <div class="span-20 last" style="display:none;">
                                <div class="span-8">
                                    <p style="margin-left:16px;">
                                        <xsl:apply-templates select="Loot" mode="lootDiv" />
                                    </p>
                                </div>
                                <div class="span-4">
                                    <p>
                                        <xsl:apply-templates select="Loot" mode="ritualsDiv" />
                                    </p>
                                </div>
                                <div class="span-8 last">
                                    <p>
                                        <xsl:apply-templates select="Loot" mode="moneyDiv" />
                                    </p>
                                </div>
                            </div>
                            <div class="span-20 last" style="display:none;">
                                <div class="span-10">
                                    <xsl:apply-templates select="Description/Notes" mode="listitem" />
                                    <br/>
                                    <br/>
                                    <xsl:apply-templates select="Description/Appearance" mode="listitem" />
                                </div>
                                <div class="span-10 last">
                                    <xsl:apply-templates select="Description/Traits" mode="listitem" />
                                    <br/>
                                    <br/>
                                    <xsl:apply-templates select="Description/Companions" mode="listitem" />
                                </div>
                            </div>
                        </xsl:with-param>
                    </xsl:call-template>
                </div>
                <div class="span-4 last Sibling">
                    <xsl:call-template name="CharacterSection">
                            <xsl:with-param name="multiplesActive" select="'yes'" />
                        <xsl:with-param name="id" select="concat(@key, 'skillsAndAbilities')" />
                        <xsl:with-param name="width" select="4" />
                        <xsl:with-param name="contentStyle">overflow:hidden;height:540px;</xsl:with-param>
                        <xsl:with-param name="content">
                            <div>
                                <h3 style="margin-bottom:2px;">Skills</h3>
                                <table style="margin:0;" cols="2" class="SkillHeatmap">
                                    <xsl:apply-templates select="Skills/Skill" mode="listitem" />
                                </table>
                                <h3>Ability Scores</h3>
                                <table cellpadding="0" cellspacing="0" style="font-size:1.3em;" class="AbilityHeatmap">
                                    <xsl:apply-templates select="AbilityScores/AbilityScore" mode="listitem" />
                                </table>
                                <script type="text/javascript" language="javascript">
                                    makeHeatmap('.SkillHeatmap .Roller', '.SkillHeatmap .RollerCell');
                                    makeHeatmap('.AbilityHeatmap .Roller', '.AbilityHeatmap .Roller');
                                </script>
                            </div>
                        </xsl:with-param>
                    </xsl:call-template>
                </div>
            </div>
        </div>
    </div>
</xsl:template>

</xsl:stylesheet>
