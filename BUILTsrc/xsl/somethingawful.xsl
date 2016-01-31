<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output indent="no" method="html"/>
    <xsl:variable name="opendetail"> [sub][super][i]</xsl:variable>
    <xsl:variable name="closedetail">[/i][/super][/sub]</xsl:variable>

    <!-- Think of this as the "main" routine.  But then don't think of anything else as a routine. -->
    <xsl:template match="Character">
         <!-- Instead of <PRE>, you might use <INPUT> to put the output in a textbox. -->
        <pre>
            <!-- Character Name. Understand why these three lines work they way they do before you try anything else. -->
            <xsl:text>[pre][b][u]</xsl:text>
            <xsl:value-of select="@name"/>
            <xsl:text>[/u][/b]</xsl:text>
            
            <xsl:apply-templates select="Description"/>
            <xsl:apply-templates select="AbilityScores"/>
            <xsl:apply-templates select="Health"/>
            <xsl:apply-templates select="Defenses"/>
            <xsl:apply-templates select="Build"/>
            <xsl:apply-templates select="Feats"/>
            <xsl:apply-templates select="Powers"/>
            <xsl:apply-templates select="Skills"/>
            <xsl:apply-templates select="Proficiencies"/>
            <xsl:apply-templates select="Loot"/>
            <xsl:text>[/pre]</xsl:text>
            <xsl:if test="Description/Appearance |Description/Traits | Description/Companions|Description/Notes ">
                <xsl:text>&#xA;[quote="Details"]</xsl:text>
                <xsl:apply-templates select="Description/Appearance"/>
                <xsl:apply-templates select="Description/Traits"/>
                <xsl:apply-templates select="Description/Companions"/>
                <xsl:apply-templates select="Description/Notes"/>
                <xsl:text>[/quote]</xsl:text>
            </xsl:if>
        </pre>
    </xsl:template>
    
    <!-- HEADER SECTION -->
    <xsl:template match="Description">
        <!-- &#xA; is the newline character represented in hex -->
        <xsl:text>&#xA;</xsl:text>
        <xsl:value-of select="../Build/Race/@name"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="../Build/Class/@name"/>        
        <xsl:apply-templates select="../Build/@name"/>
        <xsl:apply-templates select="../Build/ParagonPath/@name"/>
        <xsl:apply-templates select="../Build/EpicDestiny/@name"/>
        <xsl:text>&#xA;Level </xsl:text>
        <xsl:value-of select="../Build/@level"/>
        <xsl:apply-templates select="../Build/@alignment"/>
        <xsl:apply-templates select="@gender"/>
        <xsl:apply-templates select="@height"/>
        <xsl:apply-templates select="@weight"/>
        <xsl:apply-templates select="../Build/@experience"/>
        <xsl:apply-templates select="/Character/Languages"/> 
    </xsl:template>

    <!-- Optional items get their own template so they display neatly when missing. 
        This is often cleaner than using an if statement. -->
    <xsl:template match="Build/@name">
        <xsl:text> (</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>)</xsl:text>
    </xsl:template>
    <xsl:template match="@gender | @height | @weight | @alignment">
        <xsl:text>, </xsl:text>
        <xsl:value-of select="."/>
    </xsl:template>
    <xsl:template match="@experience">
        <xsl:text>&#xA;XP: </xsl:text>
        <xsl:value-of select="."/>
    </xsl:template>
    <xsl:template match="Languages">
        <xsl:text>&#xA;Languages: </xsl:text>
        <xsl:apply-templates select="Language"/>
    </xsl:template>
    <xsl:template match="Language">
        <xsl:value-of select="@name"/>
        <xsl:if test="position()!=last()">, </xsl:if>
    </xsl:template>
    <xsl:template match="ParagonPath/@name">
        <xsl:text> / </xsl:text>
        <xsl:value-of select="."/>
    </xsl:template>
    <xsl:template match="EpicDestiny/@name">
        <xsl:text> / </xsl:text>
        <xsl:value-of select="."/>
    </xsl:template>

    <!-- ABILITY SCORES SECTION -->
    <xsl:template match="AbilityScores">
        <!--xsl:text>&#xA;&#xA;[b]ABILITIES[/b]&#xA;</xsl:text-->
        <xsl:text>&#xA;</xsl:text>
        <xsl:apply-templates select="AbilityScore"/>
    </xsl:template>
    <xsl:template match="AbilityScore">
        <xsl:text>&#xA;</xsl:text>
        <xsl:value-of select="@abbreviation"/>
        <!-- Prepend pad always returns a string of length "length" with leading spaces 
            and @value aligned at the right.  Strings longer than "length" are truncated -->
        <xsl:call-template name="prepend-pad">
            <xsl:with-param name="length" select="4"/>
            <xsl:with-param name="padVar" select="@value"/>
        </xsl:call-template>
        <xsl:text> (</xsl:text>
        <xsl:call-template name="prepend-pad">
            <xsl:with-param name="length" select="3"/>
            <xsl:with-param name="padVar" select="./AbilityModifier/@modifier"/>
        </xsl:call-template>
        <xsl:text>)</xsl:text>
        <xsl:call-template name="AbilityFactorDetailLine">
            <xsl:with-param name="TheNode" select="."/>
        </xsl:call-template>
    </xsl:template>

    <!-- HEALTH SECTION -->
    <xsl:template match="Health">
        <xsl:text>&#xA;&#xA;[b]Hit Points[/b]</xsl:text>
        <!-- &#x9 is the tab character.  In this sheet it is used only at the start of lines. -->
        <xsl:call-template name="label-value-pad">
            <xsl:with-param name="label" select="'&#xA;&#x9;Max HP:'"/>
            <xsl:with-param name="labellength" select="14"/>
            <xsl:with-param name="value" select="MaxHitPoints/@value"/>
            <xsl:with-param name="valuelength" select="3"/>
        </xsl:call-template>
        <!-- If you wish to alter the way "factor details" are shown, see the FactorDetailLine template. -->
        <xsl:call-template name="FactorDetailLine">
            <xsl:with-param name="TheNode" select="MaxHitPoints"/>
        </xsl:call-template>
        <!-- Label-Value-Pad uses the prepend and append templates to align the label on the left and the value on the right. -->
        <xsl:call-template name="label-value-pad">
            <xsl:with-param name="label" select="'&#xA;&#x9;Bloodied:'"/>
            <xsl:with-param name="labellength" select="14"/>
            <xsl:with-param name="value" select="BloodiedValue/@value"/>
            <xsl:with-param name="valuelength" select="3"/>
        </xsl:call-template>
        <xsl:call-template name="FactorDetailLine">
            <xsl:with-param name="TheNode" select="BloodiedValue"/>
        </xsl:call-template>
        <xsl:call-template name="label-value-pad">
            <xsl:with-param name="label" select="'&#xA;&#x9;Surge:'"/>
            <xsl:with-param name="labellength" select="14"/>
            <xsl:with-param name="value" select="SurgeValue/@value"/>
            <xsl:with-param name="valuelength" select="3"/>
        </xsl:call-template>
        <xsl:call-template name="FactorDetailLine">
            <xsl:with-param name="TheNode" select="SurgeValue"/>
        </xsl:call-template>
        <xsl:call-template name="label-value-pad">
            <xsl:with-param name="label" select="'&#xA;&#x9;Surges/Day:'"/>
            <xsl:with-param name="labellength" select="14"/>
            <xsl:with-param name="value" select="MaxSurges/@value"/>
            <xsl:with-param name="valuelength" select="3"/>
        </xsl:call-template>
        <xsl:call-template name="FactorDetailLine">
            <xsl:with-param name="TheNode" select="MaxSurges"/>
        </xsl:call-template>
    </xsl:template>

    <!-- DEFENSES AND SENSES SECTION -->
    <xsl:template match="Defenses">
        <xsl:text>&#xA;&#xA;[b]Defenses and Senses[/b]</xsl:text>
        <!-- We explicitly apply four separate conditional templates to enforce display order. -->
        <xsl:apply-templates select="Defense[@abbreviation='AC']"/>
        <xsl:apply-templates select="Defense[@abbreviation='Fort']"/>
        <xsl:apply-templates select="Defense[@abbreviation='Ref']"/>
        <xsl:apply-templates select="Defense[@abbreviation='Will']"/>
        <xsl:text>&#xA;</xsl:text>
        <xsl:apply-templates select="/Character/PassiveSkills/PassiveSkill"/>
        <xsl:text>&#xA;</xsl:text>
        <xsl:apply-templates select="/Character/Movement"/>
        <xsl:if test="self::Defenses/Defense/Condition">
            <xsl:text>&#xA;&#xA;&#x9;Conditional Defenses:</xsl:text>
            <xsl:apply-templates select="Condition"/>
            <xsl:apply-templates select="Defense[@abbreviation='AC']/Condition"/>
            <xsl:apply-templates select="Defense[@abbreviation='Fort']/Condition"/>
            <xsl:apply-templates select="Defense[@abbreviation='Ref']/Condition"/>
            <xsl:apply-templates select="Defense[@abbreviation='Will']/Condition"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="Defense">
        <xsl:call-template name="label-value-pad">
            <xsl:with-param name="label" select="concat('&#xA;&#x9;',@abbreviation,':')"/>
            <xsl:with-param name="labellength" select="8"/>
            <xsl:with-param name="value" select="@value"/>
            <xsl:with-param name="valuelength" select="2"/>
        </xsl:call-template>
        <xsl:call-template name="FactorDetailLine">
            <xsl:with-param name="TheNode" select="."/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="Movement">
        <xsl:call-template name="label-value-pad">
            <xsl:with-param name="label" select="'&#xA;&#x9;Initiative:'"/>
            <xsl:with-param name="labellength" select="14"/>
            <xsl:with-param name="value" select="Initiative/@value"/>
            <xsl:with-param name="valuelength" select="2"/>
        </xsl:call-template>
        <xsl:call-template name="FactorDetailLine">
            <xsl:with-param name="TheNode" select="Initiative"/>
        </xsl:call-template>
        <xsl:call-template name="label-value-pad">
            <xsl:with-param name="label" select="'&#xA;&#x9;Speed:'"/>
            <xsl:with-param name="labellength" select="14"/>
            <xsl:with-param name="value" select="Speed/@value"/>
            <xsl:with-param name="valuelength" select="2"/>
        </xsl:call-template>
        <xsl:call-template name="FactorDetailLine">
            <xsl:with-param name="TheNode" select="Speed"/>
        </xsl:call-template>
        <xsl:call-template name="append-pad">
            <xsl:with-param name="length" select="14"/>
            <xsl:with-param name="padVar" select="'&#xA;&#x9;Vision:'"/>
        </xsl:call-template>
        <xsl:value-of select="/Character/Build/@vision"/>
    </xsl:template>
    <xsl:template match="Defense/Condition">
        <xsl:text>&#xA;&#x9;&#x9;</xsl:text>
        <xsl:value-of select="parent::node()/@abbreviation"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="@name"/>    
    </xsl:template>
    <xsl:template match="Defenses/Condition">
        <xsl:text>&#xA;&#x9;&#x9;</xsl:text>
        <xsl:text>All Defenses </xsl:text>
        <xsl:value-of select="@name"/>    
    </xsl:template>

    <!-- FEATURES SECTION -->
    <xsl:template match="Build">
        <xsl:text>&#xA;&#xA;[b]Race and Class Features[/b]</xsl:text>
        <xsl:apply-templates select="Race"/>
        <xsl:apply-templates select="Class"/>
        <xsl:apply-templates select="ParagonPath"/>
        <xsl:apply-templates select="EpicDestiny"/>
    </xsl:template>
    <xsl:template match="Race | Class | ParagonPath | EpicDestiny">
        <xsl:apply-templates select="Feature"/>
    </xsl:template>
    <xsl:template match="Feature">
        <xsl:text>&#xA;&#x9;</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text> [</xsl:text>
        <xsl:value-of select="parent::node()/@name"/>
        <xsl:text>]</xsl:text>
        <xsl:apply-templates select="@description"/>
    </xsl:template>
    <xsl:template match="@description">
        <xsl:text>&#xA;&#x9;    </xsl:text>
        <!-- On the SomethingAwful forums, the $opendetail value of "[sub][super][i]" makes for nice tiny text.
         $closedetail obviously closes those bbcode tags.  Change these xsl variables at the top of this file.-->
        <xsl:value-of select="$opendetail"/>
        <xsl:value-of select="."/>
        <xsl:value-of select="$closedetail"/>
    </xsl:template>

    <!-- FEATS SECTION -->
    <xsl:template match="Feats">
        <xsl:text>&#xA;&#xA;[b]Feats[/b]</xsl:text>
        <xsl:apply-templates select="Feat"/>
    </xsl:template>

    <xsl:template match="Feat">
        <xsl:text>&#xA;&#x9;</xsl:text>
        <xsl:value-of select="@name"/>
        <!-- using a template for description in case it is empty -->
        <xsl:apply-templates select="@description"/>
    </xsl:template>
    
    <!-- POWERS SECTION -->
    <xsl:template match="Powers">
        <xsl:text>&#xA;&#xA;[b]Powers[/b]</xsl:text>
        <xsl:text>&#xA;&#x9;[i]At-Will[/i]</xsl:text>
        <xsl:apply-templates select="Power[starts-with(@powerusage, 'At-Will')]"/>
        <xsl:text>&#xA;&#xA;&#x9;[i]Encounter[/i]</xsl:text>
        <xsl:apply-templates select="Power[starts-with(@powerusage, 'Encounter')]"/>
        <xsl:text>&#xA;&#xA;&#x9;[i]Daily[/i]</xsl:text>
        <xsl:apply-templates select="Power[starts-with(@powerusage, 'Daily')]"/>
    </xsl:template>
    
    <!-- D&D Insider URLs are available for just about everything.  In this sheet we only use them for Powers and Items. -->
    <xsl:template match="Power"> 
        <xsl:choose>
            <xsl:when test="contains(@name,'Basic')">
                
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>&#xA;&#x9;[url=</xsl:text>
                <xsl:value-of disable-output-escaping="yes" select="@url"/>
                <xsl:text>]</xsl:text>
                <xsl:value-of select="@name"/>
                <xsl:text>[/url]</xsl:text>
                <xsl:apply-templates select="@actiontype"/>
                <xsl:apply-templates select="./Condition"/>
                <xsl:apply-templates select="./Weapon"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="Power/@actiontype">
        <xsl:value-of select="$opendetail"/>
        <xsl:text> [</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>]</xsl:text>
        <xsl:value-of select="$closedetail"/>
    </xsl:template>
    
    <xsl:template match="Power/Weapon">
        <xsl:text>&#xA;&#x9;    </xsl:text>
        <xsl:value-of select="$opendetail"/>
        <xsl:value-of select="@name"/>

        <xsl:text> - Attack: </xsl:text>
        <xsl:value-of select="AttackBonus/@value"/>
        <xsl:text> vs. </xsl:text>
        <xsl:value-of select="@defense"/>
        <xsl:text>,  </xsl:text>
        
        <!--xsl:apply-templates select="AttackBonus/Factor"/-->
        
        <xsl:text>Damage: </xsl:text>
        <xsl:value-of select="Damage/@value"/>
        <xsl:apply-templates select="Damage/@type"/>
       
        <!--xsl:apply-templates select="Damage/Factor"/-->
        <xsl:value-of select="$closedetail"/>
    </xsl:template>
    <xsl:template match="@type">
        <xsl:text> (</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>)  </xsl:text>
    </xsl:template>

    <!-- SKILLS SECTION -->
    <xsl:template match="Skills">
        <xsl:text>&#xA;&#xA;[b]Skills[/b]</xsl:text>
        <xsl:apply-templates select="Skill"/>
    </xsl:template>
    <xsl:template match="Skill">
        <xsl:call-template name="label-value-pad">
            <xsl:with-param name="label" select="concat('&#xA;&#x9;',./@name,':')"/>
            <xsl:with-param name="labellength" select="17"/>
            <xsl:with-param name="value" select="./@value"/>
            <xsl:with-param name="valuelength" select="2"/>
        </xsl:call-template>
        <xsl:call-template name="FactorDetailLine">
            <xsl:with-param name="TheNode" select="."/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="PassiveSkill">
        <xsl:call-template name="label-value-pad">
            <xsl:with-param name="label" select="concat('&#xA;&#x9;Passive ',./@name,':')"/>
            <xsl:with-param name="labellength" select="23"/>
            <xsl:with-param name="value" select="./@value"/>
            <xsl:with-param name="valuelength" select="2"/>
        </xsl:call-template>
        <xsl:call-template name="FactorDetailLine">
            <xsl:with-param name="TheNode" select="."/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- PROFICIENCY SECTION -->
    <!-- There are a lot of different ways to show proficiencies.  
        This approach opts for summarized weapon groups but verbose armor groups. -->
    <xsl:template match="Proficiencies">
        <xsl:text>&#xA;&#xA;[b]Proficiencies[/b]</xsl:text>
        <xsl:text>&#xA;&#x9;[i]Weapons[/i]</xsl:text>
        <xsl:apply-templates select="WeaponProficiencies/ProficiencyGroup"/>
        <xsl:apply-templates select="WeaponProficiencies/Proficiency"/>
        <xsl:text>&#xA;&#xA;&#x9;[i]Armor[/i]</xsl:text>
        <xsl:apply-templates select="ArmorProficiencies/Proficiency"/>
        <xsl:apply-templates select="ShieldProficiencies/Proficiency"/>
    </xsl:template>
    <xsl:template match="ProficiencyGroup">
            <xsl:text>&#xA;&#x9;&#x9;</xsl:text>
            <xsl:value-of select="@name"/>
            <xsl:text> [</xsl:text>
            <xsl:value-of select="@source"/>
            <xsl:text>]</xsl:text>
    </xsl:template>
    <xsl:template match="Proficiency">
        <!--xsl:if test="parent::Proficiencies"-->
            <xsl:text>&#xA;&#x9;&#x9;</xsl:text>
            <xsl:value-of select="@name"/>
            <xsl:if test="parent::ShieldProficiencies">
                <xsl:text> Shield</xsl:text>
            </xsl:if>
            <xsl:text> [</xsl:text>
            <xsl:value-of select="@source"/>
            <xsl:text>]</xsl:text>
        <!--/xsl:if-->
    </xsl:template>
    
    <!-- ITEM SECTION -->
    <xsl:template match="Loot">
        <xsl:text>&#xA;&#xA;[b]Inventory[/b]</xsl:text>
        <xsl:text>&#xA;&#x9;[i]Weapons[/i]</xsl:text>
        <xsl:apply-templates select="Item[@type='Weapon']"/>
        <xsl:text>&#xA;&#xA;&#x9;[i]Armor[/i]</xsl:text>
        <xsl:apply-templates select="Item[@type='Armor']"/>
        <xsl:if test="Item[@type='Magic Item']">
            <xsl:text>&#xA;&#xA;&#x9;[i]Magic Items[/i]</xsl:text>
            <xsl:apply-templates select="Item[@type='Magic Item']"/>
        </xsl:if>
        <xsl:if test="Item[@type='Gear']">
            <xsl:text>&#xA;&#xA;&#x9;[i]Gear[/i]</xsl:text>
            <xsl:apply-templates select="Item[@type='Gear']"/>
        </xsl:if>
        <xsl:if test="Item[@type!='Armor' and @type!='Weapon'
            and @type!='Magic Item' and @type!='Ritual']">
            <h2>Other</h2>
            <ul>
                <xsl:apply-templates
                    select="Item[@type!='Armor' and @type!='Weapon' and @type!='Magic
                    Item' and @type!='Ritual']" mode="listitem" />
            </ul>
        </xsl:if>
        <xsl:text>&#xA;&#xA;&#x9;[i]Coin[/i]</xsl:text>
        <xsl:text>&#xA;&#x9;Carried: </xsl:text>
        <xsl:value-of select="@carriedmoney"/>
        <xsl:text>&#xA;&#x9;Stored: </xsl:text>
        <xsl:value-of select="@Storedmoney"/>
        <xsl:if test="Item[@type='Ritual']">
            <xsl:text>&#xA;&#xA;[b]Rituals[/b]</xsl:text>
            <xsl:apply-templates select="Item[@type='Ritual']"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="Item">
        <xsl:if test="@count > 0">
        <xsl:text>&#xA;&#x9;</xsl:text>
        <xsl:text>[url=</xsl:text>
        <xsl:value-of disable-output-escaping="yes" select="@url"/>
        <xsl:text>]</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>[/url]</xsl:text>
        <xsl:apply-templates select="./Enhancement"/>
            <xsl:if test="@count > 1">
                <xsl:text>(quantity: </xsl:text>
                <xsl:value-of select="@count"/>
                <xsl:text>)</xsl:text>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    <xsl:template match="Enhancement">
        <xsl:text>, </xsl:text>
        <xsl:text>[url=</xsl:text>
        <xsl:value-of disable-output-escaping="yes" select="@url"/>
        <xsl:text>]</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>[/url]</xsl:text>
    </xsl:template>
    
    
    <!-- DESCRIPTION DETAILS -->
    <xsl:template match="Appearance | Traits | Companions | Notes">
        <xsl:text>&#xA;[i]</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>[/i]&#xA;</xsl:text>
        <xsl:value-of select="self::node()"/>
        <xsl:text>&#xA;</xsl:text>
        
    </xsl:template>
    
    <!-- HELPER TEMPLATES -->
    <xsl:template name="WrappingFactorDetailLine">
        <xsl:param name="TheString"/>
        <xsl:param name="LeadingCharacters"/>
        <xsl:if test="string-length($TheString)"></xsl:if>
        <xsl:value-of select="$opendetail"/>
        <xsl:value-of select="$closedetail"/>
    </xsl:template>
    
    <xsl:template name="FactorDetailLine">
        <xsl:param name="TheNode" select="."/>
        <xsl:value-of select="$opendetail"/>
        <xsl:apply-templates select="$TheNode/Factor"/>
        <xsl:value-of select="$closedetail"/>
    </xsl:template>
    
    <xsl:template name="AbilityFactorDetailLine">
        <xsl:param name="TheNode" select="."/>
        <xsl:value-of select="$opendetail"/>
        <xsl:apply-templates select="$TheNode/Factor[not(contains(@name, 'Level '))]"/>
        <xsl:choose>
            <xsl:when test="$TheNode/Factor[contains(@name, 'Level ')]">
                <xsl:text>+</xsl:text>
                <xsl:value-of select="count($TheNode/Factor[contains(@name, 'Level ')])" />
                <xsl:text>(Level</xsl:text>
                <xsl:if test="count(Factor[contains(@name, 'Level ')]) > 1">
                    <xsl:text>s</xsl:text>
                </xsl:if> 
                <xsl:for-each select="$TheNode/Factor[contains(@name, 'Level ')]">
                    <xsl:value-of select="substring(@name, 6)" />
                    <xsl:if test="position()!=last()">,</xsl:if>
                </xsl:for-each>
                <xsl:text>)</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="$TheNode/Factor"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$closedetail"/>
    </xsl:template>
    <!-- This is the tiny text line which appears wherever a value has a factor.  
    In this sheet we use abbreviations wherever possible. -->
    
    <xsl:template match="Factor">
        <xsl:text></xsl:text>
        <xsl:value-of select="@modifier"/>
        <xsl:text>(</xsl:text>
        <xsl:choose>
            <xsl:when test="@abbreviation">
                <xsl:value-of select="@abbreviation"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="@name"/>
            </xsl:otherwise>
        </xsl:choose>        
        <xsl:text>)</xsl:text>
    </xsl:template>

    <xsl:template name="label-value-pad">
        <xsl:param name="label"/>
        <xsl:param name="labellength"/>
        <xsl:param name="value"/>
        <xsl:param name="valuelength"/>
        <xsl:call-template name="append-pad">
            <xsl:with-param name="length" select="$labellength"/>
            <xsl:with-param name="padVar" select="$label"/>
        </xsl:call-template>
        <xsl:call-template name="prepend-pad">
            <xsl:with-param name="length" select="$valuelength"/>
            <xsl:with-param name="padVar" select="$value"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="prepend-pad">
        <!-- recursive template to right justify and prepend-->
        <!-- the value with whatever padChar is passed in   -->
        <xsl:param name="padVar"/>
        <xsl:param name="length"/>
        <xsl:variable name="padChar">
            <xsl:text> </xsl:text>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="string-length($padVar) &lt; $length">
                <xsl:call-template name="prepend-pad">
                    <xsl:with-param name="padChar" select="$padChar"/>
                    <xsl:with-param name="padVar" select="concat($padChar,$padVar)"/>
                    <xsl:with-param name="length" select="$length"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="substring($padVar,string-length($padVar) - $length + 1)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="append-pad">
        <!-- recursive template to left justify and append  -->
        <!-- the value with whatever padChar is passed in   -->
        <xsl:param name="padVar"/>
        <xsl:param name="length"/>
        <xsl:variable name="padChar">
            <xsl:text> </xsl:text>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="string-length($padVar) &lt; $length">
                <xsl:call-template name="append-pad">
                    <xsl:with-param name="padChar" select="$padChar"/>
                    <xsl:with-param name="padVar" select="concat($padVar,$padChar)"/>
                    <xsl:with-param name="length" select="$length"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="substring($padVar,1,$length)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="@url">
        <xsl:value-of disable-output-escaping="yes" select="."/>
    </xsl:template>   
    
    <xsl:strip-space elements="*"/>
</xsl:stylesheet>
