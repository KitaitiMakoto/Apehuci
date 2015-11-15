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

set :feed_uri, 'recent-days.atom'
class Feed < ::Middleman::Extension
  def initialize(app, option_hash={}, &block)
    super
    require 'rss'
  end

  def manipulate_resource_list(resources)
    feed = Middleman::Sitemap::StringResource.new(app.sitemap, app.config[:feed_uri]) {
      articles = app.sitemap.resources.select {|resource| resource.kind_of? Middleman::Blog::BlogArticle}
      RSS::Maker.make('atom') {|maker|
        maker.channel.id = maker.channel.link = app.data.site.uri
        maker.channel.title = app.data.site.title
        maker.channel.author = app.data.site.author
        maker.channel.links.new_link do |link|
          link.rel = 'self'
          link.href = app.data.site.uri + app.config[:feed_uri]
          link.type = 'application/atom+xml'
        end
        maker.channel.generator do |generator|
          generator.content = 'Middleman Blog'
          generator.uri = 'https://middlemanapp.com/'
          generator.version = Middleman::Blog::VERSION
        end
        maker.items.do_sort = true

        articles.each do |article|
          date = article.date.time
          maker.channel.updated =
            maker.channel.updated ? [maker.channel.updated, date].max : date

          maker.items.new_item do |entry|
            entry.id = app.data.site.uri + article.url[1..-1]
            entry.updated = date
            entry.title = article.title
            entry.content.type = 'html'
            entry.content.content = article.body
          end
        end
      }
    }

    resources + [feed]
  end
end
Middleman::Extensions.register :feed, Feed
activate :feed
