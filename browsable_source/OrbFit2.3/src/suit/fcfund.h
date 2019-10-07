* Copyright (C) 2000 by Mario Carpino (carpino@brera.mi.astro.it)
* Version: November 16, 2000
* ---------------------------------------------------------------------
* Computation of fundamental functions for correlation
* (to be included in different routines)
*
* REQUIRED VALUES:
*   kf1  = function integer code
*   par1 = value of the parameter
*   dt   = time lag
*
* COMPUTED VALUES:
*   ff1 = value of the function
*   fd1 = derivative of the function wrt the parameter
*
* Multiplicative coefficient (constant)
      IF(kf1.EQ.1) THEN
          ff1=par1
          fd1=1
* Exponential function
      ELSEIF(kf1.EQ.2) THEN
          ff1=EXP(-par1*dt)
          fd1=-dt*ff1
* Normal function
      ELSEIF(kf1.EQ.3) THEN
          ff1=EXP(-par1*(dt**2))
          fd1=-(dt**2)*ff1
* Parabola
      ELSEIF(kf1.EQ.4) THEN
          ff1=(1-par1*(dt**2))
          fd1=-(dt**2)
* ADD HERE NEW FUNCTIONS
