###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false
page '/*.atom', layout: false

# With alternative layout
# page "/path/to/file.html", layout: :otherlayout

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

###
# Helpers
###
helpers do
  include Erubis::XmlHelper

  def encode_url_path_segments(path)
    path.split('/').map {|segment| url_encode(segment)}.join('/')
  end
  alias upath encode_url_path_segments
end

activate :relative_assets
set :relative_links, true

set :markdown, 'syntax_highlighter' => 'rouge'

# Reload the browser automatically whenever files change
configure :development do
#   activate :livereload
end

# Methods defined in the helpers block are available in templates
# helpers do
# end

# Build-specific configuration
configure :build do
  used_bower_components = %w[
    webcomponentsjs/webcomponents.min.js
  ]

  ignore do |path|
    ignored = true
    ignored = false unless path.start_with? 'bower_components/'
    used_bower_components.each do |used_file|
      ignored = false if path == File.join('bower_components', used_file)
    end

    ignored
  end

  # Minify CSS on build
  activate :minify_css do |css|
    css.ignore = /"#{used_bower_components.join('|')}/
  end

  # Minify Javascript on build
  activate :minify_javascript do |js|
    js.ignore = /"#{used_bower_components.join('|')}/
  end

  activate :asset_hash do |asset|
    asset.ignore = /\Abower_components\//
  end

  activate :minify_html do |html|
    html.remove_intertag_spaces = true
    html.simple_doctype = true
    html.remove_form_attributes = true
    html.remove_quotes = true
  end
end

activate :web_components

activate :blog do |blog|
  Time.zone = 'Tokyo'
  blog.sources = '{year}-{month}-{day}.html'
  blog.permalink = '{year}/{month}/{day}.html'
  blog.layout = 'blog'
  blog.tag_template = 'tag.html'
end

activate :deploy do |deploy|
  deploy.deploy_method = :git
end

require_relative 'extensions/feed'
set :feed_uri, 'recent-days.atom'
activate :feed
