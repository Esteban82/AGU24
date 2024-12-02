#!/usr/bin/env bash

# Script para probar metodo para crear grillas con badtrack sobre una superficie teorica.
# 
# Pasos seguidos:
# 0. Crear grilla teorica.
# 1. Convertir grilla a tabla de datos
# 2. Agregar error a un perfil.
# 3. Regrillar datos
# 4. Graficar resultados


# Parametros de la grilla y variables
# -----------------------------------
# Grid size
#N=100
N=20
R=-$N/$N/-$N/$N

# Sampling
I=1
#I=0.5
#I=1

Width=8c
error=10

# Files
Track=tmp_track.txt
BadTrack=tmp_badtrack.txt
TrackGradient=tmp_trackGradient.txt
Grid=tmp_grid.nc
BATI1=Greenspline_resto_BadTrack.nc
BATI2=Greenspline_resto_SlopeTrack.nc
XYZ=tmp_xyz.txt
Rest=tmp_resto.txt

gmt set PS_COLOR_MODEL CMYK


#	0. Create surface
# 	-------------------------------------------------------------------------------------------
#	B. Hat	
	gmt grdmath -R$N+ue -I$I X Y HYPOT DUP 2 MUL PI MUL 8 DIV COS EXCH NEG 10 DIV EXP MUL NORM 20 MUL = $Grid

# 	1. Prepare data
#   -------------------------------------------------------------------------------------------
#	A. Create data table from grid
	gmt grd2xyz $Grid > $XYZ

#	B. Split data in E-W track (i.e. column 2 is 0).
	awk '$2 == 0' $XYZ > $Track
	awk '$2 != 0' $XYZ > $Rest

#	C. Add error to create BadTrack
	gmt math $Track -C2 $error ADD = $BadTrack

#	D. Convert XYZ data to gradient profile with ad-hoc XYZ software
	../Software/./XYZ $BadTrack $TrackGradient

# 	2. Regenerate grids
#	-------------------------------------------------------------------------------------------
#	A. BATI1: Grid with badtrack depths values (standard method)
	gmt greenspline $Rest $BadTrack -R$R -I1 -G$BATI1 -St0.5 -Z1 -V

#	B. BATI2: Grid with badtrack gradient data (new method)-
	gmt greenspline $Rest -A$TrackGradient+f2 -R$R -I1 -G$BATI2 -St0.5 -Z1 -V 

#	4. Make plots
#	------------------------------------------------------------------------
#	A. Extract data from grids BATI1 and BATI2
	gmt grdtrack $Track -G$BATI1 -G$BATI2 > tmp_tracks.txt

# B. Hacer figura
gmt begin $(basename $0 .sh) png

	# 1. Original Grid
	gmt grdimage $Grid  -JX$Width -Cbatlow
	gmt basemap -B+t"Original Grid"
	gmt plot -Sc0.07 -Gblack $Rest
	gmt plot -Wthinner,orange $Track
	gmt plot -Sc0.07 -Gwhite $TrackGradient
	gmt basemap -BWSne -Baf

	# 2. Gids BATI1 y BATI2
	gmt grdimage $BATI1 -JX$Width -BwSne+t"Standard Method" -Cbatlow -Baf+e -Xaw+0.2c
	gmt grdimage $BATI2 -JX$Width -BwSne+t"New Method"      -Cbatlow -Baf+e -Xa2w+0.4c

	# 3. Top profile
	domain=$(gmt info tmp_tracks.txt -I0/16 -i0,4)
	gmt basemap $domain -JX24.4c/4c -Baf -BWesn -Yh+1.5c
	gmt plot tmp_tracks.txt -Wblue   -i0,3 -l"Standard Method"
	gmt plot tmp_tracks.txt -Wgreen  -i0,4 -l"New Method"
	gmt plot $Track -Sc0.1 -Gred -i0,2 -l"Original data"
	gmt legend -DjBR+o0.1c -F+g235+pthin
	gmt basemap -B+t"E-W Profile"
gmt end

# 5. Delete temporary files
rm -f $Grid gmt.history tmp_*.txt $BATI1 $BATI2 
