* Copyright (C) 1997 by Mario Carpino (carpino@brera.mi.astro.it)
* Version: November 28, 1997
* ---------------------------------------------------------------------
* Options for ephemeris generation (ORBFIT)
*
* 
* iiceph      -  Initialization check
* kepobj      -  List of objects for which ephemeris is done
* nepobj      -  Number of entries in list kepobj
* teph1       -  Starting time for ephemeris (MJD, TDT)
* teph2       -  Ending time for ephemeris (MJD, TDT)
* dteph       -  Ephemeris stepsize (d)
* idsta       -  Observatory code
* ephtsc      -  Time scale
* ephfld      -  Output fields
*
      INTEGER idsta,kepobj(3),nepobj,iiceph
      DOUBLE PRECISION teph1,teph2,dteph
      CHARACTER*10 ephtsc
      CHARACTER*100 ephfld
      COMMON/cmeph1/idsta,kepobj,nepobj,iiceph
      COMMON/cmeph2/teph1,teph2,dteph
      COMMON/cmeph3/ephtsc
      COMMON/cmeph4/ephfld
