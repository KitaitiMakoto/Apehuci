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
# configure :development do
#   activate :livereload
# end

set :components_dir, 'components'
# Methods defined in the helpers block are available in templates
helpers do
  def component_import_tag(*sources)
    options = {
      rel: 'import'
    }.update(sources.extract_options!.symbolize_keys)
    sources.flatten.inject(ActiveSupport::SafeBuffer.new) do |all, source|
      components_dir = app.config[:components_dir] || 'components'
      url = url_for(File.join(components_dir, "#{source}.html"))
      all << tag(:link, {href: url}.update(options))
    end
  end
end

# Build-specific configuration
configure :build do
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

activate :blog do |blog|
  blog.sources = '{year}-{month}-{day}.html'
  blog.permalink = '{year}/{month}/{day}.html'
  blog.layout = 'blog'
end

activate :deploy do |deploy|
  deploy.deploy_method = :git
  deploy.remote = 'github'
end

class Vulcanize < Middleman::Extension
  def initialize(app, options={}, &block)
    super
    app.after_build do |builder|
      command = 'cd source && vulcanize -o ../build/components/elements.vulcanized.html components/elements.html'
      $stderr.puts "run: #{command}"
      $stderr.puts `#{command}`
    end
  end
end

::Middleman::Extensions.register :vulcanize, Vulcanize
