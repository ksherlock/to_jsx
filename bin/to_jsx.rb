#!/usr/bin/env ruby

require 'rexml/document'
include REXML

require 'html_to_jsx'


file = File.new('../test.html')

doc = Document.new(file)

visitor = ToJSX::TargetJSX.new
puts visitor.process(doc)


visitor = ToJSX::TargetInline.new
puts visitor.process(doc)

visitor = ToJSX::TargetReact.new
puts visitor.process(doc)

exit 0