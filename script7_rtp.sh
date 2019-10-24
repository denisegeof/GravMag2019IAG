#!/usr/bin/env bash

# script 7: calcular redução ao polo e tilt angle

#!/usr/bin/env bash

# modulos: grdredpol, grdmath, gmtset, makecpt, grdimage, pscoast, psscale, grd2cpt

r="-R-47.25/-40/-21/-15"
j="-JM12"

# mesmos dados do script5

#RTP
gmt grdredpol EMAG2_V2cut.grd -T2013 -GEMAG2_V2_RTP.grd
gmt grdredpol EMAG2_V2cut.grd -C-24/-35 -GEMAG2_V2_RTPa.grd
gmt grdredpol EMAG2_V2cut.grd -C-114/-35 -GEMAG2_V2_RTPb.grd
gmt grdredpol EMAG2_V2cut.grd -C-204/-35 -GEMAG2_V2_RTPc.grd

# tilt angle
gmt grdmath ddx.grd SQR ddy.grd SQR ADD SQRT = way.grd  # parte da eq. tilt angle
gmt grdmath ddz.grd way.grd DIV COT = tiltangle.grd     # continuação do calculo

# para plotar os resultados em um .ps só vamos mudar o default para uma folha maior (A2) e colocar um gráfico ao lado do outro:
gmt set --PS_MEDIA=a2             #A4=21x28 A2=42x59 1A2=4A4

# vamos plotar algo do tipo:
#   | m1   m2  m3 |
#   | m4   m5  m6 |
#   | m7   m8  m9 |

m="rtp_script7.ps"
kop="-K -O -P"
d="-D13/5/10/0.5"

# m1 - topo
g="SRTM15+V2cut.nc"
makecpt -T0/1500/1 -Chaxby -Z > my.cpt
gmt grdimage $g $r $j -Cmy.cpt -Ba2f1g1WenS -X2 -Y29 -K > $m
gmt pscoast -R -J -B+t"SRTM15" -Na/0.3p -Df -Sgray $kop >> $m
gmt psscale $d -Ba500:"m": -Cmy.cpt $kop >> $m

# m2 - anomag
g="EMAG2_V2cut.grd"
makecpt -T-300/300/1 -Chaxby -Z > my.cpt
gmt grdimage $g $r $j -Cmy.cpt -Ba2f1g1WenS -X19 $kop >> $m
gmt pscoast -R -J -B+t"EMAG2 v2" -Na/0.3p -Df -Sgray $kop >> $m
gmt psscale $d -Ba100:"nT": -Cmy.cpt $kop >> $m

# m3 - RTP IGRF
g="EMAG2_V2_RTP.grd"
grd2cpt $g -Chaxby -Z > my.cpt
gmt grdimage $g $r $j -Cmy.cpt -Ba2f1g1WenS -X19 $kop >> $m
gmt pscoast -R -J -B+t"RTP IGRF2013" -Na/0.3p -Df -Sgray $kop >> $m
gmt psscale $d -Ba50:"nT": -Cmy.cpt $kop >> $m

# m4 - RTP a
g="EMAG2_V2_RTPa.grd"
grd2cpt $g -Chaxby -Z > my.cpt
gmt grdimage $g $r $j -Cmy.cpt -Ba2f1g1WenS -X-38 -Y-14 $kop >> $m
gmt pscoast -R -J -B+t"RTP dec/inc=-22/-35" -Na/0.3p -Df -Sgray $kop >> $m
gmt psscale $d -Ba50:"nT": -Cmy.cpt $kop >> $m

# m5 - RTP b
g="EMAG2_V2_RTPb.grd"
grd2cpt $g -Chaxby -Z > my.cpt
gmt grdimage $g $r $j -Cmy.cpt -Ba2f1g1WenS -X19 $kop >> $m
gmt pscoast -R -J -B+t"RTP dec/inc=-112/-35" -Na/0.3p -Df -Sgray $kop >> $m
gmt psscale $d -Ba50:"nT": -Cmy.cpt $kop >> $m

# m6 - RTP c
g="EMAG2_V2_RTPc.grd"
grd2cpt $g -Chaxby -Z > my.cpt
gmt grdimage $g $r $j -Cmy.cpt -Ba2f1g1WenS -X19 $kop >> $m
gmt pscoast -R -J -B+t"RTP dec/inc=-202/-35" -Na/0.3p -Df -Sgray $kop >> $m
gmt psscale $d -Ba50:"nT": -Cmy.cpt $kop >> $m

# m7 - ASA
g="asa.grd"
grd2cpt $g -Chaxby -Z > my.cpt
gmt grdimage $g $r $j -Cmy.cpt -Ba2f1g1WenS -X-38 -Y-14 $kop >> $m
gmt pscoast -R -J -B+t"ASA" -Na/0.3p -Df -Sgray $kop >> $m
gmt psscale $d -Ba100:"nT/m": -Cmy.cpt $kop >> $m

# m8 - tiltangle
g="tiltangle.grd"
grd2cpt $g -Chaxby -Z > my.cpt
gmt grdimage $g $r $j -Cmy.cpt -Ba2f1g1WenS -X19 $kop >> $m
gmt pscoast -R -J -B+t"Tilt Angle" -Na/0.3p -Df -Sgray $kop >> $m
gmt grdcontour -R -J $g -C+0 $kop >> $m

# m9 - Bouguer?
g="EGM2008_bgcut.grd"
grd2cpt $g -Chaxby -Z > my.cpt
gmt grdimage $g $r $j -Cmy.cpt -Ba2f1g1WenS -X19 $kop >> $m
gmt pscoast -R -J -B+t"Bouguer - EGM2008" -Na/0.3p -Df -Sgray $kop >> $m
gmt psscale $d -Ba50:"mGal": -Cmy.cpt -O >> $m
