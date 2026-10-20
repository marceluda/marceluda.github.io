---
layout: page
title: Red Pitaya Projects
subtitle: Applications for laboratory instrumentation
permalink: /redpitaya/en/
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

Lock-in+PID SQ is only available as 2.x.
</div>

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
  {% include download-badge.html file="lock_in+pid-2.2.11-26-devbuild.tar.gz" label="Lock-in+PID v2.2.11-26" %} {% include download-badge.html file="lock_in+pid-2.2.11-26-devbuild.zip" label="Lock-in+PID v2.2.11-26" %}<br />
  {% include download-badge.html file="lock_in+pid-0.2.4-11-devbuild.tar.gz" label="Lock-in+PID v0.2.4-11" %} {% include download-badge.html file="lock_in+pid-0.2.4-11-devbuild.zip" label="Lock-in+PID v0.2.4-11" %}
  </div>
</div>

## Lock-in+PID H {#lock-in-pid-h}

{% include project-badges.html repo="marceluda/rp_lock-in_pid_h" site="https://marceluda.github.io/rp_lock-in_pid/Derivated/#lock-in-pid-h" name="Lock-in+PID H" %}

Harmonic lock-in up to 50 kHz, PID filters and lock control.

<div class="download-box">
  <i class="fa fa-download download-icon" aria-hidden="true"></i>
  <div class="download-list">
  {% include download-badge.html file="lock_in+pid_harmonic-2.3.26-62-devbuild.tar.gz" label="Lock-in+PID H v2.3.26-62" %} {% include download-badge.html file="lock_in+pid_harmonic-2.3.26-62-devbuild.zip" label="Lock-in+PID H v2.3.26-62" %}<br />
  {% include download-badge.html file="lock_in+pid_harmonic-0.3.11-17-devbuild.tar.gz" label="Lock-in+PID H v0.3.11-17" %} {% include download-badge.html file="lock_in+pid_harmonic-0.3.11-17-devbuild.zip" label="Lock-in+PID H v0.3.11-17" %}
  </div>
</div>

## Lock-in+PID SQ {#lock-in-pid-sq}

{% include project-badges.html repo="marceluda/rp_lock-in_pid_sq" site="https://marceluda.github.io/rp_lock-in_pid/Derivated/#lock-in-pid-sq" name="Lock-in+PID SQ" %}

Version of Lock-in+PID with only the square (fast) lock-in.

<div class="download-box">
  <i class="fa fa-download download-icon" aria-hidden="true"></i>
  <div class="download-list">
  {% include download-badge.html file="lock_in+pid_square-2.0.5-15-devbuild.tar.gz" label="Lock-in+PID SQ v2.0.5-15" %} {% include download-badge.html file="lock_in+pid_square-2.0.5-15-devbuild.zip" label="Lock-in+PID SQ v2.0.5-15" %}
  </div>
</div>

## Lock-in+PID H HF {#lock-in-pid-h-hf}

{% include project-badges.html repo="marceluda/rp_lock-in_pid_h_hf" site="https://marceluda.github.io/rp_lock-in_pid/Derivated/#lock-in-pid-h-hf" name="Lock-in+PID H HF" %}

Variant of Lock-in+PID H that reaches 1 MHz.

<div class="download-box">
  <i class="fa fa-download download-icon" aria-hidden="true"></i>
  <div class="download-list">
  {% include download-badge.html file="lock_in+pid_harmonic_hf-2.3.16-21-devbuild.tar.gz" label="Lock-in+PID H HF v2.3.16-21" %} {% include download-badge.html file="lock_in+pid_harmonic_hf-2.3.16-21-devbuild.zip" label="Lock-in+PID H HF v2.3.16-21" %}<br />
  {% include download-badge.html file="lock_in+pid_harmonic_hf-0.3.9-7-devbuild.tar.gz" label="Lock-in+PID H HF v0.3.9-7" %} {% include download-badge.html file="lock_in+pid_harmonic_hf-0.3.9-7-devbuild.zip" label="Lock-in+PID H HF v0.3.9-7" %}
  </div>
</div>

## Lock-in+PID H2 {#lock-in-pid-h2}

{% include project-badges.html repo="marceluda/rp_lock-in_pid_h2" site="https://marceluda.github.io/rp_lock-in_pid/Derivated/#lock-in-pid-h2" name="Lock-in+PID H2" %}

Lock-in demodulators sharing the same local oscillator, PID filters and lock control.

<div class="download-box">
  <i class="fa fa-download download-icon" aria-hidden="true"></i>
  <div class="download-list">
  {% include download-badge.html file="lock_in+pid_harmonic2-2.4.9-23-devbuild.tar.gz" label="Lock-in+PID H2 v2.4.9-23" %} {% include download-badge.html file="lock_in+pid_harmonic2-2.4.9-23-devbuild.zip" label="Lock-in+PID H2 v2.4.9-23" %}<br />
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
