#!/usr/bin/env bash

# script 5: calcular derivadas: vamos calcular derivadas de um grid (EMAG2), incluindo a ASA,
# e plotá-las junto em um ps (introdução do gmtset)

# modulos: grdcut, grdfft, grdmath, gmtset, makecpt, grd2cpt, grdimage, pscoast, psscale

r="-R-47.25/-40/-21/-15"     #facilita a vida colocar o nome do grid quando estamos só querendo fazer rapidamente no terminal,
                             #o gmt lê o grid e coloca os limites dele na imagem
j="-JM12"                    #tem trocentas projeções, vamos ver na sala algumas, essa m é a mercartor,boa para regiões pequenas,
                             #o valor depois é a escala, para cada grau 3cm

# baixei de http://geomag.org/models/emag2.html o grid formato netctd: EMAG2_V2.grd, primeiro vamos corta-lo na area de interesse
# poderiamos rodar tudo sem esse passo, e somente plotar a area de interesse, mas deixaria o script muito lento
# estou disponibilizando somente o cut no drive, pois o grid original tem cerca de 230Mb
# grdcut EMAG2_V2.grd $r -GEMAG2_V2cut.grd

# com o grid de anomalia magnética crustal EMAG2 vamos testar o grdmath e o grdfft (para calcular a derivada em z)
gmt grdfft EMAG2_V2cut.grd -fg -D -Gddz.grd                                 # ddz
gmt grdfft EMAG2_V2cut.grd -fg -D -D -Gd2dz2.grd                            # d2dz2

gmt grdmath EMAG2_V2cut.grd -fg DDX = ddx.grd                               # ddx
gmt grdmath EMAG2_V2cut.grd -fg DDY = ddy.grd                               # ddy
gmt grdmath ddx.grd SQR ddy.grd SQR ADD ddz.grd SQR ADD SQRT = asa.grd  # amplitude do sinal analitico (ASA)

gmt grdmath EMAG2_V2cut.grd -fg D2DX2 = d2dx2.grd                           # d2dx2
gmt grdmath EMAG2_V2cut.grd -fg D2DY2 = d2dy2.grd                           # d2dy2
gmt grdmath EMAG2_V2cut.grd -fg D2DXY = d2dxy.grd                           # d2dxdy


# para plotar os resultados em um .ps só vamos mudar o default para uma folha maior (A2) e colocar um gráfico ao lado do outro:
# obs: podemos fazer isso para qualquer parâmetro default do GMT, tamanho, tipo, cor, grauºmin'seg'', grau decimal...
# sugestao: cria um gmt.conf na home, quando precisar saber o nome e o valor do parâmetro no default só confere lá muda pelo set
# comnado pra isso -> $ gmt default -D > ~/gmt.conf

gmt set --PS_MEDIA=a2             #A4=21x28 A2=42x59 1A2=4A4

# vamos plotar algo do tipo:
#   | m1   m2  m3 |
#   | m4   m5  m6 |
#   | m7   m8  m9 |

m="derivadas_script5.ps"
kop="-K -O -P"
d="-D13/5/10/0.5"

# m1 - topo (grid original)
g="EMAG2_V2cut.grd"
makecpt -T-300/300/1 -Chaxby -Z > my.cpt
gmt grdimage $g $r $j -Cmy.cpt -Ba2f1g1WenS -X2 -Y29 -K > $m
gmt pscoast -R -J -B+t"EMAG2" -Na/0.3p -Df -W $kop >> $m
gmt psscale $d -Ba100:"nT": -Cmy.cpt $kop >> $m

# m2 - ASA
g="asa.grd"
grd2cpt $g -Chaxby -Z > my.cpt
gmt grdimage $g $r $j -Cmy.cpt -Ba2f1g1WenS -X19 $kop >> $m
gmt pscoast -R -J -B+t"ASA" -Na/0.3p -Df -W $kop >> $m
gmt psscale $d -Ba500:"nT/m": -Cmy.cpt $kop >> $m

# m3 - dxdy
g="d2dxy.grd"
grd2cpt $g -Chaxby -Z > my.cpt
gmt grdimage $g $r $j -Cmy.cpt -Ba2f1g1WenS -X19 $kop >> $m
gmt pscoast -R -J -B+t"dxdy" -Na/0.3p -Df -W $kop >> $m
gmt psscale $d -Ba2000000:"nT/m2": -Cmy.cpt $kop >> $m

# m4 - ddx
g="ddx.grd"
grd2cpt $g -Chaxby -Z > my.cpt
gmt grdimage $g $r $j -Cmy.cpt -Ba2f1g1WenS -X-38 -Y-14 $kop >> $m
gmt pscoast -R -J -B+t"ddx" -Na/0.3p -Df -W $kop >> $m
gmt psscale $d -Ba1000:"nT/m": -Cmy.cpt $kop >> $m

# m5 - ddy
g="ddy.grd"
grd2cpt $g -Chaxby -Z > my.cpt
gmt grdimage $g $r $j -Cmy.cpt -Ba2f1g1WenS -X19 $kop >> $m
gmt pscoast -R -J -B+t"ddy" -Na/0.3p -Df -W $kop >> $m
gmt psscale $d -Ba1000:"nT/m": -Cmy.cpt $kop >> $m

# m6 - ddz
g="ddz.grd"
grd2cpt $g -Chaxby -Z > my.cpt
gmt grdimage $g $r $j -Cmy.cpt -Ba2f1g1WenS -X19 $kop >> $m
gmt pscoast -R -J -B+t"ddz" -Na/0.3p -Df -W $kop >> $m
gmt psscale $d -Ba0.01:"nT/m": -Cmy.cpt $kop >> $m

# m7 - d2dx2
g="d2dx2.grd"
grd2cpt $g -Chaxby -Z > my.cpt
gmt grdimage $g $r $j -Cmy.cpt -Ba2f1g1WenS -X-38 -Y-14 $kop >> $m
gmt pscoast -R -J -B+t"d2dx2" -Na/0.3p -Df -W $kop >> $m
gmt psscale $d -Ba10000:"nT/m2": -Cmy.cpt $kop >> $m

# m8 - d2dy2
g="d2dy2.grd"
grd2cpt $g -Chaxby -Z > my.cpt
gmt grdimage $g $r $j -Cmy.cpt -Ba2f1g1WenS -X19 $kop >> $m
gmt pscoast -R -J -B+t"d2dy2" -Na/0.3p -Df -W $kop >> $m
gmt psscale $d -Ba10000:"nT/m2": -Cmy.cpt $kop >> $m

# m9 - d2dz2
g="d2dz2.grd"
grd2cpt $g -Chaxby -Z > my.cpt
gmt grdimage $g $r $j -Cmy.cpt -Ba2f1g1WenS -X19 $kop >> $m
gmt pscoast -R -J -B+t"d2dz2" -Na/0.3p -Df -W $kop >> $m
gmt psscale $d -Ba0.000001:"nT/m2": -Cmy.cpt -O >> $m
