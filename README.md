`_config.yml`:

    gallery_dir: galleries
    gallery_layout: gallery

Sample layout for gallery index, which you can make a `galleries.html` in Jekyll root directory:

    <section class="index">
      {% for gallery_hash in site.data['galleries'] %}
        {% for e in gallery_hash %}
          <p>
            <a href="{{ e[1] }}">{{ e[0] }}</a>
          </p>
        {% endfor %}
      {% endfor %}
      <hr>
    </section>

Sample layout for one gallery page, which normally you will put it as `_layouts/gallery.html`:

    ---
    layout: base
    ---
    {% for photo_url in page.photos %}
    <p>
    <img src="{{ photo_url }}" />
    </p>
    {% endfor %}
