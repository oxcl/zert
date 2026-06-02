# Comparação de gerenciadores de plugins Zsh

Este documento compara o Zert com os gerenciadores de plugins Zsh mais amplamente utilizados. Destina-se a usuários experientes de Zsh que estão avaliando qual gerenciador de plugins se adapta ao seu fluxo de trabalho. Cada entrada descreve como o gerenciador funciona, como os plugins são configurados e onde sua abordagem difere da do Zert.

A tabela de comparação mostra as dimensões principais de relance. As seções individuais abaixo fornecem contexto mais profundo para cada gerenciador.

---

## Tabela de Comparação

| Recurso | Zert | Antidote | Antibody | Antigen | Sheldon | Zap | Zgenom | Zim | Zinit | Zplug |
|---|---|---|---|---|---|---|---|---|---|---|
| **Escrito em** | Zsh | Zsh | Go | Zsh | Rust | Zsh | Zsh | Zsh | Zsh | Zsh |
| **Estilo de config** | Inline | Arquivo separado | Arquivo separado | Inline | Arquivo TOML | Inline | Inline | Arquivo `.zimrc` | Inline | Inline |
| **Lockfile** | Sim | Não | Não | Não | Não | Não | Não | Não | Não | Não |
| **Instalação paralela** | Sim | Sim | Sim | Não | Sim | Não | Não | Sim | Não | Sim |
| **Estratégia de carregamento** | Source direto | Arquivo estático | Arquivo estático | Pacote estático | Arquivo estático | Source direto | Arquivo estático | Arquivo estático | Modo turbo (async) | Cache |
| **Compilação bytecode** | Sim | Não | Não | Sim | N/A | Não | Opcional | Sim | Sim | Não |
| **Suporte OMZ** | Sim | Sim | Sim | Sim | Templates | Limitado | Sim | Sim | Sim (snippet) | Sim |
| **Suporte Prezto** | Sim | Sim | Não | Não | Templates | Não | Sim | Sim | Sim (snippet) | Sim |
| **Autogerenciamento** | Sim | Não | Não | Não | Não | Não | Não | Não | Não | Não |
| **Arquivos de config** | Nenhum | `plugins.txt` | `plugins.txt` | Nenhum | `plugins.toml` | Nenhum | Nenhum | `.zimrc` | Nenhum | Nenhum |
| **Binário externo** | Nenhum | Nenhum | Binário Go | Nenhum | Binário Rust | Nenhum | Nenhum | Nenhum | Nenhum | Nenhum |
| **Status** | Ativo | Ativo | Arquivado | Sem manutenção | Ativo | Ativo | Ativo | Ativo | Ativo | Abandonado |

---

## Antidote

**GitHub:** [mattmc3/antidote](https://github.com/mattmc3/antidote) · **Status:** Ativo

Antidote é um gerenciador de plugins puro em Zsh criado como sucessor do Antibody. Ele lê os plugins de um arquivo `~/.zsh_plugins.txt` (um plugin por linha), gera um script de carregamento estático contendo instruções `source`, e seu `.zshrc` carrega esse arquivo gerado. Em inicializações subsequentes do shell, apenas o arquivo estático é carregado — nenhuma re-análise das declarações de plugins ocorre.

A instalação é paralela. O carregamento é efetivamente uma única chamada `source`. O Antidote suporta plugins do Oh-My-Zsh e Prezto nativamente usando a notação abreviada `owner/repo`.

**vs Zert:** O Antidote usa um arquivo de configuração separado `plugins.txt`; o Zert declara plugins inline no `.zshrc`. O Antidote não tem lockfile — os plugins não estão fixados em SHAs de commits, então a reprodutibilidade entre máquinas depende do estado de cada clone. O Zert escreve um `zert.lock` que fixa cada plugin em um commit exato. Ambos são Zsh puro com instalações paralelas. A abordagem de arquivo estático do Antidote significa zero sobrecarga de análise no carregamento; o Zert analisa as declarações a cada inicialização, mas otimiza pulando operações de UI/git quando os plugins já estão sincronizados.

---

## Antibody

**GitHub:** [getantibody/antibody](https://github.com/getantibody/antibody) · **Status:** Arquivado (depreciado janeiro 2021)

O Antibody era um binário Go que gerenciava plugins do Zsh. Ele suportava um arquivo `plugins.txt` (semelhante ao Antidote) e podia gerar um arquivo de carregamento estático. Foi o predecessor do Antidote — seu autor o depreciou depois que os gerenciadores nativos do Zsh alcançaram seu desempenho.

A implementação Go do Antibody lidava com a análise e geração de arquivos, mas o carregamento real dos plugins era feito pelo comando `source` do Zsh, o que significa que o binário Go apenas reduzia a sobrecarga de análise de configuração, não a sobrecarga de carregamento de plugins.

**vs Zert:** O Antibody exigia um binário Go compilado; o Zert é Zsh puro. O Antibody não tinha lockfile nem fixação de commits. O Antibody está arquivado e não é mais mantido; o Zert está em desenvolvimento ativo. Ambos suportavam instalação paralela e carregamento estático. A diferença chave é o modelo de dependências — o Zert requer apenas `git` e `curl`, enquanto o Antibody exigia instalar e atualizar um binário Go.

---

## Antigen

**GitHub:** [zsh-users/antigen](https://github.com/zsh-users/antigen) · **Status:** Sem manutenção

O Antigen foi um dos primeiros gerenciadores de plugins Zsh, inspirado no Vundle/Pathogen do Vim. Ele introduziu o comando `antigen bundle` para declarar plugins inline e foi o primeiro a trazer compatibilidade com plugins do Oh-My-Zsh para o gerenciamento de plugins independentes. Versões posteriores adicionaram carregamento estático de pacotes e compilação bytecode.

O Antigen carrega os plugins sequencialmente. Ele não tem capacidade de instalação paralela. O tempo de início limpo é de cerca de 60ms, mais lento que as alternativas modernas.

**vs Zert:** Ambos usam declarações inline. O Antigen não tem lockfile, nem instalação paralela, nem fixação de commits. O Antigen está sem manutenção; o Zert está ativo. A compilação bytecode do Antigen é anterior à do Zert, mas a estratégia de clone paralelo + clone treeless do Zert torna a instalação significativamente mais rápida. O Antigen suporta apenas Oh-My-Zsh; o Zert também suporta Prezto.

---

## Sheldon

**GitHub:** [rossmacarthur/sheldon](https://github.com/rossmacarthur/sheldon) · **Status:** Ativo

O Sheldon é um gerenciador de plugins de shell escrito em Rust. Ele usa um arquivo de configuração TOML (`plugins.toml`) e gera um script de carregamento estático. Como a análise e geração de arquivos acontecem em Rust, a sobrecarga de inicialização do Zsh é mínima — o shell apenas carrega o arquivo pré-gerado.

O Sheldon suporta plugins de repositórios Git (com fixação de branch/tag/commit), GitHub Gists, scripts remotos, plugins locais e inline. Ele usa um sistema de templates para métodos de instalação flexíveis. É agnóstico ao shell, funcionando com Bash e Zsh.

**vs Zert:** O Sheldon exige um binário Rust; o Zert é Zsh puro. O Sheldon usa um arquivo de configuração TOML; o Zert usa declarações inline. O Sheldon não tem lockfile; o `zert.lock` do Zert fixa cada plugin em um commit exato. O Sheldon é agnóstico ao shell; o Zert é específico do Zsh. O sistema de templates do Sheldon é mais configurável, mas adiciona complexidade; a abordagem do Zert é mais simples com padrões sensatos. Ambos suportam instalação paralela.

---

## Zap

**GitHub:** [zap-zsh/zap](https://github.com/zap-zsh/zap) · **Status:** Ativo

O Zap é um gerenciador de plugins minimalista do Zsh. Os plugins são declarados inline usando comandos `plug` no `.zshrc`. Ele clona os plugins na primeira carga e os carrega diretamente — sem geração de arquivos estáticos, sem compilação bytecode, sem cache. Toda a base de código é pequena.

O Zap fornece subcomandos `zap update`, `zap list` e `zap clean`. Ele suporta plugins locais e prefixos URL personalizados para repositórios privados. Não tem integração com Oh-My-Zsh ou Prezto.

**vs Zert:** Ambos usam declarações inline e são Zsh puro. O Zap é o mais próximo em filosofia do Zert — minimalista, inline, sem arquivos de configuração. No entanto, o Zap não tem lockfile, nem instalação paralela, nem compilação bytecode, e compatibilidade limitada com frameworks. O Zert adiciona reprodutibilidade (lockfile), desempenho (paralelo + compilação) e suporte OMZ/Prezto sobre o mesmo modelo inline. O Zap é mais simples; o Zert é mais capaz.

---

## Zgenom

**GitHub:** [jandamm/zgenom](https://github.com/jandamm/zgenom) · **Status:** Ativo

O Zgenom é o fork mantido do zgen. Ele usa uma abordagem de "gerar uma vez, carregar muitas vezes": os plugins são declarados com comandos `zgenom load` dentro de um bloco `if ! zgenom saved; then ... zgenom save; fi`. Na primeira execução, ele clona os plugins e gera um script de init estático. Em execuções subsequentes, ele carrega esse script diretamente.

O Zgenom suporta Oh-My-Zsh e Prezto, auto-atualização em um agendamento configurável, `--pin` para plugins individuais, e `zgenom compile` para compilação bytecode. Ele também tem um recurso `zgenom autoupdate` que verifica atualizações periodicamente em segundo plano sem diminuir a velocidade de inicialização.

**vs Zert:** Ambos são Zsh puro com declarações inline e suporte OMZ/Prezto. O Zgenom requer um `zgenom reset` manual após alterar declarações de plugins para regenerar o script de init; o Zert detecta alterações automaticamente em cada carga. O `--pin` do Zgenom existe para plugins individuais, mas não há um lockfile global; o `zert.lock` do Zert fixa cada plugin atomicamente. A abordagem de arquivo estático do Zgenom significa zero sobrecarga de análise em cargas quentes; o Zert analisa declarações a cada vez, mas cortocircuita quando os plugins já estão sincronizados. O Zgenom não tem instalação paralela; o Zert clona em paralelo.

---

## Zim (zimfw)

**GitHub:** [zimfw/zimfw](https://github.com/zimfw/zimfw) · **Status:** Ativo

O Zim é um framework de configuração do Zsh que empacota um gerenciador de plugins com módulos curados. Ele usa um arquivo separado `~/.zimrc` com chamadas `zmodule` para definir módulos. Ele constrói um script estático `init.zsh` e compila agressivamente todos os arquivos Zsh para bytecode. Os tempos de carga em caliente são extremamente rápidos — cerca de 0.009s em benchmarks.

O Zim fornece seus próprios módulos (ambiente, git, entrada, completamento, etc.) junto com plugins externos. Ele suporta uma ferramenta `degit` (baseada em curl/wget) como alternativa ao git para instalações mais rápidas e leves em repositórios GitHub. Os módulos podem definir arquivos de carga personalizados, funções de auto-carregamento e hooks pós-pull.

**vs Zert:** O Zim é um framework com gerenciador de plugins; o Zert é um gerenciador de plugins independente. O Zim usa um arquivo de configuração separado `.zimrc`; o Zert usa declarações inline. O Zim não tem lockfile. A compilação agressiva de bytecode do Zim dá a ele os tempos de carga em caliente mais rápidos do ecossistema. O Zert também compila, mas a integração em nível de framework do Zim significa que ele compila sua própria infraestrutura também. A opção `degit` do Zim troca histórico git por downloads mais rápidos; o Zert sempre usa git. O conjunto de módulos curados do Zim é um pró (padrões prontos para uso) e um contra (menos flexível do que escolher de repositórios arbitrários).

---

## Zinit

**GitHub:** [zdharma-continuum/zinit](https://github.com/zdharma-continuum/zinit) · **Status:** Ativo (mantido pela comunidade após o autor original excluir o projeto em 2021)

O Zinit é o gerenciador de plugins Zsh com mais recursos. Seu recurso definidor é o "modo turbo" — os plugins carregam de forma assíncrona após o prompt aparecer, ocultando a latência de carregamento. Ele também fornece compilação bytecode, relatórios de plugins (mostrando quais aliases, funções e completamentos o plugin configura), um sistema de annex para extensibilidade, e serviços para processos em segundo plano.

O Zinit usa `zinit light` para plugins e `zinit snippet` para carregar arquivos individuais de repositórios Oh-My-Zsh ou Prezto. Ele tem um complexo sistema de "modificadores ice" (`atload`, `wait`, `depth`, `lucid`, etc.) que controla como e quando os plugins carregam. O modo turbo pode reduzir a inicialização percebida em 50-80%, embora tenha compensações — alguns plugins esperam carregamento síncrono e quebram quando diferidos.

**vs Zert:** O Zinit é o gerenciador mais complexo; o Zert é deliberadamente simples. O Zinit tem modo turbo (carregamento assíncrono); o Zert carrega tudo de forma síncrona antes do prompt. O Zinit não tem lockfile; o `zert.lock` do Zert fixa cada commit. O sistema de modificadores ice do Zinit é poderoso, mas tem uma curva de aprendizado íngreme; os flags do Zert `--pin`, `--branch`, `--no-alias` cobrem casos comuns sem complexidade. O Zinit é mantido pela comunidade após uma história turbulenta; o Zert está em desenvolvimento ativo. Ambos suportam OMZ/Prezto e compilação bytecode. O Zinit resolve a latência percebida; o Zert resolve a reprodutibilidade.

---

## Zplug

**GitHub:** [zplug/zplug](https://github.com/zplug/zplug) · **Status:** Abandonado

O Zplug foi um gerenciador de plugins rico em recursos que suportava instalação paralela, carregamento preguiçoso, gerenciamento de dependências entre plugins, fixação de branch/tag/commit e hooks pós-atualização. Ele gerenciava plugins do GitHub, Bitbucket, Oh-My-Zsh, Prezto e diretórios locais.

Apesar de seu conjunto de recursos, o Zplug tinha uma implementação deficiente — o tempo de início limpo era de cerca de 160ms, significativamente mais lento que as alternativas. O projeto foi abandonado sem commits recentes.

**vs Zert:** Ambos usam declarações inline. O Zplug tinha instalação paralela e cache, mas com desempenho ruim; o Zert alcança instalações paralelas com sobrecarga mínima através de clones treeless. O Zplug não tem lockfile; o `zert.lock` do Zert fornece reprodutibilidade. O Zplug está abandonado; o Zert está ativo. O gerenciamento de dependências entre plugins do Zplug era um recurso único que o Zert não replica. O carregamento preguiçoso do Zplug era conceitualmente semelhante ao modo turbo do Zinit, mas pior implementado.

---

## Zsh Unplugged / Zcomet

**GitHub:** [mattmc3/zsh_unplugged](https://github.com/mattmc3/zsh_unplugged) / [menacel-mgmt/zcomet](https://github.com/menacel-mgmt/zcomet) · **Status:** Ativo

O Zsh Unplugged não é um gerenciador de plugins — é uma função `plugin-load` de ~20 linhas que demonstra como gerenciar plugins Zsh sem nenhum gerenciador. Ela clona repositórios, encontra o arquivo `.zsh` apropriado e o carrega. A intenção é desmistificar o que os gerenciadores de plugins fazem e mostrar que para configurações básicas, uma ferramenta independente é desnecessária.

O Zcomet é um gerenciador de plugins minimalista do mesmo autor que formaliza a abordagem unplugged. Ele alcança pontuações excelentes em benchmarks (10% de atraso no primeiro prompt, 44% de atraso no primeiro comando) com uma base de código minúscula.

**vs Zert:** O Zsh Unplugged é um exercício educacional; o Zert é uma ferramenta de produção. A abordagem unplugged não tem lockfile, nem instalação paralela, nem compilação, nem compatibilidade com frameworks, nem UI. O Zcomet adiciona estrutura, mas permanece minimalista — sem lockfile, sem instalação paralela. Ambas as filosofias rejeitam a complexidade, mas o Zert adiciona ferramentas de reprodutibilidade e desempenho mantendo o mesmo modelo de declarações inline. Se você quer a configuração mais simples possível e está disposto a gerenciar versões manualmente, a abordagem unplugged funciona. Se você quer reprodutibilidade sem pensar nisso, o Zert preenche essa lacuna.
