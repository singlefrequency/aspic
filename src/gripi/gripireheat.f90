!GRIP inflation reheating functions in the slow-roll approximations

module gripireheat
  use infprec, only : kp, tolkp, transfert
  use inftools, only : zbrent
  use srreheat, only : get_calfconst, find_reheat, slowroll_validity
  use srreheat, only : display, pi, Nzero, ln_rho_endinf
  use srreheat, only : ln_rho_reheat
  use gripisr, only : gripi_epsilon_one, gripi_epsilon_two, gripi_epsilon_three
  use gripisr, only : gripi_norm_potential, gripi_x_endinf, gripi_x_epsonemin
  use gripisr, only : gripi_efold_primitive
  implicit none

  private

  public gripi_x_star, gripi_lnrhoend 

contains

!returns x such given potential parameters, scalar power, wreh and
!lnrhoreh. If present, returns the corresponding bfoldstar
  function gripi_x_star(alpha,phi0,w,lnRhoReh,Pstar,bfoldstar)    
    implicit none
    real(kp) :: gripi_x_star
    real(kp), intent(in) :: alpha,phi0,lnRhoReh,w,Pstar
    real(kp), intent(out), optional :: bfoldstar

    real(kp), parameter :: tolzbrent=tolkp
    real(kp) :: mini,maxi,calF,x
    real(kp) :: primEnd,epsOneEnd,xend,potEnd

    type(transfert) :: gripiData
    

    if (w.eq.1._kp/3._kp) then
       if (display) write(*,*)'w = 1/3 : solving for rhoReh = rhoEnd'
    endif
    
    xEnd = gripi_x_endinf(alpha,phi0)
    epsOneEnd = gripi_epsilon_one(xEnd,alpha,phi0)
    potEnd = gripi_norm_potential(xEnd,alpha,phi0)
    primEnd = gripi_efold_primitive(xEnd,alpha,phi0)

    calF = get_calfconst(lnRhoReh,Pstar,w,epsOneEnd,potEnd)

    gripiData%real1 = alpha 
    gripiData%real2 = phi0 
    gripiData%real3 = xEnd
    gripiData%real4 = w
    gripiData%real5 = calF + primEnd

    mini = xend

    if (alpha .lt. 1._kp) then
	maxi = gripi_x_epsonemin(alpha)*(1._kp-100000._kp*epsilon(1._kp))
    else
	maxi = gripi_x_epsonemin(alpha)*(1._kp-100000._kp*epsilon(1._kp)) !local maximum of the potential
    endif

    x = zbrent(find_gripi_x_star,mini,maxi,tolzbrent,gripiData)
    gripi_x_star = x

    if (present(bfoldstar)) then
       bfoldstar = - (gripi_efold_primitive(x,alpha,phi0) - primEnd)
    endif


  end function gripi_x_star

  function find_gripi_x_star(x,gripiData)   
    implicit none
    real(kp) :: find_gripi_x_star
    real(kp), intent(in) :: x
    type(transfert), optional, intent(inout) :: gripiData

    real(kp) :: primStar,alpha,phi0,xEnd,w,CalFplusprimEnd,potStar,epsOneStar

    alpha=gripiData%real1
    phi0=gripiData%real2
    xEnd=gripiData%real3
    w = gripiData%real4
    CalFplusprimEnd = gripiData%real5

    primStar = gripi_efold_primitive(x,alpha,phi0)
    epsOneStar = gripi_epsilon_one(x,alpha,phi0)
    potStar = gripi_norm_potential(x,alpha,phi0)

    find_gripi_x_star = find_reheat(primStar,calFplusprimEnd,w,epsOneStar,potStar)

  
  end function find_gripi_x_star



  function gripi_lnrhoend(alpha,phi0,Pstar) 
    implicit none
    real(kp) :: gripi_lnrhoend
    real(kp), intent(in) :: alpha,phi0,Pstar

    real(kp) :: xEnd, potEnd, epsOneEnd
    real(kp) :: x, potStar, epsOneStar

    real(kp),parameter :: wrad=1_kp/3_kp
    real(kp),parameter :: junk=0_kp

    real(kp) :: lnRhoEnd
    
    xEnd = gripi_x_endinf(alpha,phi0)
    potEnd  = gripi_norm_potential(xEnd,alpha,phi0)
    epsOneEnd = gripi_epsilon_one(xEnd,alpha,phi0)

!   Trick to return x such that rho_reh=rho_end

    x = gripi_x_star(alpha,phi0,wrad,junk,Pstar)    
    potStar = gripi_norm_potential(x,alpha,phi0)
    epsOneStar = gripi_epsilon_one(x,alpha,phi0)

    
!    if (.not.slowroll_validity(epsOneStar)) stop 'gripi_lnrhoend: slow-roll violated!'
    
    lnRhoEnd = ln_rho_endinf(Pstar,epsOneStar,epsOneEnd,potEnd/potStar)

    gripi_lnrhoend = lnRhoEnd

  end function gripi_lnrhoend

  
end module gripireheat
