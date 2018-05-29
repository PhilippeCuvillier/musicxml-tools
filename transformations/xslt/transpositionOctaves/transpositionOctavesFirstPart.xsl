<?xml version="1.0" encoding="UTF-8"?>

<!--
   Transposes the octaves of all notes of a music sheet.
   Affects only the first part.
   
   Do not change stem directions. 
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   exclude-result-prefixes="xs"
   version="1.0">
   
   <!--
      XML output, MusicXML 3.1 Partwise DTD.
   -->
   <xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="no" standalone="no"
      doctype-system="http://www.musicxml.org/dtds/partwise.dtd"
      doctype-public="-//Recordare//DTD MusicXML 3.1 Partwise//EN"/>
   
   <!-- INPUT PARAMETERS -->
   <!--
      Transposition in octaves
   -->
   <xsl:param name="octaves" select="1"/>
   
   <!--
      Identity template that will copy every
      attribute, element, comment, and processing instruction
      to the output
   -->
   <xsl:template match="@*|comment()|processing-instruction()|node()">
      <xsl:copy>
         <xsl:apply-templates select="@*|comment()|processing-instruction()|node()"/>
      </xsl:copy>
   </xsl:template>
   
   <!-- MAIN OPERATION -->
   <!-- 
      Deep copy all but first part (so that transposition is not applied).
   -->
   <xsl:template match="part[count(preceding-sibling::part)]">
      <xsl:copy-of select="."/>
   </xsl:template>
   
   <!--
      Apply transposition on octave elements 
   -->
   <xsl:template match="octave">
      <xsl:copy>
         <xsl:value-of select=". + $octaves"/>
      </xsl:copy>
   </xsl:template>
</xsl:stylesheet>