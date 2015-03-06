#!/usr/bin/env ruby

require 'rexml/document'
require 'optparse'

require 'to_jsx'

include REXML
include ToJSX


options = { :type => :react, :export => :none}

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

	opts.on("--id ID", String,
		"Only export HTML element with specific ID") {|arg|
		options[:xpath] = "*[@id='#{arg}']"
	}

	opts.on("--xpath XPATH", String,
		"Only export first HTML element matching XPATH") {|arg|
		options[:xpath] = arg
	}

	opts.on("-e", "--export METHOD", [:cjs, :es6, :none],
		"Specify export method (cjs, es6, none") {|arg|
		options[:export] = arg
	}

	opts.on("-c", "--class NAME", String,
		"Specify React class name") {|arg|
		options[:class] = arg
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

root = nil

if options[:xpath]
	root = XPath.first(doc, options[:xpath])
else
	root = doc.first {|e| REXML::Element === e }
end

if root.nil?
	puts "Unable to find root node"
	exit(1)
end

target = case options[:type]
when :jsx
	TargetJSX.new
when :inline
	TargetInline.new
when :react
	TargetReact.new
end

# add front-matter
outfile.puts target.process(root)

#add back matter

exit 0

