REM script 3: vamos tirar perfis do grid, plotar como gráfico e introduzir o awk

REM modulos: gmtproject, grdtrack, gmtselect, psxy, grdimage, grdcontour, pscoast, psscale,pstext

REM Vamos extrair perfis de um grid, selecionar pontos de um arquivo de texto localizados dentro de um poligono
REM e plotar os gráficos junto com o mapa
REM Esse é um script mais completo, que utiliza o awk para manipular os dados

set p=perfilA.ps
set m=topo_srtm15_btaub_perfis.ps

REM vamos tirar um perfil NW-SE
REM o gmt project cria uma lista com pontos de C a E com a distancia de G
REM o trck pega esse perfil e tira os valores de z no grid G
gmt project -Q -C-46.5/-22.5 -E-45/-24 -G0.1 | gmt grdtrack -Gtopo_srtm15_btaub.grd > perfil1_btaub_xydz.dat

REM awk é muuuuito util! Aqui estou usando para selecionar colunas de uma tabela de dados, mas ele tem condicionais, loops..
type perfil1_btaub_xydz.dat | gawk "{ print $1, $2, $4}" > xyz.dat
type perfil1_btaub_xydz.dat | gawk "{ print $1, $4}" > xz.dat

REM o select seleciona, aqui dentro de um poligono, pode ser em volta de um ponto, fora de um poligono
gmtselect xyz.dat -Ftaubate.xy > xyz_select.dat
type xyz_select.dat | gawk "{ print $1, $3}" > xz_select.dat

REM plotamos o perfil lat alt
gmt psxy xz.dat -R-46.5/-45/-1000/2500 -JX23c/4c -Ba.2f.1g.2:"Lat(graus)":/a1000g1000f500:"Topo(km)":WSne -Wred -Xc -Y2 -K > %p%
gmt psxy xz_select.dat -R -J -Wblue -K -O >> %p%

REM vamos calcular o eixo x em metros partindo do ponto inicial -46/-22.5
type xyz.dat | gawk "{ print (sqrt((($1+46.5)^2)+(($2+22.5)^2)))*(1100), $3}" > xz_km.dat
type xyz_select.dat | gawk "{ print (sqrt((($1+46.5)^2)+(($2+22.5)^2)))*(1100), $3}" > xz_select_km.dat

REM agora plotar em metros...
gmt psxy xz_km.dat -R0/2330/-1000/2500 -JX23c/4c -Ba200f100g200:"Dist\342ncia(m)":/a1000g1000f500:"Topo(km)"::."Bacia de Taubat\351 - Perfil A":WSne -Wred -Y7 -K -O >> %p%
gmt psxy xz_select_km.dat -R -J -Wblue -O >> %p%

REM vamos tirar mais um perfil e fazer uma imagem com o mapa e os perfis
REM primeiro tirar outro perfil, mais a NE
gmt project -Q -C-46/-22 -E-44.5/-23.5 -G0.1 | gmt grdtrack -Gtopo_srtm15_btaub.grd > perfil2_btaub_xydz.dat
type perfil2_btaub_xydz.dat | gawk "{ print $1, $2, $4}" > xyz.dat
type xyz.dat | gawk "{ print (sqrt((($1+46)^2)+(($2+22)^2)))*(1100), $3}" > xz_km2.dat
gmtselect xyz.dat -Ftaubate.xy | gawk "{ print (sqrt((($1+46)^2)+(($2+22)^2)))*(1100), $3}" > xz_select_km2.dat

REM fazer mapa com perfis
gmt grdimage topo_srtm15_btaub.grd -R-48/-40/-25/-20 -JM15 -Cmyetopo1.cpt -Ihillshade-hist.nc -Ba2f1g1WenS -X2 -Yc -K > %m%
gmt grdcontour topo_btaub_30s.grd -R -J -C500m -W.001,50 -K -O >> %m%
gmt pscoast -R -J -B+t"                                     Topografia" -Cdarkblue -Da -K -O >> %m%
gmt pscoast -R -J -Na/0.3p -Df -T-40.5/-26/1 -W -K -O >> %m%
gmt psxy taubate.xy -Wblue -Gblue -R -J -K -O >> %m%
gmt psxy perfil1_btaub_xydz.dat -W2p,red -R -J -K -O >> %m%
gmt psxy perfil2_btaub_xydz.dat -W2p,purple -R -J -K -O >> %m%
echo -46.5 -22.5 14 0 13 RB A > A.txt
echo -45 -24 14 0 13 LT A' >> A.txt
gmt pstext A.txt -R -J -Gwhite -K -O >> %m%
echo -46 -22 14 0 13 RB B > B.txt
echo -44.5 -23.5 14 0 13 RB B' >> B.txt
gmt pstext B.txt -R -J -Gwhite -K -O >> %m%
gmt psscale -D7.5/-1/11/0.4h -Ba1000:"m": -Cmyetopo1.cpt -E -K -O >> %m%
gmt psxy xz_km.dat -R0/2330/-1000/2500 -JX8c/2c -Ba500f250g500:"Dist\342ncia(m)":/a1000g1000f500:"Topo(km)"::."A                               A'":wESn -Wred -X16 -Y1 -K -O >> %m%
gmt psxy xz_select_km.dat -R -J -Wblue -K -O >> %m%
gmt psxy xz_km2.dat -R0/2330/-1000/2500 -JX8c/2c -Ba500f250g500/a1000g1000f500:"Topo(km)"::."B                               B'":wESn -Wpurple -Y5 -K -O >> %m%
gmt psxy xz_select_km2.dat -R -J -Wblue -O >> %m%
