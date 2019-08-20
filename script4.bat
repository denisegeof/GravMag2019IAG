REM script 4: mapa completo de área de estudo
REM Legenda, grid com sombra, globinho e mais detalhes
REM modulos: makecpt, grdgradient, grdhisteq, grdimage, grdcontour, pscoast, psscale, psxy, pslegend, psconvert

set r=-R-48/-40/-25/-20
set j=-JM15c
set g=topo_srtm15_btaub.grd
set m=topo_srtm15_btaub3.ps
set pko=-P -K -O
REM criei o pko para não esquecer de colocar

REM tabela de cores
gmt makecpt -Cworld -T-3500/3500/10 > myglobe.cpt

REM fazer a sombra do grid
REM gradient: calcula grid de sombra com direção 335 graus
REM histeq: faço redução de 70% do tamanho original
gmt grdgradient %g% -Ghillshade-grad.nc -A335
gmt grdhisteq hillshade-grad.nc -Ghillshade-hist.nc -N.7

REM definindo arquivos de entrada
REM texto dentro do mapa
echo -46.5 -22.5 14 0 13 BR A > texto.txt
echo -45 -24 14 0 13 TL A' >> texto.txt
echo -40 -24.93 8 0 13 BR Proje\347\343o Mercartor WGS84 - topografia SRTM15PLUS (Olson et al., 2016) >> texto.txt

REM localizacao de capitais
echo -22.876520 -43.263354 Rio de Janeiro >> capitais.dat
echo -23.564108 -46.653442 Sao Paulo >> capitais.dat
echo -20.305535 -40.301151 Vitoria >> capitais.dat

REM legenda
REM pslegend: -F desenha borda, -Dx posição distante do ponto 0 +w tamanho xy
REM entrada pslegend: G is vertical gap, V is vertical line, N sets # of columns, D draws horizontal line,
REM H is header, L is label, S is symbol, T is paragraph text, M is map scale, B is cpt
REM no H fica centralizado, no resto tem q dizer a qnt de espaço (default cm)
REM simbolos iguais do psxy, cor/textura
echo H 18 Times-Roman Legenda > legenda.txt
echo G 0.2 >> legenda.txt
echo N 2 >> legenda.txt
echo S 0.5 r 0.5 p300/12 0.25p 1 Taubat\351 basin >> legenda.txt
echo S 0.5 a 0.4 yellow 0.2p 1 Capitais >> legenda.txt
echo G 0.1 >> legenda.txt
echo S 0.5 v 0.8 pink 0.2p 1 Rio Grande >> legenda.txt
echo S 0.5 - 0.5 - red,- 1 Cota -170m >> legenda.txt
echo G 0.1 >> legenda.txt
echo S 0.5 t 0.25 cyan 0.3p 1 Tri\342ngulo >> legenda.txt
echo S 0.5 - 0.5 - thick,purple 1 Perfil A >> legenda.txt
echo N 1 >> legenda.txt
echo G 0.5 >> legenda.txt
echo B myglobe.cpt 0.3 0.4 -B1000 >> legenda.txt
echo H 13 Times-Roman m >> legenda.txt

REM
echo -48 -25 > area.dat
echo -48 -20 >> area.dat
echo -40 -20 >> area.dat
echo -40 -25 >> area.dat
echo -48 -25 >> area.dat

REM mapa
gmt grdimage %g% %r% %j% -Cmyglobe.cpt -Ihillshade-hist.nc -X2 -Y17 -P -K > %m%
gmt grdcontour %g% %r% %j% -A+-170 -W0.2p,red,- %pko% >> %m%
gmt pscoast -R -J -Cblue -Da %pko% >> %m%
REM pscoast: -L escala no mapa x/y/yref/tamanho +l coloca unidade
REM -T rosa dos ventos x/y/tamanho/tipo, tipo <1-simples, 2-subcartesianos, 3-subsub>
gmt pscoast -R -J -Na/0.3p -Df -Ba2f1WENS -Lf-41.5/-24.3/10/200+l -Tf-46.8/-26.5/1.5/2 -W %pko% >> %m%
REM psxy: como vimos o -Gp indica textura, o perfil1 foi calculado/removido no script3
gmt psxy taubate.xy -W0 -Gp300/12 -R -J %pko% >> %m%
gmt psxy perfil1_btaub_xydz.dat -W2p,purple -R -J %pko% >> %m%
REM entrada pstext: x y tamanhofonte angulo tipodeletra BTC/RLC texto
REM ele vai reclamar aqui, pq é o estilo antigo
gmt pstext texto.txt -R -J -Gwhite %pko% >> %m%
REM psxy: -: significa que a entrada é yx
gmt psxy capitais.dat -W0.1 -Gyellow -Sa0.75 -: -R -J %pko% >> %m%
gmt psxy -W0.1 -S -Gcyan -R -J %pko% >> %m% <<< "-44 -21 .3 1 t"
gmt psxy -W0.1 -Sv.5+ea -Gpink -R -J %pko% >> %m% <<< "-44.5 -20.5 200 1"
gmt pslegend legenda.txt -F+p -Dx5/-6+w10/5/10 %pko% >> %m%

REM definimos aqui outro R e J, o GMT guarda sempre o ultimo
REM para fazer outro mapinha na mesma imagem (globinho)
gmt pscoast -Rg -JG-50/5/3 -Bg30 -S0/240/255 -G150 -Da -X-1.5 -Y8 -A10000 %pko% >> %m%
gmt psxy area.dat -W0.5,red -Gred -R -J -P -O >> %m%

REM no convert o -T diz qual formato e o -A corta onde tem figura, tbm tem o ps2raster e o ps2pdf
gmt psconvert %m% -Tf -P -A
