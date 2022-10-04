# ImportUtility
# 1. General remarks

Either copy the content of the ps1-files to a powershell console or download the executables.
Note that the exe-files were created with ps2exe (see https://github.com/MScholtes/PS2EXE) and may be falsely flagged as malicious programs by your antivirus software.
The exe files CAN ONLY BE STOPPED by killing the task in the task manager or by finishing the questionnaire process. In general it is recommended to either copy paste to powershell or excecuting the ps1 scripts (right click > run with powershell)


# 2. Walkthrough Import/Rename
    1.) Paste the path to the data. If the individual data files are located in multiple subfolders paste the path to the parent folder which contains all relevant     
        data.
    2.) Decide if you want to create (a) a TrakEM import text file or (b) rename files by incorporating their (grand-)parent folder name
       a)   IMPORT 
       a1)  Type import
       a2)  Type the width of your image files. If the width varies from one image to another, type the maximum width. If you are unsure about max-width give an
            arbitrary large value.
       a3)  Type the height of your image files. 
       a4)  Type X-overlap in pixels you specified in your imaging software. If you are unsure about exact overlap use something like 10% of image width.
       a5)  Type Y-overlap in pixels you specified in your imaging software. If you are unsure about exact overlap use something like 10% of image height.
       a6)  Type the Z-location of the substack. This value is only important if the project spans multiple wafers or imaging runs. In this case, wafer 1 could start
            with section 0 and wafer 2 could then start with section 250.
       a7)  8bit or 16bit. Type 8 or 8bit or 16 or 16bit depending on the bit depth you chose in your imaging software. This will set max and min grey-values and 
            image type for TrakEM.
       a8)  File extension. Type the file extension without fullstop. E.g. tif and not .tif.
       a9)  File name template. If your data follows standard naming schemes of Zeiss ATLAS5 or Thermo MAPS3 you can use templates by typing Zeiss or Thermo. If the               name is different you have to create a name template. In the template you have to replace meaningful digits by #z#, #x# or #y#, random or for   
            alignment/stitching
            irrelevant digits have to be replaced by \d+. A few examples:
            I) Sample_negstain_x1-y5_G216902-J2_0245_Mag-20kx --> Sample_negstain_#x#-#y#_G\d+-J\d+_\d+_Mag-\d+kx
           (if any of the irrelevant digits is constant it can be kept as is, for example Mag stays 20kx template could be Georg_negstain_#x#-#y#_G\d+-J\d+_\d+_Mag-               20kx)
            II) image1 --> image#z#
           and so on...
       a10) Copy all files to folder? Type Y to copy all files to a newly created raw_data folder created at ..\specified_path or N to exit script.
            NOTE if multiple images share names due to the datastructure being something like below run the renaming part of the script first (b).
              .\Z-location1\imageX1Y1.tif
              .\Z-Location2\imageX1Y1.tif
              .\...
       NOTE that a2) to a5) are only really important if the stack is tiled. Since the x and y location of each tile is calculated by (x-variable*width)-overlapX or 
       (y-variable*height)-overlapY respectively. The goal is to specify width/height and x/y overlap in a way that 'tiles are roughly in place' in the TrakEM 
       stitching dialog can be used later on.
       b)   RENAME
       b1)  Type rename.
       b2)  Specify the name giving folders level. Type parent, grandparent or greatgrand.
            A few examples. Folder structure is:
            
            .\somename\anothername\z-location1\imagex1y1.tif
            .\somename\anothername\z-location2\imagex1y1.tif
            .\somename\anothername\z-location3\imagex1y1.tif
            
            Filenames if parent was typed are z-location1-imagex1y1.tif,z-location2-imagex1y1.tif and z-location3-imagex1y1.tif
            Filenames if grandparent was typed are anothername-imagex1y1.tif,anothername-imagex1y1.tif and anothername-imagex1y1.tif
            Filenames if greatgrand was typed are somename-imagex1y1.tif,somename-imagex1y1.tif and somename-imagex1y1.tif
       b3)  File extension. Type the file extension without fullstop. E.g. tif and not .tif.
       NOTE that the script will rename every file with the specified extension in all subfolders of the specified path. A template function is not implemented yet.
       If the file type you want to rename is not included add it to line 129 of the script by adding -or ($extension -match "(?<![\w\d])jpg(?![\w\d])"), where jpg is        replaced by your desired extension.
       
 # 3. Walktrough diff-2-txtfiles
      1) Set working directory
      2) Give old file name, include extension eg RawImgList.txt
      3) Give new file name, include extension eg RawImgList2.txt
 # A new txtfile named Only_diff_import.txt will be created. This file includes only lines which are in the new file but NOT in the old one. This may help if imaging is going on for a longer period of time and parts of the stack were imported prematurely. Say an import txt file has been created when only sections 1-100 were imaged and these were stitched and aligned in TrakEM. If later on sections 101-200 finished imaging, the import txtfile can be created the same way as before. To then import ONLY the additional images to TrakEM one can diff the old and new import txt files. When choosing import from text file.. and the same base layer as before (z=0.0 [layer]) one will not import duplicates and can continue stitching/aligning the second part.


#Import, stitching and aligning in TrakEM2 (https://github.com/trakem2/TrakEM2)
1) In FIJI
  I) File>New>TrakEM2 (blank). Set storage folder close to image location. If possible work from fastest available directory/disk. If multiple local disks are available consider Raid0 disk striping to improve read/write speed.
2) In TrakEM2
  II) Adjust settings before importing
    a) Right click on canvas>Project>Project properties...
      Image resizing mode > Area downsampling
      Bucket side length > 40960 pixels
      Autosave every > 1000000 minutes
      Number of threads for mipmaps > max available cores (check how many via cmd > echo %NUMBER_OF_PROCESSORS%)
    #I noticed crashes when importing from slow drives when max cores were used, if crashes occur use slightly less.
    b) To be sure Right click on canvas>Project>Release Memory... slider to max value
       and Right click on canvas>Project>Flush image cache
  III) Importing data from a text file
    a) Right click on canvas>Import>Import from text file...
    b) Window1: Select the previously created text file
    c) Window2: Base layer 1: z=0.0 [layer]
                Default setting for all other values
    d) Window3: Select Image directory (all images have to be at same level in one folder)
  IV) Stitching (Usually the slowest step)
    a) Right click on canvas>Align>Montage multiple layers... (Or All images in this layer... to test settings)
    b) Window1: Choose range (usually max range in both directions, except for Layer1 which will be empty)
    c) Window2: Montage mode > least squares (usually works best)
    d) Window3: Sift parameters
                Initial gaussian blur: 1.6
                steps per scale octave: 3
                minimum image size: 512 (Increased value to use more small features for stitching, since large features may not be sufficient to stitch accurately)
                                    [try 256 if 512 was too slow or not working as expected]
                maximum image size: something between 1536 and 2048 (aim for ~8000 detected features)
                feature descriptor size: 8
                feature descriptor orientation bins: 8
                closest/next closest ratio: 0.92
    e) Window4: Geometric Consensus Filter
                maximal alignment error: try 100 px (if not working try 200)
                minimal inlier ratio: 0.0
                minimal number of inliers: 7
                expected transformation: Rigid (Try translation if rigid was not working for some reason)
                ignore constant background: unticked
                tolerance: 0.5px (irrelevant here)
    f) Window5: Alignment parameters
                desired transformation: Translation (Try Rigid if translation was not working)
                correspondence weight: 1
                regularize: unticked (usually works, but ticked and more maximal iterations can help to improve stitching sometimes)
                optimization:
                  maximal iterations: 4000
                maximal plateauwidth: 200
                filter outliers: unticked
                  mean factor: 3
                        Optional window5b if regularize was ticked: regularizer to translation and lambda to ~0.25. This only helps if desired trafo was rigid or                               more.
    g) Window6: Miscellaneous
                tiles are roughly in place: ticked (safes lots of comparisons/time if it is actually true unticked if the tiles are randomly placed)
                sloppy overlap test (fast): unticked (does usually not work for me but may be worth a try on a single layer)
                consider largest graph only: unticked
                hide tiles from non largest graph: unticked (but can be ticked if tiles without stitching correspondences are annoyingly placed on top of main stitch                   area)
                delete tiles from non largest graph: unticked
#Repeat the stitching on single layers until good parameters were found. Usually changes in min and max image size have biggest influence on success/failure of     stitching attempts.

V) Alignment
    a) Right click on canvas>Align>Align layers...
      Optional window 1a: If you have placed a rectangle ROI you can use it to only find features inside the rectangle for alignment. This can be helpful for fine             alignments of a smaller subROI in large planes.
    b) Window1: Align Layers 
                mode: least squares (linear feature correspondences)
               Layer Range:
                first:set to whatever you want to align
                reference: i use *None* but if a certain sections is a desirable template select that one.
                last: set to whatever you want to align
                use only images whose title matches:
                use visible images only: ticked
                propagate transform to first layer: unticked (or ticked if only a part of the stack will be aligned)
                propagate transform to last layer: unticked (or ticked if only a part of the stack will be aligned)
    d) Window2: Sift parameters
              Scale Invariant Interest Point Detector:
                Initial gaussian blur: 1.6
                steps per scale octave: 3
                minimum image size: 256 (Increased value to use a bit more small features for alignment, since large features may not be sufficient to align)
                                   [try something between 128 and 512 if 256 was not OK smaller values will omit smaller features]
                maximum image size: something between 1024 and 2048 (aim for ~8000 detected features)
                                   [try smaller values first and increase if not enough features are found]
              Feature Descriptor:
                feature descriptor size: 8
                feature descriptor orientation bins: 8
              Local Descriptor Matching:
                closest/next closest ratio: 0.92
              Miscellaneous:
                clear cache: ticked
                feature extraction threads: use max available cores (check how many via cmd > echo %NUMBER_OF_PROCESSORS%)
    e) Window4: Geometric Filters
                maximal alignment error: try 100 px (sometimes running multiple alignments with decreasing error can improve final alignment)
                minimal inlier ratio: 0.0
                minimal number of inliers: 12
                expected transformation: Affine (Try rigid if affine was not working for some reason)
                test multiple hypotheses: unticked
                wideset only: unticked
                ignore constant background: usually unticked (ticked may help if large empty areas are present)
                  tolerance: 5 px
              Layer neighbor range:
                test maximally: 5 layers
                give up after: 3 failures
                #####################################Continue here
    f) Window5: Alignment parameters
                desired transformation: Translation (Try Rigid if translation was not working)
                correspondence weight: 1
                regularize: unticked (usually works, but ticked and more maximal iterations can help to improve stitching sometimes)
                optimization:
                  maximal iterations: 4000
                maximal plateauwidth: 200
                filter outliers: unticked
                  mean factor: 3
    g) Window6: Miscellaneous
                tiles are roughly in place: ticked (safes lots of comparisons/time if it is actually true unticked if the tiles are randomly placed)
                sloppy overlap test (fast): unticked (does usually not work for me but may be worth a try on a single layer)
                consider largest graph only: unticked
                hide tiles from non largest graph: unticked (but can be ticked if tiles without stitching correspondences are annoyingly placed on top of main stitch                   area)
                delete tiles from non largest graph: unticked
    
    
    
    
      
 
