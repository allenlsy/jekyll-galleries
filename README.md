# jekyll-galleries

By [allenlsy](mailto:cafe@allenlsy.com)

__Jekyll-galleries__ is a Jekyll plugin used for generating photo galleries from image folders.

##### Features:

* Automatically generate galleries from <tt>galleries</tt> folder
* Load galleries and photos configuration from YAML file


There are two main concept in this plugin:

* __GalleriesPage__: index page displays all the galleries
* __GalleryPage__: single gallery webpage which shows all the photos in this gallery

1. Setup the plugin

Add `gem 'jekyll-galleries'` to the `Gemfile` in your jekyll project, and then run `bundle` command in shell to install it.

Then inside the `_config.yml`, and a `galleries` attribute.

2. Add galleries to jekyll project

By default, galleries are stored in the `galleries` folder in the jekyll project root path. If you want to change the storing path, you can customize it in `_config.yml` with `gallery_dir` attributes.

__Jekyll-galleries__ will recognize all the subfolders in `galleries` with the format of `<yyyy-MM-dd>-<NAME>` as a gallery folder. Meanwhile adding `date` (value `yyyy-MM-dd`) and `name` (value `NAME`) attributes to the gallery. In the `name` attributes, space and other characters are allowed. All the files in gallery folder will be loaded to the GalleryPage. So please ensure you have correct image file in the gallery folder.

3. Adding attribute to images

You can have a `.yml` file with the same name of the gallery folder, to define attributes of images in that gallery. Only photos with extra attributes is required in the yaml file. Each photo is identified by an attribute `filename`. A typical photos config file looks like this:

    - filename: IMG_0075.JPG
      annotation: this is the allenllsy's jekyll-galleries
    - filename: IMG_1234.JPG
      annotation: shot at London

Then later you can use the attributes in your template





Inside the `galleries` attribute, you can have objects, with attribute `name` the value equals to your gallery name. For example: 

    galleries:
      - name: Sample Gallery
        subtitle: This is a sample gallery






Optional configurations are:

    gallery_dir: galleries
    gallery_layout: gallery

Sample layout for gallery index, which you can make a `galleries.html` in Jekyll root directory:

    {% for gallery in site.data['galleries'] %}
      <p>
        <a href="{{ gallery.url }}">{{ gallery.name }}</a>
        <span>{{ gallery.date }}</span>
      </p>
    {% endfor %}

Sample layout for one gallery page, which normally you will put it as <tt>_layouts/gallery.html</tt>:

    ---
    layout: base
    ---
    {% for photo_url in page.photos %}
      <p>
        <img src="{{ photo_url }}" />
      </p>
    {% endfor %}

### License

#### The MIT License

Copyright (c) 2010-2012 University of Cologne,
Albertus-Magnus-Platz, 50923 Cologne, Germany

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

