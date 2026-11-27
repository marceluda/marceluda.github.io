---
layout: page
title: Red Pitaya Apps - Downloads
subtitle: Every published package with its md5sum
permalink: /redpitaya/downloads/
---
{%- comment -%}
  La tabla sale de _data/downloads.json, que arma sync-downloads.py (junto con
  redpitaya/downloads/last_stables.txt). Correr el script cada vez que cambian los paquetes.
{%- endcomment -%}

<div class="text-center">
  <a href="{{ site.baseurl }}/redpitaya/en/" class="btn btn-default btn-sm" role="button"><i class="fa fa-arrow-left"></i> Red Pitaya Apps</a>
  <a href="{{ site.baseurl }}/redpitaya/en/versions/" class="btn btn-default btn-sm" role="button"><i class="fa fa-archive"></i> All versions</a>
  <a href="{{ site.baseurl }}/redpitaya/downloads/last_stables.txt" class="btn btn-default btn-sm" role="button"><i class="fa fa-file-text-o"></i> last_stables.txt</a>
</div>

Packages are sorted by App name and then by version, newest first.
[`last_stables.txt`]({{ site.baseurl }}/redpitaya/downloads/last_stables.txt) lists only the newest
package of each App, one file per line as `name<TAB>url`.

<div class="downloads-wrap" markdown="0">
<table class="downloads-table">
  <thead>
    <tr><th>Name</th><th>Version</th><th>Package</th><th>md5sum</th></tr>
  </thead>
  <tbody>
  {%- for v in site.data.downloads %}
    <tr>
      <td class="dl-name">{{ v.name }}</td>
      <td class="dl-version">{{ v.version | default: "—" }}</td>
      <td class="dl-files">{% for f in v.files %}<a href="{{ site.baseurl }}/redpitaya/downloads/{{ f.file }}">{{ f.file }}</a>{% unless forloop.last %}<br>{% endunless %}{% endfor %}</td>
      <td class="dl-md5">{% for f in v.files %}<code>{{ f.md5 }}</code>{% unless forloop.last %}<br>{% endunless %}{% endfor %}</td>
    </tr>
  {%- endfor %}
  </tbody>
</table>
</div>
