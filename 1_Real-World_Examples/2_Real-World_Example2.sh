
# Eigenvalue a analizar
	N=90

#	Define map
#	-----------------------------------------------------------------------------------------------------------
echo "Comparar grillas usando datos de pendientes del good track y del bad track sin filtrar con blockmean.
Se analiza la grilla de greenspline hasta el eigenvalue $N"

#	Titulo del mapa
	title=$(basename $0 .sh)

#	Data for TEST 1
	#Data="0_Datos/ngdc_utm.xyz"						# All the data
	Track="0_Datos/Track_UTM56.txt"						# Bad track for test 1
	Resto="0_Datos/Perfiles_Resto_utm.xyz"				# Rest of data
	
#	Data for TEST 2
	TRACK2="0_Datos/Prueba/New_Track.txt"
	RESTO2="0_Datos/Prueba/Perfiles_Resto2_utm.xyz"


#	Region y proyeccion en UTM
	INC=2000
	Width=15c
	PROJ=X${Width}/0
	REGION=$(gmt info $Track -I$INC)
	T=2000

# 	Nombre archivo de salida
	BATI0=Greenspline_GoodTrack_2.nc
	BATI1=Greenspline_BadTrack_2.nc
	BATI2=Greenspline_resto_SlopeGoodTrack_2.nc
	BATI3=Greenspline_resto_SlopeGoodTrack_lowpass_2.nc
	BadTrack=tmp_Badtrack_2.txt
	TrackGradient=tmp_trackGradient_2.txt

# 	0. Procesar datos
#   ******************************************************************************************	
#	BATI0 (Metodo standard con good track)
#	-------------------------------------
#	B1. Filtrar
	#gmt blockmedian $RESTO2 $Track $TRACK2 $REGION -I$INC > tmp_resto_Track

#	B2. Grillar
	#gmt greenspline tmp_resto_Track $REGION -I$INC -G$BATI0 -St0.5 -Z1 -V

#   -------------------------------------------------------------------------------------------
#	BATI1 (Metodo standard con Bad Track)
#	-------------------------------------
#	B. Filtrar sin nuevo track
	#gmt blockmedian $RESTO2 $Track $REGION -I$INC > tmp_resto_Track

#	C. Grillar
	#gmt greenspline tmp_resto_Track $REGION -I$INC -G$BATI1 -St0.5 -Z1 -V
	
#	BATI2 y BATI3 (Metodo nuevo con bad track)
#	------------------------------------------
#	B1. Filtrar
	#gmt blockmedian $RESTO2 $Track $REGION -I$INC > tmp_resto
	
#	B. Distancia vs Gradiente/Pendiente
#	B2. Crear Bad track con XYZ
	echo "Crear Bad track con XYZ"
#	./XYZ $TRACK2 $TrackGradient
	../Software/./XYZ $TRACK2 $TrackGradient

	# Eigenvalue a analizar
	# Grillar usando trackgrad original
	gmt greenspline tmp_resto $REGION -I$INC -G$BATI2 -St0.5 -Z1 -V -A$TrackGradient+f2

	# Eigenvalue a analizar
	# Grillar usando trackgrad original
	gmt greenspline tmp_resto $REGION -I$INC -G$BATI3 -St0.5 -Z1 -V -A$TrackGradient+f2 -Cn${N}%

# 	Make plot
#	-----------------------------------------------------------------------------------------------------------
gmt begin ${title}_${N} png
gmt makecpt -Ctopo -T-7000/0
	gmt subplot begin 2x2 $REGION -J$PROJ -Fs${Width} -Bxaf -Byaf+ap -Srl -Scb -A1+gwhite+jTR -M0.05c/0.6c
		gmt basemap -B+t"Standard method with original data" -c
		gmt grdimage $BATI0 -C -I
		gmt grdcontour $BATI0 -C1000 -Wthinner
		gmt plot $Track  -Sp -Gblack
		gmt plot $RESTO2 -Sp -Gblack
		gmt plot $TrackGradient -Sp -Gred
		gmt basemap -LjBL+o0.5c+w20000+l"m"
		

		gmt basemap -B+t"Standard method without \"Bad Track\"" -c
		gmt grdimage $BATI1 -C -I
		gmt grdcontour $BATI1 -C1000 -Wthinner
		#gmt plot tmp_resto -Sp
		#gmt plot $TrackGrad -Sp -Gred
		gmt plot $Track  -Sp -Gblack
		gmt plot $RESTO2 -Sp -Gblack
		gmt plot $TRACK2 -Sp -Gred	

		gmt basemap -B+t"New method with all eigenvalues" -c
		gmt grdimage $BATI2 -C -I
		gmt grdcontour $BATI2 -C1000 -Wthinner
		gmt plot tmp_resto -Sp
		gmt plot $TrackGradient -Sp -Gred

		gmt basemap -B+t"New method with $N % eigenvalues" -c
		gmt grdimage $BATI3 -C -I
		gmt grdcontour $BATI3 -C1000 -Wthinner
		gmt plot tmp_resto  -Sp
		gmt plot $TrackGradient -Sp -Gred
	gmt subplot end
gmt end
