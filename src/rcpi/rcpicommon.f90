!common slow-roll function for radiatively corrected plateau inflation
!
!V(phi) = M^4 x^p [1 + alpha ln(x) + beta ln(x)^2]
!
!x=phi/Mp
!
!with no assumptions on p, alpha, beta
!
module rcpicommon
  use infprec, only : kp, tolkp, transfert
  use inftools, only : selectsort, zbrent

  implicit none

  
  private

  public rcpi_norm_potential, rcpi_norm_deriv_potential
  public rcpi_norm_deriv_second_potential
  public rcpi_epsilon_one, rcpi_epsilon_two
  public rcpi_epsilon_three, rcpi_x_epstwozero, rcpi_x_epsoneunity
  public rcpi_efold_primitive, find_rcpi_x_trajectory
  public rcpi_check_derivpotzero, rcpi_check_potzero
  public rcpi_x_potzero, rcpi_x_derivpotzero
  public rcpi_numacc_x_potbig

contains

  
  function rcpi_norm_potential(x,p,alpha,beta)
    implicit none
    real(kp) :: rcpi_norm_potential
    real(kp), intent(in) :: x,alpha,beta,p

    rcpi_norm_potential = x**p*(1._kp + alpha*log(x) + beta *log(x)**2)
    
  end function rcpi_norm_potential


  
  function rcpi_norm_deriv_potential(x,p,alpha,beta)
    implicit none
    real(kp) :: rcpi_norm_deriv_potential
    real(kp), intent(in) :: x,alpha,beta,p

    rcpi_norm_deriv_potential = x**(p-1._kp)* &
         (p + alpha + (alpha*p + 2*beta)*log(x) + p*beta*log(x)**2)

  end function rcpi_norm_deriv_potential


  
  function rcpi_norm_deriv_second_potential(x,p,alpha,beta)
    implicit none
    real(kp) :: rcpi_norm_deriv_second_potential
    real(kp), intent(in) :: x,p,alpha,beta

    rcpi_norm_deriv_second_potential = x**(p-2._kp) &
         * (p*p - alpha + p*(2*alpha - 1._kp) + 2*beta &
         + (-p*alpha + p*p*alpha - 2*beta + 4*p*beta)*log(x) &
         + (p-1._kp)*p*beta*log(x)**2)

  end function rcpi_norm_deriv_second_potential


  
  function rcpi_epsilon_one(x,p,alpha,beta)
    implicit none
    real(kp) :: rcpi_epsilon_one
    real(kp), intent(in) :: x,p,alpha,beta

    rcpi_epsilon_one = (p + (alpha + 2*beta*log(x)) &
         / (1 + log(x)*(alpha + beta*log(x))))**2 /(2._kp*x**2)
    
  end function rcpi_epsilon_one


  
  function rcpi_epsilon_two(x,p,alpha,beta)
    implicit none
    real(kp) :: rcpi_epsilon_two
    real(kp), intent(in) :: x,p,alpha,beta

    rcpi_epsilon_two = (2*(p + (alpha**2 - 4*beta) &
         /(1._kp + log(x)*(alpha + beta*log(x)))**2 &
         + (alpha + 2*beta + 2*beta*log(x)) &
         /(1._kp + log(x)*(alpha + beta*log(x)))))/x**2
    
  end function rcpi_epsilon_two


  
  function rcpi_epsilon_three(x,p,alpha,beta)
    implicit none
    real(kp) :: rcpi_epsilon_three
    real(kp), intent(in) :: x,p,alpha,beta

    rcpi_epsilon_three = -(((p + (alpha + 2*beta*log(x)) &
         /(1._kp + log(x)*(alpha + beta*log(x))))*(-2*p &
         - (2*(alpha**2 - 4*beta)*(alpha + 2*beta*log(x))) &
         /(1._kp + log(x)*(alpha + beta*log(x)))**3 &
         - (3*alpha**2 + 2*(-6 + alpha)*beta + 4*beta**2*log(x)) &
         / (1 + log(x)*(alpha + beta*log(x)))**2 - (2*(alpha + 3*beta &
         + 2*beta*log(x)))/(1._kp + log(x)*(alpha + beta*log(x))))) &
         /(x**2*(p + (alpha**2 - 4*beta)/(1._kp + log(x)*(alpha &
         + beta*log(x)))**2 + (alpha + 2*beta + 2*beta*log(x)) &
         /(1._kp + log(x)*(alpha + beta*log(x))))))

  end function rcpi_epsilon_three

  
!true if the potential vanishes (and becomes negative in some regions)  
  function rcpi_check_potzero(alpha,beta)
    implicit none
    logical :: rcpi_check_potzero
    real(kp), intent(in) :: alpha, beta
    
    rcpi_check_potzero = ((alpha**2 - 4*beta).ge.0._kp)
    
  end function rcpi_check_potzero

  
  
!non-vanishing field values at which the potential vanishes
  function rcpi_x_potzero(alpha,beta)
    implicit none
    real(kp), dimension(2) :: rcpi_x_potzero
    real(kp), intent(in) :: alpha,beta

    if (.not.rcpi_check_potzero(alpha,beta)) then
       stop 'rcpi_x_potzero: V > 0'
    endif

    if ((beta.eq.0._kp).and.(alpha.ne.0._kp)) then
       rcpi_x_potzero(1) = exp(1._kp/alpha)
       rcpi_x_potzero(2) = exp(1._kp/alpha)
       return
    endif
           
    if (beta.gt.0._kp) then
       rcpi_x_potzero(1) = exp(0.5_kp*(-alpha - sqrt(alpha*alpha - 4*beta))/beta)
       rcpi_x_potzero(2) = exp(0.5_kp*(-alpha + sqrt(alpha*alpha - 4*beta))/beta)        
    else
       rcpi_x_potzero(2) = exp(0.5_kp*(-alpha - sqrt(alpha*alpha - 4*beta))/beta)
       rcpi_x_potzero(1) = exp(0.5_kp*(-alpha + sqrt(alpha*alpha - 4*beta))/beta)
    endif
       
       
  end function rcpi_x_potzero


!true if the potential admits local extrema
  function rcpi_check_derivpotzero(p,alpha,beta)
    implicit none
    logical :: rcpi_check_derivpotzero
    real(kp), intent(in) :: p,alpha, beta

    if (p.eq.0._kp) then
       rcpi_check_derivpotzero = .true.
       return
    endif
    
    rcpi_check_derivpotzero = (((alpha + 2._kp*beta/p)**2 - 4*beta*(1._kp+alpha/p)).ge.0._kp)
    
  end function rcpi_check_derivpotzero
  
    
  
!non vanishing field values at which the potential is extremal
  function rcpi_x_derivpotzero(p,alpha,beta)
    implicit none
    real(kp), dimension(2) :: rcpi_x_derivpotzero
    real(kp), intent(in) :: p,alpha,beta

    if (.not.rcpi_check_derivpotzero(p,alpha,beta)) then
       stop 'rcpi_x_potmax: dV/dx > 0'
    endif

    if (p.eq.0._kp) then
       rcpi_x_derivpotzero = exp(-0.5_kp * alpha/beta)
       return
    endif

    rcpi_x_derivpotzero(1) = exp( 0.5_kp*(-2*beta/p-alpha &
         - sqrt((2*beta/p+alpha)**2 - 4*beta*(1._kp+alpha/p)))/beta)
    rcpi_x_derivpotzero(2) = exp( 0.5_kp*(-2*beta/p-alpha &
         + sqrt((2*beta/p+alpha)**2 - 4*beta*(1._kp+alpha/p)))/beta)

    call selectsort(rcpi_x_derivpotzero)
    
  end function rcpi_x_derivpotzero


!return the non-vanishing field values at which epsilon1 is extremal
!(epsilon2 vanishes). At most two, zero values should be ignored.
  function rcpi_x_epstwozero(p,alpha,beta)
    use inftools, only : quarticroots
    implicit none
    real(kp), dimension(2) :: rcpi_x_epstwozero
    real(kp), intent(in) :: p,alpha,beta

    real(kp), dimension(5) :: coefficients
    complex(kp), dimension(4) :: croots

    integer :: i,j

    rcpi_x_epstwozero = 0._kp
    
    coefficients(1) = p + alpha + alpha*alpha - 2*beta
    coefficients(2) = alpha*alpha + 2*(1._kp + alpha)*beta + 2*alpha*p
    coefficients(3) = beta*(3*alpha + 2*beta) + (alpha*alpha + 2*beta)*p
    coefficients(4) = 2*beta*(beta + alpha*p)
    coefficients(5) = beta*beta*p

    call quarticroots(coefficients,croots)

    j=0
    do i=1,4
       if (aimag(croots(i)).ne.0._kp) cycle
       j=j+1
       if (j.gt.2) stop 'rcpi_x_epstwozero: internal error!'
       rcpi_x_epstwozero(j) = exp(real(croots(i)))
    enddo
    
    call selectsort(rcpi_x_epstwozero)
    
  end function rcpi_x_epstwozero


!numerical accuracy limitation for large field values  
  function rcpi_numacc_x_potbig(p)
    implicit none
    real(kp) :: rcpi_numacc_x_potbig
    real(kp), intent(in) :: p
    real(kp), parameter :: big = epsilon(1._kp)*huge(1._kp)

    if (p.ne.0._kp) then    
       rcpi_numacc_x_potbig = big**(1._kp/p)
    else
       rcpi_numacc_x_potbig = big
    end if
    
  end function rcpi_numacc_x_potbig
  

!returns the solution of epsilon1(x)=1, in the domain in which V>0. At
!most five, zero values should be ignored.
  function rcpi_x_epsoneunity(p,alpha,beta)
    implicit none
    integer, parameter :: nepsmax = 5
    real(kp), dimension(nepsmax) :: rcpi_x_epsoneunity
    real(kp), intent(in) :: p,alpha,beta

    real(kp), parameter :: tolFind = tolkp
    type(transfert) :: rcpiData

    real(kp), dimension(5) :: xeps
    real(kp), dimension(2) :: xepstwozero, epsones
    real(kp), dimension(2) :: xdpotzero, xpotzero

    real(kp) :: mini, maxi
    integer :: neps2

    rcpiData%real1 = p
    rcpiData%real2 = alpha
    rcpiData%real3 = beta

!the potential is piecewise positive    
    if (rcpi_check_potzero(alpha,beta)) then

       xpotzero = rcpi_x_potzero(alpha,beta)
       xdpotzero = rcpi_x_derivpotzero(p,alpha,beta)
       
       if (beta.ge.0._kp) then
!positive around x=0 and at infinity
          mini = epsilon(1._kp)
          maxi = xdpotzero(1)
          xeps(1) = zbrent(find_rcpi_x_epsoneunity,mini,maxi,tolFind,rcpiData)

          mini = xdpotzero(1)
          maxi = xpotzero(1)
          xeps(2) = zbrent(find_rcpi_x_epsoneunity,mini,maxi,tolFind,rcpiData)

          xeps(3) = 0._kp
          xeps(4) = 0._kp
          
          mini = xpotzero(2)
          maxi = rcpi_numacc_x_potbig(p)
          xeps(5) = zbrent(find_rcpi_x_epsoneunity,mini,maxi,tolFind,rcpiData)

       else
!positive only between the potential zeros
          xeps(1) = 0._kp
          xeps(2) = 0._kp
          
          mini = xpotzero(1)
          maxi = xdpotzero(2)
          xeps(3) = zbrent(find_rcpi_x_epsoneunity,mini,maxi,tolFind,rcpiData)

          mini = xdpotzero(2)
          maxi = xpotzero(2)
          xeps(4) = zbrent(find_rcpi_x_epsoneunity,mini,maxi,tolFind,rcpiData)

          xeps(5) = 0._kp
          
       endif
          
    else
!the potential is never negative
       xepstwozero = rcpi_x_epstwozero(p,alpha,beta)
       neps2 = count(xepstwozero.ne.0._kp)

       if (neps2.eq.2) then
          epsones(1) = rcpi_epsilon_one(xepstwozero(1),p,alpha,beta)
          epsones(2) = rcpi_epsilon_one(xepstwozero(2),p,alpha,beta)
       else
          mini = epsilon(1._kp)
          maxi = rcpi_numacc_x_potbig(p)
          xeps(1:4) = 0._kp
          xeps(5) = zbrent(find_rcpi_x_epsoneunity,mini,maxi,tolFind,rcpiData)
          rcpi_x_epsoneunity = xeps
          return
       endif
                              
       if (rcpi_check_derivpotzero(p,alpha,beta)) then
!at most five roots
          xdpotzero = rcpi_x_derivpotzero(p,alpha,beta)

          if (epsones(2).lt.1._kp) then
             xeps(5) = 0._kp
             xeps(4) = 0._kp
          else
             mini = xepstwozero(2)
             maxi = rcpi_numacc_x_potbig(p)
             xeps(5) = zbrent(find_rcpi_x_epsoneunity,mini,maxi,tolFind,rcpiData)
             mini = xdpotzero(2)
             maxi = xepstwozero(2)
             xeps(4) = zbrent(find_rcpi_x_epsoneunity,mini,maxi,tolFind,rcpiData)
          endif

          if (epsones(1).lt.1._kp) then
             xeps(3) = 0._kp
             xeps(2) = 0._kp
          else
             mini = xepstwozero(1)
             maxi = xdpotzero(2)
             xeps(3) = zbrent(find_rcpi_x_epsoneunity,mini,maxi,tolFind,rcpiData)
             mini = xdpotzero(1)
             maxi = xepstwozero(1)
             xeps(2) = zbrent(find_rcpi_x_epsoneunity,mini,maxi,tolFind,rcpiData)
          endif

          mini = epsilon(1._kp)
          maxi = xdpotzero(1)
          xeps(1) = zbrent(find_rcpi_x_epsoneunity,mini,maxi,tolFind,rcpiData)

          !at most three roots       
       else

          xeps(3) = 0._kp
          xeps(2) = 0._kp
                    
          if (epsones(2).lt.1._kp) then
             xeps(5) = 0._kp
             xeps(4) = 0._kp
             mini = epsilon(1._kp)
             maxi = xepstwozero(1)
             xeps(1) = zbrent(find_rcpi_x_epsoneunity,mini,maxi,tolFind,rcpiData)

          elseif (epsones(1).lt.1._kp) then
             mini = xepstwozero(2)
             maxi = rcpi_numacc_x_potbig(p)
             xeps(5) = zbrent(find_rcpi_x_epsoneunity,mini,maxi,tolFind,rcpiData)

             mini = xepstwozero(1)
             maxi = xepstwozero(2)
             xeps(4) = zbrent(find_rcpi_x_epsoneunity,mini,maxi,tolFind,rcpiData)

             mini = epsilon(1._kp)
             maxi = xepstwozero(1)
             xeps(1) = zbrent(find_rcpi_x_epsoneunity,mini,maxi,tolFind,rcpiData)

          elseif (epsones(1).ge.1._kp) then
             xeps(4) = 0._kp
             xeps(1) = 0._kp
             mini = xepstwozero(2)
             maxi = rcpi_numacc_x_potbig(p)
             xeps(5) = zbrent(find_rcpi_x_epsoneunity,mini,maxi,tolFind,rcpiData)
          endif

       endif

    endif

    rcpi_x_epsoneunity = xeps
    
    
  end function rcpi_x_epsoneunity


  
  function find_rcpi_x_epsoneunity(x,rcpiData)
    implicit none
    real(kp) :: find_rcpi_x_epsoneunity
    real(kp), intent(in) :: x
    type(transfert), optional, intent(inout) :: rcpiData
    real(kp) :: p,alpha,beta

    p = rcpiData%real1
    alpha = rcpiData%real2
    beta = rcpiData%real3

    find_rcpi_x_epsoneunity = rcpi_epsilon_one(x,p,alpha,beta)-1._kp

  end function find_rcpi_x_epsoneunity



  
  function rcpi_efold_primitive(x,p,alpha,beta)
    use specialinf, only : cei, ei
    implicit none
    real(kp) :: rcpi_efold_primitive
    real(kp), intent(in) :: x,p,alpha,beta
    complex(kp) :: sqrtdelta, za, zb
    complex(kp) :: expinta, expintb,primitive

    if ((p.eq.0._kp).and.(alpha.eq.0._kp).and.(beta.eq.0._kp)) then
       stop 'rcpi_efold_primitive: de-Sitter model not supported!'
    endif
    
    if ((p.eq.0._kp).and.(beta.ne.0._kp)) then
       rcpi_efold_primitive = (-(((alpha**2 - 4*beta) &
            *ei(alpha/beta + 2*Log(x)))/exp(alpha/beta)) &
            + beta*x**2*(alpha - beta + 2*beta*log(x)))/(8*beta**2)
       return
    endif

    if ((beta.eq.0._kp).and.(p.ne.0._kp).and.(alpha.ne.0._kp)) then
       rcpi_efold_primitive = x**2/(2._kp*p) - ei(2*(1._kp/alpha + 1._kp/p + log(x))) &
            /(exp(2*(1._kp/alpha + 1._kp/p))*p**2)
       return
    endif

    if ((beta.eq.0._kp).and.(p.eq.0._kp).and.alpha.ne.0._kp) then
       rcpi_efold_primitive = (x**2*(2 - alpha + 2*alpha*log(x)))/(4._kp*alpha)
       return
    endif

    sqrtdelta = sqrt(cmplx(p*p*(alpha*alpha-4*beta) + 4*beta*beta))

    za = (-sqrtdelta + p*alpha + 2*beta)/p/beta
    zb = (sqrtdelta + p*alpha + 2*beta)/p/beta
    
    call cei(za+2._kp*log(x),expinta)
    call cei(zb+2._kp*log(x),expintb)
   
    primitive = (exp(zb)*p*sqrtdelta*x**2 - 2*exp((2*sqrtdelta)/(beta*p)) &
         *(-2*beta + sqrtdelta)*expinta - 2*(2*beta + sqrtdelta)*expintb) &
         /(2._kp*exp(zb)*p**2*sqrtdelta)
    
    rcpi_efold_primitive = real(primitive,kp)

    if (isnan(rcpi_efold_primitive)) stop 'rcpi_efold_primitive: NaN!'
    
  end function rcpi_efold_primitive


  function find_rcpi_x_trajectory(x,rcpiData)
    implicit none
    real(kp) :: find_rcpi_x_trajectory
    real(kp), intent(in) :: x
    type(transfert), optional, intent(inout) :: rcpiData

    real(kp) :: p, alpha, beta, NplusNuend

    p = rcpiData%real1
    alpha = rcpiData%real2
    beta = rcpiData%real3
    NplusNuend = rcpiData%real4

    find_rcpi_x_trajectory = rcpi_efold_primitive(x,p,alpha,beta) - NplusNuend
    
  end function find_rcpi_x_trajectory

  
end module rcpicommon
