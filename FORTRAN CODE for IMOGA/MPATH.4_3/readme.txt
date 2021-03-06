July, 2003
U. S. Geological Survey


                      MODPATH/MODPATH-PLOT Version 4.3
              Distribution for IBM-PC compatible computers


NOTE: Any use of trade, product or firm names is for descriptive purposes 
      only and does not imply endorsement by the U.S. Government.


Instructions for installing, executing, and testing MODPATH and
MODPATH-PLOT are provided below.

This version of the software is packaged for use on personal computers
using a Microsoft Windows operating system.


                             TABLE OF CONTENTS

                         A.  DISTRIBUTION FILE
                         B.  EXTRACTING FILES
                         C.  COMPILING
                         D.  INSTALLING
                         E.  RUNNING THE SOFTWARE
                         F.  TESTING
                         G.  REVISED INPUT INSTRUCTIONS

A. DISTRIBUTION FILE

The following self-extracting distribution file, containing the software,
test data sets, and information files, is currently available for
computer systems using one of the Microsoft Windows operating systems:

         mpath4_3.exe

File mpath.4_3/doc/modpath.txt describes the history of the software
versions.  Also included in directory mpath.4_3/doc is a Portable
Document Format (PDF) version of the MODPATH documentatoin
(ofr94464.pdf).

The PDF file is readable and printable on various computer platforms using
Acrobat Reader from Adobe.  The Acrobat Reader is freely available from
the following World Wide Web sites:
      http://www.adobe.com/
      http://www.shareware.com/



B. EXTRACTING FILES

Extract the files by executing file:

        mpath4_3.exe

When the extraction progrm runs, specify that the files should be
restored to directory C:\WRDAPP .  The following directory structure
will be created in C:\WRDAPP (the contents of each directory are shown
to the right):


	C:\WRDAPP
              |
              |-- MPATH90.4_3
              |       |
              |       |-- DATA       (MODPATH test data files)
              |       |
              |       |-- DOC        (Documentation in PDF format)
              |       |
              |       |-- MFOUTPUT   (MODFLOW output files for demo problem)
              |       |
              |       |-- SETUP      (Setup files, MODPATH and MODPATH-PLOT 
              |       |               executable files, and BAT files for
              |       |               running MODPATH and MODPATH-PLOT)
              |       |-- SRC
              |              |
              |              |
              |              |-- MPATH  (Source for MODPATH
              |              |
              |              |-- MPLOT  (Source for MODPATH-PLOT)
              |
              |
              |


C. COMPILING

An executable version of the code for personal computers is provided in
the setup directory.  This version has been compiled using the
Lahey/Fujitsu Fortran 95 compiler version 5.6e.

The source code is also provided in the src directory so that users can
generate the executable themselves. No support can be provided for
users generating their own versions of the software.  All of the source
code options that are specific to this Lahey compiler are contained in
files: MPATH4LF.FOR, MPLOT4LF.FOR, SYSLF.FOR, and OPENSPEC.INC. Files
MPATH4LF.FOR and MPLOT4LF.FOR contain the code to implement dynamic
memory allocation. SYSLF.FOR contains Lahey-specific code to retrieve
command-line arguments.  OPENSPEC.INC includes Lahey-specific
specifiers for opening unformatted files, which control the structure of
the unformatted files.  The code necessary to convert these files
back to standard, compiler-independent FORTRAN-77 is provided in
the files but is commented out. 

To recompile MODPATH-PLOT, it is necessary to have access to a Level 0A
GKS graphics subroutine library. This version of MODPATH-PLOT uses a
GKS library that is implemented using the Interacter Graphics Library.
To recompile the code, a license for Interacter is required.

The executable versions of MODPATH and MODPATH-PLOT provided here were
compiled using the Lahey AutoMake utility. The src directory contains
the files used by the Lahey Automake utility to control compilation.


D: INSTALLING


Files MPATH4.BAT and MPLOT4.BAT must be copied from the SETUP directory
to a directory in the user's search path. These BAT files rely on the
runfiles being located in directory C:\WRDAPP\MPATH.4_3\SETUP.



E. RUNNING THE SOFTWARE

After MODPATH and MODPATH-PLOT are properly installed in a directory
that is included in the user's search path, they are executed using the
commands MPATH4 and MPLOT4, respectively.

   NOTE: The unformatted files generated by MODFLOW (".HED" and ".BUD"
   files) were generated by a version of MODFLOW that was compiled with
   Lahey 95 Fortran using options that cause MODFLOW to create unformatted
   files without any structure. MODPATH and MODPATH-PLOT have been
   compiled using the same Lahey 95 compiler options, and therefore
   MODPATH and MODPATH can read the unformatted files geneated by the
   MODFLOW runfile. Other compilers could be used to compile MODPATH and
   MODPATH-PLOT provided that they cause unformatted files to be written
   in the same unstructured manner.  However, if options are used that
   cause a compiler to generate structured binary files, then it is
   generally necessary that MODPATH and MODPATH-PLOT be compiled with
   the same compiler used to compile MODFLOW.

   Starting with MODFLOW-2000 version 1.2, the USGS-distributed MODFLOW
   runfile for personal computers is compiled by the Lahey 95 compiler
   using the above-mentioned options for writing unstructured binary
   files.  If you are using an earlier version of a MODFLOW runfile
   produced by the USGS, then the head and budget unformatted files
   will not work with the current version of MODPATH and MODPATH-PLOT.

MODPATH-PLOT has been compiled using a GKS library that uses the
Interacter Graphics Library by Interactive Software Services.  The
following graphics devices have been incorporated:

Device 1 -- Screen only
Device 2 -- Screen and Windows Meta File -- output goes into file mplot.wmf
Device 3 -- Screen and PostScript File -- output goes into file mplot.ps
Device 4 -- Screen and DXF -- output goes into file mplot.dxf
Device 5 -- Screen and Windows Print Manager -- output goes to the current
                    default printer
Device 6 -- Screen and Windows Clipboard -- output goes to the clipboard,
                    which allows it to be pasted into other applications
                    that can accept graphics from the clipboard

After MODPATH-PLOT draws the plot on the screen, terminate the program
by striking any key with the active window being the MODPATH-PLOT graphics
window.


F. TESTING

Directory C:\WRDAPP\MPATH.4_3\DATA has data files for running the example
problems described in the MODPATH documentation.  Run these problems as
follows:

1. The MODFLOW output files needed to run the MODPATH example problems are
   already present in the DATA directory. So, you can run the MODPATH and
   MODPATH-PLOT DATA without running MODFLOW. This allows the example problems
   to be run even on computers that do not yet have MODFLOW installed or
   have a version of MODFLOW that was not compiled using the Lahey Fortran
   compiler. Extra copies of the MODFLOW output files also are located in 
   the MFOUTPUT directory.

   The files DEMO-S.NAM and DEMO-T.NAM are "name files" that contain a list 
   of MODFLOW data files and Fortran unit numbers for the MODFLOW steady 
   state and transient runs. Some versions of PC MODFLOW read these name files 
   directly to obtain data file information. If you have a version of MODFLOW 
   that is not set up to read a name file, or a version that reads a name file 
   with a different format, you will need to convert the information in the
   name files to the form required by your version of MODFLOW. MODFLOW-96,
   the latest version of MODFLOW from the USGS, will read the name file.

2. Once the MODFLOW output files have been generated, you can now run the 
   MODPATH example problems. The example problems are the same problems
   presented in the MODPATH manual (USGS Open-File Report 94-464). 

   MODPATH and MODPATH-PLOT use a combination of interactive and data file
   input. Interactive input is recorded in response files that can
   be used in subsequent runs in place of interactive input. Data
   files and response files have been prepared for 4 steady-state and 
   4 transient particle tracking analyses. The response files end with the
   suffix ".RSP". For example, PATH-S1.RSP and PLOT-S1.RSP are the response 
   files needed to run MODPATH and MODPATH-PLOT for the first steady state
   analysis. 
   
   To run MODPATH from a DOS window, type "MPATH4" and then press enter. To
   run MODPATH from Windows shortcut icon, edit the shortcut so that
   MODPATH will start in the DATA directory, then double click the MODPATH 
   shortcut icon to start the program. The program will prompt you for the 
   name of a response file. To have the program read input from a response 
   file, simply enter the name of the response file you want to use. If you 
   want to run MODPATH and enter the data interactively at the keyboard, just 
   press enter without typing the name of a file when prompted for the name 
   of a response file. 
   
   MODPATH-PLOT works in the same way. To run MODPATH-PLOT, either type 
   "MPLOT4" in a DOS window or double click the MODPATH-PLOT shortcut icon
   on the desktop. Then, enter the name of a response file, or enter a blank 
   line to input data interactively. MODPATH-PLOT will either generate a plot
   to a Windows Metafile, a PostScript file, or a DXF file.  You must view the
   results using a separate program.  For example, you can import a Windows
   Metafile into Microsoft Word.


3. Once you have run through all of the examples, you can create your own
   new runs by running MODPATH and MODPATH-PLOT interactively rather than 
   with response files. Note that after you run MODPATH interactively, your 
   responses are recorded in a file name MPATH.RSP. If you want to save this 
   file for future use, you must rename it to avoid overwriting it the next 
   time you run MODPATH. MODPATH-PLOT creates a response file named MPLOT.RSP.



G. REVISED INPUT INSTRUCTIONS

The purpose of this new version is to work with MODFLOW-2000. There are
two major changes to MODPATH.  One change involves the MAIN data file.
MODFLOW-96 did not always define the vertical elevations, so these were
required in MODPATH's main data file.  MODFLOW-2000 requires the
vertical elevation of all cells, including confining beds simulated
using the Quasi-3D Approach, to be defined in a discretization input
file.  Thus, MODPATH version 4 has been modified to read the elevations
from MODFLOW's discretization file.  The discretization file also
defines the number and length of stress periods, so this information is
no longer read from MODPATH's main data file.

The second change involves the way MODPATH determines where stresses
are located.  MODPATH versions 3_2 and earlier read the MODFLOW input
files for stresses.  These were read in order to identify the locations
of stresses and the faces to which a stress is applied (variable
IFACE). For WEL and RCH Packages, the MODFLOW files were also read to
define the actual stress rather than using data in the budget file. 
When parameters are defined in MODFLOW-2000 input data, the input files
are not compatible with MODFLOW-96.  Rather than modifying MODPATH to
read the new files, a new approach has been taken.  MODPATH no longer
reads any stress files.  Instead, the stress information is obtained
entirely from the budget file.  MODFLOW-2000 has been modified to save
IFACE in the budget file.



MODPATH VERSION 4 INPUT INSTRUCTIONS:

MODFLOW-2000 input files

1.  When point stresses are applied to faces, declare IFACE as an
Auxilary Variable in each point-stress input file, and use the COMPACT
BUDGET AUXILIARLY option in Output Control.  The IFACE values are only
written into the budget file if this Output Control option is used.


MODPATH Name File

1.  The MODFLOW discretization file must be included in the name file. 
Its file type is DIS.

2.  The stress packages should no longer be included in the name file. 
If they are included, they will be ignored.


MODPATH MAIN data file

1.  MAXSIZ HNOFLO  HDRY  NPART  IRCHTP  IEVTTP

IRCHTP indicates where recharge (if used in the model) is applied
          0 indicates distributed
          not 0 indicates the top face
IEVTTP indicates where evapotranspiration (if used in the model) is applied
          0 indicates distributed
          not 0 indicates the top face

2.  Options -- same as before

3.  LAYCON(NLAY)
          0 indicates confined
          not 0 indicates convertible or water table

4.  IBOUND(NCOL,NROW)
      Read one array for each layer

5.  POR(NCOL,NLAY)
      Read one array for each layer

Items 6A and 6B are required only for transient simulations:

6A.  TBEGIN

6B.  BeginPeriod  BeginStep  End Period  EndStep









