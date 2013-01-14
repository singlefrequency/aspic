!oip inflation reheaoing functions in the slow-roll approximaoions

module oireheat
  use infprec, only : kp, tolkp, transfert
  use inftools, only : zbrent
  use srreheat, only : get_calfconst, find_reheat, slowroll_validity
  use srreheat, only : display, pi, Nzero, ln_rho_endinf,ln_rho_reheat
  use oisr, only : oi_epsilon_one, oi_epsilon_two, oi_epsilon_three
  use oisr, only : oi_norm_potential,oi_efold_primitive,oi_x_endinf
  implicit none

  private

  public oi_x_star, oi_lnrhoend,find_oi_x_star

contains

!returns x given potential parameters, scalar power, wreh and
!lnrhoreh. If present, returns the correspoding bfoldstar
  function oi_x_star(alpha,phi0,w,lnRhoReh,Pstar,bfold)    
    implicit none
    real(kp) :: oi_x_star
    real(kp), intent(in) :: alpha,phi0,w,lnRhoReh,Pstar
    real(kp), optional :: bfold

    real(kp), parameter :: tolFind=tolkp
    real(kp) :: mini,maxi,calF,x
    real(kp) :: primEnd,epsOneEnd,xEnd,potEnd

    type(transfert) :: oiData
    

    if (w.eq.1._kp/3._kp) then
       if (display) write(*,*)'w = 1/3 : solving for rhoReh = rhoEnd'
    endif

    xEnd=oi_x_endinf(alpha,phi0)
    
    epsOneEnd = oi_epsilon_one(xEnd,alpha,phi0)
    potEnd = oi_norm_potential(xEnd,alpha)
    primEnd = oi_efold_primitive(xEnd,alpha,phi0)
   

    calF = get_calfconst(lnRhoReh,Pstar,w,epsOneEnd,potEnd)

    oiData%real1 = alpha
    oiData%real2 = phi0
    oiData%real3 = w
    oiData%real4 = calF + primEnd

    mini = xEnd*(1._kp+epsilon(1._kp))
    maxi = mini/epsilon(1._kp)


    x = zbrent(find_oi_x_star,mini,maxi,tolFind,oiData)
    oi_x_star = x

    if (present(bfold)) then
       bfold = -(oi_efold_primitive(x,alpha,phi0) - primEnd)
    endif


  end function oi_x_star

  function find_oi_x_star(x,oiData)   
    implicit none
    real(kp) :: find_oi_x_star
    real(kp), intent(in) :: x
    type(transfert), optional, intent(inout) :: oiData

    real(kp) :: primStar,alpha,phi0,w,CalFplusPrimEnd,potStar,epsOneStar

    alpha=oiData%real1
    phi0=oiData%real2
    w = oiData%real3
    CalFplusPrimEnd = oiData%real4

    primStar = oi_efold_primitive(x,alpha,phi0)
    epsOneStar = oi_epsilon_one(x,alpha,phi0)
    potStar = oi_norm_potential(x,alpha)


    find_oi_x_star = find_reheat(PrimStar,calFplusPrimEnd,w,epsOneStar,potStar)


  end function find_oi_x_star


  function oi_lnrhoend(alpha,phi0,Pstar) 
    implicit none
    real(kp) :: oi_lnrhoend
    real(kp), intent(in) :: alpha,phi0,Pstar

    real(kp) :: xEnd, potEnd, epsOneEnd
    real(kp) :: x, potStar, epsOneStar

    real(kp), parameter :: wrad = 1._kp/3._kp
    real(kp), parameter :: junk= 0._kp
    real(kp) :: lnRhoEnd
        
    xEnd=oi_x_endinf(alpha,phi0) 
    potEnd  = oi_norm_potential(xEnd,alpha)
    epsOneEnd = oi_epsilon_one(xEnd,alpha,phi0)

!    print*,'oi_lnrhoend:   alpha=',alpha,'  phi0=',phi0, &
!            'xEnd=',xEnd,'  potEnd=',potEnd,'   epsOneEnd=',epsOneEnd
!    pause
       
    x = oi_x_star(alpha,phi0,wrad,junk,Pstar)    
    potStar = oi_norm_potential(x,alpha)
    epsOneStar = oi_epsilon_one(x,alpha,phi0)

!    print*,'oi_lnrhoend:   xstar=',x,'  potStar=',potStar,'   epsOneStar=',epsOneStar
!    pause
    
    if (.not.slowroll_validity(epsOneStar)) then
        print*,'xstar=',x,'  epsOneStar=',epsOneStar 
        stop 'oi_lnrhoend: slow-roll violated!'
    endif
    
    lnRhoEnd = ln_rho_endinf(Pstar,epsOneStar,epsOneEnd,potEnd/potStar)

    oi_lnrhoend = lnRhoEnd

  end function oi_lnrhoend

  
  
end module oireheat