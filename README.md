# Gestão de Ginásio — Programação Funcional (Haskell)

Projeto semestral de grupo de **Programação Funcional** (UTAD, Licenciatura em Engenharia Informática).
Este repositório está na **Fase 1 — Modelação e núcleo funcional**.

## Grupo

| Nº | Nome |
|----|------|
| al2025157657 | José Mota |
| al2025166979 | Simão Dias |
| al2025169084 | Rui Monteiro

## Descrição do projeto

Sistema de gestão de um ginásio que permite:

- registar **membros**, cada um com um **plano** (Básico, Standard, Premium) e um **estado** (Ativo, Suspenso, Cancelado);
- gerir **aulas** de várias modalidades, com instrutor, dia, hora e capacidade;
- **inscrever** membros em aulas, respeitando regras de negócio (plano, estado, lotação, inscrições repetidas);
- acompanhar **pagamentos** mensais, receita recebida/prevista e membros em dívida.

**Utilizadores previstos:** rececionista/gestor do ginásio.

### Regras de negócio já implementadas

| Regra | Onde |
|-------|------|
| Mensalidade: Básico 20 €, Standard 30 €, Premium 45 € | `Domain.precoMensal` |
| Básico só acede a Musculação; Standard a tudo exceto CrossTraining; Premium a tudo | `Domain.planoPermite` |
| Só membros **ativos** se podem inscrever | `Domain.inscrever` |
| Não há inscrições repetidas nem acima da capacidade da aula | `Domain.inscrever` |
| Em dívida = ativo, já membro nesse mês e sem pagamento desse mês | `Domain.membrosEmDivida` |

## Requisitos

- [GHC](https://www.haskell.org/ghc/) 9.4 ou superior e [cabal-install](https://www.haskell.org/cabal/) 3.8 ou superior
  (a forma mais simples de instalar é o [GHCup](https://www.haskell.org/ghcup/)).
- Não são usadas bibliotecas externas: apenas `base`.

## Compilar, executar e testar

Na pasta do projeto:

```bash
cabal update          # só na primeira vez
cabal build           # compila tudo
cabal run ginasio     # corre a demonstração
cabal test            # corre os testes automáticos
```

Alternativa sem cabal (a partir da pasta do projeto):

```bash
ghc -isrc -outputdir build -o ginasio app/Main.hs && ./ginasio
ghc -isrc -outputdir build -o spec test/Spec.hs && ./spec
```

> **Windows:** se os acentos aparecerem trocados no terminal, correr `chcp 65001` antes de executar.

## Estrutura do projeto

```
ginasio/
├── README.md
├── cabal.project
├── ginasio.cabal
├── src/
│   ├── Model.hs        -- tipos de dados (data, type, records)
│   ├── Domain.hs       -- regras de negócio: funções puras e recursivas
│   ├── Format.hs       -- formatação de texto (euros, datas, descrições)
│   └── SampleData.hs   -- dados de teste para demonstração
├── app/
│   └── Main.hs         -- demonstração (único módulo com IO)
├── test/
│   └── Spec.hs         -- testes das funções puras e casos limite
└── docs/
    └── CHECKLIST_FASE1.md
```

## Modelo de domínio

```
Ginasio ──┬── [Membro]      (id, nome, Plano, Estado, Data de inscrição)
          ├── [Instrutor]   (id, nome, [Modalidade])
          ├── [Aula]        (id, Modalidade, instrutor, DiaSemana, hora, capacidade)
          ├── [Inscricao]   (membro, aula)        -- relação N-para-N
          └── [Pagamento]   (membro, mês, ano, valor em cêntimos)
```

Decisões de modelação:

- **Valores em cêntimos (`Int`)** para evitar erros de vírgula flutuante; `Format.formatarEuros` trata da apresentação.
- **`Plano`, `Estado`, `Modalidade` e `DiaSemana` são tipos algébricos** (enumerações), pelo que o compilador obriga a tratar todos os casos.
- **Relações por identificador** (`aulaInstrutor`, `inscMembro`, `inscAula`, `pagMembro`), como numa base de dados relacional.
- **Estado imutável:** `Ginasio` é um valor; as operações devolvem um novo `Ginasio` em vez de alterar o anterior.

## O que a Fase 1 cobre

| Requisito da Fase 1 | Como está coberto |
|---------------------|-------------------|
| Modelo de domínio | `src/Model.hs` |
| Estrutura do projeto | Módulos `Model`, `Domain`, `Format`, `SampleData`; IO isolado em `app/Main.hs` |
| Funções essenciais | `src/Domain.hs` (planos, membros, aulas, inscrições, pagamentos) |
| Recursão | Todas as listas percorridas com recursão explícita e pattern matching (`contarMembrosAtivos`, `lugaresOcupados`, `receitaDoMes`, `ordenarPorNome`, …) |
| Dados de teste | `src/SampleData.hs` (8 membros, 3 instrutores, 6 aulas, inscrições e pagamentos) |
| README | Este ficheiro |
| Git | Histórico de commits do grupo |

## Próximos passos

- **Fase 2:** reescrever funções com `map`, `filter` e `foldr`; usar `Either` para devolver o *motivo* de uma inscrição recusada (em vez de `Nothing`); estatísticas e rankings; mais testes de erro.
- **Fase 3:** leitura/escrita de ficheiros, parsing e validação, menu textual, relatórios, relatório final e defesa.
