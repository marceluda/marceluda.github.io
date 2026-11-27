---
layout: page
title: Red Pitaya Projects
subtitle: Applications for laboratory instrumentation
permalink: /redpitaya/en/
js:
  - /js/copy-cmd.js
---

<div class="text-right">
  <a href="{{ site.baseurl }}/redpitaya/" class="btn btn-default btn-sm" role="button"><i class="fa fa-language"></i> Versión en español</a>
</div>

[Red Pitaya](https://www.redpitaya.com/) is an open instrumentation platform that combines
an FPGA, fast analog-to-digital converters and an ARM processor with a web interface.
These applications turn it into lock-in amplifiers, PID controllers and other
useful tools for an optics and atomic physics laboratory.

<div class="alert alert-info" role="alert" markdown="1">
**2.x versions:** they were redesigned by incorporating the original FPGA layer designs into the
RedPitaya-FPGA [Release_2025.2](https://github.com/RedPitaya/RedPitaya-FPGA/releases/tag/Release_2025.2) base design
(tag `2.07-48`, branch `origin/Release-2025.2`), with the FPGA built in Vivado 2020.1.

**Which version should I download?**
- **2.x** → Red Pitaya **Ecosystem 2.0** (e.g. `RedPitaya_OS_2.04`; tested on 2.04-35).
- **0.x** → **0.9x / 1.0** ecosystems. They are still available for download.

Lock-in+PID Plus and Lock-in+PID SQ are only available as 2.x.
</div>

## Fast install {#fast-install}

A single line in a terminal installs these Apps on your Red Pitaya. Copy the line for your system, paste it in a
terminal and follow the instructions: the installer lets you choose the Apps, asks for the address of the Red Pitaya
(for example `rp-xxxxxx.local`, its IP or the URL you use in the browser) and uploads them by SSH
(the factory password of `root` is `root`).

{% include copy-cmd.html icon="fa-linux" label="Linux (terminal)" copy="Copy" copied="Copied!" cmd="bash <(curl -fsSL https://marceluda.github.io/redpitaya/install_rp_apps.sh)" %}
{% include copy-cmd.html icon="fa-windows" label="Windows 10 / 11 (PowerShell)" copy="Copy" copied="Copied!" cmd="irm https://marceluda.github.io/redpitaya/install_rp_apps.ps1 | iex" %}

It installs the newest version of each App, the one listed in
[last_stables.txt]({{ site.baseurl }}/redpitaya/downloads/last_stables.txt) (currently the 2.x versions, for Ecosystem 2.0).
You can look at the scripts before running them:
[install_rp_apps.sh]({{ site.baseurl }}/redpitaya/install_rp_apps.sh) ·
[install_rp_apps.ps1]({{ site.baseurl }}/redpitaya/install_rp_apps.ps1).

<div class="text-center">
  <a href="{{ site.baseurl }}/redpitaya/en/versions/" class="btn btn-default btn-sm" role="button"><i class="fa fa-archive"></i> All versions</a>
</div>

{% include card-grid.html items=site.data.redpitaya logo=true lang="en" %}

------

## Lock-in+PID {#lock-in-pid}

{% include project-badges.html repo="marceluda/rp_lock-in_pid" site="https://marceluda.github.io/rp_lock-in_pid/" name="Lock-in+PID" %}

The original App. It includes two lock-in amplifiers, a fast square one and a slow harmonic one,
plus PID filters and lock control, embedded in the FPGA.

This application has been split into two independent applications: [Lock-in+PID Harmonic](#lock-in-pid-h)
with the harmonic version of the lock-in and [Lock-in+PID SQ](#lock-in-pid-sq) with the square version. Each of
them includes new *features* that could not be added to the original one due to lack of space in the FPGA.

<div class="download-box">
  <i class="fa fa-download download-icon" aria-hidden="true"></i>
  <div class="download-list">
  {% include download-badge.html file="lock_in+pid-2.2.18-37-devbuild.tar.gz" label="Lock-in+PID v2.2.18-37" %} {% include download-badge.html file="lock_in+pid-2.2.18-37-devbuild.zip" label="Lock-in+PID v2.2.18-37" %}<br />
  {% include download-badge.html file="lock_in+pid-0.2.4-11-devbuild.tar.gz" label="Lock-in+PID v0.2.4-11" %} {% include download-badge.html file="lock_in+pid-0.2.4-11-devbuild.zip" label="Lock-in+PID v0.2.4-11" %}
  </div>
</div>

## Lock-in+PID H {#lock-in-pid-h}

{% include project-badges.html repo="marceluda/rp_lock-in_pid_h" site="https://marceluda.github.io/rp_lock-in_pid/Derivated/#lock-in-pid-h" name="Lock-in+PID H" %}

Harmonic lock-in up to 50 kHz, PID filters and lock control.

<div class="download-box">
  <i class="fa fa-download download-icon" aria-hidden="true"></i>
  <div class="download-list">
  {% include download-badge.html file="lock_in+pid_harmonic-2.3.33-76-devbuild.tar.gz" label="Lock-in+PID H v2.3.33-76" %} {% include download-badge.html file="lock_in+pid_harmonic-2.3.33-76-devbuild.zip" label="Lock-in+PID H v2.3.33-76" %}<br />
  {% include download-badge.html file="lock_in+pid_harmonic-0.3.11-17-devbuild.tar.gz" label="Lock-in+PID H v0.3.11-17" %} {% include download-badge.html file="lock_in+pid_harmonic-0.3.11-17-devbuild.zip" label="Lock-in+PID H v0.3.11-17" %}
  </div>
</div>

## Lock-in+PID Plus {#lock-in-pid-plus}

{% include project-badges.html repo="marceluda/rp_lock-in_pid_plus" site="https://marceluda.github.io/rp_lock-in_pid/Derivated/#lock-in-pid-plus" name="Lock-in+PID Plus" %}

Derived from [Lock-in+PID H](#lock-in-pid-h). Lock-in with frequency-set DDS reference, harmonic demodulation, external reference (ADPLL), PID and ramp controller.

<div class="download-box">
  <i class="fa fa-download download-icon" aria-hidden="true"></i>
  <div class="download-list">
  {% include download-badge.html file="lock_in+pid_plus-2.2.2-22-devbuild.tar.gz" label="Lock-in+PID Plus v2.2.2-22" %} {% include download-badge.html file="lock_in+pid_plus-2.2.2-22-devbuild.zip" label="Lock-in+PID Plus v2.2.2-22" %}
  </div>
</div>

## Lock-in+PID SQ {#lock-in-pid-sq}

{% include project-badges.html repo="marceluda/rp_lock-in_pid_sq" site="https://marceluda.github.io/rp_lock-in_pid/Derivated/#lock-in-pid-sq" name="Lock-in+PID SQ" %}

Version of Lock-in+PID with only the square (fast) lock-in.

<div class="download-box">
  <i class="fa fa-download download-icon" aria-hidden="true"></i>
  <div class="download-list">
  {% include download-badge.html file="lock_in+pid_square-2.0.12-23-devbuild.tar.gz" label="Lock-in+PID SQ v2.0.12-23" %} {% include download-badge.html file="lock_in+pid_square-2.0.12-23-devbuild.zip" label="Lock-in+PID SQ v2.0.12-23" %}
  </div>
</div>

## Lock-in+PID H HF {#lock-in-pid-h-hf}

{% include project-badges.html repo="marceluda/rp_lock-in_pid_h_hf" site="https://marceluda.github.io/rp_lock-in_pid/Derivated/#lock-in-pid-h-hf" name="Lock-in+PID H HF" %}

Variant of Lock-in+PID H that reaches 1 MHz.

<div class="download-box">
  <i class="fa fa-download download-icon" aria-hidden="true"></i>
  <div class="download-list">
  {% include download-badge.html file="lock_in+pid_harmonic_hf-2.3.23-29-devbuild.tar.gz" label="Lock-in+PID H HF v2.3.23-29" %} {% include download-badge.html file="lock_in+pid_harmonic_hf-2.3.23-29-devbuild.zip" label="Lock-in+PID H HF v2.3.23-29" %}<br />
  {% include download-badge.html file="lock_in+pid_harmonic_hf-0.3.9-7-devbuild.tar.gz" label="Lock-in+PID H HF v0.3.9-7" %} {% include download-badge.html file="lock_in+pid_harmonic_hf-0.3.9-7-devbuild.zip" label="Lock-in+PID H HF v0.3.9-7" %}
  </div>
</div>

## Lock-in+PID H2 {#lock-in-pid-h2}

{% include project-badges.html repo="marceluda/rp_lock-in_pid_h2" site="https://marceluda.github.io/rp_lock-in_pid/Derivated/#lock-in-pid-h2" name="Lock-in+PID H2" %}

Lock-in demodulators sharing the same local oscillator, PID filters and lock control.

<div class="download-box">
  <i class="fa fa-download download-icon" aria-hidden="true"></i>
  <div class="download-list">
  {% include download-badge.html file="lock_in+pid_harmonic2-2.4.16-31-devbuild.tar.gz" label="Lock-in+PID H2 v2.4.16-31" %} {% include download-badge.html file="lock_in+pid_harmonic2-2.4.16-31-devbuild.zip" label="Lock-in+PID H2 v2.4.16-31" %}<br />
  {% include download-badge.html file="lock_in+pid_harmonic2-0.4.2-10-devbuild.tar.gz" label="Lock-in+PID H2 v0.4.2-10" %} {% include download-badge.html file="lock_in+pid_harmonic2-0.4.2-10-devbuild.zip" label="Lock-in+PID H2 v0.4.2-10" %}
  </div>
</div>

## Scope++ {#scope-plus}

{% include project-badges.html repo="marceluda/rp_scope_plus" %}

Extended version of the free oscilloscope application of the Red Pitaya community, with an enhanced interface.

- Includes function generator, basic PID filters and oscilloscope.
- Based on [scope_release-v0.95](https://github.com/RedPitaya/RedPitaya/tree/release-v0.95/apps-free/scope).

<div class="download-box">
  <i class="fa fa-download download-icon" aria-hidden="true"></i>
  <div class="download-list">
  {% include download-badge.html file="scope++-1.1.1-4-devbuild.tar.gz" label="Scope++ v1.1.1-4" %} {% include download-badge.html file="scope++-1.1.1-4-devbuild.zip" label="Scope++ v1.1.1-4" %}
  </div>
</div>

## Dummy Simulator {#dummy-simulator}

{% include project-badges.html repo="marceluda/rp_dummy_simulator" %}

Spectral peak simulator, to test scans and locking.

<div class="download-box">
  <i class="fa fa-download download-icon" aria-hidden="true"></i>
  <div class="download-list">
  {% include download-badge.html file="dummy_simulator-0.1.4-7-devbuild.tar.gz" label="Dummy Simulator v0.1.4-7" %} {% include download-badge.html file="dummy_simulator-0.1.4-7-devbuild.zip" label="Dummy Simulator v0.1.4-7" %}
  </div>
</div>

## Dummy System {#dummy-system}

{% include project-badges.html repo="marceluda/rp_dummy" site="https://marceluda.github.io/rp_dummy/" name="Dummy System" %}

Application development environment for Red Pitaya for educational purposes, based on Vivado 2015.2.
It is designed to simplify the development of applications with a web interface. It automatically
generates an application that contains:

- The oscilloscope module
- The function generator module
- The PID filters module
- A Dummy module to be programmed by the user, with inputs and outputs already wired
- A set of web controls to use in the FPGA design

Project creation and web and C programming are fully automated, leaving the user
only the FPGA design task.

<div class="download-box">
  <i class="fa fa-download download-icon" aria-hidden="true"></i>
  <div class="download-list">
  {% include download-badge.html file="rp_dummy.zip" label="Dummy System v0.1.0" %}
  </div>
</div>
