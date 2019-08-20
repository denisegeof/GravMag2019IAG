#!/usr/bin/env bash

# script 4: mapa completo de área de estudo
# Legenda, grid com sombra, globinho e mais detalhes
# modulos: makecpt, grdgradient, grdhisteq, grdimage, grdcontour, pscoast, psscale, psxy, pslegend, psconvert

r="-R-48/-40/-25/-20"       # nomeamos para deixar o script mais limpo, entre "" pois é string
j="-JM15c"
g="topo_srtm15_btaub.grd"
m="topo_srtm15_btaub3.ps"
pko="-P -K -O"              # criei o pko para não esquecer de colocar

#tabela de cores
gmt makecpt -Cworld -T-3500/3500/10 > myglobe.cpt

# fazer a sombra do grid
gmt grdgradient $g -Ghillshade-grad.nc -A335                          # calcula grid de sombra com direção 335 graus
gmt grdhisteq hillshade-grad.nc -Ghillshade-hist.nc -N.7              # faz redução de 70% do tamanho original

# mapa
gmt grdimage $g $r $j -Cmyglobe.cpt -Ihillshade-hist.nc -X2 -Y17 -P -K > $m
gmt grdcontour $g $r $j -A+-170 -W0.2p,red,- $pko >> $m
gmt pscoast -R -J -Cblue -Da $pko >> $m
gmt pscoast -R -J -Na/0.3p -Df -Ba2f1WENS -Lf-41.5/-24.3/-24.3/200+l -Tf-46.8/-26.5/1.5/2 -W $pko >> $m # -L escala no mapa x/y/yref/tamanho +l coloca unidade
                                                                                                        # -T rosa dos ventos x/y/tamanho/tipo
                                                                                                        # tipo <1-simples, 2-subcartesianos, 3-subsub>
gmt psxy taubate.xy -W0 -Gp300/12 -R -J $pko >> $m                    # como vimos o -Gp indica textura
gmt psxy perfil1_btaub_xydz.dat -W2p,purple -R -J $pko >> $m          # calculado no script3
# entrada pstext: x y tamanhofonte angulo tipodeletra BTC/RLC texto
# ele vai reclamar aqui, pq é o estilo antigo
gmt pstext -R -J -Gwhite $pko << EOF >> $m
-46.5 -22.5 14 0 13 BR A
-45 -24 14 0 13 TL A'
-40 -24.93 8 0 13 BR Proje\347\343o Mercartor WGS84 - topografia SRTM15PLUS (Olson et al., 2016)
EOF
# -: significa que sua entrada é yx
gmt psxy -W0.1 -Gyellow -Sa0.75 -: -R -J $pko << EOF >> $m
-22.876520 -43.263354 Rio de Janeiro
-23.564108 -46.653442 Sao Paulo
-20.305535 -40.301151 Vitoria
EOF
gmt psxy -W0.1 -S -Gcyan -R -J $pko >> $m <<< "-44 -21 .3 1 t"
gmt psxy -W0.1 -Sv.5+ea -Gpink -R -J $pko >> $m <<< "-44.5 -20.5 200 1"
# pslegend: -F desenha borda, -Dx posição distante do ponto 0 +w tamanho xy
# entrada pslegend: G is vertical gap, V is vertical line, N sets # of columns, D draws horizontal line,
# H is header, L is label, S is symbol, T is paragraph text, M is map scale, B is cpt
# no H fica centralizado, no resto tem q dizer a qnt de espaço (default cm)
# simbolos iguais do psxy, cor/textura
gmt pslegend -F -Dx5/-6+w10/5 $pko << EOF >> $m
H 18 Times-Roman Legenda
G 0.2
N 2
S 0.5 r 0.5 p300/12 0.25p 1 Taubat\351 basin
S 0.5 a 0.4 yellow 0.2p 1 Capitais
G 0.1
S 0.5 v 0.8 pink 0.2p 1 Rio Grande
S 0.5 - 0.5 - red,- 1 Cota -170m
G 0.1
S 0.5 t 0.25 cyan 0.3p 1 Tri\342ngulo
S 0.5 - 0.5 - thick,purple 1 Perfil A
N 1
G 0.5
B myglobe.cpt 0.3 0.4 -B1000
H 13 Times-Roman m
EOF
# definimos aqui outro R e J, o GMT guarda sempre o ultimo
# para fazer outro mapinha na mesma imagem (globinho)
gmt pscoast -Rg -JG-50/5/3 -Bg30 -S0/240/255 -G150 -Da -X-1.5 -Y8 -A10000 $pko >> $m
gmt psxy -W0.5,red -Gred -R -J -P -O << EOF >> $m
-48 -25
-48 -20
-40 -20
-40 -25
-48 -25
EOF
gmt psconvert $m -Tf -P -A   # no convert o -T diz qual formato e o -A corta onde tem figura, tbm tem o ps2raster e o ps2pdf
