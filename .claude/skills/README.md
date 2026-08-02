# Skills — TOM

Duas skills com as convenções operacionais do projeto. Carregadas **sob demanda** (só quando a tarefa se encaixa), diferente do `CLAUDE.md`, que entra em toda sessão.

| Skill | Dispara quando | Cobre |
|---|---|---|
| `tom-git-workflow` | commitar, criar branch, abrir PR, taggear release, "commit this", "push", "ship it" | Nomenclatura de branch, Conventional Commits com os escopos do monorepo, política de squash, releases como tags, regras extras do `tom-pro` |
| `tom-pr-writer` | "escreve o PR", "draft a PR description", terminar uma branch, revisar descrição existente | Inspecionar o diff real antes de escrever, título = Conventional Commit do squash, template What/Why/Notes, checklist condicional |

## Destino: só o repo público

As skills vivem em **`tom/.claude/skills/`** e em nenhum outro lugar:

- Versionadas com o projeto e disponíveis para qualquer pessoa que clone e use o Claude Code — o `tom-git-workflow` só cumpre seu papel se o contribuidor externo também o receber.
- O **`tom-pro` as herda por caminho relativo** (`~/dev/tom/.claude/skills/`), como já faz com a doc. O setup do repo comercial exige os dois clones lado a lado, então o caminho resolve. **Nunca copiar para lá** — cópia divergente é pior que nenhuma cópia; ambas as skills já têm uma seção final cobrindo o que muda no `tom-pro`.
- A pasta `skills/` deste pacote é só uma cópia avulsa para conveniência (instalar no perfil pessoal, se quiser tê-las fora dos repos). A fonte da verdade é o repo público.

## Manutenção

As skills espelham o `CONTRIBUTING.md` e as decisões. Ao mudar uma convenção (escopos novos, política de merge, formato de release), atualizar os três: `CONTRIBUTING.md`, a skill correspondente e — se for decisão arquitetural — um arquivo em `docs/decisions/`. Como o `tom-pro` referencia as skills por caminho em vez de copiá-las, ele acompanha automaticamente.
