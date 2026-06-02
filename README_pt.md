<div align="center">

![Zert logo](./logo.png)

# ⚡ Zert

### O gerenciador de plugins que seu `.zshrc` estava esperando

**Declarativo. Reprodutível. Zsh puro.**

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Zsh 5.0+](https://img.shields.io/badge/Zsh-5.0%2B-green?logo=gnu-bash&logoColor=white)](https://www.zsh.org/)
[![Pure Zsh](https://img.shields.io/badge/dependencies-git%20%2B%20curl-orange)](https://github.com/oxcl/zert)

</div>

---

Zert é um **gerenciador de plugins puro em Zsh** construído ao redor de uma ideia simples: seus plugins devem ser declarados diretamente no seu `.zshrc`, fixados em commits exatos e reproduzíveis em qualquer máquina, assim como npm faz para projetos Node.

Sem arquivos de configuração para manter. Sem subcomandos para memorizar. Sem ferramentas externas. Apenas Zsh, `git` e `curl`.

---

## ✨ Funcionalidades

- **Sintaxe declarativa inline** — declare plugins diretamente no `.zshrc`. Sem arquivo de configuração separado.
- **Reprodutibilidade baseada em lockfile** — `zert.lock` fixa cada plugin em um SHA de commit exato. Compartilhe. Replique em qualquer lugar.
- **Instalação paralela** — clona múltiplos plugins simultaneamente usando git treeless clones para mínimo uso de banda.
- **Zero dependências externas de UI** — interface bonita construída inteiramente com códigos de escape ANSI.
- **Autogerenciamento** — Ative com `zert zert` no seu `.zshrc`. Zert se rastreia e atualiza como qualquer outro plugin.
- **Compatibilidade com Oh-My-Zsh / Prezto** — carregue bibliotecas do OMZ e módulos do Prezto sem instalar nenhum dos frameworks.

---

## 🚀 Instalação

Cole isto no topo do seu `.zshrc`:

```zsh
export ZERT_PLUGINS_DIR="${ZERT_PLUGINS_DIR:-${ZERT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/zert}/plugins}"; \
[[ -f "$ZERT_PLUGINS_DIR/zert/zert.zsh" ]] || \
(curl -fsSL https://raw.githubusercontent.com/oxcl/zert/main/bootstrap.sh | zsh); \
source "$ZERT_PLUGINS_DIR/zert/zert.zsh"

zert zert  # gerenciar o próprio zert (opcional, habilita auto-atualizações)
```

É isso. Na primeira vez que seu shell iniciar, Zert faz seu bootstrap. Em cada inicialização subsequente, ele carrega instantaneamente do clonagem em cache.

---

## 📦 Uso

### Declarando Plugins

Adicione linhas `zert` ao seu `.zshrc` após a linha de bootstrap:

```zsh
# Autogerenciamento (opt-in)
zert zert                          # rastrear o próprio zert no lockfile
zert zert --branch dev             # rastrear uma branch específica do zert

# Abreviação do GitHub
zert zsh-users/zsh-autosuggestions
zert zsh-users/zsh-syntax-highlighting

# URL completa (GitHub ou GitLab)
zert https://gitlab.com/someone/their-plugin.git

# Branch específica
zert zsh-users/zsh-completions --branch main

# Fixar em um commit exato (tem precedência sobre o lockfile)
zert zsh-users/zsh-autosuggestions --pin a1b2c3d4e5f6

# Plugin local
zert $ZDOTDIR/local-plugins/my-work-plugin

# Compatibilidade com Oh-My-Zsh — carrega bibliotecas do OMZ sem o framework completo
zert use ohmyzsh
zert ohmyzsh lib/clipboard
zert ohmyzsh plugins/git

# Compatibilidade com Prezto
zert use prezto
zert prezto modules/utility
```

### Flags

| Flag | O que faz |
|------|-----------|
| `--no-alias` | Pula o carregamento das definições de alias do plugin |
| `--no-completion` | Não adiciona arquivos de completamento ao `fpath` |
| `--only-completion` | Apenas adiciona ao `fpath` — não carrega o plugin |
| `--pin <sha>` | Fixa em um SHA de commit exato |
| `--branch <name>` | Clona uma branch específica |

---

## 🔧 Subcomandos

```zsh
zert list          # Mostra todos os plugins declarados e seu status
zert update        # Puxa os últimos commits para todos os plugins não fixados
zert prune         # Remove plugins não mais declarados na sua configuração
```

---

## 🔒 O Lockfile

Após cada instalação ou atualização, Zert escreve `zert.lock` no seu `$ZDOTDIR` (geralmente `$HOME`):

```
# ARQUIVO AUTO-GERADO. NÃO EDITE MANUALMENTE.
# Commite este arquivo no controle de versão para instalações reproduzíveis.
version::1
zsh-users/zsh-autosuggestions::git::https://github.com/zsh-users/zsh-autosuggestions::a1b2c3d4e5f6...::pin=false
zsh-users/zsh-syntax-highlighting::git::https://github.com/zsh-users/zsh-syntax-highlighting::f7g8h9i0j1k2...::
ohmyzsh::ohmyzsh::ohmyzsh::3l4m5n6o7p8q...::
```

**Commite `zert.lock` no seu repositório de dotfiles.** Em uma máquina nova, Zert lê o lockfile e clona cada plugin no commit exato — idêntico bit a bit às suas outras máquinas.

---

## ⚙️ Configuração

Zert é configurado inteiramente através de variáveis de ambiente. Defina-as antes da linha de bootstrap:

```zsh
export ZERT_DIR="$HOME/.zert"               # Alterar onde o Zert fica
export ZERT_PLUGINS_DIR="$ZERT_DIR/plugins" # Alterar onde os plugins são clonados
export ZERT_LOCKFILE="$HOME/.zert.lock"     # Alterar o caminho do lockfile
```

## 🏗️ Como Funciona

```
Inicialização do .zshrc
│
├─ 1. Linha de bootstrap — source zert.zsh
│
├─ 2. Processar declarações zert (em ordem)
│   ├─ Plugins ausentes → git clone paralelo + zcompile
│   └─ Escrever/atualizar zert.lock
│
└─ 3. Carregar plugins (sequencial, ordem estrita)
    ├─ Carregar arquivo principal de cada plugin
    └─ Parar + reportar na primeira falha
```

**A instalação é paralela. O carregamento é sequencial.** Isso te dá a velocidade da clonagem paralela sem surpresas de ordenação.


## ⭐ Apoio

Se o Zert é útil para você, considere dar uma estrela no [GitHub](https://github.com/oxcl/zert) ou fazer uma [doação](https://oxcl.github.io/zert/#donate).


## 🔄 Comparação

O ecossistema de gerenciadores de plugins Zsh é grande — Antidote, Zinit, Sheldon, Zgenom, Zim e outros adotam abordagens diferentes para o mesmo problema. A maioria é rápida o suficiente para que as diferenças de desempenho sejam insignificantes. As distinções significativas se resumem ao estilo de configuração, reprodutibilidade e modelo de dependências. O Zert é o único gerenciador puro em Zsh com declarações inline e um lockfile para instalações reproduzíveis. Para uma análise completa, veja a [comparação](./COMPARISON_pt.md).

## 📄 Licença

GNU General Public License v3.0 — veja [`LICENSE`](./LICENSE) para detalhes.

---

<div align="center">

**Construído com atenção irracional aos detalhes.**

[github.com/oxcl/zert](https://github.com/oxcl/zert)

</div>
