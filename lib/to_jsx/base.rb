require 'rexml/document'

module ToJSX


	class Base

		def initialize()
		end

		def camelCase(x)
			x.gsub(/-([a-z])/) {|m| m[1].upcase }
		end

		def rename_attr(x)

			case x
			when /^(data|aria)-/
				return x
			when 'for'
				return 'htmlFor'
			when 'class'
				return 'className'
				
			else
				nodash = x.tr('-','')
				return ATTR_MAP[nodash] if ATTR_MAP[nodash]
				return x
			end

		end

		def trim_ws(x)

			# remove leading cr/lf (and any whitespace following)
			x.gsub!(/^[\r\n][\r\n\t ]*/, '')

			# remove trailing cr/lf (and any whitespace preceeding)
			x.gsub!(/^[\r\n\t ]*[\r\n]$/, '')

			# collapse any whitespace
			x.gsub!(/[\r\n\t ]+/, ' ')

			return x
		end

		def style_to_hash(x)
			# parse a style string into a hash.
			# "color: red; ..." -> { 'color': 'red'}
			# could have ; within a string? should be escaped.

			rv = {}
			array = x.split(';')
			array.each {|tmp| 
				name, value = tmp.split(':',2)
				name.strip!
				value.strip!
				name = camelCase(name)

				rv[name] = value
			}
			return rv
		end



		def process(e)
			child = case e
			when REXML::Document
				e.first
			else
				e
			end
			one_node(child)
		end

		def one_text(e)
		end

		def one_comment(e)
		end

		def one_element(e)
			e.each {|child| one_node(e)}
		end

		def one_node(e)
			case e
			when REXML::Text
				one_text(e)
			when REXML::Element
				one_element(e)
			when REXML::Comment
				one_comment(e)
			else
				raise e.Class
			end
		end


	end


end