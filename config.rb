###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
#
# With no layout
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# With alternative layout
# page "/path/to/file.html", layout: :otherlayout

# Proxy pages (http://middlemanapp.com/basics/dynamic-pages/)
# proxy "/this-page-has-no-template.html", "/template-file.html", locals: {
#  which_fake_page: "Rendering a fake page with a local variable" }

###
# Helpers
###

activate :relative_assets
set :relative_links, true

set :markdown, 'syntax_highlighter' => 'rouge'

# Reload the browser automatically whenever files change
configure :development do
#   activate :livereload
  set :component_suffix, '.html'
end

set :components_dir, 'components'
# Methods defined in the helpers block are available in templates
# helpers do
# end

# Build-specific configuration
configure :build do
  set :component_suffix, '.vulcanized.html'

  ignore /\Abower_components/

  # Minify CSS on build
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  activate :asset_hash

  activate :minify_html do |html|
    html.remove_intertag_spaces = true
    html.simple_doctype = true
    html.remove_form_attributes = true
    html.remove_quotes = true
  end
end

activate :web_component

activate :blog do |blog|
  blog.sources = '{year}-{month}-{day}.html'
  blog.permalink = '{year}/{month}/{day}.html'
  blog.layout = 'blog'
end

activate :deploy do |deploy|
  deploy.deploy_method = :git
  deploy.remote = 'github'
end
