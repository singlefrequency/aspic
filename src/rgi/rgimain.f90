!test the reheating derivation from slow-roll
program rgimain
  use infprec, only : kp
  use cosmopar, only : lnRhoNuc, powerAmpScalar
  use rgisr, only : rgi_epsilon_one, rgi_epsilon_two, rgi_epsilon_three
  use rgireheat, only : rgi_lnrhoreh_max, rgi_lnrhoreh_fromepsilon 
  use rgireheat, only : rgi_xp_fromepsilon, rgi_x_star
  use infinout, only : delete_file, livewrite
  use srreheat, only : log_energy_reheat_ingev

  use rgisr, only : rgi_norm_potential, rgi_x_endinf
  use rgireheat, only : rgi_x_rreh, rgi_x_rrad
  use srreheat, only : get_lnrrad_rreh, get_lnrreh_rrad, ln_rho_endinf
  use srreheat, only : get_lnrrad_rhow, get_lnrreh_rhow, ln_rho_reheat

  use infinout, only : aspicwrite_header, aspicwrite_data, aspicwrite_end
  use infinout, only : labeps12, labnsr, labbfoldreh
  
  implicit none


  real(kp) :: Pstar, logErehGeV, Treh

  integer :: i,j
  integer :: npts = 10

  integer :: Nalpha
  real(kp) :: alphamin=0.00001
  real(kp) :: alphamax=1._kp

  real(kp) :: alpha,w,bfoldstar
  real(kp) :: lnRhoReh,xstar,eps1,eps2,eps3,ns,r

  real(kp) :: lnRhoRehMin, lnRhoRehMax
  real(kp), dimension(2) :: vecbuffer


  real(kp) :: eps1A,eps2A,eps3A,nsA,rA,eps1B,eps2B,eps3B,nsB,rB,xstarA,xstarB

  real(kp) :: lnRmin, lnRmax, lnR, lnRhoEnd
  real(kp) :: lnRradMin, lnRradMax, lnRrad
  real(kp) :: VendOverVstar, eps1End, xend

  Nalpha = 10

  Pstar = powerAmpScalar

  call delete_file('rgi_predic.dat')
  call delete_file('rgi_nsr.dat')

  call aspicwrite_header('rgi',labeps12,labnsr,labbfoldreh,(/'alpha'/))
  
  w=0.


  do j=0,Nalpha

     alpha=alphamin*(alphamax/alphamin)**(real(j,kp)/real(Nalpha,kp))

     lnRhoRehMin = lnRhoNuc
     xEnd = rgi_x_endinf(alpha)
     lnRhoRehMax = rgi_lnrhoreh_max(alpha,xend,Pstar)

     print *,'alpha=',alpha,'lnRhoRehMin=',lnRhoRehMin, 'lnRhoRehMax= ',lnRhoRehMax

     do i=1,npts

        lnRhoReh = lnRhoRehMin + (lnRhoRehMax-lnRhoRehMin)*real(i-1,kp)/real(npts-1,kp)

        xstar = rgi_x_star(alpha,xend,w,lnRhoReh,Pstar,bfoldstar)

        print *,'lnRhoReh',lnRhoReh,' bfoldstar= ',bfoldstar,'xstar=',xstar

        eps1 = rgi_epsilon_one(xstar,alpha)
        eps2 = rgi_epsilon_two(xstar,alpha)
        eps3 = rgi_epsilon_three(xstar,alpha)

        logErehGeV = log_energy_reheat_ingev(lnRhoReh)
        Treh = 10._kp**( logErehGeV -0.25_kp*log10(acos(-1._kp)**2/30._kp) )

        ns = 1._kp - 2._kp*eps1 - eps2
        r =16._kp*eps1

        call aspicwrite_data((/eps1,eps2/),(/ns,r/),(/abs(bfoldstar),lnRhoReh/),(/alpha/))

        call livewrite('rgi_true.dat',alpha,xEnd)

        call livewrite('rgi_nsr.dat',ns,r,abs(bfoldstar),lnRhoReh)

     end do

  end do

  call aspicwrite_end()
  
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  !! Write Data for the summarizing plots !!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  call delete_file('rgi_predic_summarized.dat') 
  nalpha=1000
  alphamin=10._kp**(-5.)
  alphamax=10._kp**(4.)
  w=0._kp
  do j=1,nalpha
     alpha=alphamin*(alphamax/alphamin)**(real(j,kp)/real(nalpha,kp))
     xEnd = rgi_x_endinf(alpha)
     lnRhoReh = lnRhoNuc
     xstarA = rgi_x_star(alpha,xend,w,lnRhoReh,Pstar,bfoldstar)
     eps1A = rgi_epsilon_one(xstarA,alpha)
     eps2A = rgi_epsilon_two(xstarA,alpha)
     eps3A = rgi_epsilon_three(xstarA,alpha)
     nsA = 1._kp - 2._kp*eps1A - eps2A
     rA = 16._kp*eps1A
     lnRhoReh = rgi_lnrhoreh_max(alpha,xend,Pstar)
     xstarB = rgi_x_star(alpha,xend,w,lnRhoReh,Pstar,bfoldstar)
     eps1B = rgi_epsilon_one(xstarB,alpha)
     eps2B = rgi_epsilon_two(xstarB,alpha)
     eps3B = rgi_epsilon_three(xstarB,alpha)
     nsB = 1._kp - 2._kp*eps1B - eps2B
     rB =16._kp*eps1B
     call livewrite('rgi_predic_summarized.dat',eps1A,eps2A,eps3A,rA,nsA,eps1B,eps2B,eps3B,rB,nsB)
  enddo


  write(*,*)
  write(*,*)'Testing Rrad/Rreh'

  lnRradmin=-42
  lnRradmax = 10
  alpha = 5e-4
  xEnd = rgi_x_endinf(alpha)
  do i=1,npts

     lnRrad = lnRradMin + (lnRradMax-lnRradMin)*real(i-1,kp)/real(npts-1,kp)

     xstar = rgi_x_rrad(alpha,xend,lnRrad,Pstar,bfoldstar)

     print *,'lnRrad=',lnRrad,' bfoldstar= ',bfoldstar, 'xstar', xstar

     eps1 = rgi_epsilon_one(xstar,alpha)

     !consistency test
     !get lnR from lnRrad and check that it gives the same xstar
     eps1end =  rgi_epsilon_one(xend,alpha)
     VendOverVstar = rgi_norm_potential(xend,alpha)/rgi_norm_potential(xstar,alpha)

     lnRhoEnd = ln_rho_endinf(Pstar,eps1,eps1End,VendOverVstar)

     lnR = get_lnrreh_rrad(lnRrad,lnRhoEnd)
     xstar = rgi_x_rreh(alpha,xend,lnR,bfoldstar)
     print *,'lnR',lnR, 'bfoldstar= ',bfoldstar, 'xstar', xstar

     !second consistency check
     !get rhoreh for chosen w and check that xstar gotten this way is the same
     w = 0._kp
     lnRhoReh = ln_rho_reheat(w,Pstar,eps1,eps1End,-bfoldstar,VendOverVstar)

     xstar = rgi_x_star(alpha,xend,w,lnRhoReh,Pstar,bfoldstar)
     print *,'lnR', get_lnrreh_rhow(lnRhoReh,w,lnRhoEnd),'lnRrad' &
          ,get_lnrrad_rhow(lnRhoReh,w,lnRhoEnd),'xstar',xstar

  enddo

end program rgimain
