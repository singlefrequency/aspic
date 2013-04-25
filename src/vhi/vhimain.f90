!test the reheating derivation from slow-roll
program vhimain
  use infprec, only : kp
  use cosmopar, only : lnRhoNuc, powerAmpScalar
  use vhisr, only : vhi_epsilon_one, vhi_epsilon_two, vhi_epsilon_three
  use vhisr, only : vhi_xinimax,vhi_xendmin,vhi_xendmax
  use vhireheat, only : vhi_lnrhoreh_max, vhi_x_star
  use infinout, only : delete_file, livewrite
  use srreheat, only : log_energy_reheat_ingev

  implicit none

  
  real(kp) :: Pstar, logErehGeV, Treh

  integer :: i,j,k
  integer :: npts = 20

  integer :: Nmu
  real(kp) :: mumin
  real(kp) :: mumax

  integer :: NxEnd
  real(kp) :: xEndmin
  real(kp) :: xEndmax

  real(kp) :: p,mu,xEnd,w,bfoldstar
  real(kp) :: lnRhoReh,xstar,eps1,eps2,eps3,ns,r

  real(kp) :: lnRhoRehMin, lnRhoRehMax
  real(kp), dimension(2) :: vecbuffer



  Pstar = powerAmpScalar

  call delete_file('vhi_predic.dat')
  call delete_file('vhi_nsr.dat')


!  w = 1._kp/3._kp
  w=0._kp




!!!!!!!!!!!!!!!!!!!!!
!!!!    p=0.5    !!!!
!!!!!!!!!!!!!!!!!!!!!

p=0.5_kp
Nmu=10
mumin=0.001_kp
mumax=1000000._kp
NxEnd=50

 do j=0,Nmu
 mu=mumin*(mumax/mumin)**(real(j,kp)/Nmu)
 xEndmin=vhi_xendmin(p,mu)*(1._kp+epsilon(1._kp))
 xEndmax=vhi_xinimax(p,mu)*0.99

 do k=0,NxEnd
 xEnd=xEndmin*(xEndmax/xEndmin)**(real(k,kp)/NxEnd) !logarithmic step
! xEnd=xEndmin+(xEndmax-xEndmin)*(real(k,kp)/NxEnd)*p,mu*(1.+epsilon(1._kp)) !arithmetic step


  lnRhoRehMin = lnRhoNuc
  lnRhoRehMax = vhi_lnrhoreh_max(p,mu,xEnd,Pstar)

  print *,'p',p,'mu=',mu,'xEnd=',xEnd,'lnRhoRehMin=',lnRhoRehMin, 'lnRhoRehMax= ',lnRhoRehMax

  do i=1,npts

       lnRhoReh = lnRhoRehMin + (lnRhoRehMax-lnRhoRehMin)*real(i-1,kp)/real(npts-1,kp)

	xstar = vhi_x_star(p,mu,xEnd,w,lnRhoReh,Pstar,bfoldstar)

       print *,'lnRhoReh',lnRhoReh,' bfoldstar= ',bfoldstar,'xstar=',xstar,'eps1star=',vhi_epsilon_one(xstar,p,mu)

 

       eps1 = vhi_epsilon_one(xstar,p,mu)
       eps2 = vhi_epsilon_two(xstar,p,mu)
       eps3 = vhi_epsilon_three(xstar,p,mu)


       logErehGeV = log_energy_reheat_ingev(lnRhoReh)


       Treh = 10._kp**( logErehGeV -0.25_kp*log10(acos(-1._kp)**2/30._kp) )


       ns = 1._kp - 2._kp*eps1 - eps2
       r =16._kp*eps1

       call livewrite('vhi_predic.dat',p,mu,xEnd,eps1,eps2,eps3,r,ns,Treh)

       call livewrite('vhi_nsr.dat',ns,r,abs(bfoldstar),lnRhoReh)
  
    end do

 end do

end do

!!!!!!!!!!!!!!!!!!!!!
!!!!     p=1     !!!!
!!!!!!!!!!!!!!!!!!!!!


p=1._kp
Nmu=10
mumin=0.001_kp
mumax=1000._kp
NxEnd=20

 do j=0,Nmu
 mu=mumin*(mumax/mumin)**(real(j,kp)/Nmu)
 xEndmin=vhi_xendmin(p,mu)*(1._kp+epsilon(1._kp))
 xEndmax=vhi_xinimax(p,mu)*0.99

 do k=0,NxEnd
 xEnd=xEndmin*(xEndmax/xEndmin)**(real(k,kp)/NxEnd) !logarithmic step
! xEnd=xEndmin+(xEndmax-xEndmin)*(real(k,kp)/NxEnd)*p,mu*(1.+epsilon(1._kp)) !arithmetic step


  lnRhoRehMin = lnRhoNuc
  lnRhoRehMax = vhi_lnrhoreh_max(p,mu,xEnd,Pstar)

  print *,'p',p,'mu=',mu,'xEnd=',xEnd,'lnRhoRehMin=',lnRhoRehMin, 'lnRhoRehMax= ',lnRhoRehMax

  do i=1,npts

       lnRhoReh = lnRhoRehMin + (lnRhoRehMax-lnRhoRehMin)*real(i-1,kp)/real(npts-1,kp)

	xstar = vhi_x_star(p,mu,xEnd,w,lnRhoReh,Pstar,bfoldstar)

       print *,'lnRhoReh',lnRhoReh,' bfoldstar= ',bfoldstar,'xstar=',xstar,'eps1star=',vhi_epsilon_one(xstar,p,mu)

 

       eps1 = vhi_epsilon_one(xstar,p,mu)
       eps2 = vhi_epsilon_two(xstar,p,mu)
       eps3 = vhi_epsilon_three(xstar,p,mu)


       logErehGeV = log_energy_reheat_ingev(lnRhoReh)


       Treh = 10._kp**( logErehGeV -0.25_kp*log10(acos(-1._kp)**2/30._kp) )


       ns = 1._kp - 2._kp*eps1 - eps2
       r =16._kp*eps1

       call livewrite('vhi_predic.dat',p,mu,xEnd,eps1,eps2,eps3,r,ns,Treh)

       call livewrite('vhi_nsr.dat',ns,r,abs(bfoldstar),lnRhoReh)
  
    end do

 end do

end do


!!!!!!!!!!!!!!!!!!!!!
!!!!    p=1.5    !!!!
!!!!!!!!!!!!!!!!!!!!!

p=1.5_kp
Nmu=20
mumin=0.8_kp
mumax=1000._kp
NxEnd=50

 do j=0,Nmu
 mu=mumin*(mumax/mumin)**(real(j,kp)/Nmu)
 xEndmin=vhi_xendmin(p,mu)*(1._kp+epsilon(1._kp))
 xEndmax=vhi_xinimax(p,mu)*0.99
 xEndmax=min(vhi_xendmax(50._kp,p,mu),10._kp) !To remain vacum dominated

 do k=0,NxEnd
 xEnd=xEndmin*(xEndmax/xEndmin)**(real(k,kp)/NxEnd) !logarithmic step
! xEnd=xEndmin+(xEndmax-xEndmin)*(real(k,kp)/NxEnd)*p,mu*(1.+epsilon(1._kp)) !arithmetic step


  lnRhoRehMin = lnRhoNuc
  lnRhoRehMax = vhi_lnrhoreh_max(p,mu,xEnd,Pstar)

  print *,'p,mu=',p,mu,'xEnd=',xEnd,'lnRhoRehMin=',lnRhoRehMin, 'lnRhoRehMax= ',lnRhoRehMax

  do i=1,npts

       lnRhoReh = lnRhoRehMin + (lnRhoRehMax-lnRhoRehMin)*real(i-1,kp)/real(npts-1,kp)

	xstar = vhi_x_star(p,mu,xEnd,w,lnRhoReh,Pstar,bfoldstar)

       print *,'lnRhoReh',lnRhoReh,' bfoldstar= ',bfoldstar,'xstar=',xstar,'eps1star=',vhi_epsilon_one(xstar,p,mu)

 

       eps1 = vhi_epsilon_one(xstar,p,mu)
       eps2 = vhi_epsilon_two(xstar,p,mu)
       eps3 = vhi_epsilon_three(xstar,p,mu)

       logErehGeV = log_energy_reheat_ingev(lnRhoReh)


       Treh = 10._kp**( logErehGeV -0.25_kp*log10(acos(-1._kp)**2/30._kp) )


       ns = 1._kp - 2._kp*eps1 - eps2
       r =16._kp*eps1

       call livewrite('vhi_predic.dat',p,mu,xEnd,eps1,eps2,eps3,r,ns,Treh)

       call livewrite('vhi_nsr.dat',ns,r,abs(bfoldstar),lnRhoReh)
  
    end do

 end do

end do


!!!!!!!!!!!!!!!!!!!!!
!!!!     p=2     !!!!
!!!!!!!!!!!!!!!!!!!!!

p=2._kp
Nmu=20
mumin=0.8_kp
mumax=1000._kp
NxEnd=100

 do j=0,Nmu
 mu=mumin*(mumax/mumin)**(real(j,kp)/Nmu)
 xEndmin=vhi_xendmin(p,mu)*(1._kp+epsilon(1._kp))
 xEndmax=vhi_xinimax(p,mu)*0.99
 xEndmax=min(vhi_xendmax(50._kp,p,mu),10._kp) !To remain vacum dominated

 do k=0,NxEnd
 xEnd=xEndmin*(xEndmax/xEndmin)**(real(k,kp)/NxEnd) !logarithmic step
! xEnd=xEndmin+(xEndmax-xEndmin)*(real(k,kp)/NxEnd)*p,mu*(1.+epsilon(1._kp)) !arithmetic step


  lnRhoRehMin = lnRhoNuc
  lnRhoRehMax = vhi_lnrhoreh_max(p,mu,xEnd,Pstar)

  print *,'p,mu=',p,mu,'xEnd=',xEnd,'lnRhoRehMin=',lnRhoRehMin, 'lnRhoRehMax= ',lnRhoRehMax

  do i=1,npts

       lnRhoReh = lnRhoRehMin + (lnRhoRehMax-lnRhoRehMin)*real(i-1,kp)/real(npts-1,kp)

	xstar = vhi_x_star(p,mu,xEnd,w,lnRhoReh,Pstar,bfoldstar)

       print *,'lnRhoReh',lnRhoReh,' bfoldstar= ',bfoldstar,'xstar=',xstar,'eps1star=',vhi_epsilon_one(xstar,p,mu)

 

       eps1 = vhi_epsilon_one(xstar,p,mu)
       eps2 = vhi_epsilon_two(xstar,p,mu)
       eps3 = vhi_epsilon_three(xstar,p,mu)


       logErehGeV = log_energy_reheat_ingev(lnRhoReh)


       Treh = 10._kp**( logErehGeV -0.25_kp*log10(acos(-1._kp)**2/30._kp) )


       ns = 1._kp - 2._kp*eps1 - eps2
       r =16._kp*eps1

       call livewrite('vhi_predic.dat',p,mu,xEnd,eps1,eps2,eps3,r,ns,Treh)

       call livewrite('vhi_nsr.dat',ns,r,abs(bfoldstar),lnRhoReh)
  
    end do

 end do

end do


!!!!!!!!!!!!!!!!!!!!!
!!!!     p=3     !!!!
!!!!!!!!!!!!!!!!!!!!!

p=3._kp
Nmu=20
mumin=0.8_kp
mumax=1000._kp
NxEnd=200

 do j=0,Nmu
 mu=mumin*(mumax/mumin)**(real(j,kp)/Nmu)
 xEndmin=vhi_xendmin(p,mu)*(1._kp+epsilon(1._kp))
 xEndmax=vhi_xinimax(p,mu)*0.99
 xEndmax=min(vhi_xendmax(50._kp,p,mu),10._kp) !To remain vacum dominated

 do k=0,NxEnd
 xEnd=xEndmin*(xEndmax/xEndmin)**(real(k,kp)/NxEnd) !logarithmic step
! xEnd=xEndmin+(xEndmax-xEndmin)*(real(k,kp)/NxEnd)*p,mu*(1.+epsilon(1._kp)) !arithmetic step


  lnRhoRehMin = lnRhoNuc
  lnRhoRehMax = vhi_lnrhoreh_max(p,mu,xEnd,Pstar)

  print *,'p,mu=',p,mu,'xEnd=',xEnd,'lnRhoRehMin=',lnRhoRehMin, 'lnRhoRehMax= ',lnRhoRehMax

  do i=1,npts

       lnRhoReh = lnRhoRehMin + (lnRhoRehMax-lnRhoRehMin)*real(i-1,kp)/real(npts-1,kp)

	xstar = vhi_x_star(p,mu,xEnd,w,lnRhoReh,Pstar,bfoldstar)

       print *,'lnRhoReh',lnRhoReh,' bfoldstar= ',bfoldstar,'xstar=',xstar,'eps1star=',vhi_epsilon_one(xstar,p,mu)

 

       eps1 = vhi_epsilon_one(xstar,p,mu)
       eps2 = vhi_epsilon_two(xstar,p,mu)
       eps3 = vhi_epsilon_three(xstar,p,mu)


       logErehGeV = log_energy_reheat_ingev(lnRhoReh)


       Treh = 10._kp**( logErehGeV -0.25_kp*log10(acos(-1._kp)**2/30._kp) )


       ns = 1._kp - 2._kp*eps1 - eps2
       r =16._kp*eps1

       call livewrite('vhi_predic.dat',p,mu,xEnd,eps1,eps2,eps3,r,ns,Treh)

       call livewrite('vhi_nsr.dat',ns,r,abs(bfoldstar),lnRhoReh)
  
    end do

 end do

end do

!!!!!!!!!!!!!!!!!!!!!
!!!!     p=3     !!!!
!!!!!!!!!!!!!!!!!!!!!

p=3._kp
Nmu=20
mumin=0.8_kp
mumax=1000._kp
NxEnd=200

 do j=0,Nmu
 mu=mumin*(mumax/mumin)**(real(j,kp)/Nmu)
 xEndmin=vhi_xendmin(p,mu)*(1._kp+epsilon(1._kp))
 xEndmax=vhi_xinimax(p,mu)*0.99
 xEndmax=min(vhi_xendmax(50._kp,p,mu),10._kp) !To remain vacum dominated

 do k=0,NxEnd
 xEnd=xEndmin*(xEndmax/xEndmin)**(real(k,kp)/NxEnd) !logarithmic step
! xEnd=xEndmin+(xEndmax-xEndmin)*(real(k,kp)/NxEnd)*p,mu*(1.+epsilon(1._kp)) !arithmetic step


  lnRhoRehMin = lnRhoNuc
  lnRhoRehMax = vhi_lnrhoreh_max(p,mu,xEnd,Pstar)

  print *,'p,mu=',p,mu,'xEnd=',xEnd,'lnRhoRehMin=',lnRhoRehMin, 'lnRhoRehMax= ',lnRhoRehMax

  do i=1,npts

       lnRhoReh = lnRhoRehMin + (lnRhoRehMax-lnRhoRehMin)*real(i-1,kp)/real(npts-1,kp)

	xstar = vhi_x_star(p,mu,xEnd,w,lnRhoReh,Pstar,bfoldstar)

       print *,'lnRhoReh',lnRhoReh,' bfoldstar= ',bfoldstar,'xstar=',xstar,'eps1star=',vhi_epsilon_one(xstar,p,mu)

 

       eps1 = vhi_epsilon_one(xstar,p,mu)
       eps2 = vhi_epsilon_two(xstar,p,mu)
       eps3 = vhi_epsilon_three(xstar,p,mu)


       logErehGeV = log_energy_reheat_ingev(lnRhoReh)


       Treh = 10._kp**( logErehGeV -0.25_kp*log10(acos(-1._kp)**2/30._kp) )


       ns = 1._kp - 2._kp*eps1 - eps2
       r =16._kp*eps1

       call livewrite('vhi_predic.dat',p,mu,xEnd,eps1,eps2,eps3,r,ns,Treh)

       call livewrite('vhi_nsr.dat',ns,r,abs(bfoldstar),lnRhoReh)
  
    end do

 end do

end do



end program vhimain
