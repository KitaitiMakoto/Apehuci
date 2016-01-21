class AMP < ::Middleman::Extension
  option :layout, 'layout', 'AMP-specific layout'

  def manipulate_resource_list(resources)
    amp_resources = resources.lazy.select {|resource|
      need_amp?(resource)
    }.map {|resource|
      amp = resource.dup
      amp.extend Middleman::Blog::BlogArticle
      amp.destination_path = sub_ext(resource.destination_path, '.amp.html')
      layout = options.layout
      amp.singleton_class.class_eval do
        define_method :render, ->(opts={}, locs={}, &block) {
          unless opts.has_key? :layout
            opts[:layout] = metadata[:options][:layout]
            opts[:layout] = layout if opts[:layout].nil?
            opts[:layout] = opts[:layout].to_s if opts[:layout].kind_of? Symbol
          end
          super(opts, locs, &block)
        }
      end

      amp
    }.to_a

    resources + amp_resources
  end

  private

  def need_amp?(resource)
    (! resource.ignored?) &&
      resource.kind_of?(Middleman::Blog::BlogArticle) &&
      (app.environment === :development || resource.published?)
  end

  def sub_ext(path, ext)
    Pathname(path).sub_ext(ext).to_path
  end
end
Middleman::Extensions.register :amp, AMP
