<?xml version="1.0" encoding="UTF-8"?>

<!--
   Transposes the octaves of all notes of a music sheet.
   Affects all parts or a single part.
   
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
      Number of octaves for transposition.
   -->
   <xsl:param name="octaves" select="1"/>
   <!--
      Index of the music part to be transposed.
      If 0, then all parts are transposed.
      If > 0, then one part is transposed.
   -->
   <xsl:param name="part" select="0"/>
   
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
      Apply transposition only the <part> with position equals to input parameter 'part'.
      Apply transposition to all parts if 'part' equals to 0.
   -->
   <xsl:template match="part">
      <xsl:choose>
         <xsl:when test="($part = 0) or (1+count(preceding-sibling::part) = $part)">
            <xsl:copy>
               <xsl:apply-templates select="@*|comment()|processing-instruction()|node()"/>
            </xsl:copy>
         </xsl:when>
         <xsl:otherwise>
            <xsl:copy-of select="."/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   
   <!--
      Apply transposition on <octave> elements
   -->
   <xsl:template match="octave">
      <xsl:copy>
         <xsl:value-of select=". + $octaves"/>
      </xsl:copy>
   </xsl:template>
</xsl:stylesheet>