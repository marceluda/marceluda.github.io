---
layout: page
title: marceluda
subtitle: Página de proyectos
---

Acá voy a alojar los proyectos en los que trabajo. Por ahora, están los links de la barra de navegación.

## Proyectos en curso:

  - [Python para hacer física](https://marceluda.github.io/python-para-fisicos/)
    - Tutoriales en español para hacér tareas cotidianas de física
      ingeniería y ciencias en general en Python.
    - Estado: incipiente. Escrituro de los primeros artículos
  - [Lock-in+PID](https://marceluda.github.io/rp_lock-in_pid/):
    aplicación para [Red Pitaya](https://www.redpitaya.com/)
      - Implementación de un amplificador Lock-in y filtros PID para
        embebido programable en FPGA
      - Estado: Beta bastante avanzado
  - [Scope++](https://github.com/marceluda/rp_scope_lock) aplicación
    para [Red Pitaya](https://www.redpitaya.com/):
    - Versión extendida de la aplicación de osciloscopio Libre de la comunidad de Red Pitaya.
    - Incluye Generador de funciones, filtros PID elementales y osciloscopio.
    - Basada en [scope_release-v0.95](https://github.com/RedPitaya/RedPitaya/tree/release-v0.95/apps-free/scope)
  - [Dummy System](https://marceluda.github.io/rp_dummy), entorno de desarrollo de
    aplicaciones para [Red Pitaya](https://www.redpitaya.com/):
    - Entorno de programación con fines educativos.
    - Diseñado para simplificar el desarrollo de aplicaciones para RedPitaya con entorno web.
    - El sistema permite implementar de forma automatizada una aplicación para Red Pitaya que contenga:
      - El módulo de osciloscopio
      - El módulo de generador de funciones
      - El módulo de filtros PID
      - Un módulo Dummy a ser programado por el usuario, con la entradas y salidas ya programadas
      - Una serie de controles Web para usar en el diseño FPGA.
    - La creación de proyectos y la programación Web y en C está complemtamente automatizada, dejando
      al usuario sólo la tarea del diseño en FPGA.
