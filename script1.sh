#!/usr/bin/env bash

# script 1: trata dados xyz, calcula média, interpola, plota

# Dados da Bacia de Taubaté: modelo SRTM15+
# O arquivo de entrada é um grid, vamos tirar os pontos dele e reinterpolar para ver todas as etapas, depois vamos testar para ver se deu diferença no grid

# modulos: grdinfo, grd2cpt, makecpt, grdimage, grd2xyz, blockmean, surface, grdmath, pscoast, psscale

# obs: ninguem sabe todos os modulos do gmt de cor, só digitar o nome no terminal que verificamos os parametros obrigatorios

# entrada: topo_srtm15_btaub.grd
# saida: myetopo1.cpt, mycolor.cpt, topo_srtm15_btaub.ps, topo_srtm15_btaub.xyz, topo_btaub_30s.grd, topo_btaub_30s.ps, dif_topo_teste.grd, dif_topo_teste.ps


# 1) vamos dar uma olhadinha no grid, grdinfo no terminal para observar os dados do grid e um grdimage/grdview para visualizar em mapa

#grdinfo topo_srtm15_btaub.grd                                                      #podemos usar o grdinfo dentro do script (qualquer modulo pode ser usado no terminal ou no script)

gmt grd2cpt topo_srtm15_btaub.grd -Cetopo1 -Z > myetopo1.cpt                            # alem das pelatas prontas, podemos editar os .cpt ou definir as cores no -C
                                                                                    # SUGESTÃO: 1)Teste tirar o -Z;  
gmt makecpt -Cred,orange,yellow,green -T-100,-10,0,10,100 > mycolor.cpt                 # 2) teste variar os valores e cores, para fazer uma paleta com o makecpt;
                                                                                    # 3) teste inverter a ordem da paleta -I

gmt grdimage topo_srtm15_btaub.grd -Rtopo_srtm15_btaub.grd -JM20 -Ba1f1 -Cmyetopo1.cpt > topo_srtm15_btaub.ps      # facilita a vida colocar o nome do grid no -R quando estamos só querendo fazer rapidamente no terminal, o gmt lê o grid e coloca os limites dele na imagem



# 2) passar o grd para tabela de dados, calculo da média/mediana e interpolação

gmt grd2xyz topo_srtm15_btaub.grd > topo_srtm15_btaub.xyz                               # assim ele tira todos os pontos do grid regular, no caso a resolução do modelo é de 15' deltaX,Y = 0,00416667

gmt blockmean topo_srtm15_btaub.xyz -I30s -R-48/-40/-25/-20 | gmt surface -R -I15s -T0.75 -Gtopo_btaub_30s.grd         # vamos diminuir a resolução para 30', surface (minima curvatura com tensor, defaut T=0, minima curvatura, GMT sugere T=.75 topo e .25 grav/mag)
                                                                                                               # além do blockmean (média), tem o blockmedian e o blockmode
                                                                                                               # além do surface tem: greenslipe, nearneighbor, triangulate
                                                                                                               # SUGESTÃO: teste outros tipos de interpolação e faça o procedimento abaixo para comparar


# obs: para mudar a resolução usem grdsample, só fiz assim para apresentar os módulos de interpolação. no sample você coloca -I30s, por exemplo, e ele reamostra


# 3)  visulaização do grid reamostrado, cálculo da diferença e plot em mapa do grid de diferença

#gmt grdinfo topo_btaub_30s.grd

gmt grdimage topo_btaub_30s.grd -Rtopo_btaub_30s.grd -JM20 -Ba1f1wEnS -Cmyetopo1.cpt > topo_btaub_30s.ps

gmt grdmath topo_srtm15_btaub.grd topo_btaub_30s.grd SUB = dif_topo_teste.grd           # o grdmath tem essa cara de calculadora científica, deem uma olhada nas funções disponíveis

#gmt grdinfo dif_topo_teste.grd

gmt grdimage dif_topo_teste.grd -Rdif_topo_teste.grd -JM20 -Ba1f1g1wEnS -Cmycolor.cpt -Yc -K > dif_topo_teste.ps   # agora vamos usar mais camadas na nossa imagem, para adicionar camadas use >>
                                                                                                               # precisamos tambem dizer para o GMT manter a figura aberta com o -K e quando fechar, com o -O

gmt pscoast -R -J -B+t"Diferen\347a" -Cdarkblue -Df -K -O >> dif_topo_teste.ps                                     # pscoast plota bordas (o GMT tem divisas de países, estados e rios, lagos), +t coloca titulo, -Df usa a melhor resolução possível dos limites
gmt pscoast -R -J -Na/0.3p -Df -W -K -O >> dif_topo_teste.ps                                                       # -N 1: países, 2: estados, a: all 

gmt psscale -D10/-1/18/0.5h -Ba10:"m": -Cmycolor.cpt -O >> dif_topo_teste.ps                                       # psscale coloca a escala no mapa, h fala q é horizontal, o X e Y são em cima de parametros anteriores, no caso -Yc
