#!/usr/bin/env ruby

# file: recordx-xslt.rb

require 'c32'


class RecordxXSLT
  using ColouredText
  
  attr_accessor :schema, :xslt_schema

  def initialize(schema: '', xslt_schema: '', debug: false)
    
    @schema, @xslt_schema, @debug = schema, xslt_schema, debug
    
  end

  def to_xslt()

header =<<HEADER
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="xml" indent="yes" />

HEADER

    a_element = @schema.split('/').map{|x| x[/\w+/]}
    
    @xslt_schema = build_xslt_schema(@schema) if @xslt_schema.empty?
    puts ('@xslt_schema: ' + @xslt_schema.inspect).debug if @debug

    a_html = @xslt_schema.split('/').map do |x|

      result = x.match(/([\w\>]+)(?:[\(\[]([^\]\)]+)[\]\)])?(.*)/)
      name, children, remaining = result.captures if result


      list = children.split(/ *, */).map {|y| y.split(':',2)} if children        

      [name, list]
    end
    
    puts ('a_html: ' + a_html.inspect).debug if @debug

    rxmap = a_element.zip(a_html)
    
    a = rxmap.map.with_index do |a,i|

      out = []
      tag = a.shift
      puts 'tag: ' + tag.inspect if @debug
      
      field = i > 0 ? 'records/' + tag : tag
      out << "<xsl:template match='#{field}'>" + "\n"
      a.flatten!(1)
      puts 'a: ' + a.inspect if @debug
      
      if a.last.is_a? Array then

        if @debug then
          puts 'before scan_e a: ' + a.inspect
          puts 'before scan_e rxmap: ' + rxmap.inspect
          puts 'before scan_e rxmap[i+1]: ' + rxmap[i+1].inspect 
        end
        
        if rxmap[i+1] and rxmap[i+1][1][0] =~ />/ then
          
          raw_body, rxtag = rxmap[i+1][1][0].split(/>/,2)
          body = ["<%s>" % raw_body,"</%s>" % raw_body]
          
          puts 'body: ' + body.inspect if @debug
          rxmap[i+1][1][0] = rxtag
        else
          body = []
        end
        
        out << scan_e(a, tag, indent='  ', body) 
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
      "%s[%s]" % [head + '2', fields\
                  .map{|x| [x + '2', x].join(':')}.join(', ')]
      
    end.join('/')    
    
  end

  def scan_e(a, prev_tag='', indent='  ', body=[])

    out = []

    unless a.first.is_a? Array then
      
      raw_tags = a.shift
      
      tags = raw_tags.split('>')
      start_tags = tags.map {|x| "<%s>" % x }.join
      end_tags = tags.reverse.map {|x| "</%s>" % x }
      puts 'end_tags: ' + end_tags.inspect if @debug
      puts 'body: ' + body.inspect if @debug
      
      if body.any? then
        end_tags.insert(-2, body[0])
        end_tags[-1][0] = body[-1] #+ end_tags.last
      end
      puts '2. end_tags: ' + end_tags.inspect if @debug

      puts 'prev_tag: ' + prev_tag.inspect if @debug
      puts '_a: ' + a.inspect if @debug
      
      out << indent + "%s\n" % start_tags
      out << indent + "  <xsl:apply-templates select='summary'/>\n"
      out << indent + "%s\n" % end_tags[0..-2].join if end_tags.length > 1
      out << indent + "  <xsl:apply-templates select='records'/>\n"      
      out << indent + "%s\n" % end_tags[-1]
      out << "</xsl:template>\n\n"
      out << "<xsl:template match='%s/summary'>\n" % [prev_tag]

      a.flatten!(1)
      
      if a.last.is_a? Array then
        out << scan_e(a, tags.last, indent + '  ') 
      else
        out << indent + '  ' + a.first + "\n"
      end

    else
      a.map do |target,src|
        
        if @debug then
          puts 'target: ' + target.inspect
          puts 'src: ' + src.inspect
        end

        if src then
          
          if target[0] == '@' then
            
            target.slice!(0,1) 
            out << indent + "<xsl:attribute name='#{target}'>" + 
                "<xsl:value-of select='#{src}'/></xsl:attribute>\n"
          else
            
            start_tag = target.gsub(/\s*\{[^\}]+\}/) do |attr| 

              ' ' + attr.scan(/(\w+[:=]\s*(?:\w+|["'][^"']+["'])),?\s*/)\
              .map {|x| x.first.split(/\s*[:=]\s*/) }\
              .map {|attr, val| "%s='%s'" % [attr,val.gsub(/^["']|["']$/,'')]}\
              .join(', ')
            end
            
            end_tag = target.gsub(/\s*{.*/,'')           

            out << indent + "<%s><xsl:value-of select='%s'/></%s>\n" % 
                                                  [start_tag,src,end_tag]
          end
          
        else
          out << indent + "<%s></%s>\n" % ([target] * 2)
        end
      end
    end

    out
  end
  
end
