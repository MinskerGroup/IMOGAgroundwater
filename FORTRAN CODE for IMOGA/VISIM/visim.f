      program main
C%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
C                                                                      %
C Copyright (C) 1996, The Board of Trustees of the Leland Stanford     %
C Junior University.  All rights reserved.                             %
C                                                                      %
C The programs in GSLIB are distributed in the hope that they will be  %
C useful, but WITHOUT ANY WARRANTY.  No author or distributor accepts  %
C responsibility to anyone for the consequences of using them or for   %
C whether they serve any particular purpose or work at all, unless he  %
C says so in writing.  Everyone is granted permission to copy, modify  %
C and redistribute the programs in GSLIB, but only under the condition %
C that this notice and the above copyright notice remain intact.       %
C                                                                      %
C%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
c-----------------------------------------------------------------------
c
c                Volume Integration SIMulation
c                ******************************c
c The program is executed either by specifying the 
c parameter file as a commandline parameter  
c   visim visim.par
c or with no command line arguments
c   visim
c In the latter case the user
c will be prompted for the name of a parameter file.  The parameter
c file is described in the documentation 
c
c The output file will be a GEOEAS file containing the simulated values
c The file is ordered by x,y,z, and then simulation (i.e., x cycles
c fastest, then y, then z, then simulation number).  
c can be transformed to reproduce a target histogram.
c
c
c
c-----------------------------------------------------------------------
      include  'visim.inc'

      character tmpfl*80
      integer i,j
      real float
      logical testfl
c
c Input/Output units used:
c
      lin  = 1
      lout = 2
      ldbg = 3
      llvm = 4
      lkv  = 5
      lout_mean = 26

c
c Read the parameters and data (transform as required):
c


      call readparm


c
c Create Conditional Prob Lookup Table
c
c      if ((idrawopt.eq.2).or.(idrawopt.eq.4)) then
      if (idrawopt.eq.1) then
         call create_condtab
      endif


c     
c  setup the krige estimation variance matrix for honoring the local data 
c  (conditional simulation) if it is to be calculated in stead of read
c  from a seperate file.  
c     
      write(ldbg,*) 'icond=', icond      
      if(icond.eq.1.and.ivar.eq.0) then
c        call setup_krgvar
c	write(*,*) 'Kriging variance calculated'
      end if 

c
c  open the output file 
c
      open(lout,file=outfl,status='UNKNOWN')

      if (doestimation.eq.1) then 
         write(tmpfl,871) 'visim_estimation',outfl
         open(lout_mean,file=tmpfl,status='UNKNOWN')
 871     format(A,'_',A)
         write(lout_mean,110)
      endif

      write(lout,108)
      
 108  format('VISIM Realizations',/,'1',/,'value')  
 110  format('VISIM ESTIMATION',/,'2',/,'mean',/,'std')
      

c     INITIALIZE Data2Volume lookup table
      call  cov_data2vol(0,0,0,0,0,temp)
c      write(*,*) 'start  : Calculating Data2Vol covariance'
c      write(*,*) 'stop  : Calculating Data2Vol covariance'


c     INITIALIZE Volume2Volume lookup table
      call  cov_vol2vol(0,0,temp)
      

c next line should be set via parameter file.   
c      write(*,*) 'read_covtable',read_covtable
c      stop
      if (read_covtable.eq.1) then
c     ALSO CHECK IF FILES EXIST
         write(tmpfl,1871) 'cv2v',outfl
         inquire(file=tmpfl,exist=testfl)
         if(.not.testfl) then
            write(*,*) 'Could not read Covariance lookup table : ',
     1           tmpfl,' - Continuing without reading...'
         else
            if (idbg.gt.0) then
               write(*,*) 'Reading cv2v=',tmpfl
            endif
            open(9,file=tmpfl,status='unknown',form='unformatted')
            do i=1,nvol
               read(9) (cv2v(i,j),j=1,nvol)
            end do
            close(9)
         endif
         write(tmpfl,1871) 'cd2v',outfl
         inquire(file=tmpfl,exist=testfl)
         if(.not.testfl) then
            write(*,*) 'Could not read Covariance lookup table : ',
     1           tmpfl,' - Continuing without reading...'
         else
            if (idbg.gt.0) then
               write(*,*) 'Reading cd2v=',tmpfl
            endif
            open(9,file=tmpfl,status='unknown',form='unformatted')
            do i=1,nxyz
               read(9) (cd2v(i,j),j=1,nvol)
            end do
            close(9)
         endif
      endif

      
      
c      write(*,*) 'start : Calculating Vol2Vol covariance'
c      do i =1, nvol 
c         do j =i, nvol 
c            call cov_vol2vol(i,j,temp)
c            cv2v(i,j) = dble(temp)
c         enddo
c      enddo 
c      write(*,*) 'stop  : Calculating Vol2Vol covariance'
      
      
C        write(tmpfl,1871) 'cv2v_init',outfl
C        open(9, file=tmpfl, status = 'unknown')
       
C        do i=1,nvol
C           do j=1,nvol
C              write(9,*) i, j, cv2v(i,j)
C           end do
C        end do
C        close(9)


c
c     Open File Handle for lambdas
c
      write(tmpfl,1871) 'lambda',outfl
      open(99, file=tmpfl, status = 'unknown',form='unformatted')
      
c
c  begin the actual simulation 
c

      do isim =1, nsim 
c
c call visim for the simulation(s):
c
      
         call visim

      end do 

      close(lout) 
      if (doestimation.eq.1) close(lout_mean) 

      if (idbg.gt.-2) then
      
c         write(tmpfl,1871) 'txtcv2v',outfl
c         open(9, file=tmpfl, status = 'unknown')
c         do i=1,nvol
c            do j=1,nvol
c               write(9,*) i, j, cv2v(i,j)
c            end do
c         end do
c         close(9)

         write(tmpfl,1871) 'cv2v',outfl
         open(9,file=tmpfl,status='unknown',form='unformatted')
         do i=1,nvol
            write(9) ((cv2v(i,j)),j=1,nvol)
         end do
         close(9)

         write(tmpfl,1871) 'cd2v',outfl
         open(9,file=tmpfl,status='unknown',form='unformatted')
         do i=1,nxyz
            write(9) ((cd2v(i,j)),j=1,nvol)
         end do
         close(9)

 1871    format(A,'_',A)

c     Close file handle 99 (lambdas)
         
         close(99)


      endif


c
c Finished:
c
      if (idbg.gt.-1) then
         write(*,9998) VERSION
 9998    format(/' VISIM Version: ',f5.3, ' Finished'/)
      endif
      stop
      end

