-- | Funções de apresentação (texto legível). Mantidas fora do 'Domain'
-- para separar regras de negócio de formatação.
module Format
  ( formatarEuros
  , descreverData
  , descreverMembro
  , descreverAula
  ) where

import Model

-- | @formatarEuros 4500 == "45,00 €"@
formatarEuros :: Centimos -> String
formatarEuros c
  | c < 0     = '-' : formatarEuros (negate c)
  | otherwise = show (c `div` 100) ++ "," ++ pad2 (c `mod` 100) ++ " €"

-- | @descreverData (Data 2026 11 3) == "03/11/2026"@
descreverData :: Data -> String
descreverData (Data a m d) = pad2 d ++ "/" ++ pad2 m ++ "/" ++ show a

descreverMembro :: Membro -> String
descreverMembro m =
  "#" ++ show (membroId m) ++ " " ++ membroNome m
    ++ " | " ++ show (membroPlano m)
    ++ " | " ++ show (membroEstado m)
    ++ " | desde " ++ descreverData (membroDesde m)

descreverAula :: Aula -> String
descreverAula a =
  "#" ++ show (aulaId a) ++ " " ++ show (aulaModalidade a)
    ++ " | " ++ show (aulaDia a) ++ " às " ++ pad2 (aulaHora a) ++ ":00"
    ++ " | capacidade " ++ show (aulaCapacidade a)

pad2 :: Int -> String
pad2 n
  | n < 10    = '0' : show n
  | otherwise = show n
