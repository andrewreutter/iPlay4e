<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" encoding="ISO-8859-1" indent="yes"
 doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
 doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

<xsl:include href="/143371090575/xsl/UI.xsl" />

<xsl:template match="Campaign">
    <html>
        <head>
            <link rel="stylesheet" href="/143371090575/css/gfdynamicfeedcontrol.css" type="text/css" />
        </head>
        <xsl:apply-templates select="." mode="header" />
        <body class="CharacterOuterDiv FullPageSheet">
            <div id="{@key}Container" class="{@key}Multiple container" style="text-align:left;">
                <xsl:apply-templates select="." mode="controlBar" />
                <xsl:apply-templates select="." mode="campaignTabLinks" />
                <xsl:choose>
                    <xsl:when test="@blogUrl=''">
                        <div class="span-24 last {@safe-key}OwnerOnly" id="{@key}CampaignTabs">
                            <div class="span-24 CombatantContent last" id="{@key}CampaignTabLinks" style="font-size:1.2em;">
                                <div style="margin-left:8px;">
                                        Please use Blogger to set up a blog for use in Play-By-Post games
                                </div>
                                <xsl:apply-templates select="." mode="configBlog" />
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
                                            <u><a target="blog" href="http://{@blogUrl}.blogspot.com">http://<xsl:value-of select="@blogUrl" />.blogspot.com</a></u>
                                            <span class="{@safe-key}OwnerOnly" style="display:none;">
                                                |
                                                <a style="margin-left:4px;" href="#"
                                                onclick="new Effect.toggle('configBlog', 'blind', {{duration:.3}});return false;"
                                                ><u>Change</u>  <span style="font-size:.7em;">&#9660;</span></a>
                                            </span>
                                    </span>
                                </div>
                                <div id="configBlog" style="display:none;">
                                    <xsl:apply-templates select="." mode="configBlog" />
                                </div>
                            </div>
                            <div class="span-24 last CombatantContent" style="padding-top:6px;">
                                <div class="span-24 last">
                                    <h2 style="font-size:1.4em; color:#3669D5; background:inherit; font-weight:normal; margin-bottom:8px;">
                                        <a target="blog" 
                                         href="http://{@blogUrl}.blogspot.com">Blogger.com</a>
                                    </h2>
                                    <iframe name="innerTool" id="innerTool" class="FAQAnswer" src="http://{@blogUrl}.blogspot.com" style="margin:0; height:30px; width:100%; padding:0; margin-top:6px; overflow-y:hidden;" scrolling="no">
                                    </iframe>
                                </div>
                                
                                  <div id="feed-control">
                                    <span style="color:#676767;font-size:11px;margin:10px;padding:4px;">Loading...</span>
                                  </div>
                                
                                  <script src="http://www.google.com/jsapi?key=notsupplied-wizard"
                                    type="text/javascript"></script>
                                  <script src="http://www.google.com/uds/solutions/dynamicfeed/gfdynamicfeedcontrol.js"
                                    type="text/javascript"></script>
                                  <script type="text/javascript">
                                    var blogUrl = 'http://<xsl:value-of select="@blogUrl" />.blogspot.com';
                                    function LoadDynamicFeedControl() {
                                      var feeds = [ {title: 'iplay4e', url: blogUrl + '/feeds/posts/default' } ];
                                      var options = {
                                        stacked : false, vertical : true, horizontal : false,
                                        title : " ",
                                        numResults: 12, scrollOnFadeOut: false, linkTarget: 'forumWin', displayTime:8000, fadeOutTime: 0
                                      };
                                
                                      new GFdynamicFeedControl(feeds, 'feed-control', options);
                                    }
                                    google.load('feeds', '1');
                                    google.setOnLoadCallback(LoadDynamicFeedControl);
                                  </script>
                            </div>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
            <script type="text/javascript" language="javascript">
                $('blogActivator').addClassName('Active');
            </script>
        </body>
    </html>
</xsl:template>

<xsl:template match="Campaign" mode="configBlog">
                                <div class="{@safe-key}OwnerOnly" style="margin:16px; margin-top:0; display:none;">
                                        <hr style="margin-bottom:8px;"/>
                                        <div class="FAQAnswer">
                                            <form style="margin-0; display:inline;" method="POST" action="/campaigns/save">
                                                http://
                                                <input type="text" name="blogUrl" value="{@blogUrl}" width="20" />
                                                .blogspot.com
                                                <input type="hidden" name="key" value="{@key}"/>
                                                <input type="submit" value="Save" />
                                            </form>
                                        </div>
                                        <div class="FAQAnswer">
                                            <u><a target="blogger" href="http://www.blogger.com/create-blog.g?hca=true"
                                            >Create a Blog on Blogger</a></u>
                                            |
                                            <u><a target="blogger" href="http://blogger.com">Blogger Home</a></u>
                                        </div>
                                </div>
</xsl:template>

</xsl:stylesheet>
