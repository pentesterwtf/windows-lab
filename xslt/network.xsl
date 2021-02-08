<?xml version="1.0" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output omit-xml-declaration="yes" indent="yes"/>

  <xsl:template match="node()|@*">
     <xsl:copy>
       <xsl:apply-templates select="node()|@*"/>
     </xsl:copy>
  </xsl:template>

  <xsl:template match="/network/ip/dhcp/range">
    <xsl:copy>
      <xsl:apply-templates select="@* | *"/>
    </xsl:copy>
      <xsl:element name="host">
	      <xsl:attribute name="mac">AA:BB:CC:11:22:22</xsl:attribute>
	      <xsl:attribute name="name">DC</xsl:attribute>
              <xsl:attribute name="ip">10.0.10.100</xsl:attribute>
       </xsl:element>
  </xsl:template>
</xsl:stylesheet>
