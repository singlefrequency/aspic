!test the reheating derivation from slow-roll
program rchimain
  use infprec, only : kp, pi
  use cosmopar, only : lnRhoNuc, powerAmpScalar
  use rchisr, only : rchi_epsilon_one, rchi_epsilon_two, rchi_epsilon_three
  use rchireheat, only : rchi_lnrhoreh_max, rchi_x_star
  use infinout, only : delete_file, livewrite
  use srreheat, only : log_energy_reheat_ingev, potential_normalization
  
  use rchisr, only : rchi_norm_potential, rchi_x_endinf
  use rchireheat, only : rchi_x_rreh, rchi_x_rrad
  use srreheat, only : get_lnrrad_rreh, get_lnrreh_rrad, ln_rho_endinf
  use srreheat, only : get_lnrrad_rhow, get_lnrreh_rhow, ln_rho_reheat

  use infinout, only : aspicwrite_header, aspicwrite_data, aspicwrite_end
  use infinout, only : labeps12, labnsr, labbfoldreh
  
  
  implicit none


  real(kp) :: Pstar, logErehGeV, Treh, norm

  integer :: i,j
  integer :: npts = 10
  integer ::nAI

  real(kp) :: AI,w,bfoldstar
  real(kp) :: lnRhoReh,xstar,eps1,eps2,eps3,ns,r

  real(kp) :: lnRhoRehMin, lnRhoRehMax
  real(kp), dimension(2) :: vecbuffer
  real(kp) :: AImin,AImax

  real(kp) :: eps1A,eps2A,eps3A,nsA,rA,eps1B,eps2B,eps3B,nsB,rB,xstarA,xstarB

  real(kp) :: eps1approx, eps2approx, etapprox, nsapprox, rapprox, ystar
  
  real(kp) :: lnRmin, lnRmax, lnR, lnRhoEnd
  real(kp) :: lnRradMin, lnRradMax, lnRrad
  real(kp) :: VendOverVstar, eps1End, xend, Vend, Vstar

  nAI=10
  AImin=-10._kp
  AImax=100._kp

!  AImin=-0.5_kp
!  AImax=0.5_kp


  Pstar = powerAmpScalar

  !  w = 1._kp/3._kp
  w=0._kp

  call delete_file('rchi_predic.dat')
  call delete_file('rchi_nsr.dat')

  call aspicwrite_header('rchi',labeps12,labnsr,labbfoldreh,(/'AI'/))
 

  do j=0,nAI
!     AI=AImin*(AImax/AImin)**(real(j,kp)/real(nAI,kp)) !log step
     AI=AImin+(AImax-AImin)*(real(j,kp)/real(nAI,kp)) !arithmetic step

     lnRhoRehMin = lnRhoNuc
     xEnd = rchi_x_endinf(AI)
     lnRhoRehMax = rchi_lnrhoreh_max(AI,xend,Pstar)

     print *,'AI=',AI,'lnRhoRehMin=',lnRhoRehMin, 'lnRhoRehMax= ',lnRhoRehMax

     do i=1,npts

        lnRhoReh = lnRhoRehMin + (lnRhoRehMax-lnRhoRehMin)*real(i-1,kp)/real(npts-1,kp)

        xstar = rchi_x_star(AI,xend,w,lnRhoReh,Pstar,bfoldstar)

        print *,'lnRhoReh',lnRhoReh,' bfoldstar= ',bfoldstar,'xstar=',xstar

        eps1 = rchi_epsilon_one(xstar,AI)
        eps2 = rchi_epsilon_two(xstar,AI)
        eps3 = rchi_epsilon_three(xstar,AI)

        logErehGeV = log_energy_reheat_ingev(lnRhoReh)
        Treh = 10._kp**( logErehGeV -0.25_kp*log10(acos(-1._kp)**2/30._kp) )

        ns = 1._kp - 2._kp*eps1 - eps2
        r =16._kp*eps1

!        if ((abs(eps2).gt.0.2) .or. (eps1.lt.1e-6)) cycle
        
        Vstar = rchi_norm_potential(xstar,AI)
        Vend = rchi_norm_potential(xend,AI)
        norm = sqrt(potential_normalization(Pstar,eps1,Vstar)**4*Vend)
		
        call livewrite('rchi_true.dat',AI,xend,potential_normalization(Pstar,eps1,Vstar),norm)

        call livewrite('rchi_nsr.dat',ns,r,abs(bfoldstar),lnRhoReh)

        call aspicwrite_data((/eps1,eps2/),(/ns,r/),(/abs(bfoldstar),lnRhoReh/),(/AI/))
        
     end do

  end do

  call aspicwrite_end()


  call delete_file('rchi_nsr_exact.dat')
  call delete_file('rchi_nsr_approx.dat')

  npts = 7
  nAI = 25

  AImin = -10._kp
  AImax = 50._kp
  
  do j=0,nAI

     AI=AImin+(AImax-AImin)*(real(j,kp)/real(nAI,kp)) !arithmetic step

     lnRhoRehMin = lnRhoNuc
     xEnd = rchi_x_endinf(AI)
     lnRhoRehMax = rchi_lnrhoreh_max(AI,xend,Pstar)

     print *,'AI=',AI,'lnRhoRehMin=',lnRhoRehMin, 'lnRhoRehMax= ',lnRhoRehMax

     do i=1,npts

        lnRhoReh = lnRhoRehMin + (lnRhoRehMax-lnRhoRehMin)*real(i-1,kp)/real(npts-1,kp)

        xstar = rchi_x_star(AI,xend,w,lnRhoReh,Pstar,bfoldstar)
        ystar = sqrt(2._kp/3._kp)*xstar

        
        print *,'lnRhoReh',lnRhoReh,' bfoldstar= ',bfoldstar,'xstar=',xstar

        eps1 = rchi_epsilon_one(xstar,AI)
        eps2 = rchi_epsilon_two(xstar,AI)
        eps3 = rchi_epsilon_three(xstar,AI)

        logErehGeV = log_energy_reheat_ingev(lnRhoReh)
        Treh = 10._kp**( logErehGeV -0.25_kp*log10(acos(-1._kp)**2/30._kp) )

        ns = 1._kp - 2._kp*eps1 - eps2
        r =16._kp*eps1



        eps1approx= (4._kp/3._kp)*exp(-2._kp*ystar) &
             * (1._kp + AI/(64._kp*pi*pi)*exp(ystar))**2

        etapprox= -4._kp/3._kp * exp(-ystar)

        eps2approx=4._kp*eps1approx - 2._kp*etapprox

        nsapprox = 1._kp - 2._kp * eps1approx - eps2approx
        rapprox = 16._kp * eps1approx
        

        call livewrite('rchi_nsr_approx.dat',nsapprox,rapprox,AI,lnRhoReh)
        call livewrite('rchi_nsr_exact.dat',ns,r,AI,lnRhoReh)
                
        
     end do

  end do




  
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! Write Data for the summarizing plots !!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  call delete_file('rchi_predic_summarized.dat') 
  nAI=20
  AImin=-30._kp
  AImax=50._kp
  w=0._kp
  do j=0,nAI
     AI=AImin+(AImax-AImin)*(real(j,kp)/real(nAI,kp)) !arithmetic step
     xEnd = rchi_x_endinf(AI)
     lnRhoReh = lnRhoNuc
     xstarA = rchi_x_star(AI,xend,w,lnRhoReh,Pstar,bfoldstar)
     eps1A = rchi_epsilon_one(xstarA,AI)
     eps2A = rchi_epsilon_two(xstarA,AI)
     eps3A = rchi_epsilon_three(xstarA,AI)
     nsA = 1._kp - 2._kp*eps1A - eps2A
     rA = 16._kp*eps1A
     lnRhoReh = rchi_lnrhoreh_max(AI,xend,Pstar)
     xstarB = rchi_x_star(AI,xend,w,lnRhoReh,Pstar,bfoldstar)
     eps1B = rchi_epsilon_one(xstarB,AI)
     eps2B = rchi_epsilon_two(xstarB,AI)
     eps3B = rchi_epsilon_three(xstarB,AI)
     nsB = 1._kp - 2._kp*eps1B - eps2B
     rB =16._kp*eps1B
     call livewrite('rchi_predic_summarized.dat',eps1A,eps2A,eps3A,rA,nsA,eps1B,eps2B,eps3B,rB,nsB)
  enddo


  write(*,*)
  write(*,*)'Testing Rrad/Rreh'

  lnRradmin=-42
  lnRradmax = 10
  AI = 5

  xEnd = rchi_x_endinf(AI)
  
  do i=1,npts

     lnRrad = lnRradMin + (lnRradMax-lnRradMin)*real(i-1,kp)/real(npts-1,kp)

     xstar = rchi_x_rrad(AI,xend,lnRrad,Pstar,bfoldstar)

     print *,'lnRrad=',lnRrad,' bfoldstar= ',bfoldstar, 'xstar', xstar

     eps1 = rchi_epsilon_one(xstar,AI)

     !consistency test
     !get lnR from lnRrad and check that it gives the same xstar
     eps1end =  rchi_epsilon_one(xend,AI)
     VendOverVstar = rchi_norm_potential(xend,AI)/rchi_norm_potential(xstar,AI)

     lnRhoEnd = ln_rho_endinf(Pstar,eps1,eps1End,VendOverVstar)

     lnR = get_lnrreh_rrad(lnRrad,lnRhoEnd)
     xstar = rchi_x_rreh(AI,xend,lnR,bfoldstar)
     print *,'lnR',lnR, 'bfoldstar= ',bfoldstar, 'xstar', xstar

     !second consistency check
     !get rhoreh for chosen w and check that xstar gotten this way is the same
     w = 0._kp
     lnRhoReh = ln_rho_reheat(w,Pstar,eps1,eps1End,-bfoldstar,VendOverVstar)

     xstar = rchi_x_star(AI,xend,w,lnRhoReh,Pstar,bfoldstar)
     print *,'lnR', get_lnrreh_rhow(lnRhoReh,w,lnRhoEnd),'lnRrad' &
          ,get_lnrrad_rhow(lnRhoReh,w,lnRhoEnd),'xstar',xstar

  enddo


end program rchimain
