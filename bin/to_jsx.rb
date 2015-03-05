#!/usr/bin/env ruby

require 'rexml/document'
require 'optparse'

require 'to_jsx'

include REXML
include ToJSX


options = { :type => :react}

op = OptionParser.new do |opts|
	opts.banner = "Usage:  #{File.basename($PROGRAM_NAME)} [OPTIONS] FILE"
	
	opts.on( "-h", "--help", 
		"Show this message." ) {
		puts opts
		exit
	}

	opts.on("-o FILE", String,
		"Specify output file name") {|file|
		options[:output] = file
	}

	opts.on("-t", "--type TYPE", [:inline, :react, :jsx], 
		"Specify output type (inline, react, jsx)") {|arg|
		options[:type] = arg
	}
end

begin
	op.parse!
rescue OptionParser::ParseError => e
	puts e
	puts op
	exit 1
end


if ARGV.length > 1
	puts op
	exit 1
end


infilename = ARGV.first
infilename = nil if infilename == "-"
infile = infilename.nil? ? $stdin : File.new(infilename, "r")

outfilename = options[:output]
if infilename && !outfilename
	ext = case options[:type]
	when :jsx
		"jsx"
	else
		"js"
	end
	outfilename = infilename + "." + ext
end
outfilename = nil if outfilename == "-"
outfile = outfilename.nil? ? $stdout : File.new(outfilename, "w")


doc = Document.new(infile)



target = case options[:type]
when :jsx
	TargetJSX.new
when :inline
	TargetInline.new
when :react
	TargetReact.new
end

outfile.puts target.process(doc)

exit 0

