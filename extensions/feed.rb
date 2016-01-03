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
