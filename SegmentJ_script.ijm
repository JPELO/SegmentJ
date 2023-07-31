// Select source directory and destination directories.
dir_source = getDirectory("Choose Data Directory");
dir_scans = dir_source + "Scans (original)/";
dir_subscans = dir_source + "Scans (sub)/";
dir_imseq = dir_source + "Image Sequences/";
dir_msdata = dir_source + "Data (microstructure)/";
dir_graindata = dir_source + "Data (grain)/";
dir_stl = dir_source + "STL Files/";

// Get user inputs for date and volume percentage
edgeLength = getNumber("Enter Subsample Edge Length (px):",150);

// Get list of files in selected source directory and set
// batch mode to "true".
list = getFileList(dir_scans);
setBatchMode(true);

// Set up batch iteration loop.
for (i=0; i<list.length; i++) {
	
	// Display current progress with files.
	showProgress(i+1, list.length);
	
	// Open file(i) and get some file metadata.
	print("Scan Name: " + list[i]);
	print("Scan Number: " + i+1 + "/" + list.length + "\n");
	open(dir_scans + list[i]);
	scanName = substring(getTitle,0,getTitle.length-4);

	// Get scan size dimension & number of X,Y,Z locations.
	getDimensions(width, height, channels, slices, nFrames);
	nX = floor(width/edgeLength); nY = floor(height/edgeLength); nZ = floor(slices/edgeLength);
	
	// Loop through all X, Y, and Z locations. Create counter.
	count = 1;
	for (z = 1; z<=nZ; z++) {
		zCoords = newArray((z-1)*edgeLength + 1,z*edgeLength);
		for (y = 1; y<=nY; y++) {
			yCoord = (y-1)*edgeLength;
			for (x = 1; x<=nX; x++) {
				xCoord = (x-1)*edgeLength;
				 
				// Select subsection and append count;
				selectWindow(scanName + ".tif");
				run("Specify...","width=" + edgeLength + " height=" + edgeLength + " x=" + xCoord +
					" y=" + yCoord + " slice=1");
				subscanName = scanName + "_" + IJ.pad(count, 3);
				run("Duplicate...", "title=" + subscanName + " duplicate range=" + zCoords[0] + "-" + zCoords[1]);
				saveAs("Tiff", dir_subscans + subscanName);
				count++;
				
				// Export image sequence.
				File.makeDirectory(dir_imseq + subscanName + "/");
				run("Image Sequence... ", "select=[" + dir_subscans + subscanName + "] dir=[" + dir_imseq +
					subscanName + "/] format=TIFF name=" + subscanName + "_" + " digits=4");
				
				// Perform watershed.
				run("Distance Transform Watershed 3D", "distances=[Borgefors (3,4,5)] output=[16 bits] " +
					"normalize dynamic=2 connectivity=6");
				run("Set Label Map", "colormap=[Golden angle] background=black shuffle");
	
				// Analyze grain regions.
				run("Analyze Regions 3D", "voxel_count volume surface_area mean_breadth sphericity " +
					"euler_number bounding_box centroid equivalent_ellipsoid ellipsoid_elongations " +
					"max._inscribed surface_area_method=[Crofton (13 dirs.)] euler_connectivity=6");
				saveAs("Results", dir_graindata + subscanName + "_grainscan" + ".csv");
				selectWindow(subscanName + "_grainscan" + ".csv"); run("Close");
				
				// Get morphological microstructure data.
				run("Microstructure 3D", "volume surface mean_breadth euler surface_0=[Crofton (13 dirs.)] " +
				"mean=[Crofton (13 dirs.)] mean_0=4 euler_0=6");
				saveAs("Results", dir_msdata + subscanName + "_msdata" + ".csv");
				selectWindow(subscanName + "_msdata" + ".csv"); run("Close");
				
//				// Export .STL mesh file.
//				selectWindow(subscanName + ".tif");
//				run("3D Viewer");
//				call("ij3d.ImageJ3DViewer.setCoordinateSystem", "false");
//				call("ij3d.ImageJ3DViewer.add", subscanName + ".tif", "White", subscanName +
//					".tif", "75", "true", "true", "true", "3", "2");
//				call("ij3d.ImageJ3DViewer.select", subscanName + ".tif");
//				call("ij3d.ImageJ3DViewer.exportContent", "STL ASCII", dir_stl + subscanName + ".stl");
//				call("ij3d.ImageJ3DViewer.close");
				
				// Close subsection windows
				selectWindow(scanName + ".tif");
				close("\\Others");
			}
		}
	}	
}