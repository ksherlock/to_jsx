#!/usr/bin/env ruby

require 'rexml/document'
require 'to_jsx'

include REXML
include ToJSX


file = File.new('../test.html')

doc = Document.new(file)

visitor = TargetJSX.new
puts visitor.process(doc)


visitor = TargetInline.new
puts visitor.process(doc)

visitor = TargetReact.new
puts visitor.process(doc)

exit 0