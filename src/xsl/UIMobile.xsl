<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" encoding="ISO-8859-1" indent="yes"
 doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
 doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

<xsl:template match="Player" mode="listitem">
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
    <li>
        <div class="primary">
            <xsl:value-of select="$displayname" />
        </div>
        <div class="secondary" style="clear:both;float:left;text-align:left;margin-left:10px;">
            <xsl:value-of select="$campaignRole" />
        </div>
    </li>
</xsl:template>

<xsl:template match="Character | Campaign" mode="listitem">
    <li class="withArrow">
        <a href="/view?xsl=jPint&amp;key={@key}">
            <xsl:variable name="numCommas" select="string-length(@title) - string-length(translate(@title, ',', ''))" />
            <xsl:if test="$numCommas!='0'">
                <div class="primary">
                    <xsl:value-of select="substring-before(@title, ',')" />
                </div>
                <div class="secondary" style="clear:both;float:left;text-align:left;margin-left:10px;">
                    <xsl:value-of select="substring-after(@title, ',')" />
                </div>
                <div class="tertiary">
                    <xsl:value-of select="@subtitle" />
                </div>
            </xsl:if>
            <xsl:if test="$numCommas='0'">
                <div class="primary">
                    <xsl:value-of select="@title" />
                </div>
                <div class="secondary" style="clear:both;float:left;text-align:left;margin-left:10px;">
                    <xsl:value-of select="@subtitle" />
                </div>
            </xsl:if>
        </a>
    </li>
</xsl:template>

<xsl:template name="headtag">
    <xsl:param name="title" />
    <head>
        <title>iPlay4e</title>

        <meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" />
        <meta name="viewport" content="user-scalable=no, width=device-width" />
        <meta name="apple-mobile-web-app-capable" content="yes" />
        <meta name="apple-mobile-web-app-status-bar-style" content="black" />
        <link rel="apple-touch-startup-image" href="/startup.png" />

        <link rel="stylesheet" type="text/css" charset="utf-8" href="/TIME_TOKEN/css/jPint.css" />
        <style type="text/css">
            .plaintext
            {   font-size:16px; font-weight:normal; margin:4px 10px;
            }
            .EdgedList ul li .plaintext a, .plaintext a,
            .EdgedList ul li .mainplaintext a, .mainplaintext a
            {   display:inline; text-decoration:underline; color:#6D84A2;
            }
            .EdgedList ul li ul li
            {   list-style-image: url(/TIME_TOKEN/images/d2016px.png);
                list-style-position: inside; list-style-type:none;
                padding-left: 20px; border-top:none;
                line-height:auto; min-height:none; font-weight:normal;
            }
            li .plaintext {margin:0 10px;}

            .mainplaintext
            {   font-size:16px; font-weight:normal; margin:4px 10px;
            }
            .EdgedList ul li .mainplaintext
            {   background-image: url(/TIME_TOKEN/images/d2016px.png);
                background-position: 2px left;
                background-repeat: no-repeat;
                padding-left: 20px;
            }
            li .mainplaintext {margin:0 10px;}
        </style>

        <script type="text/javascript" language="javascript" src="/TIME_TOKEN/js/prototype/prototype.js" />
        <script type="text/javascript" language="javascript" src="/TIME_TOKEN/js/iplay4e.js" />
        <script type="text/javascript" language="javascript">
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
</xsl:template>

<xsl:template name="header">
    <xsl:param name="title" />
    <h1 style="padding-left:10px;height:auto;">
        <div class="Subtitle" style="margin-right:10px;">
            <a class="SignInOut"></a>
        </div>
        <xsl:value-of select="$title" />
        <div style="position:relative;">
            <!-- The font-size CSS makes it not look ridiculous in Android 1.5 -->
            <form method="GET" action="/search" style="float:right;margin-right:16px;">
                <input name="q" id="searchText" style="width:222px;margin:2px 6px; font-size:.7em;" 
                 type="search" autocorrect="off" autocapitalize="off" placeholder="Search..." 
                 autosave="iplay4e" results="10"
                />
            </form>
            <a href="#" style="font-size:.8em; font-weight:normal;position:relative;top:4px;"
             onclick="var moreMenu = $('moreMenu'); moreMenu.visible() ? moreMenu.hide() : moreMenu.show();return false;"
            >
                <u>More...</u>
            </a>
            <script type="text/javascript" language="javascript">
                $('searchText').value = 
                    (unescape((document.location+'').toQueryParams()['q'] || '')+'').replace('+', ' ') || '';
            </script>
        </div>
    </h1>
    <div id="moreMenu" class="EdgedList" 
     style="display:none;position:absolute;top:61px;z-index:1000; background:white; border: 3px solid #6D84A2; border-top:none;">
        <ul>
            <li>
                <a href="/characters" style="padding-left:20px;padding-right:20px;">
                    Characters
                </a>
            </li>
            <li>
                <a href="/campaigns" style="padding-left:20px;padding-right:20px;">
                    Campaigns
                </a>
            </li>
            <li>
                <a target="forums" href="http://groups.google.com/group/iplay4e" 
                 style="padding-left:20px;padding-right:20px;">
                    Forums
                </a>
            </li>
            <li>
                <a href="/links" style="padding-left:20px;padding-right:20px;">
                    Links
                </a>
            </li>
            <li>
                <a href="/help" style="padding-left:20px;padding-right:20px;">
                    Help
                </a>
            </li>
            <li>
                <a href="/new" style="padding-left:20px;padding-right:20px;">
                    New features
                </a>
            </li>
            <li>
                <a href="/terms" style="padding-left:20px;padding-right:20px;">
                    Terms of Use
                </a>
            </li>
            <li>
                <a href="/privacy" style="padding-left:20px;padding-right:20px;">
                    Privacy Policy
                </a>
            </li>
        </ul>
    </div>
</xsl:template>

</xsl:stylesheet>
