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
    <!-- This stylesheet processes extent for dsc2 leaf containers. It includes a key-based test for partial containers. -->
    <xsl:function name="functx:substring-after-last-match" as="xs:string" xmlns:functx="http://www.functx.com">
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:param name="regex" as="xs:string"/>
        <xsl:sequence select="
                replace($arg, concat('^.*', $regex), '')
                "/>
    </xsl:function>
    <xsl:template match="@* | node() | comment() | processing-instruction()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node() | comment() | processing-instruction()"/>
        </xsl:copy>
    </xsl:template>
    <!-- RH: create value keys -->
    <xsl:variable name="root" select="/"/>
    <xsl:key name="ptr-target" match="ead:did/ead:container/ead:ptr | ead:did/ead:unitid/ead:ptr" use="@target"/>
    <xsl:key name="parent-target" match="ead:did/ead:container[@parent]" use="@parent"/>
    <xsl:key name="folder-index" match="//ead:did/ead:container[@parent]">
        <xsl:for-each select=".">
            <xsl:variable name="parent">
                <xsl:value-of select="current()/@parent"/>
            </xsl:variable>
            <xsl:variable name="type">
                <xsl:value-of select="current()/@type"/>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="count(tokenize(current()/text(), '-')) = 2">
                    <xsl:variable name="tokens" select="tokenize(current()/text(), '-')"/>
                    <xsl:if test="$tokens[1] castable as xs:integer and $tokens[2] castable as xs:integer">
                        <xsl:for-each select="xs:integer($tokens[1]) to xs:integer($tokens[2])">
                            <item>
                                <xsl:value-of select="concat($parent, $type, .)"/>
                            </item>
                        </xsl:for-each>
                    </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                    <item>
                        <xsl:value-of select="concat($parent, $type, ./text())"/>
                    </item>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:key>
    <xsl:template match="ead:c[ancestor::ead:dsc[@type = 'combined'] and not(ead:c//ead:container)]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <did>
                <xsl:apply-templates select="ead:did/*[not(self::ead:physdesc)]"/>
                <physdesc>
                    <xsl:apply-templates select="ead:did/ead:physdesc/*[not(self::ead:extent[not(@type = 'computed')])]"/>
                    <xsl:if test="ead:did[ead:container[ead:ptr or @parent] or ead:unitid[@type = 'itemnumber' and ead:ptr]]">
                        <xsl:call-template name="do-extent"/>
                    </xsl:if>
                </physdesc>
            </did>
            <xsl:apply-templates select="current()/*[not(self::ead:did)]"/>
        </xsl:copy>
    </xsl:template>
    <!-- RH: New template to address dsc[2] scenarios -->
    <xsl:template name="do-extent">
        <!-- This bit addresses containers with child ptr -->
        <!-- displays as "1 unitid"-alternatives? -->
        <xsl:choose>
            <xsl:when test="(ead:did/ead:container/ead:ptr or ead:did/ead:unitid/ead:ptr)">
                <xsl:for-each-group select="(ead:did/ead:container/ead:ptr | ead:did/ead:unitid/ead:ptr)"
                    group-by="//ead:c[@id = current()/@target]/ead:did/ead:container/@type">
                    <extent type="computed">
                        <xsl:choose>
                            <xsl:when test="current-grouping-key() = 'unitid'">
                                <xsl:attribute name="unit">item</xsl:attribute>
                                <xsl:value-of select="count(current-group()), ' item'"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="unit">
                                    <xsl:value-of select="current-grouping-key()"/>
                                </xsl:attribute>
                                <xsl:value-of select="count(current-group()), current-grouping-key()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:if test="count(current-group()) > 1">
                            <xsl:if test="current-grouping-key() = 'box'">
                                <xsl:text>e</xsl:text>
                            </xsl:if>
                            <xsl:text>s</xsl:text>
                        </xsl:if>
                        <!-- Check for duplicate ptr values -->
                        <xsl:if test="count(key('ptr-target', current()/@target)) + count(key('parent-target', current()/@target)) > 1">
                            <xsl:text> (</xsl:text>
                            <xsl:if test="count(current-group()) > 1">
                                <xsl:value-of
                                    select="count(current-group()/@target[key('ptr-target', .)]) + count(current-group()/@target[key('parent-target', .)])"/>
                                <xsl:text> </xsl:text>
                            </xsl:if>
                            <xsl:text>partial)</xsl:text>
                        </xsl:if>
                    </extent>
                    <componentindex>
                        <xsl:for-each select="current-group()">
                            <item>
                                <xsl:attribute name="selftype">
                                    <xsl:value-of select="//ead:c[@id = current()/@target]/ead:did/ead:container/@type"/>
                                </xsl:attribute>
                                <xsl:value-of select="@target"/>
                                <!--, ' ', //ead:c[@id = current()/@target]/ead:did/ead:container/text()-->
                            </item>
                        </xsl:for-each>
                    </componentindex>
                </xsl:for-each-group>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="ead:did/ead:physdesc/ead:extent"/>
            </xsl:otherwise>
        </xsl:choose>
        <!-- This bit addresses containers with @parent, i.e. subcontainers -->
        <xsl:if test="ead:did/ead:container[@parent]">
            <xsl:for-each-group select="ead:did/ead:container[@parent]" group-by="@type">
                <xsl:variable name="ranges">
                    <xsl:for-each select="current-group()[contains(., '-')]">
                        <!-- NB: this will ignore alphanumeric ranges -->
                        <xsl:if test="tokenize(current(), '-')[1] castable as xs:integer and tokenize(current(), '-')[2] castable as xs:integer">
                            <range>
                                <xsl:value-of select="sum(xs:integer(tokenize(current(), '-')[2]) - xs:integer(tokenize(current(), '-')[1]) + 1)"/>
                            </range>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="single">
                    <xsl:value-of select="count(current-group()[not(contains(string(.), '-'))])"/>
                </xsl:variable>
                <xsl:variable name="singular">
                    <xsl:value-of select="$single + sum($ranges/*)"/>
                </xsl:variable>
                <!-- Check for duplicate use of subcontainers -->
                <xsl:variable name="valuepairs">
                    <xsl:for-each select="current-group()">
                        <xsl:variable name="type">
                            <xsl:value-of select="@type"/>
                        </xsl:variable>
                        <xsl:variable name="parent">
                            <xsl:value-of select="@parent"/>
                        </xsl:variable>
                        <xsl:variable name="component-index">
                            <xsl:choose>
                                <!-- build range -->
                                <xsl:when test="count(tokenize(current(), '-')) = 2">
                                    <xsl:variable name="tokens" select="tokenize(current(), '-')"/>
                                    <xsl:choose>
                                        <xsl:when test="$tokens[1] castable as xs:integer and $tokens[2] castable as xs:integer">
                                            <xsl:for-each select="xs:integer($tokens[1]) to xs:integer($tokens[2])">
                                                <item>
                                                    <xsl:value-of select="concat($parent, $type, current())"/>
                                                </item>
                                            </xsl:for-each>
                                        </xsl:when>
                                        <!-- include noncountables in component index to test against -->
                                        <xsl:otherwise>
                                            <xsl:for-each select="$tokens">
                                                <item>
                                                    <xsl:value-of select="concat($parent, $type, current())"/>
                                                </item>
                                            </xsl:for-each>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <!-- include singles in component index -->
                                <xsl:otherwise>
                                    <item>
                                        <xsl:value-of select="concat($parent, $type, current())"/>
                                    </item>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:if test="count($component-index/*[count(key('folder-index', ., $root)) > 1])[. > 0]">
                            <p type="countable">
                                <xsl:value-of select="count($component-index/*[count(key('folder-index', ., $root)) > 1])[. > 0]"/>
                            </p>
                        </xsl:if>
                        <xsl:if test="$component-index/*[not(key('folder-index', ., $root))]">
                            <p type="noncountable">
                                <xsl:value-of select="current-grouping-key(), current()"/>
                            </p>
                        </xsl:if>
                        <xsl:for-each select="$component-index/*[not(key('folder-index', ., $root))]">
                            <item type="alphanum">
                                <xsl:attribute name="selftype">
                                    <xsl:value-of select="current-grouping-key()"/>
                                </xsl:attribute>
                                <!-- This does something wonky to !9A-C in C0138, but I'm treating that as a data issue -->
                                <xsl:attribute name="number">
                                    <xsl:value-of select="replace(., '(^[\D\S]+?_i\d+[\D\S]+?)(\d+)(\D)', '$2')"/>
                                </xsl:attribute>
                                <xsl:value-of select="."/>
                            </item>
                        </xsl:for-each>
                        <xsl:for-each select="$component-index/*[key('folder-index', ., $root)]">
                            <item>
                                <xsl:attribute name="selftype">
                                    <xsl:value-of select="current-grouping-key()"/>
                                </xsl:attribute>
                                <xsl:value-of select="."/>
                            </item>
                        </xsl:for-each>
                    </xsl:for-each>
                </xsl:variable>
                <extent type="computed">
                    <xsl:attribute name="unit">
                        <xsl:value-of select="current-grouping-key()"/>
                    </xsl:attribute>
                    <xsl:if test="$singular > 0">
                        <xsl:if test="$valuepairs/*[@type = 'noncountable']">
                            <xsl:text>at least </xsl:text>
                        </xsl:if>
                        <xsl:value-of select="$singular, current-grouping-key()"/>
                    </xsl:if>
                    <xsl:if test="$singular > 1">
                        <xsl:text>s</xsl:text>
                    </xsl:if>
                    <xsl:if test="sum($valuepairs/*[@type = 'countable']) > 0">
                        <xsl:text> (</xsl:text>
                        <xsl:if test="$singular > 1">
                            <xsl:value-of select="sum($valuepairs/*[@type = 'countable'])[. != 0]"/>
                            <xsl:text> </xsl:text>
                        </xsl:if>
                        <xsl:text>partial)</xsl:text>
                    </xsl:if>
                    <xsl:if test="$valuepairs/*[@type = 'noncountable']">
                        <xsl:if test="$singular > 0">
                            <xsl:text> and </xsl:text>
                        </xsl:if>
                        <xsl:text>at least </xsl:text>
                        <xsl:variable name="range">
                            <xsl:value-of select="substring-after($valuepairs/*[@type = 'noncountable'], ' ')"/>
                        </xsl:variable>
                        <xsl:variable name="type">
                            <xsl:value-of select="substring-before($valuepairs/*[@type = 'noncountable'], ' ')"/>
                        </xsl:variable>
                        <!-- for some reason tokenize doesn't take here -->
                        <xsl:variable name="token1" select="replace(substring-before($range, '-'), '\D', '')"/>
                        <xsl:variable name="token2" select="replace(substring-after($range, '-'), '\D', '')"/>
                        <xsl:choose>
                            <xsl:when test="number($token1) and number($token2) and $token1 != $token2">
                                <xsl:value-of select="xs:integer($token2) - xs:integer($token1) + 1"/>
                            </xsl:when>
                            <!-- I'm not sure this flies in all cases. It does apply to 19A-C. -->
                            <xsl:otherwise>
                                <xsl:value-of select="number(2)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:value-of select="' ', $type"/>
                        <xsl:text>s</xsl:text>
                    </xsl:if>
                </extent>
                <componentindex>
                    <xsl:copy-of select="$valuepairs/*[not(self::ead:p)]"/>
                </componentindex>
            </xsl:for-each-group>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
