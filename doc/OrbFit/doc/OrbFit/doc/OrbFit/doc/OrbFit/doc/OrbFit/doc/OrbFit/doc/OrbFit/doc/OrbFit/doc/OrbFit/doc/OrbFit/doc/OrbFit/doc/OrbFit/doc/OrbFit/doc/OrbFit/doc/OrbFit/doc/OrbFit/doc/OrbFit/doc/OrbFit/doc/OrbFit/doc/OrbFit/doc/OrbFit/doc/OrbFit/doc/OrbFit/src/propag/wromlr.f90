! Copyright (C) 1997-1998 by Mario Carpino (carpino@brera.mi.astro.it)  
! Modified by Andrea Milani, vers. 1.8.3, January 1999                  
! additional changes for scaling, vers.3.3.1, August 2005
! --------------------------------------------------------------------- 
!                                                                       
!  *****************************************************************    
!  *                                                               *    
!  *                         W R O M L R                           *    
!  *                                                               *    
!  *  Writes an orbital element record in an orbital element file  *    
!  *                     (multi-line format)                       *    
!  *                                                               *    
!  *****************************************************************    
!                                                                       
! INPUT:   UNIT      -  Output FORTRAN unit                            
!           NAME0      -  Name of planet/asteroid/comet                  
!           ELEM(6)   -  Orbital element vector                         
!           ELTYPE    -  Type of orbital elements (KEP/EQU/CAR)         
!           T0        -  Epoch of orbital elements (MJD, TDT)           
!           COVE      -  Covariance matrix of orbital elements          
!           DEFCOV    -  Tells whether the covariance matrix is defined 
!           NORE      -  Normal matrix of orbital elements              
!           DEFNOR    -  Tells whether the normal matrix is defined     
!           H         -  H absolute magnitude (if <-100, missing)       
!           G         -  G slope parameter                              
!           MASS      -  Mass (solar masses)                            
!                                                                       
! WARNING: the routine does not write the header of the file: this      
!          must be generated by calling subroutine wromlh               
!                                                                       
SUBROUTINE wromlr(unit,name0,elem,eltype,t0,cove,defcov,nore,defnor,h,g,mass)    
  USE fund_const  
  USE output_control
  USE name_rules  
  USE io_elems, ONLY: obscod  
  IMPLICIT NONE
  INTEGER, INTENT(IN) :: unit 
  DOUBLE PRECISION, INTENT(IN) :: elem(6),t0,h,g,cove(6,6),nore(6,6),mass
  CHARACTER*(*), INTENT(IN):: name0,eltype 
  LOGICAL, INTENT(IN) ::  defcov,defnor 
! ------------END INTERFACE -------------------------------
  DOUBLE PRECISION gammas(6,6),scales(6),units(6) ! for scaling 
  CHARACTER*(idnamvir_len) name
  INCLUDE 'parcmc.h90'
  INTEGER l1,ln,i,k,iwd,j 
  DOUBLE PRECISION cnv(6),std(6), ele(6)
  INTEGER lench 
  EXTERNAL lench 
! eigenvalues, eigenvectors                                             
  DOUBLE PRECISION eigvec(6,6),eigval(6),fv1(6),fv2(6),wdir(6),sdir
  INTEGER ierr 
! Name
  name=' '
  name=name0                                                                  
  ln=lench(name) 
  IF(ln.LE.0) THEN 
     name='????' 
     ln=4 
  END IF
  l1=1 
  IF(name(l1:l1).EQ.' ') THEN 
     DO 1 l1=1,ln 
        IF(name(l1:l1).NE.' ') GOTO 2 
1    CONTINUE 
2    CONTINUE 
     IF(l1.GT.ln) THEN 
        name='????' 
        ln=4 
     END IF
  END IF 
  WRITE(unit,100) name(l1:ln) 
100 FORMAT(A)
! Orbital elements                                                      
  cnv=1.d0 
  ele=elem
  IF(eltype.EQ.'KEP') THEN 
     cnv(3:6)=degrad 
     if(ele(6).lt.0.d0)ele(6)=ele(6)+dpig 
     if(ele(5).lt.0.d0)ele(5)=ele(5)+dpig 
     if(ele(4).lt.0.d0)ele(4)=ele(4)+dpig 
     WRITE(unit,201) comcha 
  201 FORMAT(A,' Keplerian elements: a, e, i, long. node,', &
           &         ' arg. peric., mean anomaly')  
     WRITE(unit,101) (ele(i)*cnv(i),i=1,6) 
101  FORMAT(' KEP ',1P,E22.14,0P,F18.15,4F18.13) 
  ELSEIF(eltype.EQ.'CAR') THEN 
     WRITE(unit,202) comcha 
202  FORMAT(A,' Cartesian position and velocity vectors') 
     WRITE(unit,102) ele 
102  FORMAT(' CAR ',1P,6E22.14) 
  ELSEIF(eltype.EQ.'EQU') THEN 
     cnv(6)=degrad 
     IF(ele(6).lt.0.d0)THEN 
        IF(verb_io.ge.9) WRITE(*,*) ' wromlr: negative mean longitude', ele(6)*cnv(6) 
        ele(6)=ele(6)+dpig 
     ENDIF
     WRITE(unit,203) comcha 
  203 FORMAT(A,' Equinoctial elements: a, e*sin(LP), e*cos(LP),',       &
     &         ' tan(i/2)*sin(LN), tan(i/2)*cos(LN), mean long.') 
     WRITE(unit,103) (ele(i)*cnv(i),i=1,6) 
  103 FORMAT(' EQU ',1P,E22.14,0P,2(1x,f19.15),2(1x,f20.15),1x,F17.13) 
  ELSEIF(eltype.EQ.'COM') THEN 
     cnv(3:5)=degrad 
     if(ele(5).lt.0.d0)ele(5)=ele(5)+dpig 
     if(ele(4).lt.0.d0)ele(4)=ele(4)+dpig 
     WRITE(unit,204) comcha 
  204 FORMAT(A,' Cometary elements: q, e, i, long. node,', &
           &         ' arg. peric., pericenter time')  
     WRITE(unit,114) (ele(i)*cnv(i),i=1,6) 
114  FORMAT(' COM ',1P,E22.14,0P,1x,F18.15,1x,3(F18.13,1x),F18.10) 
  ELSEIF(eltype.eq.'ATT') THEN
     cnv(1:4)=degrad
     IF(ele(1).lt.0.d0)ele(1)=ele(1)+dpig
          WRITE(unit,205) comcha 
  205 FORMAT(A,' Attributable elements: R.A., DEC, R.A.dot, DECdot, r, rdot,', &
           &         ' auxiliary information on observer needed')  
     WRITE(unit,115) (ele(i)*cnv(i),i=1,6) 
115  FORMAT(' ATT ',2(F18.13,1x),2(F18.13,1x),2(F18.13,1x)) 
     WRITE(unit,116) ' STA ',obscod
116  FORMAT(A5,A3)
  ELSE
     WRITE(*,*)  '**** wromlr: unsupported orbital element type ****', eltype
     STOP '**** wromlr: unsupported orbital element type ****' 
  END IF
! Epoch                                                                 
  WRITE(unit,104) t0 
104 FORMAT(' MJD ',F19.9,' TDT')                                                                     
! Mass                                                                  
  IF(mass.NE.0.d0) WRITE(unit,105) mass 
105 FORMAT(' MAS ',1P,E20.12)                                              
! Magnitudes                                                            
  IF(h.GT.-100.d0) WRITE(unit,106) h,g 
106 FORMAT(' MAG ',2F7.3)                                                 
! Covariance matrix                                                     
  IF(defcov) THEN 
     DO i=1,6 
        std(i)=SQRT(cove(i,i))
     ENDDO 
! eigenvalues
     gammas=cove  
     CALL weak_dir(gammas,wdir,sdir,-1,eltype,ele,units)
     scales=1.d0/units
     DO i=1,6
        DO j=1,6
           gammas(i,j)=gammas(i,j)*(scales(i)*scales(j))
        ENDDO
     ENDDO
     CALL rs(6,6,gammas,eigval,1,eigvec,fv1,fv2,ierr) 
     DO i=1,6 
        IF(eigval(i).gt.0.d0)THEN 
           eigval(i)=sqrt(eigval(i)) 
        ELSE 
           IF(eigval(i).lt.-1.d-10)THEN
              WRITE(*,*)'wromlr: zero/negative eigenvalue', eigval(i),'  for asteroid ',name(l1:ln)
           ENDIF 
           eigval(i)=-sqrt(-eigval(i)) 
        ENDIF
     ENDDO
! RMS, eigenvalues and weak direction are so far commented              
     WRITE(unit,107) comcha,(std(i)*cnv(i),i=1,6) 
107  FORMAT(A1,' RMS ',1P,6E14.5) 
     WRITE(unit,111) comcha,eigval 
111  FORMAT(A1,' EIG',1P,6E14.5) 
     WRITE(unit,110) comcha,wdir 
110  FORMAT(A1,' WEA',6F10.5) 
! covariance matrix is given uncommented, to be readable                
     WRITE(unit,108) ((cove(i,k)*cnv(i)*cnv(k),k=i,6),i=1,6) 
108  FORMAT(' COV ',1P,3E23.15) 
  END IF                                                                      
! Normal matrix                                                         
  IF(defnor) THEN 
     WRITE(unit,109) ((nore(i,k)/(cnv(i)*cnv(k)),k=i,6),i=1,6) 
109  FORMAT(' NOR ',1P,3E23.15) 
  END IF
END SUBROUTINE wromlr
