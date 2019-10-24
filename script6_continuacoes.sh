#!/usr/bin/env bash

# script 6: calcular continuações para cima e para baixo, para cálculo de regional, remove dos dados iniciais e calcula residual

# modulos: xyz2grd, grdcut, grdfft, grdmath, gmtset, makecpt, grd2cpt, grdimage, pscoast, psscale

r="-R-47.25/-40/-21/-15"
j="-JM12"

# baixei os dados de anom Bouguer do site http://icgem.gfz-potsdam.de/calcgrid uma tabela gdf
# primeiro vamos passar para -180/180 pois está 0/360, interpolar e então, cortar
# baixei o SRTM15 (oceano e continente) do site ftp://topex.ucsd.edu/pub/srtm15_plus/ só disponibilizo o cut, pois o original tem 2,7Gb
#awk '{print $1-360, $2, $3 > "EGM2008_SouthAm.dat"}' EGM2008_SouthAm.gdf
#xyz2grd EGM2008_SouthAm.dat -I0.03333333333333333 -R-80/-20/-60/10 -GEGM2008_Bouguer_SouthAm.grd
grdcut EGM2008_Bouguer_SouthAm.grd $r -GEGM2008_bgcut.grd
#grdcut SRTM15+V2.nc $r -GSRTM15+V2cut.nc

# com o grid de topo que estamos usando desde o inicio vamos agora testar o grdmath e o grdfft (para calcular a derivada em z)
gmt grdfft EGM2008_bgcut.grd -V -fg -C1000 -Gbg_up1000.grd                            # upward 1000m
gmt grdfft EGM2008_bgcut.grd -V -fg -C10000 -Gbg_up10000.grd                          # upward 1000m
gmt grdfft EGM2008_bgcut.grd -V -fg -C-100 -Gbg_down1000.grd                          # upward 1000m

# vamos subtrair da anomalia Bouguer as continuações calculadas, chamamos esse resultado de residual
gmt grdmath EGM2008_bgcut.grd bg_up1000.grd SUB = bg_up1000_residual.grd
gmt grdmath EGM2008_bgcut.grd bg_up10000.grd SUB = bg_up10000_residual.grd
gmt grdmath EGM2008_bgcut.grd bg_down1000.grd SUB = bg_down1000_residual.grd

# para plotar os resultados em um .ps só vamos mudar o default para uma folha maior (A2) e colocar um gráfico ao lado do outro:
gmt set --PS_MEDIA=a2             #A4=21x28 A2=42x59 1A2=4A4

# vamos plotar algo do tipo:
#   | m1   m2  m3 |
#   | m4   m5  m6 |
#   | m7   m8  m9 |

m="continuacoes_script6.ps"
kop="-K -O -P"
d="-D13/5/10/0.5"

# m1 - topo
g="SRTM15+V2cut.nc"
makecpt -T0/1500/1 -Chaxby -Z > my.cpt
gmt grdimage $g $r $j -Cmy.cpt -Ba2f1g1WenS -X2 -Y29 -K > $m
gmt pscoast -R -J -B+t"SRTM15" -Na/0.3p -Df -Sgray $kop >> $m
gmt psxy -W1,red -R -J -P $kop << EOF >> $m
-47.25 -18.5
-47.25 -19.25
-46.35 -19.25
-46.35 -18.5
-47.25 -18.5
EOF
gmt psscale $d -Ba500:"m": -Cmy.cpt $kop >> $m

# m2 - ar livre
g="EGM2008_Freeaircut.grd"
grd2cpt $g -Chaxby -Z > my.cpt
gmt grdimage $g $r $j -Cmy.cpt -Ba2f1g1WenS -X19 $kop >> $m
gmt pscoast -R -J -B+t"Ar Livre - EGM2008" -Na/0.3p -Df -Sgray $kop >> $m
gmt psxy -W1,red -R -J -P $kop << EOF >> $m
-47.25 -18.5
-47.25 -19.25
-46.35 -19.25
-46.35 -18.5
-47.25 -18.5
EOF
gmt psscale $d -Ba500:"mGal": -Cmy.cpt $kop >> $m

# m3 - Bouguer
g="EGM2008_bgcut.grd"
grd2cpt $g -Chaxby -Z > my.cpt
gmt grdimage $g $r $j -Cmy.cpt -Ba2f1g1WenS -X19 $kop >> $m
gmt pscoast -R -J -B+t"Bouguer - EGM2008" -Na/0.3p -Df -Sgray $kop >> $m
gmt psxy -W1,red -R -J -P $kop << EOF >> $m
-47.25 -18.5
-47.25 -19.25
-46.35 -19.25
-46.35 -18.5
-47.25 -18.5
EOF
gmt psscale $d -Ba50:"mGal": -Cmy.cpt $kop >> $m

# para mostrar melhor como é usada a continuação, para calcular o regional, vou dar um zoom em uma anomalia em cerca de 19S,45W
r="-R-47.25/-46.35/-19.25/-18.5"
j="-JM12"

# m4 - up 1000
g="bg_up1000.grd"
grd2cpt $g -Chaxby -Z > my.cpt
gmt grdimage $g $r $j -Cmy.cpt -Ba.2f.1g.1WenS -X-38 -Y-14 $kop >> $m
gmt pscoast -R -J -B+t"Bouguer - Upward 1 km" -Na/0.3p -Df -Sgray $kop >> $m
gmt psscale $d -Ba50:"mGal": -Cmy.cpt $kop >> $m

# m5 - up 10000
g="bg_up10000.grd"
grd2cpt $g -Chaxby -Z > my.cpt
gmt grdimage $g $r $j -Cmy.cpt -Ba.2f.1g.1WenS -X19 $kop >> $m
gmt pscoast -R -J -B+t"Bouguer - Upward 10 km" -Na/0.3p -Df -Sgray $kop >> $m
gmt psscale $d -Ba50:"mGal": -Cmy.cpt $kop >> $m

# m6 - down 1000
g="bg_down1000.grd"
grd2cpt $g -Chaxby -Z > my.cpt
gmt grdimage $g $r $j -Cmy.cpt -Ba.2f.1g.1WenS -X19 $kop >> $m
gmt pscoast -R -J -B+t"Bouguer - Downward 1 km" -Na/0.3p -Df -Sgray $kop >> $m
gmt psscale $d -Ba50:"mGal": -Cmy.cpt $kop >> $m

# m7 - residual (Bouguer - up 1000)
g="bg_up1000_residual.grd"
grd2cpt $g -Chaxby -Z > my.cpt
gmt grdimage $g $r $j -Cmy.cpt -Ba.2f.1g.1WenS -X-38 -Y-14 $kop >> $m
gmt pscoast -R -J -B+t"Residual up 1 km" -Na/0.3p -Df -Sgray $kop >> $m
gmt psscale $d -Ba10:"mGal": -Cmy.cpt $kop >> $m

# m8 - residual (Bouguer - up 10000)
g="bg_up10000_residual.grd"
grd2cpt $g -Chaxby -Z > my.cpt
gmt grdimage $g $r $j -Cmy.cpt -Ba.2f.1g.1WenS -X19 $kop >> $m
gmt pscoast -R -J -B+t"Residual up 10 km" -Na/0.3p -Df -Sgray $kop >> $m
gmt psscale $d -Ba10:"mGal": -Cmy.cpt $kop >> $m

# m9 - residual (Bouguer - down 1000)
g="bg_down1000_residual.grd"
grd2cpt $g -Chaxby -Z > my.cpt
gmt grdimage $g $r $j -Cmy.cpt -Ba.2f.1g.1WenS -X19 $kop >> $m
gmt pscoast -R -J -B+t"Residual down 1 km" -Na/0.3p -Df -Sgray $kop >> $m
gmt psscale $d -Ba10:"mGal": -Cmy.cpt -O >> $m
