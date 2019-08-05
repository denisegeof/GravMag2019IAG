REM script 1: trata dados xyz, calcula média, interpola, plota

REM Dados da Bacia de Taubaté: modelo SRTM15+
REM O arquivo de entrada é um grid, vamos tirar os pontos dele e reinterpolar para ver todas as etapas, depois vamos testar para ver se deu diferença no grid

REM modulos: grdinfo, grd2cpt, makecpt, grdimage, grd2xyz, blockmean, surface, grdmath, pscoast, psscale

REM obs: ninguem sabe todos os modulos do gmt de cor, só digitar o nome no terminal que verificamos os parametros obrigatorios

REM entrada: topo_srtm15_btaub.grd
REM saida: myetopo1.cpt, mycolor.cpt, topo_srtm15_btaub.ps, topo_srtm15_btaub.xyz, topo_btaub_30s.grd, topo_btaub_30s.ps, dif_topo_teste.grd, dif_topo_teste.ps


REM 1) vamos dar uma olhadinha no grid, grdinfo no terminal para observar os dados do grid e um grdimage/grdview para visualizar em mapa

REM grdinfo topo_srtm15_btaub.grd
REM podemos usar o grdinfo dentro do script (qualquer modulo pode ser usado no terminal ou no script)

grd2cpt topo_srtm15_btaub.grd -Cetopo1 -Z > myetopo1.cpt

REM alem das pelatas prontas, podemos editar os .cpt ou definir as cores no -C
REM SUGESTÃO: 1)Teste tirar o -Z;
REM 2) teste variar os valores e cores, para fazer uma paleta com o makecpt;
REM 3) teste inverter a ordem da paleta -I

makecpt -Cred,orange,yellow,green -T-100,-10,0,10,100 > mycolor.cpt

grdimage topo_srtm15_btaub.grd -Rtopo_srtm15_btaub.grd -JM20 -Ba1f1 -Cmyetopo1.cpt > topo_srtm15_btaub.ps

REM facilita a vida colocar o nome do grid no -R quando estamos só querendo fazer rapidamente no terminal, o gmt lê o grid e coloca os limites dele na imagem


REM 2) passar o grd para tabela de dados, calculo da média/mediana e interpolação
REM assim ele tira todos os pontos do grid regular, no caso a resolução do modelo é de 15' deltaX,Y = 0,00416667

grd2xyz topo_srtm15_btaub.grd > topo_srtm15_btaub.xyz

blockmean topo_srtm15_btaub.xyz -I30s -R-48/-40/-25/-20 | surface -R -I15s -T0.75 -Gtopo_btaub_30s.grd

REM vamos diminuir a resolução para 30', surface (minima curvatura com tensor, defaut T=0, minima curvatura, GMT sugere T=.75 topo e .25 grav/mag)
REM além do blockmean (média), tem o blockmedian e o blockmode
REM além do surface tem: greenslipe, nearneighbor, triangulate
REM SUGESTÃO: teste outros tipos de interpolação e faça o procedimento abaixo para comparar

REM obs: para mudar a resolução usem grdsample, só fiz assim para apresentar os módulos de interpolação. no sample você coloca -I30s, por exemplo, e ele reamostra


REM 3)  visulaização do grid reamostrado, cálculo da diferença e plot em mapa do grid de diferença

REM grdinfo topo_btaub_30s.grd

grdimage topo_btaub_30s.grd -Rtopo_btaub_30s.grd -JM20 -Ba1f1wEnS -Cmyetopo1.cpt > topo_btaub_30s.ps

grdmath topo_srtm15_btaub.grd topo_btaub_30s.grd SUB = dif_topo_teste.grd

REM o grdmath tem essa cara de calculadora científica, deem uma olhada nas funções disponíveis

REM grdinfo dif_topo_teste.grd

grdimage dif_sample.grd -Rdif_sample.grd -JM20 -Ba1f1 -Cmycolor.cpt > dif_sample.ps

REM agora vamos usar mais camadas na nossa imagem, para adicionar camadas use >>
REM precisamos tambem dizer para o GMT manter a figura aberta com o -K e quando fechar, com o -O

grdimage dif_topo_teste.grd -Rdif_topo_teste.grd -JM20 -Ba1f1g1wEnS -Cmycolor.cpt -Yc -K > dif_topo_teste.ps

pscoast -R -J -B+t"Diferen\347a" -Cdarkblue -Df -K -O >> dif_topo_teste.ps

REM pscoast plota bordas (o GMT tem divisas de países, estados e rios, lagos), +t coloca titulo, -Df usa a melhor resolução possível dos limites
REM -N 1: países, 2: estados, a: all

pscoast -R -J -Na/0.3p -Df -W -K -O >> dif_topo_teste.ps

psscale -D10/-1/18/0.5h -Ba10:"m": -Cmycolor.cpt -O >> dif_topo_teste.ps

REM psscale coloca a escala no mapa, h fala q é horizontal, o X e Y são em cima de parametros anteriores, no caso -Yc
