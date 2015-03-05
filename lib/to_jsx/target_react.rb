require 'json'
require 'htmlentities'

module ToJSX

	class TargetReact < Base

		def initialize()
			super
			@indent = 0
			@h = HTMLEntities.new()
		end

		def q(x)
			'"' + x.to_s + '"'
		end

		def one_element(e)


			# React.creatElement will be indented by parent.
			rv = "React.createElement(\n"

			@indent = @indent + 1
			indent = " " * (@indent * 2)

			rv <<  indent + q(e.name) << ",\n"

			attr = {}

			e.attributes.each {|k, v|
				k = rename_attr(k)
				case k
				when 'style'
					attr[k] = style_to_hash(v)
				else
					attr[k] = v
				end
			}

			attr = nil if attr.empty?

			# JSON.generate doesn't work with null or strings.
			rv << indent + attr.to_json

			children = []
			e.each { |child| 
				children.push(one_node(child))
			}

			children.flatten!
			children.reject! {|x| x == nil }

			unless children.empty?
				rv << ",\n" + indent
				rv << children.join(",\n" + indent)
			end

			@indent -= 1
			indent = " " * (@indent * 2)
			rv << "\n" + indent + ")"


			rv << ";\n" if @indent == 0

			return rv
		end

		def one_comment(e)
			nil
		end

		def one_text(e)
			text = trim_ws(e.value)

			return nil if text.empty?
			return @h.decode(text).to_json
		end


	end

end