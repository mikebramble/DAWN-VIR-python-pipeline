#!/bin.bash
#Code written by: Mike Bramble | michael.s.bramble@jpl.nasa.gov
#Last edited on 20 JUL 2020
#This script will make a list of all DAWN VIR PDS QUB files in a directory and then process the files using ISIS and generate ISIS image cubes, photometry cubes, and label files.
#This script was written using ISIS4.

#If the script errors out due to filename errors, check the housekeeping TAB or LBL files. There are occasional inconsistencies with the filenames of these files and whether the "_1" comes before or after the "HK" at the end of the file name.

#make list
file_list=`ls *_1.QUB`

#Loop through all the .qub files
for i in $file_list
do

	# make new list of only first few characters
	# for IR detector take first 21 characters
	# for VIS detector take first 22 characters
	rootname=`echo $i | cut -c-21`
	
	echo - - - - - - - - - - - - - - - - - - - - - - - -
	echo Current file being processed: $i
	echo - - - - - - - - - - - - - - - - - - - - - - - -
	echo Working name of file being processed: $rootname

	#dawnvir2isis
	echo - - - - - - - - - - - - - - - - - - - - - - - -
	echo Converting to ISIS
	dawnvir2isis from=${rootname}_1.LBL image=${rootname}_1.QUB hkfrom=${rootname}_HK_1.LBL hktable=${rootname}_HK_1.TAB to=${rootname}_1_vir2isis.cub

	#spiceinit
	echo - - - - - - - - - - - - - - - - - - - - - - - -
	echo Attaching spice information
	spiceinit from=${rootname}_1_vir2isis.cub ckpredicted=true

	#catlab
	echo - - - - - - - - - - - - - - - - - - - - - - - -
	echo Generating label file
	catlab from=${rootname}_1_vir2isis.cub to=${rootname}_1_vir2isis.lbl

	#phocube
	echo - - - - - - - - - - - - - - - - - - - - - - - -
	echo Generating photometry file
	phocube from=${rootname}_1_vir2isis.cub+35 to=${rootname}_1_vir2isis_phocube.cub emission=no incidence=no localemission=yes localincidence=yes
	
	echo - - - - - - - - - - - - - - - - - - - - - - - -
	echo Completed processing of ${rootname}
	echo - - - - - - - - - - - - - - - - - - - - - - - -
done

#USE ISIS CUBE (.cub) FOR ANALYSIS IN PYTHON/GDAL/RASTERIO
#USE ISIS photometry cube (_phocube.cub) FOR ANALYSIS IN PYTHON/GDAL/RASTERIO

