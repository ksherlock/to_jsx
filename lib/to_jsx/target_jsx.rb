module ToJSX


	class TargetJSX < Base

		def initialize()
			super
		end

		def q(x)
			'"' + x.to_x + '"'
		end

		def style(x)

			tmp = style_to_hash(x)
			rv = []
			tmp.each{|k,v|
				rv.push("#{k}=#{q(v)}")
			}

			return "{{#{rv.join(', ')}}}"
		end

		def one_element(e)

			rv = ''
			rv =  "<#{e.name}"

			if e.has_attributes?
				e.attributes.each {|k, v|
					k = rename_attr(k)
					case k
					when 'style'
						rv << " #{k}=#{style(v)}"
					else
						rv << " #{k}=#{q(v)}"
					end
				}
			end

			if e.has_elements? || e.has_text?
				rv << ">"
				e.each { |child| 
					tmp = one_node(child)
					rv << tmp unless tmp.nil?
				}
				rv << "</#{e.name}>"
			else
				rv << "/>"
			end
		end

		def one_comment(e)
			nil
		end

		def one_text(e)
			# need to escape '{' characters.
			text = e.value
			text.gsub!(/([{}])/, '{ "\1" }')
			return text
		end


	end



end