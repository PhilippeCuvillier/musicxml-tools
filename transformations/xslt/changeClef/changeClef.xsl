<?xml version="1.0" encoding="UTF-8"?>

<!--
  Replace all clef of the score by another one (default is treble clef).
  
  All <clef> elements are removed, except the first clef of each staff of each first measure of each part.
  An assumption is made on the score: this operation assumes that the first measure of each part 
  contains a <clef> for each staff of the part.
  Note that 'additional' clefs will be removed (e.g. clefs for cues). This might be an un-desired behavior in some cases.
-->
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <!--
    XML output, with a DOCTYPE refering the partwise DTD.
  -->
  <xsl:output method="xml" indent="yes" encoding="UTF-8"
    omit-xml-declaration="no" standalone="no"
    doctype-system="http://www.musicxml.org/dtds/partwise.dtd"
    doctype-public="-//Recordare//DTD MusicXML 3.1 Partwise//EN" />
  <xsl:strip-space elements="*"/>
  
  <!--
    Input parameters
  -->
  <!--
    Destination clef.
    Default value is treble clef.
  -->
  <xsl:param name="sign" select="'G'"/>
  <xsl:param name="line" select="2"/>
  <xsl:param name="clef-octave-change" select="0"/>
  
  <!--Identity template that will copy every
    attribute, element, comment, and processing instruction
    to the output-->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- MAIN OPERATION -->
  <!--
    Step 1. Insert the key in first measure of each part
  -->
  <xsl:template
    match="/score-partwise/part/measure[1]/attributes[1]/clef"
    priority="2">
    <!-- Copy the clef element -->
    <xsl:copy>
      <!-- Copy all attributes inside it -->
      <xsl:apply-templates select="@*"/>
      <!-- Add the input value -->
      <sign><xsl:value-of select="$sign"/></sign>
      <line><xsl:value-of select="$line"/></line>
      <xsl:if test="$clef-octave-change != 0">
        <clef-octave-change><xsl:value-of select="$clef-octave-change"/></clef-octave-change>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  
  <!--
    Step 2. Remove all other clefs
  -->
  <xsl:template match="clef" priority="1"/>
</xsl:stylesheet>
