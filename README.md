# SegmentJ
SegmentJ is a custom ImageJ script to automatically create subscans from a larger 3D CT scan file, segment each subscan into individual grains, calculate morphological and other grain parameters, and export the subscan as a 3D-printable mesh file.

# Dependencies
To use SegmentJ, you must have the following plugins:
- 3D Viewer
- MorphoLibJ

# Instructions for Use
1. Download "SegmentJ_script.ijm" and "SegmentJ Folder Template" from this repository.
2. Add CT scans for segmenting into the "Scans (original)" folder.
3. Start ImageJ and open "SegmentJ_script.ijm" from the File menu.
4. Comment/Uncomment any calculations you don't need (For example, commenting out the "Export .STL mesh file" section will save a lot of time.
5. Press "Run" in the bottom-left corner of the window.
6. In the window that opens, select the folder containing all of the subfolders. The folders must be named exactly as they are in the template.
7. In the next window, type in the desired subscan size (in pixels).
8. The script should now run until completion.
9. Subscans will be named identical to the original scan, but with _### appended.
