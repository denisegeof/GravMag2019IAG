REM script 2: vamos pegar o grid do script 1 e fazer uma imagem de localização
REM modulos: makecpt, grdgradient, grdhisteq, grdimage, grdcontour, pscoast, psscale, psxy

REM entrada: topo_srtm15_btaub.grd
REM saida: myetopo1.cpt, hillshade-grad.nc, hillshade-hist.nc, topo_srtm15_btaub2.ps, loc.dat

REM hoje a ideia é mexer com os parâmetros e tirar as dúvidas até aqui!

REM primeiro sugiro nomear as coisas mais repetitivas no script, nome do ps, dimensões (-R) e formato do mapa (-J), depois é só chamar $nomevariavel

set r=-R-48/-40/-25/-20        
REM -Rxmin/xmax/ymin/ymax
set j=-JM20
REM tem trocentas projeções, vamos ver algumas em sala, essa M é a mercartor, boa para regiões pequenas
set g=topo_srtm15_btaub.grd
REM aceita varios formatos de grid
set m=topo_srtm15_btaub2.ps
REM imprime em ps.. por isso precisa instalar o ghost!

REM tabela de cores
gmt makecpt -Cglobe -T-3500/3500/10 > myetopo1.cpt                         

REM fazer a sombra do grid
gmt grdgradient %g% -Ghillshade-grad.nc -A335                
REM -A é o azimute
gmt grdhisteq hillshade-grad.nc -Ghillshade-hist.nc -N.7     
REM -N é normalização, tentem varia-lo

REM mapa
gmt grdimage %g% %r% %j% -Cmyetopo1.cpt -Ihillshade-hist.nc -Ba2f1g1wEnS -Xc -Yc -K > %m%
REM com o -I colocamos o grid de sombra, -Ba<texto>f<borda>g<linhas>, -Xc centraliza
gmt grdcontour topo_btaub_30s.grd -R -J -C500m -W.001,50 -K -O >> %m%    
REM estou usando o grid com menos resolução feito no script1, tentem usar o %g% para ver a diferença                
gmt pscoast -R -J -B+t"Topografia" -Cdarkblue -Df -K -O >> %m%
REM -B+t coloca o titulo, -C colore as regiões alagadas, -Smar, -Wlinhadecosta, -Gareaseca                         
gmt pscoast -R -J -Na/0.3p -Df -Lf-41/-24.5/10/100+l -T-40/-26/1 -W -K -O >> %m%
REM -Lf escala +l unidade, -T norte, se coloca mais /1 rosa dos ventos
gmt psscale -D10/-1/18/0.5h -Ba1000:"m": -Cmyetopo1.cpt -E -K -O >> %m%                  
REM -B intervalo dos numeros na paleta :textonapaleta:, -E coloca triangulos nas extremidades, ele reclama pq é do GMT4...

gmt pscoast -Rg -JG-50/5/4 -Bg30 -Swhite -Da -X18 -Y12 -A10000 -G50 -K -O >> %m%         
REM -Rg projeção global, -JG é projeção global:x/y centrais e tamanho do globinho em cm (default)                                                                                        
REM -Bg indica a distancia das linhas de latlong, -Da resolução auto, -X e -Y sempre posição em cm (default)
REM -A area minima em km2 para desenhar a coast, se n colocar ele desenha detalhes q ficam enormes em um globinho
REM como vimos, -G pinta area seca, a cor pode ser o nome da cor, o numero RGB (3 num) ou escala de cinza (1 num) (0-255)
REM no globinho não dá pra ver, mas no -GP/p tem 90 texturas

REM no windows vamos salvar um arquivo loc.dat com as coordenadas do poligono, para usar no psxy e delimitar a area de estudo no globinho
echo -48 -25 > loc.dat
echo -48 -20 >> loc.dat
echo -40 -20 >> loc.dat
echo -40 -25 >> loc.dat
echo -48 -25 >> loc.dat

gmt psxy loc.dat -W0.5,red -Gred -R -J -O >> %m%
