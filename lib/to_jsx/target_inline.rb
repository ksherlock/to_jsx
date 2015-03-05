require 'json'
require 'htmlentities'

class Visitor


	EVENTS = %w{
	onClick onDoubleClick onDrag onDragEnd onDragEnter onDragExit onDragLeave
	onDragOver onDragStart onDrop onMouseDown onMouseEnter onMouseLeave
	onMouseMove onMouseOut onMouseOver onMouseUp
	onCopy onCut onPaste
	onKeyDown onKeyPress onKeyUp
	onFocus onBlur
	onChange onInput onSubmit
	onClick onDoubleClick onDrag onDragEnd onDragEnter onDragExit onDragLeave
	onDragOver onDragStart onDrop onMouseDown onMouseEnter onMouseLeave
	onMouseMove onMouseOut onMouseOver onMouseUp
	onTouchCancel onTouchEnd onTouchMove onTouchStart
	onScroll
	onWheel
	}

	TAGS = %w{
	a abbr address area article aside audio b base bdi bdo big blockquote body br
	button canvas caption cite code col colgroup data datalist dd del details dfn
	dialog div dl dt em embed fieldset figcaption figure footer form h1 h2 h3 h4 h5
	h6 head header hr html i iframe img input ins kbd keygen label legend li link
	main map mark menu menuitem meta meter nav noscript object ol optgroup option
	output p param picture pre progress q rp rt ruby s samp script section select
	small source span strong style sub summary sup table tbody td textarea tfoot th
	thead time title tr track u ul var video wbr

	circle defs ellipse g line linearGradient mask path pattern polygon polyline
	radialGradient rect stop svg text tspan
	}

	ATTRIBUTES = %w{
	accept acceptCharset accessKey action allowFullScreen allowTransparency alt
	async autoComplete autoPlay cellPadding cellSpacing charSet checked classID
	className cols colSpan content contentEditable contextMenu controls coords
	crossOrigin data dateTime defer dir disabled download draggable encType form
	formAction formEncType formMethod formNoValidate formTarget frameBorder height
	hidden href hrefLang htmlFor httpEquiv icon id label lang list loop manifest
	marginHeight marginWidth max maxLength media mediaGroup method min multiple
	muted name noValidate open pattern placeholder poster preload radioGroup
	readOnly rel required role rows rowSpan sandbox scope scrolling seamless
	selected shape size sizes span spellCheck src srcDoc srcSet start step style
	tabIndex target title type useMap value width wmode

	autoCapitalize autoCorrect 
	property
	itemProp itemScope itemType

	cx cy d dx dy fill fillOpacity fontFamily fontSize fx fy gradientTransform
	gradientUnits markerEnd markerMid markerStart offset opacity
	patternContentUnits patternUnits points preserveAspectRatio r rx ry
	spreadMethod stopColor stopOpacity stroke strokeDasharray strokeLinecap
	strokeOpacity strokeWidth textAnchor transform version viewBox x1 x2 x y1 y2 y
	}


	def initialize()
		@attr_map = {}
		ATTRIBUTES.each{|x| @attr_map[x.downcase] = x }
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
			return @attr_map[nodash] if @attr_map[nodash]
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
		when Text
			one_text(e)
		when Element
			one_element(e)
		when Comment
			one_comment(e)
		else
			raise e.Class
		end
	end


end

class TargetInline < Visitor
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

class TargetJSX < Visitor

	def initialize()
		super
	end

	def q(x)
		"\"#{x}\""
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
		""
	end

	def one_text(e)
		# todo -- need to escape '{' characters.
		text = e.value
		text.gsub!(/([{}])/, '{ "\1" }')
		return text
	end


end



class TargetReact < Visitor

	def initialize()
		super
		@indent = 0
		@h = HTMLEntities.new()
	end

	def q(x)
		'"' + x.to_s + '"'
	end

	def one_element(e)

		rv = 'React.createElement('
		rv <<  q(e.name) << ", "

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
		rv << attr.to_json

		children = []
		e.each { |child| 
			children.push(one_node(child))
		}

		children.flatten!
		children.reject! {|x| x == nil }

		unless children.empty?
			rv << ", "
			rv << children.join(", ")
		end

		rv << ")"
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
