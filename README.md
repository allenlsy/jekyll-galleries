# jekyll-galleries

By [allenlsy](mailto:cafe@allenlsy.com)

__Jekyll-galleries__ is a Jekyll plugin used for generating photo galleries from image folders.

##### Features:

* Automatically generate galleries from <tt>galleries</tt> folder
* Provide a convenient to generate galleries index page
* Load galleries and photos configuration from YAML file

There are two main concept in this plugin:

* __GalleriesPage__: index page displays all the galleries
* __GalleryPage__: single gallery webpage which shows all the photos in this gallery

### How to use the plugin

Here is an example on how to use this plugin.

1. Setup the plugin

Add `gem 'jekyll-galleries'` to the `Gemfile` in your jekyll project, and then run `bundle` command in shell to install it.


There are three attributes which are optional. All of them should be put at the root level of `_config.yml`, if needed.

* `galleries` specifies the extra information of each gallery, using the YAML object format.
* `gallery_dir` defines which folder in jekyll project stores the all the galleries. Default value is `galleries` if not defined.
* `gallery_layout` defines the layout __Jekyll-galleries__ will use to render each single gallery. Default value is `gallery`, which uses the `_layouts/gallery.html` as the template.

Check out the example `_config.yml` if you are still not clear.

2. Add galleries to jekyll project

By default, galleries are stored in the `galleries` folder in the jekyll project root path. If you want to change the storing path, you can customize the `gallery_dir` attribute it in `_config.yml` file.

__Jekyll-galleries__ will recognize all the subfolders in `galleries` (or `gallery_dir` specified in `_config.yml`) with the format of `<yyyy-MM-dd>-<NAME>` as a valid gallery folder. Meanwhile it adds `date` (value `yyyy-MM-dd`) and `name` (value `NAME`) attributes to the gallery. In the `name` attributes, space and other characters are allowed. All the files in gallery folder will be loaded to the GalleryPage. So please ensure you have correct image file in the gallery folder.

3. Adding attribute to images

You can have a `.yml` file with the same name of the gallery folder, to define attributes of each image in that gallery. Only images with extra attributes are required in the yaml file. Each image is identified by the attribute `filename`. For example, if you have an gallery, whose folder name is `2014-01-23-At the beach`, then in a `2014-01-23-At the beach.yml` file, you can config images like this:

    - filename: IMG_0075.JPG
      annotation: this is the allenllsy's jekyll-galleries
    - filename: IMG_1234.JPG
      annotation: shot at London

Then later you can use the attributes in your template, such as `annotation` in the example above.

Notice that attribute `filename` is required for any photos that as extra attributes.

4. Adding attribute to gallery

Inside the optional `galleries` attribute in `_config.yml`, you can have objects, with attribute `name` the value equals to your gallery name (not containing the date). For example:

    galleries:
      - name: Sample Gallery
        subtitle: This is a sample gallery

Then in the template, the gallery will have the attribute `subtitle` that can be rendered.

5. Use attributes in template


### Full example

Suppose in the Jekyll project root folder, my file structure is like below:

    galleries/
    |-2014-01-23-At the beach
    | -IMG_0001.JPG
    | -IMG_0005.JPG
    |-2014-02-01-Chinese New Year
    | -sing a song.jpg
    | -having dinner.jpg

First I have add a `_layouts/gallery.html` as my gallery template. 

    ---
    layout: base
    ---

    <p>
    {{ page.photos }}
    </p>
    {% for photo in page.photos %}
    <p>{{ photo.name }}</p>
    {% endfor %}
    <div id="galleria">
      {{ page.photo_urls.length }}
    </div>



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

