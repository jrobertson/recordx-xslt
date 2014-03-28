# Introducing the Recordx-XSLT gem

    require 'recordx-xslt'

    recxslt = RecordxXSLT.new(schema: 'month[name]/week[no]/day[x,wday]', xslt_schema: 'table[caption:name]/tr/td[div:x,div,div:event]')
    puts recxslt.to_xslt

output:

<pre>
   ...

    <xsl:template match='month'>
      <table>
        <xsl:apply-templates select='summary'/>
      <\table>
    </xsl:template>  

    <xsl:template match='month/summary'>
        <caption><xsl:value-of select='name'/></caption>
    </xsl:template>

    <xsl:template match='records/week'>
      <tr>
        <xsl:apply-templates select='summary'/>
        <xsl:apply-templates select='records'/>
      <\tr>
    </xsl:template>

    <xsl:template match='week/summary'>
    </xsl:template>

    <xsl:template match='records/day'>
      <td>
        <xsl:apply-templates select='summary'/>
      <\td>
    </xsl:template>  

    <xsl:template match='day/summary'>
        <div><xsl:value-of select='x'/></div>
        <div><xsl:value-of select='div'/></div>
        <div><xsl:value-of select='event'/></div>
    </xsl:template>  

    </xsl:stylesheet>
</pre>

