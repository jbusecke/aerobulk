! AeroBulk / 2015 / L. Brodeau

MODULE mod_const

   IMPLICIT NONE

   PUBLIC

   !! Following NEMO:
   INTEGER, PARAMETER :: sp = SELECTED_REAL_KIND( 6, 37)   !: single precision (real 4)
   INTEGER, PARAMETER :: dp = SELECTED_REAL_KIND(12,307)   !: double precision (real 8)
   INTEGER, PARAMETER :: wp = dp                           !: working precision

   ! THINGS THAT NEED TO BE GIVEN A VALUE, anh have the same name and type as in NEMO...
   ! Stupid values here to prevent to ommit to give them a value:
   INTEGER,                  SAVE :: jpi=0, jpj=0    !: 2D dimensions of array to be used in AeroBulk
   INTEGER,  PARAMETER            :: jpk = 1, nit000 = 1
   REAL(wp), DIMENSION(jpk), SAVE :: gdept_1d = (/ 1._wp /) !: depth at which SST is measured [m]
   REAL(wp),                 SAVE :: rdt = 3600. !: time step for the cool-skin/warm-layer parameterization  [s]
   INTEGER,                  SAVE :: nb_itt=5  !: number of itteration in the bulk algorithm

   LOGICAL, SAVE :: l_first_call=.true. , l_last_call=.false.

   LOGICAL, PARAMETER :: ldebug_blk_algos=.false.


   !! General constants:
   REAL(wp), PARAMETER, PUBLIC :: grav  = 9.8      !: acceleration of gravity    [m.s^-2]
   REAL(wp), PARAMETER, PUBLIC :: rpi   = 3.141592653589793_wp
   REAL(wp), PARAMETER, PUBLIC :: twoPi = 2.*rpi
   REAL(wp), PARAMETER, PUBLIC :: to_rad = rpi/180.

   
   !! Earth constants:
   REAL(wp), PARAMETER, PUBLIC :: R_earth = 6.37E6 ! Earth radius (m)
   REAL(wp), PARAMETER, PUBLIC ::rtilt_earth = 23.5
   REAL(wp), PARAMETER, PUBLIC ::Sol0 = 1366.         !: Solar constant W/m^2
   !!
   REAL(wp), PARAMETER, PUBLIC :: roce_alb0  = 0.066   !: Default sea surface albedo over ocean when nothing better is available
   !!                                                      !: NEMO: 0.066 / ECMWF: 0.055
   REAL(wp), PARAMETER, PUBLIC :: rice_alb0  = 0.8     !: BAD!!! must use that of the sea-ice model when possible !!!


   !! Physics constants:
   REAL(wp), PARAMETER, PUBLIC ::emiss_w = 0.97   !: emissivity of sea water
   REAL(wp), PARAMETER, PUBLIC ::emiss_i = 0.996  !:   "   for ice and snow => but Rees 1993 suggests can be lower in winter on fresh snow... 0.72 ...
   REAL(wp), PARAMETER, PUBLIC ::stefan = 5.67E-8 !: Stefan Boltzman constant

   !! Thermodynamics / Water:
   REAL(wp), PARAMETER, PUBLIC :: rt0  = 273.15      !: freezing point of fresh water [K]
   REAL(wp), PARAMETER, PUBLIC :: rtt0 = 273.16      !: triple point                  [K]
   !!
   REAL(wp), PARAMETER, PUBLIC :: rCp0_w  = 4190.    !: Specific heat capacity of seawater (ECMWF 4190) [J/K/kg]
   REAL(wp), PARAMETER, PUBLIC :: rho0_w = 1025.     !: Density of sea-water  (ECMWF->1025)             [kg/m^3]
   REAL(wp), PARAMETER, PUBLIC :: rnu0_w = 1.e-6     !: kinetic viscosity of water                      [m^2/s]
   REAL(wp), PARAMETER, PUBLIC :: rk0_w  = 0.6       !: thermal conductivity of water (at 20C)          [W/m/K]

   
   !! Thermodynamics:
   REAL(wp), PARAMETER, PUBLIC :: rCp0_a  = 1015.0   !: Specic heat of moist air                      [J/K/kg]
   REAL(wp), PARAMETER, PUBLIC :: rCp_dry = 1005.0   !: Specic heat of dry air, constant pressure      [J/K/kg]
   REAL(wp), PARAMETER, PUBLIC :: rCp_vap = 1860.0   !: Specic heat of water vapor, constant pressure  [J/K/kg]
   !!
   REAL(wp), PARAMETER, PUBLIC :: R_dry = 287.05     !: Specific gas constant for dry air              [J/K/kg]
   REAL(wp), PARAMETER, PUBLIC :: R_vap = 461.495    !: Specific gas constant for water vapor          [J/K/kg]
   !!
   REAL(wp), PARAMETER, PUBLIC :: reps0 = R_dry/R_vap      !: ratio of gas constant for dry air and water vapor => ~ 0.622
   REAL(wp), PARAMETER, PUBLIC :: rctv0 = R_vap/R_dry - 1. !: for virtual temperature (== (1-eps)/eps) => ~ 0.608
   !!
   REAL(wp), PARAMETER, PUBLIC :: rnu0_air  = 1.5E-5   !: kinematic viscosity of air    [m^2/s]
   !!
   REAL(wp), PARAMETER, PUBLIC :: rLevap = 2.46e+6_wp   !: Latent heat of vaporization for sea-water in   [J/kg]
   REAL(wp), PARAMETER, PUBLIC :: rLsub  = 2.834e+6_wp  !: Latent heat of sublimation for ice at 0 deg.C  [J/kg]
   !!
   REAL(wp), PARAMETER, PUBLIC :: Tswf  = 273.         !: BAD!!! because sea-ice not used yet!!!

   
   !! Some defaults:
   REAL(wp), PARAMETER, PUBLIC :: Patm  = 101000. !: atmospheric pressure               [Pa]
   REAL(wp), PARAMETER, PUBLIC :: rho0_a = 1.2    !: Approx. of density of air          [kg/m^3]

   
   !! Bulk model:
   REAL(wp), PARAMETER, PUBLIC :: vkarmn  = 0.4_wp         !: Von Karman's constant
   REAL(wp), PARAMETER, PUBLIC :: vkarmn2 = 0.4_wp*0.4_wp  !: Von Karman's constant ^2
   REAL(wp), PARAMETER, PUBLIC :: rdct_qsat_salt = 0.98_wp !: factor to apply to q_sat(SST) to account for salt in estimation of sat. spec. hum.
   REAL(wp), PARAMETER, PUBLIC :: z0_sea_max = 0.0025_wp   !: maximum realistic value for roughness length of sea-surface... [m]
   
   !! Cool-skin warm-layer:
   REAL(wp), PARAMETER, PUBLIC :: rcst_cs = -16._wp*9.80665_wp*rho0_w*rCp0_w*rnu0_w*rnu0_w*rnu0_w/(rk0_w*rk0_w) !: for cool-skin parameteri$
   !                              => see eq.(14) in Fairall et al. 1996   (eq.(6) of Zeng aand Beljaars is WRONG! (typo?)
   REAL(wp), PARAMETER, PUBLIC :: radrw    = rho0_a/rho0_w !: Density ratio
   REAL(wp), PARAMETER, PUBLIC :: sq_radrw = SQRT(rho0_a/rho0_w)

   REAL(wp), PARAMETER, PUBLIC :: Cx_min = 0.1E-3_wp ! smallest value allowed for bulk transfer coefficients (usually in stable conditions with now wind)
   

   !! Sea-ice stuff:
   REAL(wp), PARAMETER, PUBLIC :: rCd_ice = 1.4e-3_wp   !: transfer coefficient over ice
   REAL(wp), PARAMETER, PUBLIC :: to_mm_p_day = 24._wp*3600._wp  !: freshwater flux: from kg/s/m^2 == mm/s to mm/day
   REAL(wp), PARAMETER, PUBLIC :: wspd_thrshld_ice = 0.2_wp !: minimum scalar wind speed accepted over sea-ice...
   !REAL(wp), PARAMETER, PUBLIC :: wspd_thrshld_ice = 0.5_wp !: minimum scalar wind speed accepted over sea-ice...



   !! Calendar:
   INTEGER, DIMENSION(12), PARAMETER, PUBLIC :: &
      &   tdmn = (/ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 /), &
      &   tdml = (/ 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 /)


   CHARACTER(len=200), PARAMETER :: cform_err = '(" *** E R R O R :  ")'



   !! IFS:

   !REAL(wp), PARAMETER :: &
   !&    RKBOL = 1.380658E-23, &
   !&    RNAVO = 6.0221367E+23, &
   !&    R = RNAVO*RKBOL, &
   !&    RMD = 28.9644, &
   !&    RMV = 18.0153, &
   !&    RD = 1000.*R/RMD, &
   !&    RV = 1000.*R/RMV, &
   !&    rCp_dry = 3.5*RD, &
   !&    rLevap=2.5008E+6, &









   !! Max and min values for variable (for netcdf files)

   !REAL(wp), PARAMETER :: &
   !&                qlat_min = -1200., qlat_max = 200., &
   !     &                qsen_min = -900. , qsen_max = 300., &
   !     &                taum_min =    0., taum_max =   4.,  &
   !     !!
   !     &                msl_min  = 85000., msl_max = 105000., &
   !     &                tair_min =  223., tair_max = 323.,  &
   !     &                qair_min =    0., qair_max = 0.03,  &
   !     &                w10_min  =    0., w10_max  = 45.,   &
   !     &                sst_min  =  270., sst_max  = 310.,  &
   !     &                ice_min  =    0., ice_max  =   1.,  &
   !     &                cx_min   =    0., cx_max   = 0.01,  &
   !     &                rho_min  =   0.8, rho_max  =  1.5       ! density of air
   !CCSM/ccsm2/models/ice/dice5/flux_ai.F90



CONTAINS


   SUBROUTINE ctl_stop( cd1, cd2, cd3, cd4, cd5, cd6, cd7, cd8, cd9, cd10 )
      !!----------------------------------------------------------------------
      !!                  ***  ROUTINE  ctl_stop  ***
      !!
      !! ** Purpose :   print in ocean.outpput file a error message and
      !!                increment the error number (nstop) by one.
      !!----------------------------------------------------------------------
      CHARACTER(len=*), INTENT(in), OPTIONAL ::  cd1, cd2, cd3, cd4, cd5
      CHARACTER(len=*), INTENT(in), OPTIONAL ::  cd6, cd7, cd8, cd9, cd10
      INTEGER, PARAMETER :: numout=6
      !!----------------------------------------------------------------------
      !
      !nstop = nstop + 1

      ! force to open ocean.output file
      !IF( numout == 6 ) CALL ctl_opn( numout, 'ocean.output', 'APPEND', 'FORMATTED', 'SEQUENTIAL', -1, 6, .FALSE. )

      WRITE(numout,cform_err)
      IF( PRESENT(cd1 ) )   WRITE(numout,*) TRIM(cd1)
      IF( PRESENT(cd2 ) )   WRITE(numout,*) TRIM(cd2)
      IF( PRESENT(cd3 ) )   WRITE(numout,*) TRIM(cd3)
      IF( PRESENT(cd4 ) )   WRITE(numout,*) TRIM(cd4)
      IF( PRESENT(cd5 ) )   WRITE(numout,*) TRIM(cd5)
      IF( PRESENT(cd6 ) )   WRITE(numout,*) TRIM(cd6)
      IF( PRESENT(cd7 ) )   WRITE(numout,*) TRIM(cd7)
      IF( PRESENT(cd8 ) )   WRITE(numout,*) TRIM(cd8)
      IF( PRESENT(cd9 ) )   WRITE(numout,*) TRIM(cd9)
      IF( PRESENT(cd10) )   WRITE(numout,*) TRIM(cd10)

      WRITE(numout,*) ''
      !CALL FLUSH(numout    )
      !IF( numstp     /= -1 )   CALL FLUSH(numstp    )
      !IF( numrun     /= -1 )   CALL FLUSH(numrun    )
      !IF( numevo_ice /= -1 )   CALL FLUSH(numevo_ice)
      !
      !IF( cd1 == 'STOP' ) THEN
      !   WRITE(numout,*)  'huge E-R-R-O-R : immediate stop'
      !   CALL mppstop(ld_force_abort = .true.)
      !ENDIF
      STOP
      !
   END SUBROUTINE ctl_stop






END MODULE mod_const




!! In CCSM:
!! from CCSM/ccsm2/models/ice/dice5/flux_ai.F90 :


!      REAL, PARAMETER :: cpair  =  1.005e3         !: Specific heat of dry air
!      REAL, PARAMETER :: cpwv   =  1.81e3          !: Specific heat of water vapor
!      REAL, PARAMETER :: cpvir  =  cpwv/cpair - 1. !: Defined as cpwv/cpair - 1.
!      REAL, PARAMETER :: gravit =  9.80616         !: Acceleration of gravity
!      REAL, PARAMETER :: stebol = 56.7e-9          !: Stefan-Boltzmann's constant
!      REAL, PARAMETER :: xkar   =  0.4             !: Von Karman constant
!      REAL, PARAMETER :: zvir   =  0.606           !: rh2o/rair - 1.0
!      REAL, PARAMETER :: zzsice =  0.0005          !: ice surface roughness
!      REAL, PARAMETER :: latvap =  2.5e6           !: latent heat of evaporation
!      REAL, PARAMETER :: latice =   .334e6         !: latent heat of fusion
