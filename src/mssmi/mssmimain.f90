!test the reheating derivation from slow-roll
program mssmimain
  use infprec, only : kp
  use cosmopar, only : lnRhoNuc, powerAmpScalar
  use mssmisr, only : mssmi_epsilon_one, mssmi_epsilon_two, mssmi_epsilon_three, mssmi_x_epsilon1_min
  use mssmireheat, only : mssmi_lnrhoend, mssmi_x_star
  use infinout, only : delete_file, livewrite
  use srreheat, only : log_energy_reheat_ingev


  implicit none

  
  real(kp) :: Pstar, logErehGeV, Treh

  integer :: i,j
  integer :: npts,nalpha

  real(kp) :: alpha,w,bfoldstar,alphamin,alphamax
  real(kp) :: lnRhoReh,xstar,eps1,eps2,eps3,ns,r

  real(kp) :: lnRhoRehMin, lnRhoRehMax
  real(kp), dimension(2) :: vecbuffer

  real(kp) ::x,xmin,xmax,Riem


  Pstar = powerAmpScalar



!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!        Calculates the reheating predictions           !!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  npts = 20
  nalpha=30

  w=0._kp
!  w = 1._kp/3._kp

  call delete_file('mssmi_predic.dat')
  call delete_file('mssmi_nsr.dat')


  !Prior on alpha
  alphamin=10._kp**(-8.)
  alphamax=10._kp**(-3.)


  do j=0,nalpha
       alpha=alphamin*(alphamax/alphamin)**(real(j,kp)/real(nalpha,kp))
 

  lnRhoRehMin = lnRhoNuc
  lnRhoRehMax = mssmi_lnrhoend(alpha,Pstar)

  print *,'alpha=',alpha,'lnRhoRehMin=',lnRhoRehMin, 'lnRhoRehMax= ',lnRhoRehMax

  do i=1,npts

       lnRhoReh = lnRhoRehMin + (lnRhoRehMax-lnRhoRehMin)*real(i-1,kp)/real(npts-1,kp)

       xstar = mssmi_x_star(alpha,w,lnRhoReh,Pstar,bfoldstar)


       eps1 = mssmi_epsilon_one(xstar,alpha)
       eps2 = mssmi_epsilon_two(xstar,alpha)
       eps3 = mssmi_epsilon_three(xstar,alpha)


       print *,'lnRhoReh',lnRhoReh,' bfoldstar= ',bfoldstar,'xstar=',xstar,'eps1star=',eps1

       logErehGeV = log_energy_reheat_ingev(lnRhoReh)
       Treh = 10._kp**( logErehGeV -0.25_kp*log10(acos(-1._kp)**2/30._kp) )

       ns = 1._kp - 2._kp*eps1 - eps2
       r =16._kp*eps1

       call livewrite('mssmi_predic.dat',alpha,eps1,eps2,eps3,r,ns,Treh)

       call livewrite('mssmi_nsr.dat',ns,r,abs(bfoldstar),lnRhoReh)
  
    end do


 end do



end program mssmimain
