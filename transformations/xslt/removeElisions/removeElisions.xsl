<?xml version="1.0" encoding="UTF-8"?>

<!--
    In each lyric, concatenate multi-syllabic text.
    More explicitly, merge multiple <text> and <elisions> elements into a single <text> element, inside each <lyric> element.
    
    Suitable for MusicXML Partwise files.
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!--
      XML output, with a DOCTYPE refering the partwise DTD.
    -->
    <xsl:output method="xml" indent="yes" encoding="UTF-8"
        omit-xml-declaration="no" standalone="no"
        doctype-system="http://www.musicxml.org/dtds/partwise.dtd"
        doctype-public="-//Recordare//DTD MusicXML 3.1 Partwise//EN"
    />


    <!--Identity template that will copy every
        attribute, element, comment, and processing instruction
        to the output-->
    <xsl:template match="@*|node()">
        <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
    </xsl:template>

    <!-- MAIN OPERATION -->
    <!--
        Step 1. In each lyric, join all sibling text elements
    -->
   <xsl:template match="lyric[text[2]]/text[1]">
        <text>
          <xsl:call-template name="join">
            <xsl:with-param name="list" select="../text" />
            <xsl:with-param name="separator" select="'_'" />
          </xsl:call-template>
        </text>
    </xsl:template>
    <!--
        Step 2. In each lyric, remove all elision elements and all but first syllabic elements and text elements.
    -->
    <xsl:template match = "lyric/elision | lyric/syllabic[position() > 1] | lyric/text[position() > 1]"/>


    <!-- UTILITIES -->
    <!--
        Join a list of text nodes using the given separator
    -->
    <xsl:template name="join">
        <xsl:param name="list" />
        <xsl:param name="separator"/>
    
        <xsl:for-each select="$list">
            <xsl:value-of select="." />
            <xsl:if test="position() != last()">
                <xsl:value-of select="$separator" />
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>