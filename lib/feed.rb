class Feed < ::Middleman::Extension
  option :uri, 'feed.atom', 'Feed URI'

  def initialize(app, option_hash={}, &block)
    super
    require 'rss'
  end

  def manipulate_resource_list(resources)
    articles = app.extensions[:blog].values.flatten.map{|blog| blog.data.articles}.flatten
    feed_xml = RSS::Maker.make('atom') {|maker|
        maker.channel.id = maker.channel.link = app.data.site.uri
        maker.channel.title = app.data.site.title
        maker.channel.author = app.data.site.author
        maker.channel.links.new_link do |link|
          link.rel = 'self'
          link.href = app.data.site.uri + options.uri
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
            entry.links.new_link do |link|
              link.href = app.data.site.uri + article.destination_path
              link.type = 'text/html'
            end
          end
        end
      }
    feed = Middleman::Sitemap::StringResource.new(app.sitemap, options.uri, feed_xml)

    resources + [feed]
  end
end
Middleman::Extensions.register :feed, Feed
