!test the reheating derivation from slow-roll
program cnbimain
  use infprec, only : kp
  use cosmopar, only : lnRhoNuc, powerAmpScalar
  use cnbisr, only : cnbi_epsilon_one, cnbi_epsilon_two, cnbi_epsilon_three
  use cnbireheat, only : cnbi_lnrhoreh_max, cnbi_x_star
  use infinout, only : delete_file, livewrite
  use srreheat, only : log_energy_reheat_ingev

  
  use cnbisr, only : cnbi_norm_potential, cnbi_x_endinf,cnbi_epsilon_one_min
  use cnbisr, only :  cnbi_x_epsoneunity, cnbi_efold_primitive
  use cnbireheat, only : cnbi_x_rreh, cnbi_x_rrad
  use srreheat, only : get_lnrrad_rreh, get_lnrreh_rrad, ln_rho_endinf
  use srreheat, only : get_lnrrad_rhow, get_lnrreh_rhow, ln_rho_reheat
  use srflow, only : slowroll_violated

  use infinout, only : aspicwrite_header, aspicwrite_data, aspicwrite_end
  use infinout, only : labeps12, labnsr, labbfoldreh
  
  implicit none


  real(kp) :: Pstar, logErehGeV, Treh

  integer :: i,j
  integer :: npts = 10
  integer :: nalpha

  real(kp) :: alpha,w,bfoldstar
  real(kp) :: lnRhoReh,xstar,eps1,eps2,eps3,ns,r

  real(kp) :: lnRhoRehMin, lnRhoRehMax
  real(kp), dimension(2) :: vecbuffer

  real(kp) ::alphamin,alphamax

  real(kp) :: eps1A,eps2A,eps3A,nsA,rA,eps1B,eps2B,eps3B,nsB,rB,xstarA,xstarB

  real(kp) :: lnRmin, lnRmax, lnR, lnRhoEnd
  real(kp) :: lnRradMin, lnRradMax, lnRrad
  real(kp) :: VendOverVstar, eps1End, xend, efoldMax

  real(kp), dimension(2) :: xEps1

  nalpha = 10

  alphamin=10.**(-4)
  alphamax=0.2975_kp*0.9

  Pstar = powerAmpScalar

  !w = 1._kp/3._kp
  w=0._kp



  call delete_file('cnbi_predic.dat')
  call delete_file('cnbi_nsr.dat')

  call aspicwrite_header('cnbi',labeps12,labnsr,labbfoldreh,(/'alpha'/))
  
  do j=1,nalpha
     alpha=alphamin*(alphamax/alphamin)**(real(j-1,kp)/real(nalpha-1,kp))

     lnRhoRehMin = lnRhoNuc
     print *,'alpha====',alpha, cnbi_epsilon_one_min(alpha)

     
     xEnd = cnbi_x_endinf(alpha)
        
     xEps1 = cnbi_x_epsoneunity(alpha)
     efoldMax = -cnbi_efold_primitive(xEnd,alpha) &
          + cnbi_efold_primitive(xeps1(2),alpha)
    
     if (efoldMax.lt.60._kp) then
         print *,'too small efoldMax=',efoldMax
        cycle
     end if
     lnRhoRehMax = cnbi_lnrhoreh_max(alpha,xend,Pstar)

     print *,'alpha=',alpha,'lnRhoRehMin=',lnRhoRehMin, 'lnRhoRehMax= ',lnRhoRehMax

     do i=1,npts

        lnRhoReh = lnRhoRehMin + (lnRhoRehMax-lnRhoRehMin)*real(i-1,kp)/real(npts-1,kp)
        

        xstar = cnbi_x_star(alpha,xend,w,lnRhoReh,Pstar,bfoldstar)

        eps1 = cnbi_epsilon_one(xstar,alpha)
        eps2 = cnbi_epsilon_two(xstar,alpha)
        eps3 = cnbi_epsilon_three(xstar,alpha)


        print *,'lnRhoReh',lnRhoReh,' bfoldstar= ',bfoldstar,'xstar=',xstar, &
             'eps1star=',eps1,'eps2star=',eps2

        logErehGeV = log_energy_reheat_ingev(lnRhoReh)
        Treh = 10._kp**( logErehGeV -0.25_kp*log10(acos(-1._kp)**2/30._kp) )

        ns = 1._kp - 2._kp*eps1 - eps2
        r =16._kp*eps1

        call livewrite('cnbi_true.dat',alpha,xEnd)

        call livewrite('cnbi_nsr.dat',ns,r,abs(bfoldstar),lnRhoReh)

        call aspicwrite_data((/eps1,eps2/),(/ns,r/),(/abs(bfoldstar),lnRhoReh/),(/alpha/))
        
     end do

  end do


  call aspicwrite_end()
  
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  !! Write Data for the summarizing plots !!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  call delete_file('cnbi_predic_summarized.dat') 
  nalpha=1000
  alphamin=10.**(-5)
  alphamax=0.2975_kp*0.1_kp
  w=0._kp
  do j=1,nalpha
     alpha=alphamin*(alphamax/alphamin)**(real(j,kp)/real(nalpha,kp))
     lnRhoReh = lnRhoNuc
     xEnd = cnbi_x_endinf(alpha)
     xstarA = cnbi_x_star(alpha,xend,w,lnRhoReh,Pstar,bfoldstar)
     eps1A = cnbi_epsilon_one(xstarA,alpha)
     eps2A = cnbi_epsilon_two(xstarA,alpha)
     eps3A = cnbi_epsilon_three(xstarA,alpha)

     nsA = 1._kp - 2._kp*eps1A - eps2A
     rA = 16._kp*eps1A
     lnRhoReh = cnbi_lnrhoreh_max(alpha,xend,Pstar)
     xstarB = cnbi_x_star(alpha,xend,w,lnRhoReh,Pstar,bfoldstar)
     eps1B = cnbi_epsilon_one(xstarB,alpha)
     eps2B = cnbi_epsilon_two(xstarB,alpha)
     eps3B = cnbi_epsilon_three(xstarB,alpha)

     nsB = 1._kp - 2._kp*eps1B - eps2B
     rB =16._kp*eps1B
     call livewrite('cnbi_predic_summarized.dat',eps1A,eps2A,eps3A,rA,nsA,eps1B,eps2B,eps3B,rB,nsB)
  enddo

  write(*,*)
  write(*,*)'Testing Rrad/Rreh'

  lnRradmin=-42
  lnRradmax = 10
  alpha = 1e-2
  xEnd = cnbi_x_endinf(alpha)
  do i=1,npts

     lnRrad = lnRradMin + (lnRradMax-lnRradMin)*real(i-1,kp)/real(npts-1,kp)

     xstar = cnbi_x_rrad(alpha,xend,lnRrad,Pstar,bfoldstar)

     print *,'lnRrad=',lnRrad,' bfoldstar= ',bfoldstar, 'xstar', xstar

     eps1 = cnbi_epsilon_one(xstar,alpha)

     !consistency test
     !get lnR from lnRrad and check that it gives the same xstar
     eps1end =  cnbi_epsilon_one(xend,alpha)
     VendOverVstar = cnbi_norm_potential(xend,alpha)/cnbi_norm_potential(xstar,alpha)

     lnRhoEnd = ln_rho_endinf(Pstar,eps1,eps1End,VendOverVstar)

     lnR = get_lnrreh_rrad(lnRrad,lnRhoEnd)
     xstar = cnbi_x_rreh(alpha,xend,lnR,bfoldstar)
     print *,'lnR',lnR, 'bfoldstar= ',bfoldstar, 'xstar', xstar

     !second consistency check
     !get rhoreh for chosen w and check that xstar gotten this way is the same
     w = 0._kp
     lnRhoReh = ln_rho_reheat(w,Pstar,eps1,eps1End,-bfoldstar,VendOverVstar)

     xstar = cnbi_x_star(alpha,xend,w,lnRhoReh,Pstar,bfoldstar)
     print *,'lnR', get_lnrreh_rhow(lnRhoReh,w,lnRhoEnd),'lnRrad' &
          ,get_lnrrad_rhow(lnRhoReh,w,lnRhoEnd),'xstar',xstar

  enddo

end program
