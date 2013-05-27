# The DocPad Configuration File
# It is simply a CoffeeScript Object which is parsed by CSON
docpadConfig = {

	# =================================
	# Template Data
	# These are variables that will be accessible via our templates
	# To access one of these within our templates, refer to the FAQ: https://github.com/bevry/docpad/wiki/FAQ

	templateData:

		# Specify some site properties
		site:
			# The production url of our website
			url: "http://robbennet.com"

			# Here are some old site urls that you would like to redirect from
			oldUrls: [
				'www.robbennet.com',
				'robbennet.herokuapp.com'
			]

			# The default title of our website
			title: "Rob Bennet - Science, Technology and Web Engineering"

			# The website description (for SEO)
			description: """
				Thought snippets on physics, technology, innovation and web development.
				"""

			# The website keywords (for SEO) separated by commas
			keywords: """
				technology, physics, javascript, css, html5, node.js
				"""

			# The website author's name
			author: "Rob Bennet"

			# The website author's email
			email: "rob@madebyhoundstooth.com"

			# Styles
			styles: [
				"/assets/css/main.css"
			]

			# Scripts
			scripts: [
				"//cdnjs.cloudflare.com/ajax/libs/jquery/1.9.1/jquery.min.js",
				"//cdnjs.cloudflare.com/ajax/libs/modernizr/2.6.2/modernizr.min.js",
				"/assets/js/app.js"
			]

		paths:
			# Public Image URL
			img: "/assets/img"
			featured: "/assets/img/featured-images"
			specImgs: "/assets/img/site-specs"



		# -----------------------------
		# Helper Functions

		# Get the prepared site/document title
		# Often we would like to specify particular formatting to our page's title
		# we can apply that formatting here
		getPreparedTitle: ->
			# if we have a document title, then we should use that and suffix the site's title onto it
			if @document.title
				"#{@document.title} | #{@site.title}"
			# if our document does not have it's own title, then we should just use the site's title
			else
				@site.title

		# Get the prepared site/document description
		getPreparedDescription: ->
			# if we have a document description, then we should use that, otherwise use the site's description
			@document.description or @site.description

		# Get the prepared site/document keywords
		getPreparedKeywords: ->
			# Merge the document keywords with the site keywords
			@site.keywords.concat(@document.keywords or []).join(', ')

		# Get Gravatar URL
		getGravatarUrl: (email,size) ->
			hash = require('crypto').createHash('md5').update(email).digest('hex')
			url = "http://www.gravatar.com/avatar/#{hash}.jpg"
			if size then url += "?s=#{size}"
			return url

		# Get the current URL (used for Facebook comments)
		getCurrentUrl: ->
			host = document.location.host
			uri = @document.relativeBase
			return host + uri



	# =================================
	# Collections
	# These are special collections that our website makes available to us

	collections:
		pages: (database) ->
			database.findAllLive({pageOrder: $exists: true}, [pageOrder:1,title:1])

		articles: (database) ->
			database.findAllLive({relativeOutDirPath:'articles'},[date:-1])

		videos: (database) ->
			database.findAllLive({relativeOutDirPath:'videos'},[date:-1])

	# =================================
	# Plugins

	plugins:
		handlebars:
	        helpers:
	            # Expose docpads 'getBlock' function to handlebars
	            getBlock: (type, additional...) ->
	                additional.pop() # remove the hash object
	                @getBlock(type).add(additional).toHTML()
	        partials:
	            title: '<h1>{{document.title}}</h1>'
	            goUp: '<a href="#">Scroll up</a>'


	# =================================
	# DocPad Events

	# Here we can define handlers for events that DocPad fires
	# You can find a full listing of events on the DocPad Wiki
	events:

		# Server Extend
		# Used to add our own custom routes to the server before the docpad routes are added
		serverExtend: (opts) ->
			# Extract the server from the options
			{server} = opts
			docpad = @docpad

			# As we are now running in an event,
			# ensure we are using the latest copy of the docpad configuraiton
			# and fetch our urls from it
			latestConfig = docpad.getConfig()
			oldUrls = latestConfig.templateData.site.oldUrls or []
			newUrl = latestConfig.templateData.site.url

			# Redirect any requests accessing one of our sites oldUrls to the new site url
			server.use (req,res,next) ->
				if req.headers.host in oldUrls
					res.redirect(newUrl+req.url, 301)
				else
					next()
}


# Export our DocPad Configuration
module.exports = docpadConfig