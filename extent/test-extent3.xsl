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
    <!-- This stylesheet combines the two component indeces in one. It prepares index items for the wholeness test in step 4 by assigning the leading container, not the trailing container, as the container type. -->
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
    <xsl:variable name="root" select="/"/>
    <xsl:template match="@* | node() | comment() | processing-instruction()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node() | comment() | processing-instruction()"/>
        </xsl:copy>
    </xsl:template>
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
        <xsl:variable name="component-index">
            <xsl:for-each select="functx:distinct-deep(descendant::ead:componentindex/*)">
                <xsl:choose>
                    <xsl:when test="@selftype = 'itemnumber'">
                        <xsl:copy>
                            <xsl:copy-of select="@*[not(. = 'itemnumber')]"/>
                            <xsl:attribute name="selftype" select="'item'"/>
                            <xsl:value-of select="current()/text()"/>
                        </xsl:copy>
                    </xsl:when>
                    <xsl:when test="@selftype = 'unitid'">
                        <xsl:copy>
                            <xsl:copy-of select="@*[not(. = 'unitid')]"/>
                            <xsl:attribute name="selftype" select="'item'"/>
                            <xsl:value-of select="current()/text()"/>
                        </xsl:copy>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="current()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <!-- leave for testing purposes -->
        <componentindex>
            <xsl:for-each-group select="$component-index/*" group-by="normalize-space(text())">
                <xsl:copy-of select="current-group()"> </xsl:copy-of>
            </xsl:for-each-group>

            <xsl:variable name="checkifwhole">
                <xsl:for-each select="$component-index/*[not(. = '') and not(@selftype = 'reel')]">
                    <!-- invert @type count in prep for wholeness check -->
                    <xsl:choose>
                        <xsl:when test="@selftype = 'itemnumber'">
                            <xsl:copy>
                                <xsl:copy-of select="@*[not(. = 'itemnumber')]"/>
                                <xsl:attribute name="selftype" select="'item'"/>
                                <xsl:value-of select="."/>
                            </xsl:copy>
                        </xsl:when>
                        <xsl:otherwise>
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
                                                    <!-- to-do: this logic may need tweaking -->
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
                                                    <xsl:for-each-group select="current()" group-by="replace(., '([\D\S]+?_i\d{1,})([\D\S]+)?', '$1')">
                                                        <!-- is whole container -->
                                                        <item>
                                                            <xsl:attribute name="selftype">
                                                                <xsl:choose>
                                                                    <xsl:when
                                                                        test="$root//ead:c[@id = current-grouping-key()]/ead:did/ead:container/@type = 'unitid'">
                                                                        <xsl:value-of select="'item'"/>
                                                                    </xsl:when>
                                                                    <xsl:otherwise>
                                                                        <xsl:value-of
                                                                           select="$root//ead:c[@id = current-grouping-key()]/ead:did/ead:container/@type"
                                                                        />
                                                                    </xsl:otherwise>
                                                                </xsl:choose>
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
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:variable>
            <checkifwhole>
                <xsl:for-each-group select="$checkifwhole/*" group-by="normalize-space(text())">
                    <xsl:copy-of select="current()"> </xsl:copy-of>
                </xsl:for-each-group>
            </checkifwhole>
        </componentindex>
    </xsl:template>
    <!--    <xsl:template match="ead:componentindex"/>-->
</xsl:stylesheet>
