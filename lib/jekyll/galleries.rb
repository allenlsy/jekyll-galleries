require 'RMagick'
require 'exifr'
include Magick
include FileUtils

module Jekyll
  class GalleryGenerator < Generator
    attr_accessor :site
    attr_accessor :gallery_dir # directory for storing galleries. Default value is `galleries`
    attr_accessor :gallery_layout # layout file for gallery. Default value is `gallery`
    attr_accessor :galleries
    attr_accessor :gallery_pages
    attr_accessor :top_gallery_pages # GalleryPage array of topped galleries

    class << self; attr_accessor :site; end

    def generate(site)
      self.class.site = self.site = site
      self.gallery_dir = site.config['gallery_dir'] || 'galleries'
      self.gallery_layout = site.config['gallery_layout'] || 'gallery'
      self.gallery_pages = []
      self.top_gallery_pages = []

      # array of GalleryPage objects
      site.data['galleries'] = []

      gallery_dirs = Dir["#{site.source}/#{gallery_dir}/*/"].select { |e| File.directory? e }
      gallery_dirs.each do |dir|
        generate_gallery_page(dir)
      end

      # ordering the Page generation
      site.pages << self.top_gallery_pages
      site.pages << self.gallery_pages
      site.pages.flatten!

      # ordering galleries on gallery index page
      site.data['galleries'] << self.top_gallery_pages
      site.data['galleries'] << self.gallery_pages.reverse!
      site.data['galleries'].flatten!

    end

    private
    def generate_gallery_page(gallery_dir)
      data = { 'layout' => gallery_layout }

      page = GalleryPage.new(site, site.source, self.gallery_dir, gallery_dir, data)

      pages_queue = page.top? ? top_gallery_pages : gallery_pages # decide the queue that current page should be put into
      pages_queue << page
    end
  end

  class GalleryPage < Page
    # Valid post name regex.
    MATCHER = /^(\d+-\d+-\d+)-(.*)$/
    CONFIG_GALLERIES_ATTR = 'galleries'
    attr_accessor :url, :name, :slug, :date, :base
    attr_accessor :gen_dir # path that this gallery will be generated into
    attr_accessor :gallery_dir # the original path of the this gallery on local
    attr_accessor :gallery_dir_name # the name of this gallery dir
    attr_accessor :thumbs_dir # path of thumbnails dir

    def initialize(site, base, gen_dir, gallery_dir, data={})
      # preparation
      @base = base
      @site = site
      self.gen_dir = gen_dir
      self.gallery_dir = gallery_dir
      self.content = data.delete('content') || ''
      self.data = data
      self.thumbs_dir = site.config['thumbnails_dir']

      self.gallery_dir_name = File.basename gallery_dir
      super(site, base, gen_dir, self.gallery_dir_name)

      # ---
      generate_photos

    end

    def generate_photos
      photos_config_filepath = "#{@base}/#{@site.config['gallery_dir']}/#{self.date}-#{self.name}.yml"
      photos_config = YAML.load(File.open(photos_config_filepath).read) if File.exists?(photos_config_filepath) # config of this gallery

      # generating photos
      self.url = "/#{self.gen_dir}/#{self.gallery_dir_name}/index.html" # gallery page url
      self.data['url'] = URI.escape self.url

      # For each photo, initial attributes are `filename` and `url`
      photos = Dir["#{self.gallery_dir}/*"].map { |e| { file: File.new(e), filename: File.basename(e), url: URI.escape("/#{self.gen_dir}/#{self.gallery_dir_name}/#{File.basename e}") } } # basic photos attributes

      self.data['photos'] = [] # storing an array of Photo
      photos.each do |photo|
        photo_data = photos_config.find { |e| e['filename'] == photo[:filename] } if photos_config
        photo_data ||= {}
        begin
          photo_data['date'] = EXIFR::JPEG.new(photo[:file].path).date_time.strftime("%F %R")
        rescue
          puts "#{photo[:file].path}: cannot load date"
        end

        self.data['photos'] << Photo.new(@site, photo[:filename], self, photo_data)
      end

      # gallery page configuration
      if @site.config[CONFIG_GALLERIES_ATTR]
        attr = @site.config[CONFIG_GALLERIES_ATTR].find { |e| e['name'] == self.name }
        if attr
          attr.each { |k, v| self.data[k] = v }
        end
      end

      # generating gallery cover thumbnail
      if self.data['thumbnail']
        self.data['thumbnail'] = URI.escape("/#{self.gen_dir}/#{self.gallery_dir_name}/#{self.data['thumbnail']}")
      end
    end


    def top?
      self.data['top'] and self.data['top'] == true
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
    attr_accessor :filename, :url, :data, :thumbnail_url

    def initialize(site, filename, gallery, options=nil)
      @site = site
      @gallery = gallery
      self.data = options || {}
      self.data['url'] = URI.escape("/#{gallery.gen_dir}/#{gallery.gallery_dir_name}/#{filename}")
      self.data['filename'] = filename
      self.filename = filename

      @thumbs_dir = site.config['thumbnails_dir']
      generate_thumbnails if @thumbs_dir

    end

    def to_liquid
      self.data
    end

    def generate_thumbnails
      size_x = @site.config['thumbnail_x'] || 100
      size_y = @site.config['thumbnail_y'] || 100

      full_thumbs_path = "#{@thumbs_dir}/#{@gallery.gallery_dir_name}"
      FileUtils.mkdir_p(full_thumbs_path, :mode => 0755)
      if File.file?("#{full_thumbs_path}/#{self.filename}") == false or File.mtime("#{@gallery.gallery_dir}/#{self.filename}") > File.mtime("#{full_thumbs_path}/#{self.filename}")
        begin
          m_image = ImageList.new("#{@gallery.gallery_dir}/#{self.filename}")
          m_image.send("resize_to_fit!", size_x, size_y)
          puts "Writing thumbnail to #{full_thumbs_path}/#{self.filename}"
          m_image.write("#{full_thumbs_path}/#{self.filename}")
        rescue
          puts "error"
          puts $!
        end
        GC.start
      end
      self.data['thumbnail_url'] = URI.escape("/#{@thumbs_dir}/#{@gallery.gallery_dir_name}/#{self.filename}")
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
