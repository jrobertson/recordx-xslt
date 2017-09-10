#!/usr/bin/env ruby

# file: recordx-xslt.rb

class RecordxXSLT
  
  attr_accessor :schema, :xslt_schema

  def initialize(options={})
    o = {schema: '', xslt_schema: ''}.merge(options)
    @schema, @xslt_schema = o.values
  end

  def to_xslt()

header =<<HEADER
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml" indent="yes" />

HEADER

    a_element = @schema.split('/').map{|x| x[/\w+/]}
    
    @xslt_schema = build_xslt_schema(@schema) if @xslt_schema.empty?

    a_html = @xslt_schema.split('/').map do |x|

      result = x.match(/(\w+)(?:[\(\[]([^\]\)]+)[\]\)])?(.*)/)
      name, children, remaining = result.captures if result


      list = children.split(/ *, */).map {|y| y.split(':',2)} if children        

      [name, list]
    end

    a = a_element.zip(a_html).map.with_index do |a,i|

      out = []
      tag = a.shift
      field = i > 0 ? 'records/' + tag : tag
      out << "<xsl:template match='#{field}'>" + "\n"
      a.flatten!(1)
      if a.last.is_a? Array then

        out << scan_e(a, tag) 
        out << "</xsl:template>\n\n"
      else
        out << "  <%s>\n" % a.first
        out << "    <xsl:apply-templates select='summary'/>\n"
        out << "    <xsl:apply-templates select='records'/>\n"
        out << "  </%s>\n" % a.first
        out << "</xsl:template>\n\n"
        out << "<xsl:template match='%s/summary'>\n" % [tag]
        out << "</xsl:template>\n\n"
      end
      
      out
    end

    header + a.flatten.join + "</xsl:stylesheet>"
  end

  private
  
  def build_xslt_schema(schema)

    schema.split('/').map do |row|

      head, body = row.split('[',2)
      fields = body[/.*(?=\])/].split(/ *, */)
      "%s[%s]" % [head + '2', fields.map{|x| x + '2'}.join(', ')]
      
    end.join('/')    
    
  end

  def scan_e(a, prev_tag='', indent='  ')

    out = []

    unless a.first.is_a? Array then
      
      tag = a.shift

      out << indent + "<%s>\n" % tag
      out << indent + "  <xsl:apply-templates select='summary'/>\n"
      out << indent + "</%s>\n" % tag
      out << "</xsl:template>\n\n"
      out << "<xsl:template match='%s/summary'>\n" % [prev_tag]

      a.flatten!(1)
      
      if a.last.is_a? Array then
        out << scan_e(a, tag, indent + '  ') 
      else
        out << indent + '  ' + a.first + "\n"
      end

    else
      a.map do |target,src|

        if src then
          
          start_tag = target.gsub(/\s*\{[^\}]+\}/) do |attr| 

            ' ' + attr.scan(/(\w+[:=]\s*(?:\w+|["'][^"']+["'])),?\s*/)\
            .map {|x| x.first.split(/\s*[:=]\s*/) }\
            .map {|attr, val| "%s='%s'" % [attr,val.gsub(/^["']|["']$/,'')]}\
            .join(', ')
          end
          
          end_tag = target.gsub(/\s*{.*/,'')           

          out << indent + "<%s><xsl:value-of select='%s'/></%s>\n" % 
                                                [start_tag,src,end_tag]
        else
          out << indent + "<%s></%s>\n" % ([target] * 2)
        end
      end
    end

    out
  end
  
end