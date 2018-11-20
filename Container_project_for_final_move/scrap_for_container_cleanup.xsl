<xsl:variable name="box" select="ead:container[1]" as="xs:string"/>
<xsl:variable name="folder-elements" as="xs:string*">
    <xsl:for-each select="ead:container[position() > 1]">
        <xsl:value-of select="normalize-space(current())"/>
    </xsl:for-each>
</xsl:variable>
<xsl:variable name="folders" as="xs:string*">
    <xsl:for-each select="$folder-elements">
        <xsl:choose>
            <xsl:when test="current() castable as xs:integer">
                <xsl:value-of select="current()"/>
            </xsl:when>
            <xsl:when test="count(tokenize(current(), '-')) = 2">
                <xsl:variable name="tokens" select="tokenize(current(), '-')"
                    as="xs:string+"/>
                <xsl:for-each select="xs:integer($tokens[1]) to xs:integer($tokens[2]) ">
                    <xsl:value-of select="current()"/>
                </xsl:for-each>
            </xsl:when>