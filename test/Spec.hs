-- | Testes das funções puras de 'Domain' e 'Format'.
--
-- Sem dependências externas: cada teste é um par (descrição, resultado).
module Main (main) where

import System.Exit (exitFailure, exitSuccess)
import System.IO (hSetEncoding, stdout, utf8)

import Domain
import Format
import Model
import SampleData

type Teste = (String, Bool)

main :: IO ()
main = do
  hSetEncoding stdout utf8
  let falhados = [d | (d, ok) <- testes, not ok]
  mapM_ (\(d, ok) -> putStrLn ((if ok then "  [ok]   " else "  [FALHA] ") ++ d)) testes
  putStrLn ""
  putStrLn (show (length testes - length falhados) ++ "/" ++ show (length testes) ++ " testes passaram")
  if null falhados then exitSuccess else exitFailure

testes :: [Teste]
testes = concat [testesPlanos, testesMembros, testesAulas, testesInscricoes, testesPagamentos, testesFormat]

g :: Ginasio
g = ginasioExemplo

-- ---------------------------------------------------------------------------

testesPlanos :: [Teste]
testesPlanos =
  [ ("precoMensal Basico = 2000",    precoMensal Basico == 2000)
  , ("precoMensal Premium = 4500",   precoMensal Premium == 4500)
  , ("Premium permite CrossTraining", planoPermite Premium CrossTraining)
  , ("Standard não permite CrossTraining", not (planoPermite Standard CrossTraining))
  , ("Standard permite Yoga",        planoPermite Standard Yoga)
  , ("Básico só permite Musculação", planoPermite Basico Musculacao && not (planoPermite Basico Zumba))
  ]

testesMembros :: [Teste]
testesMembros =
  [ ("procurarMembro encontra o membro 3", fmap membroNome (procurarMembro 3 (membros g)) == Just "Carla Mendes")
  , ("procurarMembro id inexistente -> Nothing", procurarMembro 99 (membros g) == Nothing)
  , ("procurarMembro em lista vazia -> Nothing", procurarMembro 1 [] == Nothing)
  , ("contarMembrosAtivos = 6", contarMembrosAtivos (membros g) == 6)
  , ("contarMembrosAtivos [] = 0", contarMembrosAtivos [] == 0)
  , ("contarPorPlano Premium = 2", contarPorPlano Premium (membros g) == 2)
  , ("contarPorPlano Standard = 2 (ignora suspenso)", contarPorPlano Standard (membros g) == 2)
  , ("contarPorPlano Basico = 2 (ignora cancelado)", contarPorPlano Basico (membros g) == 2)
  , ("maiorIdMembro [] = 0", maiorIdMembro [] == 0)
  , ("proximoIdMembro = 9", proximoIdMembro (membros g) == 9)
  , ("adicionarMembro dá id 9 e estado Ativo",
      case procurarMembro 9 (membros (adicionarMembro "Novo" Premium (Data 2026 11 7) g)) of
        Just m  -> membroEstado m == Ativo && membroNome m == "Novo"
        Nothing -> False)
  , ("adicionarMembro ao ginásio vazio dá id 1",
      map membroId (membros (adicionarMembro "A" Basico (Data 2026 1 1) (Ginasio [] [] [] [] []))) == [1])
  , ("atualizarEstado suspende o membro 1",
      fmap membroEstado (procurarMembro 1 (atualizarEstado 1 Suspenso (membros g))) == Just Suspenso)
  , ("atualizarEstado com id inexistente não altera", atualizarEstado 99 Cancelado (membros g) == membros g)
  , ("ordenarPorNome ordena alfabeticamente",
      map membroNome (ordenarPorNome (reverse (membros g))) == map membroNome (membros g))
  , ("ordenarPorNome [] = []", ordenarPorNome [] == [])
  ]

testesAulas :: [Teste]
testesAulas =
  [ ("procurarAula 2 é Yoga", fmap aulaModalidade (procurarAula 2 (aulas g)) == Just Yoga)
  , ("procurarAula 99 -> Nothing", procurarAula 99 (aulas g) == Nothing)
  , ("aulasDoDia Segunda -> aulas 1 e 5", map aulaId (aulasDoDia Segunda (aulas g)) == [1, 5])
  , ("aulasDoDia Domingo -> []", aulasDoDia Domingo (aulas g) == [])
  , ("aulasDaModalidade Pilates -> aula 4", map aulaId (aulasDaModalidade Pilates (aulas g)) == [4])
  ]

testesInscricoes :: [Teste]
testesInscricoes =
  [ ("lugaresOcupados aula 1 = 2", lugaresOcupados 1 (inscricoes g) == 2)
  , ("lugaresOcupados aula 6 = 0", lugaresOcupados 6 (inscricoes g) == 0)
  , ("estaInscrito 1 1", estaInscrito 1 1 (inscricoes g))
  , ("não está inscrito 3 1", not (estaInscrito 3 1 (inscricoes g)))
  , ("inscrição válida é aceite",
      fmap (\x -> lugaresOcupados 2 (inscricoes x)) (inscrever 7 2 g) == Just 3)
  , ("aula cheia recusa inscrição", inscrever 5 1 g == Nothing)
  , ("plano sem acesso recusa inscrição", inscrever 3 1 g == Nothing)
  , ("membro suspenso recusa inscrição", inscrever 4 2 g == Nothing)
  , ("membro cancelado recusa inscrição", inscrever 6 5 g == Nothing)
  , ("aula inexistente recusa inscrição", inscrever 1 99 g == Nothing)
  , ("membro inexistente recusa inscrição", inscrever 99 2 g == Nothing)
  , ("inscrição repetida é recusada", inscrever 1 2 g == Nothing)
  , ("removerInscricao tira a inscrição", not (estaInscrito 1 1 (removerInscricao 1 1 (inscricoes g))))
  , ("removerInscricao inexistente não altera", removerInscricao 9 9 (inscricoes g) == inscricoes g)
  , ("depois de remover, a aula 1 volta a ter vaga",
      case procurarAula 1 (aulas g) of
        Just a  -> temVaga a (removerInscricao 1 1 (inscricoes g))
        Nothing -> False)
  ]

testesPagamentos :: [Teste]
testesPagamentos =
  [ ("totalPagamentos = 21500", totalPagamentos (pagamentos g) == 21500)
  , ("totalPagamentos [] = 0", totalPagamentos [] == 0)
  , ("receitaDoMes 10 2026 = 14000", receitaDoMes 10 2026 (pagamentos g) == 14000)
  , ("receitaDoMes 9 2026 = 7500", receitaDoMes 9 2026 (pagamentos g) == 7500)
  , ("receitaDoMes sem pagamentos = 0", receitaDoMes 1 2020 (pagamentos g) == 0)
  , ("temPagamento 1 10 2026", temPagamento 1 10 2026 (pagamentos g))
  , ("não temPagamento 7 10 2026", not (temPagamento 7 10 2026 (pagamentos g)))
  , ("em dívida em out/2026 = só a Gabriela", map membroId (membrosEmDivida 10 2026 g) == [7])
  , ("Hugo (inscrito em nov) não deve outubro", 8 `notElem` map membroId (membrosEmDivida 10 2026 g))
  , ("suspensos e cancelados não estão em dívida",
      all (`notElem` map membroId (membrosEmDivida 10 2026 g)) [4, 6])
  , ("receitaPrevista = 19000", receitaPrevista (membros g) == 19000)
  , ("receitaPrevista [] = 0", receitaPrevista [] == 0)
  ]

testesFormat :: [Teste]
testesFormat =
  [ ("formatarEuros 4500", formatarEuros 4500 == "45,00 €")
  , ("formatarEuros 5 (zero à esquerda nos cêntimos)", formatarEuros 5 == "0,05 €")
  , ("formatarEuros negativo", formatarEuros (-150) == "-1,50 €")
  , ("descreverData com zeros", descreverData (Data 2026 11 3) == "03/11/2026")
  ]
