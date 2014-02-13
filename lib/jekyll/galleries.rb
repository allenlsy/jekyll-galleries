module Jekyll
  class GalleryGenerator < Generator
    attr_accessor :site, :gallery_dir, :gallery_layout, :galleries
    class << self; attr_accessor :site; end

    CONFIG_GALLERIES_ATTR = 'galleries'

    def generate(site)
      self.class.site = self.site = site
      self.gallery_dir = site.config['gallery_dir'] || 'galleries'
      self.gallery_layout = site.config['gallery_layout'] || 'gallery'

      # array of GalleryPage objects
      site.data['galleries'] = []

      # site.galleries = []
      gallery_dirs = Dir["#{site.source}/#{gallery_dir}/*/"].select { |e| File.directory? e }
      gallery_dirs.reverse! # sort by date desc
      gallery_dirs.each do |dir|
        generate_gallery_page(dir)
      end
    end

    private
    def generate_gallery_page(gallery_dir)
      data = { 'layout' => gallery_layout }

      page = GalleryPage.new(site, site.source, self.gallery_dir, gallery_dir, data)

      site.pages << page

      site.data['galleries'] << page
    end

  end

  class GalleryPage < Page
    # Valid post name regex.
    MATCHER = /^(\d+-\d+-\d+)-(.*)$/
    CONFIG_GALLERIES_ATTR = 'galleries'

    attr_accessor :site, :url, :name, :slug, :date

    def initialize(site, base, gen_dir, dir, data={})
      self.content = data.delete('content') || ''
      self.data = data

      dir_name = File.basename dir
      super(site, base, gen_dir, dir_name )

      # url, photos
      self.url = "/#{gen_dir}/#{self.data['slug']}.html"
      self.data['url'] = URI.escape self.url
      self.data['photo_urls'] = Dir["#{base}/#{gen_dir}/#{dir_name}/*"].map { |e| URI.escape("/#{gen_dir}/#{dir_name}/#{File.basename e}") }

      if site.config[CONFIG_GALLERIES_ATTR]
        attr = site.config[CONFIG_GALLERIES_ATTR].find { |e| e['title'] == self.name}
        if attr
          attr.each { |k, v| self.data[k] = v }
        end
        # self.data['excerpt'] = attr['excerpt'] if attr
      end
    end

    def read_yaml(*)
    end

    # Extract information from the post filename.
    #
    # name - The String filename of the post file.
    #
    # Returns nothing.
    def process(name)
      m, date, name = *name.match(MATCHER)

      # self.data['date'] = Time.parse(date)
      self.data['date'] = self.date = date
      self.data['name'] = self.name = name
      self.data['slug'] = self.slug = name.gsub(/[^0-9a-z ]/i, '').downcase.gsub(/ /, '-')
    rescue ArgumentError
      raise FatalException.new("Gallery #{name} does not have a valid date.")
    end
  end

  class YamlToLiquid < Liquid::Tag
    def initialize(tag_name, arg, tokens)
      super

      if arg.length == 0
        raise 'Please enter a yaml file path'
      else
        @yml_path = arg
      end
    end

    def render(context)

      yml = YAML::load(File.read(@yml_path))
      context.registers[:page]['yml'] = yml
    end
  end
end

Liquid::Template.register_tag('yaml_to_liquid', Jekyll::YamlToLiquid)

