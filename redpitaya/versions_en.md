---
layout: page
title: Red Pitaya Apps - All versions
subtitle: Archive of every published package
permalink: /redpitaya/en/versions/
apps:
  - name: Lock-in+PID
    prefix: "lock_in+pid"
    anchor: lock-in-pid
  - name: Lock-in+PID H
    prefix: "lock_in+pid_harmonic"
    anchor: lock-in-pid-h
  - name: Lock-in+PID SQ
    prefix: "lock_in+pid_square"
    anchor: lock-in-pid-sq
  - name: Lock-in+PID H HF
    prefix: "lock_in+pid_harmonic_hf"
    anchor: lock-in-pid-h-hf
  - name: Lock-in+PID H2
    prefix: "lock_in+pid_harmonic2"
    anchor: lock-in-pid-h2
  - name: Scope++
    prefix: "scope++"
    anchor: scope-plus
  - name: Dummy Simulator
    prefix: "dummy_simulator"
    anchor: dummy-simulator
  - name: Dummy System
    prefix: "rp_dummy"
    anchor: dummy-system
---
{%- comment -%}
  Esta página se genera sola a partir de los archivos de /redpitaya/downloads/ (site.static_files).
  Nombre esperado: <prefijo>-<X.Y.Z>-<build>-devbuild.{tar.gz,zip}. El prefijo es todo lo que está
  antes de "-X.Y.Z-build-devbuild", así que lock_in+pid_harmonic no se confunde con
  lock_in+pid_harmonic2 ni con lock_in+pid_harmonic_hf. Los archivos sin "-devbuild" (rp_dummy.zip)
  usan el nombre sin extensión como prefijo. Se ignoran las variantes _DEBUG y _RELOAD.
  Orden: clave con relleno de ceros (X, Y, Z a 4 dígitos y build a 6), de la más nueva a la más vieja.

  Paso 1: armar una lista "|nombre|" de todos los archivos y una de entradas
  "prefijo#clave#version#base" (una por archivo; después se eliminan duplicados).
{%- endcomment -%}
{%- assign all_names = "|" -%}
{%- assign entries = "" -%}
{%- for f in site.static_files -%}
  {%- unless f.path contains "/redpitaya/downloads/" -%}{%- continue -%}{%- endunless -%}
  {%- if f.name contains "_DEBUG" or f.name contains "_RELOAD" -%}{%- continue -%}{%- endif -%}
  {%- if f.name contains ".tar.gz" -%}
    {%- assign base = f.name | remove: ".tar.gz" -%}
  {%- elsif f.extname == ".zip" -%}
    {%- assign base = f.name | remove: ".zip" -%}
  {%- else -%}{%- continue -%}{%- endif -%}
  {%- assign all_names = all_names | append: f.name | append: "|" -%}
  {%- if base contains "-devbuild" -%}
    {%- assign stem = base | split: "-devbuild" | first -%}
    {%- assign parts = stem | split: "-" -%}
    {%- assign nparts = parts | size -%}
    {%- assign nprefix = nparts | minus: 2 -%}
    {%- assign build = parts | last -%}
    {%- assign vidx = nparts | minus: 2 -%}
    {%- assign ver = parts[vidx] -%}
    {%- assign prefix = parts | slice: 0, nprefix | join: "-" -%}
    {%- assign key = "" -%}
    {%- assign vnums = ver | split: "." -%}
    {%- for n in vnums -%}
      {%- assign padded = "0000" | append: n | slice: -4, 4 -%}
      {%- assign key = key | append: padded | append: "." -%}
    {%- endfor -%}
    {%- assign padded = "000000" | append: build | slice: -6, 6 -%}
    {%- assign key = key | append: padded -%}
    {%- assign label = "v" | append: ver | append: "-" | append: build -%}
  {%- else -%}
    {%- assign prefix = base -%}
    {%- assign key = "0" -%}
    {%- assign label = base -%}
  {%- endif -%}
  {%- assign entries = entries | append: prefix | append: "#" | append: key | append: "#" | append: label | append: "#" | append: base | append: ";" -%}
{%- endfor -%}
{%- assign entries = entries | split: ";" | uniq | sort -%}

<div class="text-right">
  <a href="{{ site.baseurl }}/redpitaya/en/" class="btn btn-default btn-sm" role="button"><i class="fa fa-arrow-left"></i> Red Pitaya Projects</a>
</div>

This is the archive of every package published in this site for each Red Pitaya App, from the newest
to the oldest. For normal use, the latest version of each branch is recommended: **2.x** for the
Red Pitaya **Ecosystem 2.0** and **0.x** for the **0.9x / 1.0** ecosystems
(see [Red Pitaya Projects]({{ site.baseurl }}/redpitaya/en/)).

{% for app in page.apps %}
{%- assign tag = app.prefix | append: "#" -%}
{%- assign rows = "" | split: "" -%}
{%- for e in entries -%}
  {%- assign head = e | slice: 0, tag.size -%}
  {%- if head == tag -%}{%- assign rows = rows | push: e -%}{%- endif -%}
{%- endfor -%}
{%- assign rows = rows | reverse %}
## {{ app.name }} {#{{ app.anchor }}}

<div class="download-box versions-box">
  <i class="fa fa-download download-icon" aria-hidden="true"></i>
  <table class="versions-table">
  {%- assign seen = "|" -%}
  {%- for e in rows -%}
    {%- assign fields = e | split: "#" -%}
    {%- assign label = fields[2] -%}
    {%- assign base = fields[3] -%}
    {%- assign major = label | remove_first: "v" | split: "." | first -%}
    {%- assign mtag = "|" | append: major | append: "|" -%}
    {%- assign tgz = base | append: ".tar.gz" -%}
    {%- assign zip = base | append: ".zip" -%}
    {%- assign tgz_tag = "|" | append: tgz | append: "|" -%}
    {%- assign zip_tag = "|" | append: zip | append: "|" -%}
    {%- assign blabel = label -%}
    {%- if fields[1] == "0" -%}{%- assign blabel = base -%}{%- endif %}
    <tr>
      <td class="versions-label">{% if fields[1] == "0" %}{{ base }}{% else %}{{ label }}{% endif %}</td>
      <td class="versions-tag">
        {%- if fields[1] != "0" -%}{%- unless seen contains mtag %}<span class="label label-success">latest {{ major }}.x</span>{%- assign seen = seen | append: major | append: "|" -%}{%- endunless -%}{%- endif -%}</td>
      <td class="versions-files">{% if all_names contains tgz_tag %}{% include download-badge.html file=tgz label=blabel %} {% endif %}{% if all_names contains zip_tag %}{% include download-badge.html file=zip label=blabel %}{% endif %}</td>
    </tr>
  {%- endfor %}
  </table>
</div>
{% endfor %}
