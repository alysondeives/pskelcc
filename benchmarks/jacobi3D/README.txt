No cabe�alho de cada c�digo fonte existe uma breve descri��o das otimiza��es implementadas

O tamanho do bloco de threads � fixo e escolhido atrav�s de #define (BLOCK_DIMX/Y/Z) no in�cio do c�digo

Cada arquivo cont�m o c�digo para um tamanho de est�ncil

Uso:
<exec> <OPT> <DIMX> <DIMY> <DIMZ> <T_END>

OPT = otima��o escolhida
DIMX, DIMY e DIMZ = Dimens�es X, Y e Z da grade de entrada (devem ser m�ltiplos das dimens�es do bloco de threads)
T_END = quantidade de itera��es no tempo

No final da execu��o o programa ir� comparar os resultados obtidos na CPU e GPU e informar se s�o iguais ou n�o

Exemplo de chamada da aplica��o:

Otimiza��o - COMP + INTZ (Reg) (o1_o2)

>> stencil_3d_7point 12 256 256 256 1


Rela��o entre as op��es de otimiza��o e aquelas presentes no paper WSCAD:

BASE - 0 (o0)
COMP - 1 (o1)
CSL - 7 (o7)

INTZ - 3 (o3)
COMP + INTZ - 13 (o1_o3)
CSL + INTZ - 37 (o3_o7)

INTZ (Reg) - 2 (o2)
COMP + INTZ (Reg) - 12 (o1_o2)
CSL + INTZ (Reg) - 27 (o2_o7)
