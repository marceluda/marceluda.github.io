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

[Sitio](https://marceluda.github.io/rp_lock-in_pid/) · [Repositorio](https://github.com/marceluda/rp_lock-in_pid)

Es la App original. Incluye dos amplificadores lock-in, uno cuadrado y rápido y otro armónico y lento,
además de filtros PID y control de lock, embebidos en la FPGA.

## Lock-in+PID H

[Sitio](https://marceluda.github.io/rp_lock-in_pid/Derivated/#lock-in-pid-h) · [Repositorio](https://github.com/marceluda/rp_lock-in_pid_h)

Lock-in armónico hasta 50 kHz, filtros PID y control de lock.

## Lock-in+PID H2

[Sitio](https://marceluda.github.io/rp_lock-in_pid/Derivated/#lock-in-pid-h2) · [Repositorio](https://github.com/marceluda/rp_lock-in_pid_h2)

Demoduladores lock-in que comparten un mismo oscilador local, filtros PID y control de lock.

## Lock-in+PID H HF

[Sitio](https://marceluda.github.io/rp_lock-in_pid/Derivated/#lock-in-pid-h-hf) · [Repositorio](https://github.com/marceluda/rp_lock-in_pid_h_hf)

Variante de Lock-in+PID H que llega hasta 1 MHz.

## Scope++

[Repositorio](https://github.com/marceluda/rp_scope_plus)

Versión extendida de la aplicación de osciloscopio libre de la comunidad de Red Pitaya, con interfaz mejorada.

- Incluye generador de funciones, filtros PID elementales y osciloscopio.
- Basada en [scope_release-v0.95](https://github.com/RedPitaya/RedPitaya/tree/release-v0.95/apps-free/scope).

## Dummy System

[Sitio](https://marceluda.github.io/rp_dummy/) · [Repositorio](https://github.com/marceluda/rp_dummy)

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

## Dummy Simulator

[Repositorio](https://github.com/marceluda/rp_dummy_simulator)

Simulador de picos espectrales, para probar barridos y lockeos.
