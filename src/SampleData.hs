-- | Dados de teste para demonstração e para os testes automáticos.
--
-- Cenário (hoje = novembro de 2026):
--
-- * 8 membros em estados e planos diferentes;
-- * a aula 1 (Spinning) está cheia (capacidade 2, 2 inscritos);
-- * em outubro de 2026 só a Gabriela (membro 7) não pagou;
-- * o Hugo (membro 8) inscreveu-se em novembro, logo não deve nada de outubro.
module SampleData
  ( ginasioExemplo
  , membrosExemplo
  , instrutoresExemplo
  , aulasExemplo
  , inscricoesExemplo
  , pagamentosExemplo
  ) where

import Model

ginasioExemplo :: Ginasio
ginasioExemplo = Ginasio
  { membros     = membrosExemplo
  , instrutores = instrutoresExemplo
  , aulas       = aulasExemplo
  , inscricoes  = inscricoesExemplo
  , pagamentos  = pagamentosExemplo
  }

membrosExemplo :: [Membro]
membrosExemplo =
  [ Membro 1 "Ana Ribeiro"    Premium  Ativo     (Data 2024  9  2)
  , Membro 2 "Bruno Costa"    Standard Ativo     (Data 2025  1 15)
  , Membro 3 "Carla Mendes"   Basico   Ativo     (Data 2025  3 10)
  , Membro 4 "Daniel Pinto"   Standard Suspenso  (Data 2025  6  1)
  , Membro 5 "Eva Santos"     Premium  Ativo     (Data 2025  9 20)
  , Membro 6 "Filipe Araújo"  Basico   Cancelado (Data 2024 11  5)
  , Membro 7 "Gabriela Lopes" Standard Ativo     (Data 2026  2 12)
  , Membro 8 "Hugo Martins"   Basico   Ativo     (Data 2026 11  3)
  ]

instrutoresExemplo :: [Instrutor]
instrutoresExemplo =
  [ Instrutor 1 "Marta Sousa"    [Spinning, CrossTraining]
  , Instrutor 2 "Ricardo Faria"  [Musculacao, CrossTraining]
  , Instrutor 3 "Sofia Teixeira" [Yoga, Pilates, Zumba]
  ]

aulasExemplo :: [Aula]
aulasExemplo =
  [ Aula 1 Spinning      1 Segunda 18  2
  , Aula 2 Yoga          3 Terca   19 10
  , Aula 3 CrossTraining 2 Quarta  18  3
  , Aula 4 Pilates       3 Quinta  10  8
  , Aula 5 Musculacao    2 Segunda  9 15
  , Aula 6 Zumba         3 Sexta   19 12
  ]

inscricoesExemplo :: [Inscricao]
inscricoesExemplo =
  [ Inscricao 1 1
  , Inscricao 2 1   -- aula 1 fica cheia
  , Inscricao 1 2
  , Inscricao 5 2
  , Inscricao 5 3
  , Inscricao 3 5
  ]

pagamentosExemplo :: [Pagamento]
pagamentosExemplo =
  [ Pagamento 1  9 2026 4500
  , Pagamento 7  9 2026 3000
  , Pagamento 1 10 2026 4500
  , Pagamento 2 10 2026 3000
  , Pagamento 3 10 2026 2000
  , Pagamento 5 10 2026 4500
  ]
