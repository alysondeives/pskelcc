No cabeçalho de cada código fonte existe uma breve descrição das otimizações implementadas

O tamanho do bloco de threads é fixo e escolhido através de #define (BLOCK_DIMX/Y/Z) no início do código

Cada arquivo contém o código para um tamanho de estêncil

Uso:
<exec> <OPT> <DIMX> <DIMY> <DIMZ> <T_END>

OPT = otimação escolhida
DIMX, DIMY e DIMZ = Dimensões X, Y e Z da grade de entrada (devem ser múltiplos das dimensões do bloco de threads)
T_END = quantidade de iterações no tempo

No final da execução o programa irá comparar os resultados obtidos na CPU e GPU e informar se são iguais ou não

Exemplo de chamada da aplicação:

Otimização - COMP + INTZ (Reg) (o1_o2)

>> stencil_3d_7point 12 256 256 256 1


Relação entre as opções de otimização e aquelas presentes no paper WSCAD:

BASE - 0 (o0)
COMP - 1 (o1)
CSL - 7 (o7)

INTZ - 3 (o3)
COMP + INTZ - 13 (o1_o3)
CSL + INTZ - 37 (o3_o7)

INTZ (Reg) - 2 (o2)
COMP + INTZ (Reg) - 12 (o1_o2)
CSL + INTZ (Reg) - 27 (o2_o7)
