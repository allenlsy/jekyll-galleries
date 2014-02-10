module Jekyll
  class GalleryGenerator < Generator
    attr_accessor :site, :gallery_dir, :gallery_layout
    class << self; attr_accessor :site; end

    def generate(site)
      self.class.site = self.site = site
      self.gallery_dir = site.config['gallery_dir'] || 'galleries'
      self.gallery_layout = site.config['gallery_layout'] || 'gallery'

      site.data['galleries'] = []
      galleries = Dir["#{site.source}/#{gallery_dir}/*/"].select { |e| File.directory? e }
      galleries.each do |gallery|
        generate_gallery_page(gallery)
      end
    end

    private
    def generate_gallery_page(gallery)
      gallery_name = File.basename gallery
      photo_urls = Dir["#{gallery}*"].map { |e| URI.escape("/#{self.gallery_dir}/#{gallery_name}/#{File.basename e}") }
      data = { 'layout' => gallery_layout, 'photos' => photo_urls }
      site.pages << GalleryPage.new(site, site.source, gallery_dir, gallery_name, data)
      site.data['galleries'] << { "#{gallery_name}" => URI.escape("/#{self.gallery_dir}/#{gallery_name}.html") }
    end

  end

  class GalleryPage < Page
    def initialize(site, base, dir, name, data={})
      self.content = data.delete('content') || ''
      self.data = data
      super(site, base, dir, "#{name}.html")
    end

    def read_yaml(*)
    end
  end
end
