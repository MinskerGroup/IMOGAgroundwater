# Makefile for non-USGS distribution
#
# @ (#) Makefile for Modtools 27June1997
# (Supplied by L. Orzol -- erb)
#
SOURCELOC = 
UTILITYLOC = 
NEWMOD = 
PROGRAM = mf2k
INCDIR= .

# Define the Fortran compile flags

F77FLAGS= -O2 

F77= g77

# Define the libraries

#SYSLIBS= -lmisalign -ldgc -lm 
SYSLIBS= -lc
USRLIB  = 

# Define all object files which make up Modtools

OBJECTS = \
	mf2k.o \
	amg1r6.o	\
	ctime.o	\
	daf1.o \
	de45.o \
	glo1bas6.o \
	gutsdaf.o \
	gwf1bas6.o \
	gwf1bcf6.o \
	gwf1chd6.o \
	gwf1drn6.o \
	gwf1drt1.o \
	gwf1ets1.o \
	gwf1evt6.o \
	gwf1fhb1.o \
	gwf1gag5.o \
	gwf1ghb6.o \
	gwf1hfb6.o \
	gwf1huf2.o \
	gwf1ibs6.o \
	gwf1lak3.o \
	gwf1lpf1.o \
	gwf1mnw1.o \
	gwf1rch6.o \
	gwf1res1.o \
	gwf1riv6.o \
	gwf1str6.o \
	gwf1wel6.o \
	hufutl2.o \
	hydmod.o \
	lmg1.o \
	lmt6.o \
	memchk.o \
	obs1adv2.o \
	obs1bas6.o \
	obs1drn6.o \
	obs1drt1.o \
	obs1ghb6.o \
	obs1riv6.o \
	obs1str6.o \
	parutl1.o \
	pcg2.o \
	pes1bas6.o \
	pes1gau1.o \
	rtedaf.o \
	sen1bas6.o \
	sen1chd6.o \
	sen1drn6.o \
	sen1drt1.o \
	sen1ets1.o \
	sen1evt6.o \
	sen1ghb6.o \
	sen1hfb6.o \
	sen1huf2.o \
	sen1lpf1.o \
	sen1rch6.o \
	sen1riv6.o \
	sen1str6.o \
	sen1wel6.o \
	sip5.o \
	sor5.o \
	utl6.o \
	para-non.o

install: mf2k

# Define Task Function Program Modtools

all: mf2k

# Define what Modtools is

mf2k: $(OBJECTS)
	-$(F77) $(F77FLAGS) -o mf2k $(OBJECTS) $(USRLIB) $(SYSLIBS)

# Modtools_Object codes

mf2k.o: mf2k.f
	$(F77) $(F77FLAGS) -c mf2k.f


# PARALLEL PROCESSING OPTION.  To use MPI, uncomment the following 2 lines
# and replace "para-non.o" with "para-mpi.o" in definition of OBJECTS above.
#para-mpi.o: parallel/para-mpi.f
#	$(F77) $(F77FLAGS) -I$(INCDIR) -c parallel/para-mpi.f

# SERIAL PROCESSING OPTION.  To use MPI, comment out the following 2 lines:
para-non.o: serial/para-non.f
	$(F77) $(F77FLAGS) -I$(INCDIR) -c serial/para-non.f


# Pth_Object codes of Modtools

.f.o:
	$(F77) $(F77FLAGS) -c $<

clean:
	- rm *.o core

#  end
