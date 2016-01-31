<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" encoding="ISO-8859-1" indent="yes"
 doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
 doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

<xsl:include href="/TIME_TOKEN/xsl/UI.xsl" />

<xsl:template match="Campaign">
    <html>
        <head>
            <link rel="stylesheet" href="/TIME_TOKEN/css/gfdynamicfeedcontrol.css" type="text/css" />
        </head>
        <xsl:apply-templates select="." mode="header" />
        <body class="CharacterOuterDiv FullPageSheet">
            <div id="{@key}Container" class="{@key}Multiple container" style="text-align:left;">
                <xsl:apply-templates select="." mode="controlBar" />
                <xsl:apply-templates select="." mode="campaignTabLinks" />
                <xsl:choose>
                    <xsl:when test="@groupUrl=''">
                        <div class="span-24 last {@safe-key}OwnerOnly" id="{@key}CampaignTabs">
                            <div class="span-24 last" id="{@key}CampaignTabLinks" style="font-size:1.2em;">
                                <div style="margin-left:8px;">
                                    Please use Google Groups to set up a group for use as a mailing list.
                                </div>
                                <xsl:apply-templates select="." mode="configGroup" />
                                <div class="{@safe-key}NotOwner" style="display:none; margin-left:8px;">
                                    Please inform the owner of this campaign.
                                </div>
        
                            </div>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <div class="span-24 last" id="{@key}CampaignTabs">
                            <div class="span-24 last" style="font-size:1.2em;">
                                <div style="margin-left:8px;">
                                    <span class="FAQQuestion">
                                        <u><a target="group" href="http://groups.google.com/group/{@groupUrl}">http://groups.google.com/group/<xsl:value-of select="@groupUrl" /></a></u>
                                        <span class="{@safe-key}OwnerOnly" style="display:none;">
                                            |
                                            <a style="margin-left:4px;" href="#"
                                             onclick="new Effect.toggle('configGroup', 'blind', {{duration:.3}});return false;"
                                            ><u>Change</u>  <span style="font-size:.7em;">&#9660;</span></a>
                                        </span>
                                    </span>
                                </div>
                                <div class="{@safe-key}OwnerOnly" style="display:none;">
                                    <xsl:apply-templates select="." mode="configGroup" />
                                </div>
                            </div>
                        </div>
                            <div class="span-24 last CombatantContent" style="padding-top:6px;">
                                <div class="span-4">
                                    <a target="groups" href="http://groups.google.com/group/{@groupUrl}"><img src="http://groups.google.com/groups/img/3nb/groups_bar.gif" alt="Google Groups" style="height:26px;width:132px;margin:1px 3px 6px 4px;" /></a>
                                </div>
                                <div class="span-20 last" style="text-align:right;">
                                    <h4 style="margin:3px 6px;display:inline;">
                                        <a class="Button" target="forumWin" href="http://groups.google.com/group/{@groupUrl}/post">
                                            <img src="/TIME_TOKEN/images/plus_circle_small.png" /> New Post
                                        </a>
                                    </h4>
                                    <form action="http://groups.google.com/group/{@groupUrl}/boxsubscribe" target="forumWin"
                                     style="display:inline; margin-right:8px;">
                                        Email: 
                                        <input type="text" name="email" />
                                        <input type="submit" name="sub" value="Subscribe" />
                                    </form>
                                </div>
                                <hr style="margin:0 0 8px 0;"/>
                                
                                  <div id="feed-control">
                                    <span style="color:#676767;font-size:11px;margin:10px;padding:4px;">Loading...</span>
                                  </div>
                                
                                  <script src="http://www.google.com/jsapi?key=notsupplied-wizard"
                                    type="text/javascript"></script>
                                  <script src="http://www.google.com/uds/solutions/dynamicfeed/gfdynamicfeedcontrol.js"
                                    type="text/javascript"></script>
                                  <script type="text/javascript">
                                    var groupUrl = 'http://groups.google.com/group/<xsl:value-of select="@groupUrl" />';
                                    function LoadDynamicFeedControl() {
                                      var feeds = [ {title: 'iplay4e', url: groupUrl + '/feed/rss_v2_0_msgs.xml' } ];
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
                    </xsl:otherwise>
                </xsl:choose>
            </div>
            <script type="text/javascript" language="javascript">
                $('groupActivator').addClassName('Active');
            </script>
        </body>
    </html>
</xsl:template>

<xsl:template match="Campaign" mode="configGroup">
    <div id="configGroup" style="margin:16px; margin-top:0; display:none;">
            <hr style="margin-bottom:8px;"/>
            <div class="FAQAnswer">
                <form style="margin-0; display:inline;" method="POST" action="/campaigns/save">
                    http://groups.google.com/group/
                    <input type="text" name="groupUrl" value="{@groupUrl}" width="20" />
                    <input type="hidden" name="key" value="{@key}"/>
                    <input type="submit" value="Save" />
                </form>
            </div>
            <div class="FAQAnswer">
                <u><a target="googlegroups" 
                    href="http://groups.google.com/groups/create?addr={@name}&amp;name={@name}"
                >Create a Google Group</a></u>
                |
                <u><a target="googlegroups" href="http://groups.google.com">Google Groups Home</a></u>
                |
                <form style="margin-0; display:inline;" method="GET" target="googlegroups"
                 action="https://groups.google.com/groups/search">
                Search Google Groups:
                    <input type="text" name="q" />
                    <input type="hidden" name="qt_s" value="Search Groups" />
                    <input type="submit" value="Search" />
                </form>
            </div>
    </div>
    <script>
        if (!'<xsl:value-of select="@groupUrl" />') $('configGroup').show();
    </script>
</xsl:template>

</xsl:stylesheet>
