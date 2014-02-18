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

      gallery_dirs = Dir["#{site.source}/#{gallery_dir}/*/"].select { |e| File.directory? e }
      gallery_dirs.reverse! # in order to sort by date desc
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

    attr_accessor :url, :name, :slug, :date

    def initialize(site, base, gen_dir, gallery_dir, data={})
      self.content = data.delete('content') || ''
      self.data = data

      gallery_dir_name = File.basename gallery_dir
      super(site, base, gen_dir, gallery_dir_name)

      # load photos configuration
      photos_config_filepath =  "#{base}/#{site.config['gallery_dir']}/#{self.data['name']}.yml"
      photos_config = YAML.load(File.open(photos_config_filepath).read) if File.exists?(photos_config_filepath)

      # generating photos
      self.url = "/#{gen_dir}/#{self.data['slug']}.html" # gallery page url
      self.data['url'] = URI.escape self.url 

      # For each photo, initial attributes are `filename` and `url`
      photos = Dir["#{gallery_dir}/*"].map { |e| { filename: File.basename(e), url: URI.escape("/#{gen_dir}/#{gallery_dir_name}/#{File.basename e}") } } # basic photos attributes

      self.data['photos'] = [] # storing an array of Photo
      photos.each do |photo|
        photo_data = {}
        photo_data = photos_config.find { |e| e['filename'] == photo[:filename] } if photos_config
        self.data['photos'] << Photo.new(photo[:filename], photo[:url], photo_data)
      end

      # gallery page configuration
      if site.config[CONFIG_GALLERIES_ATTR]
        attr = site.config[CONFIG_GALLERIES_ATTR].find { |e| e['title'] == self.name}
        if attr
          attr.each { |k, v| self.data[k] = v }
        end
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

  class Photo
    attr_accessor :filename, :url, :data

    def initialize(filename, url, options=nil)
      self.filename = filename
      self.url = url
      self.data = options || {}
    end

    def to_liquid
      self.data.merge({ 'url' => self.url })
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
