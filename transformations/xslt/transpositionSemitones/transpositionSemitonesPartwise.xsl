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
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:exslt="http://exslt.org/common"
   extension-element-prefixes="exslt">
   
   <!--
      XML output, with a DOCTYPE refering the partwise DTD.
   -->
   <xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="no" standalone="no"
      doctype-system="http://www.musicxml.org/dtds/partwise.dtd"
      doctype-public="-//Recordare//DTD MusicXML 3.1 Partwise//EN"/>
   
   <!--
      Input parameters
   -->
   <!--
      Transposition in semitones.
   -->
   <xsl:param name="semitones" select="-3"/>
   <xsl:param name="semitonesAcc" select="$semitones"/>
  
   <!--
      Identity template that will copy every
      attribute, element, comment, and processing instruction
      to the output
   -->
   <xsl:template match="@*|node()">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
   </xsl:template>
   
   <!-- MAIN OPERATION -->
   
   <!--
      <score-partwise>
   -->
   <xsl:template match="score-partwise" name="transposeScorePartwise">
      <xsl:param name="semitonesSolo" select="$semitones"/>
      <xsl:param name="semitonesAcc" select="$semitonesAcc"/>
         
      <!--
         Apply transposition parameters to child elements.
      -->
      <xsl:copy>
         <xsl:apply-templates select="@*|comment()|processing-instruction()|node()">
            <xsl:with-param name="semitonesSolo" select="$semitonesSolo"/>
            <xsl:with-param name="semitonesAcc" select="$semitonesAcc"/>
         </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>
   
   <!-- 
      <part>
   -->
   <xsl:template match="part">
      <xsl:param name="semitonesSolo"/>
      <xsl:param name="semitonesAcc"/>
      
      <!--
         Choose the transposition value to apply to given score, according to its position
      -->
      <xsl:variable name="semitones">
         <xsl:choose>
            <xsl:when test="count(preceding-sibling::part) and not(count(following-sibling::part))">
               <xsl:value-of select="$semitonesAcc"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$semitonesSolo"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      
      <xsl:call-template name="transposePart">
         <xsl:with-param name="semitones" select="$semitones"/>
      </xsl:call-template>
   </xsl:template>
     
   <!--
      Transpose a part with some semitones.
      
      Should be called with <part> as context.
   -->
   <xsl:template name="transposePart">
      <xsl:param name="semitones"/>
            
      <!-- 
         Translate semitones into fifths + octave + direction (up, down, or identical)
      -->
      <xsl:variable name="fifths-offset">
         <xsl:call-template name="semitoneToFifth">
            <xsl:with-param name="semitones" select="$semitones mod 12"/>
         </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="octave-offset-base"
         select="floor($semitones*(1 - 2*($semitones &lt; 0)) div 12) * (1 - 2*($semitones &lt; 0))"
      />
      <xsl:variable name="transpositionDirection" select="number($semitones &gt; 0) - number($semitones &lt; 0)"/>
      
      <!--
         Apply parameters to subsequent transpositions
      -->
      <xsl:copy>
         <xsl:apply-templates select="@*|comment()|processing-instruction()|node()">
            <xsl:with-param name="fifths-offset" select="$fifths-offset"/>
            <xsl:with-param name="octave-offset-base" select="$octave-offset-base"/>
            <xsl:with-param name="transpositionDirection" select="$transpositionDirection"/>
         </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>
   
   <!--
      Retrieve key signature of each <measure> element.

      This assumes the measures contains only one <key> element.
   -->
   <xsl:template match="measure">
      <xsl:param name="fifths-offset"/>
      <xsl:param name="octave-offset-base"/>
      <xsl:param name="transpositionDirection"/>
      <!-- 
         Preliminary: compute transposition offset on the fifths cycle.
         
         This involves choosing the right enharmonic key.
         Current rule relies on current key signature: if > 5 sharps or > 6 flats, then
         switch to the enharmonic key.
      -->
      <xsl:variable
         name="fifths-unwrapped"
         select="(attributes/key/fifths | preceding-sibling::measure/attributes/key/fifths)[last()]/text() + $fifths-offset"
      />
      <xsl:variable name="fifths-offset-wrapped">
         <xsl:choose>
            <xsl:when test="$fifths-unwrapped &gt; 5">
               <xsl:value-of select="$fifths-offset - 12"/>
            </xsl:when>
            <xsl:when test="$fifths-unwrapped &lt; -6">
               <xsl:value-of select="$fifths-offset + 12"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$fifths-offset"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      
      <!--
         Recurse on children with all parameters
      -->
      <xsl:copy>
         <xsl:apply-templates select="@*|comment()|processing-instruction()|node()">
            <xsl:with-param name="fifths-offset" select="$fifths-offset-wrapped"/>
            <xsl:with-param name="octave-offset-base" select="$octave-offset-base"/>
            <xsl:with-param name="transpositionDirection" select="$transpositionDirection"/>
         </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>
   
   <!--
      Propagate parameters on attributes
   -->
   <xsl:template match="attributes">
      <xsl:param name="fifths-offset"/>
      <xsl:copy>
         <xsl:apply-templates select="@*|comment()|processing-instruction()|node()">
            <xsl:with-param name="fifths-offset" select="$fifths-offset"/>
         </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>
   
  
   <!--
      Step 1. a) Change all <key> elements
      
      This involves changing the <fifths> and the <cancel> children.
   -->
   <xsl:template match="key[fifths]">
      <xsl:param name="fifths-offset"/>
<!--      <xsl:param name="octave-offset-base"/>-->
      
      <xsl:copy>
         <!-- write <cancel> element -->
         <xsl:variable name="fifths-previous"
            select="(../../preceding-sibling::measure/attributes/key/fifths)[last()]/text()"/>
         <xsl:if test="$fifths-previous">
            <xsl:variable name="fifths-unwrapped" select="$fifths-previous + $fifths-offset"/>
            <xsl:if test="$fifths-unwrapped != 0">
               <cancel>       
                  <xsl:choose>
                     <xsl:when test="$fifths-unwrapped &gt; 5">
                        <xsl:value-of select="$fifths-unwrapped - 12"/>
                     </xsl:when>
                     <xsl:when test="$fifths-unwrapped &lt; -6">
                        <xsl:value-of select="$fifths-unwrapped + 12"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="$fifths-unwrapped"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </cancel>
            </xsl:if>
         </xsl:if>
         <!-- recurse on attributes and other children elements -->
         <xsl:apply-templates select="@*|*[not(local-name() = 'cancel')]">
            <xsl:with-param name="fifths-offset" select="$fifths-offset"/>
         </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>
   
   <!--
      Change all <fifths> element
   -->
   <xsl:template match="fifths">
      <xsl:param name="fifths-offset"/>
      
      <!-- Compute the new <fifth> value -->
      <xsl:variable name="fifths-wrapped">
<!--         <xsl:variable name="fifths-unwrapped" select="number()+$fifths-offset"/>
         <xsl:choose>
            <xsl:when test="$fifths-unwrapped &gt; 5">
               <xsl:value-of select="$fifths-unwrapped - 12"/>
            </xsl:when>
            <xsl:when test="$fifths-unwrapped &lt; -6">
               <xsl:value-of select="$fifths-unwrapped + 12"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$fifths-unwrapped"/>
            </xsl:otherwise>
         </xsl:choose>-->
         <!-- one liner version -->
         <xsl:value-of select="number() + $fifths-offset"/> 
      </xsl:variable>
      
      <!-- write the new value -->
      <xsl:copy>
         <xsl:value-of select="$fifths-wrapped"/>
      </xsl:copy>
   </xsl:template>
   
   <!--
      Step 2. Change all <note> elements that have a <pitch> child
   -->
   <xsl:template match="note[pitch]" name="transposeNote">
      <xsl:param name="fifths-offset" select="0"/>
      <xsl:param name="octave-offset-base"/>
      <xsl:param name="transpositionDirection"/>
      
      <!--
         Compute pitch transposition.
      -->
      <!-- compute index of pitch -->
      <xsl:variable name="fifthsCycleIndex">
         <xsl:call-template name="getFifthsCycleIndex">
            <xsl:with-param name="step" select="pitch[1]/step/text()"/>
            <xsl:with-param name="alter" select="sum(pitch[1]/alter)"/>
         </xsl:call-template>
      </xsl:variable>
      <!-- Transpose pitch by applying 'fifths' offset -->
      <xsl:variable
         name="transposedPitchFifthsCycleIndex"
         select="floor(1 + (($fifthsCycleIndex + $fifths-offset - 1  + 35 * (($fifthsCycleIndex + $fifths-offset) &lt; 0)  ) mod 35))"
      />
      <!--
         <note>
      -->
      <xsl:copy>
         <!-- apply templates with original and transposed pitches as parameters -->
         <xsl:apply-templates select="@*|node()">
            <xsl:with-param name="fifthsCycleIndex" select="floor($fifthsCycleIndex)"/>
            <xsl:with-param name="transposedPitchFifthsCycleIndex" select="floor($transposedPitchFifthsCycleIndex)"/>
            <xsl:with-param name="octave-offset-base" select="$octave-offset-base"/>
            <xsl:with-param name="transpositionDirection" select="$transpositionDirection"/>
         </xsl:apply-templates>
      </xsl:copy>
   </xsl:template>
   
   <!--
      Step 2. b) Change <pitch> element
   -->
   <xsl:template match="pitch">
      <xsl:param name="fifthsCycleIndex"/>
      <xsl:param name="transposedPitchFifthsCycleIndex"/>
      <xsl:param name="octave-offset-base"/>
      <xsl:param name="transpositionDirection"/>
      <!--
         <pitch>
      -->
      <xsl:copy>
         <!-- 
            Copy all attributes
         -->
         <xsl:apply-templates select="@*|comment()|processing-instruction()"/>
         <!--
            <step>, <alter>
         -->
         <xsl:copy-of select="$fifthsCycle/pitch[$transposedPitchFifthsCycleIndex]/*"/>
         <!--
            <octave>
         -->
         <!-- compute change of octave induced by change of pitch -->
         <xsl:variable name="octave-offset">
            <xsl:variable name="basePitch"
               select="(4*(($fifthsCycleIndex - 1) mod 7) + 3) mod 7"/>
            <xsl:variable name="transposedBasePitch"
               select="(4*(($transposedPitchFifthsCycleIndex - 1) mod 7) + 3) mod 7"/>
            <xsl:choose>
               <xsl:when test="$transpositionDirection &lt; 0 and $basePitch &lt; $transposedBasePitch">
                  <xsl:value-of select="-1"/>
               </xsl:when>
               <xsl:when test="$transpositionDirection &gt; 0 and $basePitch &gt; $transposedBasePitch">
                  <xsl:number value="1"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:number value="0"/>
               </xsl:otherwise>
            </xsl:choose>
            <!-- one liner version -->
<!--            <xsl:number value="number($transpositionDirection &gt; 0 and $basePitch &gt; $transposedBasePitch) - number($transpositionDirection &lt; 0 and $basePitch &lt; $transposedBasePitch)"/>-->
         </xsl:variable>
         <!-- print transposed <octave> -->
         <octave>
            <xsl:value-of select="octave+floor($octave-offset)+$octave-offset-base"/>
         </octave>
      </xsl:copy>
   </xsl:template>
   
   <!--
      Step 2. c) Change <accidental> element
   -->
   <xsl:template match="accidental">
      <xsl:param name="transposedPitchFifthsCycleIndex"/>
      <!--
         <accidental>
      -->
      <xsl:copy>
         <!-- keep <accidental> attributes -->
         <xsl:copy-of select="@*"/>
         <!-- overwrite the new accidental value -->
         <xsl:value-of select="$accidentalsMusicXml/accidental[1+floor(($transposedPitchFifthsCycleIndex - 1) div 7)]"/>
      </xsl:copy>
   </xsl:template>
   
   <!-- UTILITIES -->
   <!--
      Convert pitch to its index in the 'fifthsCycle' array.
      Inputs are pitch 'step' and 'alter' values.
   -->
   <xsl:template name="getFifthsCycleIndex">
      <xsl:param name="step"/>
      <xsl:param name="alter" select="0"/>
      
      <!-- translate 'step' as base index -->
      <xsl:variable name="step-index">
         <xsl:choose>
            <xsl:when test="$step = 'F'">
               <xsl:number value="1"/>
            </xsl:when>
            <xsl:when test="$step = 'C'">
               <xsl:number value="2"/>
            </xsl:when>
            <xsl:when test="$step = 'G'">
               <xsl:number value="3"/>
            </xsl:when>
            <xsl:when test="$step = 'D'">
               <xsl:number value="4"/>
            </xsl:when>
            <xsl:when test="$step = 'A'">
               <xsl:number value="5"/>
            </xsl:when>
            <xsl:when test="$step = 'E'">
               <xsl:number value="6"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:number value="7"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      
      <!-- translate 'alter' as offset index-->
      <xsl:number value="$step-index + ($alter + 2)*7"/>
   </xsl:template>
   
   <!--
      Array of pitches sorted by fifths cycle from Fbb to B## 
   -->   
   <xsl:variable name="fifthsCycle" select="document('fifthsCycle.xml')/fifthsCycle"/>
   
   <!--
      Array of MusicXML <accidentals> elements
   -->
   <xsl:variable name="accidentalsMusicXml" select="document('accidentalsMusicXml.xml')/accidentals"/>
   
   <!--
      Convert semitones into fifths
   -->
   <xsl:template name="semitoneToFifth">
      <xsl:param name="semitones"/>
      
      <xsl:variable name="semitones-abs" select="$semitones * (1 - 2*($semitones &lt; 0))"/>
      
      <xsl:variable name="fifths-abs">
         <xsl:choose>
            <xsl:when test="$semitones-abs = 1">
               <xsl:value-of select="-5"/>
            </xsl:when>
            <xsl:when test="$semitones-abs = 2">
               <xsl:value-of select="2"/>
            </xsl:when>
            <xsl:when test="$semitones-abs = 3">
               <xsl:value-of select="-3"/>
            </xsl:when>
            <xsl:when test="$semitones-abs = 4">
               <xsl:value-of select="4"/>
            </xsl:when>
            <xsl:when test="$semitones-abs = 5">
               <xsl:value-of select="-1"/>
            </xsl:when>
            <xsl:when test="$semitones-abs = 6">
               <xsl:value-of select="6"/>
            </xsl:when>
            <xsl:when test="$semitones-abs = 7">
               <xsl:value-of select="1"/>
            </xsl:when>
            <xsl:when test="$semitones-abs = 8">
               <xsl:value-of select="-4"/>
            </xsl:when>
            <xsl:when test="$semitones-abs = 9">
               <xsl:value-of select="3"/>
            </xsl:when>
            <xsl:when test="$semitones-abs = 10">
               <xsl:value-of select="-2"/>
            </xsl:when>
            <xsl:when test="$semitones-abs = 11">
               <xsl:value-of select="5"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="0"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      
      <xsl:value-of select="(1-2*($semitones &lt; 0)) * $fifths-abs"/>
   </xsl:template>
</xsl:stylesheet>