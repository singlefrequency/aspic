!test the reheating derivation from slow-roll
program wrimwrin
  use infprec, only : kp
  use cosmopar, only : lnRhoNuc, powerAmpScalar
  use wrisr, only : wri_epsilon_one, wri_epsilon_two, wri_epsilon_three,wri_x_endinf
  use wrireheat, only : wri_lnrhoreh_max, wri_x_star
  use infinout, only : delete_file, livewrite
  use srreheat, only : log_energy_reheat_ingev

  use wrisr, only : wri_norm_potential, wri_x_endinf
  use wrireheat, only : wri_x_rreh, wri_x_rrad
  use srreheat, only : get_lnrrad_rreh, get_lnrreh_rrad, ln_rho_endinf
  use srreheat, only : get_lnrrad_rhow, get_lnrreh_rhow, ln_rho_reheat

  use infinout, only : aspicwrite_header, aspicwrite_data, aspicwrite_end
  use infinout, only : labeps12, labnsr, labbfoldreh 
  
  implicit none

  
  real(kp) :: Pstar, logErehGeV, Treh

  integer :: i,j
  integer :: npts = 10

  integer :: Nphi0
  real(kp), parameter :: phi0min=10._kp**(-3._kp)
  real(kp), parameter :: phi0max=10._kp**(3._kp)

  real(kp) :: phi0,w,bfoldstar
  real(kp) :: lnRhoReh,xstar,eps1,eps2,eps3,ns,r

  real(kp) :: lnRhoRehMin, lnRhoRehMax
  real(kp), dimension(2) :: vecbuffer

  real(kp) :: lnRmin, lnRmax, lnR, lnRhoEnd
  real(kp) :: lnRradMin, lnRradMax, lnRrad
  real(kp) :: VendOverVstar, eps1End, xend

  Nphi0=10

  Pstar = powerAmpScalar

  call aspicwrite_header('wri',labeps12,labnsr,labbfoldreh,(/'phi0'/))
  
  call delete_file('wri_predic.dat')
  call delete_file('wri_nsr.dat')

!  w = 1._kp/3._kp
  w=0._kp

  do j=0,Nphi0

     ! phi0=phi0min+(phi0max-phi0min)*(real(j,kp)/real(Nphi0,kp)) !arithmetic step
     phi0=phi0min*(phi0max/phi0min)**(real(j,kp)/real(Nphi0,kp)) !logarithmic step

     lnRhoRehMin = lnRhoNuc
     xEnd = wri_x_endinf(phi0)
     lnRhoRehMax = wri_lnrhoreh_max(phi0,xend,Pstar)

     print *,'phi0=',phi0,'lnRhoRehMin=',lnRhoRehMin, 'lnRhoRehMax= ',lnRhoRehMax

     do i=1,npts

        lnRhoReh = lnRhoRehMin + (lnRhoRehMax-lnRhoRehMin)*real(i-1,kp)/real(npts-1,kp)

	xstar = wri_x_star(phi0,xend,w,lnRhoReh,Pstar,bfoldstar)

        print *,'lnRhoReh',lnRhoReh,' bfoldstar= ',bfoldstar,'xstar=',xstar

        eps1 = wri_epsilon_one(xstar,phi0)
        eps2 = wri_epsilon_two(xstar,phi0)
        eps3 = wri_epsilon_three(xstar,phi0)

        logErehGeV = log_energy_reheat_ingev(lnRhoReh)

        Treh = 10._kp**( logErehGeV -0.25_kp*log10(acos(-1._kp)**2/30._kp) )

        ns = 1._kp - 2._kp*eps1 - eps2
        r =16._kp*eps1

        call aspicwrite_data((/eps1,eps2/),(/ns,r/),(/abs(bfoldstar),lnRhoReh/),(/phi0/))

        call livewrite('wri_true.dat',phi0,xEnd)

        call livewrite('wri_nsr.dat',ns,r,abs(bfoldstar),lnRhoReh)

     end do

  end do

 call aspicwrite_end()
 
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!          Testing Rrad/Rreh           !!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  write(*,*)
  write(*,*)'Testing Rrad/Rreh'

  lnRradmin=-42
  lnRradmax = 10
  phi0 = 1._kp
  xEnd = wri_x_endinf(phi0)
  do i=1,npts

     lnRrad = lnRradMin + (lnRradMax-lnRradMin)*real(i-1,kp)/real(npts-1,kp)

     xstar = wri_x_rrad(phi0,xend,lnRrad,Pstar,bfoldstar)

     print *,'lnRrad=',lnRrad,' bfoldstar= ',bfoldstar, 'xstar', xstar

     eps1 = wri_epsilon_one(xstar,phi0)

     !consistency test
     !get lnR from lnRrad and check that it gives the same xstar
     eps1end =  wri_epsilon_one(xend,phi0)
     VendOverVstar = wri_norm_potential(xend,phi0)/wri_norm_potential(xstar,phi0)

     lnRhoEnd = ln_rho_endinf(Pstar,eps1,eps1End,VendOverVstar)

     lnR = get_lnrreh_rrad(lnRrad,lnRhoEnd)
     xstar = wri_x_rreh(phi0,xend,lnR,bfoldstar)
     print *,'lnR',lnR, 'bfoldstar= ',bfoldstar, 'xstar', xstar

     !second consistency check
     !get rhoreh for chosen w and check that xstar gotten this way is the same
     w = 0._kp
     lnRhoReh = ln_rho_reheat(w,Pstar,eps1,eps1End,-bfoldstar,VendOverVstar)

     xstar = wri_x_star(phi0,xend,w,lnRhoReh,Pstar,bfoldstar)
     print *,'lnR', get_lnrreh_rhow(lnRhoReh,w,lnRhoEnd),'lnRrad' &
          ,get_lnrrad_rhow(lnRhoReh,w,lnRhoEnd),'xstar',xstar

  enddo

end program wrimwrin
