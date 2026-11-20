---
layout: page
title: Videos de divulgación
subtitle: Una selección personal de videos sobre física y ciencia
js:
  - /js/videos.js
---
{%- comment -%}
  Los datos salen de _data/videos.json y _data/video_tags.json, generados con sync-videos.py
  desde el catálogo de videos. Las tarjetas se arman acá; js/videos.js hace el filtrado y el
  cambio de idioma.
{%- endcomment -%}

<div id="videos" class="videos lang-es" markdown="0">

<div class="videos-lang btn-group btn-group-sm" role="group" aria-label="Idioma / Language">
  <button type="button" class="btn btn-default active" data-lang="es">ES</button>
  <button type="button" class="btn btn-default" data-lang="en">EN</button>
</div>

<p class="t-es">Colección de videos de divulgación/debate que me parecen interesantes. Cada tarjeta
abre el video en una ventana aparte. Se puede buscar por texto o elegir etiquetas.</p>
<p class="t-en">A collection of science outreach and debate videos that I find interesting. Each card
opens the video in a new window. You can search by text or pick tags.</p>

<div class="videos-search">
  <i class="fa fa-search" aria-hidden="true"></i>
  <input type="search" id="videos-q" class="form-control" autocomplete="off"
         placeholder="Buscar en títulos, descripciones y etiquetas…"
         data-ph-es="Buscar en títulos, descripciones y etiquetas…"
         data-ph-en="Search titles, descriptions and tags…">
</div>

<div class="videos-tags">
{%- for g in site.data.video_tags %}
  <div class="videos-tag-group{% if g.tags.size > 16 %} collapsed{% endif %}">
    <span class="videos-tag-group-name"><span class="t-es">{{ g.es }}</span><span class="t-en">{{ g.en }}</span></span>
    {%- for t in g.tags %}
    <button type="button" class="video-tag{% if forloop.index > 16 %} extra{% endif %}" data-tag="{{ t.es | escape }}" aria-pressed="false"><span class="t-es">{{ t.es }}</span><span class="t-en">{{ t.en }}</span> <span class="n">{{ t.n }}</span></button>
    {%- endfor %}
    {%- if g.tags.size > 16 %}
    <button type="button" class="video-tag-more"><span class="t-es">ver todos</span><span class="t-en">show all</span></button>
    {%- endif %}
  </div>
{%- endfor %}
</div>

<div class="videos-status">
  <span id="videos-count"></span>
  <button type="button" id="videos-clear" class="btn btn-link btn-sm" hidden><i class="fa fa-times"></i> <span class="t-es">Limpiar filtros</span><span class="t-en">Clear filters</span></button>
</div>

<div class="video-grid">
{%- for v in site.data.videos %}
  {%- capture texto -%}{{ v.title }} {{ v.author }} {{ v.description.es }} {{ v.description.en }} {{ v.tags.es | join: " " }} {{ v.tags.en | join: " " }}{%- endcapture %}
  <a class="video-card" href="{{ v.url }}" target="_blank" rel="noopener"
     data-tags="{{ v.tags.es | join: '|' | escape }}" data-text="{{ texto | escape }}">
    <div class="video-img">
      <img src="{{ site.baseurl }}/apuntes/videos/img/{{ v.id }}.jpg" alt="" loading="lazy" width="480" height="270">
      {%- if v.duration %}<span class="video-duration">{{ v.duration }}</span>{% endif %}
    </div>
    <div class="video-body">
      <h4 class="video-title">{{ v.title }}</h4>
      <p class="video-meta">{{ v.author }} · {{ v.date | slice: 0, 4 }} · <span class="video-audio" title="Audio">{{ v.language | upcase }}</span></p>
      <p class="video-desc"><span class="t-es">{{ v.description.es }}</span><span class="t-en">{{ v.description.en }}</span></p>
      <p class="video-chips">
        {%- for t in v.tags.es %}<span class="video-chip"><span class="t-es">{{ t }}</span><span class="t-en">{{ v.tags.en[forloop.index0] }}</span></span>{% endfor -%}
      </p>
    </div>
  </a>
{%- endfor %}
</div>

<p id="videos-empty" class="videos-empty" hidden><span class="t-es">No hay videos que coincidan con la búsqueda.</span><span class="t-en">No videos match the search.</span></p>

</div>
