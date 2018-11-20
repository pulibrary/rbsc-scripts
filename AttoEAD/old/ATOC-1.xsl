<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	xmlns:ead="urn:isbn:1-931666-22-9"
	xmlns:ns2="http://www.w3.org/1999/xlink">
<!--
*******************************************************************
* FILE:             ATOC-1.xsl	                                  *
*                                                                 *
* VERSION:          2007A                                         *
*                                                                 *
* AUTHOR:           Mark Carlson                                  *
*                   Special Collections Computer Support Analyst  *
*                   University of Washington Libraries            *
*                   carlsonm@u.washington.edu                     *
*                                                                 *
* USAGE COMMENTS:   This stylesheet takes an XML input file       *
*                   and performs targeted modifications on        *
*                   specific parts of the source document.        *
*                   It will copy all elements, processing-        *
*                   instructions and comments from the source     *
*                   document and copy them to the output stream.  *
*                   The inspiration for this stylesheet came as   *
*                   a way to add or alter the default EAD output  *
*                   from the Archivist Toolkit to add attributes  *
*                   or elements that currently cannot be          *
*                   exported.  You are free to alter this         *
*                   stylesheet to suit your need.                *
*                                                                 *
* DISTRIBUTION:     This file may be freely distributed as long   *
*                   as this section remains in the file.          *
*                                                                 *
* DISCLAIMER:       This file is provided "as is" and the author  *
*                   assumes no responsibility for problems that   *
*                   may result from the use of this stylesheet.   *
*                   The stylesheet has not been extensively       *
*                   tested and should be considered beta          *
*                   quality code.  You should verify that the     *
*                   output resulting from the use of this code    *
*                   is as expected by comparing the source        *
*                   document with the target document             *
*******************************************************************
-->
<!-- PLEASE SEE THE MODIFICATION TIPS FILE FOR TIPS ON HOW TO ALTER THIS DOCUMENT -->
	<xsl:output method="xml" indent="yes"/>
	
	<xsl:template match="* | processing-instruction() | comment()">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
	<!-- BEGIN HIGH-LEVEL <did> PROCESSING -->
	
	<xsl:template match="ead:did[parent::ead:archdesc]">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="hl-did"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- This is the generic template that matches everything that isn't matched by a rule below -->
	
	<xsl:template match="* | processing-instruction() | comment()" mode="hl-did">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="hl-did"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- The following templates add a LABEL attribute with the value as specified -->
	
	<xsl:template match="ead:unittitle" mode="hl-did">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="label">Title</xsl:attribute>
			<xsl:apply-templates mode="hl-did"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="ead:unitdate" mode="hl-did">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="label">Dates</xsl:attribute>
			<xsl:apply-templates mode="hl-did"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="ead:origination" mode="hl-did">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="label">Creator</xsl:attribute>
			<xsl:apply-templates mode="hl-did"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="ead:unitid" mode="hl-did">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="label">Call number</xsl:attribute>
			<xsl:apply-templates mode="hl-did"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="ead:physdesc" mode="hl-did">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="label">Extent</xsl:attribute>
			<xsl:apply-templates mode="hl-did"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="ead:repository" mode="hl-did">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="label">Repository</xsl:attribute>
			<xsl:apply-templates mode="hl-did"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="ead:langmaterial" mode="hl-did">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="label">Language of Materials</xsl:attribute>
			<xsl:apply-templates mode="hl-did"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- END HIGH-LEVEL <did> PROCESSING SECTION-->
		
	<!-- BEGIN <dsc> PROCESSING SECTION -->
	
	<xsl:template match="ead:dsc">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="dsc"/>
		</xsl:copy>
	</xsl:template>
	<!-- This is the generic template that matches everything that isn't matched by the rules specified below -->
	<xsl:template match="* | processing-instruction() | comment()" mode="dsc">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates mode="dsc"/>
		</xsl:copy>
	</xsl:template>
	<!-- The following template adds a LABEL attribute that matches the TYPE attribute of container -->
	<xsl:template match="ead:container" mode="dsc">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="label">
				<xsl:value-of select="@type"/>
			</xsl:attribute>
			<xsl:apply-templates mode="dsc"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- END <dsc> PROCESSING SECTION -->
	
	<!-- BEGIN ADDITIONAL USER MODIFICATION SECTION -->
	
	
	
	<!-- END ADDITIONAL USER MODIFICATION SECTION -->
	
	
</xsl:stylesheet>