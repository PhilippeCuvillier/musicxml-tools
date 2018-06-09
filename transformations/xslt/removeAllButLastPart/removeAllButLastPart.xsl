<?xml version="1.0" encoding="UTF-8"?>
<!-- <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" exclude-result-prefixes="xs xd" version="2.0"> -->
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <!--
    XML output, with a DOCTYPE refering the partwise DTD.
    Here we use the full Internet URL.
  -->
  <xsl:output method="xml" indent="yes" encoding="UTF-8"
      omit-xml-declaration="no" standalone="no"
      doctype-system="http://www.musicxml.org/dtds/partwise.dtd"
      doctype-public="-//Recordare//DTD MusicXML 3.1 Partwise//EN" />

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
      Remove last score-part if there is strictly more than one score-part
      -->
      <xsl:template match="score-partwise/part-list/score-part[last() > position()]"/>
      <!--
      Remove last part if there is strictly more than one part
      -->
      <xsl:template match="score-partwise/part[last() > position()]"/>
</xsl:stylesheet>
