<xsl:stylesheet xmlns="urn:isbn:1-931666-22-9" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ead="urn:isbn:1-931666-22-9"
    xmlns:functx="http://www.functx.com" version="2.0" exclude-result-prefixes="#all">
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
    <!-- This stylesheet processes extent for classic leaf containers. It includes a key-based test for partial containers. -->
    <xsl:function name="functx:substring-after-last-match" as="xs:string"
        xmlns:functx="http://www.functx.com">
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:param name="regex" as="xs:string"/>
        <xsl:sequence
            select="
                replace($arg, concat('^.*', $regex), '')
                "/>
    </xsl:function>
    <xsl:function name="functx:substring-before-last-match" as="xs:string?"
        xmlns:functx="http://www.functx.com">
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:param name="regex" as="xs:string"/>
        <xsl:sequence
            select="
                replace($arg, concat('^(.*)', $regex, '.*'), '$1')
                "
        />
    </xsl:function>
    <xsl:template match="@* | node() | comment() | processing-instruction()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node() | comment() | processing-instruction()"/>
        </xsl:copy>
    </xsl:template>
    <!-- create value keys -->
    <xsl:variable name="root" select="/"/>
    <xsl:key name="collection-index"
        match="ead:did/ead:container[not(ead:ptr or @parent)] | ead:did/ead:unitid[@type = 'itemnumber' and not(ead:ptr)]">
        <!-- define container types based on whether or not they always, never, or sometimes contain other containers -->
        <xsl:variable name="subcontainer">
            <xsl:value-of
                select="./self::ead:container[matches(@type, 'division|file|issue|leaf|packet', 'i')]/@type"
            />
        </xsl:variable>
        <xsl:variable name="supercontainer">
            <xsl:value-of
                select="./self::ead:container[matches(@type, 'cabinet|case|mapcase', 'i')]/@type"/>
        </xsl:variable>
        <xsl:variable name="item">
            <xsl:value-of
                select="./self::ead:container[matches(@type, 'item|album|tube|scrapbook|reel|tape|portfolio|cassette|oversize|notebook|letterbook|dvd|cd|binder', 'i')]/@type"
            />
        </xsl:variable>
        <xsl:variable name="othercontainer">
            <xsl:variable name="types">
                <xsl:value-of select="distinct-values($subcontainer | $supercontainer)"/>
                <!-- $item |  -->
            </xsl:variable>
            <xsl:value-of select="./self::ead:container[not(matches(@type, $types, 'i'))]/@type"/>
        </xsl:variable>
        <!-- one containertype, no unitid -->
        <xsl:if
            test="count(distinct-values(../ead:container/@type)) = 1 and not(../ead:unitid[@type = 'itemnumber'])">
            <xsl:for-each
                select="./self::ead:container[not(@type = 'item')]/@type[count(distinct-values(.)) = 1]">
                <xsl:variable name="selftype" select="."/>
                <xsl:choose>
                    <xsl:when test="count(tokenize(../text(), '-')) = 2">
                        <xsl:variable name="tokens" select="tokenize(../text(), '-')"/>
                        <xsl:choose>
                            <xsl:when
                                test="$tokens[1] castable as xs:integer and $tokens[2] castable as xs:integer">
                                <xsl:for-each
                                    select="xs:integer($tokens[1]) to xs:integer($tokens[2])">
                                    <xsl:variable name="selftext" select="current()"/>
                                    <item>
                                        <xsl:attribute name="selftype">
                                            <xsl:value-of select="$selftype"/>
                                        </xsl:attribute>
                                        <xsl:value-of select="$selftype, $selftext"/>
                                    </item>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:for-each select="$tokens">
                                    <item>
                                        <xsl:attribute name="selftype">
                                            <xsl:value-of select="$selftype"/>
                                        </xsl:attribute>
                                        <xsl:value-of select="$selftype, current()"/>
                                    </item>
                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <item>
                            <xsl:attribute name="selftype">
                                <xsl:value-of select="$selftype"/>
                            </xsl:attribute>
                            <xsl:value-of select="., ../text()"/>
                        </item>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:if>
        <!--one unitid type, no container-->
        <xsl:if
            test="count(distinct-values(../ead:unitid[@type = 'itemnumber']/@type)) = 1 and not(../ead:container)">
            <xsl:for-each
                select="./self::ead:unitid[@type = 'itemnumber']/@type[count(distinct-values(.)) = 1]">
                <xsl:variable name="selftype" select="."/>
                <xsl:choose>
                    <xsl:when test="count(tokenize(../text(), '-')) = 2">
                        <xsl:variable name="tokens" select="tokenize(../text(), '-')"/>
                        <xsl:choose>
                            <xsl:when
                                test="$tokens[1] castable as xs:integer and $tokens[2] castable as xs:integer">
                                <xsl:for-each
                                    select="xs:integer($tokens[1]) to xs:integer($tokens[2])">
                                    <xsl:variable name="selftext" select="current()"/>
                                    <item>
                                        <xsl:attribute name="selftype">
                                            <xsl:value-of select="$selftype"/>
                                        </xsl:attribute>
                                        <xsl:value-of select="$selftype, $selftext"/>
                                    </item>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:for-each select="$tokens">
                                    <item>
                                        <xsl:attribute name="selftype">
                                            <xsl:value-of select="$selftype"/>
                                        </xsl:attribute>
                                        <xsl:value-of select="$selftype, current()"/>
                                    </item>
                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <item>
                            <xsl:attribute name="selftype">
                                <xsl:value-of select="$selftype"/>
                            </xsl:attribute>
                            <xsl:value-of select="., ../text()"/>
                        </item>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:if>
        <!-- multiple container types, no unitid -->
        <xsl:if
            test="count(distinct-values(../ead:container/@type)) > 1 and not(../ead:unitid[not(ead:ptr) and @type = 'itemnumber'])">
            <!-- matching container is item or is neither exclusive sub-, nor supercontainer, 
                    and has preceding sibling of different type: ignore containing containers, 
                    or has no preceding sibling and is of same type: use self-->
            <xsl:for-each
                select="
                    ./self::ead:container[(
                    matches(@type, $item) or matches(@type, $othercontainer))
                    and
                    (
                    (preceding-sibling::ead:container
                    and (@type != preceding-sibling::ead:container/@type))
                    or
                    (not(preceding-sibling::ead:container)
                    and @type = following-sibling::ead:container/@type)
                    )
                    ]">
                <xsl:variable name="selftype" select="@type"/>
                <xsl:variable name="selftext" select="text()"/>
                <xsl:variable name="precedingtype"
                    select="preceding-sibling::ead:container[not((@type = following-sibling::ead:container[1]/@type))][1]/@type"/>
                <xsl:variable name="precedingtext"
                    select="preceding-sibling::ead:container[not((@type = following-sibling::ead:container[1]/@type))][1]/text()"> </xsl:variable>
                <xsl:choose>
                    <xsl:when test="count(tokenize(current(), '-|\sto\s')) = 2">
                        <xsl:variable name="tokens" select="tokenize(current(), '-|\sto\s')"/>
                        <xsl:choose>
                            <xsl:when
                                test="$tokens[1] castable as xs:integer and $tokens[2] castable as xs:integer">
                                <xsl:for-each
                                    select="xs:integer($tokens[1]) to xs:integer($tokens[2])">
                                    <xsl:value-of
                                        select="
                                            if ($precedingtype = 'folder'
                                            or
                                            $precedingtype = ($subcontainer | $item))
                                            then
                                                ()
                                            else
                                                $precedingtype, $precedingtext, $selftype, current()"
                                    />
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:for-each select="$tokens">
                                    <xsl:value-of
                                        select="
                                            if ($precedingtype = 'folder'
                                            or
                                            $precedingtype = ($subcontainer | $item))
                                            then
                                                ()
                                            else
                                                $precedingtype, $precedingtext, $selftype, current()"
                                    />
                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="current()">
                            <xsl:value-of
                                select="
                                    if ($precedingtype = 'folder'
                                    or
                                    $precedingtype = ($subcontainer | $item)
                                    )
                                    then
                                        if (current()/following-sibling::ead:container[1]/@type = 'folder')
                                        then
                                            ()
                                        else
                                            ($selftype, $selftext)
                                    else
                                        (
                                        $precedingtype, $precedingtext, $selftype, $selftext)"
                            />
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="$precedingtype, $precedingtext"/>
            </xsl:for-each>
        </xsl:if>
        <!-- one container type combined with unitid -->
        <xsl:if
            test="count(distinct-values(../ead:container/@type)) >= 1 and ../ead:unitid[not(ead:ptr) and @type = 'itemnumber']">
            <!-- matching container is item or is neither exclusive sub-, nor supercontainer, and has preceding sibling of different type: ignore containing containers or has no preceding sibling and is of same type: use self-->
            <xsl:for-each
                select="
                    ./self::ead:container[(
                    matches(@type, $item) or matches(@type, $othercontainer))
                    and
                    (preceding-sibling::ead:unitid[not(ead:ptr) and @type = 'itemnumber'])
                    ]">
                <xsl:variable name="selftype" select="@type"/>
                <xsl:variable name="precedingtype" select="preceding-sibling::ead:unitid[1]/@type"/>
                <xsl:variable name="precedingtext" select="preceding-sibling::ead:unitid[1]/text()"/>
                <xsl:choose>
                    <xsl:when test="count(tokenize(current(), '-|\sto\s')) = 2">
                        <xsl:variable name="tokens" select="tokenize(current(), '-|\sto\s')"/>
                        <xsl:choose>
                            <xsl:when
                                test="$tokens[1] castable as xs:integer and $tokens[2] castable as xs:integer">
                                <xsl:for-each
                                    select="xs:integer($tokens[1]) to xs:integer($tokens[2])">
                                    <xsl:variable name="selftext" select="current()"/>
                                    <xsl:value-of
                                        select="$precedingtype, $precedingtext, $selftype, $selftext"
                                    />
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:for-each select="$tokens">
                                    <xsl:value-of
                                        select="$precedingtype, $precedingtext, $selftype, current()"
                                    />
                                </xsl:for-each>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="preceding-sibling::ead:unitid[not(ead:ptr) and @type = 'itemnumber']/(@type, text()), @type, text()"
                        />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:if>
    </xsl:key>
    <xsl:template match="ead:c[ancestor::ead:dsc[@type = 'combined'] and not(ead:c//ead:container)]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <did>
                <xsl:apply-templates select="ead:did/*[not(self::ead:physdesc)]"/>
                <physdesc>
                    <xsl:apply-templates
                        select="ead:did/ead:physdesc/*[not(self::ead:extent[@type = 'computed'])]"/>
                    <xsl:if
                        test="ead:did[not(ead:container[ead:ptr or @parent] or ead:unitid[@type = 'itemnumber' and ead:ptr])]">
                        <xsl:call-template name="do-extent"/>
                    </xsl:if>
                </physdesc>
            </did>
            <xsl:apply-templates select="current()/*[not(self::ead:did)]"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template name="do-extent">
        <xsl:variable name="component-index">
            <!-- define container types based on whether or not they always, never, or sometimes contain other containers -->
            <xsl:variable name="subcontainer">
                <xsl:value-of
                    select="ead:did/ead:container[not(ead:ptr or @parent)][matches(@type, 'division|file|issue|leaf|packet', 'i')]/@type"
                />
            </xsl:variable>
            <xsl:variable name="supercontainer">
                <xsl:value-of
                    select="ead:did/ead:container[not(ead:ptr or @parent)][matches(@type, 'cabinet|case|mapcase', 'i')]/@type"
                />
            </xsl:variable>
            <xsl:variable name="item">
                <xsl:value-of
                    select="ead:did/ead:container[not(ead:ptr or @parent)][matches(@type, 'item|album|tube|scrapbook|reel|tape|portfolio|cassette|oversize|notebook|letterbook|dvd|cd|binder|scroll', 'i')]/@type"
                />
            </xsl:variable>
            <xsl:variable name="othercontainer">
                <xsl:variable name="types">
                    <xsl:value-of select="distinct-values($subcontainer | $supercontainer)"/>
                    <!-- $item |  -->
                </xsl:variable>
                <xsl:value-of
                    select="ead:did/ead:container[not(ead:ptr or @parent)][not(matches(@type, $types, 'i'))]/@type"
                />
            </xsl:variable>
            <!-- 
                *****************************************************************************
                start computing component index for checking partial containers 
                *****************************************************************************
            -->
            <!-- neither unitid nor container -->
            <xsl:if test="ead:did[not(ead:container or ead:unitid[@type='itemnumber'])] and not(ead:c)">
                <item>
                    <xsl:attribute name="selftype">item</xsl:attribute>
                    <xsl:value-of select="@id"/>
                </item>
            </xsl:if>
            <!-- one containertype, no unitid -->
            <xsl:if
                test="count(distinct-values(ead:did/ead:container[not(ead:ptr or @parent)]/@type)) = 1 and not(ead:did/ead:unitid[not(ead:ptr) and @type = 'itemnumber'])">
                <xsl:for-each
                    select="ead:did/ead:container[not(ead:ptr or @parent)][not(@type = 'item')]/@type[count(distinct-values(.)) = 1]">
                    <xsl:variable name="selftype" select="."/>
                    <xsl:choose>
                        <xsl:when test="count(tokenize(../text(), '-')) = 2">
                            <xsl:variable name="tokens" select="tokenize(../text(), '-')"/>
                            <xsl:choose>
                                <xsl:when
                                    test="$tokens[1] castable as xs:integer and $tokens[2] castable as xs:integer">
                                    <xsl:for-each
                                        select="xs:integer($tokens[1]) to xs:integer($tokens[2])">
                                        <xsl:variable name="selftext" select="current()"/>
                                        <item>
                                            <xsl:attribute name="selftype">
                                                <xsl:value-of select="$selftype"/>
                                            </xsl:attribute>
                                            <xsl:value-of select="$selftype, $selftext"/>
                                        </item>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:for-each select="$tokens">
                                        <item type="alphanum">
                                            <xsl:attribute name="number"
                                                select="replace(current(), '\D', '')"/>
                                            <xsl:attribute name="selftype">
                                                <xsl:value-of select="$selftype"/>
                                            </xsl:attribute>
                                            <xsl:value-of select="$selftype, current()"/>
                                        </item>
                                    </xsl:for-each>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <item>
                                <xsl:attribute name="selftype">
                                    <xsl:value-of select="$selftype"/>
                                </xsl:attribute>
                                <xsl:value-of select="., ../text()"/>
                            </item>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:if>
            <!--one unitid type, no container-->
            <xsl:if
                test="count(distinct-values(ead:did/ead:unitid[not(ead:ptr) and @type = 'itemnumber']/@type)) = 1 and not(ead:did/ead:container)">
                <xsl:for-each
                    select="ead:did/ead:unitid[not(ead:ptr) and @type = 'itemnumber']/@type[count(distinct-values(.)) = 1]">
                    <xsl:variable name="selftype" select="."/>
                    <xsl:choose>
                        <xsl:when test="count(tokenize(../text(), '-')) = 2">
                            <xsl:variable name="tokens" select="tokenize(../text(), '-')"/>
                            <xsl:choose>
                                <xsl:when
                                    test="$tokens[1] castable as xs:integer and $tokens[2] castable as xs:integer">
                                    <xsl:for-each
                                        select="xs:integer($tokens[1]) to xs:integer($tokens[2])">
                                        <xsl:variable name="selftext" select="current()"/>
                                        <item>
                                            <xsl:attribute name="selftype">
                                                <xsl:value-of select="$selftype"/>
                                            </xsl:attribute>
                                            <xsl:value-of select="$selftype, $selftext"/>
                                        </item>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:for-each select="$tokens">
                                        <item type="alphanum">
                                            <xsl:attribute name="number"
                                                select="replace(current(), '\D', '')"/>
                                            <xsl:attribute name="selftype">
                                                <xsl:value-of select="$selftype"/>
                                            </xsl:attribute>
                                            <xsl:value-of select="$selftype, current()"/>
                                        </item>
                                    </xsl:for-each>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <item>
                                <xsl:attribute name="selftype">
                                    <xsl:value-of select="$selftype"/>
                                </xsl:attribute>
                                <xsl:value-of select="., ../text()"/>
                            </item>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:if>
            <!-- multiple container types, no unitid -->
            <xsl:if
                test="count(distinct-values(ead:did/ead:container[not(ead:ptr or @parent)]/@type)) > 1 and not(ead:did/ead:unitid[not(ead:ptr) and @type = 'itemnumber'])">
                <!-- matching container is item or is neither exclusive sub-, nor supercontainer, 
                    and has preceding sibling of different type: ignore containing containers, 
                    or has no preceding sibling and is of same type: use self-->
                <!-- build in here a filter for the ree/box/folder scenario -->
                <xsl:for-each
                    select="
                        ead:did/ead:container[not(ead:ptr or @parent)][(
                        matches(@type, $item) or matches(@type, $othercontainer))
                        and
                        (
                        (preceding-sibling::ead:container[not(ead:ptr or @parent)]
                        and (@type != preceding-sibling::ead:container[not(ead:ptr or @parent)]/@type))
                        or
                        (not(preceding-sibling::ead:container[not(ead:ptr or @parent)])
                        and @type = following-sibling::ead:container[not(ead:ptr or @parent)]/@type)
                        )
                        ]">
                    <xsl:variable name="selftype" select="@type"/>
                    <xsl:variable name="selftext" select="text()"/>
                    <xsl:variable name="precedingtype"
                        select="preceding-sibling::ead:container[not(ead:ptr or @parent)][not((@type = following-sibling::ead:container[1][not(ead:ptr or @parent)]/@type))][1]/@type"/>
                    <xsl:variable name="precedingtext"
                        select="preceding-sibling::ead:container[not(ead:ptr or @parent)][not((@type = following-sibling::ead:container[1][not(ead:ptr or @parent)]/@type))][1]/text()"> </xsl:variable>
                    <xsl:choose>
                        <xsl:when test="count(tokenize(current(), '-|\sto\s')) = 2">
                            <xsl:variable name="tokens" select="tokenize(current(), '-|\sto\s')"/>
                            <xsl:choose>
                                <xsl:when
                                    test="$tokens[1] castable as xs:integer and $tokens[2] castable as xs:integer">
                                    <xsl:for-each
                                        select="xs:integer($tokens[1]) to xs:integer($tokens[2])">
                                        <item>
                                            <xsl:attribute name="selftype">
                                                <xsl:value-of select="$selftype"/>
                                            </xsl:attribute>
                                            <xsl:value-of
                                                select="
                                                    if ($precedingtype = 'folder'
                                                    or
                                                    $precedingtype = ($subcontainer | $item))
                                                    then
                                                        ()
                                                    else
                                                        $precedingtype, $precedingtext, $selftype, current()"
                                            />
                                        </item>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:for-each select="$tokens">
                                        <item type="alphanum">
                                            <xsl:attribute name="number"
                                                select="replace(current(), '\D', '')"/>
                                            <xsl:attribute name="selftype">
                                                <xsl:value-of select="$selftype"/>
                                            </xsl:attribute>
                                            <xsl:value-of
                                                select="
                                                    if ($precedingtype = 'folder'
                                                    or
                                                    $precedingtype = ($subcontainer | $item))
                                                    then
                                                        ()
                                                    else
                                                        $precedingtype, $precedingtext, $selftype, current()"
                                            />
                                        </item>
                                    </xsl:for-each>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select="current()">
                                <item>
                                    <xsl:attribute name="selftype">
                                        <xsl:value-of select="$selftype"/>
                                    </xsl:attribute>
                                    <xsl:value-of
                                        select="
                                            if ($precedingtype = 'folder'
                                            or
                                            $precedingtype = ($subcontainer | $item)
                                            )
                                            then
                                                if (current()/following-sibling::ead:container[1][not(ead:ptr or @parent)]/@type = 'folder')
                                                then
                                                    ()
                                                else
                                                    ($selftype, $selftext)
                                            else
                                                (
                                                $precedingtype, $precedingtext, $selftype, $selftext)"
                                    />
                                </item>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:if>
            <!-- one container type combined with unitid -->
            <xsl:if
                test="count(distinct-values(ead:did/ead:container[not(ead:ptr or @parent)]/@type)) >= 1 and ead:did/ead:unitid[not(ead:ptr) and @type = 'itemnumber']">
                <!-- matching container is item or is neither exclusive sub-, nor supercontainer, and has preceding sibling of different type: ignore containing containers or has no preceding sibling and is of same type: use self-->
                <xsl:for-each
                    select="
                        ead:did/ead:container[not(ead:ptr or @parent)][(
                        matches(@type, $item) or matches(@type, $othercontainer))
                        and
                        (preceding-sibling::ead:unitid[not(ead:ptr) and @type = 'itemnumber'])
                        ]">
                    <xsl:variable name="selftype" select="@type"/>
                    <xsl:variable name="precedingtype"
                        select="preceding-sibling::ead:unitid[1][not(ead:ptr) and @type = 'itemnumber']/@type"/>
                    <xsl:variable name="precedingtext"
                        select="preceding-sibling::ead:unitid[1][not(ead:ptr) and @type = 'itemnumber']/text()"/>
                    <xsl:choose>
                        <xsl:when test="count(tokenize(current(), '-|\sto\s')) = 2">
                            <xsl:variable name="tokens" select="tokenize(current(), '-|\sto\s')"/>
                            <xsl:choose>
                                <xsl:when
                                    test="$tokens[1] castable as xs:integer and $tokens[2] castable as xs:integer">
                                    <xsl:for-each
                                        select="xs:integer($tokens[1]) to xs:integer($tokens[2])">
                                        <xsl:variable name="selftext" select="current()"/>
                                        <item>
                                            <xsl:attribute name="selftype">
                                                <xsl:value-of select="$selftype"/>
                                            </xsl:attribute>
                                            <xsl:value-of
                                                select="$precedingtype, $precedingtext, $selftype, $selftext"
                                            />
                                        </item>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:for-each select="$tokens">
                                        <item type="alphanum">
                                            <xsl:attribute name="number"
                                                select="replace(current(), '\D', '')"/>
                                            <xsl:attribute name="selftype">
                                                <xsl:value-of select="$selftype"/>
                                            </xsl:attribute>
                                            <xsl:value-of
                                                select="$precedingtype, $precedingtext, $selftype, current()"
                                            />
                                        </item>
                                    </xsl:for-each>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <item>
                                <xsl:attribute name="selftype">
                                    <xsl:value-of select="@type"/>
                                </xsl:attribute>
                                <xsl:value-of
                                    select="preceding-sibling::ead:unitid[not(ead:ptr) and @type = 'itemnumber']/(@type, text()), @type, text()"
                                />
                            </item>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
                <!-- This may be moot pending data fixes. It's Mudd-specific and addresses items in a box, to the best of my understanding. -->
                <xsl:for-each
                    select="
                    ead:did/ead:container[not(ead:ptr or @parent)][(
                    matches(@type, $item) or matches(@type, $othercontainer))
                    and
                    (following-sibling::ead:unitid[not(ead:ptr) and @type = 'itemnumber'])
                    ]">
                    <xsl:variable name="selftype" select="following-sibling::ead:unitid[not(ead:ptr) and @type = 'itemnumber']/@type"/>
                    <xsl:variable name="precedingtype"
                        select="preceding-sibling::ead:container[1][not(ead:ptr or @parent)]/@type"/>
                    <xsl:variable name="precedingtext"
                        select="preceding-sibling::ead:container[1][not(ead:ptr or @parent)]//text()"/>
                    <xsl:choose>
                        <xsl:when test="count(tokenize(current(), '-|\sto\s')) = 2">
                            <xsl:variable name="tokens" select="tokenize(current(), '-|\sto\s')"/>
                            <xsl:choose>
                                <xsl:when
                                    test="$tokens[1] castable as xs:integer and $tokens[2] castable as xs:integer">
                                    <xsl:for-each
                                        select="xs:integer($tokens[1]) to xs:integer($tokens[2])">
                                        <xsl:variable name="selftext" select="current()"/>
                                        <item>
                                            <xsl:attribute name="selftype">
                                                <xsl:value-of select="$selftype"/>
                                            </xsl:attribute>
                                            <xsl:value-of
                                                select="$precedingtype, $precedingtext, $selftype, $selftext"
                                            />
                                        </item>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:for-each select="$tokens">
                                        <item type="alphanum">
                                            <xsl:attribute name="number"
                                                select="replace(current(), '\D', '')"/>
                                            <xsl:attribute name="selftype">
                                                <xsl:value-of select="$selftype"/>
                                            </xsl:attribute>
                                            <xsl:value-of
                                                select="$precedingtype, $precedingtext, $selftype, current()"
                                            />
                                        </item>
                                    </xsl:for-each>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <item>
                                <xsl:choose>
                                    <xsl:when test="../count(ead:container) = 1">
                                <xsl:attribute name="selftype">

                                    <xsl:value-of select="following-sibling::ead:unitid[not(ead:ptr) and @type = 'itemnumber']/@type"/>
                                </xsl:attribute>
                                <xsl:value-of
                                    select="following-sibling::ead:unitid[not(ead:ptr) and @type = 'itemnumber']/(@type, text()), @type, text()"
                                />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="selftype">
                                            
                                            <xsl:value-of select="@type"/>
                                        </xsl:attribute>
                                        <xsl:value-of
                                            select="@type, text()"
                                        />
                                    </xsl:otherwise></xsl:choose>
                            </item>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:if>
        </xsl:variable>
        <!-- 
            ********************************************
            begin processing extent
            ********************************************
        -->
        <!-- level=item and no container -->
        <xsl:choose>
            <xsl:when test="not(ead:did/ead:container) and not(ead:did/ead:unitid) and @level = 'item'">
            <extent type="computed" unit="item">1 item </extent>
        </xsl:when>
            <xsl:otherwise>
        <!-- containers or unitids present -->
        <xsl:for-each select="$component-index">
            <xsl:for-each-group
                select="
                    *[count(tokenize(., '\s')) = 2
                    and not(starts-with(., 'cabinet') and starts-with(following-sibling::*[1], 'box'))]"
                group-by="substring-before(., ' ')">
                <extent type="computed">
                    <xsl:attribute name="unit">
                        <xsl:choose>
                            <xsl:when test="current-grouping-key() = 'itemnumber'">
                                <xsl:value-of select="'item'"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="current-grouping-key()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <!-- compute alphanums -->
                    <xsl:if test="./@type or following-sibling::*/@type">
                        <xsl:text>at least </xsl:text>
                    </xsl:if>
                    <xsl:variable name="counter">
                        <xsl:value-of
                            select="
                                if ((current()[not(@type)] or following-sibling::*[not(@type)]) and not(following-sibling::*[@type]))
                                then
                                    count(current-group())
                                else
                                    if ((current()[@type] or following-sibling::*[@type]) and not(following-sibling::*[not(@type)]))
                                    then
                                        sum(.[@number]/following-sibling::*[1]/number(@number) - ./number(@number) + 1)
                                    else
                                        sum(count(current-group()) + .[@number]/following-sibling::*[1]/number(@number) - ./number(@number) + 1)
                                "
                        />
                    </xsl:variable>
                    <xsl:value-of select="$counter"/>
                    <xsl:choose>
                        <xsl:when test="current-grouping-key() = 'itemnumber'">
                            <xsl:value-of select="' item'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="' ', current-grouping-key()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="count(current-group()) > 1">
                        <xsl:if test="current-grouping-key() = 'box'">
                            <xsl:text>e</xsl:text>
                        </xsl:if>
                        <xsl:text>s</xsl:text>
                    </xsl:if>
                    <xsl:if
                        test="$component-index/*[@selftype = current-grouping-key()]/text()[count(key('collection-index', ., $root)) > 1]">
                        <xsl:text> (</xsl:text>
                        <xsl:if
                            test="$counter != count($component-index/*[@selftype = current-grouping-key()]/text()[count(key('collection-index', ., $root)) > 1])">
                            <xsl:value-of
                                select="count($component-index/*[@selftype = current-grouping-key()]/text()[count(key('collection-index', ., $root)) > 1])"/>
                            <xsl:text> </xsl:text>
                        </xsl:if>
                        <xsl:text>partial)</xsl:text>
                    </xsl:if>
                </extent>
            </xsl:for-each-group>
            <xsl:for-each-group
                select="*[count(tokenize(., '\s')) = 3 and not(starts-with(., 'cabinet') and starts-with(following-sibling::*[1], 'box'))]"
                group-by="substring-before(., ' ')">
                <extent type="computed">
                    <xsl:attribute name="unit">
                        <xsl:choose>
                            <xsl:when test="current-grouping-key() = 'itemnumber'">
                                <xsl:value-of select="'item'"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="current-grouping-key()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <!-- compute alphanums -->
                    <xsl:if test="./@type or following-sibling::*/@type">
                        <xsl:text>at least </xsl:text>
                    </xsl:if>
                    <xsl:variable name="counter">
                        <xsl:value-of
                            select="
                                if ((current()[not(@type)] or following-sibling::*[not(@type)]) and not(following-sibling::*[@type]))
                                then
                                    count(current-group())
                                else
                                    if ((current()[@type] or following-sibling::*[@type]) and not(following-sibling::*[not(@type)]))
                                    then
                                        sum(.[@number]/following-sibling::*[1]/number(@number) - ./number(@number) + 1)
                                    else
                                        sum(count(current-group()) + .[@number]/following-sibling::*[1]/number(@number) - ./number(@number) + 1)
                                "
                        />
                    </xsl:variable>
                    <xsl:value-of select="$counter"/>
                    <xsl:choose>
                        <xsl:when test="current-grouping-key() = 'itemnumber'">
                            <xsl:value-of select="' item'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="' ', current-grouping-key()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="count(current-group()) > 1">
                        <xsl:if test="current-grouping-key() = 'box'">
                            <xsl:text>e</xsl:text>
                        </xsl:if>
                        <xsl:text>s</xsl:text>
                    </xsl:if>
                    <xsl:if
                        test="$component-index/*[@selftype = current-grouping-key()]/text()[count(key('collection-index', ., $root)) > 1]">
                        <xsl:text> (</xsl:text>
                        <xsl:if
                            test="$counter != count($component-index/*[@selftype = current-grouping-key()]/text()[count(key('collection-index', ., $root)) > 1])">
                            <xsl:value-of
                                select="count($component-index/*[@selftype = current-grouping-key()]/text()[count(key('collection-index', ., $root)) > 1])"/>
                            <xsl:text> </xsl:text>
                        </xsl:if>
                        <xsl:text>partial)</xsl:text>
                    </xsl:if>
                </extent>
            </xsl:for-each-group>
            <xsl:for-each-group
                select="*[count(tokenize(., '\s')) = 4 and not(starts-with(., 'cabinet') and starts-with(following-sibling::*[1], 'box') or tokenize(., '\s')[3] = 'cabinet')]"
                group-by="if(starts-with(., 'item')) then substring-before(., ' ') else functx:substring-after-last-match(functx:substring-before-last-match(., '\s'), '\s')">
                <extent type="computed">
                    <xsl:attribute name="unit">
                        <xsl:choose>
                            <xsl:when test="current-grouping-key() = 'itemnumber'">
                                <xsl:value-of select="'item'"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="current-grouping-key()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <!-- compute alphanums -->
                    <xsl:if test="./@type or following-sibling::*/@type">
                        <xsl:text>at least </xsl:text>
                    </xsl:if>
                    <xsl:variable name="counter">
                        <xsl:value-of
                            select="
                                if ((current()[not(@type)] or following-sibling::*[not(@type)]) and not(following-sibling::*[@type]))
                                then
                                    count(current-group())
                                else
                                    if ((current()[@type] or following-sibling::*[@type]) and not(following-sibling::*[not(@type)]))
                                    then
                                        sum(.[@number]/following-sibling::*[1]/number(@number) - ./number(@number) + 1)
                                    else
                                        count(current-group()) + sum(.[@number]/following-sibling::*[1]/number(@number) - ./number(@number) + 1)
                                "
                        />
                    </xsl:variable>
                    <xsl:value-of select="$counter"/>
                    <xsl:choose>
                        <xsl:when test="current-grouping-key() = 'itemnumber'">
                            <xsl:value-of select="' item'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="' ', current-grouping-key()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="count(current-group()) > 1">
                        <xsl:if test="current-grouping-key() = 'box'">
                            <xsl:text>e</xsl:text>
                        </xsl:if>
                        <xsl:text>s</xsl:text>
                    </xsl:if>
                    <xsl:if
                        test="$component-index/*[@selftype = current-grouping-key()]/text()[count(key('collection-index', ., $root)) > 1]">
                        <xsl:text> (</xsl:text>
                        <xsl:if
                            test="$counter != count($component-index/*[@selftype = current-grouping-key()]/text()[count(key('collection-index', ., $root)) > 1])">
                            <xsl:value-of
                                select="count($component-index/*[@selftype = current-grouping-key()]/text()[count(key('collection-index', ., $root)) > 1])"/>
                            <xsl:text> </xsl:text>
                        </xsl:if>
                        <xsl:text>partial)</xsl:text>
                    </xsl:if>
                    <!-- leave for testing/debugging purposes -->
                    <!--                    <test>
                        <xsl:value-of
                            select="count($component-index/*[@selftype = current-grouping-key()]/text()[count(key('collection-index', ., $root)) > 1])"/>
                        <xsl:value-of
                                select="key('collection-index', $component-index/*[@selftype = current-grouping-key()]/text(), $root)"/>
                    </test>-->
                </extent>
            </xsl:for-each-group>
        </xsl:for-each>
            </xsl:otherwise></xsl:choose>
        <!-- leave for testing/debugging purposes -->
        <componentindex>
            <xsl:copy-of select="$component-index"/>
        </componentindex>
        <!-- <key>
            <xsl:value-of select="$component-index/*[key('collection-index', ., $root)]"/>
        </key>-->
    </xsl:template>
</xsl:stylesheet>
