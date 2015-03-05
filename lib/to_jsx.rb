require "html_to_jsx/version"
require "html_to_jsx/base"

module ToJSX

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


	ATTR_MAP = ATTRIBUTES.each_with_object({}) {|x, map| map[x.downcase] = x }



end