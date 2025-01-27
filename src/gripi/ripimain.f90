!test the reheating derivation from slow-roll
program ripimain
  use infprec, only : kp
  use cosmopar, only : lnRhoNuc, powerAmpScalar
  use ripisr, only : ripi_epsilon_one, ripi_epsilon_two, ripi_epsilon_three
  use ripireheat, only : ripi_lnrhoreh_max, ripi_x_star
  use infinout, only : delete_file, livewrite
  use srreheat, only : log_energy_reheat_ingev

  use ripisr, only : ripi_norm_potential, ripi_x_endinf
  use ripireheat, only : ripi_x_rreh, ripi_x_rrad
  use srreheat, only : get_lnrrad_rreh, get_lnrreh_rrad, ln_rho_endinf
  use srreheat, only : get_lnrrad_rhow, get_lnrreh_rhow, ln_rho_reheat

  use infinout, only : aspicwrite_header, aspicwrite_data, aspicwrite_end
  use infinout, only : labeps12, labnsr, labbfoldreh
  
  implicit none


  real(kp) :: Pstar, logErehGeV, Treh

  integer :: i,j
  integer :: npts = 10
  integer :: nphi0

  real(kp) :: phi0,w,bfoldstar
  real(kp) :: lnRhoReh,xstar,eps1,eps2,eps3,ns,r

  real(kp) :: lnRhoRehMin, lnRhoRehMax
  real(kp), dimension(2) :: vecbuffer

  real(kp) ::phi0min,phi0max

  real(kp) :: eps1A,eps2A,eps3A,nsA,rA,eps1B,eps2B,eps3B,nsB,rB,xstarA,xstarB

  real(kp) :: lnRmin, lnRmax, lnR, lnRhoEnd
  real(kp) :: lnRradMin, lnRradMax, lnRrad
  real(kp) :: VendOverVstar, eps1End, xend

  nphi0 = 10

!  phi0min=4._kp/3._kp*10.**(-3.)
  phi0min=2._kp*10.**(-5.)
  phi0max=2._kp*10.**(-4.)

  Pstar = powerAmpScalar

  w=0._kp
  !w = 1._kp/3._kp

  call delete_file('ripi_predic.dat')
  call delete_file('ripi_nsr.dat')

  call aspicwrite_header('ripi',labeps12,labnsr,labbfoldreh,(/'phi0'/))
  
  do j=1,nphi0

     phi0=phi0min*(phi0max/phi0min)**(real(j,kp)/real(nphi0,kp))


     lnRhoRehMin = lnRhoNuc
     xEnd = ripi_x_endinf(phi0)
     lnRhoRehMax = ripi_lnrhoreh_max(phi0,xend,Pstar)

     print *,'phi0=',phi0,'lnRhoRehMin=',lnRhoRehMin, 'lnRhoRehMax= ',lnRhoRehMax

     do i=1,npts

        lnRhoReh = lnRhoRehMin + (lnRhoRehMax-lnRhoRehMin)*real(i-1,kp)/real(npts-1,kp)

        xstar = ripi_x_star(phi0,xend,w,lnRhoReh,Pstar,bfoldstar)

        eps1 = ripi_epsilon_one(xstar,phi0)
        eps2 = ripi_epsilon_two(xstar,phi0)
        eps3 = ripi_epsilon_three(xstar,phi0)

        print *,'lnRhoReh',lnRhoReh,' bfoldstar= ',bfoldstar,'xstar=',xstar, &
             'eps1star=',eps1,'eps2star=',eps2

        logErehGeV = log_energy_reheat_ingev(lnRhoReh)
        Treh = 10._kp**( logErehGeV -0.25_kp*log10(acos(-1._kp)**2/30._kp) )

        ns = 1._kp - 2._kp*eps1 - eps2
        r =16._kp*eps1

        call livewrite('ripi_true.dat',phi0,xEnd)

        call livewrite('ripi_nsr.dat',ns,r,abs(bfoldstar),lnRhoReh)

        call aspicwrite_data((/eps1,eps2/),(/ns,r/),(/abs(bfoldstar),lnRhoReh/),(/phi0/))

     end do

  end do

  call aspicwrite_end()

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  !! Write Data for the summarizing plots !!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  call delete_file('ripi_predic_summarized.dat') 
  nphi0=1000
  phi0min=4._kp/3._kp*10.**(-3.)
  phi0max=4._kp/3._kp*10.**(-3.)
  w=0._kp
  do j=1,nphi0
     phi0=phi0min*(phi0max/phi0min)**(real(j,kp)/real(nphi0,kp))
     xEnd = ripi_x_endinf(phi0)
     lnRhoReh = lnRhoNuc
     xstarA = ripi_x_star(phi0,xend,w,lnRhoReh,Pstar,bfoldstar)
     eps1A = ripi_epsilon_one(xstarA,phi0)
     eps2A = ripi_epsilon_two(xstarA,phi0)
     eps3A = ripi_epsilon_three(xstarA,phi0)
     nsA = 1._kp - 2._kp*eps1A - eps2A
     rA = 16._kp*eps1A
     lnRhoReh = ripi_lnrhoreh_max(phi0,xend,Pstar)
     xstarB = ripi_x_star(phi0,xend,w,lnRhoReh,Pstar,bfoldstar)
     eps1B = ripi_epsilon_one(xstarB,phi0)
     eps2B = ripi_epsilon_two(xstarB,phi0)
     eps3B = ripi_epsilon_three(xstarB,phi0)
     nsB = 1._kp - 2._kp*eps1B - eps2B
     rB =16._kp*eps1B
     call livewrite('ripi_predic_summarized.dat',eps1A,eps2A,eps3A,rA,nsA,eps1B,eps2B,eps3B,rB,nsB)
  enddo


  write(*,*)
  write(*,*)'Testing Rrad/Rreh'

  lnRradmin=-42
  lnRradmax = 10
  phi0 = 4._kp/3._kp*1e-2
  xEnd = ripi_x_endinf(phi0)
  do i=1,npts

     lnRrad = lnRradMin + (lnRradMax-lnRradMin)*real(i-1,kp)/real(npts-1,kp)

     xstar = ripi_x_rrad(phi0,xend,lnRrad,Pstar,bfoldstar)

     print *,'lnRrad=',lnRrad,' bfoldstar= ',bfoldstar, 'xstar', xstar

     eps1 = ripi_epsilon_one(xstar,phi0)

     !consistency test
     !get lnR from lnRrad and check that it gives the same xstar
     eps1end =  ripi_epsilon_one(xend,phi0)
     VendOverVstar = ripi_norm_potential(xend,phi0)/ripi_norm_potential(xstar,phi0)

     lnRhoEnd = ln_rho_endinf(Pstar,eps1,eps1End,VendOverVstar)

     lnR = get_lnrreh_rrad(lnRrad,lnRhoEnd)
     xstar = ripi_x_rreh(phi0,xend,lnR,bfoldstar)
     print *,'lnR',lnR, 'bfoldstar= ',bfoldstar, 'xstar', xstar

     !second consistency check
     !get rhoreh for chosen w and check that xstar gotten this way is the same
     w = 0._kp
     lnRhoReh = ln_rho_reheat(w,Pstar,eps1,eps1End,-bfoldstar,VendOverVstar)

     xstar = ripi_x_star(phi0,xend,w,lnRhoReh,Pstar,bfoldstar)
     print *,'lnR', get_lnrreh_rhow(lnRhoReh,w,lnRhoEnd),'lnRrad' &
          ,get_lnrrad_rhow(lnRhoReh,w,lnRhoEnd),'xstar',xstar

  enddo



end program ripimain
