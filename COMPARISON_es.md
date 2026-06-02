# Comparación de gestores de plugins Zsh

Este documento compara Zert con los gestores de plugins Zsh más utilizados. Está dirigido a usuarios experimentados de Zsh que evalúan qué gestor de plugins se adapta a su flujo de trabajo. Cada entrada describe cómo funciona el gestor, cómo se configuran los plugins y dónde su enfoque difiere del de Zert.

La tabla de comparación muestra las dimensiones clave de un vistazo. Las secciones individuales a continuación proporcionan un contexto más profundo para cada gestor.

---

## Tabla de Comparación

| Característica | Zert | Antidote | Antibody | Antigen | Sheldon | Zap | Zgenom | Zim | Zinit | Zplug |
|---|---|---|---|---|---|---|---|---|---|---|
| **Escrito en** | Zsh | Zsh | Go | Zsh | Rust | Zsh | Zsh | Zsh | Zsh | Zsh |
| **Estilo de config** | Inline | Archivo separado | Archivo separado | Inline | Archivo TOML | Inline | Inline | Archivo `.zimrc` | Inline | Inline |
| **Lockfile** | Sí | No | No | No | No | No | No | No | No | No |
| **Instalación paralela** | Sí | Sí | Sí | No | Sí | No | No | Sí | No | Sí |
| **Estrategia de carga** | Source directo | Archivo estático | Archivo estático | Paquete estático | Archivo estático | Source directo | Archivo estático | Archivo estático | Modo turbo (async) | Caché |
| **Compilación bytecode** | Sí | No | No | Sí | N/A | No | Opcional | Sí | Sí | No |
| **Soporte OMZ** | Sí | Sí | Sí | Sí | Plantillas | Limitado | Sí | Sí | Sí (snippet) | Sí |
| **Soporte Prezto** | Sí | Sí | No | No | Plantillas | No | Sí | Sí | Sí (snippet) | Sí |
| **Autogestión** | Sí | No | No | No | No | No | No | No | No | No |
| **Archivos de config** | Ninguno | `plugins.txt` | `plugins.txt` | Ninguno | `plugins.toml` | Ninguno | Ninguno | `.zimrc` | Ninguno | Ninguno |
| **Binario externo** | Ninguno | Ninguno | Binario Go | Ninguno | Binario Rust | Ninguno | Ninguno | Ninguno | Ninguno | Ninguno |
| **Estado** | Activo | Activo | Archivado | Sin mantenimiento | Activo | Activo | Activo | Activo | Activo | Abandonado |

---

## Antidote

**GitHub:** [mattmc3/antidote](https://github.com/mattmc3/antidote) · **Estado:** Activo

Antidote es un gestor de plugins puro en Zsh creado como sucesor de Antibody. Lee los plugins de un archivo `~/.zsh_plugins.txt` (un plugin por línea), genera un script de carga estático que contiene sentencias `source`, y tu `.zshrc` carga ese archivo generado. En inicios de shell subsiguientes, solo se carga el archivo estático — no se produce un re-análisis de las declaraciones de plugins.

La instalación es paralela. La carga es efectivamente una sola llamada a `source`. Antidote soporta plugins de Oh-My-Zsh y Prezto de forma nativa usando la notación abreviada `owner/repo`.

**vs Zert:** Antidote usa un archivo de configuración separado `plugins.txt`; Zert declara plugins inline en `.zshrc`. Antidote no tiene lockfile — los plugins no están fijados a SHAs de commits, por lo que la reproducibilidad entre máquinas depende del estado de cada clon. Zert escribe un `zert.lock` que fija cada plugin a un commit exacto. Ambos son Zsh puro con instalaciones paralelas. El enfoque de archivo estático de Antidote significa cero sobrecarga de análisis en carga; Zert analiza las declaraciones en cada inicio pero optimiza saltando operaciones de UI/git cuando los plugins ya están sincronizados.

---

## Antibody

**GitHub:** [getantibody/antibody](https://github.com/getantibody/antibody) · **Estado:** Archivado (deprecado enero 2021)

Antibody era un binario Go que gestionaba plugins de Zsh. Soportaba un archivo `plugins.txt` (similar a Antidote) y podía generar un archivo de carga estático. Fue el predecesor de Antidote — su autor lo deprecó después de que los gestores nativos de Zsh igualaran su rendimiento.

La implementación Go de Antibody manejaba el análisis y la generación de archivos, pero la carga real de plugins la realizaba el comando `source` de Zsh, lo que significa que el binario Go solo reducía la sobrecarga de análisis de configuración, no la sobrecarga de carga de plugins.

**vs Zert:** Antibody requería un binario Go compilado; Zert es Zsh puro. Antibody no tenía lockfile ni fijación de commits. Antibody está archivado y ya no se mantiene; Zert está en desarrollo activo. Ambos soportaban instalación paralela y carga estática. La diferencia clave es el modelo de dependencias — Zert solo requiere `git` y `curl`, mientras que Antibody requería instalar y actualizar un binario Go.

---

## Antigen

**GitHub:** [zsh-users/antigen](https://github.com/zsh-users/antigen) · **Estado:** Sin mantenimiento

Antigen fue uno de los primeros gestores de plugins Zsh, inspirado en Vundle/Pathogen de Vim. Introdujo el comando `antigen bundle` para declarar plugins inline y fue el primero en traer compatibilidad con plugins de Oh-My-Zsh a la gestión de plugins independientes. Versiones posteriores añadieron carga estática de paquetes y compilación bytecode.

Antigen carga los plugins secuencialmente. No tiene capacidad de instalación paralela. El tiempo de inicio limpio es de alrededor de 60ms, más lento que las alternativas modernas.

**vs Zert:** Ambos usan declaraciones inline. Antigen no tiene lockfile, ni instalación paralela, ni fijación de commits. Antigen está sin mantenimiento; Zert está activo. La compilación bytecode de Antigen es anterior a la de Zert, pero la estrategia de clon paralelo + clon treeless de Zert hace la instalación significativamente más rápida. Antigen solo soporta Oh-My-Zsh; Zert también soporta Prezto.

---

## Sheldon

**GitHub:** [rossmacarthur/sheldon](https://github.com/rossmacarthur/sheldon) · **Estado:** Activo

Sheldon es un gestor de plugins de shell escrito en Rust. Usa un archivo de configuración TOML (`plugins.toml`) y genera un script de carga estático. Debido a que el análisis y la generación de archivos ocurren en Rust, la sobrecarga de inicio de Zsh es mínima — el shell solo carga el archivo pre-generado.

Sheldon soporta plugins de repositorios Git (con fijación de branch/tag/commit), GitHub Gists, scripts remotos, plugins locales e inline. Usa un sistema de plantillas para métodos de instalación flexibles. Es agnóstico al shell, funcionando tanto con Bash como con Zsh.

**vs Zert:** Sheldon requiere un binario Rust; Zert es Zsh puro. Sheldon usa un archivo de configuración TOML; Zert usa declaraciones inline. Sheldon no tiene lockfile; el `zert.lock` de Zert fija cada plugin a un commit exacto. Sheldon es agnóstico al shell; Zert es específico de Zsh. El sistema de plantillas de Sheldon es más configurable pero añade complejidad; el enfoque de Zert es más simple con valores predeterminados sensatos. Ambos soportan instalación paralela.

---

## Zap

**GitHub:** [zap-zsh/zap](https://github.com/zap-zsh/zap) · **Estado:** Activo

Zap es un gestor de plugins minimalista de Zsh. Los plugins se declaran inline usando comandos `plug` en `.zshrc`. Clona los plugins en la primera carga y los carga directamente — sin generación de archivos estáticos, sin compilación bytecode, sin caché. Toda la base de código es pequeña.

Zap proporciona subcomandos `zap update`, `zap list` y `zap clean`. Soporta plugins locales y prefijos URL personalizados para repositorios privados. No tiene integración con Oh-My-Zsh ni Prezto.

**vs Zert:** Ambos usan declaraciones inline y son Zsh puro. Zap es el más cercano en filosofía a Zert — minimalista, inline, sin archivos de configuración. Sin embargo, Zap no tiene lockfile, ni instalación paralela, ni compilación bytecode, y compatibilidad limitada con frameworks. Zert añade reproducibilidad (lockfile), rendimiento (paralelo + compilación) y soporte OMZ/Prezto sobre el mismo modelo inline. Zap es más simple; Zert es más capaz.

---

## Zgenom

**GitHub:** [jandamm/zgenom](https://github.com/jandamm/zgenom) · **Estado:** Activo

Zgenom es el fork mantenido de zgen. Toma un enfoque de "generar una vez, cargar muchas": los plugins se declaran con comandos `zgenom load` dentro de un bloque `if ! zgenom saved; then ... zgenom save; fi`. En la primera ejecución, clona los plugins y genera un script de init estático. En ejecuciones posteriores, carga ese script directamente.

Zgenom soporta Oh-My-Zsh y Prezto, auto-actualización en un horario configurable, `--pin` para plugins individuales, y `zgenom compile` para compilación bytecode. También tiene una función `zgenom autoupdate` que verifica actualizaciones periódicamente en segundo plano sin ralentizar el inicio.

**vs Zert:** Ambos son Zsh puro con declaraciones inline y soporte OMZ/Prezto. Zgenom requiere un `zgenom reset` manual después de cambiar declaraciones de plugins para regenerar el script de init; Zert detecta cambios automáticamente en cada carga. El `--pin` de Zgenom existe para plugins individuales pero no hay un lockfile global; el `zert.lock` de Zert fija cada plugin atómicamente. El enfoque de archivo estático de Zgenom significa cero sobrecarga de análisis en cargas en caliente; Zert analiza declaraciones cada vez pero cortocircuita cuando los plugins ya están sincronizados. Zgenom no tiene instalación paralela; Zert clona en paralelo.

---

## Zim (zimfw)

**GitHub:** [zimfw/zimfw](https://github.com/zimfw/zimfw) · **Estado:** Activo

Zim es un framework de configuración Zsh que empaqueta un gestor de plugins con módulos curados. Usa un archivo separado `~/.zimrc` con llamadas `zmodule` para definir módulos. Construye un script estático `init.zsh` y compila agresivamente todos los archivos Zsh a bytecode. Los tiempos de carga en caliente son extremadamente rápidos — alrededor de 0.009s en benchmarks.

Zim incluye sus propios módulos (entorno, git, entrada, completado, etc.) junto con plugins externos. Soporta una herramienta `degit` (basada en curl/wget) como alternativa a git para instalaciones más rápidas y ligeras en repos de GitHub. Los módulos pueden definir archivos de carga personalizados, funciones de auto-carga y hooks post-pull.

**vs Zert:** Zim es un framework con gestor de plugins; Zert es un gestor de plugins independiente. Zim usa un archivo de configuración separado `.zimrc`; Zert usa declaraciones inline. Zim no tiene lockfile. La compilación agresiva bytecode de Zim le da los tiempos de carga en caliente más rápidos del ecosistema. Zert también compila, pero la integración a nivel de framework de Zim significa que compila su propia infraestructura también. La opción `degit` de Zim intercambia historial git por descargas más rápidas; Zert siempre usa git. El conjunto de módulos curados de Zim es un pro (valores predeterminados listos para usar) y un con (menos flexible que seleccionar de repos arbitrarios).

---

## Zinit

**GitHub:** [zdharma-continuum/zinit](https://github.com/zdharma-continuum/zinit) · **Estado:** Activo (mantenido por la comunidad después de que el autor original eliminó el proyecto en 2021)

Zinit es el gestor de plugins Zsh con más características. Su rasgo definitorio es el "modo turbo" — los plugins cargan de forma asíncrona después de que aparece el prompt, ocultando la latencia de carga. También proporciona compilación bytecode, reportes de plugins (mostrando qué alias, funciones y completados establece un plugin), un sistema de annex para extensibilidad, y servicios para procesos en segundo plano.

Zinit usa `zinit light` para plugins y `zinit snippet` para cargar archivos individuales de repos de Oh-My-Zsh o Prezto. Tiene un complejo sistema de "modificadores ice" (`atload`, `wait`, `depth`, `lucid`, etc.) que controla cómo y cuándo cargan los plugins. El modo turbo puede reducir el inicio percibido en un 50-80%, aunque tiene compensaciones — algunos plugins esperan carga síncrona y fallan cuando se difieren.

**vs Zert:** Zinit es el gestor más complejo; Zert es deliberadamente simple. Zinit tiene modo turbo (carga asíncrona); Zert carga todo de forma síncrona antes del prompt. Zinit no tiene lockfile; el `zert.lock` de Zert fija cada commit. El sistema de modificadores ice de Zinit es poderoso pero tiene una curva de aprendizaje empinada; los flags de Zert `--pin`, `--branch`, `--no-alias` cubren casos comunes sin complejidad. Zinit es mantenido por la comunidad después de una historia turbulenta; Zert está en desarrollo activo. Ambos soportan OMZ/Prezto y compilación bytecode. Zinit resuelve la latencia percibida; Zert resuelve la reproducibilidad.

---

## Zplug

**GitHub:** [zplug/zplug](https://github.com/zplug/zplug) · **Estado:** Abandonado

Zplug fue un gestor de plugins rico en características que soportaba instalación paralela, carga diferida, gestión de dependencias entre plugins, fijación de branch/tag/commit y hooks post-actualización. Gestionaba plugins de GitHub, Bitbucket, Oh-My-Zsh, Prezto y directorios locales.

A pesar de su conjunto de características, Zplug tenía una implementación deficiente — el tiempo de inicio limpio era de alrededor de 160ms, significativamente más lento que las alternativas. El proyecto ha sido abandonado sin commits recientes.

**vs Zert:** Ambos usan declaraciones inline. Zplug tenía instalación paralela y caché pero con mal rendimiento; Zert alcanza instalaciones paralelas con sobrecarga mínima mediante clones treeless. Zplug no tiene lockfile; el `zert.lock` de Zert proporciona reproducibilidad. Zplug está abandonado; Zert está activo. La gestión de dependencias entre plugins de Zplug era una característica única que Zert no replica. La carga diferida de Zplug era conceptualmente similar al modo turbo de Zinit pero peor implementada.

---

## Zsh Unplugged / Zcomet

**GitHub:** [mattmc3/zsh_unplugged](https://github.com/mattmc3/zsh_unplugged) / [menacel-mgmt/zcomet](https://github.com/menacel-mgmt/zcomet) · **Estado:** Activo

Zsh Unplugged no es un gestor de plugins — es una función `plugin-load` de ~20 líneas que demuestra cómo gestionar plugins Zsh sin ningún gestor. Clona repos, encuentra el archivo `.zsh` apropiado y lo carga. La intención es desmitificar lo que hacen los gestores de plugins y mostrar que para configuraciones básicas, una herramienta independiente es innecesaria.

Zcomet es un gestor de plugins minimalista del mismo autor que formaliza el enfoque unplugged. Alcanza excelentes puntuaciones en benchmarks (10% de retraso en primer prompt, 44% de retraso en primer comando) con una base de código diminuta.

**vs Zert:** Zsh Unplugged es un ejercicio educativo; Zert es una herramienta de producción. El enfoque unplugged no tiene lockfile, ni instalación paralela, ni compilación, ni compatibilidad con frameworks, ni UI. Zcomet añade estructura pero sigue siendo minimalista — sin lockfile, sin instalación paralela. Ambas filosofías rechazan la complejidad, pero Zert añade herramientas de reproducibilidad y rendimiento manteniendo el mismo modelo de declaraciones inline. Si quieres la configuración más simple posible y estás dispuesto a gestionar versiones manualmente, el enfoque unplugged funciona. Si quieres reproducibilidad sin pensar en ello, Zert llena ese vacío.
