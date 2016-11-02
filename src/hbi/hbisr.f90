!slow-roll functions for the hyperbolic potential
!
!V(phi) = M^4 [sinh(x)^n]
!
!x = phi/phi0
!phi0 = phi0/Mp

module hbisr
  use infprec, only : kp

  implicit none

  private

  public hbi_norm_potential, hbi_norm_deriv_potential, hbi_norm_deriv_second_potential
  public hbi_epsilon_one, hbi_epsilon_two,hbi_epsilon_three
  public hbi_x_endinf, hbi_efold_primitive, hbi_x_trajectory

  public hbi_x_fromepstwo

 
contains
!returns V/M^4
  function hbi_norm_potential(x,n,phi0)
    implicit none
    real(kp) :: hbi_norm_potential
    real(kp), intent(in) :: x,n
    real(kp), intent(in) :: phi0

    hbi_norm_potential = sinh(x)**n
  end function hbi_norm_potential


!returns the first derivative of the potential with respect to x, divided by M^4
  function hbi_norm_deriv_potential(x,n,phi0)
    implicit none
    real(kp) :: hbi_norm_deriv_potential
    real(kp), intent(in) :: x,n
    real(kp), intent(in) :: phi0

   hbi_norm_deriv_potential = n*cosh(x)*sinh(x)**(n-1._kp)

  end function hbi_norm_deriv_potential



!returns the second derivative of the potential with respect to x, divided by M^4
  function hbi_norm_deriv_second_potential(x,n,phi0)
    implicit none
    real(kp) :: hbi_norm_deriv_second_potential
    real(kp), intent(in) :: x,n
    real(kp), intent(in) :: phi0

    hbi_norm_deriv_second_potential = 0.5_kp*n*(n*cosh(2._kp*x)+n-2._kp)*sinh(x)**(n-2._kp)

  end function hbi_norm_deriv_second_potential

!epsilon1(x)
  function hbi_epsilon_one(x,n,phi0)    
    implicit none
    real(kp) :: hbi_epsilon_one
    real(kp), intent(in) :: x,n,phi0
    
    hbi_epsilon_one = 0.5*n**2/(phi0**2*tanh(x)**2)
    
  end function hbi_epsilon_one


!epsilon2(x)
  function hbi_epsilon_two(x,n,phi0)    
    implicit none
    real(kp) :: hbi_epsilon_two
    real(kp), intent(in) :: x,n,phi0
    
    hbi_epsilon_two = 2._kp*n/(phi0**2*sinh(x)**2)
    
  end function hbi_epsilon_two

!epsilon3(x)
  function hbi_epsilon_three(x,n,phi0)    
    implicit none
    real(kp) :: hbi_epsilon_three
    real(kp), intent(in) :: x,n,phi0
    
    hbi_epsilon_three = 2._kp*n/(phi0**2*tanh(x)**2)
    
  end function hbi_epsilon_three


!this is integral[V(phi)/V'(phi) dphi]
  function hbi_efold_primitive(x,n,phi0)
    implicit none
    real(kp), intent(in) :: x,n,phi0
    real(kp) :: hbi_efold_primitive

    hbi_efold_primitive = phi0**2/n*log(cosh(x))

  end function hbi_efold_primitive


!returns x at the end of inflation defined as epsilon1=1
  function hbi_x_endinf(n,phi0)
    implicit none
    real(kp), intent(in) :: n,phi0
    real(kp) :: hbi_x_endinf

    hbi_x_endinf = atanh(n/(sqrt(2._kp)*phi0))
   
  end function hbi_x_endinf


!returns x at bfold=-efolds before the end of inflation
  function hbi_x_trajectory(bfold,xend,n,phi0)
    implicit none
    real(kp), intent(in) :: bfold, n, phi0, xend
    real(kp) :: hbi_x_trajectory

    hbi_x_trajectory = acosh(exp(-n*bfold/phi0**2)/sqrt(1._kp-n**2/(2._kp*phi0**2)))
    
  end function hbi_x_trajectory


  
!returns x given epsilon2  
  function hbi_x_fromepstwo(eps2,n,phi0)   
    implicit none
    real(kp), intent(in) :: n,phi0,eps2
    real(kp) :: hbi_x_fromepstwo

    hbi_x_fromepstwo = asinh(sqrt(2._kp*n/eps2)/phi0)

 end function hbi_x_fromepstwo


end module hbisr
