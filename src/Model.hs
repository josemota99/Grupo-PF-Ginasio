-- | Modelo de domínio do Sistema de Gestão de Ginásio.
--
-- Este módulo contém apenas tipos de dados (sem lógica): é a "linguagem"
-- comum a todos os outros módulos.
module Model
  ( -- * Tipos auxiliares
    Id
  , Centimos
  , Data (..)
  , DiaSemana (..)
    -- * Enumerações do domínio
  , Plano (..)
  , Estado (..)
  , Modalidade (..)
    -- * Entidades
  , Membro (..)
  , Instrutor (..)
  , Aula (..)
  , Inscricao (..)
  , Pagamento (..)
    -- * Estado global do ginásio
  , Ginasio (..)
  ) where

-- | Identificador único de uma entidade.
type Id = Int

-- | Valores monetários guardados em cêntimos (evita erros de vírgula flutuante).
type Centimos = Int

-- | Data de calendário simples.
data Data = Data
  { dataAno :: Int
  , dataMes :: Int
  , dataDia :: Int
  } deriving (Show, Eq, Ord)

data DiaSemana
  = Segunda | Terca | Quarta | Quinta | Sexta | Sabado | Domingo
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Plano de subscrição de um membro.
data Plano = Basico | Standard | Premium
  deriving (Show, Eq, Ord, Enum, Bounded)

-- | Estado da subscrição de um membro.
data Estado = Ativo | Suspenso | Cancelado
  deriving (Show, Eq)

data Modalidade
  = Musculacao | Spinning | Yoga | Pilates | CrossTraining | Zumba
  deriving (Show, Eq, Ord, Enum, Bounded)

data Membro = Membro
  { membroId     :: Id
  , membroNome   :: String
  , membroPlano  :: Plano
  , membroEstado :: Estado
  , membroDesde  :: Data      -- ^ data de inscrição no ginásio
  } deriving (Show, Eq)

data Instrutor = Instrutor
  { instrutorId             :: Id
  , instrutorNome           :: String
  , instrutorEspecialidades :: [Modalidade]
  } deriving (Show, Eq)

data Aula = Aula
  { aulaId         :: Id
  , aulaModalidade :: Modalidade
  , aulaInstrutor  :: Id        -- ^ referência a 'instrutorId'
  , aulaDia        :: DiaSemana
  , aulaHora       :: Int       -- ^ hora de início (0-23)
  , aulaCapacidade :: Int       -- ^ número máximo de inscritos
  } deriving (Show, Eq)

-- | Ligação entre um membro e uma aula (relação N-para-N).
data Inscricao = Inscricao
  { inscMembro :: Id            -- ^ referência a 'membroId'
  , inscAula   :: Id            -- ^ referência a 'aulaId'
  } deriving (Show, Eq)

data Pagamento = Pagamento
  { pagMembro :: Id             -- ^ referência a 'membroId'
  , pagMes    :: Int            -- ^ mês a que a mensalidade diz respeito
  , pagAno    :: Int
  , pagValor  :: Centimos
  } deriving (Show, Eq)

-- | Todo o estado do ginásio num único valor imutável.
data Ginasio = Ginasio
  { membros     :: [Membro]
  , instrutores :: [Instrutor]
  , aulas       :: [Aula]
  , inscricoes  :: [Inscricao]
  , pagamentos  :: [Pagamento]
  } deriving (Show, Eq)
