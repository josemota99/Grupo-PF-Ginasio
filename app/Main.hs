-- | Demonstração da Fase 1: toda a lógica está em 'Domain'; aqui só há IO.
module Main (main) where

import System.IO (hSetEncoding, stdout, utf8)

import Domain
import Format
import Model
import SampleData

main :: IO ()
main = do
  hSetEncoding stdout utf8
  let g = ginasioExemplo

  titulo "Membros (ordenados por nome)"
  mapM_ (putStrLn . descreverMembro) (ordenarPorNome (membros g))

  titulo "Estatísticas"
  putStrLn ("Membros ativos:     " ++ show (contarMembrosAtivos (membros g)))
  putStrLn ("Ativos no Premium:  " ++ show (contarPorPlano Premium (membros g)))
  putStrLn ("Ativos no Standard: " ++ show (contarPorPlano Standard (membros g)))
  putStrLn ("Ativos no Básico:   " ++ show (contarPorPlano Basico (membros g)))

  titulo "Aulas de segunda-feira"
  mapM_ (putStrLn . descreverAula) (aulasDoDia Segunda (aulas g))

  titulo "Lotação da aula 1 (Spinning)"
  putStrLn ("Inscritos: " ++ show (lugaresOcupados 1 (inscricoes g))
            ++ " | Tem vaga? "
            ++ maybe "aula inexistente" (simNao . (`temVaga` inscricoes g)) (procurarAula 1 (aulas g)))

  titulo "Tentativas de inscrição"
  tentar g 7 2  "Gabriela (Standard) em Yoga"
  tentar g 5 1  "Eva em Spinning (aula cheia)"
  tentar g 3 1  "Carla (Básico) em Spinning (plano não permite)"
  tentar g 4 2  "Daniel (suspenso) em Yoga"
  tentar g 1 99 "Ana numa aula que não existe"

  titulo "Pagamentos de outubro de 2026"
  putStrLn ("Receita recebida: " ++ formatarEuros (receitaDoMes 10 2026 (pagamentos g)))
  putStrLn ("Receita prevista: " ++ formatarEuros (receitaPrevista (membros g)))
  putStrLn "Membros em dívida:"
  mapM_ (putStrLn . ("  " ++) . descreverMembro) (membrosEmDivida 10 2026 g)

  titulo "Novo membro"
  let g' = adicionarMembro "Inês Carvalho" Standard (Data 2026 11 7) g
  putStrLn ("Último membro registado: "
            ++ maybe "?" descreverMembro
                 (procurarMembro (maiorIdMembro (membros g')) (membros g')))

simNao :: Bool -> String
simNao True  = "sim"
simNao False = "não"

titulo :: String -> IO ()
titulo t = putStrLn ("\n=== " ++ t ++ " ===")

tentar :: Ginasio -> Id -> Id -> String -> IO ()
tentar g m a descricao =
  putStrLn (descricao ++ ": " ++ resultado)
  where
    resultado = case inscrever m a g of
      Just _  -> "inscrição aceite"
      Nothing -> "recusada"
