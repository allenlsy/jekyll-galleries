# jekyll-galleries

By [allenlsy](mailto:cafe@allenlsy.com)

__Jekyll-galleries__ is a Jekyll plugin used for generating photo galleries from image folders.

A demo to this plugin is on my [personal website](http://allenlsy.com/galleries.html).

If you have any questions or any suggestions, I'm very pleased to hear from you. I need your support and ideas to make this plugin better.

---

##### Features:

* Automatically generate galleries from <tt>galleries</tt> folder
* Provide a convenient to generate galleries index page
* Load galleries and photos configuration from YAML file

There are two main concept in this plugin:

* __GalleriesPage__: index page displays all the galleries
* __GalleryPage__: single gallery webpage which shows all the photos in this gallery

### How to use the plugin

Here is an example on how to use this plugin.

##### 1. Setup the plugin

Add `gem 'jekyll-galleries'` to the `Gemfile` in your jekyll project, and also the depedencies `rmagick`. Then run `bundle` command in shell to install them. Next add `require 'jekyll/galleries'` to `_plugins/_ext.rb`.

There are three attributes which are optional. All of them should be put into the `_config.yml`, if needed.

* `galleries` specifies the extra information of each gallery, using the YAML object format.
* `gallery_dir` defines which folder in jekyll project stores the all the galleries. Default value is `galleries` if not defined.
* `gallery_layout` defines the layout __Jekyll-galleries__ will use to render each single gallery. Default value is `gallery`, which uses the `_layouts/gallery.html` as the template.

Check out the example `_config.yml` down below if you are still not clear.

##### 2. Add galleries to jekyll project

By default, galleries are stored in the `galleries` folder in the jekyll project root path. If you want to change the storing path, you can customize the `gallery_dir` attribute it in `_config.yml` file.

__Jekyll-galleries__ will recognize all the subfolders in `galleries` (or `gallery_dir` specified in `_config.yml`) with the format of `<yyyy-MM-dd>-<NAME>` as a valid gallery folder. Meanwhile it adds `date` (value `yyyy-MM-dd`) and `name` (value `NAME`) attributes to the gallery. In the `name` attributes, space and other characters are allowed. All the files in gallery folder will be loaded to the GalleryPage. So please ensure you have correct image file in the gallery folder.

##### 3. Adding attribute to photos

You can have a `.yml` file with the same name of the gallery folder, to define attributes of each photo in that gallery. Only photos with extra attributes are required in the yaml file. Each photo is identified by the attribute `filename`. For example, if you have an gallery, whose folder name is `2014-01-23-At the beach`, then in a `2014-01-23-At the beach.yml` file, you can config photos like this:

    - filename: IMG_0075.JPG
      annotation: this is the allenllsy's jekyll-galleries
    - filename: IMG_1234.JPG
      annotation: shot at London

Then later you can use the attributes in your template, such as `annotation` in the example above.

Notice that attribute `filename` is required for any photos that as extra attributes.

##### 4. Adding attribute to gallery

Inside the optional `galleries` attribute in `_config.yml`, you can have objects, with attribute `name` the value equals to your gallery name (not containing the date). For example:

    galleries:
      - name: Sample Gallery
        subtitle: This is a sample gallery

Then in the template, the gallery will have the attribute `subtitle` that can be rendered.

###### `top` attribute

Another attribute is `top`. If you set `top: true` for a gallery, then this gallery will always be put on top of the galleries index page. For example:

    galleries:
      - name: Sample Gallery
        subtitle: This is a sample gallery
        top: true

###### `thumbnail` attribute

`thumbnail` is a special optional attribute. If you want to add a gallery cover thumbnail to galleries index page, you need to specify the thumbnail file name (not path).

##### 5. Use attributes in template

Now, the `site.data['galleries']` global variable contains all the gallery pages. It is an array of `GalleryPage` objects. Each `GalleryPage` object has at least three attributes: `name`, `date` and `url`. `url` is URL escaped. You can use them in your galleries index page.

In each gallery page, you have a `page` object. And `page.photos` is an array of `Photo` objects. An `Photo` object has at least `filename` and `url` two attributes. The `url` attribute is also URL escaped, so you don't need to worry about it.

In the example below, you will see how to use attributes in template in more detail.

### Example of Galleries Index page & Gallery page

* Galleries Index page: the index page of all galleries
* Gallery Page: the page display photos in that gallery

Suppose in the Jekyll project root folder, my file structure is like below:

    galleries/
    |-2014-01-23-At the beach
    | -IMG_0001.JPG
    | -IMG_0005.JPG
    |-2014-02-01-Chinese New Year
    | -sing a song.jpg
    | -having dinner.jpg

##### Galleries index page template

After installing and setting up the plugin, I add a galleries index file `galleries.html` in Jekyll root directory:

    ---
    layout: base
    ---
    {% for gallery in site.data['galleries'] %}
      <p>
        <a href="{{ gallery.url }}">{{ gallery.name }}</a>
        <span>{{ gallery.date }}</span>
      </p>
    {% endfor %}

If I want to also add other attributes, such as `excerpt` for some galleries, I can specifies them in `_config.yml`

    galleries:
      - name: At the beach
        excerpt: Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.

Then I update the `galleries.html` page:

    ---
    layout: base
    ---
    {% for gallery in site.data['galleries'] %}
      <div>
        <a href="{{ gallery.url }}">{{ gallery.name }}</a>
        <span>{{ gallery.date }}</span>
        {% if gallery.excerpt %}
        <p>
          {{ gallery.excerpt }}
        </p>
        {% endif %}
      </div>
    {% endfor %}

The generated `galleries.html` should be like this:

    <div>
      <a href="/galleries/2014-02-01-chinese-new-year.html">Chinese New Year</a>
      <span>2014-02-01</span>
    </div>
    <div>
      <a href="/galleries/2014-01-23-at-the-beach.html">At the beach</a>
      <span>2014-01-23</span>
      <p>
        Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat.
      </p>
    </div>


##### Gallery page template

Next, I add a `_layouts/gallery.html` file as my gallery template. This is the template for each single gallery

    ---
    layout: base
    ---

    {% for photo in page.photos %}
      <img src="{{ photo.url }}" style="width:800px;"/>
      {% if photo.info %}
      <p>{{ photo.info }}</p>
      {% endif %}
      <hr >
    {% endfor %}

In this template, I take use of the extra attribute `info` of photo. This attribute can be configured in photos config file, eg. `galleries/2014-02-01-Chinese New Year`:

    - filename: 'sing a song.jpg'
      info: 'We are singing a song'

The photos are identified using the `filename` attribute.

After I run `jekyll build`, it should generate a file `_site/galleries/2014-02-01-chinese-new-year.html`. The content should be like:

    <img src="/galleries/2014-02-02-Chinese%20New%20Year/IMG_0094.JPG" style="width:800px;"/>
    <hr >
    <img src="/galleries/2014-02-02-Chinese%20New%20Year/sing%20a%20song.jpg" style="width:800px;"/>
    <p>We are singing a song</p>
    <hr >

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

