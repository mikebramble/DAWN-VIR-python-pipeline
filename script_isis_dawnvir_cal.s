#!/bin.bash
#Code written by: Mike Bramble | michael.s.bramble@jpl.nasa.gov
#This ISIS pipeline was taken from the document "Using ISIS to read VIR cubes into ISIS" by Eric E. Palmer accessed from the PDS via DAWNVIR_ISIS_TUTORIAL.pdf.
#First written on 20 JUL 2020
#Last edited on 10 SEP 2020
#Previous version edited on 23 JUL 2020
#This script will make a list of all DAWN VIR PDS QUB files in a directory and then process the files using ISIS and generate ISIS image cubes, photometry cubes, and label files. Do not include the QQ QUB and LBL files in the directory of the images being processed if level 1B data are being processed.
#This script was written using ISIS4.
#Note 1: the rootname variable below needs to be changed depending on whether VIS or IR detector images are being processed.
#Note 2: a user-specified shape model for Ceres is applied in the spiceinit step. Make sure you either have a shape model downloaded and pointed to, or make sure you remove the shape and model pointers in the spiceinit step.

#If the script errors out due to filename errors, check the housekeeping TAB or LBL files. There are occasional inconsistencies with the filenames of these files and whether the "_1" comes before or after the "HK" at the end of the file name. If so, edit the dawnvir2isis command to account for the different position of "_1" in the filename.

#make list
file_list=`ls *_1.QUB`

#Loop through all the .qub files
for i in $file_list
do

	# iteratively step through each file in the list using the first 21 or 22 characters of the filename as the root name. Characters are collected using the cut command.
	# for IR detector take first 21 characters
	# for VIS detector take first 22 characters
	rootname=`echo $i | cut -c-22`
	
	echo - - - - - - - - - - - - - - - - - - - - - - - -
	echo Current file being processed: $i
	echo - - - - - - - - - - - - - - - - - - - - - - - -
	echo Working name of file being processed: $rootname

	#dawnvir2isis
	echo - - - - - - - - - - - - - - - - - - - - - - - -
	echo Converting to ISIS image cube
	dawnvir2isis from=${rootname}_1.LBL image=${rootname}_1.QUB hkfrom=${rootname}_HK_1.LBL hktable=${rootname}_HK_1.TAB to=${rootname}_1_vir2isis.cub

	#spiceinit
	echo - - - - - - - - - - - - - - - - - - - - - - - -
	echo Attaching spice information
	spiceinit from=${rootname}_1_vir2isis.cub ckpredicted=true shape=user model=/Users/bramble/Documents/DAWN_VIR/dawn_ceres_grv_icq1024_v2.bds

	#catlab
	echo - - - - - - - - - - - - - - - - - - - - - - - -
	echo Generating label file
	catlab from=${rootname}_1_vir2isis.cub to=${rootname}_1_vir2isis.lbl

	#phocube
	echo - - - - - - - - - - - - - - - - - - - - - - - -
	echo Generating photometry image cube
	phocube from=${rootname}_1_vir2isis.cub+35 to=${rootname}_1_vir2isis_phocube.cub emission=no incidence=no localemission=yes localincidence=yes
	
	#isis2pds
	#optional step to also produce PDS/IMG versions of the photometric image cubes
	#uncomment this following line if you wish to apply its functions
	#isis2pds from=${rootname}_1_vir2isis_phocube.cub to=${rootname}_1_vir2isis_phocube_isis2pds.img
	
	echo - - - - - - - - - - - - - - - - - - - - - - - -
	echo Completed processing of ${rootname}
	echo - - - - - - - - - - - - - - - - - - - - - - - -
done

#Rename the print.prt file to save image processing steps for posterity.

todaysdate=`date +"%Y%m%d%H%M"`
mv print.prt ./dawnvir_files_processed_${todaysdate}.txt
#rm print.prt

echo - - - - - - - - - - - - - - - - - - - - - - - -
echo Completed processing of DAWN VIR image cubes
echo - - - - - - - - - - - - - - - - - - - - - - - -

#Use ISIS cube (_vir2isis.cub) and photometry cube (_phocube.cub) for analysis in PYTHON/GDAL/RASTERIO
