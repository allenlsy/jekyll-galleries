module Jekyll
  class GalleryGenerator < Generator
    attr_accessor :site, :gallery_dir, :gallery_layout
    class << self; attr_accessor :site; end

    def generate(site)
      self.class.site = self.site = site
      self.gallery_dir = site.config['gallery_dir'] || 'galleries'
      self.gallery_layout = site.config['gallery_layout'] || 'gallery'

      # array of GalleryPage objects
      site.data['galleries'] = []
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

    attr_accessor :site, :url, :name, :slug

    def initialize(site, base, gen_dir, dir, data={})
      self.content = data.delete('content') || ''
      self.data = data

      super(site, base, gen_dir, File.basename(dir) )

      # url, photos
      self.url = "/#{gen_dir}/#{self.data['slug']}.html"
      self.data['url'] = URI.escape self.url
      self.data['photo_urls'] = Dir["#{base}/#{gen_dir}/#{self.name}/*"].map { |e| URI.escape("/#{gen_dir}/#{self.name}/#{File.basename e}") }
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
      self.data['date'] = date
      self.data['name'] = name
      self.data['slug'] = name
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

