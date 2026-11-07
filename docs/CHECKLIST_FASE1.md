# Checklist da Fase 1 — Gestão de Ginásio

Documento de apoio interno do grupo (não faz parte do código).

## 1. Antes de entregar

- [ ] `cabal build` sem erros nem avisos
- [ ] `cabal test` — todos os testes passam
- [ ] `cabal run ginasio` mostra a demonstração completa
- [ ] README com os nomes e números de **todos** os elementos do grupo
- [ ] Todos fizeram `git push` e o GitHub mostra commits de **cada** elemento
- [ ] Todos sabem explicar qualquer função (o professor pode perguntar a qualquer um)

## 2. Fluxo de Git do grupo (sem branches)

Regra de ouro: **`git pull` antes de começar a trabalhar.**

```bash
git pull                                  # 1. buscar novidades
# ... trabalhar ...
git add .                                 # 2. preparar
git commit -m "Descrição curta do que fiz"  # 3. guardar
git push                                  # 4. enviar
```

Se o push for rejeitado: `git pull` e voltar a fazer `git push`.

**Para evitar conflitos:** cada pessoa trabalha, tanto quanto possível, num módulo ou secção diferente (ver divisão abaixo) e faz commits pequenos e frequentes.

**Mensagens de commit** — curtas e no mesmo estilo, por exemplo:

- `Adiciona tipos Membro e Plano ao Model`
- `Implementa procurarMembro e contarMembrosAtivos`
- `Adiciona testes de inscrição (aula cheia, plano inválido)`
- `Atualiza README com instruções de execução`

## 3. Sugestão de divisão de tarefas

| Parte | Ficheiros | Responsável |
|-------|-----------|-------------|
| Modelo de domínio | `src/Model.hs` | *(nome)* |
| Membros e planos | `Domain.hs` (secções Planos e Membros) | *(nome)* |
| Aulas e inscrições | `Domain.hs` (secções Aulas e Inscrições) | *(nome)* |
| Pagamentos | `Domain.hs` (secção Pagamentos), `Format.hs` | *(nome)* |
| Dados, testes e README | `SampleData.hs`, `test/Spec.hs`, `README.md` | *(nome)* |

Todos devem rever o código dos outros antes da apresentação.

## 4. Perguntas que o professor pode fazer

1. Porque é que `Plano` e `Estado` são tipos algébricos e não `String`?
2. Porque é que o dinheiro está em cêntimos (`Int`) e não em `Double`?
3. Como funciona `lugaresOcupados`? Qual é o caso base e o passo recursivo?
4. Porque é que `inscrever` devolve `Maybe Ginasio`? Que problema tem (não diz *porquê* falhou)? Como se resolveria com `Either`?
5. Porque é que `Domain` não tem `IO`? Onde está o IO?
6. Como reescreveriam `contarMembrosAtivos` com `filter` e `length`? E com `foldr`?
7. O que acontece em `membrosEmDivida` com um membro que se inscreveu em novembro?
