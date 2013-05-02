!test the reheating derivation from slow-roll
program aimain
  use infprec, only : kp
  use cosmopar, only : lnRhoNuc, powerAmpScalar
  use aisr, only : ai_epsilon_one, ai_epsilon_two, ai_epsilon_three,ai_x_endinf
  use aireheat, only : ai_lnrhoreh_max, ai_x_star
  use infinout, only : delete_file, livewrite
  use srreheat, only : log_energy_reheat_ingev

  use aisr, only : ai_norm_potential, ai_x_endinf
  use aireheat, only : ai_x_rreh, ai_x_rrad
  use srreheat, only : get_lnrrad_rreh, get_lnrreh_rrad, ln_rho_endinf
  use srreheat, only : get_lnrrad_rhow, get_lnrreh_rhow, ln_rho_reheat

  implicit none


  real(kp) :: Pstar, logErehGeV, Treh, mu, mumin, mumax

  integer :: i,j
  integer :: npts = 20, nj=20

  real(kp) :: w,bfoldstar
  real(kp) :: lnRhoReh,xstar,eps1,eps2,eps3,ns,r

  real(kp) :: lnRhoRehMin, lnRhoRehMax

  real(kp), dimension(2) :: vecbuffer

  real(kp) :: eps1A,eps2A,eps3A,nsA,rA,eps1B,eps2B,eps3B,nsB,rB,xstarA,xstarB
  integer :: nmu

  real(kp) :: lnRmin, lnRmax, lnR, lnRhoEnd
  real(kp) :: lnRradMin, lnRradMax, lnRrad
  real(kp) :: VendOverVstar, eps1End, xend

  Pstar = powerAmpScalar

  call delete_file('ai_predic.dat')
  call delete_file('ai_nsr.dat')


  !  w = -1._kp/3._kp
  !  w = 1._kp
  w=0._kp

  mumin=(10._kp)**(-3)
  mumax=0.512378_kp*0.99_kp

  do j=0,nj
     mu=mumin*(mumax/mumin)**(real(j,kp)/real(nj,kp))


     lnRhoRehMin = lnRhoNuc
     lnRhoRehMax = ai_lnrhoreh_max(mu,Pstar)

     print *,'lnRhoRehMin=',lnRhoRehMin, 'lnRhoRehMax= ',lnRhoRehMax

     print*,'mu=',mu,'xEnd=',ai_x_endinf(mu)

     do i=1,npts

        lnRhoReh = lnRhoRehMin + (lnRhoRehMax-lnRhoRehMin)*real(i-1,kp)/real(npts-1,kp)

	xstar = ai_x_star(mu,w,lnRhoReh,Pstar,bfoldstar)

        print *,'lnRhoReh',lnRhoReh,' bfoldstar= ',bfoldstar,'xstar=',xstar,'eps1star=',ai_epsilon_one(xstar,mu)


        eps1 = ai_epsilon_one(xstar,mu)
        eps2 = ai_epsilon_two(xstar,mu)
        eps3 = ai_epsilon_three(xstar,mu)


        logErehGeV = log_energy_reheat_ingev(lnRhoReh)


        Treh = 10._kp**( logErehGeV -0.25_kp*log10(acos(-1._kp)**2/30._kp) )

        ns = 1._kp - 2._kp*eps1 - eps2
        r =16._kp*eps1

        call livewrite('ai_predic.dat',mu,eps1,eps2,eps3,r,ns,Treh)

        call livewrite('ai_nsr.dat',mu,ns,r,abs(bfoldstar),lnRhoReh)

     end do

  end do

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! Write Data for the summarizing plots !!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  call delete_file('ai_predic_summarized.dat') 
  nmu=1000
  mumin=(10._kp)**(-3)
  mumax=0.512378_kp*0.99_kp
  w=0._kp
  do j=1,nmu
     mu=mumin*(mumax/mumin)**(real(j,kp)/real(nmu,kp))
     lnRhoReh = lnRhoNuc
     xstarA = ai_x_star(mu,w,lnRhoReh,Pstar,bfoldstar)
     eps1A = ai_epsilon_one(xstarA,mu)
     eps2A = ai_epsilon_two(xstarA,mu)
     eps3A = ai_epsilon_three(xstarA,mu)
     nsA = 1._kp - 2._kp*eps1A - eps2A
     rA = 16._kp*eps1A
     lnRhoReh = ai_lnrhoreh_max(mu,Pstar)
     xstarB = ai_x_star(mu,w,lnRhoReh,Pstar,bfoldstar)
     eps1B = ai_epsilon_one(xstarB,mu)
     eps2B = ai_epsilon_two(xstarB,mu)
     eps3B = ai_epsilon_three(xstarB,mu)
     nsB = 1._kp - 2._kp*eps1B - eps2B
     rB =16._kp*eps1B
     call livewrite('ai_predic_summarized.dat',eps1A,eps2A,eps3A,rA,nsA,eps1B,eps2B,eps3B,rB,nsB)
  enddo

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!          Testing Rrad/Rreh           !!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  write(*,*)
  write(*,*)'Testing Rrad/Rreh'

  lnRradmin=-42
  lnRradmax = 10
  mu = 1e-2
  do i=1,npts

     lnRrad = lnRradMin + (lnRradMax-lnRradMin)*real(i-1,kp)/real(npts-1,kp)

     xstar = ai_x_rrad(mu,lnRrad,Pstar,bfoldstar)

     print *,'lnRrad=',lnRrad,' bfoldstar= ',bfoldstar, 'xstar', xstar

     eps1 = ai_epsilon_one(xstar,mu)

     !consistency test
     !get lnR from lnRrad and check that it gives the same xstar
     xend = ai_x_endinf(mu)
     eps1end =  ai_epsilon_one(xend,mu)
     VendOverVstar = ai_norm_potential(xend,mu)/ai_norm_potential(xstar,mu)

     lnRhoEnd = ln_rho_endinf(Pstar,eps1,eps1End,VendOverVstar)

     lnR = get_lnrreh_rrad(lnRrad,lnRhoEnd)
     xstar = ai_x_rreh(mu,lnR,bfoldstar)
     print *,'lnR',lnR, 'bfoldstar= ',bfoldstar, 'xstar', xstar

     !second consistency check
     !get rhoreh for chosen w and check that xstar gotten this way is the same
     w = 0._kp
     lnRhoReh = ln_rho_reheat(w,Pstar,eps1,eps1End,-bfoldstar,VendOverVstar)

     xstar = ai_x_star(mu,w,lnRhoReh,Pstar,bfoldstar)
     print *,'lnR', get_lnrreh_rhow(lnRhoReh,w,lnRhoEnd),'lnRrad' &
          ,get_lnrrad_rhow(lnRhoReh,w,lnRhoEnd),'xstar',xstar

  enddo


end program aimain

