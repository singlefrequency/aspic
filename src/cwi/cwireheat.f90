!Colemann Weinberg inflation reheating functions in the slow-roll approximations

module cwireheat
  use infprec, only : kp, tolkp, transfert
  use inftools, only : zbrent
  use srreheat, only : get_calfconst, find_reheat, slowroll_validity
  use srreheat, only : display, pi, Nzero, ln_rho_endinf
  use srreheat, only : ln_rho_reheat
  use cwisr, only : cwi_epsilon_one, cwi_epsilon_two, cwi_epsilon_three
  use cwisr, only : cwi_norm_potential
  use cwisr, only : cwi_x_endinf, cwi_efold_primitive
  implicit none

  private

  public cwi_x_star, cwi_lnrhoend 

contains

!returns x such given potential parameters, scalar power, wreh and
!lnrhoreh. If present, returns the corresponding bfoldstar
  function cwi_x_star(alpha,Q,w,lnRhoReh,Pstar,bfoldstar)    
    implicit none
    real(kp) :: cwi_x_star
    real(kp), intent(in) :: alpha,Q,lnRhoReh,w,Pstar
    real(kp), intent(out), optional :: bfoldstar

    real(kp), parameter :: tolzbrent=tolkp
    real(kp) :: mini,maxi,calF,x
    real(kp) :: primEnd,epsOneEnd,xend,potEnd

    type(transfert) :: cwiData
    

    if (w.eq.1._kp/3._kp) then
       if (display) write(*,*)'w = 1/3 : solving for rhoReh = rhoEnd'
    endif
    
    xEnd = cwi_x_endinf(alpha,Q)

    epsOneEnd = cwi_epsilon_one(xEnd,alpha,Q)
    potEnd = cwi_norm_potential(xEnd,alpha,Q)

    primEnd = cwi_efold_primitive(xEnd,alpha,Q)
   
    calF = get_calfconst(lnRhoReh,Pstar,w,epsOneEnd,potEnd)

    cwiData%real1 = alpha
    cwiData%real2 = Q
    cwiData%real3 = w
    cwiData%real4 = calF + primEnd

    mini = epsilon(1._kp)
    maxi = cwi_x_endinf(alpha,Q)

    x = zbrent(find_cwi_x_star,mini,maxi,tolzbrent,cwiData)
    cwi_x_star = x

    if (present(bfoldstar)) then
       bfoldstar = - (cwi_efold_primitive(x,alpha,Q) - primEnd)
    endif

  end function cwi_x_star

  function find_cwi_x_star(x,cwiData)   
    implicit none
    real(kp) :: find_cwi_x_star
    real(kp), intent(in) :: x
    type(transfert), optional, intent(inout) :: cwiData

    real(kp) :: primStar,alpha,Q,w,CalFplusprimEnd,potStar,epsOneStar

    alpha=cwiData%real1
    Q=cwiData%real2
    w = cwiData%real3
    CalFplusprimEnd = cwiData%real4

    primStar = cwi_efold_primitive(x,alpha,Q)
    epsOneStar = cwi_epsilon_one(x,alpha,Q)
    potStar = cwi_norm_potential(x,alpha,Q)

    find_cwi_x_star = find_reheat(primStar,calFplusprimEnd,w,epsOneStar,potStar)
  
  end function find_cwi_x_star



  function cwi_lnrhoend(alpha,Q,Pstar) 
    implicit none
    real(kp) :: cwi_lnrhoend
    real(kp), intent(in) :: alpha,Q,Pstar

    real(kp) :: xEnd, potEnd, epsOneEnd
    real(kp) :: x, potStar, epsOneStar

    real(kp),parameter :: wrad=1_kp/3_kp
    real(kp),parameter :: junk=0_kp

    real(kp) :: lnRhoEnd
    
    xEnd = cwi_x_endinf(alpha,Q)


    potEnd  = cwi_norm_potential(xEnd,alpha,Q)

    epsOneEnd = cwi_epsilon_one(xEnd,alpha,Q)



!   Trick to return x such that rho_reh=rho_end

    x = cwi_x_star(alpha,Q,wrad,junk,Pstar)  

 
    potStar = cwi_norm_potential(x,alpha,Q)
    epsOneStar = cwi_epsilon_one(x,alpha,Q)

    
    if (.not.slowroll_validity(epsOneStar)) stop 'cwi_lnrhoend: slow-roll violated!'
    
    lnRhoEnd = ln_rho_endinf(Pstar,epsOneStar,epsOneEnd,potEnd/potStar)

    cwi_lnrhoend = lnRhoEnd

  end function cwi_lnrhoend

  
end module cwireheat