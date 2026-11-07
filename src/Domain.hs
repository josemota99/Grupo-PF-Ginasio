-- | Regras de negócio do ginásio.
--
-- Todas as funções deste módulo são /puras/ (sem IO). Na Fase 1 as listas
-- são percorridas com recursão explícita e pattern matching, para treinar
-- o raciocínio recursivo. Na Fase 2 muitas destas funções podem ser
-- reescritas com 'map', 'filter' e 'foldr'.
module Domain
  ( -- * Planos
    precoMensal
  , planoPermite
    -- * Membros
  , procurarMembro
  , maiorIdMembro
  , proximoIdMembro
  , adicionarMembro
  , atualizarEstado
  , contarMembrosAtivos
  , membrosDoPlano
  , contarPorPlano
  , ordenarPorNome
    -- * Aulas
  , procurarAula
  , aulasDoDia
  , aulasDaModalidade
    -- * Inscrições
  , lugaresOcupados
  , temVaga
  , estaInscrito
  , inscrever
  , removerInscricao
    -- * Pagamentos
  , totalPagamentos
  , receitaDoMes
  , temPagamento
  , membrosEmDivida
  , receitaPrevista
  ) where

import Model

-- ---------------------------------------------------------------------------
-- Planos
-- ---------------------------------------------------------------------------

-- | Mensalidade de cada plano, em cêntimos.
precoMensal :: Plano -> Centimos
precoMensal Basico   = 2000
precoMensal Standard = 3000
precoMensal Premium  = 4500

-- | Indica se um plano dá acesso a uma modalidade.
--
-- * Básico: apenas musculação;
-- * Standard: tudo exceto crosstraining;
-- * Premium: tudo.
planoPermite :: Plano -> Modalidade -> Bool
planoPermite Premium  _             = True
planoPermite Standard CrossTraining = False
planoPermite Standard _             = True
planoPermite Basico   Musculacao    = True
planoPermite Basico   _             = False

-- ---------------------------------------------------------------------------
-- Membros
-- ---------------------------------------------------------------------------

-- | Procura um membro pelo identificador.
procurarMembro :: Id -> [Membro] -> Maybe Membro
procurarMembro _ [] = Nothing
procurarMembro i (m : ms)
  | membroId m == i = Just m
  | otherwise       = procurarMembro i ms

-- | Maior identificador existente (0 se a lista for vazia).
maiorIdMembro :: [Membro] -> Id
maiorIdMembro []       = 0
maiorIdMembro (m : ms) = max (membroId m) (maiorIdMembro ms)

-- | Próximo identificador livre.
proximoIdMembro :: [Membro] -> Id
proximoIdMembro ms = maiorIdMembro ms + 1

-- | Regista um novo membro (ativo) com o próximo identificador livre.
adicionarMembro :: String -> Plano -> Data -> Ginasio -> Ginasio
adicionarMembro nome plano desde g =
  g { membros = membros g ++ [novo] }
  where
    novo = Membro
      { membroId     = proximoIdMembro (membros g)
      , membroNome   = nome
      , membroPlano  = plano
      , membroEstado = Ativo
      , membroDesde  = desde
      }

-- | Altera o estado de um membro. Se o identificador não existir, a lista
-- fica igual.
atualizarEstado :: Id -> Estado -> [Membro] -> [Membro]
atualizarEstado _ _ [] = []
atualizarEstado i e (m : ms)
  | membroId m == i = m { membroEstado = e } : ms
  | otherwise       = m : atualizarEstado i e ms

contarMembrosAtivos :: [Membro] -> Int
contarMembrosAtivos [] = 0
contarMembrosAtivos (m : ms)
  | membroEstado m == Ativo = 1 + contarMembrosAtivos ms
  | otherwise               = contarMembrosAtivos ms

-- | Membros ativos de um dado plano.
membrosDoPlano :: Plano -> [Membro] -> [Membro]
membrosDoPlano _ [] = []
membrosDoPlano p (m : ms)
  | membroPlano m == p && membroEstado m == Ativo = m : membrosDoPlano p ms
  | otherwise                                     = membrosDoPlano p ms

-- | Número de membros ativos de um dado plano.
contarPorPlano :: Plano -> [Membro] -> Int
contarPorPlano p ms = contarLista (membrosDoPlano p ms)
  where
    contarLista []       = 0
    contarLista (_ : xs) = 1 + contarLista xs

-- | Ordenação alfabética por nome (insertion sort recursivo).
ordenarPorNome :: [Membro] -> [Membro]
ordenarPorNome []       = []
ordenarPorNome (m : ms) = inserirPorNome m (ordenarPorNome ms)

inserirPorNome :: Membro -> [Membro] -> [Membro]
inserirPorNome m [] = [m]
inserirPorNome m (x : xs)
  | membroNome m <= membroNome x = m : x : xs
  | otherwise                    = x : inserirPorNome m xs

-- ---------------------------------------------------------------------------
-- Aulas
-- ---------------------------------------------------------------------------

procurarAula :: Id -> [Aula] -> Maybe Aula
procurarAula _ [] = Nothing
procurarAula i (a : as)
  | aulaId a == i = Just a
  | otherwise     = procurarAula i as

aulasDoDia :: DiaSemana -> [Aula] -> [Aula]
aulasDoDia _ [] = []
aulasDoDia d (a : as)
  | aulaDia a == d = a : aulasDoDia d as
  | otherwise      = aulasDoDia d as

aulasDaModalidade :: Modalidade -> [Aula] -> [Aula]
aulasDaModalidade _ [] = []
aulasDaModalidade m (a : as)
  | aulaModalidade a == m = a : aulasDaModalidade m as
  | otherwise             = aulasDaModalidade m as

-- ---------------------------------------------------------------------------
-- Inscrições
-- ---------------------------------------------------------------------------

-- | Número de inscritos numa aula.
lugaresOcupados :: Id -> [Inscricao] -> Int
lugaresOcupados _ [] = 0
lugaresOcupados a (i : is)
  | inscAula i == a = 1 + lugaresOcupados a is
  | otherwise       = lugaresOcupados a is

temVaga :: Aula -> [Inscricao] -> Bool
temVaga a is = lugaresOcupados (aulaId a) is < aulaCapacidade a

estaInscrito :: Id -> Id -> [Inscricao] -> Bool
estaInscrito _ _ [] = False
estaInscrito m a (i : is)
  | inscMembro i == m && inscAula i == a = True
  | otherwise                            = estaInscrito m a is

-- | Inscreve um membro numa aula.
--
-- Devolve 'Nothing' se alguma regra falhar: membro ou aula inexistentes,
-- membro não ativo, plano sem acesso à modalidade, inscrição repetida ou
-- aula cheia. (Na Fase 2 pode devolver um 'Either' com o motivo do erro.)
inscrever :: Id -> Id -> Ginasio -> Maybe Ginasio
inscrever idM idA g =
  case (procurarMembro idM (membros g), procurarAula idA (aulas g)) of
    (Just m, Just a)
      | membroEstado m == Ativo
      , planoPermite (membroPlano m) (aulaModalidade a)
      , not (estaInscrito idM idA (inscricoes g))
      , temVaga a (inscricoes g)
        -> Just g { inscricoes = Inscricao idM idA : inscricoes g }
    _ -> Nothing

-- | Remove a inscrição de um membro numa aula (se existir).
removerInscricao :: Id -> Id -> [Inscricao] -> [Inscricao]
removerInscricao _ _ [] = []
removerInscricao m a (i : is)
  | inscMembro i == m && inscAula i == a = is
  | otherwise                            = i : removerInscricao m a is

-- ---------------------------------------------------------------------------
-- Pagamentos
-- ---------------------------------------------------------------------------

totalPagamentos :: [Pagamento] -> Centimos
totalPagamentos []       = 0
totalPagamentos (p : ps) = pagValor p + totalPagamentos ps

-- | Total recebido num determinado mês/ano.
receitaDoMes :: Int -> Int -> [Pagamento] -> Centimos
receitaDoMes _ _ [] = 0
receitaDoMes mes ano (p : ps)
  | pagMes p == mes && pagAno p == ano = pagValor p + receitaDoMes mes ano ps
  | otherwise                          = receitaDoMes mes ano ps

-- | O membro já pagou a mensalidade desse mês/ano?
temPagamento :: Id -> Int -> Int -> [Pagamento] -> Bool
temPagamento _ _ _ [] = False
temPagamento m mes ano (p : ps)
  | pagMembro p == m && pagMes p == mes && pagAno p == ano = True
  | otherwise = temPagamento m mes ano ps

-- | Membros ativos que já eram membros nesse mês e ainda não pagaram.
membrosEmDivida :: Int -> Int -> Ginasio -> [Membro]
membrosEmDivida mes ano g = emDivida (membros g)
  where
    emDivida [] = []
    emDivida (m : ms)
      | membroEstado m == Ativo
        && jaEraMembro m
        && not (temPagamento (membroId m) mes ano (pagamentos g))
          = m : emDivida ms
      | otherwise = emDivida ms

    -- Comparar (ano, mês) como pares: a ordem é lexicográfica.
    jaEraMembro m =
      (dataAno (membroDesde m), dataMes (membroDesde m)) <= (ano, mes)

-- | Receita mensal esperada: soma das mensalidades dos membros ativos.
receitaPrevista :: [Membro] -> Centimos
receitaPrevista [] = 0
receitaPrevista (m : ms)
  | membroEstado m == Ativo = precoMensal (membroPlano m) + receitaPrevista ms
  | otherwise               = receitaPrevista ms
