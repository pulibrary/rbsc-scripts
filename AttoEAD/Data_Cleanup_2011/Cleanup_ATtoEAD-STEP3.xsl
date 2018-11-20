<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="urn:isbn:1-931666-22-9" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:ead="urn:isbn:1-931666-22-9"
    xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:ns2="http://www.w3.org/1999/xlink"
    version="2.0" exclude-result-prefixes="#all">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Sep 14, 2011</xd:p>
            <xd:p><xd:b>Author:</xd:b> heberlei</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template
        match="ead:unitdate[not(@normal) and not(.='undated') and not(.='Undated') and contains(., '-')] | ead:date[not(@normal) and not(.='undated') and not(.='Undated') and contains(., '-')]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>

            <xsl:analyze-string select="string(.)"
                regex="(^\(*\[*[,\s\w]*)(\d{{4}})([\s\w\(\)\?]*-[\s\w]*)(\d{{4}})([,\s\w\(\)\?\]]*$)"
                flags="x">
                <xsl:matching-substring>
                    <xsl:attribute name="type">inclusive</xsl:attribute>
                    <xsl:attribute name="normal">
                        <xsl:value-of select="regex-group(2)"/>/<xsl:value-of
                            select="regex-group(4)"/>
                    </xsl:attribute>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:analyze-string select="string(.)" regex="(^\(*\[*\d{{2}})(\d{{2}})(-)(\d{{2}}[\]\)]*$)"
                        flags="x">
                        <xsl:matching-substring>
                            <xsl:attribute name="type">inclusive</xsl:attribute>
                            <xsl:attribute name="normal">
                                <xsl:value-of select="regex-group(1)"/><xsl:value-of
                                    select="regex-group(2)"/>/<xsl:value-of select=" regex-group(1)"
                                    /><xsl:value-of select="regex-group(4)"/>
                            </xsl:attribute>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <xsl:analyze-string select="string(.)"
                                regex="(^\(*\[*\d{{4}})(\s\w+\s*(\d{{1,2}})*\s*-\s*\w+(\d{{1,2}})*\)*\]*)"
                                flags="x">
                                <xsl:matching-substring>
                                    <xsl:attribute name="type">inclusive</xsl:attribute>
                                    <xsl:attribute name="normal">
                                        <xsl:value-of select="regex-group(1)"/>
                                    </xsl:attribute>
                                </xsl:matching-substring>
                                <xsl:non-matching-substring>
                                    <xsl:analyze-string select="string(.)"
                                        regex="(^\(*\[*\d{{4}})([\s\w]*-[\s\w]*)(\d{{4}})([,\s\w]*)(\d{{4}}\)*\]*$)"
                                        flags="x">
                                        <xsl:matching-substring>
                                            <xsl:attribute name="type">inclusive</xsl:attribute>
                                            <xsl:attribute name="normal">
                                                <xsl:value-of select="regex-group(1)"
                                                  />/<xsl:value-of select="regex-group(5)"/>
                                            </xsl:attribute>
                                        </xsl:matching-substring>
                                        <xsl:non-matching-substring>
                                            <xsl:analyze-string select="string(.)"
                                                regex="(^\(*\[*\d{{4}})([\s\w]*-[\s\w]*)(\d{{4}})([,\s\w]*)(\d{{4}})([\s\w]*-[\s\w]*)(\d{{4}}\)*\]*$)"
                                                flags="x">
                                                <xsl:matching-substring>
                                                  <xsl:attribute name="type"
                                                  >inclusive</xsl:attribute>
                                                  <xsl:attribute name="normal">
                                                  <xsl:value-of select="regex-group(1)"
                                                  />/<xsl:value-of select="regex-group(7)"/>
                                                  </xsl:attribute>
                                                </xsl:matching-substring>
                                                <xsl:non-matching-substring>
                                                  <xsl:analyze-string select="string(.)"
                                                      regex="(^\(*\[*\w+\s\d{{1,2}}(-\d{{1,2}})*[,\s]*)(\d{{4}}\)*\]*$)"
                                                  flags="x">
                                                  <xsl:matching-substring>
                                                  <xsl:attribute name="type"
                                                  >inclusive</xsl:attribute>
                                                  <xsl:attribute name="normal">
                                                  <xsl:value-of select="regex-group(3)"/>
                                                  </xsl:attribute>
                                                  </xsl:matching-substring>
                                                  <xsl:non-matching-substring>
                                                  <xsl:analyze-string select="string(.)"
                                                      regex="(^\(*\[*\w+\s\d{{1,2}}[\w+\s-]*(\d{{1,2}})*[,\s]*)(\d{{4}}\)*\]*$)"
                                                  flags="x">
                                                  <xsl:matching-substring>
                                                  <xsl:attribute name="type"
                                                  >inclusive</xsl:attribute>
                                                  <xsl:attribute name="normal">
                                                  <xsl:value-of select="regex-group(3)"/>
                                                  </xsl:attribute>
                                                  </xsl:matching-substring>
                                                  <xsl:non-matching-substring>
                                                  <xsl:analyze-string select="string(.)"
                                                      regex="(^\(*\[*[\w\s]+(\d{{1,2}})*\s*-\s*\w+\s*)((\d{{1,2}})*[,\s]*)(\d{{4}})([,\s]*\w*\)*\]*$)"
                                                  flags="x">
                                                  <xsl:matching-substring>
                                                  <xsl:attribute name="type"
                                                  >inclusive</xsl:attribute>
                                                  <xsl:attribute name="normal">
                                                  <xsl:value-of select="regex-group(5)"/>
                                                  </xsl:attribute>
                                                  </xsl:matching-substring>
                                                  <xsl:non-matching-substring>
                                                  <xsl:analyze-string select="string(.)"
                                                      regex="(^\(*\[*[\w\s]+(\d{{1,2}})[,\s]*)(\d{{4}})(\s*-[\w\s]+(\d{{1,2}})[,\s]*)(\d{{4}}\)*\]*$)"
                                                  flags="x">
                                                  <xsl:matching-substring>
                                                  <xsl:attribute name="type"
                                                  >inclusive</xsl:attribute>
                                                  <xsl:attribute name="normal">
                                                  <xsl:value-of select="regex-group(3)"
                                                  />/<xsl:value-of select="regex-group(6)"/>
                                                  </xsl:attribute>
                                                  </xsl:matching-substring>
                                                  <xsl:non-matching-substring>
                                                  <xsl:analyze-string select="string(.)"
                                                      regex="(^\(*\[*\d{{1,2}}[\s\w+]*-\s*\d{{1,2}}[\s\w+,]*)(\d{{4}}\)*\]*$)"
                                                  flags="x">
                                                  <xsl:matching-substring>
                                                  <xsl:attribute name="type"
                                                  >inclusive</xsl:attribute>
                                                  <xsl:attribute name="normal">
                                                  <xsl:value-of select="regex-group(2)"/>
                                                  </xsl:attribute>
                                                  </xsl:matching-substring>
                                                  <xsl:non-matching-substring>
                                                  <xsl:analyze-string select="string(.)"
                                                      regex="(^\(*\[*\d{{4}})(['\w,\s]*)(\d{{4}}\s*-\s*)(\d{{4}})(\)*\]*$)"
                                                  flags="x">
                                                  <xsl:matching-substring>
                                                  <xsl:attribute name="type"
                                                  >inclusive</xsl:attribute>
                                                  <xsl:attribute name="normal">
                                                  <xsl:value-of select="regex-group(1)"
                                                  />/<xsl:value-of select="regex-group(4)"/>
                                                  </xsl:attribute>
                                                  </xsl:matching-substring>
                                                  <xsl:non-matching-substring> 
                                                      <xsl:analyze-string select="string(.)"
                                                          regex="(^\(*\[*\d{{4}})(,*\s)(\d{{4}})(,*\s\w+\s*[\d{{1,2}}]*-*[\s\w+\d{{1,2}}]*\)*\]*$)"
                                                          flags="x">
                                                          <xsl:matching-substring>
                                                              <xsl:attribute name="type"
                                                                  >inclusive</xsl:attribute>
                                                              <xsl:attribute name="normal">
                                                                  <xsl:value-of select="regex-group(1)"
                                                                  />/<xsl:value-of select="regex-group(3)"/>
                                                              </xsl:attribute>
                                                          </xsl:matching-substring>
                                                          <xsl:non-matching-substring>
                                                              <xsl:analyze-string select="string(.)"
                                                                  regex="(^\(*\[*\d{{4}})(-)(\d{{4}})(,*\s)(\d{{4}})(-)(\d{{4}})(,*\s)(\d{{4}})(-)(\d{{4}})(\)*\]*$)"
                                                                  flags="x">
                                                                  <xsl:matching-substring>
                                                                      <xsl:attribute name="type"
                                                                          >inclusive</xsl:attribute>
                                                                      <xsl:attribute name="normal">
                                                                          <xsl:value-of select="regex-group(1)"
                                                                          />/<xsl:value-of select="regex-group(3)"/>
                                                                      </xsl:attribute>
                                                                  </xsl:matching-substring>
                                                                  </xsl:analyze-string>
                                                          </xsl:non-matching-substring>
                                                          </xsl:analyze-string>
                                                  </xsl:non-matching-substring>
                                                  </xsl:analyze-string>
                                                  </xsl:non-matching-substring>
                                                  </xsl:analyze-string>
                                                  </xsl:non-matching-substring>
                                                  </xsl:analyze-string>
                                                  </xsl:non-matching-substring>
                                                  </xsl:analyze-string>
                                                  </xsl:non-matching-substring>
                                                  </xsl:analyze-string>
                                                  </xsl:non-matching-substring>
                                                  </xsl:analyze-string>
                                                </xsl:non-matching-substring>
                                            </xsl:analyze-string>
                                        </xsl:non-matching-substring>
                                    </xsl:analyze-string>
                                </xsl:non-matching-substring>
                            </xsl:analyze-string>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template
        match="ead:unitdate[not(@normal) and not(.='undated') and not(.='Undated') and not(contains(., '-'))] ">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:analyze-string select="string(.)" regex="(^[(\[]*)(\d{{4}})([\?)\]]*$)" flags="x">
                <xsl:matching-substring>
                    <xsl:attribute name="normal">
                        <xsl:value-of select="regex-group(2)"/>/<xsl:value-of select="regex-group(2)"/>
                    </xsl:attribute>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:analyze-string select="string(.)" regex="(^)(\(*\[*\d{{4}})([,*\s\w+]+\)*\]*$)">
                        <xsl:matching-substring>
                            <xsl:attribute name="normal">
                                <xsl:value-of select="regex-group(2)"/>/<xsl:value-of select="regex-group(2)"/>
                            </xsl:attribute>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring>
                            <xsl:analyze-string select="string(.)"
                                regex="(^)(\(*\[*\w+[,()\?\s]*)+(\d{{4}})([,()\?\s]*)(\)*\]*$)">
                                <xsl:matching-substring>
                                    <xsl:attribute name="normal">
                                        <xsl:value-of select="regex-group(3)"/>/<xsl:value-of select="regex-group(3)"/>
                                    </xsl:attribute>
                                </xsl:matching-substring>
                                <xsl:non-matching-substring>
                                    <xsl:analyze-string select="string(.)"
                                        regex="(^\(*\[*)(\d{{4}})(,*\s\w+\s\d{{1,2}},*\s*(\d{{1,2}})*\)*\]*$)">
                                        <xsl:matching-substring>
                                            <xsl:attribute name="normal">
                                                <xsl:value-of select="regex-group(2)"/>/<xsl:value-of select="regex-group(2)"/>
                                            </xsl:attribute>
                                        </xsl:matching-substring>
                                        <xsl:non-matching-substring>
                                            <xsl:analyze-string select="string(.)"
                                                regex="(^\(*\[*)(\d{{4}})(,*\s)(\d{{4}})(\s\w+(\s\d{{1,2}})*)(\)*\]*$)"
                                                flags="x">
                                                <xsl:matching-substring>
                                                  <xsl:attribute name="normal">
                                                  <xsl:value-of select="regex-group(2)"
                                                  />/<xsl:value-of select="regex-group(4)"/>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="type"
                                                  >inclusive</xsl:attribute>
                                                </xsl:matching-substring>
                                                <xsl:non-matching-substring>
                                                  <xsl:analyze-string select="string(.)"
                                                      regex="(^\(*\[*\(*\w+[,()\?\s]*)((\d{{1,2}})([,()\?]*\s))+(\d{{4}}\)*)(\)*\]*$)">
                                                  <xsl:matching-substring>
                                                  <xsl:attribute name="normal">
                                                      <xsl:value-of select="regex-group(5)"/>/<xsl:value-of select="regex-group(5)"/>
                                                  </xsl:attribute>
                                                  </xsl:matching-substring>
                                                  <xsl:non-matching-substring>
                                                  <xsl:analyze-string select="string(.)"
                                                      regex="(^)(\(*\[*\d{{4}})(\s*[(\[]\?[)\]])(\)*\]*$)" flags="x">
                                                  <xsl:matching-substring>
                                                  <xsl:attribute name="normal">
                                                      <xsl:value-of select="regex-group(2)"/>/<xsl:value-of select="regex-group(2)"/>
                                                  </xsl:attribute>
                                                  </xsl:matching-substring>
                                                  <xsl:non-matching-substring>
                                                  <xsl:analyze-string select="string(.)"
                                                      regex="(^\(*\[*)(\d{{4}})(,*\s\w+\s(\d{{1,2}})*,*\s*)(\d{{4}})(,*\s\w+(\s\d{{1,2}})*)(\)*\]*$)"
                                                  flags="x">
                                                  <xsl:matching-substring>
                                                  <xsl:attribute name="normal">
                                                  <xsl:value-of select="regex-group(2)"
                                                  />/<xsl:value-of select="regex-group(5)"/>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="type"
                                                  >inclusive</xsl:attribute>
                                                  </xsl:matching-substring>
                                                  <xsl:non-matching-substring>
                                                  <xsl:analyze-string select="string(.)"
                                                      regex="(^\(*\[*[\w+\s]*)(\d{{3}})(0)('*s\)*\]*$)" flags="x">
                                                  <xsl:matching-substring>
                                                  <xsl:attribute name="type"
                                                  >inclusive</xsl:attribute>
                                                  <xsl:attribute name="normal">
                                                  <xsl:value-of select="regex-group(2)"
                                                  /><xsl:value-of select="regex-group(3)"
                                                  />/<xsl:value-of select="regex-group(2)"
                                                  /><xsl:value-of>9</xsl:value-of>
                                                  </xsl:attribute>
                                                  </xsl:matching-substring>
                                                      <xsl:non-matching-substring>
                                                          <xsl:analyze-string select="string(.)"
                                                              regex="(^\(*\[*[\w+\s]*)(\d{{3}})(0)('*s\s*)(\d{{3}})(0)('*s\)*\]*$)" flags="x">
                                                              <xsl:matching-substring>
                                                                  <xsl:attribute name="type"
                                                                      >inclusive</xsl:attribute>
                                                                  <xsl:attribute name="normal">
                                                                      <xsl:value-of select="regex-group(2)"
                                                                      /><xsl:value-of select="regex-group(3)"
                                                                      />/<xsl:value-of select="regex-group(5)"
                                                                      /><xsl:value-of>9</xsl:value-of>
                                                                  </xsl:attribute>
                                                              </xsl:matching-substring>
                                                              <xsl:non-matching-substring>
                                                                  <xsl:analyze-string select="string(.)"
                                                                      regex="(^\(*\[*\w+\.*\s\d{{1,2}}[\s,]*)(\d{{4}})(\s\d{{1,2}}\s*\w+\.*\s)(\d{{4}}\)*\]*$)" flags="x">
                                                                      <xsl:matching-substring>
                                                                          <xsl:attribute name="type"
                                                                              >inclusive</xsl:attribute>
                                                                          <xsl:attribute name="normal">
                                                                              <xsl:value-of select="regex-group(2)"
                                                                              />/<xsl:value-of select="regex-group(4)"
                                                                              />
                                                                          </xsl:attribute>
                                                                      </xsl:matching-substring>
                                                                      <xsl:non-matching-substring>
                                                                          <xsl:analyze-string select="string(.)"
                                                                              regex="(^[\(\[]*)(\d{{4}})([\)\]]*\.[\)\]]*$)" flags="x">
                                                                              <xsl:matching-substring>
                                                                                  <xsl:attribute name="normal">
                                                                                   <xsl:value-of select="regex-group(2)"
                                                                                      />
                                                                                      </xsl:attribute>
                                                                              </xsl:matching-substring>
                                                                              </xsl:analyze-string>
                                                                      </xsl:non-matching-substring>
                                                                      </xsl:analyze-string>
                                                              </xsl:non-matching-substring>
                                                              </xsl:analyze-string>
                                                      </xsl:non-matching-substring>
                                                  </xsl:analyze-string>
                                                  </xsl:non-matching-substring>
                                                  </xsl:analyze-string>
                                                  </xsl:non-matching-substring>
                                                  </xsl:analyze-string>
                                                  </xsl:non-matching-substring>
                                                  </xsl:analyze-string>
                                                </xsl:non-matching-substring>
                                            </xsl:analyze-string>
                                        </xsl:non-matching-substring>
                                    </xsl:analyze-string>
                                </xsl:non-matching-substring>
                            </xsl:analyze-string>
                        </xsl:non-matching-substring>

                    </xsl:analyze-string>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
