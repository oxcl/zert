<div align="center">

![Zert logo](./logo.png)

# ⚡ Zert

### Менеджер плагинов, который ждал ваш `.zshrc`

**Декларативный. Воспроизводимый. Чистый Zsh.**

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Zsh 5.0+](https://img.shields.io/badge/Zsh-5.0%2B-green?logo=gnu-bash&logoColor=white)](https://www.zsh.org/)
[![Pure Zsh](https://img.shields.io/badge/dependencies-git%20%2B%20curl-orange)](https://github.com/oxcl/zert)

</div>

---

Zert — это **менеджер плагинов на чистом Zsh**, построенный вокруг простой идеи: ваши плагины должны быть объявлены непосредственно в `.zshrc`, закреплены за точными коммитами и воспроизводимы на любой машине, как npm делает это для Node-проектов.

Нет файлов конфигурации для поддержки. Нет подкоманд для запоминания. Нет внешних инструментов. Только Zsh, `git` и `curl`.

---

## ✨ Возможности

- **Инлайновый декларативный синтаксис** — объявляйте плагины прямо в `.zshrc`. Отдельный файл конфигурации не требуется.
- **Воспроизводимость на основе lock-файла** — `zert.lock` закрепляет каждый плагин за точным git SHA коммита. Зафиксируйте его. Поделитесь. Воспроизведите где угодно.
- **Параллельная установка** — одновременное клонирование нескольких плагинов с использованием treeless-клонирования git для минимального расхода трафика.
- **Нулевые внешние зависимости UI** — красивый интерфейс полностью построен на ANSI escape-кодах.
- **Самоуправление** — подключите с помощью `zert zert` в `.zshrc`. Zert отслеживает и обновляет себя, как любой другой плагин.
- **Совместимость с Oh-My-Zsh / Prezto** — загружайте библиотеки OMZ и модули Prezto без установки фреймворков.

---

## 🚀 Установка

Вставьте это в начало вашего `.zshrc`:

```zsh
export ZERT_PLUGINS_DIR="${ZERT_PLUGINS_DIR:-${ZERT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/zert}/plugins}"; \
[[ -f "$ZERT_PLUGINS_DIR/zert/zert.zsh" ]] || \
(curl -fsSL https://raw.githubusercontent.com/oxcl/zert/main/bootstrap.sh | zsh); \
source "$ZERT_PLUGINS_DIR/zert/zert.zsh"

zert zert  # управление самим zert (опционально, включает автообновления)
```

Готово. При первом запуске shell Zert выполнит начальную настройку. При каждом последующем запуске он загружается мгновенно из кешированного клона.

---

## 📦 Использование

### Объявление плагинов

Добавьте строки `zert` в `.zshrc` после строки начальной настройки:

```zsh
# Самоуправление (опционально)
zert zert                          # отслеживать zert в lock-файле
zert zert --branch dev             # отслеживать特定ную ветку zert

# Сокращение GitHub
zert zsh-users/zsh-autosuggestions
zert zsh-users/zsh-syntax-highlighting

# Полный URL (GitHub или GitLab)
zert https://gitlab.com/someone/their-plugin.git

# Конкретная ветка
zert zsh-users/zsh-completions --branch main

# Закрепление за точным коммитом (приоритет над lock-файлом)
zert zsh-users/zsh-autosuggestions --pin a1b2c3d4e5f6

# Локальный плагин
zert $ZDOTDIR/local-plugins/my-work-plugin

# Совместимость с Oh-My-Zsh — загрузка библиотек OMZ без полного фреймворка
zert use ohmyzsh
zert ohmyzsh lib/clipboard
zert ohmyzsh plugins/git

# Совместимость с Prezto
zert use prezto
zert prezto modules/utility
```

### Флаги

| Флаг | Описание |
|------|----------|
| `--no-alias` | Пропустить загрузку определений алиасов плагина |
| `--no-completion` | Не добавлять файлы автодополнения в `fpath` |
| `--only-completion` | Только добавить в `fpath` — не загружать плагин |
| `--pin <sha>` | Закрепить за точным SHA коммита |
| `--branch <name>` | Клонировать конкретную ветку |

---

## 🔧 Подкоманды

```zsh
zert list          # Показать все объявленные плагины и их статус
zert update        # Получить последние коммиты для всех незакрепленных плагинов
zert prune         # Удалить плагины, больше не объявленные в конфигурации
```

---

## 🔒 Lock-файл

После каждой установки или обновления Zert записывает `zert.lock` в `$ZDOTDIR` (обычно `$HOME`):

```
# АВТОМАТИЧЕСКИ СОЗДАННЫЙ ФАЙЛ. НЕ РЕДАКТИРУЙТЕ ВРУЧНУЮ.
# Зафиксируйте этот файл в системе контроля версий для воспроизводимых установок.
version::1
zsh-users/zsh-autosuggestions::git::https://github.com/zsh-users/zsh-autosuggestions::a1b2c3d4e5f6...::pin=false
zsh-users/zsh-syntax-highlighting::git::https://github.com/zsh-users/zsh-syntax-highlighting::f7g8h9i0j1k2...::
ohmyzsh::ohmyzsh::ohmyzsh::3l4m5n6o7p8q...::
```

**Зафиксируйте `zert.lock` в вашем dotfiles-репозитории.** На новой машине Zert читает lock-файл и клонирует каждый плагин с точно тем же коммитом — бит в бит идентично вашим другим машинам.

---

## ⚙️ Конфигурация

Zert настраивается полностью через переменные окружения. Установите их перед строкой начальной настройки:

```zsh
export ZERT_DIR="$HOME/.zert"               # Изменить расположение Zert
export ZERT_PLUGINS_DIR="$ZERT_DIR/plugins" # Изменить расположение клонов плагинов
export ZERT_LOCKFILE="$HOME/.zert.lock"     # Изменить путь lock-файла
```

## 🏗️ Как это работает

```
Запуск .zshrc
│
├─ 1. Строка начальной настройки — source zert.zsh
│
├─ 2. Обработка объявлений zert (по порядку)
│   ├─ Отсутствующие плагины → параллельный git clone + zcompile
│   └─ Запись/обновление zert.lock
│
└─ 3. Загрузка плагинов (последовательно, строгий порядок)
    ├─ Загрузка основного файла каждого плагина
    └─ Остановка + отчёт при первой ошибке
```

**Установка параллельная. Загрузка последовательная.** Это даёт вам скорость параллельного клонирования без сюрпризов с порядком загрузки.

## 📄 Лицензия

GNU General Public License v3.0 — подробности в [`LICENSE`](./LICENSE).

---

<div align="center">

**Создано с непомерным вниманием к деталям.**

[github.com/oxcl/zert](https://github.com/oxcl/zert)

</div>
