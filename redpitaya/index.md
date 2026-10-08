---
layout: page
title: Proyectos Red Pitaya
subtitle: Aplicaciones para instrumentación de laboratorio
---

[Red Pitaya](https://www.redpitaya.com/) es una plataforma de instrumentación abierta que combina
una FPGA, conversores analógico-digitales rápidos y un procesador ARM con interfaz web.
Estas aplicaciones la convierten en amplificadores lock-in, controladores PID y otras
herramientas útiles en un laboratorio de óptica y física atómica.

{% include card-grid.html items=site.data.redpitaya logo=true %}

------

## Lock-in+PID

{% include project-badges.html repo="marceluda/rp_lock-in_pid" site="https://marceluda.github.io/rp_lock-in_pid/" name="Lock-in+PID" %}

Es la App original. Incluye dos amplificadores lock-in, uno cuadrado y rápido y otro armónico y lento,
además de filtros PID y control de lock, embebidos en la FPGA.

**Descargas:**

{% include download-badge.html file="lock_in+pid-0.2.4-11-devbuild.tar.gz" label="Lock-in+PID v0.2.4-11" %} {% include download-badge.html file="lock_in+pid-0.2.4-11-devbuild.zip" label="Lock-in+PID v0.2.4-11" %}  
{% include download-badge.html file="lock_in+pid-0.2.3-7-devbuild.tar.gz" label="Lock-in+PID v0.2.3-7" %} {% include download-badge.html file="lock_in+pid-0.2.3-7-devbuild.zip" label="Lock-in+PID v0.2.3-7" %}

## Lock-in+PID H

{% include project-badges.html repo="marceluda/rp_lock-in_pid_h" site="https://marceluda.github.io/rp_lock-in_pid/Derivated/#lock-in-pid-h" name="Lock-in+PID H" %}

Lock-in armónico hasta 50 kHz, filtros PID y control de lock.

## Lock-in+PID H2

{% include project-badges.html repo="marceluda/rp_lock-in_pid_h2" site="https://marceluda.github.io/rp_lock-in_pid/Derivated/#lock-in-pid-h2" name="Lock-in+PID H2" %}

Demoduladores lock-in que comparten un mismo oscilador local, filtros PID y control de lock.

**Descargas:**

{% include download-badge.html file="lock_in+pid_harmonic2-0.4.2-10-devbuild.tar.gz" label="Lock-in+PID H2 v0.4.2-10" %} {% include download-badge.html file="lock_in+pid_harmonic2-0.4.2-10-devbuild.zip" label="Lock-in+PID H2 v0.4.2-10" %}

## Lock-in+PID H HF

{% include project-badges.html repo="marceluda/rp_lock-in_pid_h_hf" site="https://marceluda.github.io/rp_lock-in_pid/Derivated/#lock-in-pid-h-hf" name="Lock-in+PID H HF" %}

Variante de Lock-in+PID H que llega hasta 1 MHz.

**Descargas:**

{% include download-badge.html file="lock_in+pid_harmonic_hf-0.3.9-7-devbuild.tar.gz" label="Lock-in+PID H HF v0.3.9-7" %} {% include download-badge.html file="lock_in+pid_harmonic_hf-0.3.9-7-devbuild.zip" label="Lock-in+PID H HF v0.3.9-7" %}

## Scope++

{% include project-badges.html repo="marceluda/rp_scope_plus" %}

Versión extendida de la aplicación de osciloscopio libre de la comunidad de Red Pitaya, con interfaz mejorada.

- Incluye generador de funciones, filtros PID elementales y osciloscopio.
- Basada en [scope_release-v0.95](https://github.com/RedPitaya/RedPitaya/tree/release-v0.95/apps-free/scope).

**Descargas:**

{% include download-badge.html file="scope++-1.1.1-4-devbuild.tar.gz" label="Scope++ v1.1.1-4" %} {% include download-badge.html file="scope++-1.1.1-4-devbuild.zip" label="Scope++ v1.1.1-4" %}

## Dummy System

{% include project-badges.html repo="marceluda/rp_dummy" site="https://marceluda.github.io/rp_dummy/" name="Dummy System" %}

Entorno de desarrollo de aplicaciones para Red Pitaya con fines educativos, basado en Vivado 2015.2.
Está diseñado para simplificar el desarrollo de aplicaciones con entorno web. Permite generar de forma
automatizada una aplicación que contenga:

- El módulo de osciloscopio
- El módulo de generador de funciones
- El módulo de filtros PID
- Un módulo Dummy a ser programado por el usuario, con las entradas y salidas ya programadas
- Una serie de controles web para usar en el diseño FPGA

La creación de proyectos y la programación web y en C está completamente automatizada, dejando
al usuario sólo la tarea del diseño en FPGA.

**Descargas:**

{% include download-badge.html file="rp_dummy.zip" label="Dummy System v0.1.0" %}

## Dummy Simulator

{% include project-badges.html repo="marceluda/rp_dummy_simulator" %}

Simulador de picos espectrales, para probar barridos y lockeos.

**Descargas:**

{% include download-badge.html file="dummy_simulator-0.1.2-4-devbuild.tar.gz" label="Dummy Simulator v0.1.2-4" %} {% include download-badge.html file="dummy_simulator-0.1.2-4-devbuild.zip" label="Dummy Simulator v0.1.2-4" %}

