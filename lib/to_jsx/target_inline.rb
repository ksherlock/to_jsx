require 'json'
require 'htmlentities'

module ToJSX

	class TargetInline < Base
		def initialize()
			super

			@h = HTMLEntities.new()
		end
		

		def process(e)
			JSON.pretty_generate(super(e))
		end


		def one_text(e)

			text = trim_ws(e.value)
			return nil if text.empty?
			return @h.decode(text)

		end

		def one_comment(e)
			return nil
		end

		def one_element(e)

			rv = {}
			props = {}
			children = []

			rv['type'] = e.name

			e.attributes.each {|k, v|

				k = rename_attr(k)
				case k
				when 'style'
					props[k] = style_to_hash(v)
				else
					props[k] = v
				end
			}

			children = []
			e.each {|child|

				children.push(one_node(child))
			}

			children.flatten!
			children.reject! {|x| x == nil }

			props['children'] = children

			rv['props'] = props
			return rv
		end

		
	end

end