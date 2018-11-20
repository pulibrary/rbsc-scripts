<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="urn:isbn:1-931666-22-9" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ead="urn:isbn:1-931666-22-9" xmlns:functx="http://www.functx.com" version="2.0" exclude-result-prefixes="#all">
    <!-- 
Copyright 2013 The Trustees of Princeton University
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
  http://www.apache.org/licenses/LICENSE-2.0
  
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-->
    <!-- This stylesheet performs a whole-container check per grouping/series and computes extent up -->
    <xsl:function name="functx:substring-after-last-match" as="xs:string" xmlns:functx="http://www.functx.com">
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:param name="regex" as="xs:string"/>
        <xsl:sequence select="
                replace($arg, concat('^.*', $regex), '')
                "/>
    </xsl:function>
    <xsl:function name="functx:substring-before-last-match" as="xs:string?" xmlns:functx="http://www.functx.com">
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:param name="regex" as="xs:string"/>
        <xsl:sequence select="
                replace($arg, concat('^(.*)', $regex, '.*'), '$1')
                "/>
    </xsl:function>
    <xsl:function name="functx:distinct-deep" as="node()*" xmlns:functx="http://www.functx.com">
        <xsl:param name="nodes" as="node()*"/>
        <xsl:sequence
            select="
                for $seq in (1 to count($nodes))
                return
                    $nodes[$seq][not(functx:is-node-in-sequence-deep-equal(
                    ., $nodes[position() &lt; $seq]))]
                "
        />
    </xsl:function>
    <xsl:function name="functx:is-node-in-sequence-deep-equal" as="xs:boolean" xmlns:functx="http://www.functx.com">
        <xsl:param name="node" as="node()?"/>
        <xsl:param name="seq" as="node()*"/>
        <xsl:sequence select="
                some $nodeInSeq in $seq
                    satisfies deep-equal($nodeInSeq, $node)
                "/>
    </xsl:function>
    <xsl:template match="@* | node() | comment() | processing-instruction()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node() | comment() | processing-instruction()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:variable name="root" select="/"/>
    <xsl:template match="ead:c[ancestor::ead:dsc[@type = 'combined']] | ead:archdesc">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:choose>
                <xsl:when test="ead:c | self::ead:archdesc">
                    <did>
                        <xsl:apply-templates select="ead:did/*[not(self::ead:physdesc)]"/>
                        <physdesc>
                            <xsl:apply-templates select="ead:did/ead:physdesc/*[not(self::ead:extent[@type = 'computed'])]"/>
                            <xsl:if test="ead:did[not(ead:container[ead:ptr or @parent] or ead:unitid[@type = 'itemnumber' and ead:ptr])]">
                                <xsl:call-template name="do-extent"/>
                            </xsl:if>
                        </physdesc>
                    </did>
                    <xsl:apply-templates select="current()/*[not(self::ead:did)]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="child::node()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:copy>
    </xsl:template>
    <xsl:template name="do-extent">
        <xsl:variable name="lookaround">
            <xsl:for-each
                select="
                    if (ancestor::ead:c)
                    then
                        (current()/preceding-sibling::ead:c/descendant::ead:componentindex
                        | current()/following-sibling::ead:c/descendant::ead:componentindex
                        | current()/ancestor::ead:c/following-sibling::ead:c/ead:did/ead:physdesc/ead:componentindex
                        | current()/ancestor::ead:c/preceding-sibling::ead:c/ead:did/ead:physdesc/ead:componentindex)
                    else
                        (current()/preceding-sibling::ead:c/descendant::ead:componentindex
                        | current()/following-sibling::ead:c/descendant::ead:componentindex)">
                <xsl:for-each select="ead:item">
                    <xsl:choose>
                        <xsl:when test="@selftype = 'itemnumber'">
                            <xsl:copy>
                                <xsl:copy-of select="@*[not(. = 'itemnumber')]"/>
                                <xsl:attribute name="selftype" select="'item'"/>
                                <xsl:value-of select="."/>
                            </xsl:copy>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="sequence">
            <xsl:for-each select="$lookaround/*[not(. = '')]">
                <!-- invert @type count in prep for wholeness check -->
                <xsl:choose>
                    <xsl:when test="count(tokenize(normalize-space(current()), '\s')) = 2">
                        <xsl:copy-of select="."/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!--<test><xsl:value-of select="count(tokenize(normalize-space(current()), '\s'))"/></test>-->
                        <xsl:choose>
                            <xsl:when test="count(tokenize(normalize-space(current()), '\s')) = 4">
                                <xsl:choose>
                                    <xsl:when test="matches(current(), '^(item|case|mapcase|cabinet)')">
                                        <xsl:copy-of select="."/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy>
                                            <xsl:copy-of select="@*"/>
                                            <xsl:attribute name="selftype">
                                                <xsl:value-of select="substring-before(current(), ' ')"/>
                                            </xsl:attribute>
                                            <xsl:value-of
                                                select="substring-before(current(), ' '), ' ', substring-before(substring-after(current(), ' '), ' ')"/>
                                            <!--<xsl:text>this used to be </xsl:text> <xsl:copy-of select="."></xsl:copy-of>-->
                                        </xsl:copy>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="matches(current(), '_i')">
                                        <xsl:for-each-group select="current()" group-by="replace(., '([\D\S]+?_i\d{1,})(\D[\D\S]+)', '$1')">
                                            <!-- is whole container -->
                                            <item>
                                                <xsl:attribute name="selftype">
                                                    <xsl:value-of select="$root//ead:c[@id = current-grouping-key()]/ead:did/ead:container/@type"/>
                                                </xsl:attribute>
                                                <xsl:value-of select="current-grouping-key()"/>
                                            </item>
                                        </xsl:for-each-group>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:copy-of select="current()"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="sequence-deduped">
            <xsl:for-each-group select="$sequence/*" group-by="normalize-space(text())">
                <xsl:copy-of select="current()"> </xsl:copy-of>
            </xsl:for-each-group>
        </xsl:variable>
        <!-- test lookaround -->
<!--        <lookaround>
            <xsl:copy-of select="$sequence-deduped"/>
        </lookaround>-->
        <xsl:variable name="componentindex">
            <new-index>
                <!-- this variable contains containers determined to be whole (i.e. not found while looking around) -->
                <xsl:variable name="whole">
                    <xsl:copy-of
                        select="
                            for $c in ead:did//ead:checkifwhole/*
                            return
                                if (for $l in $sequence-deduped/*
                                return
                                    $l[matches(normalize-space(.), normalize-space(concat('^', $c, '\D'))) or ((normalize-space(.) = normalize-space($c)))]
                                )
                                then
                                    ()
                                else
                                    $c
                            "
                    />
                </xsl:variable><!--
                <xsl:value-of select="$whole"/>-->
                <!-- any subcontainer starting with the string identifying a whole box gets skipped and the whole box put in instead -->
                <xsl:perform-sort>
                    <xsl:sort select="@selftype"/>
                    <xsl:sort select="@type"/>
                    <xsl:sort select="@number" order="ascending"/>
                    <xsl:copy-of
                        select="
                            for $w in $whole/*
                            return
                                if (for $i in ead:did//ead:componentindex/ead:item
                                return
                                    $i[matches(normalize-space(.), normalize-space(concat('^', $w, '\D|$')))]
                                )
                                then
                                    $w
                                else
                                    ()"/>
                    <!-- any subcontainer not starting with the string identifying a whole box gets put in separately -->
                    <xsl:copy-of
                        select="
                            for $i in ead:did//ead:componentindex/ead:item[not(matches(normalize-space(.), '^[\D\S]+_i\d{1,}$') or matches(normalize-space(.), '^\p{L}+?\s\d{1,}$'))]
                            return
                                if (for $w in $whole/*
                                return
                                    $i[matches(normalize-space(.), normalize-space(concat('^', $w, '\D')))]
                                )
                                then
                                    if ($i/@selftype[. = 'reel'])
                                    then
                                        $i
                                    else
                                        ()
                                else
                                    $i
                            "
                    /> "/> <xsl:for-each
                        select="
                            for $i in ead:did//ead:componentindex/ead:item[not(@selftype = 'reel') and (matches(normalize-space(.), '^[\D\S]+_i\d{1,}$') or matches(normalize-space(.), '^\p{L}+?\s\d{1,}$'))]
                            return
                                if (for $w in $whole/*
                                return
                                    $i[normalize-space(.) = normalize-space($w)]
                                )
                                then
                                    ()
                                else
                                    $i
                            ">
                        <xsl:copy>
                            <xsl:attribute name="partial">yes</xsl:attribute>
                            <xsl:copy-of select="@*"/>
                            <xsl:value-of select="."/>
                        </xsl:copy>
                    </xsl:for-each>
                </xsl:perform-sort>
            </new-index>
        </xsl:variable>
        <!-- test $componentindex --><!--
        <xsl:copy-of select="$componentindex"/>-->
        <!--

            ********************************************
            begin processing extent
            ********************************************
        -->
        <xsl:for-each select="$componentindex/*">
            <xsl:for-each-group select="*[not(. = '')]" group-by="@selftype">
                <xsl:sort select="@selftype"/>
                <extent type="computed">
                    <xsl:attribute name="unit">
                        <xsl:value-of select="current-grouping-key()"/>
                    </xsl:attribute>
                    <!-- compute alphanums -->
                    <xsl:if test="current-group()/@type">
                        <xsl:text>at least </xsl:text>
                    </xsl:if>
                    <xsl:variable name="alphanums">
                        <xsl:for-each select="current-group()[@number]">
                            <xsl:if test="position() mod 2 = 0">
                                <xsl:value-of select="current()/@number - preceding-sibling::*[1]/@number + 1"/>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:variable name="count">
                        <xsl:value-of
                            select="
                                if ($alphanums[not(. = '')]) then
                                    count(current-group()[not(@number)]) + $alphanums
                                else
                                    count(current-group())"
                        />
                    </xsl:variable>
                    <xsl:value-of select="$count, ' ', current-grouping-key()"/>
                    <xsl:if test="$count > 1">
                        <xsl:if test="current-grouping-key() = 'box'">
                            <xsl:text>e</xsl:text>
                        </xsl:if>
                        <xsl:text>s</xsl:text>
                    </xsl:if>
                    <xsl:if test="current-group()/@partial">
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="count(current-group()/@partial)"/>
                        <xsl:text> partial)</xsl:text>
                    </xsl:if>
                </extent>
            </xsl:for-each-group>
        </xsl:for-each>
    </xsl:template>
        <xsl:template match="ead:componentindex"/>
</xsl:stylesheet>
