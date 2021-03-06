<?xml version="1.0" encoding="UTF-8"?>
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
      Remove last score-part if there is strictly more than one part
      -->
      <xsl:template match="score-partwise/part-list[count(score-part) > 1]/score-part[last()]"/>
      <!--
      Remove last part if there is strictly more than one part
      -->
      <xsl:template match="score-partwise[count(part) > 1]/part[last()]"/>
</xsl:stylesheet>
