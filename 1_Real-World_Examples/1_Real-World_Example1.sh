
# Eigenvalue a analizar
	N=90

#	Define map
#	-----------------------------------------------------------------------------------------------------------
echo "Comparar grillas usando datos de pendientes del good track y del bad track sin filtrar con blockmean.
Se analiza la grilla de greenspline hasta el eigenvalue $N"

#	Titulo del mapa
	title=$(basename $0 .sh)

#	Datos UTM
	Data="0_Datos/ngdc_utm.xyz"							# All the data
	Track="0_Datos/Track_UTM56.txt"						# A track
	Resto="0_Datos/Perfiles_Resto_utm.xyz"				# Rest of data

#	Region y proyeccion en UTM
	INC=2000
	Width=15c
	PROJ=X${Width}/0
	REGION=$(gmt info $Track -I$INC)
	T=2000

# 	Nombre archivo de salida
	BATI0=Greenspline_GoodTrack.nc
	BATI1=Greenspline_BadTrack.nc
	BATI2=Greenspline_resto_SlopeGoodTrack.nc
	BATI3=Greenspline_resto_SlopeGoodTrack_lowpass.nc
	BadTrack=tmp_Badtrack.txt
	TrackGradient=tmp_trackGradient.txt

# 	0. Procesar datos
#   ******************************************************************************************	

#	BATI0 (Metodo standard con good track)
#	-------------------------------------
#	B1. Filtrar
	gmt blockmedian $Resto $Track $REGION -I$INC > tmp_resto_Track

#	B2. Grillar
	gmt greenspline tmp_resto_Track $REGION -I$INC -G$BATI0 -St0.5 -Z1 -V

#   -------------------------------------------------------------------------------------------
#	BATI1 (Metodo standar con Bad Track)
#	-------------------------------------
#	A. Sumar 2000 al perfil
	gmt math $Track -C2 2000 ADD = $BadTrack

#	B. Filtrar con Bad track
	gmt blockmedian $Resto $BadTrack $REGION -I$INC > tmp_resto_Track

#	C. Grillar
#	gmt greenspline tmp_resto_Track $REGION -I$INC -G$BATI1 -St0.5 -Z1 -V
	
#	BATI2 y BATI3 (Metodo nuevo con bad track)
#	------------------------------------------
#	B1. Filtrar
	gmt blockmedian $Resto $REGION -I$INC > tmp_resto
	
#	B. Distancia vs Gradiente/Pendiente
#	B2. Crear Bad track con XYZ
	echo "Crear Bad track con XYZ"
#	./XYZ $BadTrack $TrackGradient
	../Software/./XYZ $BadTrack $TrackGradient

	# Eigenvalue a analizar
	# Grillar usando trackgrad original
#	gmt greenspline tmp_resto $REGION -I$INC -G$BATI2 -St0.5 -Z1 -V -A$TrackGradient+f2

	# Eigenvalue a analizar
	N=90
	# Grillar usando trackgrad original
#	gmt greenspline tmp_resto $REGION -I$INC -G$BATI3 -St0.5 -Z1 -V -A$TrackGradient+f2 -Cn${N}%

# Crear mapa
#	-----------------------------------------------------------------------------------------------------------
gmt begin ${title}_${N} png 
gmt makecpt -Ctopo -T-7000/0
	gmt subplot begin 2x2 $REGION -J$PROJ -Fs${Width} -Bxaf -Byaf+ap -Srl -Scb -M0.05c/0.75c #-A1+gwhite+jTR
		gmt basemap -B+t"Standard method with original data" -c
		gmt grdimage $BATI0 -C -I #-c
		gmt grdcontour $BATI0 -C1000 -Wthinner
#		Dibujar datos
		gmt plot tmp_resto -Sc0.1c -Gblack -l"Rest of the data"
		gmt plot $Track    -Sc0.1c -Gred   -l"Bad Track"
		gmt basemap -LjBL+o0.5c+w20000+l"m"

		gmt basemap -B+t"Standard method with badtrack" -c
		gmt grdimage $BATI1 -C -I #-c
		gmt grdcontour $BATI1 -C1000 -Wthinner
		gmt plot tmp_resto -Sp

		gmt basemap -B+t"New method with all eigenvalues" -c
		gmt grdimage $BATI2 -C -I #-c
		gmt grdcontour $BATI2 -C1000 -Wthinner
		gmt plot tmp_resto -Sp

		gmt basemap -B+t"New method with $N % eigenvalues" -c
		gmt grdimage $BATI3 -C -I #-c
		gmt grdcontour $BATI3 -C1000 -Wthinner
		gmt plot tmp_resto  -Sp
#		gmt grdmath $BATI1 $BATI2 SUB = diff.nc
#		gmt basemap -B+t"Differences" -c
#		gmt grdimage diff.nc -Cpolar+h0 -I
#		gmt colorbar
#		gmt grdcontour diff.nc -C100 -Wthinner -Ln -A100
#		gmt grdcontour diff.nc -C100 -Wthinner -Lp -A100
	gmt subplot end
gmt end

# rm -f tmp_* gmt.* diff.nc