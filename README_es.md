<div align="center">

![Zert logo](./logo.png)

# ⚡ Zert

### El gestor de plugins que tu `.zshrc` estaba esperando

**Declarativo. Reproducible. Zsh puro.**

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Zsh 5.0+](https://img.shields.io/badge/Zsh-5.0%2B-green?logo=gnu-bash&logoColor=white)](https://www.zsh.org/)
[![Pure Zsh](https://img.shields.io/badge/dependencies-git%20%2B%20curl-orange)](https://github.com/oxcl/zert)

</div>

---

Zert es un **gestor de plugins puro en Zsh** construido alrededor de una idea simple: tus plugins deben declararse directamente en tu `.zshrc`, fijados a commits exactos y reproducibles en cualquier máquina, tal como npm hace para los proyectos de Node.

Sin archivos de configuración que mantener. Sin subcomandos que memorizar. Sin herramientas externas. Solo Zsh, `git` y `curl`.

---

## ✨ Características

- **Sintaxis declarativa inline** — declara plugins directamente en `.zshrc`. Sin archivo de configuración separado.
- **Reproducibilidad basada en lockfile** — `zert.lock` fija cada plugin a un SHA de commit exacto. Compártelo. Reprodúcelo en cualquier lugar.
- **Instalación paralela** — clona múltiples plugins simultáneamente usando git treeless clones para mínimo ancho de banda.
- **Cero dependencias externas de UI** — hermosa interfaz construida completamente con códigos de escape ANSI.
- **Autogestión** — Actívalo con `zert zert` en tu `.zshrc`. Zert se rastrea y actualiza como cualquier otro plugin.
- **Compatibilidad con Oh-My-Zsh / Prezto** — carga librerías de OMZ y módulos de Prezto sin instalar ninguno de los frameworks.

---

## 🚀 Instalación

Pega esto en la parte superior de tu `.zshrc`:

```zsh
export ZERT_PLUGINS_DIR="${ZERT_PLUGINS_DIR:-${ZERT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/zert}/plugins}"; \
[[ -f "$ZERT_PLUGINS_DIR/zert/zert.zsh" ]] || \
(curl -fsSL https://raw.githubusercontent.com/oxcl/zert/main/bootstrap.sh | zsh); \
source "$ZERT_PLUGINS_DIR/zert/zert.zsh"

zert zert  # gestionar zert mismo (opcional, habilita auto-actualizaciones)
```

Eso es todo. La primera vez que tu shell se inicia, Zert se auto-configura. En cada inicio posterior, se carga instantáneamente desde el clon cacheado.

---

## 📦 Uso

### Declarar Plugins

Añade líneas `zert` a tu `.zshrc` después de la línea de bootstrap:

```zsh
# Autogestión (opt-in)
zert zert                          # rastrear zert mismo en el lockfile
zert zert --branch dev             # rastrear una rama específica de zert

# Abreviatura de GitHub
zert zsh-users/zsh-autosuggestions
zert zsh-users/zsh-syntax-highlighting

# URL completa (GitHub o GitLab)
zert https://gitlab.com/someone/their-plugin.git

# Rama específica
zert zsh-users/zsh-completions --branch main

# Fijar a un commit exacto (tiene precedencia sobre el lockfile)
zert zsh-users/zsh-autosuggestions --pin a1b2c3d4e5f6

# Plugin local
zert $ZDOTDIR/local-plugins/my-work-plugin

# Compatibilidad con Oh-My-Zsh — carga librerías de OMZ sin el framework completo
zert use ohmyzsh
zert ohmyzsh lib/clipboard
zert ohmyzsh plugins/git

# Compatibilidad con Prezto
zert use prezto
zert prezto modules/utility
```

### Banderas

| Banderas | Qué hace |
|----------|----------|
| `--no-alias` | Omite la carga de definiciones de alias del plugin |
| `--no-completion` | No añade archivos de completado a `fpath` |
| `--only-completion` | Solo añade a `fpath` — no carga el plugin |
| `--pin <sha>` | Fija a un SHA de commit exacto |
| `--branch <name>` | Clona una rama específica |

---

## 🔧 Subcomandos

```zsh
zert list          # Muestra todos los plugins declarados y su estado
zert update        # Obtiene los últimos commits para todos los plugins sin fijar
zert prune         # Elimina plugins ya no declarados en tu configuración
```

---

## 🔒 El Lockfile

Después de cada instalación o actualización, Zert escribe `zert.lock` en tu `$ZDOTDIR` (usualmente `$HOME`):

```
# ARCHIVO AUTO-GENERADO. NO EDITAR MANUALMENTE.
# Comprometa este archivo al control de versiones para instalaciones reproducibles.
version::1
zsh-users/zsh-autosuggestions::git::https://github.com/zsh-users/zsh-autosuggestions::a1b2c3d4e5f6...::pin=false
zsh-users/zsh-syntax-highlighting::git::https://github.com/zsh-users/zsh-syntax-highlighting::f7g8h9i0j1k2...::
ohmyzsh::ohmyzsh::ohmyzsh::3l4m5n6o7p8q...::
```

**Compromete `zert.lock` a tu repositorio de dotfiles.** En una máquina nueva, Zert lee el lockfile y clona cada plugin en el commit exacto — idéntico bit por bit a tus otras máquinas.

---

## ⚙️ Configuración

Zert se configura completamente a través de variables de entorno. Establécelas antes de la línea de bootstrap:

```zsh
export ZERT_DIR="$HOME/.zert"               # Cambiar dónde vive Zert
export ZERT_PLUGINS_DIR="$ZERT_DIR/plugins" # Cambiar dónde se clonan los plugins
export ZERT_LOCKFILE="$HOME/.zert.lock"     # Cambiar la ruta del lockfile
```

## 🏗️ Cómo Funciona

```
Inicio de .zshrc
│
├─ 1. Línea de bootstrap — source zert.zsh
│
├─ 2. Procesar declaraciones zert (en orden)
│   ├─ Plugins faltantes → git clone paralelo + zcompile
│   └─ Escribir/actualizar zert.lock
│
└─ 3. Cargar plugins (secuencial, orden estricto)
    ├─ Cargar archivo principal de cada plugin
    └─ Detener + reportar en el primer fallo
```

**La instalación es paralela. La carga es secuencial.** Esto te da la velocidad de la clonación paralela sin sorpresas de ordenamiento.


## ⭐ Apoyo

Si Zert te es útil, considera darle una estrella en [GitHub](https://github.com/oxcl/zert) o hacer una [donación](https://oxcl.github.io/zert/#donate).


## 📄 Licencia

GNU General Public License v3.0 — ver [`LICENSE`](./LICENSE) para detalles.

---

<div align="center">

**Construido con atención irracional al detalle.**

[github.com/oxcl/zert](https://github.com/oxcl/zert)

</div>
