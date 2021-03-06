!> \file  
!> \author Sebastian Krittian
!> \brief This module handles all Navier-Stokes fluid routines.
!>
!> \section LICENSE
!>
!> Version: MPL 1.1/GPL 2.0/LGPL 2.1
!>
!> The contents of this file are subject to the Mozilla Public License
!> Version 1.1 (the "License"); you may not use this file except in
!> compliance with the License. You may obtain a copy of the License at
!> http://www.mozilla.org/MPL/
!>
!> Software distributed under the License is distributed on an "AS IS"
!> basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
!> License for the specific language governing rights and limitations
!> under the License.
!>
!> The Original Code is OpenCMISS
!>
!> The Initial Developer of the Original Code is University of Auckland,
!> Auckland, New Zealand, the University of Oxford, Oxford, United
!> Kingdom and King's College, London, United Kingdom. Portions created
!> by the University of Auckland, the University of Oxford and King's
!> College, London are Copyright (C) 2007-2010 by the University of
!> Auckland, the University of Oxford and King's College, London.
!> All Rights Reserved.
!>
!> Contributor(s):
!>
!> Alternatively, the contents of this file may be used under the terms of
!> either the GNU General Public License Version 2 or later (the "GPL"), or
!> the GNU Lesser General Public License Version 2.1 or later (the "LGPL"),
!> in which case the provisions of the GPL or the LGPL are applicable instead
!> of those above. If you wish to allow use of your version of this file only
!> under the terms of either the GPL or the LGPL, and not to allow others to
!> use your version of this file under the terms of the MPL, indicate your
!> decision by deleting the provisions above and replace them with the notice
!> and other provisions required by the GPL or the LGPL. If you do not delete
!> the provisions above, a recipient may use your version of this file under
!> the terms of any one of the MPL, the GPL or the LGPL.
!>

!>This module handles all Navier-Stokes fluid routines.
MODULE NAVIER_STOKES_EQUATIONS_ROUTINES

  USE ANALYTIC_ANALYSIS_ROUTINES
  USE BASE_ROUTINES
  USE BASIS_ROUTINES
  USE BOUNDARY_CONDITIONS_ROUTINES
  USE CONSTANTS
  USE CONTROL_LOOP_ROUTINES
  USE DISTRIBUTED_MATRIX_VECTOR
  USE DOMAIN_MAPPINGS
  USE EQUATIONS_ROUTINES
  USE EQUATIONS_MAPPING_ROUTINES
  USE EQUATIONS_MATRICES_ROUTINES
  USE EQUATIONS_SET_CONSTANTS
  USE FIELD_ROUTINES
  USE FLUID_MECHANICS_IO_ROUTINES
  USE INPUT_OUTPUT
  USE ISO_VARYING_STRING
  USE KINDS
  USE MATRIX_VECTOR
  USE NODE_ROUTINES
  USE PROBLEM_CONSTANTS
  USE STRINGS
  USE SOLVER_ROUTINES
  USE TIMER
  USE TYPES

  IMPLICIT NONE

  PRIVATE

  PUBLIC NAVIER_STOKES_EQUATIONS_SET_SUBTYPE_SET
  PUBLIC NAVIER_STOKES_EQUATIONS_SET_SOLUTION_METHOD_SET
  PUBLIC NAVIER_STOKES_EQUATION_ANALYTIC_CALCULATE
  PUBLIC NAVIER_STOKES_EQUATIONS_SET_SETUP
  PUBLIC NAVIER_STOKES_PROBLEM_SUBTYPE_SET
  PUBLIC NAVIER_STOKES_PROBLEM_SETUP
  PUBLIC NAVIER_STOKES_FINITE_ELEMENT_JACOBIAN_EVALUATE
  PUBLIC NAVIER_STOKES_FINITE_ELEMENT_RESIDUAL_EVALUATE
  PUBLIC NAVIER_STOKES_POST_SOLVE
  PUBLIC NAVIER_STOKES_PRE_SOLVE
  PUBLIC NAVIER_STOKES_EQUATION_ANALYTIC_FUNCTIONS
  PUBLIC NAVIER_STOKES_CONTROL_TIME_LOOP_PRE_LOOP

  INTEGER(INTG) :: SOLVER_NUMBER_NAVIER_STOKES

CONTAINS 

!
!================================================================================================================================
!

  !>Sets/changes the solution method for a Navier-Stokes flow equation type of an fluid mechanics equations set class.
  SUBROUTINE NAVIER_STOKES_EQUATIONS_SET_SOLUTION_METHOD_SET(EQUATIONS_SET,SOLUTION_METHOD,ERR,ERROR,*)

    !Argument variables
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set to set the solution method for
    INTEGER(INTG), INTENT(IN) :: SOLUTION_METHOD !<The solution method to set
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    
    CALL ENTERS("NAVIER_STOKES_EQUATIONS_SET_SOLUTION_METHOD_SET",ERR,ERROR,*999)
    
    IF(ASSOCIATED(EQUATIONS_SET)) THEN
      SELECT CASE(EQUATIONS_SET%SUBTYPE)
        CASE(EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE, &
          & EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE, &
          & EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE, &
          & EQUATIONS_SET_1DTRANSIENT_NAVIER_STOKES_SUBTYPE, &
          & EQUATIONS_SET_QUASISTATIC_NAVIER_STOKES_SUBTYPE, &
          & EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE, &
          & EQUATIONS_SET_PGM_NAVIER_STOKES_SUBTYPE)                                
          SELECT CASE(SOLUTION_METHOD)
            CASE(EQUATIONS_SET_FEM_SOLUTION_METHOD)
              EQUATIONS_SET%SOLUTION_METHOD=EQUATIONS_SET_FEM_SOLUTION_METHOD
            CASE(EQUATIONS_SET_BEM_SOLUTION_METHOD)
              CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
            CASE(EQUATIONS_SET_FD_SOLUTION_METHOD)
              CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
            CASE(EQUATIONS_SET_FV_SOLUTION_METHOD)
              CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
            CASE(EQUATIONS_SET_GFEM_SOLUTION_METHOD)
              CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
            CASE(EQUATIONS_SET_GFV_SOLUTION_METHOD)
              CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
            CASE DEFAULT
              LOCAL_ERROR="The specified solution method of "//TRIM(NUMBER_TO_VSTRING(SOLUTION_METHOD,"*",ERR,ERROR))// &
                & " is invalid."
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        CASE DEFAULT
          LOCAL_ERROR="Equations set subtype of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
            & " is not valid for a Navier-Stokes flow equation type of a fluid mechanics equations set class."
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      END SELECT
    ELSE
      CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("NAVIER_STOKES_EQUATIONS_SET_SOLUTION_METHOD_SET")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_EQUATIONS_SET_SOLUTION_METHOD_SET",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_EQUATIONS_SET_SOLUTION_METHOD_SET")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_EQUATIONS_SET_SOLUTION_METHOD_SET

!
!================================================================================================================================
!

  !>Sets/changes the equation subtype for a Navier-Stokes fluid type of a fluid mechanics equations set class.
  SUBROUTINE NAVIER_STOKES_EQUATIONS_SET_SUBTYPE_SET(EQUATIONS_SET,EQUATIONS_SET_SUBTYPE,ERR,ERROR,*)

    !Argument variables
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set to set the equation subtype for
    INTEGER(INTG), INTENT(IN) :: EQUATIONS_SET_SUBTYPE !<The equation subtype to set
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("NAVIER_STOKES_EQUATIONS_SET_SUBTYPE_SET",ERR,ERROR,*999)

    IF(ASSOCIATED(EQUATIONS_SET)) THEN
      SELECT CASE(EQUATIONS_SET_SUBTYPE)
      CASE(EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE)
        EQUATIONS_SET%CLASS=EQUATIONS_SET_FLUID_MECHANICS_CLASS
        EQUATIONS_SET%TYPE=EQUATIONS_SET_NAVIER_STOKES_EQUATION_TYPE
        EQUATIONS_SET%SUBTYPE=EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE
      CASE(EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE)
        EQUATIONS_SET%CLASS=EQUATIONS_SET_FLUID_MECHANICS_CLASS
        EQUATIONS_SET%TYPE=EQUATIONS_SET_NAVIER_STOKES_EQUATION_TYPE
        EQUATIONS_SET%SUBTYPE=EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE
      CASE(EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE)
        EQUATIONS_SET%CLASS=EQUATIONS_SET_FLUID_MECHANICS_CLASS
        EQUATIONS_SET%TYPE=EQUATIONS_SET_NAVIER_STOKES_EQUATION_TYPE
        EQUATIONS_SET%SUBTYPE=EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE
      CASE(EQUATIONS_SET_1DTRANSIENT_NAVIER_STOKES_SUBTYPE)
        EQUATIONS_SET%CLASS=EQUATIONS_SET_FLUID_MECHANICS_CLASS
        EQUATIONS_SET%TYPE=EQUATIONS_SET_NAVIER_STOKES_EQUATION_TYPE
        EQUATIONS_SET%SUBTYPE=EQUATIONS_SET_1DTRANSIENT_NAVIER_STOKES_SUBTYPE
      CASE(EQUATIONS_SET_QUASISTATIC_NAVIER_STOKES_SUBTYPE)
        EQUATIONS_SET%CLASS=EQUATIONS_SET_FLUID_MECHANICS_CLASS
        EQUATIONS_SET%TYPE=EQUATIONS_SET_NAVIER_STOKES_EQUATION_TYPE
        EQUATIONS_SET%SUBTYPE=EQUATIONS_SET_QUASISTATIC_NAVIER_STOKES_SUBTYPE
      CASE(EQUATIONS_SET_ALE_STOKES_SUBTYPE)
        EQUATIONS_SET%CLASS=EQUATIONS_SET_FLUID_MECHANICS_CLASS
        EQUATIONS_SET%TYPE=EQUATIONS_SET_NAVIER_STOKES_EQUATION_TYPE
        EQUATIONS_SET%SUBTYPE=EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE
      CASE(EQUATIONS_SET_PGM_STOKES_SUBTYPE)
        EQUATIONS_SET%CLASS=EQUATIONS_SET_FLUID_MECHANICS_CLASS
        EQUATIONS_SET%TYPE=EQUATIONS_SET_NAVIER_STOKES_EQUATION_TYPE
        EQUATIONS_SET%SUBTYPE=EQUATIONS_SET_PGM_NAVIER_STOKES_SUBTYPE
      CASE(EQUATIONS_SET_OPTIMISED_NAVIER_STOKES_SUBTYPE)
        CALL FLAG_ERROR("Not implemented yet.",ERR,ERROR,*999)
      CASE DEFAULT
        LOCAL_ERROR="Equations set subtype "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SUBTYPE,"*",ERR,ERROR))// &
          & " is not valid for a Navier-Stokes fluid type of a fluid mechanics equations set class."
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      END SELECT
    ELSE
      CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
    ENDIF

    CALL EXITS("NAVIER_STOKES_EQUATIONS_SET_SUBTYPE_SET")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_EQUATIONS_SET_SUBTYPE_SET",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_EQUATIONS_SET_SUBTYPE_SET")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_EQUATIONS_SET_SUBTYPE_SET

!
!================================================================================================================================
!

  !>Sets up the Navier-Stokes fluid setup.
  SUBROUTINE NAVIER_STOKES_EQUATIONS_SET_SETUP(EQUATIONS_SET,EQUATIONS_SET_SETUP,ERR,ERROR,*)

    !Argument variables
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set to setup
    TYPE(EQUATIONS_SET_SETUP_TYPE), INTENT(INOUT) :: EQUATIONS_SET_SETUP !<The equations set setup information
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: GEOMETRIC_SCALING_TYPE,GEOMETRIC_MESH_COMPONENT
    TYPE(DECOMPOSITION_TYPE), POINTER :: GEOMETRIC_DECOMPOSITION
    TYPE(EQUATIONS_TYPE), POINTER :: EQUATIONS
    TYPE(EQUATIONS_MAPPING_TYPE), POINTER :: EQUATIONS_MAPPING
    TYPE(EQUATIONS_MATRICES_TYPE), POINTER :: EQUATIONS_MATRICES
    TYPE(EQUATIONS_SET_MATERIALS_TYPE), POINTER :: EQUATIONS_MATERIALS
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    INTEGER(INTG) :: DEPENDENT_FIELD_NUMBER_OF_VARIABLES,DEPENDENT_FIELD_NUMBER_OF_COMPONENTS
    INTEGER(INTG) :: NUMBER_OF_DIMENSIONS,GEOMETRIC_COMPONENT_NUMBER
    INTEGER(INTG) :: INDEPENDENT_FIELD_NUMBER_OF_COMPONENTS,INDEPENDENT_FIELD_NUMBER_OF_VARIABLES
    INTEGER(INTG) :: MATERIAL_FIELD_NUMBER_OF_VARIABLES,MATERIAL_FIELD_NUMBER_OF_COMPONENTS,I

    CALL ENTERS("NAVIER_STOKES_SET_SETUP",ERR,ERROR,*999)

    NULLIFY(EQUATIONS)
    NULLIFY(EQUATIONS_MAPPING)
    NULLIFY(EQUATIONS_MATRICES)
    NULLIFY(GEOMETRIC_DECOMPOSITION)

    IF(ASSOCIATED(EQUATIONS_SET)) THEN
      SELECT CASE(EQUATIONS_SET%SUBTYPE)
        CASE(EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE, &
          & EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE, &
          & EQUATIONS_SET_1DTRANSIENT_NAVIER_STOKES_SUBTYPE, &
          & EQUATIONS_SET_QUASISTATIC_NAVIER_STOKES_SUBTYPE, &
          & EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE, &
          & EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE, &
          & EQUATIONS_SET_PGM_NAVIER_STOKES_SUBTYPE)
          SELECT CASE(EQUATIONS_SET_SETUP%SETUP_TYPE)
            CASE(EQUATIONS_SET_SETUP_INITIAL_TYPE)
              SELECT CASE(EQUATIONS_SET%SUBTYPE)
                CASE(EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE, &
                  & EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE, &
                  & EQUATIONS_SET_PGM_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_QUASISTATIC_NAVIER_STOKES_SUBTYPE, &
                  & EQUATIONS_SET_1DTRANSIENT_NAVIER_STOKES_SUBTYPE)
                  SELECT CASE(EQUATIONS_SET_SETUP%ACTION_TYPE)
                    CASE(EQUATIONS_SET_SETUP_START_ACTION)
                       CALL NAVIER_STOKES_EQUATIONS_SET_SOLUTION_METHOD_SET(EQUATIONS_SET, &
                        & EQUATIONS_SET_FEM_SOLUTION_METHOD,ERR,ERROR,*999)
                      EQUATIONS_SET%SOLUTION_METHOD=EQUATIONS_SET_FEM_SOLUTION_METHOD
                    CASE(EQUATIONS_SET_SETUP_FINISH_ACTION)
                      !!TODO: Check valid setup
                    CASE DEFAULT
                      LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%ACTION_TYPE, &
                        & "*",ERR,ERROR))// " for a setup type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP% &
                        & SETUP_TYPE,"*",ERR,ERROR))// " is not implemented for a Navier-Stokes fluid."
                      CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                  END SELECT
                CASE DEFAULT
                  LOCAL_ERROR="The equation set subtype of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                    & " for a setup sub type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                    & " is invalid for a Navier-Stokes equation."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            !Define geometric field 
            CASE(EQUATIONS_SET_SETUP_GEOMETRY_TYPE)
              SELECT CASE(EQUATIONS_SET%SUBTYPE)
                CASE(EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE, &
                  & EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE, &
                  & EQUATIONS_SET_PGM_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_QUASISTATIC_NAVIER_STOKES_SUBTYPE, &
                  & EQUATIONS_SET_1DTRANSIENT_NAVIER_STOKES_SUBTYPE)
                 !Do nothing???
                CASE DEFAULT
                  LOCAL_ERROR="The equation set subtype of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                    & " is invalid for a Navier-Stokes equation."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            !Define dependent field
            CASE(EQUATIONS_SET_SETUP_DEPENDENT_TYPE)
              SELECT CASE(EQUATIONS_SET%SUBTYPE)
                CASE(EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE, &
                  & EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE, &
                  & EQUATIONS_SET_PGM_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_QUASISTATIC_NAVIER_STOKES_SUBTYPE, &
                  & EQUATIONS_SET_1DTRANSIENT_NAVIER_STOKES_SUBTYPE)
                  SELECT CASE(EQUATIONS_SET_SETUP%ACTION_TYPE)
                    !Set start action
                    CASE(EQUATIONS_SET_SETUP_START_ACTION)
                      IF(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD_AUTO_CREATED) THEN
                        !Create the auto created dependent field
                        !start field creation with name 'DEPENDENT_FIELD'
                        CALL FIELD_CREATE_START(EQUATIONS_SET_SETUP%FIELD_USER_NUMBER,EQUATIONS_SET%REGION, &
                          & EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,ERR,ERROR,*999)
                        !start creation of a new field
                        CALL FIELD_TYPE_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_GENERAL_TYPE,ERR,ERROR,*999)
                        !label the field
                        CALL FIELD_LABEL_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,"Dependent Field",ERR,ERROR,*999)
                        !define new created field to be dependent
                        CALL FIELD_DEPENDENT_TYPE_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD, &
                          & FIELD_DEPENDENT_TYPE,ERR,ERROR,*999)
                        !look for decomposition rule already defined
                        CALL FIELD_MESH_DECOMPOSITION_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,GEOMETRIC_DECOMPOSITION, &
                          & ERR,ERROR,*999)
                        !apply decomposition rule found on new created field
                        CALL FIELD_MESH_DECOMPOSITION_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD, &
                          & GEOMETRIC_DECOMPOSITION,ERR,ERROR,*999)
                        !point new field to geometric field
                        CALL FIELD_GEOMETRIC_FIELD_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,EQUATIONS_SET%GEOMETRY% &
                          & GEOMETRIC_FIELD,ERR,ERROR,*999)
                        !set number of variables to 2 (1 for U and one for DELUDELN)
                        DEPENDENT_FIELD_NUMBER_OF_VARIABLES=2
                        CALL FIELD_NUMBER_OF_VARIABLES_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD, &
                          & DEPENDENT_FIELD_NUMBER_OF_VARIABLES,ERR,ERROR,*999)
                        CALL FIELD_VARIABLE_TYPES_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,(/FIELD_U_VARIABLE_TYPE, &
                          & FIELD_DELUDELN_VARIABLE_TYPE/),ERR,ERROR,*999)
                        CALL FIELD_DIMENSION_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, &
                          & FIELD_VECTOR_DIMENSION_TYPE,ERR,ERROR,*999)
                        CALL FIELD_DIMENSION_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_DELUDELN_VARIABLE_TYPE, &
                          & FIELD_VECTOR_DIMENSION_TYPE,ERR,ERROR,*999)
                        CALL FIELD_DATA_TYPE_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, &
                          & FIELD_DP_TYPE,ERR,ERROR,*999)
                        CALL FIELD_DATA_TYPE_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_DELUDELN_VARIABLE_TYPE, &
                          & FIELD_DP_TYPE,ERR,ERROR,*999)
                        CALL FIELD_NUMBER_OF_COMPONENTS_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE, &
                          & NUMBER_OF_DIMENSIONS,ERR,ERROR,*999)
                        !calculate number of components with one component for each dimension and one for pressure
                        IF(EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_1DTRANSIENT_NAVIER_STOKES_SUBTYPE) THEN
                           DEPENDENT_FIELD_NUMBER_OF_COMPONENTS=NUMBER_OF_DIMENSIONS+1
                        ELSE
                           DEPENDENT_FIELD_NUMBER_OF_COMPONENTS=NUMBER_OF_DIMENSIONS+1
                        ENDIF
                        CALL FIELD_NUMBER_OF_COMPONENTS_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD, &
                          & FIELD_U_VARIABLE_TYPE,DEPENDENT_FIELD_NUMBER_OF_COMPONENTS,ERR,ERROR,*999)
                        CALL FIELD_NUMBER_OF_COMPONENTS_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD, &
                          & FIELD_DELUDELN_VARIABLE_TYPE,DEPENDENT_FIELD_NUMBER_OF_COMPONENTS,ERR,ERROR,*999)
                        CALL FIELD_COMPONENT_MESH_COMPONENT_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE, & 
                          & 1,GEOMETRIC_MESH_COMPONENT,ERR,ERROR,*999)
                        !Default to the geometric interpolation setup
                        DO I=1,DEPENDENT_FIELD_NUMBER_OF_COMPONENTS
                          CALL FIELD_COMPONENT_MESH_COMPONENT_SET(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD, & 
                            & FIELD_U_VARIABLE_TYPE,I,GEOMETRIC_MESH_COMPONENT,ERR,ERROR,*999)
                          CALL FIELD_COMPONENT_MESH_COMPONENT_SET(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD, &
                            & FIELD_DELUDELN_VARIABLE_TYPE,I,GEOMETRIC_MESH_COMPONENT,ERR,ERROR,*999)
                        END DO
                        SELECT CASE(EQUATIONS_SET%SOLUTION_METHOD)
                          !Specify fem solution method
                          CASE(EQUATIONS_SET_FEM_SOLUTION_METHOD)
                            DO I=1,DEPENDENT_FIELD_NUMBER_OF_COMPONENTS
                              CALL FIELD_COMPONENT_INTERPOLATION_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD, &
                                & FIELD_U_VARIABLE_TYPE,I,FIELD_NODE_BASED_INTERPOLATION,ERR,ERROR,*999)
                              CALL FIELD_COMPONENT_INTERPOLATION_SET_AND_LOCK(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD, &
                                & FIELD_DELUDELN_VARIABLE_TYPE,I,FIELD_NODE_BASED_INTERPOLATION,ERR,ERROR,*999)
                            END DO
                            CALL FIELD_SCALING_TYPE_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,GEOMETRIC_SCALING_TYPE, &
                              & ERR,ERROR,*999)
                            CALL FIELD_SCALING_TYPE_SET(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,GEOMETRIC_SCALING_TYPE, &
                              & ERR,ERROR,*999)
                            !Other solutions not defined yet
                          CASE(EQUATIONS_SET_BEM_SOLUTION_METHOD)
                            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                          CASE(EQUATIONS_SET_FD_SOLUTION_METHOD)
                            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                          CASE(EQUATIONS_SET_FV_SOLUTION_METHOD)
                            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                          CASE(EQUATIONS_SET_GFEM_SOLUTION_METHOD)
                            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                          CASE(EQUATIONS_SET_GFV_SOLUTION_METHOD)
                            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                          CASE DEFAULT
                            LOCAL_ERROR="The solution method of " &
                              & //TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SOLUTION_METHOD,"*",ERR,ERROR))// " is invalid."
                            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                        END SELECT
                      ELSE 
                        !Check the user specified field
                        CALL FIELD_TYPE_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_GENERAL_TYPE,ERR,ERROR,*999)
                        CALL FIELD_DEPENDENT_TYPE_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_DEPENDENT_TYPE,ERR,ERROR,*999)
                        CALL FIELD_NUMBER_OF_VARIABLES_CHECK(EQUATIONS_SET_SETUP%FIELD,2,ERR,ERROR,*999)
                        CALL FIELD_VARIABLE_TYPES_CHECK(EQUATIONS_SET_SETUP%FIELD,(/FIELD_U_VARIABLE_TYPE, &
                          & FIELD_DELUDELN_VARIABLE_TYPE/),ERR,ERROR,*999)
                        CALL FIELD_DIMENSION_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_U_VARIABLE_TYPE, & 
                          & FIELD_VECTOR_DIMENSION_TYPE,ERR,ERROR,*999)
                        CALL FIELD_DIMENSION_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_DELUDELN_VARIABLE_TYPE, &
                          & FIELD_VECTOR_DIMENSION_TYPE,ERR,ERROR,*999)
                        CALL FIELD_DATA_TYPE_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_U_VARIABLE_TYPE,FIELD_DP_TYPE,ERR,ERROR,*999)
                        CALL FIELD_DATA_TYPE_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_DELUDELN_VARIABLE_TYPE,FIELD_DP_TYPE, &
                          & ERR,ERROR,*999)
                        CALL FIELD_NUMBER_OF_COMPONENTS_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE, &
                          & NUMBER_OF_DIMENSIONS,ERR,ERROR,*999)
                        !calculate number of components with one component for each dimension and one for pressure
                        IF(EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_1DTRANSIENT_NAVIER_STOKES_SUBTYPE) THEN
                           DEPENDENT_FIELD_NUMBER_OF_COMPONENTS=NUMBER_OF_DIMENSIONS+1
                        ELSE
                           DEPENDENT_FIELD_NUMBER_OF_COMPONENTS=NUMBER_OF_DIMENSIONS+1
                        ENDIF
                        CALL FIELD_NUMBER_OF_COMPONENTS_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_U_VARIABLE_TYPE, &
                          & DEPENDENT_FIELD_NUMBER_OF_COMPONENTS,ERR,ERROR,*999)
                        CALL FIELD_NUMBER_OF_COMPONENTS_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_DELUDELN_VARIABLE_TYPE, &
                          & DEPENDENT_FIELD_NUMBER_OF_COMPONENTS,ERR,ERROR,*999)
                        SELECT CASE(EQUATIONS_SET%SOLUTION_METHOD)
                          CASE(EQUATIONS_SET_FEM_SOLUTION_METHOD)
                            CALL FIELD_COMPONENT_INTERPOLATION_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_U_VARIABLE_TYPE,1, &
                              & FIELD_NODE_BASED_INTERPOLATION,ERR,ERROR,*999)
                            CALL FIELD_COMPONENT_INTERPOLATION_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_DELUDELN_VARIABLE_TYPE,1, &
                              & FIELD_NODE_BASED_INTERPOLATION,ERR,ERROR,*999)
                          CASE(EQUATIONS_SET_BEM_SOLUTION_METHOD)
                            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                          CASE(EQUATIONS_SET_FD_SOLUTION_METHOD)
                            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                          CASE(EQUATIONS_SET_FV_SOLUTION_METHOD)
                            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                          CASE(EQUATIONS_SET_GFEM_SOLUTION_METHOD)
                            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                          CASE(EQUATIONS_SET_GFV_SOLUTION_METHOD)
                            CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                          CASE DEFAULT
                            LOCAL_ERROR="The solution method of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SOLUTION_METHOD, &
                              & "*",ERR,ERROR))//" is invalid."
                            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                        END SELECT
                      ENDIF
                    !Specify finish action
                    CASE(EQUATIONS_SET_SETUP_FINISH_ACTION)
                      IF(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD_AUTO_CREATED) THEN
                        CALL FIELD_CREATE_FINISH(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,ERR,ERROR,*999)
                        CALL FIELD_PARAMETER_SET_CREATE(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, &
                          & FIELD_BOUNDARY_SET_TYPE,ERR,ERROR,*999)
                      ENDIF
                    CASE DEFAULT
                      LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%ACTION_TYPE,"*", & 
                        & ERR,ERROR))//" for a setup type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%SETUP_TYPE, & 
                        & "*",ERR,ERROR))//" is invalid for a Navier-Stokes fluid."
                      CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                  END SELECT
                CASE DEFAULT
                  LOCAL_ERROR="The equation set subtype of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                    & " for a setup sub type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                    & " is invalid for a Navier-Stokes equation."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            !Define independent field
            CASE(EQUATIONS_SET_SETUP_INDEPENDENT_TYPE)
              SELECT CASE(EQUATIONS_SET%SUBTYPE)
              CASE(EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_PGM_NAVIER_STOKES_SUBTYPE)
                  SELECT CASE(EQUATIONS_SET_SETUP%ACTION_TYPE)
                   !Set start action
                    CASE(EQUATIONS_SET_SETUP_START_ACTION)
                      IF(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD_AUTO_CREATED) THEN
                        !Create the auto created independent field
                        !start field creation with name 'INDEPENDENT_FIELD'
                        CALL FIELD_CREATE_START(EQUATIONS_SET_SETUP%FIELD_USER_NUMBER,EQUATIONS_SET%REGION, &
                          & EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,ERR,ERROR,*999)
                        !start creation of a new field
                        CALL FIELD_TYPE_SET_AND_LOCK(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,FIELD_GENERAL_TYPE,ERR,ERROR,*999)
                        !label the field
                        CALL FIELD_LABEL_SET_AND_LOCK(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,"Independent Field",ERR,ERROR, & 
                          & *999)
                        !define new created field to be independent
                        CALL FIELD_DEPENDENT_TYPE_SET_AND_LOCK(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD, &
                          & FIELD_INDEPENDENT_TYPE,ERR,ERROR,*999)
                        !look for decomposition rule already defined
                        CALL FIELD_MESH_DECOMPOSITION_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,GEOMETRIC_DECOMPOSITION, &
                          & ERR,ERROR,*999)
                        !apply decomposition rule found on new created field
                        CALL FIELD_MESH_DECOMPOSITION_SET_AND_LOCK(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD, &
                          & GEOMETRIC_DECOMPOSITION,ERR,ERROR,*999)
                        !point new field to geometric field
                        CALL FIELD_GEOMETRIC_FIELD_SET_AND_LOCK(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,EQUATIONS_SET% & 
                          & GEOMETRY%GEOMETRIC_FIELD,ERR,ERROR,*999)
                        !set number of variables to 1 (1 for U)
                        INDEPENDENT_FIELD_NUMBER_OF_VARIABLES=1
                        CALL FIELD_NUMBER_OF_VARIABLES_SET_AND_LOCK(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD, &
                        & INDEPENDENT_FIELD_NUMBER_OF_VARIABLES,ERR,ERROR,*999)
                        CALL FIELD_VARIABLE_TYPES_SET_AND_LOCK(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD, & 
                          & (/FIELD_U_VARIABLE_TYPE/),ERR,ERROR,*999)
                        CALL FIELD_DIMENSION_SET_AND_LOCK(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, &
                          & FIELD_VECTOR_DIMENSION_TYPE,ERR,ERROR,*999)
                        CALL FIELD_DATA_TYPE_SET_AND_LOCK(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, &
                          & FIELD_DP_TYPE,ERR,ERROR,*999)
                        CALL FIELD_NUMBER_OF_COMPONENTS_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE, &
                          & NUMBER_OF_DIMENSIONS,ERR,ERROR,*999)
                        !calculate number of components with one component for each dimension
                        INDEPENDENT_FIELD_NUMBER_OF_COMPONENTS=NUMBER_OF_DIMENSIONS
                        CALL FIELD_NUMBER_OF_COMPONENTS_SET_AND_LOCK(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD, & 
                          & FIELD_U_VARIABLE_TYPE,INDEPENDENT_FIELD_NUMBER_OF_COMPONENTS,ERR,ERROR,*999)
                        CALL FIELD_COMPONENT_MESH_COMPONENT_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE, & 
                          & 1,GEOMETRIC_MESH_COMPONENT,ERR,ERROR,*999)
                        !Default to the geometric interpolation setup
                        DO I=1,INDEPENDENT_FIELD_NUMBER_OF_COMPONENTS
                          CALL FIELD_COMPONENT_MESH_COMPONENT_SET(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD, & 
                            & FIELD_U_VARIABLE_TYPE,I,GEOMETRIC_MESH_COMPONENT,ERR,ERROR,*999)
                        END DO
                        SELECT CASE(EQUATIONS_SET%SOLUTION_METHOD)
                          !Specify fem solution method
                          CASE(EQUATIONS_SET_FEM_SOLUTION_METHOD)
                            DO I=1,INDEPENDENT_FIELD_NUMBER_OF_COMPONENTS
                              CALL FIELD_COMPONENT_INTERPOLATION_SET_AND_LOCK(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD, &
                              & FIELD_U_VARIABLE_TYPE,I,FIELD_NODE_BASED_INTERPOLATION,ERR,ERROR,*999)
                            END DO
                            CALL FIELD_SCALING_TYPE_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,GEOMETRIC_SCALING_TYPE, &
                              & ERR,ERROR,*999)
                            CALL FIELD_SCALING_TYPE_SET(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,GEOMETRIC_SCALING_TYPE, &
                              & ERR,ERROR,*999)
                            !Other solutions not defined yet
                          CASE DEFAULT
                            LOCAL_ERROR="The solution method of " &
                              & //TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SOLUTION_METHOD,"*",ERR,ERROR))// " is invalid."
                            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                        END SELECT 
                      ELSE
                        !Check the user specified field
                        CALL FIELD_TYPE_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_GENERAL_TYPE,ERR,ERROR,*999)
                        CALL FIELD_DEPENDENT_TYPE_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_INDEPENDENT_TYPE,ERR,ERROR,*999)
                        CALL FIELD_NUMBER_OF_VARIABLES_CHECK(EQUATIONS_SET_SETUP%FIELD,1,ERR,ERROR,*999)
                        CALL FIELD_VARIABLE_TYPES_CHECK(EQUATIONS_SET_SETUP%FIELD,(/FIELD_U_VARIABLE_TYPE/),ERR,ERROR,*999)
                        CALL FIELD_DIMENSION_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_U_VARIABLE_TYPE,FIELD_VECTOR_DIMENSION_TYPE, &
                          & ERR,ERROR,*999)
                        CALL FIELD_DATA_TYPE_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_U_VARIABLE_TYPE,FIELD_DP_TYPE,ERR,ERROR,*999)
                        CALL FIELD_NUMBER_OF_COMPONENTS_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE, &
                          & NUMBER_OF_DIMENSIONS,ERR,ERROR,*999)
                        !calculate number of components with one component for each dimension and one for pressure
                        INDEPENDENT_FIELD_NUMBER_OF_COMPONENTS=NUMBER_OF_DIMENSIONS
                        CALL FIELD_NUMBER_OF_COMPONENTS_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_U_VARIABLE_TYPE, &
                          & INDEPENDENT_FIELD_NUMBER_OF_COMPONENTS,ERR,ERROR,*999)
                        SELECT CASE(EQUATIONS_SET%SOLUTION_METHOD)
                          CASE(EQUATIONS_SET_FEM_SOLUTION_METHOD)
                            CALL FIELD_COMPONENT_INTERPOLATION_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_U_VARIABLE_TYPE,1, &
                              & FIELD_NODE_BASED_INTERPOLATION,ERR,ERROR,*999)
                            CALL FIELD_COMPONENT_INTERPOLATION_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_DELUDELN_VARIABLE_TYPE,1, &
                              & FIELD_NODE_BASED_INTERPOLATION,ERR,ERROR,*999)
                          CASE DEFAULT
                            LOCAL_ERROR="The solution method of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SOLUTION_METHOD, &
                              &"*",ERR,ERROR))//" is invalid."
                             CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                        END SELECT

                      ENDIF    
                    !Specify finish action
                    CASE(EQUATIONS_SET_SETUP_FINISH_ACTION)
                      IF(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD_AUTO_CREATED) THEN
                        CALL FIELD_CREATE_FINISH(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,ERR,ERROR,*999)
                        CALL FIELD_PARAMETER_SET_CREATE(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, &
                           & FIELD_MESH_DISPLACEMENT_SET_TYPE,ERR,ERROR,*999)
                        CALL FIELD_PARAMETER_SET_CREATE(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, &
                           & FIELD_MESH_VELOCITY_SET_TYPE,ERR,ERROR,*999)
                        CALL FIELD_PARAMETER_SET_CREATE(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, &
                          & FIELD_BOUNDARY_SET_TYPE,ERR,ERROR,*999)
                      ENDIF
                    CASE DEFAULT
                      LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                      & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                      & " is invalid for a standard Navier-Stokes fluid"
                      CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                  END SELECT
                CASE DEFAULT
                  LOCAL_ERROR="The equation set subtype of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                    & " for a setup sub type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                    & " is invalid for a Navier-Stokes equation."
                   CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            !Define analytic field  
            CASE(EQUATIONS_SET_SETUP_ANALYTIC_TYPE)
              SELECT CASE(EQUATIONS_SET%SUBTYPE)
                CASE(EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE, &
                  & EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_QUASISTATIC_NAVIER_STOKES_SUBTYPE, &
                  & EQUATIONS_SET_1DTRANSIENT_NAVIER_STOKES_SUBTYPE)
                  SELECT CASE(EQUATIONS_SET_SETUP%ACTION_TYPE)
                    !Set start action
                    CASE(EQUATIONS_SET_SETUP_START_ACTION)
                      IF(EQUATIONS_SET%DEPENDENT%DEPENDENT_FINISHED) THEN
                        IF(ASSOCIATED(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD)) THEN
                          IF(ASSOCIATED(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD)) THEN
                            CALL FIELD_NUMBER_OF_COMPONENTS_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE, & 
                              & NUMBER_OF_DIMENSIONS,ERR,ERROR,*999)
                            SELECT CASE(EQUATIONS_SET_SETUP%ANALYTIC_FUNCTION_TYPE)
                              CASE(EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_1)
                                !Set analtyic function type
                                EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE=EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_1
                              CASE(EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_2)
                                !Set analtyic function type
                                EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE=EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_2
                              CASE(EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_3)
                                !Set analtyic function type
                                EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE=EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_3
                              CASE(EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_4)
                                !Set analtyic function type
                                EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE=EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_4
                              CASE(EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_5)
                                !Set analtyic function type
                                EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE=EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_5
                              CASE(EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_1)
                                !Set analtyic function type
                                EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE=EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_1
                              CASE(EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_2)
                                !Set analtyic function type
                                EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE=EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_2
                              CASE(EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_3)
                                !Set analtyic function type
                                EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE=EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_3
                              CASE(EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_4)
                                !Set analtyic function type
                                EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE=EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_4
                              CASE(EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_5)
                                !Set analtyic function type
                                EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE=EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_5
                              CASE(EQUATIONS_SET_NAVIER_STOKES_EQUATION_ONE_DIM_1)
                                !Set analtyic function type
                                EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE=EQUATIONS_SET_NAVIER_STOKES_EQUATION_ONE_DIM_1
                              CASE DEFAULT
                                LOCAL_ERROR="The specified analytic function type of "// &
                                  & TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%ANALYTIC_FUNCTION_TYPE,"*",ERR,ERROR))// &
                                  & " is invalid for an analytic Navier-Stokes problem."
                                CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                            END SELECT
                          ELSE
                            CALL FLAG_ERROR("Equations set geometric field is not associated.",ERR,ERROR,*999)
                          ENDIF
                        ELSE
                          CALL FLAG_ERROR("Equations set dependent field is not associated.",ERR,ERROR,*999)
                        ENDIF
                      ELSE
                        CALL FLAG_ERROR("Equations set dependent field has not been finished.",ERR,ERROR,*999)
                      ENDIF
                    CASE(EQUATIONS_SET_SETUP_FINISH_ACTION)
                      IF(ASSOCIATED(EQUATIONS_SET%ANALYTIC)) THEN
                        IF(ASSOCIATED(EQUATIONS_SET%ANALYTIC%ANALYTIC_FIELD)) THEN
                          IF(EQUATIONS_SET%ANALYTIC%ANALYTIC_FIELD_AUTO_CREATED) THEN
                            CALL FIELD_CREATE_FINISH(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,ERR,ERROR,*999)
                          ENDIF
                        ENDIF
                      ELSE
                        CALL FLAG_ERROR("Equations set analytic is not associated.",ERR,ERROR,*999)
                      ENDIF
                    CASE DEFAULT
                      LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                        & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                        & " is invalid for an analytic Navier-Stokes problem."
                      CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                    END SELECT
                  CASE DEFAULT
                    LOCAL_ERROR="The equation set subtype of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                      & " for a setup sub type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                      & " is invalid for a Navier-Stokes equation."
                     CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                END SELECT
            !Define materials field
            CASE(EQUATIONS_SET_SETUP_MATERIALS_TYPE)
              SELECT CASE(EQUATIONS_SET%SUBTYPE)
                CASE(EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE, &
                  & EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE, &
                  & EQUATIONS_SET_PGM_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_QUASISTATIC_NAVIER_STOKES_SUBTYPE, &
                  & EQUATIONS_SET_1DTRANSIENT_NAVIER_STOKES_SUBTYPE)
                  !variable X with has Y components, here Y represents viscosity only
                  MATERIAL_FIELD_NUMBER_OF_VARIABLES=1!X
                  IF(EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_1DTRANSIENT_NAVIER_STOKES_SUBTYPE) THEN
                    MATERIAL_FIELD_NUMBER_OF_COMPONENTS=6!Y
                  ELSE
                    MATERIAL_FIELD_NUMBER_OF_COMPONENTS=2!Y
                  ENDIF
                  SELECT CASE(EQUATIONS_SET_SETUP%ACTION_TYPE)
                    !Specify start action
                    CASE(EQUATIONS_SET_SETUP_START_ACTION)
                      EQUATIONS_MATERIALS=>EQUATIONS_SET%MATERIALS
                      IF(ASSOCIATED(EQUATIONS_MATERIALS)) THEN
                        IF(EQUATIONS_MATERIALS%MATERIALS_FIELD_AUTO_CREATED) THEN
                          !Create the auto created materials field
                          !start field creation with name 'MATERIAL_FIELD'
                          CALL FIELD_CREATE_START(EQUATIONS_SET_SETUP%FIELD_USER_NUMBER,EQUATIONS_SET%REGION, & 
                            & EQUATIONS_SET%MATERIALS%MATERIALS_FIELD,ERR,ERROR,*999)
                          CALL FIELD_TYPE_SET_AND_LOCK(EQUATIONS_MATERIALS%MATERIALS_FIELD,FIELD_MATERIAL_TYPE,ERR,ERROR,*999)
                          !label the field
                          CALL FIELD_LABEL_SET_AND_LOCK(EQUATIONS_MATERIALS%MATERIALS_FIELD,"Materials Field",ERR,ERROR,*999)
                          CALL FIELD_DEPENDENT_TYPE_SET_AND_LOCK(EQUATIONS_MATERIALS%MATERIALS_FIELD,FIELD_INDEPENDENT_TYPE, &
                            & ERR,ERROR,*999)
                          CALL FIELD_MESH_DECOMPOSITION_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,GEOMETRIC_DECOMPOSITION, & 
                            & ERR,ERROR,*999)
                          !apply decomposition rule found on new created field
                          CALL FIELD_MESH_DECOMPOSITION_SET_AND_LOCK(EQUATIONS_SET%MATERIALS%MATERIALS_FIELD, & 
                            & GEOMETRIC_DECOMPOSITION,ERR,ERROR,*999)
                          !point new field to geometric field
                          CALL FIELD_GEOMETRIC_FIELD_SET_AND_LOCK(EQUATIONS_MATERIALS%MATERIALS_FIELD,EQUATIONS_SET%GEOMETRY% &
                            & GEOMETRIC_FIELD,ERR,ERROR,*999)
                          CALL FIELD_NUMBER_OF_VARIABLES_SET(EQUATIONS_MATERIALS%MATERIALS_FIELD, & 
                            & MATERIAL_FIELD_NUMBER_OF_VARIABLES,ERR,ERROR,*999)
                          CALL FIELD_VARIABLE_TYPES_SET_AND_LOCK(EQUATIONS_MATERIALS%MATERIALS_FIELD, & 
                            &(/FIELD_U_VARIABLE_TYPE/),ERR,ERROR,*999)
                          CALL FIELD_DIMENSION_SET_AND_LOCK(EQUATIONS_MATERIALS%MATERIALS_FIELD,FIELD_U_VARIABLE_TYPE, &
                            & FIELD_VECTOR_DIMENSION_TYPE,ERR,ERROR,*999)
                          CALL FIELD_DATA_TYPE_SET_AND_LOCK(EQUATIONS_MATERIALS%MATERIALS_FIELD,FIELD_U_VARIABLE_TYPE, &
                            & FIELD_DP_TYPE,ERR,ERROR,*999)
                          CALL FIELD_NUMBER_OF_COMPONENTS_SET_AND_LOCK(EQUATIONS_MATERIALS%MATERIALS_FIELD, & 
                            & FIELD_U_VARIABLE_TYPE,MATERIAL_FIELD_NUMBER_OF_COMPONENTS,ERR,ERROR,*999)
                          CALL FIELD_COMPONENT_MESH_COMPONENT_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD, & 
                            & FIELD_U_VARIABLE_TYPE,1,GEOMETRIC_COMPONENT_NUMBER,ERR,ERROR,*999)
                          CALL FIELD_COMPONENT_MESH_COMPONENT_SET(EQUATIONS_MATERIALS%MATERIALS_FIELD,FIELD_U_VARIABLE_TYPE, &
                            & 1,GEOMETRIC_COMPONENT_NUMBER,ERR,ERROR,*999)
                          CALL FIELD_COMPONENT_INTERPOLATION_SET(EQUATIONS_MATERIALS%MATERIALS_FIELD,FIELD_U_VARIABLE_TYPE, &
                            & 1,FIELD_CONSTANT_INTERPOLATION,ERR,ERROR,*999)
                          CALL FIELD_COMPONENT_INTERPOLATION_SET(EQUATIONS_MATERIALS%MATERIALS_FIELD,FIELD_U_VARIABLE_TYPE, &
                            & 2,FIELD_CONSTANT_INTERPOLATION,ERR,ERROR,*999)
                          !Default the field scaling to that of the geometric field
                          CALL FIELD_SCALING_TYPE_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,GEOMETRIC_SCALING_TYPE, & 
                            & ERR,ERROR,*999)
                          CALL FIELD_SCALING_TYPE_SET(EQUATIONS_MATERIALS%MATERIALS_FIELD,GEOMETRIC_SCALING_TYPE,ERR,ERROR,*999)
                       ELSE
                          !Check the user specified field
                          CALL FIELD_TYPE_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_MATERIAL_TYPE,ERR,ERROR,*999)
                          CALL FIELD_DEPENDENT_TYPE_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_INDEPENDENT_TYPE,ERR,ERROR,*999)
                          CALL FIELD_NUMBER_OF_VARIABLES_CHECK(EQUATIONS_SET_SETUP%FIELD,1,ERR,ERROR,*999)
                          CALL FIELD_VARIABLE_TYPES_CHECK(EQUATIONS_SET_SETUP%FIELD,(/FIELD_U_VARIABLE_TYPE/),ERR,ERROR,*999)
                          CALL FIELD_DIMENSION_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_U_VARIABLE_TYPE, & 
                            & FIELD_VECTOR_DIMENSION_TYPE,ERR,ERROR,*999)
                          CALL FIELD_DATA_TYPE_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_U_VARIABLE_TYPE,FIELD_DP_TYPE, & 
                            & ERR,ERROR,*999)
                          CALL FIELD_NUMBER_OF_COMPONENTS_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE, &
                            & NUMBER_OF_DIMENSIONS,ERR,ERROR,*999)
                          CALL FIELD_NUMBER_OF_COMPONENTS_CHECK(EQUATIONS_SET_SETUP%FIELD,FIELD_U_VARIABLE_TYPE,1,ERR,ERROR,*999)
                        ENDIF
                      ELSE
                        CALL FLAG_ERROR("Equations set materials is not associated.",ERR,ERROR,*999)
                      END IF
                    !Specify start action
                    CASE(EQUATIONS_SET_SETUP_FINISH_ACTION)
                      EQUATIONS_MATERIALS=>EQUATIONS_SET%MATERIALS
                        IF(ASSOCIATED(EQUATIONS_MATERIALS)) THEN
                          IF(EQUATIONS_MATERIALS%MATERIALS_FIELD_AUTO_CREATED) THEN
                            !Finish creating the materials field
                              CALL FIELD_CREATE_FINISH(EQUATIONS_MATERIALS%MATERIALS_FIELD,ERR,ERROR,*999)
                              !Set the default values for the materials field
                              !First set the mu values to 0.001
                              !MATERIAL_FIELD_NUMBER_OF_COMPONENTS
                              ! viscosity=1
                              CALL FIELD_COMPONENT_VALUES_INITIALISE(EQUATIONS_MATERIALS%MATERIALS_FIELD,FIELD_U_VARIABLE_TYPE, &
                                & FIELD_VALUES_SET_TYPE,1,1.0_DP,ERR,ERROR,*999)
                              ! density=2
                              CALL FIELD_COMPONENT_VALUES_INITIALISE(EQUATIONS_MATERIALS%MATERIALS_FIELD,FIELD_U_VARIABLE_TYPE, &
                                & FIELD_VALUES_SET_TYPE,2,1.0_DP,ERR,ERROR,*999)

                              IF(EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_1DTRANSIENT_NAVIER_STOKES_SUBTYPE) THEN
                              ! elasticity=3
                              CALL FIELD_COMPONENT_VALUES_INITIALISE(EQUATIONS_MATERIALS%MATERIALS_FIELD,FIELD_U_VARIABLE_TYPE, &
                                & FIELD_VALUES_SET_TYPE,3,1.0_DP,ERR,ERROR,*999)
                              ! thickness=4
                              CALL FIELD_COMPONENT_VALUES_INITIALISE(EQUATIONS_MATERIALS%MATERIALS_FIELD,FIELD_U_VARIABLE_TYPE, &
                                & FIELD_VALUES_SET_TYPE,4,1.0_DP,ERR,ERROR,*999)
                              ! area=5
                              CALL FIELD_COMPONENT_VALUES_INITIALISE(EQUATIONS_MATERIALS%MATERIALS_FIELD,FIELD_U_VARIABLE_TYPE, &
                                & FIELD_VALUES_SET_TYPE,5,1.0_DP,ERR,ERROR,*999)
                              ! sigma=6
                              CALL FIELD_COMPONENT_VALUES_INITIALISE(EQUATIONS_MATERIALS%MATERIALS_FIELD,FIELD_U_VARIABLE_TYPE, &
                                & FIELD_VALUES_SET_TYPE,6,1.0_DP,ERR,ERROR,*999)
                              ENDIF

                            ENDIF
                          ELSE
                            CALL FLAG_ERROR("Equations set materials is not associated.",ERR,ERROR,*999)
                          ENDIF
                    CASE DEFAULT
                      LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%ACTION_TYPE,"*", & 
                        & ERR,ERROR))//" for a setup type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%SETUP_TYPE,"*", & 
                        & ERR,ERROR))//" is invalid for Navier-Stokes equation."
                      CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                  END SELECT
                CASE DEFAULT
                  LOCAL_ERROR="The equation set subtype of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                    & " for a setup sub type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                    & " is invalid for a Navier-Stokes equation."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            !Define source field
            CASE(EQUATIONS_SET_SETUP_SOURCE_TYPE)
              SELECT CASE(EQUATIONS_SET%SUBTYPE)
                CASE(EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE, &
                  & EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE, & 
                  & EQUATIONS_SET_PGM_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_QUASISTATIC_NAVIER_STOKES_SUBTYPE, &
                  & EQUATIONS_SET_1DTRANSIENT_NAVIER_STOKES_SUBTYPE)
!\todo: Think about gravity
                  SELECT CASE(EQUATIONS_SET_SETUP%ACTION_TYPE)
                    CASE(EQUATIONS_SET_SETUP_START_ACTION)
                      !Do nothing
                    CASE(EQUATIONS_SET_SETUP_FINISH_ACTION)
                      !Do nothing
                      !? Maybe set finished flag????
                    CASE DEFAULT
                      LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%ACTION_TYPE,"*", &
                        & ERR,ERROR))//" for a setup type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%SETUP_TYPE,"*", & 
                        & ERR,ERROR))//" is invalid for a Navier-Stokes fluid."
                      CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                  END SELECT
                CASE DEFAULT
                  LOCAL_ERROR="The equation set subtype of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                    &  " for a setup sub type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                    &  " is invalid for a Navier-Stokes equation."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            !Equations type 
            CASE(EQUATIONS_SET_SETUP_EQUATIONS_TYPE)
              SELECT CASE(EQUATIONS_SET%SUBTYPE)
                CASE(EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE)
                  SELECT CASE(EQUATIONS_SET_SETUP%ACTION_TYPE)
                    CASE(EQUATIONS_SET_SETUP_START_ACTION)
                      EQUATIONS_MATERIALS=>EQUATIONS_SET%MATERIALS
                      IF(ASSOCIATED(EQUATIONS_MATERIALS)) THEN              
                        IF(EQUATIONS_MATERIALS%MATERIALS_FINISHED) THEN
                          CALL EQUATIONS_CREATE_START(EQUATIONS_SET,EQUATIONS,ERR,ERROR,*999)
                          CALL EQUATIONS_LINEARITY_TYPE_SET(EQUATIONS,EQUATIONS_NONLINEAR,ERR,ERROR,*999)
                          CALL EQUATIONS_TIME_DEPENDENCE_TYPE_SET(EQUATIONS,EQUATIONS_STATIC,ERR,ERROR,*999)
                        ELSE
                          CALL FLAG_ERROR("Equations set materials has not been finished.",ERR,ERROR,*999)
                        ENDIF
                      ELSE
                        CALL FLAG_ERROR("Equations materials is not associated.",ERR,ERROR,*999)
                      ENDIF
                    CASE(EQUATIONS_SET_SETUP_FINISH_ACTION)
                      SELECT CASE(EQUATIONS_SET%SOLUTION_METHOD)
                        CASE(EQUATIONS_SET_FEM_SOLUTION_METHOD)
                          !Finish the creation of the equations
                          CALL EQUATIONS_SET_EQUATIONS_GET(EQUATIONS_SET,EQUATIONS,ERR,ERROR,*999)
                          CALL EQUATIONS_CREATE_FINISH(EQUATIONS,ERR,ERROR,*999)
                          !Create the equations mapping.
                          CALL EQUATIONS_MAPPING_CREATE_START(EQUATIONS,EQUATIONS_MAPPING,ERR,ERROR,*999)
                          CALL EQUATIONS_MAPPING_LINEAR_MATRICES_NUMBER_SET(EQUATIONS_MAPPING,1,ERR,ERROR,*999)
                          CALL EQUATIONS_MAPPING_LINEAR_MATRICES_VARIABLE_TYPES_SET(EQUATIONS_MAPPING,(/FIELD_U_VARIABLE_TYPE/), &
                            & ERR,ERROR,*999)
                          CALL EQUATIONS_MAPPING_RHS_VARIABLE_TYPE_SET(EQUATIONS_MAPPING,FIELD_DELUDELN_VARIABLE_TYPE, & 
                            & ERR,ERROR,*999)
                          CALL EQUATIONS_MAPPING_CREATE_FINISH(EQUATIONS_MAPPING,ERR,ERROR,*999)
                          !Create the equations matrices
                          CALL EQUATIONS_MATRICES_CREATE_START(EQUATIONS,EQUATIONS_MATRICES,ERR,ERROR,*999)
                          SELECT CASE(EQUATIONS%SPARSITY_TYPE)
                            CASE(EQUATIONS_MATRICES_FULL_MATRICES)
                              CALL EQUATIONS_MATRICES_LINEAR_STORAGE_TYPE_SET(EQUATIONS_MATRICES,(/MATRIX_BLOCK_STORAGE_TYPE/), &
                                & ERR,ERROR,*999)
                              CALL EQUATIONS_MATRICES_NONLINEAR_STORAGE_TYPE_SET(EQUATIONS_MATRICES,MATRIX_BLOCK_STORAGE_TYPE, &
                                & ERR,ERROR,*999)
                            CASE(EQUATIONS_MATRICES_SPARSE_MATRICES)
                              CALL EQUATIONS_MATRICES_LINEAR_STORAGE_TYPE_SET(EQUATIONS_MATRICES, & 
                                & (/MATRIX_COMPRESSED_ROW_STORAGE_TYPE/),ERR,ERROR,*999)
                              CALL EQUATIONS_MATRICES_NONLINEAR_STORAGE_TYPE_SET(EQUATIONS_MATRICES, & 
                                & MATRIX_COMPRESSED_ROW_STORAGE_TYPE,ERR,ERROR,*999)
                              CALL EQUATIONS_MATRICES_LINEAR_STRUCTURE_TYPE_SET(EQUATIONS_MATRICES, & 
                                & (/EQUATIONS_MATRIX_FEM_STRUCTURE/),ERR,ERROR,*999)
                              CALL EQUATIONS_MATRICES_NONLINEAR_STRUCTURE_TYPE_SET(EQUATIONS_MATRICES, & 
                                & EQUATIONS_MATRIX_FEM_STRUCTURE,ERR,ERROR,*999)
                            CASE DEFAULT
                              LOCAL_ERROR="The equations matrices sparsity type of "// &
                                & TRIM(NUMBER_TO_VSTRING(EQUATIONS%SPARSITY_TYPE,"*",ERR,ERROR))//" is invalid."
                              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                          END SELECT
                          CALL EQUATIONS_MATRICES_CREATE_FINISH(EQUATIONS_MATRICES,ERR,ERROR,*999)
                        CASE(EQUATIONS_SET_BEM_SOLUTION_METHOD)
                          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                        CASE(EQUATIONS_SET_FD_SOLUTION_METHOD)
                          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                        CASE(EQUATIONS_SET_FV_SOLUTION_METHOD)
                          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                        CASE(EQUATIONS_SET_GFEM_SOLUTION_METHOD)
                          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                        CASE(EQUATIONS_SET_GFV_SOLUTION_METHOD)
                          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                        CASE DEFAULT
                          LOCAL_ERROR="The solution method of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SOLUTION_METHOD, &
                            & "*",ERR,ERROR))//" is invalid."
                          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                      END SELECT
                    CASE DEFAULT
                      LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                        & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                        & " is invalid for a steady Laplace equation."
                      CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                  END SELECT
                CASE(EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE, & 
                  & EQUATIONS_SET_PGM_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_1DTRANSIENT_NAVIER_STOKES_SUBTYPE)
                  SELECT CASE(EQUATIONS_SET_SETUP%ACTION_TYPE)
                    CASE(EQUATIONS_SET_SETUP_START_ACTION)
                      EQUATIONS_MATERIALS=>EQUATIONS_SET%MATERIALS
                      IF(ASSOCIATED(EQUATIONS_MATERIALS)) THEN              
                        IF(EQUATIONS_MATERIALS%MATERIALS_FINISHED) THEN
                          CALL EQUATIONS_CREATE_START(EQUATIONS_SET,EQUATIONS,ERR,ERROR,*999)
                          CALL EQUATIONS_LINEARITY_TYPE_SET(EQUATIONS,EQUATIONS_NONLINEAR,ERR,ERROR,*999)
                          CALL EQUATIONS_TIME_DEPENDENCE_TYPE_SET(EQUATIONS,EQUATIONS_FIRST_ORDER_DYNAMIC,ERR,ERROR,*999)
                        ELSE
                          CALL FLAG_ERROR("Equations set materials has not been finished.",ERR,ERROR,*999)
                        ENDIF
                      ELSE
                        CALL FLAG_ERROR("Equations materials is not associated.",ERR,ERROR,*999)
                      ENDIF
                    CASE(EQUATIONS_SET_SETUP_FINISH_ACTION)
                      SELECT CASE(EQUATIONS_SET%SOLUTION_METHOD)
                        CASE(EQUATIONS_SET_FEM_SOLUTION_METHOD)
                          !Finish the creation of the equations
                          CALL EQUATIONS_SET_EQUATIONS_GET(EQUATIONS_SET,EQUATIONS,ERR,ERROR,*999)
                          CALL EQUATIONS_CREATE_FINISH(EQUATIONS,ERR,ERROR,*999)
                          !Create the equations mapping.
                          CALL EQUATIONS_MAPPING_CREATE_START(EQUATIONS,EQUATIONS_MAPPING,ERR,ERROR,*999)
!                          CALL EQUATIONS_MAPPING_LINEAR_MATRICES_NUMBER_SET(EQUATIONS_MAPPING,1,ERR,ERROR,*999)
!                          CALL EQUATIONS_MAPPING_LINEAR_MATRICES_VARIABLE_TYPES_SET(EQUATIONS_MAPPING,(/FIELD_U_VARIABLE_TYPE/), &
!                            & ERR,ERROR,*999)
                          CALL EQUATIONS_MAPPING_RESIDUAL_VARIABLE_TYPES_SET(EQUATIONS_MAPPING,[FIELD_U_VARIABLE_TYPE], &
                            & ERR,ERROR,*999)
                          CALL EQUATIONS_MAPPING_DYNAMIC_MATRICES_SET(EQUATIONS_MAPPING,.TRUE.,.TRUE.,ERR,ERROR,*999)
                          CALL EQUATIONS_MAPPING_DYNAMIC_VARIABLE_TYPE_SET(EQUATIONS_MAPPING,FIELD_U_VARIABLE_TYPE,ERR,ERROR,*999)
                          CALL EQUATIONS_MAPPING_RHS_VARIABLE_TYPE_SET(EQUATIONS_MAPPING,FIELD_DELUDELN_VARIABLE_TYPE,ERR, & 
                            & ERROR,*999)
                          CALL EQUATIONS_MAPPING_CREATE_FINISH(EQUATIONS_MAPPING,ERR,ERROR,*999)
                          !Create the equations matrices
                          CALL EQUATIONS_MATRICES_CREATE_START(EQUATIONS,EQUATIONS_MATRICES,ERR,ERROR,*999)
                          SELECT CASE(EQUATIONS%SPARSITY_TYPE)
                            CASE(EQUATIONS_MATRICES_FULL_MATRICES)
                              CALL EQUATIONS_MATRICES_DYNAMIC_STORAGE_TYPE_SET(EQUATIONS_MATRICES,[MATRIX_BLOCK_STORAGE_TYPE, &
                                & MATRIX_BLOCK_STORAGE_TYPE],ERR,ERROR,*999)
                              CALL EQUATIONS_MATRICES_NONLINEAR_STORAGE_TYPE_SET(EQUATIONS_MATRICES,MATRIX_BLOCK_STORAGE_TYPE, &
                                & ERR,ERROR,*999)
                            CASE(EQUATIONS_MATRICES_SPARSE_MATRICES)
                              CALL EQUATIONS_MATRICES_DYNAMIC_STORAGE_TYPE_SET(EQUATIONS_MATRICES, &
                                & (/DISTRIBUTED_MATRIX_COMPRESSED_ROW_STORAGE_TYPE, & 
                                & DISTRIBUTED_MATRIX_COMPRESSED_ROW_STORAGE_TYPE/),ERR,ERROR,*999)
                              CALL EQUATIONS_MATRICES_DYNAMIC_STRUCTURE_TYPE_SET(EQUATIONS_MATRICES, &
                                & (/EQUATIONS_MATRIX_FEM_STRUCTURE,EQUATIONS_MATRIX_FEM_STRUCTURE/),ERR,ERROR,*999)
!                               CALL EQUATIONS_MATRICES_LINEAR_STORAGE_TYPE_SET(EQUATIONS_MATRICES, & 
!                                 & (/MATRIX_COMPRESSED_ROW_STORAGE_TYPE/),ERR,ERROR,*999)
                              CALL EQUATIONS_MATRICES_NONLINEAR_STORAGE_TYPE_SET(EQUATIONS_MATRICES, & 
                                & MATRIX_COMPRESSED_ROW_STORAGE_TYPE,ERR,ERROR,*999)
!                               CALL EQUATIONS_MATRICES_LINEAR_STRUCTURE_TYPE_SET(EQUATIONS_MATRICES, & 
!                                 & (/EQUATIONS_MATRIX_FEM_STRUCTURE/),ERR,ERROR,*999)
                              CALL EQUATIONS_MATRICES_NONLINEAR_STRUCTURE_TYPE_SET(EQUATIONS_MATRICES, & 
                                & EQUATIONS_MATRIX_FEM_STRUCTURE,ERR,ERROR,*999)
                            CASE DEFAULT
                              LOCAL_ERROR="The equations matrices sparsity type of "// &
                                & TRIM(NUMBER_TO_VSTRING(EQUATIONS%SPARSITY_TYPE,"*",ERR,ERROR))//" is invalid."
                              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                          END SELECT
                          CALL EQUATIONS_MATRICES_CREATE_FINISH(EQUATIONS_MATRICES,ERR,ERROR,*999)
                        CASE(EQUATIONS_SET_BEM_SOLUTION_METHOD)
                          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                        CASE(EQUATIONS_SET_FD_SOLUTION_METHOD)
                          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                        CASE(EQUATIONS_SET_FV_SOLUTION_METHOD)
                          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                        CASE(EQUATIONS_SET_GFEM_SOLUTION_METHOD)
                          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                        CASE(EQUATIONS_SET_GFV_SOLUTION_METHOD)
                          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                        CASE DEFAULT
                          LOCAL_ERROR="The solution method of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SOLUTION_METHOD, &
                            & "*",ERR,ERROR))//" is invalid."
                          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                      END SELECT
                    CASE DEFAULT
                      LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                        & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                        & " is invalid for a steady Laplace equation."
                      CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                  END SELECT
                CASE(EQUATIONS_SET_QUASISTATIC_NAVIER_STOKES_SUBTYPE)
                  SELECT CASE(EQUATIONS_SET_SETUP%ACTION_TYPE)
                    CASE(EQUATIONS_SET_SETUP_START_ACTION)
                      EQUATIONS_MATERIALS=>EQUATIONS_SET%MATERIALS
                      IF(ASSOCIATED(EQUATIONS_MATERIALS)) THEN              
                        IF(EQUATIONS_MATERIALS%MATERIALS_FINISHED) THEN
                          CALL EQUATIONS_CREATE_START(EQUATIONS_SET,EQUATIONS,ERR,ERROR,*999)
                          CALL EQUATIONS_LINEARITY_TYPE_SET(EQUATIONS,EQUATIONS_NONLINEAR,ERR,ERROR,*999)
                          CALL EQUATIONS_TIME_DEPENDENCE_TYPE_SET(EQUATIONS,EQUATIONS_QUASISTATIC,ERR,ERROR,*999)
                        ELSE
                          CALL FLAG_ERROR("Equations set materials has not been finished.",ERR,ERROR,*999)
                        ENDIF
                      ELSE
                        CALL FLAG_ERROR("Equations materials is not associated.",ERR,ERROR,*999)
                      ENDIF
                    CASE(EQUATIONS_SET_SETUP_FINISH_ACTION)
                      SELECT CASE(EQUATIONS_SET%SOLUTION_METHOD)
                        CASE(EQUATIONS_SET_FEM_SOLUTION_METHOD)
                          !Finish the creation of the equations
                          CALL EQUATIONS_SET_EQUATIONS_GET(EQUATIONS_SET,EQUATIONS,ERR,ERROR,*999)
                          CALL EQUATIONS_CREATE_FINISH(EQUATIONS,ERR,ERROR,*999)
                          !Create the equations mapping.
                          CALL EQUATIONS_MAPPING_CREATE_START(EQUATIONS,EQUATIONS_MAPPING,ERR,ERROR,*999)
                          CALL EQUATIONS_MAPPING_LINEAR_MATRICES_NUMBER_SET(EQUATIONS_MAPPING,1,ERR,ERROR,*999)
                          CALL EQUATIONS_MAPPING_LINEAR_MATRICES_VARIABLE_TYPES_SET(EQUATIONS_MAPPING,(/FIELD_U_VARIABLE_TYPE/), &
                            & ERR,ERROR,*999)
                          CALL EQUATIONS_MAPPING_RHS_VARIABLE_TYPE_SET(EQUATIONS_MAPPING,FIELD_DELUDELN_VARIABLE_TYPE, & 
                            & ERR,ERROR,*999)
                          CALL EQUATIONS_MAPPING_CREATE_FINISH(EQUATIONS_MAPPING,ERR,ERROR,*999)
                          !Create the equations matrices
                          CALL EQUATIONS_MATRICES_CREATE_START(EQUATIONS,EQUATIONS_MATRICES,ERR,ERROR,*999)
                          SELECT CASE(EQUATIONS%SPARSITY_TYPE)
                            CASE(EQUATIONS_MATRICES_FULL_MATRICES)
                              CALL EQUATIONS_MATRICES_LINEAR_STORAGE_TYPE_SET(EQUATIONS_MATRICES,(/MATRIX_BLOCK_STORAGE_TYPE/), &
                                & ERR,ERROR,*999)
                              CALL EQUATIONS_MATRICES_NONLINEAR_STORAGE_TYPE_SET(EQUATIONS_MATRICES,MATRIX_BLOCK_STORAGE_TYPE, &
                                & ERR,ERROR,*999)
                            CASE(EQUATIONS_MATRICES_SPARSE_MATRICES)
                              CALL EQUATIONS_MATRICES_LINEAR_STORAGE_TYPE_SET(EQUATIONS_MATRICES, & 
                                & (/MATRIX_COMPRESSED_ROW_STORAGE_TYPE/),ERR,ERROR,*999)
                              CALL EQUATIONS_MATRICES_NONLINEAR_STORAGE_TYPE_SET(EQUATIONS_MATRICES, & 
                                & MATRIX_COMPRESSED_ROW_STORAGE_TYPE,ERR,ERROR,*999)
                              CALL EQUATIONS_MATRICES_LINEAR_STRUCTURE_TYPE_SET(EQUATIONS_MATRICES, & 
                                & (/EQUATIONS_MATRIX_FEM_STRUCTURE/),ERR,ERROR,*999)
                              CALL EQUATIONS_MATRICES_NONLINEAR_STRUCTURE_TYPE_SET(EQUATIONS_MATRICES, & 
                                & EQUATIONS_MATRIX_FEM_STRUCTURE,ERR,ERROR,*999)
                            CASE DEFAULT
                              LOCAL_ERROR="The equations matrices sparsity type of "// &
                                & TRIM(NUMBER_TO_VSTRING(EQUATIONS%SPARSITY_TYPE,"*",ERR,ERROR))//" is invalid."
                              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                          END SELECT
                          CALL EQUATIONS_MATRICES_CREATE_FINISH(EQUATIONS_MATRICES,ERR,ERROR,*999)
                        CASE(EQUATIONS_SET_BEM_SOLUTION_METHOD)
                          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                        CASE(EQUATIONS_SET_FD_SOLUTION_METHOD)
                          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                        CASE(EQUATIONS_SET_FV_SOLUTION_METHOD)
                          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                        CASE(EQUATIONS_SET_GFEM_SOLUTION_METHOD)
                          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                        CASE(EQUATIONS_SET_GFV_SOLUTION_METHOD)
                          CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                        CASE DEFAULT
                          LOCAL_ERROR="The solution method of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SOLUTION_METHOD, &
                            & "*",ERR,ERROR))//" is invalid."
                          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                      END SELECT
                    CASE DEFAULT
                      LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                        & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                        & " is invalid for a steady Laplace equation."
                      CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                  END SELECT
                CASE DEFAULT
                  LOCAL_ERROR="The equation set subtype of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                    & " for a setup sub type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                    & " is invalid for a Navier-Stokes equation."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE DEFAULT
              LOCAL_ERROR="The setup type of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                & " is invalid for a Navier-Stokes fluid."
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        CASE DEFAULT
          LOCAL_ERROR="The equations set subtype of "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
            & " does not equal a Navier-Stokes fluid subtype."
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      END SELECT
    ELSE
      CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
    ENDIF

    CALL EXITS("NAVIER_STOKES_EQUATIONS_SET_SETUP")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_EQUATIONS_SET_SETUP",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_EQUATIONS_SET_SETUP")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_EQUATIONS_SET_SETUP

! 
!================================================================================================================================
!

  !>Sets/changes the problem subtype for a Navier-Stokes fluid type .
  SUBROUTINE NAVIER_STOKES_PROBLEM_SUBTYPE_SET(PROBLEM,PROBLEM_SUBTYPE,ERR,ERROR,*)

    !Argument variables
    TYPE(PROBLEM_TYPE), POINTER :: PROBLEM !<A pointer to the problem to set the problem subtype for
    INTEGER(INTG), INTENT(IN) :: PROBLEM_SUBTYPE !<The problem subtype to set
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("NAVIER_STOKES_PROBLEM_SUBTYPE_SET",ERR,ERROR,*999)

    IF(ASSOCIATED(PROBLEM)) THEN
      SELECT CASE(PROBLEM_SUBTYPE)
      CASE(PROBLEM_STATIC_NAVIER_STOKES_SUBTYPE)
        PROBLEM%CLASS=PROBLEM_FLUID_MECHANICS_CLASS
        PROBLEM%TYPE=PROBLEM_NAVIER_STOKES_EQUATION_TYPE
        PROBLEM%SUBTYPE=PROBLEM_STATIC_NAVIER_STOKES_SUBTYPE
      CASE(PROBLEM_LAPLACE_NAVIER_STOKES_SUBTYPE)
        PROBLEM%CLASS=PROBLEM_FLUID_MECHANICS_CLASS
        PROBLEM%TYPE=PROBLEM_NAVIER_STOKES_EQUATION_TYPE
        PROBLEM%SUBTYPE=PROBLEM_LAPLACE_NAVIER_STOKES_SUBTYPE
      CASE(PROBLEM_TRANSIENT_NAVIER_STOKES_SUBTYPE)
        PROBLEM%CLASS=PROBLEM_FLUID_MECHANICS_CLASS
        PROBLEM%TYPE=PROBLEM_NAVIER_STOKES_EQUATION_TYPE
        PROBLEM%SUBTYPE=PROBLEM_TRANSIENT_NAVIER_STOKES_SUBTYPE
      CASE(PROBLEM_1DTRANSIENT_NAVIER_STOKES_SUBTYPE)
        PROBLEM%CLASS=PROBLEM_FLUID_MECHANICS_CLASS
        PROBLEM%TYPE=PROBLEM_NAVIER_STOKES_EQUATION_TYPE
        PROBLEM%SUBTYPE=PROBLEM_1DTRANSIENT_NAVIER_STOKES_SUBTYPE
      CASE(PROBLEM_QUASISTATIC_NAVIER_STOKES_SUBTYPE)
        PROBLEM%CLASS=PROBLEM_FLUID_MECHANICS_CLASS
        PROBLEM%TYPE=PROBLEM_NAVIER_STOKES_EQUATION_TYPE
        PROBLEM%SUBTYPE=PROBLEM_QUASISTATIC_NAVIER_STOKES_SUBTYPE
      CASE(PROBLEM_ALE_NAVIER_STOKES_SUBTYPE)
        PROBLEM%CLASS=PROBLEM_FLUID_MECHANICS_CLASS
        PROBLEM%TYPE=PROBLEM_NAVIER_STOKES_EQUATION_TYPE
        PROBLEM%SUBTYPE=PROBLEM_ALE_NAVIER_STOKES_SUBTYPE
      CASE(PROBLEM_PGM_NAVIER_STOKES_SUBTYPE)
        PROBLEM%CLASS=PROBLEM_FLUID_MECHANICS_CLASS
        PROBLEM%TYPE=PROBLEM_NAVIER_STOKES_EQUATION_TYPE
        PROBLEM%SUBTYPE=PROBLEM_PGM_NAVIER_STOKES_SUBTYPE
      CASE(PROBLEM_OPTIMISED_NAVIER_STOKES_SUBTYPE)
        CALL FLAG_ERROR("Not implemented yet.",ERR,ERROR,*999)
      CASE DEFAULT
        LOCAL_ERROR="Problem subtype "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SUBTYPE,"*",ERR,ERROR))// &
          & " is not valid for a Navier-Stokes fluid type of a fluid mechanics problem class."
        CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      END SELECT
    ELSE
      CALL FLAG_ERROR("Problem is not associated.",ERR,ERROR,*999)
    ENDIF

    CALL EXITS("NAVIER_STOKES_PROBLEM_SUBTYPE_SET")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_PROBLEM_SUBTYPE_SET",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_PROBLEM_SUBTYPE_SET")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_PROBLEM_SUBTYPE_SET

! 
!================================================================================================================================
!
  
  !>Sets up the Navier-Stokes problem.
  SUBROUTINE NAVIER_STOKES_PROBLEM_SETUP(PROBLEM,PROBLEM_SETUP,ERR,ERROR,*)

    !Argument variables
    TYPE(PROBLEM_TYPE), POINTER :: PROBLEM !<A pointer to the problem set to setup a Navier-Stokes fluid on.
    TYPE(PROBLEM_SETUP_TYPE), INTENT(INOUT) :: PROBLEM_SETUP !<The problem setup information
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP,CONTROL_LOOP_ROOT
    TYPE(SOLVER_TYPE), POINTER :: SOLVER, MESH_SOLVER
    TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: SOLVER_EQUATIONS,MESH_SOLVER_EQUATIONS
    TYPE(SOLVERS_TYPE), POINTER :: SOLVERS


    CALL ENTERS("NAVIER_STOKES_PROBLEM_SETUP",ERR,ERROR,*999)

    NULLIFY(CONTROL_LOOP)
    NULLIFY(SOLVER)
    NULLIFY(MESH_SOLVER)
    NULLIFY(SOLVER_EQUATIONS)
    NULLIFY(MESH_SOLVER_EQUATIONS)
    NULLIFY(SOLVERS)
    IF(ASSOCIATED(PROBLEM)) THEN
      SELECT CASE(PROBLEM%SUBTYPE)
        !All steady state cases of Navier-Stokes
        CASE(PROBLEM_STATIC_NAVIER_STOKES_SUBTYPE,PROBLEM_LAPLACE_NAVIER_STOKES_SUBTYPE)
          SELECT CASE(PROBLEM_SETUP%SETUP_TYPE)
            CASE(PROBLEM_SETUP_INITIAL_TYPE)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Do nothing????
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Do nothing???
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(PROBLEM_SETUP_CONTROL_TYPE)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Set up a simple control loop
                  CALL CONTROL_LOOP_CREATE_START(PROBLEM,CONTROL_LOOP,ERR,ERROR,*999)
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Finish the control loops
                  CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
                  CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
                  CALL CONTROL_LOOP_CREATE_FINISH(CONTROL_LOOP,ERR,ERROR,*999)
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(PROBLEM_SETUP_SOLVERS_TYPE)
              !Get the control loop
              CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
              CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Start the solvers creation
                  CALL SOLVERS_CREATE_START(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  CALL SOLVERS_NUMBER_SET(SOLVERS,1,ERR,ERROR,*999)
                  !Set the solver to be a nonlinear solver
                  CALL SOLVERS_SOLVER_GET(SOLVERS,1,SOLVER,ERR,ERROR,*999)
                  CALL SOLVER_TYPE_SET(SOLVER,SOLVER_NONLINEAR_TYPE,ERR,ERROR,*999)
                  !Set solver defaults
                  CALL SOLVER_LIBRARY_TYPE_SET(SOLVER,SOLVER_PETSC_LIBRARY,ERR,ERROR,*999)
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Get the solvers
                  CALL CONTROL_LOOP_SOLVERS_GET(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  !Finish the solvers creation
                  CALL SOLVERS_CREATE_FINISH(SOLVERS,ERR,ERROR,*999)
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(PROBLEM_SETUP_SOLVER_EQUATIONS_TYPE)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Get the control loop
                  CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
                  CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
                  !Get the solver
                  CALL CONTROL_LOOP_SOLVERS_GET(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  CALL SOLVERS_SOLVER_GET(SOLVERS,1,SOLVER,ERR,ERROR,*999)
                  !Create the solver equations
                  CALL SOLVER_EQUATIONS_CREATE_START(SOLVER,SOLVER_EQUATIONS,ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_LINEARITY_TYPE_SET(SOLVER_EQUATIONS,SOLVER_EQUATIONS_NONLINEAR,ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_TIME_DEPENDENCE_TYPE_SET(SOLVER_EQUATIONS,SOLVER_EQUATIONS_STATIC,ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_SPARSITY_TYPE_SET(SOLVER_EQUATIONS,SOLVER_SPARSE_MATRICES,ERR,ERROR,*999)
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Get the control loop
                  CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
                  CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
                  !Get the solver equations
                  CALL CONTROL_LOOP_SOLVERS_GET(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  CALL SOLVERS_SOLVER_GET(SOLVERS,1,SOLVER,ERR,ERROR,*999)
                  CALL SOLVER_SOLVER_EQUATIONS_GET(SOLVER,SOLVER_EQUATIONS,ERR,ERROR,*999)
                  !Finish the solver equations creation
                  CALL SOLVER_EQUATIONS_CREATE_FINISH(SOLVER_EQUATIONS,ERR,ERROR,*999)
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE DEFAULT
              LOCAL_ERROR="The setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                & " is invalid for a Navier-Stokes fluid."
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        !Transient cases and moving mesh
        CASE(PROBLEM_TRANSIENT_NAVIER_STOKES_SUBTYPE,PROBLEM_PGM_NAVIER_STOKES_SUBTYPE)
          SELECT CASE(PROBLEM_SETUP%SETUP_TYPE)
            CASE(PROBLEM_SETUP_INITIAL_TYPE)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Do nothing????
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Do nothing???
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a transient Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(PROBLEM_SETUP_CONTROL_TYPE)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Set up a time control loop
                  CALL CONTROL_LOOP_CREATE_START(PROBLEM,CONTROL_LOOP,ERR,ERROR,*999)
                  CALL CONTROL_LOOP_TYPE_SET(CONTROL_LOOP,PROBLEM_CONTROL_TIME_LOOP_TYPE,ERR,ERROR,*999)
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Finish the control loops
                  CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
                  CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
                  CALL CONTROL_LOOP_CREATE_FINISH(CONTROL_LOOP,ERR,ERROR,*999)
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a transient Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(PROBLEM_SETUP_SOLVERS_TYPE)
              !Get the control loop
              CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
              CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Start the solvers creation
                  CALL SOLVERS_CREATE_START(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  CALL SOLVERS_NUMBER_SET(SOLVERS,1,ERR,ERROR,*999)
                  !Set the solver to be a first order dynamic solver 
                  CALL SOLVERS_SOLVER_GET(SOLVERS,1,SOLVER,ERR,ERROR,*999)
                  CALL SOLVER_TYPE_SET(SOLVER,SOLVER_DYNAMIC_TYPE,ERR,ERROR,*999)
                  CALL SOLVER_DYNAMIC_LINEARITY_TYPE_SET(SOLVER,SOLVER_DYNAMIC_NONLINEAR,ERR,ERROR,*999)
                  CALL SOLVER_DYNAMIC_ORDER_SET(SOLVER,SOLVER_DYNAMIC_FIRST_ORDER,ERR,ERROR,*999)
                  !Set solver defaults
                  CALL SOLVER_DYNAMIC_DEGREE_SET(SOLVER,SOLVER_DYNAMIC_FIRST_DEGREE,ERR,ERROR,*999)
                  CALL SOLVER_DYNAMIC_SCHEME_SET(SOLVER,SOLVER_DYNAMIC_CRANK_NICOLSON_SCHEME,ERR,ERROR,*999)
                  CALL SOLVER_LIBRARY_TYPE_SET(SOLVER,SOLVER_CMISS_LIBRARY,ERR,ERROR,*999)
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Get the solvers
                  CALL CONTROL_LOOP_SOLVERS_GET(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  !Finish the solvers creation
                  CALL SOLVERS_CREATE_FINISH(SOLVERS,ERR,ERROR,*999)
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a transient Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(PROBLEM_SETUP_SOLVER_EQUATIONS_TYPE)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Get the control loop
                  CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
                  CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
                  !Get the solver
                  CALL CONTROL_LOOP_SOLVERS_GET(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  CALL SOLVERS_SOLVER_GET(SOLVERS,1,SOLVER,ERR,ERROR,*999)
                  !Create the solver equations
                  CALL SOLVER_EQUATIONS_CREATE_START(SOLVER,SOLVER_EQUATIONS,ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_LINEARITY_TYPE_SET(SOLVER_EQUATIONS,SOLVER_EQUATIONS_NONLINEAR,ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_TIME_DEPENDENCE_TYPE_SET(SOLVER_EQUATIONS,SOLVER_EQUATIONS_FIRST_ORDER_DYNAMIC,&
                  & ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_SPARSITY_TYPE_SET(SOLVER_EQUATIONS,SOLVER_SPARSE_MATRICES,ERR,ERROR,*999)
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Get the control loop
                  CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
                  CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
                  !Get the solver equations
                  CALL CONTROL_LOOP_SOLVERS_GET(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  CALL SOLVERS_SOLVER_GET(SOLVERS,1,SOLVER,ERR,ERROR,*999)
                  CALL SOLVER_SOLVER_EQUATIONS_GET(SOLVER,SOLVER_EQUATIONS,ERR,ERROR,*999)
                  !Finish the solver equations creation
                  CALL SOLVER_EQUATIONS_CREATE_FINISH(SOLVER_EQUATIONS,ERR,ERROR,*999)
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE DEFAULT
              LOCAL_ERROR="The setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                & " is invalid for a transient Navier-Stokes fluid."
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT

        !1DTransient Navier-Stokes
        CASE(PROBLEM_1DTRANSIENT_NAVIER_STOKES_SUBTYPE)
          SELECT CASE(PROBLEM_SETUP%SETUP_TYPE)
            CASE(PROBLEM_SETUP_INITIAL_TYPE)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Do nothing????
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Do nothing???
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a 1d transient Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(PROBLEM_SETUP_CONTROL_TYPE)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Set up a time control loop
                  CALL CONTROL_LOOP_CREATE_START(PROBLEM,CONTROL_LOOP,ERR,ERROR,*999)
                  CALL CONTROL_LOOP_TYPE_SET(CONTROL_LOOP,PROBLEM_CONTROL_TIME_LOOP_TYPE,ERR,ERROR,*999)
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Finish the control loops
                  CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
                  CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
                  CALL CONTROL_LOOP_CREATE_FINISH(CONTROL_LOOP,ERR,ERROR,*999)
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a 1d transient Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(PROBLEM_SETUP_SOLVERS_TYPE)
              !Get the control loop
              CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
              CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Start the solvers creation
                  CALL SOLVERS_CREATE_START(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  CALL SOLVERS_NUMBER_SET(SOLVERS,1,ERR,ERROR,*999)
                  !Set the solver to be a first order dynamic solver
                  CALL SOLVERS_SOLVER_GET(SOLVERS,1,SOLVER,ERR,ERROR,*999)
                  CALL SOLVER_TYPE_SET(SOLVER,SOLVER_DYNAMIC_TYPE,ERR,ERROR,*999)
                  CALL SOLVER_DYNAMIC_LINEARITY_TYPE_SET(SOLVER,SOLVER_DYNAMIC_NONLINEAR,ERR,ERROR,*999)
                  CALL SOLVER_DYNAMIC_ORDER_SET(SOLVER,SOLVER_DYNAMIC_FIRST_ORDER,ERR,ERROR,*999)
                  !Set solver defaults
                  CALL SOLVER_DYNAMIC_DEGREE_SET(SOLVER,SOLVER_DYNAMIC_FIRST_DEGREE,ERR,ERROR,*999)
 !                 CALL SOLVER_DYNAMIC_SCHEME_SET(SOLVER,SOLVER_DYNAMIC_CRANK_NICHOLSON_SCHEME,ERR,ERROR,*999)
                  CALL SOLVER_LIBRARY_TYPE_SET(SOLVER,SOLVER_CMISS_LIBRARY,ERR,ERROR,*999)
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Get the solvers
                  CALL CONTROL_LOOP_SOLVERS_GET(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  !Finish the solvers creation
                  CALL SOLVERS_CREATE_FINISH(SOLVERS,ERR,ERROR,*999)
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a 1d transient Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(PROBLEM_SETUP_SOLVER_EQUATIONS_TYPE)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Get the control loop
                  CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
                  CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
                  !Get the solver
                  CALL CONTROL_LOOP_SOLVERS_GET(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  CALL SOLVERS_SOLVER_GET(SOLVERS,1,SOLVER,ERR,ERROR,*999)
                  !Create the solver equations
                  CALL SOLVER_EQUATIONS_CREATE_START(SOLVER,SOLVER_EQUATIONS,ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_LINEARITY_TYPE_SET(SOLVER_EQUATIONS,SOLVER_EQUATIONS_NONLINEAR,ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_TIME_DEPENDENCE_TYPE_SET(SOLVER_EQUATIONS,SOLVER_EQUATIONS_FIRST_ORDER_DYNAMIC,&
                  & ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_SPARSITY_TYPE_SET(SOLVER_EQUATIONS,SOLVER_SPARSE_MATRICES,ERR,ERROR,*999)
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Get the control loop
                  CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
                  CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
                  !Get the solver equations
                  CALL CONTROL_LOOP_SOLVERS_GET(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  CALL SOLVERS_SOLVER_GET(SOLVERS,1,SOLVER,ERR,ERROR,*999)
                  CALL SOLVER_SOLVER_EQUATIONS_GET(SOLVER,SOLVER_EQUATIONS,ERR,ERROR,*999)
                  !Finish the solver equations creation
                  CALL SOLVER_EQUATIONS_CREATE_FINISH(SOLVER_EQUATIONS,ERR,ERROR,*999)
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE DEFAULT
              LOCAL_ERROR="The setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                & " is invalid for a 1d transient Navier-Stokes fluid."
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT

        !Quasi-static Navier-Stokes
        CASE(PROBLEM_QUASISTATIC_NAVIER_STOKES_SUBTYPE)
          SELECT CASE(PROBLEM_SETUP%SETUP_TYPE)
            CASE(PROBLEM_SETUP_INITIAL_TYPE)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Do nothing????
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Do nothing???
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a quasistatic Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(PROBLEM_SETUP_CONTROL_TYPE)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Set up a time control loop
                  CALL CONTROL_LOOP_CREATE_START(PROBLEM,CONTROL_LOOP,ERR,ERROR,*999)
                  CALL CONTROL_LOOP_TYPE_SET(CONTROL_LOOP,PROBLEM_CONTROL_TIME_LOOP_TYPE,ERR,ERROR,*999)
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Finish the control loops
                  CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
                  CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
                  CALL CONTROL_LOOP_CREATE_FINISH(CONTROL_LOOP,ERR,ERROR,*999)
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a quasistatic Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(PROBLEM_SETUP_SOLVERS_TYPE)
              !Get the control loop
              CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
              CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
              CASE(PROBLEM_SETUP_START_ACTION)
                !Start the solvers creation
                CALL SOLVERS_CREATE_START(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                CALL SOLVERS_NUMBER_SET(SOLVERS,1,ERR,ERROR,*999)
                !Set the solver to be a nonlinear solver
                CALL SOLVERS_SOLVER_GET(SOLVERS,1,SOLVER,ERR,ERROR,*999)
                CALL SOLVER_TYPE_SET(SOLVER,SOLVER_NONLINEAR_TYPE,ERR,ERROR,*999)
                !Set solver defaults
                CALL SOLVER_LIBRARY_TYPE_SET(SOLVER,SOLVER_PETSC_LIBRARY,ERR,ERROR,*999)
              CASE(PROBLEM_SETUP_FINISH_ACTION)
                !Get the solvers
                CALL CONTROL_LOOP_SOLVERS_GET(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                !Finish the solvers creation
                CALL SOLVERS_CREATE_FINISH(SOLVERS,ERR,ERROR,*999)
              CASE DEFAULT
                LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                  & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                  & " is invalid for a quasistatic Navier-Stokes equation."
                CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(PROBLEM_SETUP_SOLVER_EQUATIONS_TYPE)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Get the control loop
                  CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
                  CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
                  !Get the solver
                  CALL CONTROL_LOOP_SOLVERS_GET(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  CALL SOLVERS_SOLVER_GET(SOLVERS,1,SOLVER,ERR,ERROR,*999)
                  !Create the solver equations
                  CALL SOLVER_EQUATIONS_CREATE_START(SOLVER,SOLVER_EQUATIONS,ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_LINEARITY_TYPE_SET(SOLVER_EQUATIONS,SOLVER_EQUATIONS_NONLINEAR,ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_TIME_DEPENDENCE_TYPE_SET(SOLVER_EQUATIONS,SOLVER_EQUATIONS_QUASISTATIC,ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_SPARSITY_TYPE_SET(SOLVER_EQUATIONS,SOLVER_SPARSE_MATRICES,ERR,ERROR,*999)
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Get the control loop
                  CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
                  CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
                  !Get the solver equations
                  CALL CONTROL_LOOP_SOLVERS_GET(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  CALL SOLVERS_SOLVER_GET(SOLVERS,1,SOLVER,ERR,ERROR,*999)
                  CALL SOLVER_SOLVER_EQUATIONS_GET(SOLVER,SOLVER_EQUATIONS,ERR,ERROR,*999)
                  !Finish the solver equations creation
                  CALL SOLVER_EQUATIONS_CREATE_FINISH(SOLVER_EQUATIONS,ERR,ERROR,*999)             
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a quasistatic Navier-Stokes equation."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                END SELECT
            CASE DEFAULT
              LOCAL_ERROR="The setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                & " is invalid for a quasistatic Navier-Stokes fluid."
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        !Navier-Stokes ALE cases
        CASE(PROBLEM_ALE_NAVIER_STOKES_SUBTYPE)
          SELECT CASE(PROBLEM_SETUP%SETUP_TYPE)
            CASE(PROBLEM_SETUP_INITIAL_TYPE)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Do nothing????
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Do nothing????
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a ALE Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(PROBLEM_SETUP_CONTROL_TYPE)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Set up a time control loop
                  CALL CONTROL_LOOP_CREATE_START(PROBLEM,CONTROL_LOOP,ERR,ERROR,*999)
                  CALL CONTROL_LOOP_TYPE_SET(CONTROL_LOOP,PROBLEM_CONTROL_TIME_LOOP_TYPE,ERR,ERROR,*999)
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Finish the control loops
                  CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
                  CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
                  CALL CONTROL_LOOP_CREATE_FINISH(CONTROL_LOOP,ERR,ERROR,*999)            
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a ALE Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(PROBLEM_SETUP_SOLVERS_TYPE)
              !Get the control loop
              CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
              CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Start the solvers creation
                  CALL SOLVERS_CREATE_START(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  CALL SOLVERS_NUMBER_SET(SOLVERS,2,ERR,ERROR,*999)
                  !Set the first solver to be a linear solver for the Laplace mesh movement problem
                  CALL SOLVERS_SOLVER_GET(SOLVERS,1,MESH_SOLVER,ERR,ERROR,*999)
                  CALL SOLVER_TYPE_SET(MESH_SOLVER,SOLVER_LINEAR_TYPE,ERR,ERROR,*999)
                  !Set solver defaults
                  CALL SOLVER_LIBRARY_TYPE_SET(MESH_SOLVER,SOLVER_PETSC_LIBRARY,ERR,ERROR,*999)
                  !Set the solver to be a first order dynamic solver 
                  CALL SOLVERS_SOLVER_GET(SOLVERS,2,SOLVER,ERR,ERROR,*999)
                  CALL SOLVER_TYPE_SET(SOLVER,SOLVER_DYNAMIC_TYPE,ERR,ERROR,*999)
                  CALL SOLVER_DYNAMIC_LINEARITY_TYPE_SET(SOLVER,SOLVER_DYNAMIC_NONLINEAR,ERR,ERROR,*999)
                  CALL SOLVER_DYNAMIC_ORDER_SET(SOLVER,SOLVER_DYNAMIC_FIRST_ORDER,ERR,ERROR,*999)
                  !Set solver defaults
                  CALL SOLVER_DYNAMIC_DEGREE_SET(SOLVER,SOLVER_DYNAMIC_FIRST_DEGREE,ERR,ERROR,*999)
                  CALL SOLVER_DYNAMIC_SCHEME_SET(SOLVER,SOLVER_DYNAMIC_CRANK_NICOLSON_SCHEME,ERR,ERROR,*999)
                  CALL SOLVER_LIBRARY_TYPE_SET(SOLVER,SOLVER_CMISS_LIBRARY,ERR,ERROR,*999)
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Get the solvers
                  CALL CONTROL_LOOP_SOLVERS_GET(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  !Finish the solvers creation
                  CALL SOLVERS_CREATE_FINISH(SOLVERS,ERR,ERROR,*999)
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a ALE Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE(PROBLEM_SETUP_SOLVER_EQUATIONS_TYPE)
              SELECT CASE(PROBLEM_SETUP%ACTION_TYPE)
                CASE(PROBLEM_SETUP_START_ACTION)
                  !Get the control loop
                  CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
                  CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
                  !Get the solver
                  CALL CONTROL_LOOP_SOLVERS_GET(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  CALL SOLVERS_SOLVER_GET(SOLVERS,1,MESH_SOLVER,ERR,ERROR,*999)
                  !Create the solver equations
                  CALL SOLVER_EQUATIONS_CREATE_START(MESH_SOLVER,MESH_SOLVER_EQUATIONS,ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_LINEARITY_TYPE_SET(MESH_SOLVER_EQUATIONS,SOLVER_EQUATIONS_LINEAR,ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_TIME_DEPENDENCE_TYPE_SET(MESH_SOLVER_EQUATIONS,SOLVER_EQUATIONS_STATIC,ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_SPARSITY_TYPE_SET(MESH_SOLVER_EQUATIONS,SOLVER_SPARSE_MATRICES,ERR,ERROR,*999)
                  CALL SOLVERS_SOLVER_GET(SOLVERS,2,SOLVER,ERR,ERROR,*999)
                  !Create the solver equations
                  CALL SOLVER_EQUATIONS_CREATE_START(SOLVER,SOLVER_EQUATIONS,ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_LINEARITY_TYPE_SET(SOLVER_EQUATIONS,SOLVER_EQUATIONS_NONLINEAR,ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_TIME_DEPENDENCE_TYPE_SET(SOLVER_EQUATIONS,SOLVER_EQUATIONS_FIRST_ORDER_DYNAMIC,&
                  & ERR,ERROR,*999)
                  CALL SOLVER_EQUATIONS_SPARSITY_TYPE_SET(SOLVER_EQUATIONS,SOLVER_SPARSE_MATRICES,ERR,ERROR,*999)
                CASE(PROBLEM_SETUP_FINISH_ACTION)
                  !Get the control loop
                  CONTROL_LOOP_ROOT=>PROBLEM%CONTROL_LOOP
                  CALL CONTROL_LOOP_GET(CONTROL_LOOP_ROOT,CONTROL_LOOP_NODE,CONTROL_LOOP,ERR,ERROR,*999)
                  !Get the solver equations
                  CALL CONTROL_LOOP_SOLVERS_GET(CONTROL_LOOP,SOLVERS,ERR,ERROR,*999)
                  CALL SOLVERS_SOLVER_GET(SOLVERS,1,MESH_SOLVER,ERR,ERROR,*999)
                  CALL SOLVER_SOLVER_EQUATIONS_GET(MESH_SOLVER,MESH_SOLVER_EQUATIONS,ERR,ERROR,*999)
                  !Finish the solver equations creation
                  CALL SOLVER_EQUATIONS_CREATE_FINISH(MESH_SOLVER_EQUATIONS,ERR,ERROR,*999)             

                  CALL SOLVERS_SOLVER_GET(SOLVERS,2,SOLVER,ERR,ERROR,*999)
                  CALL SOLVER_SOLVER_EQUATIONS_GET(SOLVER,SOLVER_EQUATIONS,ERR,ERROR,*999)
                  !Finish the solver equations creation
                  CALL SOLVER_EQUATIONS_CREATE_FINISH(SOLVER_EQUATIONS,ERR,ERROR,*999)             
                CASE DEFAULT
                  LOCAL_ERROR="The action type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%ACTION_TYPE,"*",ERR,ERROR))// &
                    & " for a setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                    & " is invalid for a Navier-Stokes fluid."
                  CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
              END SELECT
            CASE DEFAULT
              LOCAL_ERROR="The setup type of "//TRIM(NUMBER_TO_VSTRING(PROBLEM_SETUP%SETUP_TYPE,"*",ERR,ERROR))// &
                & " is invalid for a ALE Navier-Stokes fluid."
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        CASE DEFAULT
          LOCAL_ERROR="Problem subtype "//TRIM(NUMBER_TO_VSTRING(PROBLEM%SUBTYPE,"*",ERR,ERROR))// &
            & " is not valid for a Navier-Stokes equation type of a fluid mechanics problem class."
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      END SELECT
    ELSE
      CALL FLAG_ERROR("Problem is not associated.",ERR,ERROR,*999)
    ENDIF

    CALL EXITS("NAVIER_STOKES_PROBLEM_SETUP")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_PROBLEM_SETUP",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_PROBLEM_SETUP")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_PROBLEM_SETUP

  !
  !================================================================================================================================
  !

  !>Evaluates the residual element stiffness matrices and RHS for a Navier-Stokes equation finite element equations set.
  SUBROUTINE NAVIER_STOKES_FINITE_ELEMENT_RESIDUAL_EVALUATE(EQUATIONS_SET,ELEMENT_NUMBER,ERR,ERROR,*)

    !Argument variables
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set to perform the finite element calculations on
    INTEGER(INTG), INTENT(IN) :: ELEMENT_NUMBER !<The element number to calculate
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) FIELD_VAR_TYPE,ng,mh,mhs,mi,ms,nh,nhs,ni,ns,MESH_COMPONENT1,MESH_COMPONENT2, nhs_max, mhs_max, nhs_min, mhs_min
    REAL(DP) :: JGW,SUM,DXI_DX(3,3),PHIMS,PHINS,MU_PARAM,RHO_PARAM,E_PARAM,H0_PARAM,A0_PARAM,SIGMA_PARAM, &
              & DPHIMS_DXI(3),DPHINS_DXI(3),X(3)
    REAL(DP), POINTER :: BIF_VALUES(:)
    TYPE(BASIS_TYPE), POINTER :: DEPENDENT_BASIS,DEPENDENT_BASIS1,DEPENDENT_BASIS2,GEOMETRIC_BASIS,INDEPENDENT_BASIS
    TYPE(EQUATIONS_TYPE), POINTER :: EQUATIONS
    TYPE(EQUATIONS_MAPPING_TYPE), POINTER :: EQUATIONS_MAPPING
    LOGICAL :: UPDATE_STIFFNESS_MATRIX, UPDATE_DAMPING_MATRIX,UPDATE_RHS_VECTOR,UPDATE_NONLINEAR_RESIDUAL
    TYPE(EQUATIONS_MAPPING_LINEAR_TYPE), POINTER :: LINEAR_MAPPING
    TYPE(EQUATIONS_MAPPING_DYNAMIC_TYPE), POINTER :: DYNAMIC_MAPPING
    TYPE(EQUATIONS_MAPPING_NONLINEAR_TYPE), POINTER :: NONLINEAR_MAPPING
    TYPE(EQUATIONS_MATRICES_TYPE), POINTER :: EQUATIONS_MATRICES
    TYPE(EQUATIONS_MATRICES_LINEAR_TYPE), POINTER :: LINEAR_MATRICES
    TYPE(EQUATIONS_MATRICES_DYNAMIC_TYPE), POINTER :: DYNAMIC_MATRICES
    TYPE(EQUATIONS_MATRICES_NONLINEAR_TYPE), POINTER :: NONLINEAR_MATRICES
    TYPE(EQUATIONS_MATRICES_RHS_TYPE), POINTER :: RHS_VECTOR
!    TYPE(EQUATIONS_MATRICES_SOURCE_TYPE), POINTER :: SOURCE_VECTOR
    TYPE(EQUATIONS_MATRIX_TYPE), POINTER :: STIFFNESS_MATRIX, DAMPING_MATRIX
    TYPE(FIELD_TYPE), POINTER :: DEPENDENT_FIELD,GEOMETRIC_FIELD,MATERIALS_FIELD,INDEPENDENT_FIELD
    TYPE(FIELD_VARIABLE_TYPE), POINTER :: FIELD_VARIABLE
    TYPE(QUADRATURE_SCHEME_TYPE), POINTER :: QUADRATURE_SCHEME,QUADRATURE_SCHEME1,QUADRATURE_SCHEME2
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    INTEGER(INTG) :: xv,out
    TYPE(ELEMENT_MATRIX_TYPE) :: ELEMENT_MATRIX
!    LOGICAL :: GRADIENT_TRANSPOSE
!    REAL(DP) :: test(89,89),test2(89,89),scaling,square

!\todo: Check whether or not too much time is spent with the different matrix types

    REAL(DP) :: AG_MATRIX(256,256) ! "A" Matrix ("G"radient part) - maximum size allocated
    REAL(DP) :: AL_MATRIX(256,256) ! "A" Matrix ("L"aplace part) - maximum size allocated
    REAL(DP) :: ALE_MATRIX(256,256) ! "A"rbitrary "L"agrangian "E"ulerian Matrix - maximum size allocated
    REAL(DP) :: BT_MATRIX(256,256) ! "B" "T"ranspose Matrix - maximum size allocated
    REAL(DP) :: MT_MATRIX(256,256) ! "M"ass "T"ime Matrix - maximum size allocated
    REAL(DP) :: CT_MATRIX(256,256) ! "C"onvective "T"erm Matrix - maximum size allocated
    REAL(DP) :: C_MATRIX(256,256)
    REAL(DP) :: K_MATRIX(256,256)
    REAL(DP) :: RH_VECTOR(256) ! "R"ight "H"and vector - maximum size allocated
    REAL(DP) :: NL_VECTOR(256) ! "N"on "L"inear vector - maximum size allocated
    REAL(DP) :: U_VALUE(3),W_VALUE(3),A_VALUE,U_BI_VALUE(3),A_BI_VALUE(3)!,P_VALUE
    REAL(DP) :: U_DERIV(3,3),A_DERIV!,P_DERIV
    
    CALL ENTERS("NAVIER_STOKES_FINITE_ELEMENT_RESIDUAL_EVALUATE",ERR,ERROR,*999)
    out=0
    AG_MATRIX=0.0_DP
    AL_MATRIX=0.0_DP
    ALE_MATRIX=0.0_DP
    BT_MATRIX=0.0_DP
    MT_MATRIX=0.0_DP
    CT_MATRIX=0.0_DP
    C_MATRIX=0.0_DP
    K_MATRIX=0.0_DP
    RH_VECTOR=0.0_DP
    NL_VECTOR=0.0_DP
!\todo: Set X and L through user input instead (or default)
    X=0.0_DP
! ! !     L=10.0_DP
!\todo: Check whether or not the update flags work properly
    UPDATE_STIFFNESS_MATRIX=.FALSE.
    UPDATE_DAMPING_MATRIX=.FALSE.
    UPDATE_RHS_VECTOR=.FALSE.
    UPDATE_NONLINEAR_RESIDUAL=.FALSE.
   
    IF(EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_1DTRANSIENT_NAVIER_STOKES_SUBTYPE) THEN
!      IF(ELEMENT_NUMBER==1) THEN 
        !CALL VERSION_MATRIX_EXTENSION_INITIALISE(ELEMENT_MATRIX,ERR,ERROR,*999)
        !CALL VERSION_MATRIX_EXTENSION(ELEMENT_MATRIX,ERR,ERROR,*999)
!      ENDIF
    ENDIF

    IF(ASSOCIATED(EQUATIONS_SET)) THEN
      EQUATIONS=>EQUATIONS_SET%EQUATIONS
      IF(ASSOCIATED(EQUATIONS)) THEN
        SELECT CASE(EQUATIONS_SET%SUBTYPE)
        CASE(EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE, &
          & EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE, &
          & EQUATIONS_SET_PGM_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_QUASISTATIC_NAVIER_STOKES_SUBTYPE, &
          & EQUATIONS_SET_1DTRANSIENT_NAVIER_STOKES_SUBTYPE)
          !Set general and specific pointers
          DEPENDENT_FIELD=>EQUATIONS%INTERPOLATION%DEPENDENT_FIELD
          GEOMETRIC_FIELD=>EQUATIONS%INTERPOLATION%GEOMETRIC_FIELD
          MATERIALS_FIELD=>EQUATIONS%INTERPOLATION%MATERIALS_FIELD
          EQUATIONS_MATRICES=>EQUATIONS%EQUATIONS_MATRICES
          GEOMETRIC_BASIS=>GEOMETRIC_FIELD%DECOMPOSITION%DOMAIN(GEOMETRIC_FIELD%DECOMPOSITION%MESH_COMPONENT_NUMBER)%PTR% &
            & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
          DEPENDENT_BASIS=>DEPENDENT_FIELD%DECOMPOSITION%DOMAIN(DEPENDENT_FIELD%DECOMPOSITION%MESH_COMPONENT_NUMBER)%PTR% &
            & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
          QUADRATURE_SCHEME=>DEPENDENT_BASIS%QUADRATURE%QUADRATURE_SCHEME_MAP(BASIS_DEFAULT_QUADRATURE_SCHEME)%PTR
          RHS_VECTOR=>EQUATIONS_MATRICES%RHS_VECTOR
          EQUATIONS_MAPPING=>EQUATIONS%EQUATIONS_MAPPING
          SELECT CASE(EQUATIONS_SET%SUBTYPE)
            CASE(EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE, &
              & EQUATIONS_SET_QUASISTATIC_NAVIER_STOKES_SUBTYPE)
              LINEAR_MATRICES=>EQUATIONS_MATRICES%LINEAR_MATRICES
              NONLINEAR_MATRICES=>EQUATIONS_MATRICES%NONLINEAR_MATRICES
              STIFFNESS_MATRIX=>LINEAR_MATRICES%MATRICES(1)%PTR
              LINEAR_MAPPING=>EQUATIONS_MAPPING%LINEAR_MAPPING
              NONLINEAR_MAPPING=>EQUATIONS_MAPPING%NONLINEAR_MAPPING
              !                 FIELD_VARIABLE=>LINEAR_MAPPING%EQUATIONS_MATRIX_TO_VAR_MAPS(1)%VARIABLE
              FIELD_VARIABLE=>NONLINEAR_MAPPING%RESIDUAL_VARIABLES(1)%PTR
              FIELD_VAR_TYPE=FIELD_VARIABLE%VARIABLE_TYPE
              !                 SOURCE_VECTOR=>EQUATIONS_MATRICES%SOURCE_VECTOR
              STIFFNESS_MATRIX%ELEMENT_MATRIX%MATRIX=0.0_DP
              NONLINEAR_MATRICES%ELEMENT_RESIDUAL%VECTOR=0.0_DP
              IF(ASSOCIATED(STIFFNESS_MATRIX)) UPDATE_STIFFNESS_MATRIX=STIFFNESS_MATRIX%UPDATE_MATRIX
              IF(ASSOCIATED(RHS_VECTOR)) UPDATE_RHS_VECTOR=RHS_VECTOR%UPDATE_VECTOR
              IF(ASSOCIATED(NONLINEAR_MATRICES)) UPDATE_NONLINEAR_RESIDUAL=NONLINEAR_MATRICES%UPDATE_RESIDUAL
            CASE(EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE)
              DYNAMIC_MATRICES=>EQUATIONS_MATRICES%DYNAMIC_MATRICES
              STIFFNESS_MATRIX=>DYNAMIC_MATRICES%MATRICES(1)%PTR
              DAMPING_MATRIX=>DYNAMIC_MATRICES%MATRICES(2)%PTR
              NONLINEAR_MATRICES=>EQUATIONS_MATRICES%NONLINEAR_MATRICES
              DYNAMIC_MAPPING=>EQUATIONS_MAPPING%DYNAMIC_MAPPING
              NONLINEAR_MAPPING=>EQUATIONS_MAPPING%NONLINEAR_MAPPING
              FIELD_VARIABLE=>NONLINEAR_MAPPING%RESIDUAL_VARIABLES(1)%PTR
              FIELD_VAR_TYPE=FIELD_VARIABLE%VARIABLE_TYPE
              STIFFNESS_MATRIX%ELEMENT_MATRIX%MATRIX=0.0_DP
              DAMPING_MATRIX%ELEMENT_MATRIX%MATRIX=0.0_DP
              NONLINEAR_MATRICES%ELEMENT_RESIDUAL%VECTOR=0.0_DP
              IF(ASSOCIATED(STIFFNESS_MATRIX)) UPDATE_STIFFNESS_MATRIX=STIFFNESS_MATRIX%UPDATE_MATRIX
              IF(ASSOCIATED(DAMPING_MATRIX)) UPDATE_DAMPING_MATRIX=DAMPING_MATRIX%UPDATE_MATRIX
              IF(ASSOCIATED(RHS_VECTOR)) UPDATE_RHS_VECTOR=RHS_VECTOR%UPDATE_VECTOR
              IF(ASSOCIATED(NONLINEAR_MATRICES)) UPDATE_NONLINEAR_RESIDUAL=NONLINEAR_MATRICES%UPDATE_RESIDUAL
            CASE(EQUATIONS_SET_1DTRANSIENT_NAVIER_STOKES_SUBTYPE)
              DYNAMIC_MATRICES=>EQUATIONS_MATRICES%DYNAMIC_MATRICES
              STIFFNESS_MATRIX=>DYNAMIC_MATRICES%MATRICES(1)%PTR
              DAMPING_MATRIX=>DYNAMIC_MATRICES%MATRICES(2)%PTR
              NONLINEAR_MATRICES=>EQUATIONS_MATRICES%NONLINEAR_MATRICES
              DYNAMIC_MAPPING=>EQUATIONS_MAPPING%DYNAMIC_MAPPING
              NONLINEAR_MAPPING=>EQUATIONS_MAPPING%NONLINEAR_MAPPING
              FIELD_VARIABLE=>NONLINEAR_MAPPING%RESIDUAL_VARIABLES(1)%PTR
              FIELD_VAR_TYPE=FIELD_VARIABLE%VARIABLE_TYPE
              STIFFNESS_MATRIX%ELEMENT_MATRIX%MATRIX=0.0_DP
              DAMPING_MATRIX%ELEMENT_MATRIX%MATRIX=0.0_DP
              NONLINEAR_MATRICES%ELEMENT_RESIDUAL%VECTOR=0.0_DP
              IF(ASSOCIATED(STIFFNESS_MATRIX)) UPDATE_STIFFNESS_MATRIX=STIFFNESS_MATRIX%UPDATE_MATRIX
              IF(ASSOCIATED(DAMPING_MATRIX)) UPDATE_DAMPING_MATRIX=DAMPING_MATRIX%UPDATE_MATRIX
              IF(ASSOCIATED(RHS_VECTOR)) UPDATE_RHS_VECTOR=RHS_VECTOR%UPDATE_VECTOR
              IF(ASSOCIATED(NONLINEAR_MATRICES)) UPDATE_NONLINEAR_RESIDUAL=NONLINEAR_MATRICES%UPDATE_RESIDUAL
            CASE(EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_PGM_NAVIER_STOKES_SUBTYPE)
              INDEPENDENT_FIELD=>EQUATIONS%INTERPOLATION%INDEPENDENT_FIELD
              INDEPENDENT_BASIS=>INDEPENDENT_FIELD%DECOMPOSITION%DOMAIN(INDEPENDENT_FIELD%DECOMPOSITION%MESH_COMPONENT_NUMBER)% & 
                & PTR%TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
              DYNAMIC_MATRICES=>EQUATIONS_MATRICES%DYNAMIC_MATRICES
              STIFFNESS_MATRIX=>DYNAMIC_MATRICES%MATRICES(1)%PTR
              DAMPING_MATRIX=>DYNAMIC_MATRICES%MATRICES(2)%PTR
              NONLINEAR_MATRICES=>EQUATIONS_MATRICES%NONLINEAR_MATRICES
              DYNAMIC_MAPPING=>EQUATIONS_MAPPING%DYNAMIC_MAPPING
              NONLINEAR_MAPPING=>EQUATIONS_MAPPING%NONLINEAR_MAPPING
              FIELD_VARIABLE=>NONLINEAR_MAPPING%RESIDUAL_VARIABLES(1)%PTR
              FIELD_VAR_TYPE=FIELD_VARIABLE%VARIABLE_TYPE
              STIFFNESS_MATRIX%ELEMENT_MATRIX%MATRIX=0.0_DP
              DAMPING_MATRIX%ELEMENT_MATRIX%MATRIX=0.0_DP
              NONLINEAR_MATRICES%ELEMENT_RESIDUAL%VECTOR=0.0_DP
              IF(ASSOCIATED(STIFFNESS_MATRIX)) UPDATE_STIFFNESS_MATRIX=STIFFNESS_MATRIX%UPDATE_MATRIX
              IF(ASSOCIATED(DAMPING_MATRIX)) UPDATE_DAMPING_MATRIX=DAMPING_MATRIX%UPDATE_MATRIX
              IF(ASSOCIATED(RHS_VECTOR)) UPDATE_RHS_VECTOR=RHS_VECTOR%UPDATE_VECTOR
              IF(ASSOCIATED(NONLINEAR_MATRICES)) UPDATE_NONLINEAR_RESIDUAL=NONLINEAR_MATRICES%UPDATE_RESIDUAL
              CALL FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET(FIELD_MESH_VELOCITY_SET_TYPE,ELEMENT_NUMBER,EQUATIONS%INTERPOLATION% &
                & INDEPENDENT_INTERP_PARAMETERS(FIELD_U_VARIABLE_TYPE)%PTR,ERR,ERROR,*999)
            CASE DEFAULT
              LOCAL_ERROR="Equations set subtype "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                & " is not valid for a Navier-Stokes fluid type of a fluid mechanics equations set class."
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
          CALL FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET(FIELD_VALUES_SET_TYPE,ELEMENT_NUMBER,EQUATIONS%INTERPOLATION% &
            & DEPENDENT_INTERP_PARAMETERS(FIELD_VAR_TYPE)%PTR,ERR,ERROR,*999)
          CALL FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET(FIELD_VALUES_SET_TYPE,ELEMENT_NUMBER,EQUATIONS%INTERPOLATION% &
            & GEOMETRIC_INTERP_PARAMETERS(FIELD_U_VARIABLE_TYPE)%PTR,ERR,ERROR,*999)
          CALL FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET(FIELD_VALUES_SET_TYPE,ELEMENT_NUMBER,EQUATIONS%INTERPOLATION% &
            & MATERIALS_INTERP_PARAMETERS(FIELD_U_VARIABLE_TYPE)%PTR,ERR,ERROR,*999)
          !Loop over Gauss points
          DO ng=1,QUADRATURE_SCHEME%NUMBER_OF_GAUSS
            CALL FIELD_INTERPOLATE_GAUSS(FIRST_PART_DERIV,BASIS_DEFAULT_QUADRATURE_SCHEME,ng,EQUATIONS%INTERPOLATION% &
              & DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR,ERR,ERROR,*999)
            CALL FIELD_INTERPOLATE_GAUSS(FIRST_PART_DERIV,BASIS_DEFAULT_QUADRATURE_SCHEME,ng,EQUATIONS%INTERPOLATION% &
              & GEOMETRIC_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR,ERR,ERROR,*999)
            CALL FIELD_INTERPOLATED_POINT_METRICS_CALCULATE(GEOMETRIC_BASIS%NUMBER_OF_XI,EQUATIONS%INTERPOLATION% &
              & GEOMETRIC_INTERP_POINT_METRICS(FIELD_U_VARIABLE_TYPE)%PTR,ERR,ERROR,*999)
            CALL FIELD_INTERPOLATE_GAUSS(NO_PART_DERIV,BASIS_DEFAULT_QUADRATURE_SCHEME,ng,EQUATIONS%INTERPOLATION% &
              & MATERIALS_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR,ERR,ERROR,*999)
            IF(EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE.OR. &
              & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_PGM_NAVIER_STOKES_SUBTYPE) THEN
              CALL FIELD_INTERPOLATE_GAUSS(FIRST_PART_DERIV,BASIS_DEFAULT_QUADRATURE_SCHEME,ng,EQUATIONS%INTERPOLATION% &
                & INDEPENDENT_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR,ERR,ERROR,*999)
                W_VALUE(1)=EQUATIONS%INTERPOLATION%INDEPENDENT_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR%VALUES(1,NO_PART_DERIV)
                W_VALUE(2)=EQUATIONS%INTERPOLATION%INDEPENDENT_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR%VALUES(2,NO_PART_DERIV)
                IF(FIELD_VARIABLE%NUMBER_OF_COMPONENTS==4) THEN
                  W_VALUE(3)=EQUATIONS%INTERPOLATION%INDEPENDENT_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR%VALUES(3,NO_PART_DERIV)
                END IF 
            ELSE
              W_VALUE=0.0_DP
            END IF
            !Define MU_PARAM, viscosity=1
            MU_PARAM=EQUATIONS%INTERPOLATION%MATERIALS_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR%VALUES(1,NO_PART_DERIV)
            !Define RHO_PARAM, density=2
            RHO_PARAM=EQUATIONS%INTERPOLATION%MATERIALS_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR%VALUES(2,NO_PART_DERIV)
            !Start with matrix calculations
            IF(EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE.OR. &
              & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE.OR. &
              & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE.OR. &
              & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_QUASISTATIC_NAVIER_STOKES_SUBTYPE.OR. &
              & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE.OR. &
              & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_PGM_NAVIER_STOKES_SUBTYPE) THEN
              !Loop over field components
              mhs=0
              DO mh=1,FIELD_VARIABLE%NUMBER_OF_COMPONENTS-1
                MESH_COMPONENT1=FIELD_VARIABLE%COMPONENTS(mh)%MESH_COMPONENT_NUMBER
                DEPENDENT_BASIS1=>DEPENDENT_FIELD%DECOMPOSITION%DOMAIN(MESH_COMPONENT1)%PTR% &
                  & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
                QUADRATURE_SCHEME1=>DEPENDENT_BASIS1%QUADRATURE%QUADRATURE_SCHEME_MAP(BASIS_DEFAULT_QUADRATURE_SCHEME)%PTR
                JGW=EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT_METRICS(FIELD_U_VARIABLE_TYPE)%PTR%JACOBIAN* &
                  & QUADRATURE_SCHEME1%GAUSS_WEIGHTS(ng)
                DO ms=1,DEPENDENT_BASIS1%NUMBER_OF_ELEMENT_PARAMETERS
                  mhs=mhs+1
                  nhs=0
                  IF(UPDATE_STIFFNESS_MATRIX.OR.UPDATE_DAMPING_MATRIX) THEN
                    !Loop over element columns
                    DO nh=1,FIELD_VARIABLE%NUMBER_OF_COMPONENTS
                      MESH_COMPONENT2=FIELD_VARIABLE%COMPONENTS(nh)%MESH_COMPONENT_NUMBER
                      DEPENDENT_BASIS2=>DEPENDENT_FIELD%DECOMPOSITION%DOMAIN(MESH_COMPONENT2)%PTR% &
                        & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
                      QUADRATURE_SCHEME2=>DEPENDENT_BASIS2%QUADRATURE%QUADRATURE_SCHEME_MAP&
                        &(BASIS_DEFAULT_QUADRATURE_SCHEME)%PTR
                      ! JGW=EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT_METRICS%JACOBIAN*QUADRATURE_SCHEME2%&
                      ! &GAUSS_WEIGHTS(ng)                        
                      DO ns=1,DEPENDENT_BASIS2%NUMBER_OF_ELEMENT_PARAMETERS
                        nhs=nhs+1
                        !Calculate some general values
!\todo: Use direct reference instead and check the time spent in here
                        DO ni=1,DEPENDENT_BASIS2%NUMBER_OF_XI
                          DO mi=1,DEPENDENT_BASIS1%NUMBER_OF_XI
                            DXI_DX(mi,ni)=EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT_METRICS(FIELD_U_VARIABLE_TYPE)%PTR% &
                              & DXI_DX(mi,ni)
                          END DO
                          DPHIMS_DXI(ni)=QUADRATURE_SCHEME1%GAUSS_BASIS_FNS(ms,PARTIAL_DERIVATIVE_FIRST_DERIVATIVE_MAP(ni),ng)
                          DPHINS_DXI(ni)=QUADRATURE_SCHEME2%GAUSS_BASIS_FNS(ns,PARTIAL_DERIVATIVE_FIRST_DERIVATIVE_MAP(ni),ng)
                        END DO !ni
                        PHIMS=QUADRATURE_SCHEME1%GAUSS_BASIS_FNS(ms,NO_PART_DERIV,ng)
                        PHINS=QUADRATURE_SCHEME2%GAUSS_BASIS_FNS(ns,NO_PART_DERIV,ng)
                        !Laplace only matrix
                        IF(UPDATE_STIFFNESS_MATRIX) THEN
                          !LAPLACE TYPE 
                          IF(nh==mh) THEN 
                            SUM=0.0_DP
                            !Calculate SUM 
                            DO xv=1,DEPENDENT_BASIS1%NUMBER_OF_XI
                              DO mi=1,DEPENDENT_BASIS1%NUMBER_OF_XI
                                DO ni=1,DEPENDENT_BASIS2%NUMBER_OF_XI
                                  SUM=SUM+MU_PARAM*DPHINS_DXI(ni)*DXI_DX(ni,xv)*DPHIMS_DXI(mi)*DXI_DX(mi,xv)
                                ENDDO !ni
                              ENDDO !mi
                            ENDDO !x 
                            !Calculate MATRIX  
                            AL_MATRIX(mhs,nhs)=AL_MATRIX(mhs,nhs)+SUM*JGW
                          END IF
                        END IF
                        !General matrix
                        IF(UPDATE_STIFFNESS_MATRIX) THEN
                          !GRADIENT TRANSPOSE TYPE
                          IF(EQUATIONS_SET%SUBTYPE/=EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE) THEN 
                            IF(nh<FIELD_VARIABLE%NUMBER_OF_COMPONENTS) THEN 
                              SUM=0.0_DP
                              !Calculate SUM 
                              DO mi=1,DEPENDENT_BASIS1%NUMBER_OF_XI
                                DO ni=1,DEPENDENT_BASIS2%NUMBER_OF_XI
                                  !note mh/nh derivative in DXI_DX 
                                  SUM=SUM+MU_PARAM*DPHINS_DXI(mi)*DXI_DX(mi,mh)*DPHIMS_DXI(ni)*DXI_DX(ni,nh)
                                ENDDO !ni
                              ENDDO !mi
                              !Calculate MATRIX
                              AG_MATRIX(mhs,nhs)=AG_MATRIX(mhs,nhs)+SUM*JGW
                            END IF
                          END IF
                        END IF
                        !Contribution through ALE
!\todo: This part must be either here or within the nonlinear vector
                        IF(UPDATE_STIFFNESS_MATRIX) THEN
                          !GRADIENT TRANSPOSE TYPE
                          IF(EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE.OR. & 
                            & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_PGM_NAVIER_STOKES_SUBTYPE) THEN 
                            IF(nh==mh) THEN 
                              SUM=0.0_DP
                              !Calculate SUM 
                              DO mi=1,DEPENDENT_BASIS1%NUMBER_OF_XI
                                DO ni=1,DEPENDENT_BASIS1%NUMBER_OF_XI
                                  SUM=SUM-RHO_PARAM*W_VALUE(mi)*DPHINS_DXI(ni)*DXI_DX(ni,mi)*PHIMS
                                ENDDO !ni
                              ENDDO !mi
                              !Calculate MATRIX
                              ALE_MATRIX(mhs,nhs)=ALE_MATRIX(mhs,nhs)+SUM*JGW
                            END IF
                          END IF
                        END IF
                        !Pressure contribution (B transpose)
                        IF(UPDATE_STIFFNESS_MATRIX) THEN
                          !LAPLACE TYPE 
                          IF(nh==FIELD_VARIABLE%NUMBER_OF_COMPONENTS) THEN 
                            SUM=0.0_DP
                            !Calculate SUM 
                            DO ni=1,DEPENDENT_BASIS1%NUMBER_OF_XI
                              SUM=SUM-PHINS*DPHIMS_DXI(ni)*DXI_DX(ni,mh)
                            ENDDO !ni
                            !Calculate MATRIX
                            BT_MATRIX(mhs,nhs)=BT_MATRIX(mhs,nhs)+SUM*JGW
                          END IF
                        END IF
                        !Damping matrix
                        IF(EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE.OR. &
                          & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE.OR. &
                          & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_PGM_NAVIER_STOKES_SUBTYPE) THEN
                          IF(UPDATE_DAMPING_MATRIX) THEN
                            IF(nh==mh) THEN 
                              SUM=0.0_DP 
                              !Calculate SUM 
                              SUM=PHIMS*PHINS*RHO_PARAM
                              !Calculate MATRIX
                              MT_MATRIX(mhs,nhs)=MT_MATRIX(mhs,nhs)+SUM*JGW
                            END IF
                          END IF
                        END IF
                      ENDDO !ns    
                    ENDDO !nh
                  ENDIF
                ENDDO !ms
              ENDDO !mh
              !Analytic RHS vector
              IF(RHS_VECTOR%FIRST_ASSEMBLY) THEN
                IF(UPDATE_RHS_VECTOR) THEN
                  IF(ASSOCIATED(EQUATIONS_SET%ANALYTIC)) THEN
                    IF(EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_1.OR. &
                      & EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_2.OR. &
                      & EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_3.OR. &
                      & EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_4.OR. &
                      & EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_5.OR. &
                      & EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_ONE_DIM_1.OR. &
                      & EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_1.OR. &
                      & EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_2.OR. &
                      & EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_3.OR. &
                      & EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_4.OR. &
                      & EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_5) THEN
                      mhs=0
                      DO mh=1,FIELD_VARIABLE%NUMBER_OF_COMPONENTS-1
                        MESH_COMPONENT1=FIELD_VARIABLE%COMPONENTS(mh)%MESH_COMPONENT_NUMBER
                        DEPENDENT_BASIS1=>DEPENDENT_FIELD%DECOMPOSITION%DOMAIN(MESH_COMPONENT1)%PTR% &
                          & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
                        QUADRATURE_SCHEME1=>DEPENDENT_BASIS1%QUADRATURE%QUADRATURE_SCHEME_MAP(BASIS_DEFAULT_QUADRATURE_SCHEME)%PTR
                        JGW=EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT_METRICS(FIELD_U_VARIABLE_TYPE)%PTR%JACOBIAN* &
                          & QUADRATURE_SCHEME1%GAUSS_WEIGHTS(ng)
                        DO ms=1,DEPENDENT_BASIS1%NUMBER_OF_ELEMENT_PARAMETERS
                          mhs=mhs+1
                          PHIMS=QUADRATURE_SCHEME1%GAUSS_BASIS_FNS(ms,NO_PART_DERIV,ng)
                          !note mh value derivative 
                          SUM=0.0_DP 
                          X(1) = EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR%VALUES(1,1)
                          X(2) = EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR%VALUES(2,1)
                          IF(DEPENDENT_BASIS1%NUMBER_OF_XI==3) THEN
                            X(3) = EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR%VALUES(3,1)
                          END IF
                          IF(EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_1) THEN
                            IF(mh==1) THEN 
                              !Calculate SUM 
                              SUM=0.0_DP                         
                            ELSE IF(mh==2) THEN
                              !Calculate SUM 
                              SUM=PHIMS*(-2.0_DP/3.0_DP*(X(1)**3*RHO_PARAM+3.0_DP*MU_PARAM*10.0_DP**2- &
                                & 3.0_DP*RHO_PARAM*X(2)**2*X(1))/(10.0_DP**4))
                            ENDIF
                          ELSE IF(EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_2) &
                            & THEN
                            IF(mh==1) THEN 
                              !Calculate SUM 
                              SUM=0.0_DP                               
                            ELSE IF(mh==2) THEN
                              !Calculate SUM 
                              SUM=PHIMS*(-4.0_DP*MU_PARAM/10.0_DP/10.0_DP*EXP((X(1)-X(2))/10.0_DP))
                            ENDIF
                          ELSE IF(EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_3) & 
                           & THEN
                            IF(mh==1) THEN 
                              !Calculate SUM 
                              SUM=0.0_DP         
                            ELSE IF(mh==2) THEN
                              !Calculate SUM 
                              SUM=PHIMS*(16.0_DP*MU_PARAM*PI**2/10.0_DP**2*COS(2.0_DP*PI*X(2)/10.0_DP)* &
                                & COS(2.0_DP*PI*X(1)/10.0_DP)- &
                                & 2.0_DP*COS(2.0_DP*PI*X(2)/10.0_DP)*SIN(2.0_DP*PI*X(2)/10.0_DP)*RHO_PARAM*PI/10.0_DP)
                            ENDIF
                          ELSE IF(EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_4) & 
                           & THEN
                            IF(mh==1) THEN 
                              !Calculate SUM 
                              SUM=PHIMS*(2.0_DP*SIN(X(1))*COS(X(2)))*MU_PARAM
                            ELSE IF(mh==2) THEN
                              !Calculate SUM 
                              SUM=PHIMS*(-2.0_DP*COS(X(1))*SIN(X(2)))*MU_PARAM
                            ENDIF
                          ELSE IF(EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_5) & 
                           & THEN
                            !do nothing
                          ELSE IF(EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE== & 
                            & EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_1) THEN
                            IF(mh==1) THEN 
                              !Calculate SUM 
                              SUM=0.0_DP       
                            ELSE IF(mh==2) THEN
                              !Calculate SUM 
                              SUM=PHIMS*(-2.0_DP/3.0_DP*(RHO_PARAM*X(1)**3+6.0_DP*RHO_PARAM*X(1)*X(3)*X(2)+ &
                                & 6.0_DP*MU_PARAM*10.0_DP**2- & 
                                & 3.0_DP*RHO_PARAM*X(2)**2*X(1)-3.0_DP*RHO_PARAM*X(3)*X(1)**2-3.0_DP*RHO_PARAM*X(3)*X(2)**2)/ &
                                  & (10.0_DP**4))
                            ELSE IF(mh==3) THEN
                              !Calculate SUM 
                              SUM=PHIMS*(-2.0_DP/3.0_DP*(6.0_DP*RHO_PARAM*X(1)*X(3)*X(2)+RHO_PARAM*X(1)**3+ &
                                & 6.0_DP*MU_PARAM*10.0_DP**2- & 
                                & 3.0_DP*RHO_PARAM*X(1)*X(3)**2-3.0_DP*RHO_PARAM*X(2)*X(1)**2-3.0_DP*RHO_PARAM*X(2)*X(3)**2)/ & 
                                & (10.0_DP**4))
                            ENDIF
                          ELSE IF(EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE== & 
                            & EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_2) THEN
                            IF(mh==1) THEN 
                              !Calculate SUM 
                              SUM=0.0_DP         
                            ELSE IF(mh==2) THEN
                              !Calculate SUM 
                              SUM=PHIMS*((-4.0_DP*MU_PARAM*EXP((X(1)-X(2))/10.0_DP)-2.0_DP*MU_PARAM*EXP((X(2)-X(3))/10.0_DP)+ & 
                                & RHO_PARAM*EXP((X(3)-X(2))/10.0_DP)*10.0_DP)/10.0_DP**2)
                            ELSE IF(mh==3) THEN
                              !Calculate SUM 
                              SUM=PHIMS*(-(4.0_DP*MU_PARAM*EXP((X(3)-X(1))/10.0_DP)+2.0_DP*MU_PARAM*EXP((X(2)-X(3))/10.0_DP)+ & 
                                & RHO_PARAM*EXP((X(3)-X(2))/10.0_DP)*10.0_DP)/10.0_DP** 2)
                            ENDIF
                          ELSE IF(EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE== & 
                            & EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_3) THEN
                            IF(mh==1) THEN 
                              !Calculate SUM 
                              SUM=0.0_DP         
                            ELSE IF(mh==2) THEN
                              !Calculate SUM 
                              SUM=PHIMS*(2.0_DP*COS(2.0_DP*PI*X(2)/10.0_DP)*(18.0_DP*COS(2.0_DP*PI*X(1)/10.0_DP)* &
                                & MU_PARAM*PI*SIN(2.0_DP*PI*X(3)/10.0_DP)-3.0_DP*RHO_PARAM*COS(2.0_DP*PI*X(1)/10.0_DP)**2* &
                                & SIN(2.0_DP*PI*X(2)/10.0_DP)*10.0_DP-2.0_DP*RHO_PARAM*SIN(2.0_DP*PI*X(2)/10.0_DP)*10.0_DP+ & 
                                & 2.0_DP*RHO_PARAM*SIN(2.0_DP*PI*X(2)/10.0_DP)*10.0_DP*COS(2.0_DP*PI*X(3)/10.0_DP)**2)*PI/ &
                                & 10.0_DP**2)
                            ELSE IF(mh==3) THEN
                              !Calculate SUM 
                              SUM=PHIMS*(-2.0_DP*PI*COS(2.0_DP*PI*X(3)/10.0_DP)*RHO_PARAM*SIN(2.0_DP*PI*X(3)/10.0_DP)* & 
                                & (-1.0_DP+COS(2.0_DP*PI*X(2)/10.0_DP)**2)/10.0_DP)
                            ENDIF
                          ELSE IF(EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_4) & 
                           & THEN
                            IF(mh==1) THEN 
                              !Calculate SUM 
! ! !                               SUM=PHIMS*(2.0_DP*SIN(X(1))*COS(X(2)))*MU_PARAM
                            ELSE IF(mh==2) THEN
                              !Calculate SUM 
! ! !                               SUM=PHIMS*(-2.0_DP*COS(X(1))*SIN(X(2)))*MU_PARAM
                            ENDIF
                          ELSE IF(EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_5) & 
                           & THEN
                            !do nothing
                          ENDIF
                          !Calculate RH VECTOR
                          RH_VECTOR(mhs)=RH_VECTOR(mhs)+SUM*JGW
                        ENDDO !ms
                      ENDDO !mh
                    ELSE
                      RH_VECTOR(mhs)=0.0_DP
                    ENDIF                 
                  ENDIF
                ENDIF                                                                     
              ENDIF                                      
              !Calculate nonlinear vector
              IF(UPDATE_NONLINEAR_RESIDUAL) THEN
                U_VALUE(1)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(1,NO_PART_DERIV)
                U_VALUE(2)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(2,NO_PART_DERIV)
                U_DERIV(1,1)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(1,PART_DERIV_S1)
                U_DERIV(1,2)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(1,PART_DERIV_S2)
                U_DERIV(2,1)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(2,PART_DERIV_S1)
                U_DERIV(2,2)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(2,PART_DERIV_S2)
                IF(FIELD_VARIABLE%NUMBER_OF_COMPONENTS==4) THEN
                  U_VALUE(3)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(3,NO_PART_DERIV)
                  U_DERIV(3,1)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(3,PART_DERIV_S1)
                  U_DERIV(3,2)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(3,PART_DERIV_S2)
                  U_DERIV(3,3)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(3,PART_DERIV_S3)
                  U_DERIV(1,3)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(1,PART_DERIV_S3)
                  U_DERIV(2,3)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(2,PART_DERIV_S3) 
                ELSE
                  U_VALUE(3)=0.0_DP
                  U_DERIV(3,1)=0.0_DP
                  U_DERIV(3,2)=0.0_DP
                  U_DERIV(3,3)=0.0_DP
                  U_DERIV(1,3)=0.0_DP
                  U_DERIV(2,3)=0.0_DP
                END IF
                !Here W_VALUES must be ZERO if ALE part of linear matrix
                W_VALUE=0.0_DP
                mhs=0
                DO mh=1,(FIELD_VARIABLE%NUMBER_OF_COMPONENTS-1)
                  MESH_COMPONENT1=FIELD_VARIABLE%COMPONENTS(mh)%MESH_COMPONENT_NUMBER
                  DEPENDENT_BASIS1=>DEPENDENT_FIELD%DECOMPOSITION%DOMAIN(MESH_COMPONENT1)%PTR% &
                    & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
                  QUADRATURE_SCHEME1=>DEPENDENT_BASIS1%QUADRATURE%QUADRATURE_SCHEME_MAP(BASIS_DEFAULT_QUADRATURE_SCHEME)%PTR
                  JGW=EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT_METRICS(FIELD_U_VARIABLE_TYPE)%PTR%JACOBIAN* &
                    & QUADRATURE_SCHEME1%GAUSS_WEIGHTS(ng)
                  DXI_DX=0.0_DP
                  DO ni=1,DEPENDENT_BASIS1%NUMBER_OF_XI
                    DO mi=1,DEPENDENT_BASIS1%NUMBER_OF_XI
                      DXI_DX(mi,ni)=EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT_METRICS(FIELD_U_VARIABLE_TYPE)%PTR%DXI_DX(mi,ni)
                    END DO
                  END DO
                  DO ms=1,DEPENDENT_BASIS1%NUMBER_OF_ELEMENT_PARAMETERS
                    mhs=mhs+1
                    PHIMS=QUADRATURE_SCHEME1%GAUSS_BASIS_FNS(ms,NO_PART_DERIV,ng)
                    !note mh value derivative 
                    SUM=0.0_DP
                    !Calculate SUM 
                    DO ni=1,DEPENDENT_BASIS1%NUMBER_OF_XI
                     SUM=SUM+RHO_PARAM*PHIMS*( & 
                       & (U_VALUE(1)-W_VALUE(1))*(U_DERIV(mh,ni)*DXI_DX(ni,1))+ &
                       & (U_VALUE(2)-W_VALUE(2))*(U_DERIV(mh,ni)*DXI_DX(ni,2))+ &
                       & (U_VALUE(3)-W_VALUE(3))*(U_DERIV(mh,ni)*DXI_DX(ni,3)))
                    ENDDO !ni
                    NL_VECTOR(mhs)=NL_VECTOR(mhs)+SUM*JGW
                  ENDDO !ms
                ENDDO !mh
              ENDIF
            ENDIF

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! 1D TRANSIENT !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

            !Start with matrix calculations
            IF(EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_1DTRANSIENT_NAVIER_STOKES_SUBTYPE) THEN

              MU_PARAM=EQUATIONS%INTERPOLATION%MATERIALS_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR%VALUES(1,NO_PART_DERIV)
              RHO_PARAM=EQUATIONS%INTERPOLATION%MATERIALS_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR%VALUES(2,NO_PART_DERIV)
              E_PARAM=EQUATIONS%INTERPOLATION%MATERIALS_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR%VALUES(3,NO_PART_DERIV)
              H0_PARAM=EQUATIONS%INTERPOLATION%MATERIALS_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR%VALUES(4,NO_PART_DERIV)
              A0_PARAM=EQUATIONS%INTERPOLATION%MATERIALS_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR%VALUES(5,NO_PART_DERIV)
              SIGMA_PARAM=EQUATIONS%INTERPOLATION%MATERIALS_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR%VALUES(6,NO_PART_DERIV)

              mhs=0
              DO mh=1,FIELD_VARIABLE%NUMBER_OF_COMPONENTS
                MESH_COMPONENT1=FIELD_VARIABLE%COMPONENTS(mh)%MESH_COMPONENT_NUMBER
                DEPENDENT_BASIS1=>DEPENDENT_FIELD%DECOMPOSITION%DOMAIN(MESH_COMPONENT1)%PTR% &
                  & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
                QUADRATURE_SCHEME1=>DEPENDENT_BASIS1%QUADRATURE%QUADRATURE_SCHEME_MAP(BASIS_DEFAULT_QUADRATURE_SCHEME)%PTR
                JGW=EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT_METRICS(FIELD_U_VARIABLE_TYPE)%PTR%JACOBIAN* &
                  & QUADRATURE_SCHEME1%GAUSS_WEIGHTS(ng)

                DO ms=1,DEPENDENT_BASIS1%NUMBER_OF_ELEMENT_PARAMETERS
                  mhs=mhs+1
                  nhs=0

                  IF(UPDATE_STIFFNESS_MATRIX.OR.UPDATE_DAMPING_MATRIX) THEN
                    !Loop over element columns

                    DO nh=1,FIELD_VARIABLE%NUMBER_OF_COMPONENTS
                      MESH_COMPONENT1=FIELD_VARIABLE%COMPONENTS(nh)%MESH_COMPONENT_NUMBER
                      DEPENDENT_BASIS1=>DEPENDENT_FIELD%DECOMPOSITION%DOMAIN(MESH_COMPONENT1)%PTR% &
                        & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
                      QUADRATURE_SCHEME1=>DEPENDENT_BASIS1%QUADRATURE%QUADRATURE_SCHEME_MAP&
                        &(BASIS_DEFAULT_QUADRATURE_SCHEME)%PTR
                      ! JGW=EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT_METRICS%JACOBIAN*QUADRATURE_SCHEME2%GAUSS_WEIGHTS(ng)

                      DO ns=1,DEPENDENT_BASIS1%NUMBER_OF_ELEMENT_PARAMETERS
                        nhs=nhs+1
                        !Calculate some general values
                        DXI_DX(1,1)=EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT_METRICS(FIELD_U_VARIABLE_TYPE)%PTR%DXI_DX(1,1)
                        DPHIMS_DXI(1)=QUADRATURE_SCHEME1%GAUSS_BASIS_FNS(ms,FIRST_PART_DERIV,ng)
                        DPHINS_DXI(1)=QUADRATURE_SCHEME1%GAUSS_BASIS_FNS(ns,FIRST_PART_DERIV,ng)
                        PHIMS=QUADRATURE_SCHEME1%GAUSS_BASIS_FNS(ms,NO_PART_DERIV,ng)
                        PHINS=QUADRATURE_SCHEME1%GAUSS_BASIS_FNS(ns,NO_PART_DERIV,ng)

                        !DAMPING MATRIX
!                        IF(UPDATE_DAMPING_MATRIX) THEN
!                          IF(mh==1) THEN
!                            IF(nh==1) THEN
!                              SUM=PHINS*PHIMS
!                              !Calculate Matrix
!                              C_MATRIX(mhs,nhs)=C_MATRIX(mhs,nhs)+SUM*JGW
!                            END IF
!                          END IF

!                          IF(mh==2) THEN
!                            IF(nh==2) THEN
!                              SUM=PHINS*PHIMS
!                              !Calculate Matrix
!                              C_MATRIX(mhs,nhs)=C_MATRIX(mhs,nhs)+SUM*JGW
!                            END IF
!                          END IF
!                        END IF



                        !--DAMPING MATRIX BRANCH SECTION--!
                        IF(UPDATE_DAMPING_MATRIX) THEN
                          IF(ELEMENT_NUMBER==1) THEN

                            IF(mh==1) THEN
                              IF(nh==1) THEN
                                SUM=PHINS*PHIMS
                                C_MATRIX(mhs,nhs)=C_MATRIX(mhs,nhs)+SUM*JGW
                              END IF
                            END IF

                            IF(mh==2) THEN
                              IF(nh==2) THEN
                                SUM=PHINS*PHIMS
                                C_MATRIX(mhs+3,nhs+3)=C_MATRIX(mhs+3,nhs+3)+SUM*JGW
                              END IF
                            END IF

                          ELSEIF(ELEMENT_NUMBER==2) THEN

                            IF(mh==1) THEN
                              IF(nh==1) THEN
                                SUM=PHINS*PHIMS
                                C_MATRIX(mhs+3,nhs+3)=C_MATRIX(mhs+3,nhs+3)+SUM*JGW
                              END IF
                            END IF

                            IF(mh==2) THEN
                              IF(nh==2) THEN
                                SUM=PHINS*PHIMS
                                C_MATRIX(mhs+6,nhs+6)=C_MATRIX(mhs+6,nhs+6)+SUM*JGW
                              END IF
                            END IF

                          ELSEIF(ELEMENT_NUMBER==3) THEN

                            IF(mh==1) THEN
                              IF(nh==1) THEN
                                SUM=PHINS*PHIMS
                                C_MATRIX(mhs+3,nhs+3)=C_MATRIX(mhs+3,nhs+3)+SUM*JGW
                              END IF
                            END IF

                            IF(mh==2) THEN
                              IF(nh==2) THEN
                                SUM=PHINS*PHIMS
                                C_MATRIX(mhs+6,nhs+6)=C_MATRIX(mhs+6,nhs+6)+SUM*JGW
                              END IF
                            END IF

                          END IF
                        END IF



                        !STIFFNESS MATRIX
!                        IF(UPDATE_STIFFNESS_MATRIX) THEN
!                          IF(mh==1) THEN
!                            IF(nh==1) THEN
!                              SUM=(8*3.1416*MU_PARAM/RHO_PARAM)*PHINS*PHIMS
!                              !Calculate MATRIX
!                              K_MATRIX(mhs,nhs)=K_MATRIX(mhs,nhs)+SUM*JGW
!                            END IF
!                          END IF
!
!                          IF(mh==1) THEN
!                            IF(nh==2) THEN
!                              SUM=(  (1.7725*E_PARAM*H0_PARAM)/( (A0_PARAM**1.5)*RHO_PARAM )  )*DPHINS_DXI(1)*DXI_DX(1,1)*PHIMS
!                              !Calculate MATRIX
!                              K_MATRIX(mhs,nhs)=K_MATRIX(mhs,nhs)+SUM*JGW
!                            END IF
!                          END IF
!                        END IF



                        !--STIFFNESS MATRIX BRANCH SECTION--!
                        IF(UPDATE_STIFFNESS_MATRIX) THEN
                          IF(ELEMENT_NUMBER==1) THEN
                            IF(mh==1) THEN
                              IF(nh==2) THEN
                                SUM=((1.7725*E_PARAM*H0_PARAM)/((A0_PARAM**1.5)*RHO_PARAM))*DPHINS_DXI(1)*DXI_DX(1,1)*PHIMS
                                K_MATRIX(mhs,nhs+3)=K_MATRIX(mhs,nhs+3)+SUM*JGW
                              END IF
                            END IF
                          ELSEIF(ELEMENT_NUMBER==2) THEN
                            IF(mh==1) THEN
                              IF(nh==2) THEN
                                SUM=((1.7725*E_PARAM*H0_PARAM)/((A0_PARAM**1.5)*RHO_PARAM))*DPHINS_DXI(1)*DXI_DX(1,1)*PHIMS
                                K_MATRIX(mhs+3,nhs+6)=K_MATRIX(mhs+3,nhs+6)+SUM*JGW
                              END IF
                            END IF
                          ELSEIF(ELEMENT_NUMBER==3) THEN
                            IF(mh==1) THEN
                              IF(nh==2) THEN
                                SUM=((1.7725*E_PARAM*H0_PARAM)/((A0_PARAM**1.5)*RHO_PARAM))*DPHINS_DXI(1)*DXI_DX(1,1)*PHIMS
                                K_MATRIX(mhs+3,nhs+6)=K_MATRIX(mhs+3,nhs+6)+SUM*JGW
                              END IF
                            END IF
                          END IF
                        END IF 

                      !NO RIGHT HAND SIDE FOR THIS CASE
                      ENDDO !ns    
                    ENDDO !nh
                  ENDIF
                ENDDO !ms
              ENDDO !mh

              !CALCULATE NONLINEAR VECTOR
              IF(UPDATE_NONLINEAR_RESIDUAL) THEN
                U_VALUE(1)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(1,NO_PART_DERIV)
                A_VALUE=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(2,NO_PART_DERIV)
!                P_VALUE=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(3,NO_PART_DERIV)
                U_DERIV(1,1)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(1,FIRST_PART_DERIV)
                A_DERIV=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(2,FIRST_PART_DERIV)
!                P_DERIV=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(3,FIRST_PART_DERIV)      

                mhs=0
                DO mh=1,FIELD_VARIABLE%NUMBER_OF_COMPONENTS
                  MESH_COMPONENT1=FIELD_VARIABLE%COMPONENTS(mh)%MESH_COMPONENT_NUMBER
                  DEPENDENT_BASIS1=>DEPENDENT_FIELD%DECOMPOSITION%DOMAIN(MESH_COMPONENT1)%PTR% &
                    & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
                  QUADRATURE_SCHEME1=>DEPENDENT_BASIS1%QUADRATURE%QUADRATURE_SCHEME_MAP(BASIS_DEFAULT_QUADRATURE_SCHEME)%PTR
                  JGW=EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT_METRICS(FIELD_U_VARIABLE_TYPE)%PTR%JACOBIAN* &
                    & QUADRATURE_SCHEME1%GAUSS_WEIGHTS(ng)
                  DXI_DX=0.0_DP
                  DXI_DX(1,1)=EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT_METRICS(FIELD_U_VARIABLE_TYPE)%PTR%DXI_DX(1,1)

                  DO ms=1,DEPENDENT_BASIS1%NUMBER_OF_ELEMENT_PARAMETERS
                    mhs=mhs+1
                    PHIMS=QUADRATURE_SCHEME1%GAUSS_BASIS_FNS(ms,NO_PART_DERIV,ng)

                     !NONLINEAR VECTOR
!                    IF(mh==1) THEN
!                      SUM=( U_VALUE(1)*U_DERIV(1,1)*DXI_DX(1,1) )*PHIMS
!                      !Calculate Matrix
!                      NL_VECTOR(mhs)=NL_VECTOR(mhs)+SUM*JGW

!                    ENDIF
!
!                    IF(mh==2) THEN
!                      SUM=( A_VALUE*U_DERIV(1,1)+U_VALUE(1)*A_DERIV )*DXI_DX(1,1)*PHIMS
!                      !Calculate Matrix
!                      NL_VECTOR(mhs)=NL_VECTOR(mhs)+SUM*JGW
!                    ENDIF


                    !--NONLINEAR VECTOR BRANCH SECTION--!
                    IF(ELEMENT_NUMBER==1) THEN
                      IF(mh==1) THEN
                        SUM=((U_VALUE(1)*U_DERIV(1,1)*DXI_DX(1,1))+(8*3.1416*.0033*U_VALUE(1)/A_VALUE))*PHIMS
                        NL_VECTOR(mhs)=NL_VECTOR(mhs)+SUM*JGW
                      ENDIF

                      IF(mh==2) THEN
                        SUM=( A_VALUE*U_DERIV(1,1)+U_VALUE(1)*A_DERIV )*DXI_DX(1,1)*PHIMS
                        NL_VECTOR(mhs+3)=NL_VECTOR(mhs+3)+SUM*JGW
                      ENDIF

                    ELSEIF(ELEMENT_NUMBER==2) THEN
                      IF(mh==1) THEN
                        SUM=((U_VALUE(1)*U_DERIV(1,1)*DXI_DX(1,1))+(8*3.1416*.0033*U_VALUE(1)/A_VALUE))*PHIMS
                        NL_VECTOR(mhs+3)=NL_VECTOR(mhs+3)+SUM*JGW
                      ENDIF

                      IF(mh==2) THEN
                        SUM=( A_VALUE*U_DERIV(1,1)+U_VALUE(1)*A_DERIV )*DXI_DX(1,1)*PHIMS
                        NL_VECTOR(mhs+6)=NL_VECTOR(mhs+6)+SUM*JGW
                      ENDIF

                    ELSEIF(ELEMENT_NUMBER==3) THEN
                      IF(mh==1) THEN
                        SUM=((U_VALUE(1)*U_DERIV(1,1)*DXI_DX(1,1))+(8*3.1416*.0033*U_VALUE(1)/A_VALUE))*PHIMS
                        NL_VECTOR(mhs+3)=NL_VECTOR(mhs+3)+SUM*JGW
                      ENDIF

                      IF(mh==2) THEN
                        SUM=( A_VALUE*U_DERIV(1,1)+U_VALUE(1)*A_DERIV )*DXI_DX(1,1)*PHIMS
                        NL_VECTOR(mhs+6)=NL_VECTOR(mhs+6)+SUM*JGW
                      ENDIF
                    ENDIF
  
                  ENDDO !ms
                ENDDO !mh

                !--NONLINEAR VECTOR BIFURCATION SECTION--!
                IF(ELEMENT_NUMBER==1) THEN
                  SUM=-4*(((2*1.7725*H0_PARAM*E_PARAM)/(3*18.1*RHO_PARAM))**0.5)* &
                     & (A_VALUE**0.25)
                  NL_VECTOR(4)=NL_VECTOR(4)+SUM*JGW
                ELSEIF(ELEMENT_NUMBER==2) THEN
                  SUM=4*(((2*1.7725*H0_PARAM*E_PARAM)/(3*11.4*RHO_PARAM))**0.5)* &
                     & (A_VALUE**0.25)
                  NL_VECTOR(2)=NL_VECTOR(2)+SUM*JGW
                ELSEIF(ELEMENT_NUMBER==3) THEN
                  SUM=4*(((2*1.7725*H0_PARAM*E_PARAM)/(3*11.4*RHO_PARAM))**0.5)* &
                     & (A_VALUE**0.25)
                  NL_VECTOR(3)=NL_VECTOR(3)+SUM*JGW
                ENDIF
                !--NONLINEAR VECTOR BIFURCATION SECTION--!

              ENDIF
            ENDIF
          ENDDO !ng

          !Assemble partial matrices in final matrix
          mhs_min=mhs
          mhs_max=nhs
          nhs_min=mhs
          nhs_max=nhs
          IF(EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE.OR.  &
            & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE.OR. &
            & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE.OR. &
            & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_QUASISTATIC_NAVIER_STOKES_SUBTYPE.OR. &
            & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE.OR. &
            & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_PGM_NAVIER_STOKES_SUBTYPE) THEN
            IF(STIFFNESS_MATRIX%FIRST_ASSEMBLY) THEN
              IF(UPDATE_STIFFNESS_MATRIX) THEN
                STIFFNESS_MATRIX%ELEMENT_MATRIX%MATRIX(1:mhs_min,1:nhs_min)=(AL_MATRIX(1:mhs_min,1:nhs_min)+ &
                  & AG_MATRIX(1:mhs_min,1:nhs_min)+ALE_MATRIX(1:mhs_min,1:nhs_min))
                STIFFNESS_MATRIX%ELEMENT_MATRIX%MATRIX(1:mhs_min,nhs_min+1:nhs_max)=(BT_MATRIX(1:mhs_min,nhs_min+1:nhs_max))
                DO mhs=mhs_min+1,mhs_max
                  DO nhs=1,nhs_min
                    !Transpose pressure type entries for mass equation  
                    STIFFNESS_MATRIX%ELEMENT_MATRIX%MATRIX(mhs,nhs)=STIFFNESS_MATRIX%ELEMENT_MATRIX%MATRIX(nhs,mhs)
                  END DO
                END DO
              ENDIF
            ENDIF
          ENDIF
          IF(EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE.OR. &
            & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE.OR.&
            & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_PGM_NAVIER_STOKES_SUBTYPE) THEN
            IF(UPDATE_DAMPING_MATRIX) THEN
              DAMPING_MATRIX%ELEMENT_MATRIX%MATRIX(1:mhs_min,1:nhs_min)=MT_MATRIX(1:mhs_min,1:nhs_min)
            END IF
          END IF

          IF (EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE.OR.  &
            & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE.OR. &
            & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE.OR. &
            & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_QUASISTATIC_NAVIER_STOKES_SUBTYPE.OR. &
            & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE.OR. &
            & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_PGM_NAVIER_STOKES_SUBTYPE) THEN
            !Assemble RHS vector
            IF(RHS_VECTOR%FIRST_ASSEMBLY) THEN
              IF(UPDATE_RHS_VECTOR) THEN
                RHS_VECTOR%ELEMENT_VECTOR%VECTOR(1:mhs_max)=RH_VECTOR(1:mhs_max)
              ENDIF
            ENDIF
            !Assemble non-linear vector
            IF(UPDATE_NONLINEAR_RESIDUAL) THEN
               NONLINEAR_MATRICES%ELEMENT_RESIDUAL%VECTOR(1:mhs_max)=NL_VECTOR(1:mhs_max)
            END IF
          END IF

          IF(EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_1DTRANSIENT_NAVIER_STOKES_SUBTYPE) THEN
            IF(STIFFNESS_MATRIX%FIRST_ASSEMBLY) THEN
              IF(UPDATE_STIFFNESS_MATRIX) THEN
                

                !--STIFFNESS MATRIX BIFURCATION SECTION--!      
                IF(ELEMENT_NUMBER==1) THEN
                  K_MATRIX(4,3)=-1
                  K_MATRIX(4,4)=1
                  K_MATRIX(11,10)=1
                  K_MATRIX(12,10)=1
                ELSEIF(ELEMENT_NUMBER==2) THEN
                  K_MATRIX(2,2)=1
                  K_MATRIX(2,4)=-1
                  K_MATRIX(8,8)=-2
                ELSEIF(ELEMENT_NUMBER==3) THEN
                  K_MATRIX(3,3)=1
                  K_MATRIX(3,4)=-1
                  K_MATRIX(9,9)=-2
                ENDIF
                !--STIFFNESS MATRIX BIFURCATION SECTION--!


                STIFFNESS_MATRIX%ELEMENT_MATRIX%MATRIX(1:mhs+6,1:nhs+6)=K_MATRIX(1:mhs+6,1:nhs+6)
              ENDIF
            ENDIF

            IF(UPDATE_DAMPING_MATRIX) THEN
              DAMPING_MATRIX%ELEMENT_MATRIX%MATRIX(1:mhs+6,1:nhs+6)=C_MATRIX(1:mhs+6,1:nhs+6)
            END IF

            IF(RHS_VECTOR%FIRST_ASSEMBLY) THEN
              IF(UPDATE_RHS_VECTOR) THEN
                RHS_VECTOR%ELEMENT_VECTOR%VECTOR(1:mhs)=RH_VECTOR(1:mhs)
              ENDIF
            ENDIF
            

            !--NONLINEAR VECTOR BIFURCATION SECTION--!
            IF(UPDATE_NONLINEAR_RESIDUAL) THEN
              NULLIFY(BIF_VALUES)
              CALL FIELD_PARAMETER_SET_DATA_GET(DEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, &
                  & FIELD_VALUES_SET_TYPE,BIF_VALUES,ERR,ERROR,*999)

              U_BI_VALUE(1)=FIELD_VARIABLE%COMPONENTS(1)%PARAM_TO_DOF_MAP%NODE_PARAM2DOF_MAP%NODES(3)% & 
                     & DERIVATIVES(1)%VERSIONS(2)
              U_BI_VALUE(1)=BIF_VALUES(U_BI_VALUE(1))

              A_BI_VALUE(1)=FIELD_VARIABLE%COMPONENTS(2)%PARAM_TO_DOF_MAP%NODE_PARAM2DOF_MAP%NODES(3)% & 
                     & DERIVATIVES(1)%VERSIONS(2)
              A_BI_VALUE(1)=BIF_VALUES(A_BI_VALUE(1))

              U_BI_VALUE(2)=FIELD_VARIABLE%COMPONENTS(1)%PARAM_TO_DOF_MAP%NODE_PARAM2DOF_MAP%NODES(3)% & 
                     & DERIVATIVES(1)%VERSIONS(3)
              U_BI_VALUE(2)=BIF_VALUES(U_BI_VALUE(2))

              A_BI_VALUE(2)=FIELD_VARIABLE%COMPONENTS(2)%PARAM_TO_DOF_MAP%NODE_PARAM2DOF_MAP%NODES(3)% & 
                     & DERIVATIVES(1)%VERSIONS(3)
              A_BI_VALUE(2)=BIF_VALUES(A_BI_VALUE(2))

              U_BI_VALUE(3)=FIELD_VARIABLE%COMPONENTS(1)%PARAM_TO_DOF_MAP%NODE_PARAM2DOF_MAP%NODES(3)% & 
                     & DERIVATIVES(1)%VERSIONS(4)
              U_BI_VALUE(3)=BIF_VALUES(U_BI_VALUE(3))

              A_BI_VALUE(3)=FIELD_VARIABLE%COMPONENTS(2)%PARAM_TO_DOF_MAP%NODE_PARAM2DOF_MAP%NODES(3)% & 
                     & DERIVATIVES(1)%VERSIONS(4)
              A_BI_VALUE(3)=BIF_VALUES(A_BI_VALUE(3))

              CALL FIELD_PARAMETER_SET_DATA_RESTORE(DEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, &
                  & FIELD_VALUES_SET_TYPE,BIF_VALUES,ERR,ERROR,*999)


              !--NONLINEAR VECTOR BIFURCATION SECTION--!
              IF(ELEMENT_NUMBER==1) THEN
                NL_VECTOR(4)=NL_VECTOR(4)+( 4*(((2*1.7725*H0_PARAM*E_PARAM)/(3*18.1*RHO_PARAM)) &
                            & **0.5)*(A_BI_VALUE(1)**0.25) )
                NL_VECTOR(10)=(A_BI_VALUE(1)*U_BI_VALUE(1))-(A_BI_VALUE(2)*U_BI_VALUE(2))-(A_BI_VALUE(3)*U_BI_VALUE(3))
                NL_VECTOR(11)=2*11.4-18.1
                NL_VECTOR(12)=2*11.4-18.1
              ELSEIF(ELEMENT_NUMBER==2) THEN
                NL_VECTOR(2)=NL_VECTOR(2)+( -4*(((2*1.7725*H0_PARAM*E_PARAM)/(3*11.4*RHO_PARAM)) &
                            & **0.5)*(A_BI_VALUE(2)**0.25)  )
              ELSEIF(ELEMENT_NUMBER==3) THEN
                NL_VECTOR(3)=NL_VECTOR(3)+( -4*(((2*1.7725*H0_PARAM*E_PARAM)/(3*11.4*RHO_PARAM)) &
                            & **0.5)*(A_BI_VALUE(3)**0.25)  )       
              ENDIF
              !--NONLINEAR VECTOR BIFURCATION SECTION--!


              NONLINEAR_MATRICES%ELEMENT_RESIDUAL%VECTOR(1:mhs+6)=NL_VECTOR(1:mhs+6)
            END IF
          END IF

        CASE DEFAULT
          LOCAL_ERROR="Equations set subtype "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
            & " is not valid for a Navier-Stokes equation type of a classical field equations set class."
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        END SELECT
      ELSE
        CALL FLAG_ERROR("Equations set equations is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
    ENDIF
    
    CALL EXITS("NAVIER_STOKES_FINITE_ELEMENT_RESIDUAL_EVALUATE")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_FINITE_ELEMENT_RESIDUAL_EVALUATE",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_FINITE_ELEMENT_RESIDUAL_EVALUATE")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_FINITE_ELEMENT_RESIDUAL_EVALUATE

  !
  !================================================================================================================================
  !

  !>Evaluates the Jacobian element stiffness matrices and RHS for a Navier-Stokes equation finite element equations set.
  SUBROUTINE NAVIER_STOKES_FINITE_ELEMENT_JACOBIAN_EVALUATE(EQUATIONS_SET,ELEMENT_NUMBER,ERR,ERROR,*)

    !Argument variables
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set to perform the finite element calculations on
    INTEGER(INTG), INTENT(IN) :: ELEMENT_NUMBER !<The element number to calculate
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) FIELD_VAR_TYPE,ng,mh,mhs,mi,ms,nh,nhs,ni,ns,MESH_COMPONENT1,MESH_COMPONENT2, nhs_max, mhs_max, nhs_min, mhs_min
    REAL(DP) :: JGW,SUM,DXI_DX(3,3),PHIMS,PHINS,MU_PARAM,RHO_PARAM,E_PARAM,H0_PARAM,A0_PARAM,SIGMA_PARAM,DPHIMS_DXI(3),DPHINS_DXI(3)
    REAL(DP), POINTER :: BIF_VALUES(:)
    TYPE(BASIS_TYPE), POINTER :: DEPENDENT_BASIS,DEPENDENT_BASIS1,DEPENDENT_BASIS2,GEOMETRIC_BASIS,INDEPENDENT_BASIS
    TYPE(EQUATIONS_TYPE), POINTER :: EQUATIONS
    TYPE(EQUATIONS_MAPPING_TYPE), POINTER :: EQUATIONS_MAPPING
    TYPE(EQUATIONS_MAPPING_LINEAR_TYPE), POINTER :: LINEAR_MAPPING
    TYPE(EQUATIONS_MAPPING_DYNAMIC_TYPE), POINTER :: DYNAMIC_MAPPING
    TYPE(EQUATIONS_MAPPING_NONLINEAR_TYPE), POINTER :: NONLINEAR_MAPPING
    TYPE(EQUATIONS_MATRICES_TYPE), POINTER :: EQUATIONS_MATRICES
    TYPE(EQUATIONS_MATRICES_LINEAR_TYPE), POINTER :: LINEAR_MATRICES
    TYPE(EQUATIONS_MATRICES_DYNAMIC_TYPE), POINTER :: DYNAMIC_MATRICES
    TYPE(EQUATIONS_MATRICES_NONLINEAR_TYPE), POINTER :: NONLINEAR_MATRICES
    TYPE(EQUATIONS_JACOBIAN_TYPE), POINTER :: JACOBIAN_MATRIX
    TYPE(EQUATIONS_MATRIX_TYPE), POINTER :: STIFFNESS_MATRIX !, DAMPING_MATRIX
    TYPE(FIELD_TYPE), POINTER :: DEPENDENT_FIELD,GEOMETRIC_FIELD,MATERIALS_FIELD,INDEPENDENT_FIELD
    TYPE(FIELD_VARIABLE_TYPE), POINTER :: FIELD_VARIABLE
    TYPE(QUADRATURE_SCHEME_TYPE), POINTER :: QUADRATURE_SCHEME,QUADRATURE_SCHEME1,QUADRATURE_SCHEME2
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    INTEGER(INTG) :: x

    LOGICAL :: UPDATE_JACOBIAN_MATRIX

    !REAL(DP) :: test(89,89),test2(89,89),scaling,square
    REAL(DP) :: J1_MATRIX(256,256) ! "A" Matrix ("G"radient part) - maximum size allocated
    REAL(DP) :: J2_MATRIX(256,256) ! "A" Matrix ("L"aplace part) - maximum size allocated
    REAL(DP) :: J_MATRIX(256,256)
    REAL(DP) :: U_VALUE(3),W_VALUE(3),A_VALUE,U_BI_VALUE(3),A_BI_VALUE(3)!,P_VALUE
    REAL(DP) :: U_DERIV(3,3),A_DERIV!,P_DERIV

    CALL ENTERS("NAVIER_STOKES_FINITE_ELEMENT_JACOBIAN_EVALUATE",ERR,ERROR,*999)

    J1_MATRIX=0.0_DP
    J2_MATRIX=0.0_DP
    J_MATRIX=0.0_DP

!\todo: Check whether or not update flags work properly and how much time is spent in each section

    UPDATE_JACOBIAN_MATRIX=.FALSE.

    IF(ASSOCIATED(EQUATIONS_SET)) THEN
      NULLIFY(EQUATIONS)
      EQUATIONS=>EQUATIONS_SET%EQUATIONS
      IF(ASSOCIATED(EQUATIONS)) THEN
        SELECT CASE(EQUATIONS_SET%SUBTYPE)
          CASE(EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE, &
            & EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE, &
            & EQUATIONS_SET_PGM_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_QUASISTATIC_NAVIER_STOKES_SUBTYPE, &
            & EQUATIONS_SET_1DTRANSIENT_NAVIER_STOKES_SUBTYPE)
            !Set some general and case-specific pointers
            DEPENDENT_FIELD=>EQUATIONS%INTERPOLATION%DEPENDENT_FIELD
            GEOMETRIC_FIELD=>EQUATIONS%INTERPOLATION%GEOMETRIC_FIELD
            MATERIALS_FIELD=>EQUATIONS%INTERPOLATION%MATERIALS_FIELD
            EQUATIONS_MATRICES=>EQUATIONS%EQUATIONS_MATRICES
            GEOMETRIC_BASIS=>GEOMETRIC_FIELD%DECOMPOSITION%DOMAIN(GEOMETRIC_FIELD%DECOMPOSITION%MESH_COMPONENT_NUMBER)%PTR% &
              & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
            DEPENDENT_BASIS=>DEPENDENT_FIELD%DECOMPOSITION%DOMAIN(DEPENDENT_FIELD%DECOMPOSITION%MESH_COMPONENT_NUMBER)%PTR% &
              & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
            QUADRATURE_SCHEME=>DEPENDENT_BASIS%QUADRATURE%QUADRATURE_SCHEME_MAP(BASIS_DEFAULT_QUADRATURE_SCHEME)%PTR
!            RHS_VECTOR=>EQUATIONS_MATRICES%RHS_VECTOR
            EQUATIONS_MAPPING=>EQUATIONS%EQUATIONS_MAPPING
            SELECT CASE(EQUATIONS_SET%SUBTYPE)
              CASE(EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE, &
                & EQUATIONS_SET_QUASISTATIC_NAVIER_STOKES_SUBTYPE)
                LINEAR_MATRICES=>EQUATIONS_MATRICES%LINEAR_MATRICES
                NONLINEAR_MATRICES=>EQUATIONS_MATRICES%NONLINEAR_MATRICES
                JACOBIAN_MATRIX=>NONLINEAR_MATRICES%JACOBIANS(1)%PTR
                STIFFNESS_MATRIX=>LINEAR_MATRICES%MATRICES(1)%PTR
                LINEAR_MAPPING=>EQUATIONS_MAPPING%LINEAR_MAPPING
                NONLINEAR_MAPPING=>EQUATIONS_MAPPING%NONLINEAR_MAPPING
                FIELD_VARIABLE=>NONLINEAR_MAPPING%RESIDUAL_VARIABLES(1)%PTR
                FIELD_VAR_TYPE=FIELD_VARIABLE%VARIABLE_TYPE
!               SOURCE_VECTOR=>EQUATIONS_MATRICES%SOURCE_VECTOR
                STIFFNESS_MATRIX%ELEMENT_MATRIX%MATRIX=0.0_DP
                NONLINEAR_MATRICES%ELEMENT_RESIDUAL%VECTOR=0.0_DP
                IF(ASSOCIATED(JACOBIAN_MATRIX)) UPDATE_JACOBIAN_MATRIX=JACOBIAN_MATRIX%UPDATE_JACOBIAN
              CASE(EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE)
                NONLINEAR_MAPPING=>EQUATIONS_MAPPING%NONLINEAR_MAPPING
                NONLINEAR_MATRICES=>EQUATIONS_MATRICES%NONLINEAR_MATRICES
                JACOBIAN_MATRIX=>NONLINEAR_MATRICES%JACOBIANS(1)%PTR
                JACOBIAN_MATRIX%ELEMENT_JACOBIAN%MATRIX=0.0_DP
                DYNAMIC_MATRICES=>EQUATIONS_MATRICES%DYNAMIC_MATRICES
                DYNAMIC_MAPPING=>EQUATIONS_MAPPING%DYNAMIC_MAPPING
                FIELD_VARIABLE=>NONLINEAR_MAPPING%RESIDUAL_VARIABLES(1)%PTR
                FIELD_VAR_TYPE=FIELD_VARIABLE%VARIABLE_TYPE
                LINEAR_MAPPING=>EQUATIONS_MAPPING%LINEAR_MAPPING
                IF(ASSOCIATED(JACOBIAN_MATRIX)) UPDATE_JACOBIAN_MATRIX=JACOBIAN_MATRIX%UPDATE_JACOBIAN
              CASE(EQUATIONS_SET_1DTRANSIENT_NAVIER_STOKES_SUBTYPE)
                NONLINEAR_MAPPING=>EQUATIONS_MAPPING%NONLINEAR_MAPPING
                NONLINEAR_MATRICES=>EQUATIONS_MATRICES%NONLINEAR_MATRICES
                JACOBIAN_MATRIX=>NONLINEAR_MATRICES%JACOBIANS(1)%PTR
                JACOBIAN_MATRIX%ELEMENT_JACOBIAN%MATRIX=0.0_DP
                DYNAMIC_MATRICES=>EQUATIONS_MATRICES%DYNAMIC_MATRICES
                DYNAMIC_MAPPING=>EQUATIONS_MAPPING%DYNAMIC_MAPPING
                FIELD_VARIABLE=>NONLINEAR_MAPPING%RESIDUAL_VARIABLES(1)%PTR
                FIELD_VAR_TYPE=FIELD_VARIABLE%VARIABLE_TYPE
                LINEAR_MAPPING=>EQUATIONS_MAPPING%LINEAR_MAPPING
                IF(ASSOCIATED(JACOBIAN_MATRIX)) UPDATE_JACOBIAN_MATRIX=JACOBIAN_MATRIX%UPDATE_JACOBIAN
              CASE(EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE,EQUATIONS_SET_PGM_NAVIER_STOKES_SUBTYPE)
                INDEPENDENT_FIELD=>EQUATIONS%INTERPOLATION%INDEPENDENT_FIELD
                INDEPENDENT_BASIS=>INDEPENDENT_FIELD%DECOMPOSITION%DOMAIN(INDEPENDENT_FIELD%DECOMPOSITION%MESH_COMPONENT_NUMBER)% & 
                  & PTR%TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
                NONLINEAR_MAPPING=>EQUATIONS_MAPPING%NONLINEAR_MAPPING
                NONLINEAR_MATRICES=>EQUATIONS_MATRICES%NONLINEAR_MATRICES
                JACOBIAN_MATRIX=>NONLINEAR_MATRICES%JACOBIANS(1)%PTR
                JACOBIAN_MATRIX%ELEMENT_JACOBIAN%MATRIX=0.0_DP
                DYNAMIC_MATRICES=>EQUATIONS_MATRICES%DYNAMIC_MATRICES
                DYNAMIC_MAPPING=>EQUATIONS_MAPPING%DYNAMIC_MAPPING
                FIELD_VARIABLE=>NONLINEAR_MAPPING%RESIDUAL_VARIABLES(1)%PTR
                FIELD_VAR_TYPE=FIELD_VARIABLE%VARIABLE_TYPE
                LINEAR_MAPPING=>EQUATIONS_MAPPING%LINEAR_MAPPING
                IF(ASSOCIATED(JACOBIAN_MATRIX)) UPDATE_JACOBIAN_MATRIX=JACOBIAN_MATRIX%UPDATE_JACOBIAN
                CALL FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET(FIELD_MESH_VELOCITY_SET_TYPE,ELEMENT_NUMBER,EQUATIONS% & 
                  & INTERPOLATION%INDEPENDENT_INTERP_PARAMETERS(FIELD_U_VARIABLE_TYPE)%PTR,ERR,ERROR,*999)
              CASE DEFAULT
                LOCAL_ERROR="Equations set subtype "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
                  & " is not valid for a Navier-Stokes fluid type of a fluid mechanics equations set class."
                CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
            END SELECT
            CALL FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET(FIELD_VALUES_SET_TYPE,ELEMENT_NUMBER,EQUATIONS%INTERPOLATION% &
              & DEPENDENT_INTERP_PARAMETERS(FIELD_VAR_TYPE)%PTR,ERR,ERROR,*999)
            CALL FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET(FIELD_VALUES_SET_TYPE,ELEMENT_NUMBER,EQUATIONS%INTERPOLATION% &
              & GEOMETRIC_INTERP_PARAMETERS(FIELD_U_VARIABLE_TYPE)%PTR,ERR,ERROR,*999)
            CALL FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET(FIELD_VALUES_SET_TYPE,ELEMENT_NUMBER,EQUATIONS%INTERPOLATION% &
              & MATERIALS_INTERP_PARAMETERS(FIELD_U_VARIABLE_TYPE)%PTR,ERR,ERROR,*999)
            !Loop over all Gauss points 
            DO ng=1,QUADRATURE_SCHEME%NUMBER_OF_GAUSS
 !               CALL FIELD_INTERPOLATE_GAUSS(NO_PART_DERIV,BASIS_DEFAULT_QUADRATURE_SCHEME,ng,EQUATIONS%INTERPOLATION% &
              CALL FIELD_INTERPOLATE_GAUSS(FIRST_PART_DERIV,BASIS_DEFAULT_QUADRATURE_SCHEME,ng,EQUATIONS%INTERPOLATION% &
                & DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR,ERR,ERROR,*999)
              CALL FIELD_INTERPOLATE_GAUSS(FIRST_PART_DERIV,BASIS_DEFAULT_QUADRATURE_SCHEME,ng,EQUATIONS%INTERPOLATION% &
                & GEOMETRIC_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR,ERR,ERROR,*999)
              CALL FIELD_INTERPOLATED_POINT_METRICS_CALCULATE(GEOMETRIC_BASIS%NUMBER_OF_XI,EQUATIONS%INTERPOLATION% &
                & GEOMETRIC_INTERP_POINT_METRICS(FIELD_U_VARIABLE_TYPE)%PTR,ERR,ERROR,*999)
              CALL FIELD_INTERPOLATE_GAUSS(NO_PART_DERIV,BASIS_DEFAULT_QUADRATURE_SCHEME,ng,EQUATIONS%INTERPOLATION% &
                & MATERIALS_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR,ERR,ERROR,*999)
              IF(EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE.OR. &
                & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_PGM_NAVIER_STOKES_SUBTYPE) THEN
                CALL FIELD_INTERPOLATE_GAUSS(FIRST_PART_DERIV,BASIS_DEFAULT_QUADRATURE_SCHEME,ng,EQUATIONS%INTERPOLATION% &
                  & INDEPENDENT_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR,ERR,ERROR,*999)
                  W_VALUE(1)=EQUATIONS%INTERPOLATION%INDEPENDENT_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR%VALUES(1,NO_PART_DERIV)
                  W_VALUE(2)=EQUATIONS%INTERPOLATION%INDEPENDENT_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR%VALUES(2,NO_PART_DERIV)
                  IF(FIELD_VARIABLE%NUMBER_OF_COMPONENTS==4) THEN
                    W_VALUE(3)=EQUATIONS%INTERPOLATION%INDEPENDENT_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR%VALUES(3,NO_PART_DERIV)
                  END IF 
              ELSE
                W_VALUE=0.0_DP
              END IF
              !Define MU_PARAM, viscosity=1
              MU_PARAM=EQUATIONS%INTERPOLATION%MATERIALS_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR%VALUES(1,NO_PART_DERIV)
              !Define RHO_PARAM, density=2
              RHO_PARAM=EQUATIONS%INTERPOLATION%MATERIALS_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR%VALUES(2,NO_PART_DERIV)

             IF(EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE.OR.  &
                  & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE.OR. &
                  & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE.OR. &
                  & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_QUASISTATIC_NAVIER_STOKES_SUBTYPE.OR. &
                  & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE.OR. &
                  & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_PGM_NAVIER_STOKES_SUBTYPE) THEN

                U_VALUE(1)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(1,NO_PART_DERIV)
                U_VALUE(2)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(2,NO_PART_DERIV)
                U_DERIV(1,1)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(1,PART_DERIV_S1)
                U_DERIV(1,2)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(1,PART_DERIV_S2)
                U_DERIV(2,1)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(2,PART_DERIV_S1)
                U_DERIV(2,2)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(2,PART_DERIV_S2)
                IF(FIELD_VARIABLE%NUMBER_OF_COMPONENTS==4) THEN
                  U_VALUE(3)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(3,NO_PART_DERIV)
                  U_DERIV(3,1)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(3,PART_DERIV_S1)
                  U_DERIV(3,2)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(3,PART_DERIV_S2)
                  U_DERIV(3,3)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(3,PART_DERIV_S3)
                  U_DERIV(1,3)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(1,PART_DERIV_S3)
                  U_DERIV(2,3)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(2,PART_DERIV_S3)
                ELSE
                  U_VALUE(3)=0.0_DP
                  U_DERIV(3,1)=0.0_DP
                  U_DERIV(3,2)=0.0_DP
                  U_DERIV(3,3)=0.0_DP
                  U_DERIV(1,3)=0.0_DP
                  U_DERIV(2,3)=0.0_DP
                END IF
                !Start with calculation of partial matrices
                !Here W_VALUES must be ZERO if ALE part of linear matrix
                W_VALUE=0.0_DP
             END IF

              IF(EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE.OR.  &
                & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE.OR. &
                & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE.OR. &
                & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_QUASISTATIC_NAVIER_STOKES_SUBTYPE.OR. &
                & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE.OR. &
                & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_PGM_NAVIER_STOKES_SUBTYPE) THEN
                !Loop over field components
                mhs=0
                DO mh=1,FIELD_VARIABLE%NUMBER_OF_COMPONENTS-1
                  MESH_COMPONENT1=FIELD_VARIABLE%COMPONENTS(mh)%MESH_COMPONENT_NUMBER
                  DEPENDENT_BASIS1=>DEPENDENT_FIELD%DECOMPOSITION%DOMAIN(MESH_COMPONENT1)%PTR% &
                    & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
                  QUADRATURE_SCHEME1=>DEPENDENT_BASIS1%QUADRATURE%QUADRATURE_SCHEME_MAP(BASIS_DEFAULT_QUADRATURE_SCHEME)%PTR
                  JGW=EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT_METRICS(FIELD_U_VARIABLE_TYPE)%PTR%JACOBIAN* &
                    & QUADRATURE_SCHEME1%GAUSS_WEIGHTS(ng)
                  DO ms=1,DEPENDENT_BASIS1%NUMBER_OF_ELEMENT_PARAMETERS
                    mhs=mhs+1
                    nhs=0
                    IF(UPDATE_JACOBIAN_MATRIX) THEN
                      !Loop over element columns
                      DO nh=1,FIELD_VARIABLE%NUMBER_OF_COMPONENTS-1
                        MESH_COMPONENT2=FIELD_VARIABLE%COMPONENTS(nh)%MESH_COMPONENT_NUMBER
                        DEPENDENT_BASIS2=>DEPENDENT_FIELD%DECOMPOSITION%DOMAIN(MESH_COMPONENT2)%PTR% &
                          & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
                        QUADRATURE_SCHEME2=>DEPENDENT_BASIS2%QUADRATURE%QUADRATURE_SCHEME_MAP&
                          &(BASIS_DEFAULT_QUADRATURE_SCHEME)%PTR
                        ! JGW=EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT_METRICS%JACOBIAN*QUADRATURE_SCHEME2%&
                        ! &GAUSS_WEIGHTS(ng)                        
                        DO ns=1,DEPENDENT_BASIS2%NUMBER_OF_ELEMENT_PARAMETERS
                          nhs=nhs+1
                          !Calculate some general values needed below
!\todo: Check how much time is spent here 
                          DO ni=1,DEPENDENT_BASIS2%NUMBER_OF_XI
                            DO mi=1,DEPENDENT_BASIS1%NUMBER_OF_XI
                              DXI_DX(mi,ni)=EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT_METRICS(FIELD_U_VARIABLE_TYPE)%PTR% &
                                & DXI_DX(mi,ni)
                            END DO
                            DPHIMS_DXI(ni)=QUADRATURE_SCHEME1%GAUSS_BASIS_FNS(ms,PARTIAL_DERIVATIVE_FIRST_DERIVATIVE_MAP(ni),ng)
                            DPHINS_DXI(ni)=QUADRATURE_SCHEME2%GAUSS_BASIS_FNS(ns,PARTIAL_DERIVATIVE_FIRST_DERIVATIVE_MAP(ni),ng)
                          END DO !ni
                            PHIMS=QUADRATURE_SCHEME1%GAUSS_BASIS_FNS(ms,NO_PART_DERIV,ng)
                            PHINS=QUADRATURE_SCHEME2%GAUSS_BASIS_FNS(ns,NO_PART_DERIV,ng)
                          SUM=0.0_DP
                          IF(UPDATE_JACOBIAN_MATRIX) THEN
                            !Calculate J1 only
                            DO ni=1,DEPENDENT_BASIS1%NUMBER_OF_XI
                              SUM=SUM+(PHINS*U_DERIV(mh,ni)*DXI_DX(ni,nh)*PHIMS*RHO_PARAM)
                            ENDDO 
                            !Calculate MATRIX  
                            J1_MATRIX(mhs,nhs)=J1_MATRIX(mhs,nhs)+SUM*JGW
                            !Calculate J2 only
                            IF(nh==mh) THEN 
                              SUM=0.0_DP
                              !Calculate SUM 
                              DO x=1,DEPENDENT_BASIS1%NUMBER_OF_XI
                                DO mi=1,DEPENDENT_BASIS2%NUMBER_OF_XI
                                  SUM=SUM+RHO_PARAM*(U_VALUE(x)-W_VALUE(x))*DPHINS_DXI(mi)*DXI_DX(mi,x)*PHIMS
                                ENDDO !mi
                              ENDDO !x
                              !Calculate MATRIX
                              J2_MATRIX(mhs,nhs)=J2_MATRIX(mhs,nhs)+SUM*JGW
                            END IF
                          END IF
                        ENDDO !ns    
                      ENDDO !nh
                    ENDIF
                  ENDDO !ms
                ENDDO !mh
              END IF

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! 1D TRANSIENT !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

              IF(EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_1DTRANSIENT_NAVIER_STOKES_SUBTYPE) THEN
                U_VALUE(1)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(1,NO_PART_DERIV)
                A_VALUE=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(2,NO_PART_DERIV)
!                P_VALUE=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(3,NO_PART_DERIV)
                U_DERIV(1,1)=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(1,FIRST_PART_DERIV)
                A_DERIV=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(2,FIRST_PART_DERIV)
!                P_DERIV=EQUATIONS%INTERPOLATION%DEPENDENT_INTERP_POINT(FIELD_VAR_TYPE)%PTR%VALUES(3,FIRST_PART_DERIV)
                MU_PARAM=EQUATIONS%INTERPOLATION%MATERIALS_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR%VALUES(1,NO_PART_DERIV)
                RHO_PARAM=EQUATIONS%INTERPOLATION%MATERIALS_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR%VALUES(2,NO_PART_DERIV)
                E_PARAM=EQUATIONS%INTERPOLATION%MATERIALS_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR%VALUES(3,NO_PART_DERIV)
                H0_PARAM=EQUATIONS%INTERPOLATION%MATERIALS_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR%VALUES(4,NO_PART_DERIV)
                A0_PARAM=EQUATIONS%INTERPOLATION%MATERIALS_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR%VALUES(5,NO_PART_DERIV)
                SIGMA_PARAM=EQUATIONS%INTERPOLATION%MATERIALS_INTERP_POINT(FIELD_U_VARIABLE_TYPE)%PTR%VALUES(6,NO_PART_DERIV)

                !Loop over field components
                mhs=0
                DO mh=1,FIELD_VARIABLE%NUMBER_OF_COMPONENTS
                  MESH_COMPONENT1=FIELD_VARIABLE%COMPONENTS(mh)%MESH_COMPONENT_NUMBER
                  DEPENDENT_BASIS1=>DEPENDENT_FIELD%DECOMPOSITION%DOMAIN(MESH_COMPONENT1)%PTR% &
                    & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
                  QUADRATURE_SCHEME1=>DEPENDENT_BASIS1%QUADRATURE%QUADRATURE_SCHEME_MAP(BASIS_DEFAULT_QUADRATURE_SCHEME)%PTR
                  JGW=EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT_METRICS(FIELD_U_VARIABLE_TYPE)%PTR%JACOBIAN* &
                    & QUADRATURE_SCHEME1%GAUSS_WEIGHTS(ng)

                  DO ms=1,DEPENDENT_BASIS1%NUMBER_OF_ELEMENT_PARAMETERS
                    mhs=mhs+1
                    nhs=0

                    IF(UPDATE_JACOBIAN_MATRIX) THEN
                      !Loop over element columns
                     DO nh=1,FIELD_VARIABLE%NUMBER_OF_COMPONENTS
                        MESH_COMPONENT1=FIELD_VARIABLE%COMPONENTS(nh)%MESH_COMPONENT_NUMBER
                        DEPENDENT_BASIS1=>DEPENDENT_FIELD%DECOMPOSITION%DOMAIN(MESH_COMPONENT1)%PTR% &
                          & TOPOLOGY%ELEMENTS%ELEMENTS(ELEMENT_NUMBER)%BASIS
                        QUADRATURE_SCHEME1=>DEPENDENT_BASIS1%QUADRATURE%QUADRATURE_SCHEME_MAP&
                          &(BASIS_DEFAULT_QUADRATURE_SCHEME)%PTR
                        ! JGW=EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT_METRICS%JACOBIAN*QUADRATURE_SCHEME2%GAUSS_WEIGHTS(ng)

                        DO ns=1,DEPENDENT_BASIS1%NUMBER_OF_ELEMENT_PARAMETERS
                          nhs=nhs+1
 
                          DXI_DX(1,1)=EQUATIONS%INTERPOLATION%GEOMETRIC_INTERP_POINT_METRICS(FIELD_U_VARIABLE_TYPE)%PTR%DXI_DX(1,1)
                          DPHIMS_DXI(1)=QUADRATURE_SCHEME1%GAUSS_BASIS_FNS(ms,FIRST_PART_DERIV,ng)
                          DPHINS_DXI(1)=QUADRATURE_SCHEME1%GAUSS_BASIS_FNS(ns,FIRST_PART_DERIV,ng)
                          PHIMS=QUADRATURE_SCHEME1%GAUSS_BASIS_FNS(ms,NO_PART_DERIV,ng)
                          PHINS=QUADRATURE_SCHEME1%GAUSS_BASIS_FNS(ns,NO_PART_DERIV,ng)

!                          !J1 ONLY
!                          IF(mh==1) THEN
!                            IF(nh==1) THEN
!                              SUM=(  ( PHINS*U_DERIV(1,1)+U_VALUE(1)*DPHINS_DXI(1) )*DXI_DX(1,1)  )*PHIMS
!                              J_MATRIX(mhs,nhs)=J_MATRIX(mhs,nhs)+SUM*JGW
!                            END IF
!                          END IF
!
!                          !J2 ONLY
!                          IF(mh==2) THEN
!                            IF(nh==1) THEN
!                              SUM=(  ( PHINS*A_DERIV+A_VALUE*DPHINS_DXI(1)  )*DXI_DX(1,1)  )*PHIMS
!                              J_MATRIX(mhs,nhs)=J_MATRIX(mhs,nhs)+SUM*JGW
!                            END IF
!                          END IF
!
!                          !J3 ONLY
!                          IF(mh==2) THEN
!                            IF(nh==2) THEN
!                              SUM=(  ( PHINS*U_DERIV(1,1)+U_VALUE(1)*DPHINS_DXI(1) )*DXI_DX(1,1)  )*PHIMS
!                              J_MATRIX(mhs,nhs)=J_MATRIX(mhs,nhs)+SUM*JGW
!                            END IF
!                          END IF

                        !--JACOBIAN MATRIX BIFURCATION MATRIX--!
                        IF(ELEMENT_NUMBER==1) THEN
                          !J1 ONLY
                          IF(mh==1) THEN
                            IF(nh==1) THEN
                              SUM=((PHINS*U_DERIV(1,1)+U_VALUE(1)*DPHINS_DXI(1))*DXI_DX(1,1) + &
                                 & (8*3.1416*.0033*PHINS/A_VALUE))*PHIMS
                              J_MATRIX(mhs,nhs)=J_MATRIX(mhs,nhs)+SUM*JGW
                            END IF
                          END IF

                          !J2 ONLY
                          IF(mh==1) THEN
                            IF(nh==2) THEN
                              SUM=(-8*3.1416*.0033*PHINS*U_VALUE(1)/(A_VALUE**2))*PHIMS
                              J_MATRIX(mhs,nhs+3)=J_MATRIX(mhs,nhs+3)+SUM*JGW
                            END IF
                          END IF

                          !J3 ONLY
                          IF(mh==2) THEN
                            IF(nh==1) THEN
                              SUM=(  ( PHINS*A_DERIV+A_VALUE*DPHINS_DXI(1)  )*DXI_DX(1,1)  )*PHIMS
                              J_MATRIX(mhs+3,nhs)=J_MATRIX(mhs+3,nhs)+SUM*JGW
                            END IF
                          END IF

                          !J4 ONLY
                          IF(mh==2) THEN
                            IF(nh==2) THEN
                              SUM=(  ( PHINS*U_DERIV(1,1)+U_VALUE(1)*DPHINS_DXI(1) )*DXI_DX(1,1)  )*PHIMS
                              J_MATRIX(mhs+3,nhs+3)=J_MATRIX(mhs+3,nhs+3)+SUM*JGW
                            END IF
                          END IF

                          IF(mh==2 .AND. ms==1 .AND. nh==2) THEN
                            SUM=-4*( ((2*1.7725*H0_PARAM*E_PARAM)/(3*18.1*RHO_PARAM))**0.5 )* &
                               & ( 0.25*PHINS*(A_VALUE**(-0.75)) )
                            J_MATRIX(mhs,nhs+3)=J_MATRIX(mhs,nhs+3)+SUM*JGW
                          END IF

                        ELSEIF(ELEMENT_NUMBER==2) THEN
                          !J1 ONLY
                          IF(mh==1) THEN
                            IF(nh==1) THEN
                              SUM=((PHINS*U_DERIV(1,1)+U_VALUE(1)*DPHINS_DXI(1))*DXI_DX(1,1) + &
                                 & (8*3.1416*.0033*PHINS/A_VALUE))*PHIMS
                              J_MATRIX(mhs+3,nhs+3)=J_MATRIX(mhs+3,nhs+3)+SUM*JGW
                            END IF
                          END IF

                          !J2 ONLY
                          IF(mh==1) THEN
                            IF(nh==2) THEN
                              SUM=(-8*3.1416*.0033*PHINS*U_VALUE(1)/(A_VALUE**2))*PHIMS
                              J_MATRIX(mhs+3,nhs+6)=J_MATRIX(mhs+3,nhs+6)+SUM*JGW
                            END IF
                          END IF

                          !J3 ONLY
                          IF(mh==2) THEN
                            IF(nh==1) THEN
                              SUM=(  ( PHINS*A_DERIV+A_VALUE*DPHINS_DXI(1)  )*DXI_DX(1,1)  )*PHIMS
                              J_MATRIX(mhs+6,nhs+3)=J_MATRIX(mhs+6,nhs+3)+SUM*JGW
                            END IF
                          END IF

                          !J4 ONLY
                          IF(mh==2) THEN
                            IF(nh==2) THEN
                              SUM=(  ( PHINS*U_DERIV(1,1)+U_VALUE(1)*DPHINS_DXI(1) )*DXI_DX(1,1)  )*PHIMS
                              J_MATRIX(mhs+6,nhs+6)=J_MATRIX(mhs+6,nhs+6)+SUM*JGW
                            END IF
                          END IF

                          IF(mh==1 .AND. ms==2 .AND. nh==2) THEN
                            SUM=4*( ((2*1.7725*H0_PARAM*E_PARAM)/(3*11.4*RHO_PARAM))**0.5 )* &
                               & ( 0.25*PHINS*(A_VALUE**(-0.75)) ) 
                            J_MATRIX(mhs,nhs+6)=J_MATRIX(mhs,nhs+6)+SUM*JGW
                          END IF

                        ELSEIF(ELEMENT_NUMBER==3) THEN
                          !J1 ONLY
                          IF(mh==1) THEN
                            IF(nh==1) THEN
                              SUM=((PHINS*U_DERIV(1,1)+U_VALUE(1)*DPHINS_DXI(1))*DXI_DX(1,1) + &
                                 & (8*3.1416*.0033*PHINS/A_VALUE))*PHIMS
                              J_MATRIX(mhs+3,nhs+3)=J_MATRIX(mhs+3,nhs+3)+SUM*JGW
                            END IF
                          END IF

                          !J2 ONLY
                          IF(mh==1) THEN
                            IF(nh==2) THEN
                              SUM=(-8*3.1416*.0033*PHINS*U_VALUE(1)/(A_VALUE**2))*PHIMS
                              J_MATRIX(mhs+3,nhs+6)=J_MATRIX(mhs+3,nhs+6)+SUM*JGW
                            END IF
                          END IF

                          !J3 ONLY
                          IF(mh==2) THEN
                            IF(nh==1) THEN
                              SUM=(  ( PHINS*A_DERIV+A_VALUE*DPHINS_DXI(1)  )*DXI_DX(1,1)  )*PHIMS
                              J_MATRIX(mhs+6,nhs+3)=J_MATRIX(mhs+6,nhs+3)+SUM*JGW
                            END IF
                          END IF

                          !J4 ONLY
                          IF(mh==2) THEN
                            IF(nh==2) THEN
                              SUM=(  ( PHINS*U_DERIV(1,1)+U_VALUE(1)*DPHINS_DXI(1) )*DXI_DX(1,1)  )*PHIMS
                              J_MATRIX(mhs+6,nhs+6)=J_MATRIX(mhs+6,nhs+6)+SUM*JGW
                            END IF
                          END IF

                          IF(mh==1 .AND. ms==3 .AND. nh==2) THEN
                            SUM=4*( ((2*1.7725*H0_PARAM*E_PARAM)/(3*11.4*RHO_PARAM))**0.5 )* &
                               & ( 0.25*PHINS*(A_VALUE**(-0.75) ) )   
                            J_MATRIX(mhs,nhs+6)=J_MATRIX(mhs,nhs+6)+SUM*JGW
                          ENDIF
                        END IF
                        ENDDO !ns
                      ENDDO !nh
                    ENDIF
                  ENDDO !ms
                ENDDO !mh
              END IF
        ENDDO !ng

            !Assemble matrices and vectors 
            mhs_min=mhs
            mhs_max=nhs
            nhs_min=mhs
            nhs_max=nhs
            IF (EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_STATIC_NAVIER_STOKES_SUBTYPE.OR. &
              & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_LAPLACE_NAVIER_STOKES_SUBTYPE.OR. &
              & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_TRANSIENT_NAVIER_STOKES_SUBTYPE.OR. &
              & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_QUASISTATIC_NAVIER_STOKES_SUBTYPE.OR. &
              & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_ALE_NAVIER_STOKES_SUBTYPE.OR. &
              & EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_PGM_NAVIER_STOKES_SUBTYPE) THEN
              !Assemble Jacobian matrix first
              IF(UPDATE_JACOBIAN_MATRIX) THEN
                JACOBIAN_MATRIX%ELEMENT_JACOBIAN%MATRIX(1:mhs_min,1:nhs_min)=J1_MATRIX(1:mhs_min,1:nhs_min)+ & 
                  & J2_MATRIX(1:mhs_min,1:nhs_min)
              END IF
            ENDIF

            IF(EQUATIONS_SET%SUBTYPE==EQUATIONS_SET_1DTRANSIENT_NAVIER_STOKES_SUBTYPE) THEN
              IF(UPDATE_JACOBIAN_MATRIX) THEN
              !--JACOBIAN MATRIX BIFURCATION MATRIX--!
              NULLIFY(BIF_VALUES)
              CALL FIELD_PARAMETER_SET_DATA_GET(DEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, &
                  & FIELD_VALUES_SET_TYPE,BIF_VALUES,ERR,ERROR,*999)

              U_BI_VALUE(1)=FIELD_VARIABLE%COMPONENTS(1)%PARAM_TO_DOF_MAP%NODE_PARAM2DOF_MAP%NODES(3)% & 
                     & DERIVATIVES(1)%VERSIONS(2)
              U_BI_VALUE(1)=BIF_VALUES(U_BI_VALUE(1))

              A_BI_VALUE(1)=FIELD_VARIABLE%COMPONENTS(2)%PARAM_TO_DOF_MAP%NODE_PARAM2DOF_MAP%NODES(3)% & 
                     & DERIVATIVES(1)%VERSIONS(2)
              A_BI_VALUE(1)=BIF_VALUES(A_BI_VALUE(1))

              U_BI_VALUE(2)=FIELD_VARIABLE%COMPONENTS(1)%PARAM_TO_DOF_MAP%NODE_PARAM2DOF_MAP%NODES(3)% & 
                     & DERIVATIVES(1)%VERSIONS(3)
              U_BI_VALUE(2)=BIF_VALUES(U_BI_VALUE(2))

              A_BI_VALUE(2)=FIELD_VARIABLE%COMPONENTS(2)%PARAM_TO_DOF_MAP%NODE_PARAM2DOF_MAP%NODES(3)% & 
                     & DERIVATIVES(1)%VERSIONS(3)
              A_BI_VALUE(2)=BIF_VALUES(A_BI_VALUE(2))

              U_BI_VALUE(3)=FIELD_VARIABLE%COMPONENTS(1)%PARAM_TO_DOF_MAP%NODE_PARAM2DOF_MAP%NODES(3)% & 
                     & DERIVATIVES(1)%VERSIONS(4)
              U_BI_VALUE(3)=BIF_VALUES(U_BI_VALUE(3))

              A_BI_VALUE(3)=FIELD_VARIABLE%COMPONENTS(2)%PARAM_TO_DOF_MAP%NODE_PARAM2DOF_MAP%NODES(3)% & 
                     & DERIVATIVES(1)%VERSIONS(4)
              A_BI_VALUE(3)=BIF_VALUES(A_BI_VALUE(3))

              CALL FIELD_PARAMETER_SET_DATA_RESTORE(DEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, &
                  & FIELD_VALUES_SET_TYPE,BIF_VALUES,ERR,ERROR,*999)

              !--JACOBIAN MATRIX BIFURCATION MATRIX--!
              IF(ELEMENT_NUMBER==1) THEN
                J_MATRIX(4,10)=4*( ((2*1.7725*H0_PARAM*E_PARAM)/(3*18.1*RHO_PARAM))**0.5 )* &
                             & ( 0.25*(A_BI_VALUE(1)**(-0.75)) )
                J_MATRIX(10,4)=A_BI_VALUE(1)
                J_MATRIX(10,10)=U_BI_VALUE(1)

              ELSEIF(ELEMENT_NUMBER==2) THEN
                J_MATRIX(2,8)=-4*( ((2*1.7725*H0_PARAM*E_PARAM)/(3*11.4*RHO_PARAM))**0.5 )* &
                             & ( 0.25*(A_BI_VALUE(2)**(-0.75)) ) 
                J_MATRIX(7,2)=-A_BI_VALUE(2)
                J_MATRIX(7,8)=-U_BI_VALUE(2)

              ELSEIF(ELEMENT_NUMBER==3) THEN
                J_MATRIX(3,9)=-4*( ((2*1.7725*H0_PARAM*E_PARAM)/(3*11.4*RHO_PARAM))**0.5 )* &
                             & ( 0.25*(A_BI_VALUE(3)**(-0.75) ))   
                J_MATRIX(7,3)=-A_BI_VALUE(3)
                J_MATRIX(7,9)=-U_BI_VALUE(3)

              ENDIF
              !--JACOBIAN MATRIX BIFURCATION MATRIX--!

                JACOBIAN_MATRIX%ELEMENT_JACOBIAN%MATRIX(1:mhs+6,1:nhs+6)=J_MATRIX(1:mhs+6,1:nhs+6)
              END IF
            ENDIF

          CASE DEFAULT
            LOCAL_ERROR="Equations set subtype "//TRIM(NUMBER_TO_VSTRING(EQUATIONS_SET%SUBTYPE,"*",ERR,ERROR))// &
              & " is not valid for a Navier-Stokes equation type of a fluid mechanics equations set class."
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
        END SELECT
      ELSE
        CALL FLAG_ERROR("Equations set equations is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
    ENDIF
       
    CALL EXITS("NAVIER_STOKES_FINITE_ELEMENT_JACOBIAN_EVALUATE")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_FINITE_ELEMENT_JACOBIAN_EVALUATE",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_FINITE_ELEMENT_JACOBIAN_EVALUATE")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_FINITE_ELEMENT_JACOBIAN_EVALUATE

  !
  !================================================================================================================================
  !

  !>Sets up the Navier-Stokes problem post solve.
  SUBROUTINE NAVIER_STOKES_POST_SOLVE(CONTROL_LOOP,SOLVER,ERR,ERROR,*)

    !Argument variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP !<A pointer to the control loop to solve.
    TYPE(SOLVER_TYPE), POINTER :: SOLVER!<A pointer to the solver
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(SOLVER_TYPE), POINTER :: SOLVER2 !<A pointer to the solver
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    CALL ENTERS("NAVIER_STOKES_POST_SOLVE",ERR,ERROR,*999)
    NULLIFY(SOLVER2)

    IF(ASSOCIATED(CONTROL_LOOP)) THEN
      IF(ASSOCIATED(SOLVER)) THEN
        IF(ASSOCIATED(CONTROL_LOOP%PROBLEM)) THEN 
          SELECT CASE(CONTROL_LOOP%PROBLEM%SUBTYPE)
            CASE(PROBLEM_STATIC_NAVIER_STOKES_SUBTYPE,PROBLEM_LAPLACE_NAVIER_STOKES_SUBTYPE)
              CALL NAVIER_STOKES_POST_SOLVE_OUTPUT_DATA(CONTROL_LOOP,SOLVER,ERR,ERROR,*999)
            CASE(PROBLEM_PGM_NAVIER_STOKES_SUBTYPE)
              CALL NAVIER_STOKES_POST_SOLVE_OUTPUT_DATA(CONTROL_LOOP,SOLVER,ERR,ERROR,*999)
            CASE(PROBLEM_QUASISTATIC_NAVIER_STOKES_SUBTYPE)
              CALL NAVIER_STOKES_POST_SOLVE_OUTPUT_DATA(CONTROL_LOOP,SOLVER,ERR,ERROR,*999)
            CASE(PROBLEM_TRANSIENT_NAVIER_STOKES_SUBTYPE)
              CALL NAVIER_STOKES_POST_SOLVE_OUTPUT_DATA(CONTROL_LOOP,SOLVER,ERR,ERROR,*999)
            CASE(PROBLEM_1DTRANSIENT_NAVIER_STOKES_SUBTYPE)
              CALL NAVIER_STOKES_POST_SOLVE_OUTPUT_DATA(CONTROL_LOOP,SOLVER,ERR,ERROR,*999)
            CASE(PROBLEM_ALE_NAVIER_STOKES_SUBTYPE)
              !Post solve for the linear solver
              IF(SOLVER%SOLVE_TYPE==SOLVER_LINEAR_TYPE) THEN
                CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"Mesh movement post solve... ",ERR,ERROR,*999)
                CALL SOLVERS_SOLVER_GET(SOLVER%SOLVERS,2,SOLVER2,ERR,ERROR,*999)
                IF(ASSOCIATED(SOLVER2%DYNAMIC_SOLVER)) THEN
                  SOLVER2%DYNAMIC_SOLVER%ALE=.TRUE.
                ELSE  
                  CALL FLAG_ERROR("Dynamic solver is not associated for ALE problem.",ERR,ERROR,*999)
                END IF
              !Post solve for the dynamic solver
              ELSE IF(SOLVER%SOLVE_TYPE==SOLVER_DYNAMIC_TYPE) THEN
                CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"ALE Navier-Stokes post solve... ",ERR,ERROR,*999)
                CALL NAVIER_STOKES_POST_SOLVE_OUTPUT_DATA(CONTROL_LOOP,SOLVER,ERR,ERROR,*999)
              END IF
            CASE DEFAULT
              LOCAL_ERROR="Problem subtype "//TRIM(NUMBER_TO_VSTRING(CONTROL_LOOP%PROBLEM%SUBTYPE,"*",ERR,ERROR))// &
                & " is not valid for a Navier-Stokes fluid type of a fluid mechanics problem class."
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        ELSE
          CALL FLAG_ERROR("Problem is not associated.",ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Solver is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Control loop is not associated.",ERR,ERROR,*999)
    ENDIF

    CALL EXITS("NAVIER_STOKES_POST_SOLVE")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_POST_SOLVE",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_POST_SOLVE")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_POST_SOLVE

  !
  !================================================================================================================================
  !


  !>Sets up the Navier-Stokes problem pre solve.
  SUBROUTINE NAVIER_STOKES_PRE_SOLVE(CONTROL_LOOP,SOLVER,ERR,ERROR,*)

    !Argument variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP !<A pointer to the control loop to solve.
    TYPE(SOLVER_TYPE), POINTER :: SOLVER !<A pointer to the solver
!     TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: SOLVER_EQUATIONS  !<A pointer to the solver equations
!     TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: SOLVER_EQUATIONS  !<A pointer to the solver equations
    TYPE(SOLVER_MAPPING_TYPE), POINTER :: SOLVER_MAPPING !<A pointer to the solver mapping
    TYPE(SOLVER_MATRICES_TYPE), POINTER :: SOLVER_MATRICES
    TYPE(SOLVER_MATRIX_TYPE), POINTER :: SOLVER_MATRIX
    TYPE(SOLVER_TYPE), POINTER :: SOLVER_NAVIER_STOKES  !<A pointer to the solvers
    TYPE(SOLVER_TYPE), POINTER :: SOLVER2 !<A pointer to the solvers
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    INTEGER(INTG) :: solver_matrix_idx

    CALL ENTERS("NAVIER_STOKES_PRE_SOLVE",ERR,ERROR,*999)
    NULLIFY(SOLVER2)
 
    IF(ASSOCIATED(CONTROL_LOOP)) THEN
      IF(ASSOCIATED(SOLVER)) THEN
        IF(ASSOCIATED(CONTROL_LOOP%PROBLEM)) THEN
          SELECT CASE(CONTROL_LOOP%PROBLEM%SUBTYPE)
            CASE(PROBLEM_STATIC_NAVIER_STOKES_SUBTYPE,PROBLEM_LAPLACE_NAVIER_STOKES_SUBTYPE)
              ! do nothing ???
            CASE(PROBLEM_TRANSIENT_NAVIER_STOKES_SUBTYPE)
                CALL NAVIER_STOKES_PRE_SOLVE_UPDATE_BOUNDARY_CONDITIONS(CONTROL_LOOP,SOLVER,ERR,ERROR,*999)
            CASE(PROBLEM_1DTRANSIENT_NAVIER_STOKES_SUBTYPE)
                !--- Set 'SOLVER_NUMBER' depending on CONTROL_LOOP%PROBLEM%SUBTYPE
                SOLVER_NUMBER_NAVIER_STOKES=1
                !--- Set explicitly 'SOLVER_MATRIX%UPDATE_MATRIX=.TRUE.'
                SOLVER_EQUATIONS=>SOLVER%SOLVER_EQUATIONS
                IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
                  SOLVER_MAPPING=>SOLVER_EQUATIONS%SOLVER_MAPPING
                  IF(ASSOCIATED(SOLVER_MAPPING)) THEN
                    SOLVER_MATRICES=>SOLVER_EQUATIONS%SOLVER_MATRICES
                    IF(ASSOCIATED(SOLVER_MATRICES)) THEN
                      DO solver_matrix_idx=1,SOLVER_MAPPING%NUMBER_OF_SOLVER_MATRICES
                        SOLVER_MATRIX=>SOLVER_MATRICES%MATRICES(solver_matrix_idx)%PTR
                        IF(ASSOCIATED(SOLVER_MATRIX)) THEN
                          SOLVER_MATRIX%UPDATE_MATRIX=.TRUE.
                        ELSE
                          CALL FLAG_ERROR("Solver Matrix is not associated.",ERR,ERROR,*999)
                        ENDIF
                      ENDDO
                    ELSE
                      CALL FLAG_ERROR("Solver Matrices is not associated.",ERR,ERROR,*999)
                    ENDIF
                  ELSE
                    CALL FLAG_ERROR("Solver mapping is not associated.",ERR,ERROR,*999)
                  ENDIF
                ELSE
                  CALL FLAG_ERROR("Solver equations is not associated.",ERR,ERROR,*999)
                ENDIF
                CALL NAVIER_STOKES_PRE_SOLVE_UPDATE_BOUNDARY_CONDITIONS(CONTROL_LOOP,SOLVER,ERR,ERROR,*999)
            CASE(PROBLEM_QUASISTATIC_NAVIER_STOKES_SUBTYPE)
              ! do nothing ???
                CALL NAVIER_STOKES_PRE_SOLVE_UPDATE_BOUNDARY_CONDITIONS(CONTROL_LOOP,SOLVER,ERR,ERROR,*999)
            CASE(PROBLEM_PGM_NAVIER_STOKES_SUBTYPE)
              ! do nothing ???
              !First update mesh and calculates boundary velocity values
              CALL NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_MESH(CONTROL_LOOP,SOLVER,ERR,ERROR,*999)
              !Then apply both normal and moving mesh boundary conditions
              CALL NAVIER_STOKES_PRE_SOLVE_UPDATE_BOUNDARY_CONDITIONS(CONTROL_LOOP,SOLVER,ERR,ERROR,*999)
            CASE(PROBLEM_ALE_NAVIER_STOKES_SUBTYPE)
              !Pre solve for the linear solver
              IF(SOLVER%SOLVE_TYPE==SOLVER_LINEAR_TYPE) THEN
                CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"Mesh movement pre solve... ",ERR,ERROR,*999)
                !Update boundary conditions for mesh-movement
                CALL NAVIER_STOKES_PRE_SOLVE_UPDATE_BOUNDARY_CONDITIONS(CONTROL_LOOP,SOLVER,ERR,ERROR,*999)
                CALL SOLVERS_SOLVER_GET(SOLVER%SOLVERS,2,SOLVER2,ERR,ERROR,*999)
                IF(ASSOCIATED(SOLVER2%DYNAMIC_SOLVER)) THEN
                  SOLVER2%DYNAMIC_SOLVER%ALE=.FALSE.
                ELSE  
                  CALL FLAG_ERROR("Dynamic solver is not associated for ALE problem.",ERR,ERROR,*999)
                END IF
                !Update material properties for Laplace mesh movement
                CALL NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_PARAMETERS(CONTROL_LOOP,SOLVER,ERR,ERROR,*999)
              !Pre solve for the linear solver
              ELSE IF(SOLVER%SOLVE_TYPE==SOLVER_DYNAMIC_TYPE) THEN
                CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"ALE Navier-Stokes pre solve... ",ERR,ERROR,*999)
                IF(SOLVER%DYNAMIC_SOLVER%ALE) THEN
                  !First update mesh and calculates boundary velocity values
                  CALL NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_MESH(CONTROL_LOOP,SOLVER,ERR,ERROR,*999)
                  !Then apply both normal and moving mesh boundary conditions
                  CALL NAVIER_STOKES_PRE_SOLVE_UPDATE_BOUNDARY_CONDITIONS(CONTROL_LOOP,SOLVER,ERR,ERROR,*999)
                ELSE  
                  CALL FLAG_ERROR("Mesh motion calculation not successful for ALE problem.",ERR,ERROR,*999)
                END IF
              ELSE  
                CALL FLAG_ERROR("Solver type is not associated for ALE problem.",ERR,ERROR,*999)
              END IF
            CASE DEFAULT
              LOCAL_ERROR="Problem subtype "//TRIM(NUMBER_TO_VSTRING(CONTROL_LOOP%PROBLEM%SUBTYPE,"*",ERR,ERROR))// &
                & " is not valid for a Navier-Stokes fluid type of a fluid mechanics problem class."
              CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        ELSE
          CALL FLAG_ERROR("Problem is not associated.",ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Solver is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Control loop is not associated.",ERR,ERROR,*999)
    ENDIF

    CALL EXITS("NAVIER_STOKES_PRE_SOLVE")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_PRE_SOLVE",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_PRE_SOLVE")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_PRE_SOLVE

  !
  !================================================================================================================================
  !
   SUBROUTINE NAVIER_STOKES_CONTROL_TIME_LOOP_PRE_LOOP(CONTROL_LOOP,ERR,ERROR,*)

    !Argument variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP !<A pointer to the time control loop for the NAVIER_STOKES  problem
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string

    !Local Variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP_NAVIER_STOKES
    TYPE(SOLVER_TYPE), POINTER :: SOLVER_NAVIER_STOKES

    CALL ENTERS("NAVIER_STOKES_CONTROL_TIME_LOOP_PRE_LOOP",ERR,ERROR,*999)

    !Get the solver for the NAVIER_STOKES problem
    NULLIFY(SOLVER_NAVIER_STOKES)
    NULLIFY(CONTROL_LOOP_NAVIER_STOKES)
    !SOLVER_NUMBER_NAVIER_STOKES has to be set here so that store_reference_data and store_previous_data have access to it
    SOLVER_NUMBER_NAVIER_STOKES=1
    CALL CONTROL_LOOP_GET(CONTROL_LOOP,(/CONTROL_LOOP_NODE/),CONTROL_LOOP_NAVIER_STOKES,ERR,ERROR,*999)
    CALL SOLVERS_SOLVER_GET(CONTROL_LOOP_NAVIER_STOKES%SOLVERS,SOLVER_NUMBER_NAVIER_STOKES,SOLVER_NAVIER_STOKES,ERR,ERROR,*999)

    !If this is the first time step then store reference data
    IF(CONTROL_LOOP%TIME_LOOP%ITERATION_NUMBER==1) THEN
      IF(CONTROL_LOOP%OUTPUT_TYPE>=CONTROL_LOOP_PROGRESS_OUTPUT) THEN
        CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,'== Storing reference data',ERR,ERROR,*999)
      ENDIF
      CALL NAVIER_STOKES_PRE_SOLVE_STORE_REFERENCE_DATA(CONTROL_LOOP,SOLVER_NAVIER_STOKES,ERR,ERROR,*999)
    ENDIF

    !Store data of previous time step (mesh position); executed once per time step before subiteration
    IF(CONTROL_LOOP%OUTPUT_TYPE>=CONTROL_LOOP_PROGRESS_OUTPUT) THEN
      CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,'== Storing previous data',ERR,ERROR,*999)
    ENDIF
    CALL NAVIER_STOKES_PRE_SOLVE_STORE_PREVIOUS_DATA(CONTROL_LOOP,SOLVER_NAVIER_STOKES,ERR,ERROR,*999)


    CALL EXITS("NAVIER_STOKES_CONTROL_TIME_LOOP_PRE_LOOP")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_CONTROL_TIME_LOOP_PRE_LOOP",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_CONTROL_TIME_LOOP_PRE_LOOP")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_CONTROL_TIME_LOOP_PRE_LOOP

  !
  !================================================================================================================================
  !

  !>Store some reference data for 1D_NAVIER_STOKES problem
  SUBROUTINE NAVIER_STOKES_PRE_SOLVE_STORE_REFERENCE_DATA(CONTROL_LOOP,SOLVER,ERR,ERROR,*)

    !Argument variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP !<A pointer to the control loop to solve.
    TYPE(SOLVER_TYPE), POINTER :: SOLVER !<A pointer to the solvers
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(FIELD_TYPE), POINTER :: DEPENDENT_FIELD, GEOMETRIC_FIELD
    TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: SOLVER_EQUATIONS  !<A pointer to the solver equations
    TYPE(SOLVER_MAPPING_TYPE), POINTER :: SOLVER_MAPPING !<A pointer to the solver mapping
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set
    TYPE(EQUATIONS_MAPPING_TYPE), POINTER :: EQUATIONS_MAPPING
    TYPE(FIELD_VARIABLE_TYPE), POINTER :: FIELD_VARIABLE
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    REAL(DP) :: ALPHA
    REAL(DP), POINTER :: INITIAL_VALUES(:)

    INTEGER(INTG) :: FIELD_VAR_TYPE
    INTEGER(INTG) :: NDOFS_TO_PRINT

    CALL ENTERS("NAVIER_STOKES_PRE_SOLVE_STORE_REFERENCE_DATA",ERR,ERROR,*999)

    NULLIFY(SOLVER_EQUATIONS)
    NULLIFY(SOLVER_MAPPING)
    NULLIFY(EQUATIONS_SET)

    IF(ASSOCIATED(CONTROL_LOOP)) THEN
      IF(ASSOCIATED(SOLVER)) THEN
        IF(SOLVER%GLOBAL_NUMBER==SOLVER_NUMBER_NAVIER_STOKES) THEN
          IF(ASSOCIATED(CONTROL_LOOP%PROBLEM)) THEN
            SOLVER_EQUATIONS=>SOLVER%SOLVER_EQUATIONS
            IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
              SOLVER_MAPPING=>SOLVER_EQUATIONS%SOLVER_MAPPING
              IF(ASSOCIATED(SOLVER_MAPPING)) THEN
                EQUATIONS_SET=>SOLVER_MAPPING%EQUATIONS_SETS(1)%PTR
                IF(ASSOCIATED(EQUATIONS_SET)) THEN
                  DEPENDENT_FIELD=>EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD
                  GEOMETRIC_FIELD=>EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD
                  IF(ASSOCIATED(DEPENDENT_FIELD).AND.ASSOCIATED(GEOMETRIC_FIELD)) THEN
                    !Store the initial (= reference) GEOMETRY field values
                    ALPHA = 1.0_DP
                    CALL FIELD_PARAMETER_SETS_COPY(GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE, &
                         & FIELD_VALUES_SET_TYPE,FIELD_INITIAL_VALUES_SET_TYPE,ALPHA,ERR,ERROR,*999)
                    EQUATIONS_MAPPING=>EQUATIONS_SET%EQUATIONS%EQUATIONS_MAPPING
                    IF(ASSOCIATED(EQUATIONS_MAPPING)) THEN
                      FIELD_VARIABLE=>EQUATIONS_MAPPING%DYNAMIC_MAPPING%EQUATIONS_MATRIX_TO_VAR_MAPS(1)%VARIABLE
                      IF(ASSOCIATED(FIELD_VARIABLE)) THEN
                        FIELD_VAR_TYPE=FIELD_VARIABLE%VARIABLE_TYPE
                        !Store the initial DEPENDENT field values
                        ALPHA = 1.0_DP
                        CALL FIELD_PARAMETER_SETS_COPY(DEPENDENT_FIELD,FIELD_VAR_TYPE, &
                             & FIELD_VALUES_SET_TYPE,FIELD_INITIAL_VALUES_SET_TYPE,ALPHA,ERR,ERROR,*999)
                        IF(DIAGNOSTICS1) THEN
                          NULLIFY(INITIAL_VALUES)
                          CALL FIELD_PARAMETER_SET_DATA_GET(DEPENDENT_FIELD,FIELD_VAR_TYPE, &
                               & FIELD_INITIAL_VALUES_SET_TYPE,INITIAL_VALUES,ERR,ERROR,*999)
                          NDOFS_TO_PRINT = SIZE(INITIAL_VALUES,1)
                          CALL WRITE_STRING_VECTOR(DIAGNOSTIC_OUTPUT_TYPE,1,1,NDOFS_TO_PRINT,NDOFS_TO_PRINT,NDOFS_TO_PRINT,&
                               & INITIAL_VALUES, &
                               & '(" DEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE,FIELD_INITIAL_VALUES_SET_TYPE = ",4(X,E13.6))', &
                               & '4(4(X,E13.6))',ERR,ERROR,*999)
                          CALL FIELD_PARAMETER_SET_DATA_RESTORE(DEPENDENT_FIELD,FIELD_VAR_TYPE, &
                               & FIELD_INITIAL_VALUES_SET_TYPE,INITIAL_VALUES,ERR,ERROR,*999)
                        ENDIF
                      ELSE
                        CALL FLAG_ERROR("FIELD_VAR_TYPE is not associated.",ERR,ERROR,*999)
                      ENDIF
                    ELSE
                      CALL FLAG_ERROR("EQUATIONS_MAPPING is not associated.",ERR,ERROR,*999)
                    ENDIF
                  ELSE
                    CALL FLAG_ERROR("Dependent field and / or geometric field is / are not associated.",ERR,ERROR,*999)
                  ENDIF
                ELSE
                  CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
                ENDIF
              ELSE
                CALL FLAG_ERROR("Solver mapping is not associated.",ERR,ERROR,*999)
              ENDIF
            ELSE
              CALL FLAG_ERROR("Solver equations is not associated.",ERR,ERROR,*999)
            ENDIF
          ELSE
            CALL FLAG_ERROR("Problem is not associated.",ERR,ERROR,*999)
          ENDIF
        ELSE
          ! do nothing ???
        ENDIF
      ELSE
        CALL FLAG_ERROR("Solver is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Control loop is not associated.",ERR,ERROR,*999)
    ENDIF

    CALL EXITS("NAVIER_STOKES_PRE_SOLVE_STORE_REFERENCE_DATA")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_PRE_SOLVE_STORE_REFERENCE_DATA",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_PRE_SOLVE_STORE_REFERENCE_DATA")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_PRE_SOLVE_STORE_REFERENCE_DATA

  !
  !================================================================================================================================
  !

  !>Store data of previous time step (mesh position) for 1D_NAVIER_STOKES problem
  SUBROUTINE NAVIER_STOKES_PRE_SOLVE_STORE_PREVIOUS_DATA(CONTROL_LOOP,SOLVER,ERR,ERROR,*)

    !Argument variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP !<A pointer to the control loop to solve.
    TYPE(SOLVER_TYPE), POINTER :: SOLVER !<A pointer to the solvers
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(FIELD_TYPE), POINTER :: GEOMETRIC_FIELD
    TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: SOLVER_EQUATIONS  !<A pointer to the solver equations
    TYPE(SOLVER_MAPPING_TYPE), POINTER :: SOLVER_MAPPING !<A pointer to the solver mapping
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set
    TYPE(VARYING_STRING) :: LOCAL_ERROR

    REAL(DP) :: ALPHA

    CALL ENTERS("NAVIER_STOKES_PRE_SOLVE_STORE_PREVIOUS_DATA",ERR,ERROR,*999)

    NULLIFY(SOLVER_EQUATIONS)
    NULLIFY(SOLVER_MAPPING)
    NULLIFY(EQUATIONS_SET)

    IF(ASSOCIATED(CONTROL_LOOP)) THEN
      IF(ASSOCIATED(SOLVER)) THEN
        IF(SOLVER%GLOBAL_NUMBER==SOLVER_NUMBER_NAVIER_STOKES) THEN
          IF(ASSOCIATED(CONTROL_LOOP%PROBLEM)) THEN
            SOLVER_EQUATIONS=>SOLVER%SOLVER_EQUATIONS
            IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
              SOLVER_MAPPING=>SOLVER_EQUATIONS%SOLVER_MAPPING
              IF(ASSOCIATED(SOLVER_MAPPING)) THEN
                EQUATIONS_SET=>SOLVER_MAPPING%EQUATIONS_SETS(1)%PTR
                IF(ASSOCIATED(EQUATIONS_SET)) THEN
                  GEOMETRIC_FIELD=>EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD
                  IF(ASSOCIATED(GEOMETRIC_FIELD)) THEN
                    !Store the GEOMETRY field values of the previous time step
                    ALPHA = 1.0_DP
                    CALL FIELD_PARAMETER_SETS_COPY(GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE, &
                       & FIELD_VALUES_SET_TYPE,FIELD_PREVIOUS_VALUES_SET_TYPE,ALPHA,ERR,ERROR,*999)
                  ELSE
                    CALL FLAG_ERROR("Dependent field and / or geometric field is / are not associated.",ERR,ERROR,*999)
                  ENDIF
                ELSE
                  CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
                ENDIF
              ELSE
                CALL FLAG_ERROR("Solver mapping is not associated.",ERR,ERROR,*999)
              ENDIF
            ELSE
              CALL FLAG_ERROR("Solver equations is not associated.",ERR,ERROR,*999)
            ENDIF
          ELSE
            CALL FLAG_ERROR("Problem is not associated.",ERR,ERROR,*999)
          ENDIF
        ELSE
          ! do nothing ???
        ENDIF
      ELSE
        CALL FLAG_ERROR("Solver is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Control loop is not associated.",ERR,ERROR,*999)
    ENDIF

    CALL EXITS("NAVIER_STOKES_PRE_SOLVE_STORE_PREVIOUS_DATA")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_PRE_SOLVE_STORE_PREVIOUS_DATA",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_PRE_SOLVE_STORE_PREVIOUS_DATA")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_PRE_SOLVE_STORE_PREVIOUS_DATA

  !
  !================================================================================================================================
  !

  !>Update boundary conditions for Navier-Stokes flow pre solve
  SUBROUTINE NAVIER_STOKES_PRE_SOLVE_UPDATE_BOUNDARY_CONDITIONS(CONTROL_LOOP,SOLVER,ERR,ERROR,*)

    !Argument variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP !<A pointer to the control loop to solve.
    TYPE(SOLVER_TYPE), POINTER :: SOLVER !<A pointer to the solver
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: SOLVER_EQUATIONS  !<A pointer to the solver equations
    TYPE(SOLVER_MAPPING_TYPE), POINTER :: SOLVER_MAPPING !<A pointer to the solver mapping
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set
    TYPE(EQUATIONS_TYPE), POINTER :: EQUATIONS
    TYPE(EQUATIONS_MAPPING_TYPE), POINTER :: EQUATIONS_MAPPING
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    TYPE(BOUNDARY_CONDITIONS_VARIABLE_TYPE), POINTER :: BOUNDARY_CONDITIONS_VARIABLE
    TYPE(BOUNDARY_CONDITIONS_TYPE), POINTER :: BOUNDARY_CONDITIONS
    TYPE(FIELD_TYPE), POINTER :: DEPENDENT_FIELD,GEOMETRIC_FIELD,MATERIALS_FIELD
    TYPE(FIELD_VARIABLE_TYPE), POINTER :: FIELD_VARIABLE,GEOMETRIC_VARIABLE
    TYPE(DOMAIN_TYPE), POINTER :: DOMAIN
    TYPE(DOMAIN_NODES_TYPE), POINTER :: DOMAIN_NODES
    TYPE(FIELD_INTERPOLATED_POINT_PTR_TYPE), POINTER :: INTERPOLATED_POINT(:)
    TYPE(FIELD_INTERPOLATION_PARAMETERS_PTR_TYPE), POINTER :: INTERPOLATION_PARAMETERS(:)
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_TIME_LOOP

    REAL(DP), POINTER :: MESH_VELOCITY_VALUES(:), GEOMETRIC_PARAMETERS(:)
    REAL(DP), POINTER :: BOUNDARY_VALUES(:)
    REAL(DP), POINTER :: INITIAL_VALUES(:)
    REAL(DP), POINTER :: DUMMY_VALUES1(:)
    REAL(DP) :: CURRENT_TIME,TIME_INCREMENT,DISPLACEMENT_VALUE,VALUE,XI_COORDINATES(3)
    REAL(DP) :: T_COORDINATES(20,3)
    REAL(DP) :: X(3),MU_PARAM,RHO_PARAM,VELOCITY,PRESSURE

    INTEGER(INTG) :: NUMBER_OF_DIMENSIONS,BOUNDARY_CONDITION_CHECK_VARIABLE,GLOBAL_DERIV_INDEX,node_idx,variable_type
    INTEGER(INTG) :: variable_idx,local_ny,ANALYTIC_FUNCTION_TYPE,component_idx,deriv_idx,dim_idx
    INTEGER(INTG) :: element_idx,en_idx,I,J,K,number_of_nodes_xic(3)
    INTEGER(INTG) :: FIELD_VAR_TYPE
    INTEGER(INTG) :: dof_number,NUMBER_OF_DOFS,loop_idx
    INTEGER(INTG) :: NDOFS_TO_PRINT

    CALL ENTERS("NAVIER_STOKES_PRE_SOLVE_UPDATE_BOUNDARY_CONDITIONS",ERR,ERROR,*999)

    IF(ASSOCIATED(CONTROL_LOOP)) THEN
      CALL CONTROL_LOOP_CURRENT_TIMES_GET(CONTROL_LOOP,CURRENT_TIME,TIME_INCREMENT,ERR,ERROR,*999)
      IF(ASSOCIATED(SOLVER)) THEN
        IF(ASSOCIATED(CONTROL_LOOP%PROBLEM)) THEN
          SELECT CASE(CONTROL_LOOP%PROBLEM%SUBTYPE)
            CASE(PROBLEM_STATIC_NAVIER_STOKES_SUBTYPE,PROBLEM_LAPLACE_NAVIER_STOKES_SUBTYPE)
              ! do nothing ???
            CASE(PROBLEM_TRANSIENT_NAVIER_STOKES_SUBTYPE)
              SOLVER_EQUATIONS=>SOLVER%SOLVER_EQUATIONS
              IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
                SOLVER_MAPPING=>SOLVER_EQUATIONS%SOLVER_MAPPING
                EQUATIONS=>SOLVER_MAPPING%EQUATIONS_SET_TO_SOLVER_MAP(1)%EQUATIONS
                IF(ASSOCIATED(EQUATIONS)) THEN
                  EQUATIONS_SET=>EQUATIONS%EQUATIONS_SET
                  IF(ASSOCIATED(EQUATIONS_SET%ANALYTIC)) THEN
                    IF(EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_4 .OR. &
                      & EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_5 .OR. &
                      & EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_4 .OR. &
                      & EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_5 .OR. &
                      & EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_1) THEN
                      IF(ASSOCIATED(EQUATIONS_SET)) THEN
                        IF(ASSOCIATED(EQUATIONS_SET%ANALYTIC)) THEN
                          DEPENDENT_FIELD=>EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD
                          IF(ASSOCIATED(DEPENDENT_FIELD)) THEN
                            GEOMETRIC_FIELD=>EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD
                            IF(ASSOCIATED(GEOMETRIC_FIELD)) THEN            
                              CALL FIELD_NUMBER_OF_COMPONENTS_GET(GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE,&
                                & NUMBER_OF_DIMENSIONS,ERR,ERROR,*999)
                              NULLIFY(INTERPOLATION_PARAMETERS)
                              NULLIFY(INTERPOLATED_POINT) 
                              CALL FIELD_INTERPOLATION_PARAMETERS_INITIALISE(GEOMETRIC_FIELD,INTERPOLATION_PARAMETERS,ERR,ERROR, &
                                & *999)
                              CALL FIELD_INTERPOLATED_POINTS_INITIALISE(INTERPOLATION_PARAMETERS,INTERPOLATED_POINT,ERR,ERROR,*999)
                              NULLIFY(GEOMETRIC_VARIABLE)
                              CALL FIELD_VARIABLE_GET(GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE,GEOMETRIC_VARIABLE,ERR,ERROR,*999)
                              NULLIFY(GEOMETRIC_PARAMETERS)
                              CALL FIELD_PARAMETER_SET_DATA_GET(GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE,FIELD_VALUES_SET_TYPE,& 
                                & GEOMETRIC_PARAMETERS,ERR,ERROR,*999)
                               DO variable_idx=1,DEPENDENT_FIELD%NUMBER_OF_VARIABLES
                                variable_type=DEPENDENT_FIELD%VARIABLES(variable_idx)%VARIABLE_TYPE
                                FIELD_VARIABLE=>DEPENDENT_FIELD%VARIABLE_TYPE_MAP(variable_type)%PTR
                                IF(ASSOCIATED(FIELD_VARIABLE)) THEN
                                  DO component_idx=1,FIELD_VARIABLE%NUMBER_OF_COMPONENTS
                                    IF(FIELD_VARIABLE%COMPONENTS(component_idx)%INTERPOLATION_TYPE== & 
                                      & FIELD_NODE_BASED_INTERPOLATION) THEN
                                      DOMAIN=>FIELD_VARIABLE%COMPONENTS(component_idx)%DOMAIN
                                      IF(ASSOCIATED(DOMAIN)) THEN
                                        IF(ASSOCIATED(DOMAIN%TOPOLOGY)) THEN
                                          DOMAIN_NODES=>DOMAIN%TOPOLOGY%NODES
                                          IF(ASSOCIATED(DOMAIN_NODES)) THEN
                                            !Should be replaced by boundary node flag
                                            DO node_idx=1,DOMAIN_NODES%NUMBER_OF_NODES
                                              element_idx=DOMAIN%topology%nodes%nodes(node_idx)%surrounding_elements(1)
                                              CALL FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET(FIELD_VALUES_SET_TYPE,element_idx, &
                                                & INTERPOLATION_PARAMETERS(FIELD_U_VARIABLE_TYPE)%PTR,ERR,ERROR,*999)
                                              en_idx=0
                                              XI_COORDINATES=0.0_DP
                                              number_of_nodes_xic(1)=DOMAIN%topology%elements%elements(element_idx)% &
                                                & basis%number_of_nodes_xic(1)
                                              number_of_nodes_xic(2)=DOMAIN%topology%elements%elements(element_idx)% & 
                                                & basis%number_of_nodes_xic(2)
                                              IF(NUMBER_OF_DIMENSIONS==3) THEN
                                                number_of_nodes_xic(3)=DOMAIN%topology%elements%elements(element_idx)%basis% &
                                                  & number_of_nodes_xic(3)
                                              ELSE
                                                number_of_nodes_xic(3)=1
                                              ENDIF
!\todo: change definitions as soon as adjacent elements / boundary elements calculation works for simplex
                                              IF(DOMAIN%topology%elements%maximum_number_of_element_parameters==4.OR. &
                                                & DOMAIN%topology%elements%maximum_number_of_element_parameters==9.OR. &
                                                & DOMAIN%topology%elements%maximum_number_of_element_parameters==16.OR. &
                                                & DOMAIN%topology%elements%maximum_number_of_element_parameters==8.OR. &
                                                & DOMAIN%topology%elements%maximum_number_of_element_parameters==27.OR. &
                                                & DOMAIN%topology%elements%maximum_number_of_element_parameters==64.) THEN
                                                  DO K=1,number_of_nodes_xic(3)
                                                    DO J=1,number_of_nodes_xic(2)
                                                      DO I=1,number_of_nodes_xic(1)
                                                        en_idx=en_idx+1
                                                        IF(DOMAIN%topology%elements%elements(element_idx)% & 
                                                          & element_nodes(en_idx)==node_idx) EXIT
                                                        XI_COORDINATES(1)=XI_COORDINATES(1)+(1.0_DP/(number_of_nodes_xic(1)-1))
                                                      ENDDO
                                                      IF(DOMAIN%topology%elements%elements(element_idx)% &
                                                        & element_nodes(en_idx)==node_idx) EXIT
                                                        XI_COORDINATES(1)=0.0_DP
                                                        XI_COORDINATES(2)=XI_COORDINATES(2)+(1.0_DP/(number_of_nodes_xic(2)-1))
                                                    ENDDO
                                                    IF(DOMAIN%topology%elements%elements(element_idx)% & 
                                                      & element_nodes(en_idx)==node_idx) EXIT
                                                    XI_COORDINATES(1)=0.0_DP
                                                    XI_COORDINATES(2)=0.0_DP
                                                    IF(number_of_nodes_xic(3)/=1) THEN
                                                      XI_COORDINATES(3)=XI_COORDINATES(3)+(1.0_DP/(number_of_nodes_xic(3)-1))
                                                    ENDIF
                                                  ENDDO
                                                  CALL FIELD_INTERPOLATE_XI(NO_PART_DERIV,XI_COORDINATES, &
                                                    & INTERPOLATED_POINT(FIELD_U_VARIABLE_TYPE)%PTR,ERR,ERROR,*999)
                                              ELSE
!\todo: Use boundary flag
                                                IF(DOMAIN%topology%elements%maximum_number_of_element_parameters==3) THEN
                                                  T_COORDINATES(1,1:2)=(/0.0_DP,1.0_DP/)
                                                  T_COORDINATES(2,1:2)=(/1.0_DP,0.0_DP/)
                                                  T_COORDINATES(3,1:2)=(/1.0_DP,1.0_DP/)
                                                ELSE IF(DOMAIN%topology%elements%maximum_number_of_element_parameters==6) THEN
                                                  T_COORDINATES(1,1:2)=(/0.0_DP,1.0_DP/)
                                                  T_COORDINATES(2,1:2)=(/1.0_DP,0.0_DP/)
                                                  T_COORDINATES(3,1:2)=(/1.0_DP,1.0_DP/)
                                                  T_COORDINATES(4,1:2)=(/0.5_DP,0.5_DP/)
                                                  T_COORDINATES(5,1:2)=(/1.0_DP,0.5_DP/)
                                                  T_COORDINATES(6,1:2)=(/0.5_DP,1.0_DP/)
                                                ELSE IF(DOMAIN%topology%elements%maximum_number_of_element_parameters==10.AND. & 
                                                  & NUMBER_OF_DIMENSIONS==2) THEN
                                                  T_COORDINATES(1,1:2)=(/0.0_DP,1.0_DP/)
                                                  T_COORDINATES(2,1:2)=(/1.0_DP,0.0_DP/)
                                                  T_COORDINATES(3,1:2)=(/1.0_DP,1.0_DP/)
                                                  T_COORDINATES(4,1:2)=(/1.0_DP/3.0_DP,2.0_DP/3.0_DP/)
                                                  T_COORDINATES(5,1:2)=(/2.0_DP/3.0_DP,1.0_DP/3.0_DP/)
                                                  T_COORDINATES(6,1:2)=(/1.0_DP,1.0_DP/3.0_DP/)
                                                  T_COORDINATES(7,1:2)=(/1.0_DP,2.0_DP/3.0_DP/)
                                                  T_COORDINATES(8,1:2)=(/2.0_DP/3.0_DP,1.0_DP/)
                                                  T_COORDINATES(9,1:2)=(/1.0_DP/3.0_DP,1.0_DP/)
                                                  T_COORDINATES(10,1:2)=(/2.0_DP/3.0_DP,2.0_DP/3.0_DP/)
                                                ELSE IF(DOMAIN%topology%elements%maximum_number_of_element_parameters==4) THEN
                                                  T_COORDINATES(1,1:3)=(/0.0_DP,1.0_DP,1.0_DP/)
                                                  T_COORDINATES(2,1:3)=(/1.0_DP,0.0_DP,1.0_DP/)
                                                  T_COORDINATES(3,1:3)=(/1.0_DP,1.0_DP,0.0_DP/)
                                                  T_COORDINATES(4,1:3)=(/1.0_DP,1.0_DP,1.0_DP/)
                                                ELSE IF(DOMAIN%topology%elements%maximum_number_of_element_parameters==10.AND. & 
                                                  & NUMBER_OF_DIMENSIONS==3) THEN
                                                  T_COORDINATES(1,1:3)=(/0.0_DP,1.0_DP,1.0_DP/)
                                                  T_COORDINATES(2,1:3)=(/1.0_DP,0.0_DP,1.0_DP/)
                                                  T_COORDINATES(3,1:3)=(/1.0_DP,1.0_DP,0.0_DP/)
                                                  T_COORDINATES(4,1:3)=(/1.0_DP,1.0_DP,1.0_DP/)
                                                  T_COORDINATES(5,1:3)=(/0.5_DP,0.5_DP,1.0_DP/)
                                                  T_COORDINATES(6,1:3)=(/0.5_DP,1.0_DP,0.5_DP/)
                                                  T_COORDINATES(7,1:3)=(/0.5_DP,1.0_DP,1.0_DP/)
                                                  T_COORDINATES(8,1:3)=(/1.0_DP,0.5_DP,0.5_DP/)
                                                  T_COORDINATES(9,1:3)=(/1.0_DP,1.0_DP,0.5_DP/)
                                                  T_COORDINATES(10,1:3)=(/1.0_DP,0.5_DP,1.0_DP/)
                                                ELSE IF(DOMAIN%topology%elements%maximum_number_of_element_parameters==20) THEN
                                                  T_COORDINATES(1,1:3)=(/0.0_DP,1.0_DP,1.0_DP/)
                                                  T_COORDINATES(2,1:3)=(/1.0_DP,0.0_DP,1.0_DP/)
                                                  T_COORDINATES(3,1:3)=(/1.0_DP,1.0_DP,0.0_DP/)
                                                  T_COORDINATES(4,1:3)=(/1.0_DP,1.0_DP,1.0_DP/)
                                                  T_COORDINATES(5,1:3)=(/1.0_DP/3.0_DP,2.0_DP/3.0_DP,1.0_DP/)
                                                  T_COORDINATES(6,1:3)=(/2.0_DP/3.0_DP,1.0_DP/3.0_DP,1.0_DP/)
                                                  T_COORDINATES(7,1:3)=(/1.0_DP/3.0_DP,1.0_DP,2.0_DP/3.0_DP/)
                                                  T_COORDINATES(8,1:3)=(/2.0_DP/3.0_DP,1.0_DP,1.0_DP/3.0_DP/)
                                                  T_COORDINATES(9,1:3)=(/1.0_DP/3.0_DP,1.0_DP,1.0_DP/)
                                                  T_COORDINATES(10,1:3)=(/2.0_DP/3.0_DP,1.0_DP,1.0_DP/)
                                                  T_COORDINATES(11,1:3)=(/1.0_DP,1.0_DP/3.0_DP,2.0_DP/3.0_DP/)
                                                  T_COORDINATES(12,1:3)=(/1.0_DP,2.0_DP/3.0_DP,1.0_DP/3.0_DP/)
                                                  T_COORDINATES(13,1:3)=(/1.0_DP,1.0_DP,1.0_DP/3.0_DP/)
                                                  T_COORDINATES(14,1:3)=(/1.0_DP,1.0_DP,2.0_DP/3.0_DP/)
                                                  T_COORDINATES(15,1:3)=(/1.0_DP,1.0_DP/3.0_DP,1.0_DP/)
                                                  T_COORDINATES(16,1:3)=(/1.0_DP,2.0_DP/3.0_DP,1.0_DP/)
                                                  T_COORDINATES(17,1:3)=(/2.0_DP/3.0_DP,2.0_DP/3.0_DP,2.0_DP/3.0_DP/)
                                                  T_COORDINATES(18,1:3)=(/2.0_DP/3.0_DP,2.0_DP/3.0_DP,1.0_DP/)
                                                  T_COORDINATES(19,1:3)=(/2.0_DP/3.0_DP,1.0_DP,2.0_DP/3.0_DP/)
                                                  T_COORDINATES(20,1:3)=(/1.0_DP,2.0_DP/3.0_DP,2.0_DP/3.0_DP/)
                                                ENDIF
                                                DO K=1,DOMAIN%topology%elements%maximum_number_of_element_parameters
                                                  IF(DOMAIN%topology%elements%elements(element_idx)%element_nodes(K)==node_idx) EXIT
                                                ENDDO
                                                IF(NUMBER_OF_DIMENSIONS==2) THEN
                                                  CALL FIELD_INTERPOLATE_XI(NO_PART_DERIV,T_COORDINATES(K,1:2), &
                                                    & INTERPOLATED_POINT(FIELD_U_VARIABLE_TYPE)%PTR,ERR,ERROR,*999)
                                                ELSE IF(NUMBER_OF_DIMENSIONS==3) THEN
                                                  CALL FIELD_INTERPOLATE_XI(NO_PART_DERIV,T_COORDINATES(K,1:3), &
                                                    & INTERPOLATED_POINT(FIELD_U_VARIABLE_TYPE)%PTR,ERR,ERROR,*999)
                                                ENDIF 
                                              ENDIF
                                              X=0.0_DP
                                              DO dim_idx=1,NUMBER_OF_DIMENSIONS
                                                X(dim_idx)=INTERPOLATED_POINT(FIELD_U_VARIABLE_TYPE)%PTR%VALUES(dim_idx,1)
                                              ENDDO !dim_idx
                                              !Loop over the derivatives
                                              DO deriv_idx=1,DOMAIN_NODES%NODES(node_idx)%NUMBER_OF_DERIVATIVES
                                                ANALYTIC_FUNCTION_TYPE=EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE
                                                GLOBAL_DERIV_INDEX=DOMAIN_NODES%NODES(node_idx)%DERIVATIVES(deriv_idx)% &
                                                  & GLOBAL_DERIVATIVE_INDEX
                                                MATERIALS_FIELD=>EQUATIONS_SET%MATERIALS%MATERIALS_FIELD
                                                !Define MU_PARAM, density=1
                                                MU_PARAM=MATERIALS_FIELD%variables(1)%parameter_sets%parameter_sets(1)%ptr% &
                                                  & parameters%cmiss%data_dp(1)
                                                !Define RHO_PARAM, density=2
                                                RHO_PARAM=MATERIALS_FIELD%variables(1)%parameter_sets%parameter_sets(1)%ptr% &
                                                  & parameters%cmiss%data_dp(2)
                                                CALL NAVIER_STOKES_EQUATION_ANALYTIC_FUNCTIONS(VALUE,X,MU_PARAM,RHO_PARAM, &
                                                  & CURRENT_TIME,variable_type, & 
                                                  & GLOBAL_DERIV_INDEX,ANALYTIC_FUNCTION_TYPE,NUMBER_OF_DIMENSIONS, &
                                                  & FIELD_VARIABLE%NUMBER_OF_COMPONENTS,component_idx,ERR,ERROR,*999)
                                                !Default to version 1 of each node derivative
                                                local_ny=FIELD_VARIABLE%COMPONENTS(component_idx)%PARAM_TO_DOF_MAP% &
                                                  & NODE_PARAM2DOF_MAP%NODES(node_idx)%DERIVATIVES(deriv_idx)%VERSIONS(1)
                                                CALL FIELD_PARAMETER_SET_UPDATE_LOCAL_DOF(DEPENDENT_FIELD,variable_type, &
                                                  & FIELD_ANALYTIC_VALUES_SET_TYPE,local_ny,VALUE,ERR,ERROR,*999)
                                                CALL BOUNDARY_CONDITIONS_VARIABLE_GET(BOUNDARY_CONDITIONS,DEPENDENT_FIELD% &
                                                  & VARIABLE_TYPE_MAP(FIELD_U_VARIABLE_TYPE)%PTR,BOUNDARY_CONDITIONS_VARIABLE, &
                                                  & ERR,ERROR,*999)
                                                IF(ASSOCIATED(BOUNDARY_CONDITIONS_VARIABLE)) THEN
                                                  BOUNDARY_CONDITION_CHECK_VARIABLE=BOUNDARY_CONDITIONS_VARIABLE% &
                                                    & GLOBAL_BOUNDARY_CONDITIONS(local_ny)
                                                  IF(BOUNDARY_CONDITION_CHECK_VARIABLE==BOUNDARY_CONDITION_FIXED) THEN
                                                    CALL FIELD_PARAMETER_SET_UPDATE_LOCAL_DOF(DEPENDENT_FIELD, &
                                                     & variable_type,FIELD_VALUES_SET_TYPE,local_ny, &
                                                     & VALUE,ERR,ERROR,*999)
                                                  ENDIF
                                                ELSE
                                                  CALL FLAG_ERROR("Boundary conditions U variable is not associated.", &
                                                    & ERR,ERROR,*999)
                                                ENDIF
                                              ENDDO !deriv_idx
                                            ENDDO !node_idx
                                          ELSE
                                            CALL FLAG_ERROR("Domain topology nodes is not associated.",ERR,ERROR,*999)
                                          ENDIF
                                        ELSE
                                          CALL FLAG_ERROR("Domain topology is not associated.",ERR,ERROR,*999)
                                        ENDIF
                                      ELSE
                                        CALL FLAG_ERROR("Domain is not associated.",ERR,ERROR,*999)
                                      ENDIF
                                    ELSE
                                      CALL FLAG_ERROR("Only node based interpolation is implemented.",ERR,ERROR,*999)
                                    ENDIF
                                  ENDDO !component_idx
                                  CALL FIELD_PARAMETER_SET_UPDATE_START(DEPENDENT_FIELD,variable_type, &
                                   & FIELD_ANALYTIC_VALUES_SET_TYPE,ERR,ERROR,*999)
                                  CALL FIELD_PARAMETER_SET_UPDATE_FINISH(DEPENDENT_FIELD,variable_type, &
                                   & FIELD_ANALYTIC_VALUES_SET_TYPE,ERR,ERROR,*999)
                                  CALL FIELD_PARAMETER_SET_UPDATE_START(DEPENDENT_FIELD,variable_type, &
                                   & FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)
                                  CALL FIELD_PARAMETER_SET_UPDATE_FINISH(DEPENDENT_FIELD,variable_type, &
                                   & FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)
                                ELSE
                                  CALL FLAG_ERROR("Field variable is not associated.",ERR,ERROR,*999)
                                ENDIF
                               ENDDO !variable_idx
                               CALL FIELD_PARAMETER_SET_DATA_RESTORE(GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE,&
                                & FIELD_VALUES_SET_TYPE,GEOMETRIC_PARAMETERS,ERR,ERROR,*999)
                            ELSE
                              CALL FLAG_ERROR("Equations set geometric field is not associated.",ERR,ERROR,*999)
                            ENDIF
                          ELSE
                            CALL FLAG_ERROR("Equations set dependent field is not associated.",ERR,ERROR,*999)
                          ENDIF
                        ELSE
                          CALL FLAG_ERROR("Equations set analytic is not associated.",ERR,ERROR,*999)
                        ENDIF
                      ELSE
                        CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
                      ENDIF
                    ENDIF
                  ENDIF
                ELSE
                  CALL FLAG_ERROR("Equations are not associated.",ERR,ERROR,*999)
                END IF
              ELSE
                CALL FLAG_ERROR("Solver equations are not associated.",ERR,ERROR,*999)
              END IF
              CALL FIELD_PARAMETER_SET_UPDATE_START(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, &
                & FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)
              CALL FIELD_PARAMETER_SET_UPDATE_FINISH(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, &
                & FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)
            CASE(PROBLEM_1DTRANSIENT_NAVIER_STOKES_SUBTYPE)
              SOLVER_EQUATIONS=>SOLVER%SOLVER_EQUATIONS
              IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
                SOLVER_MAPPING=>SOLVER_EQUATIONS%SOLVER_MAPPING
                IF(ASSOCIATED(SOLVER_MAPPING)) THEN
                  EQUATIONS=>SOLVER_MAPPING%EQUATIONS_SET_TO_SOLVER_MAP(1)%EQUATIONS
                  IF(ASSOCIATED(EQUATIONS)) THEN
                    EQUATIONS_SET=>EQUATIONS%EQUATIONS_SET
                    IF(ASSOCIATED(EQUATIONS_SET)) THEN
                      IF(SOLVER%OUTPUT_TYPE>=SOLVER_PROGRESS_OUTPUT) THEN
                        CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"Navier Stokes update boundary conditions ... ",ERR,ERROR,*999)
                      ENDIF
                      DEPENDENT_FIELD=>EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD
                      GEOMETRIC_FIELD=>EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD
                      IF(ASSOCIATED(DEPENDENT_FIELD).AND.ASSOCIATED(GEOMETRIC_FIELD)) THEN
                        BOUNDARY_CONDITIONS=>SOLVER_EQUATIONS%BOUNDARY_CONDITIONS
                        IF(ASSOCIATED(BOUNDARY_CONDITIONS)) THEN
                          EQUATIONS_MAPPING=>EQUATIONS_SET%EQUATIONS%EQUATIONS_MAPPING
                          IF(ASSOCIATED(EQUATIONS_MAPPING)) THEN
                            FIELD_VARIABLE=>EQUATIONS_MAPPING%DYNAMIC_MAPPING%EQUATIONS_MATRIX_TO_VAR_MAPS(1)%VARIABLE
                            IF(ASSOCIATED(FIELD_VARIABLE)) THEN
                              FIELD_VAR_TYPE=FIELD_VARIABLE%VARIABLE_TYPE
                              CALL BOUNDARY_CONDITIONS_VARIABLE_GET(BOUNDARY_CONDITIONS,FIELD_VARIABLE, &
                                & BOUNDARY_CONDITIONS_VARIABLE,ERR,ERROR,*999)
                              IF(ASSOCIATED(BOUNDARY_CONDITIONS_VARIABLE)) THEN
                                IF(DIAGNOSTICS1) THEN
                                  NULLIFY( DUMMY_VALUES1 )
                                  CALL FIELD_PARAMETER_SET_DATA_GET(DEPENDENT_FIELD,FIELD_VAR_TYPE, &
                                     & FIELD_VALUES_SET_TYPE,DUMMY_VALUES1,ERR,ERROR,*999)
                                  NDOFS_TO_PRINT = SIZE(DUMMY_VALUES1,1)
                                  CALL WRITE_STRING_VECTOR(DIAGNOSTIC_OUTPUT_TYPE,1,1,NDOFS_TO_PRINT,NDOFS_TO_PRINT, &
                                     & NDOFS_TO_PRINT,DUMMY_VALUES1, &
                                     & '(" DEPENDENT_FIELD,FIELD_VAR_TYPE,FIELD_VALUES_SET_TYPE (before) = ",4(X,E13.6))', &
                                     & '4(4(X,E13.6))',ERR,ERROR,*999)
                                ENDIF
                                NUMBER_OF_DOFS = DEPENDENT_FIELD%VARIABLE_TYPE_MAP(FIELD_VAR_TYPE)%PTR%NUMBER_OF_DOFS

                                VELOCITY =( (.05*SIN(0.001*(CURRENT_TIME-100)*3.1416))+.05 )

                                CALL FIELD_PARAMETER_SET_UPDATE_LOCAL_DOF(DEPENDENT_FIELD,FIELD_VAR_TYPE, &
                                   & FIELD_VALUES_SET_TYPE,1,VELOCITY,ERR,ERROR,*999)

                                CALL FIELD_PARAMETER_SET_UPDATE_START(DEPENDENT_FIELD, &
                                   & FIELD_VAR_TYPE, FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)
                                CALL FIELD_PARAMETER_SET_UPDATE_FINISH(DEPENDENT_FIELD, & 
                                   & FIELD_VAR_TYPE, FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)
                              ELSE
                                CALL FLAG_ERROR("Boundary condition variable is not associated.",ERR,ERROR,*999)
                              END IF
                            ELSE
                              CALL FLAG_ERROR("FIELD_VAR_TYPE is not associated.",ERR,ERROR,*999)
                            ENDIF
                          ELSE
                            CALL FLAG_ERROR("EQUATIONS_MAPPING is not associated.",ERR,ERROR,*999)
                          ENDIF
                        ELSE
                          CALL FLAG_ERROR("Boundary conditions are not associated.",ERR,ERROR,*999)
                        END IF
                      ELSE
                        CALL FLAG_ERROR("Dependent field and/or geometric field is/are not associated.",ERR,ERROR,*999)
                      END IF
                    ELSE
                      CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
                    END IF
                  ELSE
                    CALL FLAG_ERROR("Equations are not associated.",ERR,ERROR,*999)
                  END IF
                ELSE
                  CALL FLAG_ERROR("Solver mapping is not associated.",ERR,ERROR,*999)
                ENDIF
              ELSE
                CALL FLAG_ERROR("Solver equations are not associated.",ERR,ERROR,*999)
              END IF
              CALL FIELD_PARAMETER_SET_UPDATE_START(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_VAR_TYPE, &
                & FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)
              CALL FIELD_PARAMETER_SET_UPDATE_FINISH(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_VAR_TYPE, &
                & FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)
            CASE(PROBLEM_QUASISTATIC_NAVIER_STOKES_SUBTYPE)
              !Pre solve for the linear solver
              SOLVER_EQUATIONS=>SOLVER%SOLVER_EQUATIONS
              IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
                SOLVER_MAPPING=>SOLVER_EQUATIONS%SOLVER_MAPPING
                EQUATIONS=>SOLVER_MAPPING%EQUATIONS_SET_TO_SOLVER_MAP(1)%EQUATIONS
                IF(ASSOCIATED(EQUATIONS)) THEN
                  EQUATIONS_SET=>EQUATIONS%EQUATIONS_SET
                  IF(ASSOCIATED(EQUATIONS_SET)) THEN
                    BOUNDARY_CONDITIONS=>SOLVER_EQUATIONS%BOUNDARY_CONDITIONS
                    IF(ASSOCIATED(BOUNDARY_CONDITIONS)) THEN
                      FIELD_VARIABLE=>EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD%VARIABLE_TYPE_MAP(FIELD_U_VARIABLE_TYPE)%PTR
                      IF(ASSOCIATED(FIELD_VARIABLE)) THEN
                        CALL BOUNDARY_CONDITIONS_VARIABLE_GET(BOUNDARY_CONDITIONS,FIELD_VARIABLE, &
                          & BOUNDARY_CONDITIONS_VARIABLE,ERR,ERROR,*999)
                      ELSE
                        CALL FLAG_ERROR("Field U variable is not associated",ERR,ERROR,*999)
                      ENDIF
                      IF(ASSOCIATED(BOUNDARY_CONDITIONS_VARIABLE)) THEN
                       CALL FIELD_NUMBER_OF_COMPONENTS_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE, &
                        & NUMBER_OF_DIMENSIONS,ERR,ERROR,*999)
                       NULLIFY(BOUNDARY_VALUES)
                       CALL FIELD_PARAMETER_SET_DATA_GET(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, &
                         & FIELD_BOUNDARY_SET_TYPE,BOUNDARY_VALUES,ERR,ERROR,*999)
                       CALL FLUID_MECHANICS_IO_READ_BOUNDARY_CONDITIONS(SOLVER_NONLINEAR_TYPE,BOUNDARY_VALUES, &
                         & NUMBER_OF_DIMENSIONS,BOUNDARY_CONDITION_FIXED_INLET,CONTROL_LOOP%TIME_LOOP%INPUT_NUMBER, &
                         & CONTROL_LOOP%TIME_LOOP%ITERATION_NUMBER,CURRENT_TIME,1.0_DP)
                       DO variable_idx=1,EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD%NUMBER_OF_VARIABLES
                         variable_type=EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD%VARIABLES(variable_idx)%VARIABLE_TYPE
                         FIELD_VARIABLE=>EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD%VARIABLE_TYPE_MAP(variable_type)%PTR
                         IF(ASSOCIATED(FIELD_VARIABLE)) THEN
                           DO component_idx=1,FIELD_VARIABLE%NUMBER_OF_COMPONENTS
                             DOMAIN=>FIELD_VARIABLE%COMPONENTS(component_idx)%DOMAIN
                             IF(ASSOCIATED(DOMAIN)) THEN
                               IF(ASSOCIATED(DOMAIN%TOPOLOGY)) THEN
                                 DOMAIN_NODES=>DOMAIN%TOPOLOGY%NODES
                                 IF(ASSOCIATED(DOMAIN_NODES)) THEN
                                   !Loop over the local nodes excluding the ghosts.
                                   DO node_idx=1,DOMAIN_NODES%NUMBER_OF_NODES
                                     DO deriv_idx=1,DOMAIN_NODES%NODES(node_idx)%NUMBER_OF_DERIVATIVES
                                       !Default to version 1 of each node derivative
                                       local_ny=FIELD_VARIABLE%COMPONENTS(component_idx)%PARAM_TO_DOF_MAP% &
                                         & NODE_PARAM2DOF_MAP%NODES(node_idx)%DERIVATIVES(deriv_idx)%VERSIONS(1)
                                       BOUNDARY_CONDITION_CHECK_VARIABLE=BOUNDARY_CONDITIONS_VARIABLE% &
                                         & GLOBAL_BOUNDARY_CONDITIONS(local_ny)
                                       IF(BOUNDARY_CONDITION_CHECK_VARIABLE==BOUNDARY_CONDITION_FIXED_INLET) THEN
                                         CALL FIELD_PARAMETER_SET_UPDATE_LOCAL_DOF(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD, &
                                           & FIELD_U_VARIABLE_TYPE,FIELD_VALUES_SET_TYPE,local_ny, &
                                           & BOUNDARY_VALUES(local_ny),ERR,ERROR,*999)
                                       END IF
                                     ENDDO !deriv_idx
                                   ENDDO !node_idx
                                 ENDIF
                               ENDIF
                             ENDIF
                           ENDDO !component_idx
                         ENDIF
                       ENDDO !variable_idx

!\todo: This part should be read in out of a file eventually
                     ELSE
                       CALL FLAG_ERROR("Boundary condition variable is not associated.",ERR,ERROR,*999)
                     END IF
                   ELSE
                     CALL FLAG_ERROR("Boundary conditions are not associated.",ERR,ERROR,*999)
                   END IF
                 ELSE
                   CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
                 END IF
               ELSE
                 CALL FLAG_ERROR("Equations are not associated.",ERR,ERROR,*999)
               END IF
              ELSE
                CALL FLAG_ERROR("Solver equations are not associated.",ERR,ERROR,*999)
              END IF
              CALL FIELD_PARAMETER_SET_UPDATE_START(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, &
                & FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)
              CALL FIELD_PARAMETER_SET_UPDATE_FINISH(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, &
                & FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)
            CASE(PROBLEM_PGM_NAVIER_STOKES_SUBTYPE)
             !Pre solve for the dynamic solver
             IF(SOLVER%SOLVE_TYPE==SOLVER_DYNAMIC_TYPE) THEN
               CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"Mesh movement change boundary conditions... ",ERR,ERROR,*999)
                SOLVER_EQUATIONS=>SOLVER%SOLVER_EQUATIONS
                IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
                  SOLVER_MAPPING=>SOLVER_EQUATIONS%SOLVER_MAPPING
                  EQUATIONS=>SOLVER_MAPPING%EQUATIONS_SET_TO_SOLVER_MAP(1)%EQUATIONS
                  IF(ASSOCIATED(EQUATIONS)) THEN
                    EQUATIONS_SET=>EQUATIONS%EQUATIONS_SET
                    IF(ASSOCIATED(EQUATIONS_SET)) THEN
                      BOUNDARY_CONDITIONS=>SOLVER_EQUATIONS%BOUNDARY_CONDITIONS
                      IF(ASSOCIATED(BOUNDARY_CONDITIONS)) THEN
                        FIELD_VARIABLE=>EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD%VARIABLE_TYPE_MAP(FIELD_U_VARIABLE_TYPE)%PTR
                        IF(ASSOCIATED(FIELD_VARIABLE)) THEN
                          CALL BOUNDARY_CONDITIONS_VARIABLE_GET(BOUNDARY_CONDITIONS,FIELD_VARIABLE, &
                            & BOUNDARY_CONDITIONS_VARIABLE,ERR,ERROR,*999)
                        ELSE
                          CALL FLAG_ERROR("Field U variable is not associated",ERR,ERROR,*999)
                        ENDIF
                        IF(ASSOCIATED(BOUNDARY_CONDITIONS_VARIABLE)) THEN
                          CALL FIELD_NUMBER_OF_COMPONENTS_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE, &
                            & NUMBER_OF_DIMENSIONS,ERR,ERROR,*999)
                          NULLIFY(MESH_VELOCITY_VALUES)
                          CALL FIELD_PARAMETER_SET_DATA_GET(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, & 
                            & FIELD_MESH_VELOCITY_SET_TYPE,MESH_VELOCITY_VALUES,ERR,ERROR,*999)
                          NULLIFY(BOUNDARY_VALUES)
                          CALL FIELD_PARAMETER_SET_DATA_GET(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, & 
                            & FIELD_BOUNDARY_SET_TYPE,BOUNDARY_VALUES,ERR,ERROR,*999)
                          CALL FLUID_MECHANICS_IO_READ_BOUNDARY_CONDITIONS(SOLVER_LINEAR_TYPE,BOUNDARY_VALUES, & 
                            & NUMBER_OF_DIMENSIONS,BOUNDARY_CONDITION_FIXED_INLET,CONTROL_LOOP%TIME_LOOP%INPUT_NUMBER, &
                            & CONTROL_LOOP%TIME_LOOP%ITERATION_NUMBER,CURRENT_TIME,1.0_DP)
                          DO variable_idx=1,EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD%NUMBER_OF_VARIABLES
                            variable_type=EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD%VARIABLES(variable_idx)%VARIABLE_TYPE
                            FIELD_VARIABLE=>EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD%VARIABLE_TYPE_MAP(variable_type)%PTR
                            IF(ASSOCIATED(FIELD_VARIABLE)) THEN
                              DO component_idx=1,FIELD_VARIABLE%NUMBER_OF_COMPONENTS
                                DOMAIN=>FIELD_VARIABLE%COMPONENTS(component_idx)%DOMAIN
                                IF(ASSOCIATED(DOMAIN)) THEN
                                  IF(ASSOCIATED(DOMAIN%TOPOLOGY)) THEN
                                    DOMAIN_NODES=>DOMAIN%TOPOLOGY%NODES
                                    IF(ASSOCIATED(DOMAIN_NODES)) THEN
                                      !Loop over the local nodes excluding the ghosts.
                                      DO node_idx=1,DOMAIN_NODES%NUMBER_OF_NODES
                                        DO deriv_idx=1,DOMAIN_NODES%NODES(node_idx)%NUMBER_OF_DERIVATIVES
                                          !Default to version 1 of each node derivative
                                          local_ny=FIELD_VARIABLE%COMPONENTS(component_idx)%PARAM_TO_DOF_MAP% &
                                            & NODE_PARAM2DOF_MAP%NODES(node_idx)%DERIVATIVES(deriv_idx)%VERSIONS(1)
                                          DISPLACEMENT_VALUE=0.0_DP
                                          BOUNDARY_CONDITION_CHECK_VARIABLE=BOUNDARY_CONDITIONS_VARIABLE% & 
                                            & GLOBAL_BOUNDARY_CONDITIONS(local_ny)
                                          IF(BOUNDARY_CONDITION_CHECK_VARIABLE==BOUNDARY_CONDITION_MOVED_WALL) THEN
                                            CALL FIELD_PARAMETER_SET_UPDATE_LOCAL_DOF(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD, & 
                                              & FIELD_U_VARIABLE_TYPE,FIELD_VALUES_SET_TYPE,local_ny, & 
                                              & MESH_VELOCITY_VALUES(local_ny),ERR,ERROR,*999)
                                          ELSE IF(BOUNDARY_CONDITION_CHECK_VARIABLE==BOUNDARY_CONDITION_FIXED_INLET) THEN
                                            CALL FIELD_PARAMETER_SET_UPDATE_LOCAL_DOF(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD, & 
                                              & FIELD_U_VARIABLE_TYPE,FIELD_VALUES_SET_TYPE,local_ny, & 
                                              & BOUNDARY_VALUES(local_ny),ERR,ERROR,*999)
                                          END IF
                                        ENDDO !deriv_idx
                                      ENDDO !node_idx
                                    ENDIF
                                  ENDIF
                                ENDIF
                              ENDDO !component_idx
                            ENDIF
                          ENDDO !variable_idx
                        ELSE
                          CALL FLAG_ERROR("Boundary condition variable is not associated.",ERR,ERROR,*999)
                        END IF
                      ELSE
                        CALL FLAG_ERROR("Boundary conditions are not associated.",ERR,ERROR,*999)
                      END IF
                    ELSE
                      CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
                    END IF
                  ELSE
                    CALL FLAG_ERROR("Equations are not associated.",ERR,ERROR,*999)
                  END IF                
                ELSE
                  CALL FLAG_ERROR("Solver equations are not associated.",ERR,ERROR,*999)
                END IF  
                CALL FIELD_PARAMETER_SET_UPDATE_START(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, & 
                  & FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)
                CALL FIELD_PARAMETER_SET_UPDATE_FINISH(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, & 
                  & FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)
              END IF
            CASE(PROBLEM_ALE_NAVIER_STOKES_SUBTYPE)
              !Pre solve for the linear solver
              IF(SOLVER%SOLVE_TYPE==SOLVER_LINEAR_TYPE) THEN
                CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"Mesh movement change boundary conditions... ",ERR,ERROR,*999)
                SOLVER_EQUATIONS=>SOLVER%SOLVER_EQUATIONS
                IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
                  SOLVER_MAPPING=>SOLVER_EQUATIONS%SOLVER_MAPPING
                  EQUATIONS=>SOLVER_MAPPING%EQUATIONS_SET_TO_SOLVER_MAP(1)%EQUATIONS
                  IF(ASSOCIATED(EQUATIONS)) THEN
                    EQUATIONS_SET=>EQUATIONS%EQUATIONS_SET
                    IF(ASSOCIATED(EQUATIONS_SET)) THEN
                      BOUNDARY_CONDITIONS=>SOLVER_EQUATIONS%BOUNDARY_CONDITIONS
                      IF(ASSOCIATED(BOUNDARY_CONDITIONS)) THEN
                        FIELD_VARIABLE=>EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD%VARIABLE_TYPE_MAP(FIELD_U_VARIABLE_TYPE)%PTR
                        IF(ASSOCIATED(FIELD_VARIABLE)) THEN
                          CALL BOUNDARY_CONDITIONS_VARIABLE_GET(BOUNDARY_CONDITIONS,FIELD_VARIABLE, &
                            & BOUNDARY_CONDITIONS_VARIABLE,ERR,ERROR,*999)
                        ELSE
                          CALL FLAG_ERROR("Field U variable is not associated",ERR,ERROR,*999)
                        ENDIF
                        IF(ASSOCIATED(BOUNDARY_CONDITIONS_VARIABLE)) THEN
                          CALL FIELD_NUMBER_OF_COMPONENTS_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE, &
                            & NUMBER_OF_DIMENSIONS,ERR,ERROR,*999)
                          NULLIFY(BOUNDARY_VALUES)
                          CALL FIELD_PARAMETER_SET_DATA_GET(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, & 
                            & FIELD_BOUNDARY_SET_TYPE,BOUNDARY_VALUES,ERR,ERROR,*999)
                          CALL FLUID_MECHANICS_IO_READ_BOUNDARY_CONDITIONS(SOLVER_LINEAR_TYPE,BOUNDARY_VALUES, & 
                            & NUMBER_OF_DIMENSIONS,BOUNDARY_CONDITION_MOVED_WALL,CONTROL_LOOP%TIME_LOOP%INPUT_NUMBER, &
                            & CONTROL_LOOP%TIME_LOOP%ITERATION_NUMBER,CURRENT_TIME,1.0_DP)
                          DO variable_idx=1,EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD%NUMBER_OF_VARIABLES
                            variable_type=EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD%VARIABLES(variable_idx)%VARIABLE_TYPE
                            FIELD_VARIABLE=>EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD%VARIABLE_TYPE_MAP(variable_type)%PTR
                            IF(ASSOCIATED(FIELD_VARIABLE)) THEN
                              DO component_idx=1,FIELD_VARIABLE%NUMBER_OF_COMPONENTS
                                DOMAIN=>FIELD_VARIABLE%COMPONENTS(component_idx)%DOMAIN
                                IF(ASSOCIATED(DOMAIN)) THEN
                                  IF(ASSOCIATED(DOMAIN%TOPOLOGY)) THEN
                                    DOMAIN_NODES=>DOMAIN%TOPOLOGY%NODES
                                    IF(ASSOCIATED(DOMAIN_NODES)) THEN
                                      !Loop over the local nodes excluding the ghosts.
                                      DO node_idx=1,DOMAIN_NODES%NUMBER_OF_NODES
                                        DO deriv_idx=1,DOMAIN_NODES%NODES(node_idx)%NUMBER_OF_DERIVATIVES
                                          !Default to version 1 of each node derivative
                                          local_ny=FIELD_VARIABLE%COMPONENTS(component_idx)%PARAM_TO_DOF_MAP% &
                                            & NODE_PARAM2DOF_MAP%NODES(node_idx)%DERIVATIVES(deriv_idx)%VERSIONS(1)
                                          BOUNDARY_CONDITION_CHECK_VARIABLE=BOUNDARY_CONDITIONS_VARIABLE% & 
                                            & GLOBAL_BOUNDARY_CONDITIONS(local_ny)
                                          IF(BOUNDARY_CONDITION_CHECK_VARIABLE==BOUNDARY_CONDITION_MOVED_WALL) THEN
                                            CALL FIELD_PARAMETER_SET_UPDATE_LOCAL_DOF(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD, & 
                                              & FIELD_U_VARIABLE_TYPE,FIELD_VALUES_SET_TYPE,local_ny, & 
                                              & BOUNDARY_VALUES(local_ny),ERR,ERROR,*999)
                                          END IF
                                        ENDDO !deriv_idx
                                      ENDDO !node_idx
                                    ENDIF
                                  ENDIF
                                ENDIF
                              ENDDO !component_idx
                            ENDIF
                          ENDDO !variable_idx
                          CALL FIELD_PARAMETER_SET_DATA_RESTORE(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD, &
                            & FIELD_U_VARIABLE_TYPE,FIELD_BOUNDARY_SET_TYPE,BOUNDARY_VALUES,ERR,ERROR,*999)
!\todo: This part should be read in out of a file eventually
                        ELSE
                          CALL FLAG_ERROR("Boundary condition variable is not associated.",ERR,ERROR,*999)
                        END IF
                      ELSE
                        CALL FLAG_ERROR("Boundary conditions are not associated.",ERR,ERROR,*999)
                      END IF
                    ELSE
                      CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
                    END IF
                  ELSE
                    CALL FLAG_ERROR("Equations are not associated.",ERR,ERROR,*999)
                  END IF                
                ELSE
                  CALL FLAG_ERROR("Solver equations are not associated.",ERR,ERROR,*999)
                END IF  
                CALL FIELD_PARAMETER_SET_UPDATE_START(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, & 
                  & FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)
                CALL FIELD_PARAMETER_SET_UPDATE_FINISH(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, & 
                  & FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)
              !Pre solve for the dynamic solver
              ELSE IF(SOLVER%SOLVE_TYPE==SOLVER_DYNAMIC_TYPE) THEN
               CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"Mesh movement change boundary conditions... ",ERR,ERROR,*999)
                SOLVER_EQUATIONS=>SOLVER%SOLVER_EQUATIONS
                IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
                  SOLVER_MAPPING=>SOLVER_EQUATIONS%SOLVER_MAPPING
                  EQUATIONS=>SOLVER_MAPPING%EQUATIONS_SET_TO_SOLVER_MAP(1)%EQUATIONS
                  IF(ASSOCIATED(EQUATIONS)) THEN
                    EQUATIONS_SET=>EQUATIONS%EQUATIONS_SET
                    IF(ASSOCIATED(EQUATIONS_SET)) THEN
                      BOUNDARY_CONDITIONS=>SOLVER_EQUATIONS%BOUNDARY_CONDITIONS
                      IF(ASSOCIATED(BOUNDARY_CONDITIONS)) THEN
                        FIELD_VARIABLE=>EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD%VARIABLE_TYPE_MAP(FIELD_U_VARIABLE_TYPE)%PTR
                        IF(ASSOCIATED(FIELD_VARIABLE)) THEN
                          CALL BOUNDARY_CONDITIONS_VARIABLE_GET(BOUNDARY_CONDITIONS,FIELD_VARIABLE, &
                            & BOUNDARY_CONDITIONS_VARIABLE,ERR,ERROR,*999)
                        ELSE
                          CALL FLAG_ERROR("Field U variable is not associated",ERR,ERROR,*999)
                        ENDIF
                        IF(ASSOCIATED(BOUNDARY_CONDITIONS_VARIABLE)) THEN
                          CALL FIELD_NUMBER_OF_COMPONENTS_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE, &
                            & NUMBER_OF_DIMENSIONS,ERR,ERROR,*999)
                          NULLIFY(MESH_VELOCITY_VALUES)
                          CALL FIELD_PARAMETER_SET_DATA_GET(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, & 
                            & FIELD_MESH_VELOCITY_SET_TYPE,MESH_VELOCITY_VALUES,ERR,ERROR,*999)
                          NULLIFY(BOUNDARY_VALUES)
                          CALL FIELD_PARAMETER_SET_DATA_GET(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, & 
                            & FIELD_BOUNDARY_SET_TYPE,BOUNDARY_VALUES,ERR,ERROR,*999)
                          CALL FLUID_MECHANICS_IO_READ_BOUNDARY_CONDITIONS(SOLVER_LINEAR_TYPE,BOUNDARY_VALUES, & 
                            & NUMBER_OF_DIMENSIONS,BOUNDARY_CONDITION_FIXED_INLET,CONTROL_LOOP%TIME_LOOP%INPUT_NUMBER, &
                            & CONTROL_LOOP%TIME_LOOP%ITERATION_NUMBER,CURRENT_TIME,1.0_DP)
                          DO variable_idx=1,EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD%NUMBER_OF_VARIABLES
                            variable_type=EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD%VARIABLES(variable_idx)%VARIABLE_TYPE
                            FIELD_VARIABLE=>EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD%VARIABLE_TYPE_MAP(variable_type)%PTR
                            IF(ASSOCIATED(FIELD_VARIABLE)) THEN
                              DO component_idx=1,FIELD_VARIABLE%NUMBER_OF_COMPONENTS
                                DOMAIN=>FIELD_VARIABLE%COMPONENTS(component_idx)%DOMAIN
                                IF(ASSOCIATED(DOMAIN)) THEN
                                  IF(ASSOCIATED(DOMAIN%TOPOLOGY)) THEN
                                    DOMAIN_NODES=>DOMAIN%TOPOLOGY%NODES
                                    IF(ASSOCIATED(DOMAIN_NODES)) THEN
                                      !Loop over the local nodes excluding the ghosts.
                                      DO node_idx=1,DOMAIN_NODES%NUMBER_OF_NODES
                                        DO deriv_idx=1,DOMAIN_NODES%NODES(node_idx)%NUMBER_OF_DERIVATIVES
                                          !Default to version 1 of each node derivative
                                          local_ny=FIELD_VARIABLE%COMPONENTS(component_idx)%PARAM_TO_DOF_MAP% &
                                            & NODE_PARAM2DOF_MAP%NODES(node_idx)%DERIVATIVES(deriv_idx)%VERSIONS(1)
                                          DISPLACEMENT_VALUE=0.0_DP
                                          BOUNDARY_CONDITION_CHECK_VARIABLE=BOUNDARY_CONDITIONS_VARIABLE% & 
                                            & GLOBAL_BOUNDARY_CONDITIONS(local_ny)
                                          IF(BOUNDARY_CONDITION_CHECK_VARIABLE==BOUNDARY_CONDITION_MOVED_WALL) THEN
                                            CALL FIELD_PARAMETER_SET_UPDATE_LOCAL_DOF(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD, & 
                                              & FIELD_U_VARIABLE_TYPE,FIELD_VALUES_SET_TYPE,local_ny, & 
                                              & MESH_VELOCITY_VALUES(local_ny),ERR,ERROR,*999)
                                          ELSE IF(BOUNDARY_CONDITION_CHECK_VARIABLE==BOUNDARY_CONDITION_FIXED_INLET) THEN
                                            CALL FIELD_PARAMETER_SET_UPDATE_LOCAL_DOF(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD, & 
                                              & FIELD_U_VARIABLE_TYPE,FIELD_VALUES_SET_TYPE,local_ny, & 
                                              & BOUNDARY_VALUES(local_ny),ERR,ERROR,*999)
                                          END IF
                                        ENDDO !deriv_idx
                                      ENDDO !node_idx
                                    ENDIF
                                  ENDIF
                                ENDIF
                              ENDDO !component_idx
                            ENDIF
                          ENDDO !variable_idx
                          CALL FIELD_PARAMETER_SET_DATA_RESTORE(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD, &
                            & FIELD_U_VARIABLE_TYPE,FIELD_MESH_VELOCITY_SET_TYPE,MESH_VELOCITY_VALUES,ERR,ERROR,*999)
                          CALL FIELD_PARAMETER_SET_DATA_RESTORE(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD, &
                            & FIELD_U_VARIABLE_TYPE,FIELD_BOUNDARY_SET_TYPE,BOUNDARY_VALUES,ERR,ERROR,*999)
                        ELSE
                          CALL FLAG_ERROR("Boundary condition variable is not associated.",ERR,ERROR,*999)
                        END IF
                      ELSE
                        CALL FLAG_ERROR("Boundary conditions are not associated.",ERR,ERROR,*999)
                      END IF
                    ELSE
                      CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
                    END IF
                  ELSE
                    CALL FLAG_ERROR("Equations are not associated.",ERR,ERROR,*999)
                  END IF                
                ELSE
                  CALL FLAG_ERROR("Solver equations are not associated.",ERR,ERROR,*999)
                END IF  
                CALL FIELD_PARAMETER_SET_UPDATE_START(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, & 
                  & FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)
                CALL FIELD_PARAMETER_SET_UPDATE_FINISH(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, & 
                  & FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)
              END IF
              ! do nothing ???
            CASE DEFAULT
              LOCAL_ERROR="Problem subtype "//TRIM(NUMBER_TO_VSTRING(CONTROL_LOOP%PROBLEM%SUBTYPE,"*",ERR,ERROR))// &
                & " is not valid for a Navier-Stokes equation fluid type of a fluid mechanics problem class."
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        ELSE
          CALL FLAG_ERROR("Problem is not associated.",ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Solver is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Control loop is not associated.",ERR,ERROR,*999)
    ENDIF

    CALL EXITS("NAVIER_STOKES_PRE_SOLVE_UPDATE_BOUNDARY_CONDITIONS")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_PRE_SOLVE_UPDATE_BOUNDARY_CONDITIONS",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_PRE_SOLVE_UPDATE_BOUNDARY_CONDITIONS")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_PRE_SOLVE_UPDATE_BOUNDARY_CONDITIONS

  !
  !================================================================================================================================
  !

  !>Update mesh velocity and move mesh for ALE Navier-Stokes problem
  SUBROUTINE NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_MESH(CONTROL_LOOP,SOLVER,ERR,ERROR,*)

    !Argument variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP !<A pointer to the control loop to solve.
    TYPE(SOLVER_TYPE), POINTER :: SOLVER !<A pointer to the solvers
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(SOLVER_TYPE), POINTER :: SOLVER_ALE_NAVIER_STOKES, SOLVER_LAPLACE !<A pointer to the solvers
    TYPE(FIELD_TYPE), POINTER :: DEPENDENT_FIELD_LAPLACE, INDEPENDENT_FIELD_ALE_NAVIER_STOKES
    TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: SOLVER_EQUATIONS_LAPLACE, SOLVER_EQUATIONS_ALE_NAVIER_STOKES  !<A pointer to the solver equations
    TYPE(SOLVER_MAPPING_TYPE), POINTER :: SOLVER_MAPPING_LAPLACE, SOLVER_MAPPING_ALE_NAVIER_STOKES !<A pointer to the solver mapping
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET_LAPLACE, EQUATIONS_SET_ALE_NAVIER_STOKES !<A pointer to the equations set
    TYPE(EQUATIONS_TYPE), POINTER :: EQUATIONS
    TYPE(EQUATIONS_MAPPING_TYPE), POINTER :: EQUATIONS_MAPPING
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    TYPE(FIELD_VARIABLE_TYPE), POINTER :: FIELD_VARIABLE
    TYPE(DOMAIN_TYPE), POINTER :: DOMAIN
    TYPE(DOMAIN_NODES_TYPE), POINTER :: DOMAIN_NODES


!\todo: Reduce number of variables used
    REAL(DP) :: CURRENT_TIME,TIME_INCREMENT,ALPHA
    REAL(DP), POINTER :: MESH_DISPLACEMENT_VALUES(:)
    INTEGER(INTG) :: I,NUMBER_OF_DIMENSIONS_LAPLACE
    INTEGER(INTG) :: NUMBER_OF_DIMENSIONS_ALE_NAVIER_STOKES,GEOMETRIC_MESH_COMPONENT,INPUT_TYPE,INPUT_OPTION
    INTEGER(INTG) :: component_idx,deriv_idx,local_ny,node_idx,variable_idx,variable_type

    CALL ENTERS("NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_MESH",ERR,ERROR,*999)

    IF(ASSOCIATED(CONTROL_LOOP)) THEN
      CALL CONTROL_LOOP_CURRENT_TIMES_GET(CONTROL_LOOP,CURRENT_TIME,TIME_INCREMENT,ERR,ERROR,*999)
      NULLIFY(SOLVER_LAPLACE)
      NULLIFY(SOLVER_ALE_NAVIER_STOKES)

      IF(ASSOCIATED(SOLVER)) THEN
        IF(ASSOCIATED(CONTROL_LOOP%PROBLEM)) THEN
          SELECT CASE(CONTROL_LOOP%PROBLEM%SUBTYPE)
            CASE(PROBLEM_STATIC_NAVIER_STOKES_SUBTYPE,PROBLEM_LAPLACE_NAVIER_STOKES_SUBTYPE)
              ! do nothing ???
            CASE(PROBLEM_TRANSIENT_NAVIER_STOKES_SUBTYPE)
              ! do nothing ???
            CASE(PROBLEM_1DTRANSIENT_NAVIER_STOKES_SUBTYPE)
              ! do nothing ???
            CASE(PROBLEM_PGM_NAVIER_STOKES_SUBTYPE)
              !Update mesh within the dynamic solver
              IF(SOLVER%SOLVE_TYPE==SOLVER_DYNAMIC_TYPE) THEN
                !Get the independent field for the ALE Navier-Stokes problem
                CALL SOLVERS_SOLVER_GET(SOLVER%SOLVERS,1,SOLVER_ALE_NAVIER_STOKES,ERR,ERROR,*999)
                SOLVER_EQUATIONS_ALE_NAVIER_STOKES=>SOLVER_ALE_NAVIER_STOKES%SOLVER_EQUATIONS
                IF(ASSOCIATED(SOLVER_EQUATIONS_ALE_NAVIER_STOKES)) THEN
                  SOLVER_MAPPING_ALE_NAVIER_STOKES=>SOLVER_EQUATIONS_ALE_NAVIER_STOKES%SOLVER_MAPPING
                  IF(ASSOCIATED(SOLVER_MAPPING_ALE_NAVIER_STOKES)) THEN
                    EQUATIONS_SET_ALE_NAVIER_STOKES=>SOLVER_MAPPING_ALE_NAVIER_STOKES%EQUATIONS_SETS(1)%PTR
                    IF(ASSOCIATED(EQUATIONS_SET_ALE_NAVIER_STOKES)) THEN
                      INDEPENDENT_FIELD_ALE_NAVIER_STOKES=>EQUATIONS_SET_ALE_NAVIER_STOKES%INDEPENDENT%INDEPENDENT_FIELD
                    ELSE
                      CALL FLAG_ERROR("ALE Navier-Stokes equations set is not associated.",ERR,ERROR,*999)
                    END IF
                    !Get the data
                    CALL FIELD_NUMBER_OF_COMPONENTS_GET(EQUATIONS_SET_ALE_NAVIER_STOKES%GEOMETRY%GEOMETRIC_FIELD, & 
                      & FIELD_U_VARIABLE_TYPE,NUMBER_OF_DIMENSIONS_ALE_NAVIER_STOKES,ERR,ERROR,*999)
!\todo: Introduce user calls instead of hard-coding 42/1
                    !Copy input to Navier-Stokes' independent field
                    INPUT_TYPE=42
                    INPUT_OPTION=1
                    NULLIFY(MESH_DISPLACEMENT_VALUES)
                    CALL FIELD_PARAMETER_SET_DATA_GET(EQUATIONS_SET_ALE_NAVIER_STOKES%INDEPENDENT%INDEPENDENT_FIELD, &
                      & FIELD_U_VARIABLE_TYPE,FIELD_MESH_DISPLACEMENT_SET_TYPE,MESH_DISPLACEMENT_VALUES,ERR,ERROR,*999)
                    CALL FLUID_MECHANICS_IO_READ_DATA(SOLVER_LINEAR_TYPE,MESH_DISPLACEMENT_VALUES, & 
                      & NUMBER_OF_DIMENSIONS_ALE_NAVIER_STOKES,INPUT_TYPE,INPUT_OPTION, &
                      & CONTROL_LOOP%TIME_LOOP%ITERATION_NUMBER,1.0_DP)
                    CALL FIELD_PARAMETER_SET_UPDATE_START(EQUATIONS_SET_ALE_NAVIER_STOKES%INDEPENDENT%INDEPENDENT_FIELD, & 
                      & FIELD_U_VARIABLE_TYPE,FIELD_MESH_DISPLACEMENT_SET_TYPE,ERR,ERROR,*999)
                    CALL FIELD_PARAMETER_SET_UPDATE_FINISH(EQUATIONS_SET_ALE_NAVIER_STOKES%INDEPENDENT%INDEPENDENT_FIELD, & 
                      & FIELD_U_VARIABLE_TYPE,FIELD_MESH_DISPLACEMENT_SET_TYPE,ERR,ERROR,*999)
                  ELSE
                    CALL FLAG_ERROR("ALE Navier-Stokes solver mapping is not associated.",ERR,ERROR,*999)
                  END IF
                ELSE
                  CALL FLAG_ERROR("ALE Navier-Stokes solver equations are not associated.",ERR,ERROR,*999)
                END IF
                 !Use calculated values to update mesh
                CALL FIELD_COMPONENT_MESH_COMPONENT_GET(EQUATIONS_SET_ALE_NAVIER_STOKES%GEOMETRY%GEOMETRIC_FIELD, & 
                  & FIELD_U_VARIABLE_TYPE,1,GEOMETRIC_MESH_COMPONENT,ERR,ERROR,*999)
!                 CALL FIELD_PARAMETER_SET_DATA_GET(INDEPENDENT_FIELD_ALE_NAVIER_STOKES,FIELD_U_VARIABLE_TYPE, & 
!                   & FIELD_MESH_DISPLACEMENT_SET_TYPE,MESH_DISPLACEMENT_VALUES,ERR,ERROR,*999)
                EQUATIONS=>SOLVER_MAPPING_ALE_NAVIER_STOKES%EQUATIONS_SET_TO_SOLVER_MAP(1)%EQUATIONS
                IF(ASSOCIATED(EQUATIONS)) THEN
                  EQUATIONS_MAPPING=>EQUATIONS%EQUATIONS_MAPPING
                  IF(ASSOCIATED(EQUATIONS_MAPPING)) THEN
                    DO variable_idx=1,EQUATIONS_SET_ALE_NAVIER_STOKES%GEOMETRY%GEOMETRIC_FIELD%NUMBER_OF_VARIABLES
                      variable_type=EQUATIONS_SET_ALE_NAVIER_STOKES%GEOMETRY%GEOMETRIC_FIELD%VARIABLES(variable_idx)%VARIABLE_TYPE
                      FIELD_VARIABLE=>EQUATIONS_SET_ALE_NAVIER_STOKES%GEOMETRY%GEOMETRIC_FIELD%VARIABLE_TYPE_MAP(variable_type)%PTR
                      IF(ASSOCIATED(FIELD_VARIABLE)) THEN
                        DO component_idx=1,FIELD_VARIABLE%NUMBER_OF_COMPONENTS
                          DOMAIN=>FIELD_VARIABLE%COMPONENTS(component_idx)%DOMAIN
                          IF(ASSOCIATED(DOMAIN)) THEN
                            IF(ASSOCIATED(DOMAIN%TOPOLOGY)) THEN
                              DOMAIN_NODES=>DOMAIN%TOPOLOGY%NODES
                              IF(ASSOCIATED(DOMAIN_NODES)) THEN
                                !Loop over the local nodes excluding the ghosts.
                                DO node_idx=1,DOMAIN_NODES%NUMBER_OF_NODES
                                  DO deriv_idx=1,DOMAIN_NODES%NODES(node_idx)%NUMBER_OF_DERIVATIVES
                                    !Default to version 1 of each node derivative
                                    local_ny=FIELD_VARIABLE%COMPONENTS(component_idx)%PARAM_TO_DOF_MAP% &
                                      & NODE_PARAM2DOF_MAP%NODES(node_idx)%DERIVATIVES(deriv_idx)%VERSIONS(1)
                                    CALL FIELD_PARAMETER_SET_ADD_LOCAL_DOF(EQUATIONS_SET_ALE_NAVIER_STOKES%GEOMETRY% &
                                      & GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE,FIELD_VALUES_SET_TYPE,local_ny, & 
                                      & MESH_DISPLACEMENT_VALUES(local_ny),ERR,ERROR,*999)
                                  ENDDO !deriv_idx
                                ENDDO !node_idx
                              ENDIF
                            ENDIF
                          ENDIF
                        ENDDO !component_idx
                      ENDIF
                    ENDDO !variable_idx
                  ELSE
                    CALL FLAG_ERROR("Equations mapping is not associated.",ERR,ERROR,*999)
                  END IF
                ELSE
                  CALL FLAG_ERROR("Equations are not associated.",ERR,ERROR,*999)
                END IF
                CALL FIELD_PARAMETER_SET_UPDATE_START(EQUATIONS_SET_ALE_NAVIER_STOKES%GEOMETRY%GEOMETRIC_FIELD, & 
                  & FIELD_U_VARIABLE_TYPE,FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)
                CALL FIELD_PARAMETER_SET_UPDATE_FINISH(EQUATIONS_SET_ALE_NAVIER_STOKES%GEOMETRY%GEOMETRIC_FIELD, & 
                  & FIELD_U_VARIABLE_TYPE,FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)
                !Now use displacement values to calculate velocity values
                TIME_INCREMENT=CONTROL_LOOP%TIME_LOOP%TIME_INCREMENT
                ALPHA=1.0_DP/TIME_INCREMENT
                CALL FIELD_PARAMETER_SETS_COPY(INDEPENDENT_FIELD_ALE_NAVIER_STOKES,FIELD_U_VARIABLE_TYPE, & 
                  & FIELD_MESH_DISPLACEMENT_SET_TYPE,FIELD_MESH_VELOCITY_SET_TYPE,ALPHA,ERR,ERROR,*999)
              ELSE  
                CALL FLAG_ERROR("Mesh motion calculation not successful for ALE problem.",ERR,ERROR,*999)
              END IF
            CASE(PROBLEM_ALE_NAVIER_STOKES_SUBTYPE)
              !Update mesh within the dynamic solver
              IF(SOLVER%SOLVE_TYPE==SOLVER_DYNAMIC_TYPE) THEN
                IF(SOLVER%DYNAMIC_SOLVER%ALE) THEN
                  !Get the dependent field for the three component Laplace problem
                  CALL SOLVERS_SOLVER_GET(SOLVER%SOLVERS,1,SOLVER_LAPLACE,ERR,ERROR,*999)
                  SOLVER_EQUATIONS_LAPLACE=>SOLVER_LAPLACE%SOLVER_EQUATIONS
                  IF(ASSOCIATED(SOLVER_EQUATIONS_LAPLACE)) THEN
                    SOLVER_MAPPING_LAPLACE=>SOLVER_EQUATIONS_LAPLACE%SOLVER_MAPPING
                    IF(ASSOCIATED(SOLVER_MAPPING_LAPLACE)) THEN
                      EQUATIONS_SET_LAPLACE=>SOLVER_MAPPING_LAPLACE%EQUATIONS_SETS(1)%PTR
                      IF(ASSOCIATED(EQUATIONS_SET_LAPLACE)) THEN
                        DEPENDENT_FIELD_LAPLACE=>EQUATIONS_SET_LAPLACE%DEPENDENT%DEPENDENT_FIELD
                      ELSE
                        CALL FLAG_ERROR("Laplace equations set is not associated.",ERR,ERROR,*999)
                      END IF
                      CALL FIELD_NUMBER_OF_COMPONENTS_GET(EQUATIONS_SET_LAPLACE%GEOMETRY%GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE, &
                        & NUMBER_OF_DIMENSIONS_LAPLACE,ERR,ERROR,*999)
                    ELSE
                      CALL FLAG_ERROR("Laplace solver mapping is not associated.",ERR,ERROR,*999)
                    END IF
                  ELSE
                    CALL FLAG_ERROR("Laplace solver equations are not associated.",ERR,ERROR,*999)
                  END IF
                  !Get the independent field for the ALE Navier-Stokes problem
                  CALL SOLVERS_SOLVER_GET(SOLVER%SOLVERS,2,SOLVER_ALE_NAVIER_STOKES,ERR,ERROR,*999)
                  SOLVER_EQUATIONS_ALE_NAVIER_STOKES=>SOLVER_ALE_NAVIER_STOKES%SOLVER_EQUATIONS
                  IF(ASSOCIATED(SOLVER_EQUATIONS_ALE_NAVIER_STOKES)) THEN
                    SOLVER_MAPPING_ALE_NAVIER_STOKES=>SOLVER_EQUATIONS_ALE_NAVIER_STOKES%SOLVER_MAPPING
                    IF(ASSOCIATED(SOLVER_MAPPING_ALE_NAVIER_STOKES)) THEN
                      EQUATIONS_SET_ALE_NAVIER_STOKES=>SOLVER_MAPPING_ALE_NAVIER_STOKES%EQUATIONS_SETS(1)%PTR
                      IF(ASSOCIATED(EQUATIONS_SET_ALE_NAVIER_STOKES)) THEN
                        INDEPENDENT_FIELD_ALE_NAVIER_STOKES=>EQUATIONS_SET_ALE_NAVIER_STOKES%INDEPENDENT%INDEPENDENT_FIELD
                      ELSE
                        CALL FLAG_ERROR("ALE Navier-Stokes equations set is not associated.",ERR,ERROR,*999)
                      END IF
                      CALL FIELD_NUMBER_OF_COMPONENTS_GET(EQUATIONS_SET_ALE_NAVIER_STOKES%GEOMETRY%GEOMETRIC_FIELD, & 
                        & FIELD_U_VARIABLE_TYPE,NUMBER_OF_DIMENSIONS_ALE_NAVIER_STOKES,ERR,ERROR,*999)
                    ELSE
                      CALL FLAG_ERROR("ALE Navier-Stokes solver mapping is not associated.",ERR,ERROR,*999)
                    END IF
                  ELSE
                    CALL FLAG_ERROR("ALE Navier-Stokes solver equations are not associated.",ERR,ERROR,*999)
                  END IF
                  !Copy result from Laplace mesh movement to Navier-Stokes' independent field
                  IF(NUMBER_OF_DIMENSIONS_ALE_NAVIER_STOKES==NUMBER_OF_DIMENSIONS_LAPLACE) THEN
                    DO I=1,NUMBER_OF_DIMENSIONS_ALE_NAVIER_STOKES
                      CALL FIELD_PARAMETERS_TO_FIELD_PARAMETERS_COMPONENT_COPY(DEPENDENT_FIELD_LAPLACE, & 
                        & FIELD_U_VARIABLE_TYPE,FIELD_VALUES_SET_TYPE,I,INDEPENDENT_FIELD_ALE_NAVIER_STOKES, & 
                        & FIELD_U_VARIABLE_TYPE,FIELD_MESH_DISPLACEMENT_SET_TYPE,I,ERR,ERROR,*999)
                    END DO
                  ELSE
                    CALL FLAG_ERROR("Dimension of Laplace and ALE Navier-Stokes equations set is not consistent.",ERR,ERROR,*999)
                  END IF
                  !Use calculated values to update mesh
                  CALL FIELD_COMPONENT_MESH_COMPONENT_GET(EQUATIONS_SET_ALE_NAVIER_STOKES%GEOMETRY%GEOMETRIC_FIELD, & 
                    & FIELD_U_VARIABLE_TYPE,1,GEOMETRIC_MESH_COMPONENT,ERR,ERROR,*999)
                  NULLIFY(MESH_DISPLACEMENT_VALUES)
                  CALL FIELD_PARAMETER_SET_DATA_GET(INDEPENDENT_FIELD_ALE_NAVIER_STOKES,FIELD_U_VARIABLE_TYPE, & 
                    & FIELD_MESH_DISPLACEMENT_SET_TYPE,MESH_DISPLACEMENT_VALUES,ERR,ERROR,*999)
                  EQUATIONS=>SOLVER_MAPPING_LAPLACE%EQUATIONS_SET_TO_SOLVER_MAP(1)%EQUATIONS
                  IF(ASSOCIATED(EQUATIONS)) THEN
                    EQUATIONS_MAPPING=>EQUATIONS%EQUATIONS_MAPPING
                    IF(ASSOCIATED(EQUATIONS_MAPPING)) THEN
                      DO variable_idx=1,EQUATIONS_SET_ALE_NAVIER_STOKES%GEOMETRY%GEOMETRIC_FIELD%NUMBER_OF_VARIABLES
                        variable_type=EQUATIONS_SET_ALE_NAVIER_STOKES%GEOMETRY%GEOMETRIC_FIELD%VARIABLES(variable_idx)%VARIABLE_TYPE
                        FIELD_VARIABLE=>EQUATIONS_SET_ALE_NAVIER_STOKES%GEOMETRY%GEOMETRIC_FIELD% &
                          & VARIABLE_TYPE_MAP(variable_type)%PTR
                        IF(ASSOCIATED(FIELD_VARIABLE)) THEN
                          DO component_idx=1,FIELD_VARIABLE%NUMBER_OF_COMPONENTS
                            DOMAIN=>FIELD_VARIABLE%COMPONENTS(component_idx)%DOMAIN
                            IF(ASSOCIATED(DOMAIN)) THEN
                              IF(ASSOCIATED(DOMAIN%TOPOLOGY)) THEN
                                DOMAIN_NODES=>DOMAIN%TOPOLOGY%NODES
                                IF(ASSOCIATED(DOMAIN_NODES)) THEN
                                  !Loop over the local nodes excluding the ghosts.
                                  DO node_idx=1,DOMAIN_NODES%NUMBER_OF_NODES
                                    DO deriv_idx=1,DOMAIN_NODES%NODES(node_idx)%NUMBER_OF_DERIVATIVES
                                      !Default to version 1 of each node derivative
                                      local_ny=FIELD_VARIABLE%COMPONENTS(component_idx)%PARAM_TO_DOF_MAP% &
                                        & NODE_PARAM2DOF_MAP%NODES(node_idx)%DERIVATIVES(deriv_idx)%VERSIONS(1)
                                      CALL FIELD_PARAMETER_SET_ADD_LOCAL_DOF(EQUATIONS_SET_ALE_NAVIER_STOKES%GEOMETRY% &
                                        & GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE,FIELD_VALUES_SET_TYPE,local_ny, & 
                                        & MESH_DISPLACEMENT_VALUES(local_ny),ERR,ERROR,*999)
                                    ENDDO !deriv_idx
                                  ENDDO !node_idx
                                ENDIF
                              ENDIF
                            ENDIF
                          ENDDO !component_idx
                        ENDIF
                      ENDDO !variable_idx
                    ELSE
                      CALL FLAG_ERROR("Equations mapping is not associated.",ERR,ERROR,*999)
                    ENDIF
                    CALL FIELD_PARAMETER_SET_DATA_RESTORE(INDEPENDENT_FIELD_ALE_NAVIER_STOKES,FIELD_U_VARIABLE_TYPE, & 
                      & FIELD_MESH_DISPLACEMENT_SET_TYPE,MESH_DISPLACEMENT_VALUES,ERR,ERROR,*999)
                  ELSE
                    CALL FLAG_ERROR("Equations are not associated.",ERR,ERROR,*999)
                  END IF
                  CALL FIELD_PARAMETER_SET_UPDATE_START(EQUATIONS_SET_ALE_NAVIER_STOKES%GEOMETRY%GEOMETRIC_FIELD, & 
                    & FIELD_U_VARIABLE_TYPE,FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)
                  CALL FIELD_PARAMETER_SET_UPDATE_FINISH(EQUATIONS_SET_ALE_NAVIER_STOKES%GEOMETRY%GEOMETRIC_FIELD, & 
                    & FIELD_U_VARIABLE_TYPE,FIELD_VALUES_SET_TYPE,ERR,ERROR,*999)
                  !Now use displacement values to calculate velocity values
                  TIME_INCREMENT=CONTROL_LOOP%TIME_LOOP%TIME_INCREMENT
                  ALPHA=1.0_DP/TIME_INCREMENT
                  CALL FIELD_PARAMETER_SETS_COPY(INDEPENDENT_FIELD_ALE_NAVIER_STOKES,FIELD_U_VARIABLE_TYPE, & 
                    & FIELD_MESH_DISPLACEMENT_SET_TYPE,FIELD_MESH_VELOCITY_SET_TYPE,ALPHA,ERR,ERROR,*999)
                ELSE  
                  CALL FLAG_ERROR("Mesh motion calculation not successful for ALE problem.",ERR,ERROR,*999)
                END IF
              ELSE  
                CALL FLAG_ERROR("Mesh update is not defined for non-dynamic problems.",ERR,ERROR,*999)
              END IF
            CASE DEFAULT
              LOCAL_ERROR="Problem subtype "//TRIM(NUMBER_TO_VSTRING(CONTROL_LOOP%PROBLEM%SUBTYPE,"*",ERR,ERROR))// &
                & " is not valid for a Navier-Stokes equation fluid type of a fluid mechanics problem class."
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        ELSE
          CALL FLAG_ERROR("Problem is not associated.",ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Solver is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Control loop is not associated.",ERR,ERROR,*999)
    ENDIF
    CALL EXITS("NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_MESH")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_MESH",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_MESH")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_MESH

  !
  !================================================================================================================================
  !
  !>Update mesh parameters for three component Laplace problem
  SUBROUTINE NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_PARAMETERS(CONTROL_LOOP,SOLVER,ERR,ERROR,*)

    !Argument variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP !<A pointer to the control loop to solve.
    TYPE(SOLVER_TYPE), POINTER :: SOLVER !<A pointer to the solver
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(FIELD_TYPE), POINTER :: INDEPENDENT_FIELD
    TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: SOLVER_EQUATIONS  !<A pointer to the solver equations
    TYPE(SOLVER_MAPPING_TYPE), POINTER :: SOLVER_MAPPING !<A pointer to the solver mapping
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set
    TYPE(EQUATIONS_TYPE), POINTER :: EQUATIONS
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    REAL(DP) :: CURRENT_TIME,TIME_INCREMENT
    INTEGER(INTG) :: component_idx,deriv_idx,local_ny,node_idx,variable_idx,variable_type
    REAL(DP), POINTER :: MESH_STIFF_VALUES(:)
    TYPE(DOMAIN_TYPE), POINTER :: DOMAIN
    TYPE(DOMAIN_NODES_TYPE), POINTER :: DOMAIN_NODES
    TYPE(FIELD_VARIABLE_TYPE), POINTER :: FIELD_VARIABLE



    CALL ENTERS("NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_PARAMETERS",ERR,ERROR,*999)

    IF(ASSOCIATED(CONTROL_LOOP)) THEN
      CALL CONTROL_LOOP_CURRENT_TIMES_GET(CONTROL_LOOP,CURRENT_TIME,TIME_INCREMENT,ERR,ERROR,*999)
!       write(*,*)'CURRENT_TIME = ',CURRENT_TIME
!       write(*,*)'TIME_INCREMENT = ',TIME_INCREMENT
      IF(ASSOCIATED(SOLVER)) THEN
        IF(ASSOCIATED(CONTROL_LOOP%PROBLEM)) THEN
          SELECT CASE(CONTROL_LOOP%PROBLEM%SUBTYPE)
            CASE(PROBLEM_STATIC_NAVIER_STOKES_SUBTYPE,PROBLEM_LAPLACE_NAVIER_STOKES_SUBTYPE)
              ! do nothing ???
            CASE(PROBLEM_TRANSIENT_NAVIER_STOKES_SUBTYPE)
              ! do nothing ???
            CASE(PROBLEM_1DTRANSIENT_NAVIER_STOKES_SUBTYPE)
              ! do nothing ???
            CASE(PROBLEM_ALE_NAVIER_STOKES_SUBTYPE)
              IF(SOLVER%SOLVE_TYPE==SOLVER_LINEAR_TYPE) THEN
                !Get the independent field for the ALE Navier-Stokes problem
                SOLVER_EQUATIONS=>SOLVER%SOLVER_EQUATIONS
                IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
                  SOLVER_MAPPING=>SOLVER_EQUATIONS%SOLVER_MAPPING
                  IF(ASSOCIATED(SOLVER_MAPPING)) THEN
                    EQUATIONS_SET=>SOLVER_MAPPING%EQUATIONS_SETS(1)%PTR
                    NULLIFY(MESH_STIFF_VALUES)
                    CALL FIELD_PARAMETER_SET_DATA_GET(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, & 
                      & FIELD_VALUES_SET_TYPE,MESH_STIFF_VALUES,ERR,ERROR,*999)
                    IF(ASSOCIATED(EQUATIONS_SET)) THEN
                      EQUATIONS=>SOLVER_MAPPING%EQUATIONS_SET_TO_SOLVER_MAP(1)%EQUATIONS
                      IF(ASSOCIATED(EQUATIONS)) THEN
                        INDEPENDENT_FIELD=>EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD
                        IF(ASSOCIATED(INDEPENDENT_FIELD)) THEN
                          DO variable_idx=1,EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD%NUMBER_OF_VARIABLES
                            variable_type=EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD%VARIABLES(variable_idx)%VARIABLE_TYPE
                            FIELD_VARIABLE=>EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD%VARIABLE_TYPE_MAP(variable_type)%PTR
                            IF(ASSOCIATED(FIELD_VARIABLE)) THEN
                              DO component_idx=1,FIELD_VARIABLE%NUMBER_OF_COMPONENTS
                                DOMAIN=>FIELD_VARIABLE%COMPONENTS(component_idx)%DOMAIN
                                IF(ASSOCIATED(DOMAIN)) THEN
                                  IF(ASSOCIATED(DOMAIN%TOPOLOGY)) THEN
                                    DOMAIN_NODES=>DOMAIN%TOPOLOGY%NODES
                                    IF(ASSOCIATED(DOMAIN_NODES)) THEN
                                      !Loop over the local nodes excluding the ghosts.
                                      DO node_idx=1,DOMAIN_NODES%NUMBER_OF_NODES
                                        DO deriv_idx=1,DOMAIN_NODES%NODES(node_idx)%NUMBER_OF_DERIVATIVES
                                          !Default to version 1 of each node derivative
                                          local_ny=FIELD_VARIABLE%COMPONENTS(component_idx)%PARAM_TO_DOF_MAP% &
                                            & NODE_PARAM2DOF_MAP%NODES(node_idx)%DERIVATIVES(deriv_idx)%VERSIONS(1)
                                          !Calculation of K values dependent on current mesh topology
                                          MESH_STIFF_VALUES(local_ny)=1.0_DP
                                          CALL FIELD_PARAMETER_SET_UPDATE_LOCAL_DOF(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD, & 
                                            & FIELD_U_VARIABLE_TYPE,FIELD_VALUES_SET_TYPE,local_ny, & 
                                            & MESH_STIFF_VALUES(local_ny),ERR,ERROR,*999)
                                        ENDDO !deriv_idx
                                      ENDDO !node_idx
                                    ENDIF
                                  ENDIF
                                ENDIF
                              ENDDO !component_idx
                            ENDIF
                          ENDDO !variable_idx
                        ELSE
                          CALL FLAG_ERROR("Independent field is not associated.",ERR,ERROR,*999)
                        END IF
                      ELSE
                        CALL FLAG_ERROR("Equations are not associated.",ERR,ERROR,*999)
                      END IF
                    ELSE
                      CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
                    ENDIF
                    CALL FIELD_PARAMETER_SET_DATA_RESTORE(EQUATIONS_SET%INDEPENDENT%INDEPENDENT_FIELD,FIELD_U_VARIABLE_TYPE, & 
                      & FIELD_VALUES_SET_TYPE,MESH_STIFF_VALUES,ERR,ERROR,*999)                     
                  ELSE
                    CALL FLAG_ERROR("Solver mapping is not associated.",ERR,ERROR,*999)
                  END IF
                ELSE
                  CALL FLAG_ERROR("Solver equations are not associated.",ERR,ERROR,*999)
                END IF
              ELSE IF(SOLVER%SOLVE_TYPE==SOLVER_DYNAMIC_TYPE) THEN
                CALL FLAG_ERROR("Mesh motion calculation not successful for ALE problem.",ERR,ERROR,*999)
              END IF
            CASE DEFAULT
              LOCAL_ERROR="Problem subtype "//TRIM(NUMBER_TO_VSTRING(CONTROL_LOOP%PROBLEM%SUBTYPE,"*",ERR,ERROR))// &
                & " is not valid for a Navier-Stokes equation fluid type of a fluid mechanics problem class."
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        ELSE
          CALL FLAG_ERROR("Problem is not associated.",ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Solver is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Control loop is not associated.",ERR,ERROR,*999)
    ENDIF
    CALL EXITS("NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_PARAMETERS")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_PARAMETERS",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_PARAMETERS")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_PRE_SOLVE_ALE_UPDATE_PARAMETERS

  !
  !================================================================================================================================
  !

  !>Output data post solve
  SUBROUTINE NAVIER_STOKES_POST_SOLVE_OUTPUT_DATA(CONTROL_LOOP,SOLVER,ERR,ERROR,*)

    !Argument variables
    TYPE(CONTROL_LOOP_TYPE), POINTER :: CONTROL_LOOP !<A pointer to the control loop to solve.
    TYPE(SOLVER_TYPE), POINTER :: SOLVER !<A pointer to the solver
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    TYPE(SOLVER_EQUATIONS_TYPE), POINTER :: SOLVER_EQUATIONS  !<A pointer to the solver equations
    TYPE(SOLVER_MAPPING_TYPE), POINTER :: SOLVER_MAPPING !<A pointer to the solver mapping
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET !<A pointer to the equations set
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    REAL(DP) :: CURRENT_TIME,TIME_INCREMENT
    INTEGER(INTG) :: EQUATIONS_SET_IDX,CURRENT_LOOP_ITERATION,OUTPUT_ITERATION_NUMBER,NUMBER_OF_DIMENSIONS
    LOGICAL :: EXPORT_FIELD
    TYPE(VARYING_STRING) :: METHOD!,FILE
    CHARACTER(14) :: FILE
    CHARACTER(14) :: OUTPUT_FILE

    CALL ENTERS("NAVIER_STOKES_POST_SOLVE_OUTPUT_DATA",ERR,ERROR,*999)

    IF(ASSOCIATED(CONTROL_LOOP)) THEN
      IF(ASSOCIATED(SOLVER)) THEN
        IF(ASSOCIATED(CONTROL_LOOP%PROBLEM)) THEN
          SELECT CASE(CONTROL_LOOP%PROBLEM%SUBTYPE)
            CASE(PROBLEM_STATIC_NAVIER_STOKES_SUBTYPE,PROBLEM_LAPLACE_NAVIER_STOKES_SUBTYPE)
              SOLVER_EQUATIONS=>SOLVER%SOLVER_EQUATIONS
                IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
                  SOLVER_MAPPING=>SOLVER_EQUATIONS%SOLVER_MAPPING
                  IF(ASSOCIATED(SOLVER_MAPPING)) THEN
                    !Make sure the equations sets are up to date
                    DO equations_set_idx=1,SOLVER_MAPPING%NUMBER_OF_EQUATIONS_SETS
                      EQUATIONS_SET=>SOLVER_MAPPING%EQUATIONS_SETS(equations_set_idx)%PTR
                      METHOD="FORTRAN"
                      EXPORT_FIELD=.TRUE.
                      IF(EXPORT_FIELD) THEN          
                        CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"...",ERR,ERROR,*999)
                        CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"Now export fields... ",ERR,ERROR,*999)
                        CALL FLUID_MECHANICS_IO_WRITE_CMGUI(EQUATIONS_SET%REGION,EQUATIONS_SET%GLOBAL_NUMBER,"STATICSOLUTION", &
                          & ERR,ERROR,*999)
                        CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"STATICSOLUTION",ERR,ERROR,*999)
                        CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"...",ERR,ERROR,*999)
                      ENDIF
                    ENDDO
                  ENDIF 
                ENDIF
            CASE(PROBLEM_TRANSIENT_NAVIER_STOKES_SUBTYPE,PROBLEM_ALE_NAVIER_STOKES_SUBTYPE,PROBLEM_PGM_NAVIER_STOKES_SUBTYPE, &
              & PROBLEM_QUASISTATIC_NAVIER_STOKES_SUBTYPE,PROBLEM_1DTRANSIENT_NAVIER_STOKES_SUBTYPE)
              CALL CONTROL_LOOP_CURRENT_TIMES_GET(CONTROL_LOOP,CURRENT_TIME,TIME_INCREMENT,ERR,ERROR,*999)
              SOLVER_EQUATIONS=>SOLVER%SOLVER_EQUATIONS
              IF(ASSOCIATED(SOLVER_EQUATIONS)) THEN
                SOLVER_MAPPING=>SOLVER_EQUATIONS%SOLVER_MAPPING
                IF(ASSOCIATED(SOLVER_MAPPING)) THEN
                  !Make sure the equations sets are up to date
                  DO equations_set_idx=1,SOLVER_MAPPING%NUMBER_OF_EQUATIONS_SETS
                    EQUATIONS_SET=>SOLVER_MAPPING%EQUATIONS_SETS(equations_set_idx)%PTR
                    CURRENT_LOOP_ITERATION=CONTROL_LOOP%TIME_LOOP%ITERATION_NUMBER
                    OUTPUT_ITERATION_NUMBER=CONTROL_LOOP%TIME_LOOP%OUTPUT_NUMBER
                    IF(OUTPUT_ITERATION_NUMBER/=0) THEN
                      IF(CONTROL_LOOP%TIME_LOOP%CURRENT_TIME<=CONTROL_LOOP%TIME_LOOP%STOP_TIME) THEN
                        IF(CURRENT_LOOP_ITERATION<10) THEN
                          WRITE(OUTPUT_FILE,'("TIME_STEP_000",I0)') CURRENT_LOOP_ITERATION
                        ELSE IF(CURRENT_LOOP_ITERATION<100) THEN
                          WRITE(OUTPUT_FILE,'("TIME_STEP_00",I0)') CURRENT_LOOP_ITERATION
                        ELSE IF(CURRENT_LOOP_ITERATION<1000) THEN
                          WRITE(OUTPUT_FILE,'("TIME_STEP_0",I0)') CURRENT_LOOP_ITERATION
                        ELSE IF(CURRENT_LOOP_ITERATION<10000) THEN
                          WRITE(OUTPUT_FILE,'("TIME_STEP_",I0)') CURRENT_LOOP_ITERATION
                        END IF
                        FILE=OUTPUT_FILE
  !          FILE="TRANSIENT_OUTPUT"
                        METHOD="FORTRAN"
                        EXPORT_FIELD=.TRUE.
                        IF(EXPORT_FIELD) THEN          
                          IF(MOD(CURRENT_LOOP_ITERATION,OUTPUT_ITERATION_NUMBER)==0)  THEN   
                            CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"...",ERR,ERROR,*999)
                            CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"Now export fields... ",ERR,ERROR,*999)
                            CALL FLUID_MECHANICS_IO_WRITE_CMGUI(EQUATIONS_SET%REGION,EQUATIONS_SET%GLOBAL_NUMBER,FILE, &
                              & ERR,ERROR,*999)
                            CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,OUTPUT_FILE,ERR,ERROR,*999)
                            CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"...",ERR,ERROR,*999)
                            CALL FIELD_NUMBER_OF_COMPONENTS_GET(EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE, &
                              & NUMBER_OF_DIMENSIONS,ERR,ERROR,*999)
                            IF(NUMBER_OF_DIMENSIONS==3) THEN
!\todo: Allow user to choose whether or not ENCAS ouput is activated (default = NO)
                              EXPORT_FIELD=.FALSE.
                              IF(EXPORT_FIELD) THEN
                                CALL FLUID_MECHANICS_IO_WRITE_ENCAS(EQUATIONS_SET%REGION,EQUATIONS_SET%GLOBAL_NUMBER,FILE, &
                                  & ERR,ERROR,*999)
                                CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,OUTPUT_FILE,ERR,ERROR,*999)
                                CALL WRITE_STRING(GENERAL_OUTPUT_TYPE,"...",ERR,ERROR,*999)
                              ENDIF
                            ENDIF
                          ENDIF
                        ENDIF 
                        IF(ASSOCIATED(EQUATIONS_SET%ANALYTIC)) THEN
                          IF(EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_4.OR. &
                            & EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_5.OR. &
                            & EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_4.OR. &
                            & EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_5.OR. &
                            & EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_ONE_DIM_1.OR. &
                            & EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_1) THEN
                            CALL ANALYTIC_ANALYSIS_OUTPUT(EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD,FILE,ERR,ERROR,*999)
                          ENDIF
                        ENDIF
                      ENDIF 
                    ENDIF
                  ENDDO
                ENDIF
              ENDIF
            CASE DEFAULT
              LOCAL_ERROR="Problem subtype "//TRIM(NUMBER_TO_VSTRING(CONTROL_LOOP%PROBLEM%SUBTYPE,"*",ERR,ERROR))// &
                & " is not valid for a Navier-Stokes equation fluid type of a fluid mechanics problem class."
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          END SELECT
        ELSE
          CALL FLAG_ERROR("Problem is not associated.",ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Solver is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Control loop is not associated.",ERR,ERROR,*999)
    ENDIF
    CALL EXITS("NAVIER_STOKES_POST_SOLVE_OUTPUT_DATA")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_POST_SOLVE_OUTPUT_DATA",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_POST_SOLVE_OUTPUT_DATA")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_POST_SOLVE_OUTPUT_DATA

  !
  !================================================================================================================================
  !

  !>Calculates the analytic solution and sets the boundary conditions for an analytic problem.
  SUBROUTINE NAVIER_STOKES_EQUATION_ANALYTIC_CALCULATE(EQUATIONS_SET,BOUNDARY_CONDITIONS,ERR,ERROR,*)

    !Argument variables
    TYPE(EQUATIONS_SET_TYPE), POINTER :: EQUATIONS_SET
    TYPE(BOUNDARY_CONDITIONS_TYPE), POINTER :: BOUNDARY_CONDITIONS
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    !Local Variables
    INTEGER(INTG) :: component_idx,deriv_idx,dim_idx,local_ny,node_idx,NUMBER_OF_DIMENSIONS,variable_idx,variable_type,I,J,K
    INTEGER(INTG) :: number_of_nodes_xic(3),element_idx,en_idx,BOUND_COUNT,ANALYTIC_FUNCTION_TYPE,GLOBAL_DERIV_INDEX
    REAL(DP) :: VALUE,X(3),XI_COORDINATES(3)
!     REAL(DP) :: BOUNDARY_TOLERANCE, BOUNDARY_X(3,2),MU_PARAM,L
    REAL(DP) :: T_COORDINATES(20,3),CURRENT_TIME,MU_PARAM,RHO_PARAM
    REAL(DP), POINTER :: GEOMETRIC_PARAMETERS(:)
    TYPE(DOMAIN_TYPE), POINTER :: DOMAIN
    TYPE(DOMAIN_NODES_TYPE), POINTER :: DOMAIN_NODES
    TYPE(FIELD_TYPE), POINTER :: DEPENDENT_FIELD,GEOMETRIC_FIELD,MATERIALS_FIELD
    TYPE(FIELD_VARIABLE_TYPE), POINTER :: FIELD_VARIABLE,GEOMETRIC_VARIABLE
    TYPE(FIELD_INTERPOLATED_POINT_PTR_TYPE), POINTER :: INTERPOLATED_POINT(:)
    TYPE(FIELD_INTERPOLATION_PARAMETERS_PTR_TYPE), POINTER :: INTERPOLATION_PARAMETERS(:)
!     TYPE(VARYING_STRING) :: LOCAL_ERROR    

! ! !     !Temp variables
! ! !     INTEGER(INTG) :: number_of_element_nodes,temp_local_ny,temp_node_number,velocity_DOF_check,temp_local_node_number    

    CALL ENTERS("NAVIER_STOKES_EQUATION_ANALYTIC_CALCULATE",ERR,ERROR,*999)
!\todo: Introduce user call to set parameters
    BOUND_COUNT=0
! ! ! !     L=10.0_DP
    XI_COORDINATES(3)=0.0_DP
!     BOUNDARY_TOLERANCE=0.000000001_DP
! ! !     BOUNDARY_X=0.0_DP
! ! !     T_COORDINATES=0.0_DP
! ! !     number_of_element_nodes=0
! ! !     temp_local_node_number=0
! ! !     temp_local_ny=0
! ! !     temp_node_number=0
! ! !     velocity_DOF_check=0
    IF(ASSOCIATED(EQUATIONS_SET)) THEN
      IF(ASSOCIATED(EQUATIONS_SET%ANALYTIC)) THEN
        DEPENDENT_FIELD=>EQUATIONS_SET%DEPENDENT%DEPENDENT_FIELD
        IF(ASSOCIATED(DEPENDENT_FIELD)) THEN
          GEOMETRIC_FIELD=>EQUATIONS_SET%GEOMETRY%GEOMETRIC_FIELD
          IF(ASSOCIATED(GEOMETRIC_FIELD)) THEN     
            NULLIFY(INTERPOLATION_PARAMETERS)
            NULLIFY(INTERPOLATED_POINT) 
            CALL FIELD_INTERPOLATION_PARAMETERS_INITIALISE(GEOMETRIC_FIELD,INTERPOLATION_PARAMETERS,ERR,ERROR,*999)
            CALL FIELD_INTERPOLATED_POINTS_INITIALISE(INTERPOLATION_PARAMETERS,INTERPOLATED_POINT,ERR,ERROR,*999)
            CALL FIELD_NUMBER_OF_COMPONENTS_GET(GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE,NUMBER_OF_DIMENSIONS,ERR,ERROR,*999)
!\todo: Check if adjacent element calculation works for simplex elements now and then switch to boundary flag instead
! ! !             IF(NUMBER_OF_DIMENSIONS==2) THEN
! ! !               BOUNDARY_X(1,1)=0.0_DP
! ! !               BOUNDARY_X(1,2)=10.0_DP
! ! !               BOUNDARY_X(2,1)=0.0_DP
! ! !               BOUNDARY_X(2,2)=10.0_DP
! ! !               IF(EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_4.OR. &
! ! !                 & EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_5) THEN
! ! !                 BOUNDARY_X(1,1)=0.0_DP/L*PI
! ! !                 BOUNDARY_X(1,2)=L/L*PI
! ! !                 BOUNDARY_X(2,1)=0.0_DP/L*PI
! ! !                 BOUNDARY_X(2,2)=L/L*PI
! ! !               ENDIF
! ! !             ELSE IF(NUMBER_OF_DIMENSIONS==3) THEN
! ! !               BOUNDARY_X(1,1)=-5.0_DP
! ! !               BOUNDARY_X(1,2)=5.0_DP
! ! !               BOUNDARY_X(2,1)=-5.0_DP
! ! !               BOUNDARY_X(2,2)=5.0_DP
! ! !               BOUNDARY_X(3,1)=-5.0_DP
! ! !               BOUNDARY_X(3,2)=5.0_DP
! ! !             ENDIF
            NULLIFY(GEOMETRIC_VARIABLE)
            CALL FIELD_VARIABLE_GET(GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE,GEOMETRIC_VARIABLE,ERR,ERROR,*999)
            NULLIFY(GEOMETRIC_PARAMETERS)
            CALL FIELD_PARAMETER_SET_DATA_GET(GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE,FIELD_VALUES_SET_TYPE,GEOMETRIC_PARAMETERS, &
              & ERR,ERROR,*999)
            IF(ASSOCIATED(BOUNDARY_CONDITIONS)) THEN
              DO variable_idx=1,DEPENDENT_FIELD%NUMBER_OF_VARIABLES
                variable_type=DEPENDENT_FIELD%VARIABLES(variable_idx)%VARIABLE_TYPE
                FIELD_VARIABLE=>DEPENDENT_FIELD%VARIABLE_TYPE_MAP(variable_type)%PTR
                IF(ASSOCIATED(FIELD_VARIABLE)) THEN
                  CALL FIELD_PARAMETER_SET_CREATE(DEPENDENT_FIELD,variable_type,FIELD_ANALYTIC_VALUES_SET_TYPE,ERR,ERROR,*999)
                  DO component_idx=1,FIELD_VARIABLE%NUMBER_OF_COMPONENTS
                    BOUND_COUNT=0
                    IF(FIELD_VARIABLE%COMPONENTS(component_idx)%INTERPOLATION_TYPE==FIELD_NODE_BASED_INTERPOLATION) THEN
                      DOMAIN=>FIELD_VARIABLE%COMPONENTS(component_idx)%DOMAIN
                      IF(ASSOCIATED(DOMAIN)) THEN
                        IF(ASSOCIATED(DOMAIN%TOPOLOGY)) THEN
                          DOMAIN_NODES=>DOMAIN%TOPOLOGY%NODES
                          IF(ASSOCIATED(DOMAIN_NODES)) THEN
                            !Loop over the local nodes excluding the ghosts.
                            DO node_idx=1,DOMAIN_NODES%NUMBER_OF_NODES
                              element_idx=DOMAIN%topology%nodes%nodes(node_idx)%surrounding_elements(1)
                              CALL FIELD_INTERPOLATION_PARAMETERS_ELEMENT_GET(FIELD_VALUES_SET_TYPE,element_idx, &
                                & INTERPOLATION_PARAMETERS(FIELD_U_VARIABLE_TYPE)%PTR,ERR,ERROR,*999)
                              en_idx=0
                              XI_COORDINATES=0.0_DP
                              number_of_nodes_xic(1)=DOMAIN%topology%elements%elements(element_idx)%basis%number_of_nodes_xic(1)
                              number_of_nodes_xic(2)=DOMAIN%topology%elements%elements(element_idx)%basis%number_of_nodes_xic(2)
                              IF(NUMBER_OF_DIMENSIONS==3) THEN
                                number_of_nodes_xic(3)=DOMAIN%topology%elements%elements(element_idx)%basis%number_of_nodes_xic(3)
                              ELSE
                                number_of_nodes_xic(3)=1
                              ENDIF
!\todo: Use boundary flag
                              IF(DOMAIN%topology%elements%maximum_number_of_element_parameters==4.AND.NUMBER_OF_DIMENSIONS==2 .OR. &
                                & DOMAIN%topology%elements%maximum_number_of_element_parameters==9.OR. &
                                & DOMAIN%topology%elements%maximum_number_of_element_parameters==16.OR. &
                                & DOMAIN%topology%elements%maximum_number_of_element_parameters==8.OR. &
                                & DOMAIN%topology%elements%maximum_number_of_element_parameters==27.OR. &
                                & DOMAIN%topology%elements%maximum_number_of_element_parameters==64) THEN
                                DO K=1,number_of_nodes_xic(3)
                                  DO J=1,number_of_nodes_xic(2)
                                    DO I=1,number_of_nodes_xic(1)
                                      en_idx=en_idx+1
                                      IF(DOMAIN%topology%elements%elements(element_idx)%element_nodes(en_idx)==node_idx) EXIT
                                      XI_COORDINATES(1)=XI_COORDINATES(1)+(1.0_DP/(number_of_nodes_xic(1)-1))
                                    ENDDO
                                      IF(DOMAIN%topology%elements%elements(element_idx)%element_nodes(en_idx)==node_idx) EXIT
                                      XI_COORDINATES(1)=0.0_DP
                                      XI_COORDINATES(2)=XI_COORDINATES(2)+(1.0_DP/(number_of_nodes_xic(2)-1))
                                  ENDDO
                                  IF(DOMAIN%topology%elements%elements(element_idx)%element_nodes(en_idx)==node_idx) EXIT
                                  XI_COORDINATES(1)=0.0_DP
                                  XI_COORDINATES(2)=0.0_DP
                                  IF(number_of_nodes_xic(3)/=1) THEN
                                    XI_COORDINATES(3)=XI_COORDINATES(3)+(1.0_DP/(number_of_nodes_xic(3)-1))
                                  ENDIF
                                ENDDO
                                CALL FIELD_INTERPOLATE_XI(NO_PART_DERIV,XI_COORDINATES, &
                                  & INTERPOLATED_POINT(FIELD_U_VARIABLE_TYPE)%PTR,ERR,ERROR,*999)
                              ELSE
!\todo: Use boundary flag
                                IF(DOMAIN%topology%elements%maximum_number_of_element_parameters==3) THEN
                                  T_COORDINATES(1,1:2)=(/0.0_DP,1.0_DP/)
                                  T_COORDINATES(2,1:2)=(/1.0_DP,0.0_DP/)
                                  T_COORDINATES(3,1:2)=(/1.0_DP,1.0_DP/)
                                ELSE IF(DOMAIN%topology%elements%maximum_number_of_element_parameters==6) THEN
                                  T_COORDINATES(1,1:2)=(/0.0_DP,1.0_DP/)
                                  T_COORDINATES(2,1:2)=(/1.0_DP,0.0_DP/)
                                  T_COORDINATES(3,1:2)=(/1.0_DP,1.0_DP/)
                                  T_COORDINATES(4,1:2)=(/0.5_DP,0.5_DP/)
                                  T_COORDINATES(5,1:2)=(/1.0_DP,0.5_DP/)
                                  T_COORDINATES(6,1:2)=(/0.5_DP,1.0_DP/)
                                ELSE IF(DOMAIN%topology%elements%maximum_number_of_element_parameters==10.AND. &
                                  & NUMBER_OF_DIMENSIONS==2) THEN
                                  T_COORDINATES(1,1:2)=(/0.0_DP,1.0_DP/)
                                  T_COORDINATES(2,1:2)=(/1.0_DP,0.0_DP/)
                                  T_COORDINATES(3,1:2)=(/1.0_DP,1.0_DP/)
                                  T_COORDINATES(4,1:2)=(/1.0_DP/3.0_DP,2.0_DP/3.0_DP/)
                                  T_COORDINATES(5,1:2)=(/2.0_DP/3.0_DP,1.0_DP/3.0_DP/)
                                  T_COORDINATES(6,1:2)=(/1.0_DP,1.0_DP/3.0_DP/)
                                  T_COORDINATES(7,1:2)=(/1.0_DP,2.0_DP/3.0_DP/)
                                  T_COORDINATES(8,1:2)=(/2.0_DP/3.0_DP,1.0_DP/)
                                  T_COORDINATES(9,1:2)=(/1.0_DP/3.0_DP,1.0_DP/)
                                  T_COORDINATES(10,1:2)=(/2.0_DP/3.0_DP,2.0_DP/3.0_DP/)
                                ELSE IF(DOMAIN%topology%elements%maximum_number_of_element_parameters==4) THEN
                                  T_COORDINATES(1,1:3)=(/0.0_DP,1.0_DP,1.0_DP/)
                                  T_COORDINATES(2,1:3)=(/1.0_DP,0.0_DP,1.0_DP/)
                                  T_COORDINATES(3,1:3)=(/1.0_DP,1.0_DP,0.0_DP/)
                                  T_COORDINATES(4,1:3)=(/1.0_DP,1.0_DP,1.0_DP/)
                                ELSE IF(DOMAIN%topology%elements%maximum_number_of_element_parameters==10.AND. &
                                  & NUMBER_OF_DIMENSIONS==3) THEN
                                  T_COORDINATES(1,1:3)=(/0.0_DP,1.0_DP,1.0_DP/)
                                  T_COORDINATES(2,1:3)=(/1.0_DP,0.0_DP,1.0_DP/)
                                  T_COORDINATES(3,1:3)=(/1.0_DP,1.0_DP,0.0_DP/)
                                  T_COORDINATES(4,1:3)=(/1.0_DP,1.0_DP,1.0_DP/)
                                  T_COORDINATES(5,1:3)=(/0.5_DP,0.5_DP,1.0_DP/)
                                  T_COORDINATES(6,1:3)=(/0.5_DP,1.0_DP,0.5_DP/)
                                  T_COORDINATES(7,1:3)=(/0.5_DP,1.0_DP,1.0_DP/)
                                  T_COORDINATES(8,1:3)=(/1.0_DP,0.5_DP,0.5_DP/)
                                  T_COORDINATES(9,1:3)=(/1.0_DP,1.0_DP,0.5_DP/)
                                  T_COORDINATES(10,1:3)=(/1.0_DP,0.5_DP,1.0_DP/)
                                ELSE IF(DOMAIN%topology%elements%maximum_number_of_element_parameters==20) THEN
                                  T_COORDINATES(1,1:3)=(/0.0_DP,1.0_DP,1.0_DP/)
                                  T_COORDINATES(2,1:3)=(/1.0_DP,0.0_DP,1.0_DP/)
                                  T_COORDINATES(3,1:3)=(/1.0_DP,1.0_DP,0.0_DP/)
                                  T_COORDINATES(4,1:3)=(/1.0_DP,1.0_DP,1.0_DP/)
                                  T_COORDINATES(5,1:3)=(/1.0_DP/3.0_DP,2.0_DP/3.0_DP,1.0_DP/)
                                  T_COORDINATES(6,1:3)=(/2.0_DP/3.0_DP,1.0_DP/3.0_DP,1.0_DP/)
                                  T_COORDINATES(7,1:3)=(/1.0_DP/3.0_DP,1.0_DP,2.0_DP/3.0_DP/)
                                  T_COORDINATES(8,1:3)=(/2.0_DP/3.0_DP,1.0_DP,1.0_DP/3.0_DP/)
                                  T_COORDINATES(9,1:3)=(/1.0_DP/3.0_DP,1.0_DP,1.0_DP/)
                                  T_COORDINATES(10,1:3)=(/2.0_DP/3.0_DP,1.0_DP,1.0_DP/)
                                  T_COORDINATES(11,1:3)=(/1.0_DP,1.0_DP/3.0_DP,2.0_DP/3.0_DP/)
                                  T_COORDINATES(12,1:3)=(/1.0_DP,2.0_DP/3.0_DP,1.0_DP/3.0_DP/)
                                  T_COORDINATES(13,1:3)=(/1.0_DP,1.0_DP,1.0_DP/3.0_DP/)
                                  T_COORDINATES(14,1:3)=(/1.0_DP,1.0_DP,2.0_DP/3.0_DP/)
                                  T_COORDINATES(15,1:3)=(/1.0_DP,1.0_DP/3.0_DP,1.0_DP/)
                                  T_COORDINATES(16,1:3)=(/1.0_DP,2.0_DP/3.0_DP,1.0_DP/)
                                  T_COORDINATES(17,1:3)=(/2.0_DP/3.0_DP,2.0_DP/3.0_DP,2.0_DP/3.0_DP/)
                                  T_COORDINATES(18,1:3)=(/2.0_DP/3.0_DP,2.0_DP/3.0_DP,1.0_DP/)
                                  T_COORDINATES(19,1:3)=(/2.0_DP/3.0_DP,1.0_DP,2.0_DP/3.0_DP/)
                                  T_COORDINATES(20,1:3)=(/1.0_DP,2.0_DP/3.0_DP,2.0_DP/3.0_DP/)
                                ENDIF
                                DO K=1,DOMAIN%topology%elements%maximum_number_of_element_parameters
                                  IF(DOMAIN%topology%elements%elements(element_idx)%element_nodes(K)==node_idx) EXIT
                                ENDDO
                                IF(NUMBER_OF_DIMENSIONS==2) THEN
                                  CALL FIELD_INTERPOLATE_XI(NO_PART_DERIV,T_COORDINATES(K,1:2), &
                                    & INTERPOLATED_POINT(FIELD_U_VARIABLE_TYPE)%PTR,ERR,ERROR,*999)
                                ELSE IF(NUMBER_OF_DIMENSIONS==3) THEN
                                  CALL FIELD_INTERPOLATE_XI(NO_PART_DERIV,T_COORDINATES(K,1:3), &
                                    & INTERPOLATED_POINT(FIELD_U_VARIABLE_TYPE)%PTR,ERR,ERROR,*999)
                                ENDIF
                              ENDIF
                              X=0.0_DP
                              DO dim_idx=1,NUMBER_OF_DIMENSIONS
                                X(dim_idx)=INTERPOLATED_POINT(FIELD_U_VARIABLE_TYPE)%PTR%VALUES(dim_idx,1)
                              ENDDO !dim_idx

                              !Loop over the derivatives
                              DO deriv_idx=1,DOMAIN_NODES%NODES(node_idx)%NUMBER_OF_DERIVATIVES
                                ANALYTIC_FUNCTION_TYPE=EQUATIONS_SET%ANALYTIC%ANALYTIC_FUNCTION_TYPE
                                GLOBAL_DERIV_INDEX=DOMAIN_NODES%NODES(node_idx)%DERIVATIVES(deriv_idx)% &
                                  & GLOBAL_DERIVATIVE_INDEX
                                CURRENT_TIME=0.0_DP
                                MATERIALS_FIELD=>EQUATIONS_SET%MATERIALS%MATERIALS_FIELD
                                !Define MU_PARAM, density=1
                                MU_PARAM=MATERIALS_FIELD%variables(1)%parameter_sets%parameter_sets(1)%ptr% &
                                  & parameters%cmiss%data_dp(1)
                                !Define RHO_PARAM, density=2
                                RHO_PARAM=MATERIALS_FIELD%variables(1)%parameter_sets%parameter_sets(1)%ptr% &
                                  & parameters%cmiss%data_dp(2)
                                CALL NAVIER_STOKES_EQUATION_ANALYTIC_FUNCTIONS(VALUE,X,MU_PARAM,RHO_PARAM,CURRENT_TIME, &
                                  & variable_type,GLOBAL_DERIV_INDEX,ANALYTIC_FUNCTION_TYPE,NUMBER_OF_DIMENSIONS, &
                                  & FIELD_VARIABLE%NUMBER_OF_COMPONENTS,component_idx,ERR,ERROR,*999)
                                !Default to version 1 of each node derivative
                                local_ny=FIELD_VARIABLE%COMPONENTS(component_idx)%PARAM_TO_DOF_MAP% &
                                  & NODE_PARAM2DOF_MAP%NODES(node_idx)%DERIVATIVES(deriv_idx)%VERSIONS(1)
                                CALL FIELD_PARAMETER_SET_UPDATE_LOCAL_DOF(DEPENDENT_FIELD,variable_type, &
                                  & FIELD_ANALYTIC_VALUES_SET_TYPE,local_ny,VALUE,ERR,ERROR,*999)
                                IF(variable_type==FIELD_U_VARIABLE_TYPE) THEN
! \todo: This part should work even for simplex elements as soon as adjacent element calculation has been fixed
                                  IF(DOMAIN_NODES%NODES(node_idx)%BOUNDARY_NODE) THEN
                                    !If we are a boundary node then set the analytic value on the boundary
                                    IF(component_idx<=NUMBER_OF_DIMENSIONS) THEN
                                      CALL BOUNDARY_CONDITIONS_SET_LOCAL_DOF(BOUNDARY_CONDITIONS,DEPENDENT_FIELD,variable_type, &
                                        & local_ny,BOUNDARY_CONDITION_FIXED,VALUE,ERR,ERROR,*999)
                                      BOUND_COUNT=BOUND_COUNT+1
                                    ELSE
! \todo: This is just a workaround for linear pressure fields in simplex element components
                                      IF(DOMAIN%topology%elements%maximum_number_of_element_parameters==3) THEN
                                        IF(ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_STOKES_EQUATION_TWO_DIM_1.OR. &
                                          & ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_STOKES_EQUATION_TWO_DIM_2.OR. &
                                          & ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_STOKES_EQUATION_TWO_DIM_3.OR. &
                                          & ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_STOKES_EQUATION_TWO_DIM_4.OR. &
                                          & ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_STOKES_EQUATION_TWO_DIM_5) THEN
                                          IF(-0.001_DP<X(1).AND.X(1)<0.001_DP.AND.-0.001_DP<X(2).AND.X(2)<0.001_DP.OR. &
                                            &  10.0_DP-0.001_DP<X(1).AND.X(1)<10.0_DP+0.001_DP.AND.-0.001_DP<X(2).AND. &
                                            & X(2)<0.001_DP.OR. &
                                            &  10.0_DP-0.001_DP<X(1).AND.X(1)<10.0_DP+0.001_DP.AND.10.0_DP-0.001_DP<X(2).AND. &
                                            & X(2)<10.0_DP+0.001_DP.OR. &
                                            &  -0.001_DP<X(1).AND.X(1)<0.001_DP.AND.10.0_DP-0.001_DP<X(2).AND. &
                                            & X(2)<10.0_DP+0.001_DP) THEN
                                              CALL BOUNDARY_CONDITIONS_SET_LOCAL_DOF(BOUNDARY_CONDITIONS,DEPENDENT_FIELD, &
                                                & variable_type,local_ny,BOUNDARY_CONDITION_FIXED,VALUE,ERR,ERROR,*999)
                                              BOUND_COUNT=BOUND_COUNT+1
                                          ENDIF
                                        ENDIF
                                      ELSE IF(DOMAIN%topology%elements%maximum_number_of_element_parameters==4.AND. &
                                        & NUMBER_OF_DIMENSIONS==3) THEN
                                        IF(ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_STOKES_EQUATION_THREE_DIM_1.OR. &
                                          & ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_STOKES_EQUATION_THREE_DIM_2.OR. &
                                          & ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_STOKES_EQUATION_THREE_DIM_3.OR. &
                                          & ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_STOKES_EQUATION_THREE_DIM_4.OR. &
                                          & ANALYTIC_FUNCTION_TYPE==EQUATIONS_SET_STOKES_EQUATION_THREE_DIM_5) THEN
                                          IF(-5.0_DP-0.001_DP<X(1).AND.X(1)<-5.0_DP+0.001_DP.AND.-5.0_DP-0.001_DP<X(2).AND. &
                                            & X(2)<-5.0_DP+0.001_DP.AND.-5.0_DP-0.001_DP<X(3).AND.X(3)<-5.0_DP+0.001_DP.OR. &
                                            & -5.0_DP-0.001_DP<X(1).AND.X(1)<-5.0_DP+0.001_DP.AND.5.0_DP-0.001_DP<X(2).AND. &
                                            & X(2)<5.0_DP+0.001_DP.AND.-5.0_DP-0.001_DP<X(3).AND.X(3)<-5.0_DP+0.001_DP.OR. &
                                            & 5.0_DP-0.001_DP<X(1).AND.X(1)<5.0_DP+0.001_DP.AND.5.0_DP-0.001_DP<X(2).AND. &
                                            & X(2)<5.0_DP+0.001_DP.AND.-5.0_DP-0.001_DP<X(3).AND.X(3)<-5.0_DP+0.001_DP.OR. &
                                            & 5.0_DP-0.001_DP<X(1).AND.X(1)<5.0_DP+0.001_DP.AND.-5.0_DP-0.001_DP<X(2).AND. &
                                            & X(2)<-5.0_DP+0.001_DP.AND.-5.0_DP-0.001_DP<X(3).AND.X(3)<-5.0_DP+0.001_DP.OR. &
                                            & -5.0_DP-0.001_DP<X(1).AND.X(1)<-5.0_DP+0.001_DP.AND.-5.0_DP-0.001_DP<X(2).AND. &
                                            & X(2)<-5.0_DP+0.001_DP.AND.5.0_DP-0.001_DP<X(3).AND.X(3)<5.0_DP+0.001_DP.OR. &
                                            & -5.0_DP-0.001_DP<X(1).AND.X(1)<-5.0_DP+0.001_DP.AND.5.0_DP-0.001_DP<X(2).AND. &
                                            & X(2)<5.0_DP+0.001_DP.AND.5.0_DP-0.001_DP<X(3).AND.X(3)<5.0_DP+0.001_DP.OR. &
                                            & 5.0_DP-0.001_DP<X(1).AND.X(1)<5.0_DP+0.001_DP.AND.5.0_DP-0.001_DP<X(2).AND. &
                                            & X(2)<5.0_DP+0.001_DP.AND.5.0_DP-0.001_DP<X(3).AND.X(3)<5.0_DP+0.001_DP.OR. &
                                            & 5.0_DP-0.001_DP<X(1).AND.X(1)<5.0_DP+0.001_DP.AND.-5.0_DP-0.001_DP<X(2).AND. &
                                            & X(2)<-5.0_DP+ 0.001_DP.AND.5.0_DP-0.001_DP<X(3).AND.X(3)<5.0_DP+0.001_DP) THEN
                                            CALL BOUNDARY_CONDITIONS_SET_LOCAL_DOF(BOUNDARY_CONDITIONS,DEPENDENT_FIELD, &
                                              & variable_type,local_ny,BOUNDARY_CONDITION_FIXED,VALUE,ERR,ERROR,*999)
                                            BOUND_COUNT=BOUND_COUNT+1
                                          ENDIF
                                        ENDIF
! \todo: This is how it should be if adjacent elements would be working
                                      ELSE IF(BOUND_COUNT==0) THEN
                                        CALL BOUNDARY_CONDITIONS_SET_LOCAL_DOF(BOUNDARY_CONDITIONS,DEPENDENT_FIELD,variable_type, &
                                          & local_ny,BOUNDARY_CONDITION_FIXED,VALUE,ERR,ERROR,*999)
                                        BOUND_COUNT=BOUND_COUNT+1
                                      ENDIF
                                    ENDIF
                                  ELSE
                                    IF(component_idx<=NUMBER_OF_DIMENSIONS) THEN
                                      CALL FIELD_PARAMETER_SET_UPDATE_LOCAL_DOF(DEPENDENT_FIELD,variable_type, &
                                        & FIELD_VALUES_SET_TYPE,local_ny,VALUE,ERR,ERROR,*999)
                                    ENDIF
                                  ENDIF
! \todo: Use boundary node flag
! ! !                                 !If we are a boundary node then set the analytic value on the boundary
! ! !                                 IF(NUMBER_OF_DIMENSIONS==2) THEN
! ! !                                   IF(X(1)<BOUNDARY_X(1,1)+BOUNDARY_TOLERANCE.AND.X(1)>BOUNDARY_X(1,1)-BOUNDARY_TOLERANCE.OR. &
! ! !                                     & X(1)<BOUNDARY_X(1,2)+BOUNDARY_TOLERANCE.AND.X(1)>BOUNDARY_X(1,2)-BOUNDARY_TOLERANCE.OR. &
! ! !                                     & X(2)<BOUNDARY_X(2,1)+BOUNDARY_TOLERANCE.AND.X(2)>BOUNDARY_X(2,1)-BOUNDARY_TOLERANCE.OR. &
! ! !                                     & X(2)<BOUNDARY_X(2,2)+BOUNDARY_TOLERANCE.AND.X(2)>BOUNDARY_X(2,2)-BOUNDARY_TOLERANCE) THEN
! ! !                                     IF(component_idx<=NUMBER_OF_DIMENSIONS) THEN
! ! !                                       CALL BOUNDARY_CONDITIONS_SET_LOCAL_DOF(BOUNDARY_CONDITIONS,variable_type,local_ny, &
! ! !                                         & BOUNDARY_CONDITION_FIXED,VALUE,ERR,ERROR,*999)
! ! !                                     BOUND_COUNT=BOUND_COUNT+1
! ! !                                     !Apply boundary conditions check for pressure nodes
! ! !                                     ELSE IF(component_idx>NUMBER_OF_DIMENSIONS) THEN
! ! !                                       IF(DOMAIN%topology%elements%maximum_number_of_element_parameters==4) THEN
! ! !                                       IF(X(1)<BOUNDARY_X(1,1)+BOUNDARY_TOLERANCE.AND.X(1)>BOUNDARY_X(1,1)-BOUNDARY_TOLERANCE.AND. &
! ! !                                         & X(2)<BOUNDARY_X(2,1)+BOUNDARY_TOLERANCE.AND.X(2)>BOUNDARY_X(2,1)-BOUNDARY_TOLERANCE) &
! ! !                                         & THEN
! ! !                                            ! Commented out for testing purposes
! ! !                                           CALL BOUNDARY_CONDITIONS_SET_LOCAL_DOF(BOUNDARY_CONDITIONS,variable_type,local_ny, &
! ! !                                             & BOUNDARY_CONDITION_FIXED,VALUE,ERR,ERROR,*999)
! ! !                                           BOUND_COUNT=BOUND_COUNT+1
! ! !                                       ENDIF
! ! !                                       ENDIF
! ! ! !\todo: Again, ...
! ! !                                       IF(DOMAIN%topology%elements%maximum_number_of_element_parameters==3.OR. &
! ! !                                         & DOMAIN%topology%elements%maximum_number_of_element_parameters==6.OR. &
! ! !                                         & DOMAIN%topology%elements%maximum_number_of_element_parameters==10) THEN
! ! !                                       IF(X(1)<BOUNDARY_X(1,1)+BOUNDARY_TOLERANCE.AND.X(1)>BOUNDARY_X(1,1)-BOUNDARY_TOLERANCE.AND. &
! ! !                                         & X(2)<BOUNDARY_X(2,1)+BOUNDARY_TOLERANCE.AND.X(2)>BOUNDARY_X(2,1)-BOUNDARY_TOLERANCE.OR. &
! ! !                                         & X(1)<BOUNDARY_X(1,1)+BOUNDARY_TOLERANCE.AND.X(1)>BOUNDARY_X(1,1)-BOUNDARY_TOLERANCE.AND.&
! ! !                                         & X(2)<BOUNDARY_X(2,2)+BOUNDARY_TOLERANCE.AND.X(2)>BOUNDARY_X(2,2)-BOUNDARY_TOLERANCE.OR. &
! ! !                                         & X(1)<BOUNDARY_X(1,2)+BOUNDARY_TOLERANCE.AND.X(1)>BOUNDARY_X(1,2)-BOUNDARY_TOLERANCE.AND.&
! ! !                                         & X(2)<BOUNDARY_X(2,1)+BOUNDARY_TOLERANCE.AND.X(2)>BOUNDARY_X(2,1)-BOUNDARY_TOLERANCE.OR. &
! ! !                                         & X(1)<BOUNDARY_X(1,2)+BOUNDARY_TOLERANCE.AND.X(1)>BOUNDARY_X(1,2)-BOUNDARY_TOLERANCE.AND.&
! ! !                                         & X(2)<BOUNDARY_X(2,2)+BOUNDARY_TOLERANCE.AND.X(2)>BOUNDARY_X(2,2)-BOUNDARY_TOLERANCE) &
! ! !                                         & THEN
! ! !                                           CALL BOUNDARY_CONDITIONS_SET_LOCAL_DOF(BOUNDARY_CONDITIONS,variable_type,local_ny, &
! ! !                                             & BOUNDARY_CONDITION_FIXED,VALUE,ERR,ERROR,*999)
! ! !                                           BOUND_COUNT=BOUND_COUNT+1
! ! !                                       ENDIF
! ! !                                       ENDIF
! ! !                                     ENDIF
! ! !                                   ENDIF
! ! !                                     IF(component_idx<=NUMBER_OF_DIMENSIONS+1) THEN
! ! !                                       CALL FIELD_PARAMETER_SET_UPDATE_LOCAL_DOF(DEPENDENT_FIELD,variable_type, &
! ! !                                         & FIELD_VALUES_SET_TYPE,local_ny,VALUE,ERR,ERROR,*999)
! ! !                                     ENDIF
! ! !                                 ELSE IF(NUMBER_OF_DIMENSIONS==3) THEN
! ! !                                   IF(X(1)<BOUNDARY_X(1,1)+BOUNDARY_TOLERANCE.AND.X(1)>BOUNDARY_X(1,1)-BOUNDARY_TOLERANCE.OR. &
! ! !                                     & X(1)<BOUNDARY_X(1,2)+BOUNDARY_TOLERANCE.AND.X(1)>BOUNDARY_X(1,2)-BOUNDARY_TOLERANCE.OR. &
! ! !                                     & X(2)<BOUNDARY_X(2,1)+BOUNDARY_TOLERANCE.AND.X(2)>BOUNDARY_X(2,1)-BOUNDARY_TOLERANCE.OR. &
! ! !                                     & X(2)<BOUNDARY_X(2,2)+BOUNDARY_TOLERANCE.AND.X(2)>BOUNDARY_X(2,2)-BOUNDARY_TOLERANCE.OR. &
! ! !                                     & X(3)<BOUNDARY_X(3,1)+BOUNDARY_TOLERANCE.AND.X(3)>BOUNDARY_X(3,1)-BOUNDARY_TOLERANCE.OR. &
! ! !                                     & X(3)<BOUNDARY_X(3,2)+BOUNDARY_TOLERANCE.AND.X(3)>BOUNDARY_X(3,2)-BOUNDARY_TOLERANCE) THEN
! ! !                                     IF(component_idx<=NUMBER_OF_DIMENSIONS) THEN
! ! !                                       CALL BOUNDARY_CONDITIONS_SET_LOCAL_DOF(BOUNDARY_CONDITIONS,variable_type,local_ny, &
! ! !                                         & BOUNDARY_CONDITION_FIXED,VALUE,ERR,ERROR,*999)
! ! !                                     BOUND_COUNT=BOUND_COUNT+1
! ! !                                     !Apply boundary conditions check for pressure nodes
! ! !                                     ELSE IF(component_idx>NUMBER_OF_DIMENSIONS) THEN
! ! !                                       IF(DOMAIN%topology%elements%maximum_number_of_element_parameters==4.OR. &
! ! !                                         & DOMAIN%topology%elements%maximum_number_of_element_parameters==10.OR. &
! ! !                                         & DOMAIN%topology%elements%maximum_number_of_element_parameters==20) THEN
! ! !                                       IF(X(1)<BOUNDARY_X(1,1)+BOUNDARY_TOLERANCE.AND.X(1)>BOUNDARY_X(1,1)-BOUNDARY_TOLERANCE.AND. &
! ! !                                        & X(2)<BOUNDARY_X(2,1)+BOUNDARY_TOLERANCE.AND.X(2)>BOUNDARY_X(2,1)-BOUNDARY_TOLERANCE.AND. &
! ! !                                        & X(3)<BOUNDARY_X(3,1)+BOUNDARY_TOLERANCE.AND.X(3)>BOUNDARY_X(3,1)-BOUNDARY_TOLERANCE.OR. &
! ! !                                        & X(1)<BOUNDARY_X(1,1)+BOUNDARY_TOLERANCE.AND.X(1)>BOUNDARY_X(1,1)-BOUNDARY_TOLERANCE.AND. &
! ! !                                        & X(2)<BOUNDARY_X(2,1)+BOUNDARY_TOLERANCE.AND.X(2)>BOUNDARY_X(2,1)-BOUNDARY_TOLERANCE.AND. &
! ! !                                        & X(3)<BOUNDARY_X(3,2)+BOUNDARY_TOLERANCE.AND.X(3)>BOUNDARY_X(3,2)-BOUNDARY_TOLERANCE.OR. &
! ! !                                        & X(1)<BOUNDARY_X(1,1)+BOUNDARY_TOLERANCE.AND.X(1)>BOUNDARY_X(1,1)-BOUNDARY_TOLERANCE.AND. &
! ! !                                        & X(2)<BOUNDARY_X(2,2)+BOUNDARY_TOLERANCE.AND.X(2)>BOUNDARY_X(2,2)-BOUNDARY_TOLERANCE.AND. &
! ! !                                        & X(3)<BOUNDARY_X(3,1)+BOUNDARY_TOLERANCE.AND.X(3)>BOUNDARY_X(3,1)-BOUNDARY_TOLERANCE.OR. &
! ! !                                        & X(1)<BOUNDARY_X(1,1)+BOUNDARY_TOLERANCE.AND.X(1)>BOUNDARY_X(1,1)-BOUNDARY_TOLERANCE.AND. &
! ! !                                        & X(2)<BOUNDARY_X(2,2)+BOUNDARY_TOLERANCE.AND.X(2)>BOUNDARY_X(2,2)-BOUNDARY_TOLERANCE.AND. &
! ! !                                        & X(3)<BOUNDARY_X(3,2)+BOUNDARY_TOLERANCE.AND.X(3)>BOUNDARY_X(3,2)-BOUNDARY_TOLERANCE.OR. &
! ! !                                        & X(1)<BOUNDARY_X(1,2)+BOUNDARY_TOLERANCE.AND.X(1)>BOUNDARY_X(1,2)-BOUNDARY_TOLERANCE.AND. &
! ! !                                        & X(2)<BOUNDARY_X(2,1)+BOUNDARY_TOLERANCE.AND.X(2)>BOUNDARY_X(2,1)-BOUNDARY_TOLERANCE.AND. &
! ! !                                        & X(3)<BOUNDARY_X(3,1)+BOUNDARY_TOLERANCE.AND.X(3)>BOUNDARY_X(3,1)-BOUNDARY_TOLERANCE.OR. &
! ! !                                        & X(1)<BOUNDARY_X(1,2)+BOUNDARY_TOLERANCE.AND.X(1)>BOUNDARY_X(1,2)-BOUNDARY_TOLERANCE.AND. &
! ! !                                        & X(2)<BOUNDARY_X(2,1)+BOUNDARY_TOLERANCE.AND.X(2)>BOUNDARY_X(2,1)-BOUNDARY_TOLERANCE.AND. &
! ! !                                        & X(3)<BOUNDARY_X(3,2)+BOUNDARY_TOLERANCE.AND.X(3)>BOUNDARY_X(3,2)-BOUNDARY_TOLERANCE.OR. &
! ! !                                        & X(1)<BOUNDARY_X(1,2)+BOUNDARY_TOLERANCE.AND.X(1)>BOUNDARY_X(1,2)-BOUNDARY_TOLERANCE.AND. &
! ! !                                        & X(2)<BOUNDARY_X(2,2)+BOUNDARY_TOLERANCE.AND.X(2)>BOUNDARY_X(2,2)-BOUNDARY_TOLERANCE.AND. &
! ! !                                        & X(3)<BOUNDARY_X(3,1)+BOUNDARY_TOLERANCE.AND.X(3)>BOUNDARY_X(3,1)-BOUNDARY_TOLERANCE.OR. &
! ! !                                        & X(1)<BOUNDARY_X(1,2)+BOUNDARY_TOLERANCE.AND.X(1)>BOUNDARY_X(1,2)-BOUNDARY_TOLERANCE.AND. &
! ! !                                        & X(2)<BOUNDARY_X(2,2)+BOUNDARY_TOLERANCE.AND.X(2)>BOUNDARY_X(2,2)-BOUNDARY_TOLERANCE.AND. &
! ! !                                        & X(3)<BOUNDARY_X(3,2)+BOUNDARY_TOLERANCE.AND.X(3)>BOUNDARY_X(3,2)-BOUNDARY_TOLERANCE) THEN
! ! !                                          CALL BOUNDARY_CONDITIONS_SET_LOCAL_DOF(BOUNDARY_CONDITIONS,variable_type,local_ny, &
! ! !                                            & BOUNDARY_CONDITION_FIXED,VALUE,ERR,ERROR,*999)
! ! !                                          BOUND_COUNT=BOUND_COUNT+1
! ! !                                       ENDIF
! ! !                                       ENDIF
! ! !                                     ENDIF
! ! !                                   ELSE
! ! !                                     IF(component_idx<=NUMBER_OF_DIMENSIONS+1) THEN
! ! !                                       CALL FIELD_PARAMETER_SET_UPDATE_LOCAL_DOF(DEPENDENT_FIELD,variable_type, &
! ! !                                         & FIELD_VALUES_SET_TYPE,local_ny,VALUE,ERR,ERROR,*999)
! ! !                                     ENDIF
! ! !                                   ENDIF
! ! !                                 ENDIF
                                ENDIF
                              ENDDO !deriv_idx
                            ENDDO !node_idx
                          ELSE
                            CALL FLAG_ERROR("Domain topology nodes is not associated.",ERR,ERROR,*999)
                          ENDIF
                        ELSE
                          CALL FLAG_ERROR("Domain topology is not associated.",ERR,ERROR,*999)
                        ENDIF
                      ELSE
                        CALL FLAG_ERROR("Domain is not associated.",ERR,ERROR,*999)
                      ENDIF
                    ELSE
                      CALL FLAG_ERROR("Only node based interpolation is implemented.",ERR,ERROR,*999)
                    ENDIF
WRITE(*,*)'NUMBER OF BOUNDARIES SET ',BOUND_COUNT
                  ENDDO !component_idx
                  CALL FIELD_PARAMETER_SET_UPDATE_START(DEPENDENT_FIELD,variable_type,FIELD_ANALYTIC_VALUES_SET_TYPE, &
                    & ERR,ERROR,*999)
                  CALL FIELD_PARAMETER_SET_UPDATE_FINISH(DEPENDENT_FIELD,variable_type,FIELD_ANALYTIC_VALUES_SET_TYPE, &
                    & ERR,ERROR,*999)
                  CALL FIELD_PARAMETER_SET_UPDATE_START(DEPENDENT_FIELD,variable_type,FIELD_VALUES_SET_TYPE, &
                    & ERR,ERROR,*999)
                  CALL FIELD_PARAMETER_SET_UPDATE_FINISH(DEPENDENT_FIELD,variable_type,FIELD_VALUES_SET_TYPE, &
                    & ERR,ERROR,*999)
                ELSE
                  CALL FLAG_ERROR("Field variable is not associated.",ERR,ERROR,*999)
                ENDIF
              ENDDO !variable_idx
              CALL FIELD_PARAMETER_SET_DATA_RESTORE(GEOMETRIC_FIELD,FIELD_U_VARIABLE_TYPE,FIELD_VALUES_SET_TYPE, &
                & GEOMETRIC_PARAMETERS,ERR,ERROR,*999)
              CALL FIELD_INTERPOLATED_POINTS_FINALISE(INTERPOLATED_POINT,ERR,ERROR,*999)
              CALL FIELD_INTERPOLATION_PARAMETERS_FINALISE(INTERPOLATION_PARAMETERS,ERR,ERROR,*999)
            ELSE
              CALL FLAG_ERROR("Boundary conditions is not associated.",ERR,ERROR,*999)
            ENDIF
          ELSE
            CALL FLAG_ERROR("Equations set geometric field is not associated.",ERR,ERROR,*999)
          ENDIF
        ELSE
          CALL FLAG_ERROR("Equations set dependent field is not associated.",ERR,ERROR,*999)
        ENDIF
      ELSE
        CALL FLAG_ERROR("Equations set analytic is not associated.",ERR,ERROR,*999)
      ENDIF
    ELSE
      CALL FLAG_ERROR("Equations set is not associated.",ERR,ERROR,*999)
    ENDIF

    CALL EXITS("NAVIER_STOKES_EQUATION_ANALYTIC_CALCULATE")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_EQUATION_ANALYTIC_CALCULATE",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_EQUATION_ANALYTIC_CALCULATE")
    RETURN 1    
  END SUBROUTINE NAVIER_STOKES_EQUATION_ANALYTIC_CALCULATE

  !
  !================================================================================================================================
  !
  !>Calculates the various analytic solutions given X and time, can be called from within analytic calculate or elsewhere if needed
  SUBROUTINE NAVIER_STOKES_EQUATION_ANALYTIC_FUNCTIONS(VALUE,X,MU_PARAM,RHO_PARAM,CURRENT_TIME,VARIABLE_TYPE, & 
    & GLOBAL_DERIV_INDEX,ANALYTIC_FUNCTION_TYPE,NUMBER_OF_DIMENSIONS,NUMBER_OF_COMPONENTS,COMPONENT_IDX,ERR,ERROR,*)

    !Argument variables
    INTEGER(INTG), INTENT(OUT) :: ERR !<The error code
    TYPE(VARYING_STRING), INTENT(OUT) :: ERROR !<The error string
    REAL(DP), INTENT(OUT) :: VALUE
    REAL(DP) :: MU_PARAM,RHO_PARAM
    REAL(DP), INTENT(IN) :: CURRENT_TIME
    REAL(DP), INTENT(IN), DIMENSION(3) :: X
    INTEGER(INTG), INTENT(IN) :: NUMBER_OF_DIMENSIONS,NUMBER_OF_COMPONENTS,COMPONENT_IDX
    !Local variables
    TYPE(VARYING_STRING) :: LOCAL_ERROR
    INTEGER(INTG) :: variable_type,GLOBAL_DERIV_INDEX,ANALYTIC_FUNCTION_TYPE
    !TYPE(DOMAIN_TYPE), POINTER :: DOMAIN
    !TYPE(DOMAIN_NODES_TYPE), POINTER :: DOMAIN_NODES
    REAL(DP) :: INTERNAL_TIME

    CALL ENTERS("NAVIER_STOKES_EQUATION_ANALYTIC_FUNCTIONS",ERR,ERROR,*999)

!\todo: Introduce user-defined or default values instead for density and viscosity
    INTERNAL_TIME=CURRENT_TIME
     SELECT CASE(ANALYTIC_FUNCTION_TYPE)
       CASE(EQUATIONS_SET_NAVIER_STOKES_EQUATION_ONE_DIM_1)
         IF(NUMBER_OF_DIMENSIONS==1.AND.NUMBER_OF_COMPONENTS==3) THEN
           !Polynomial function
           SELECT CASE(variable_type)
             CASE(FIELD_U_VARIABLE_TYPE)
               SELECT CASE(GLOBAL_DERIV_INDEX)
                 CASE(NO_GLOBAL_DERIV)
                   IF(component_idx==1) THEN
                     !calculate Q
                     VALUE=X(1)**2/10.0_DP**2
                   ELSE IF(component_idx==2) THEN
                     !calculate A
                     VALUE=X(1)**2/10.0_DP**2
                   ELSE IF(component_idx==3) THEN
                     !calculate P
                     VALUE=X(1)**2/10.0_DP**2
                   ELSE
                     CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                   ENDIF
                 CASE(GLOBAL_DERIV_S1)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE(GLOBAL_DERIV_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE(GLOBAL_DERIV_S1_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE DEFAULT
                   LOCAL_ERROR="The global derivative index of "//TRIM(NUMBER_TO_VSTRING( &
                     & GLOBAL_DERIV_INDEX,"*",ERR,ERROR))// &
                     & " is invalid."
                   CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
               END SELECT
             CASE(FIELD_DELUDELN_VARIABLE_TYPE)
               SELECT CASE(GLOBAL_DERIV_INDEX)
                 CASE(NO_GLOBAL_DERIV)
                   VALUE= 0.0_DP
                 CASE(GLOBAL_DERIV_S1)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE(GLOBAL_DERIV_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)                                    
                 CASE(GLOBAL_DERIV_S1_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE DEFAULT
                   LOCAL_ERROR="The global derivative index of "//TRIM(NUMBER_TO_VSTRING( &
                     & GLOBAL_DERIV_INDEX,"*",ERR,ERROR))// &
                     & " is invalid."
                   CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
               END SELECT
             CASE DEFAULT
               LOCAL_ERROR="The variable type of "//TRIM(NUMBER_TO_VSTRING(variable_type,"*",ERR,ERROR))// &
                 & " is invalid."
               CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
           END SELECT      
         ELSE 
           LOCAL_ERROR="The number of components does not correspond to the number of dimensions."
           CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
         ENDIF

       CASE(EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_1)
         IF(NUMBER_OF_DIMENSIONS==2.AND.NUMBER_OF_COMPONENTS==3) THEN
           !Polynomial function
           SELECT CASE(variable_type)
             CASE(FIELD_U_VARIABLE_TYPE)
               SELECT CASE(GLOBAL_DERIV_INDEX)
                 CASE(NO_GLOBAL_DERIV)
                   IF(component_idx==1) THEN
                     !calculate u
                     VALUE=X(2)**2/10.0_DP**2
                   ELSE IF(component_idx==2) THEN
                     !calculate v
                     VALUE=X(1)**2/10.0_DP**2
                   ELSE IF(component_idx==3) THEN
                     !calculate p
                     VALUE=2.0_DP/3.0_DP*X(1)*(3.0_DP*MU_PARAM*10.0_DP**2-RHO_PARAM*X(1)**2*X(2))/(10.0_DP ** 4)
                   ELSE
                     CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                   ENDIF
                 CASE(GLOBAL_DERIV_S1)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE(GLOBAL_DERIV_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE(GLOBAL_DERIV_S1_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE DEFAULT
                   LOCAL_ERROR="The global derivative index of "//TRIM(NUMBER_TO_VSTRING( &
                     & GLOBAL_DERIV_INDEX,"*",ERR,ERROR))// &
                     & " is invalid."
                   CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
               END SELECT
             CASE(FIELD_DELUDELN_VARIABLE_TYPE)
               SELECT CASE(GLOBAL_DERIV_INDEX)
                 CASE(NO_GLOBAL_DERIV)
                   VALUE= 0.0_DP
                 CASE(GLOBAL_DERIV_S1)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE(GLOBAL_DERIV_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)                                    
                 CASE(GLOBAL_DERIV_S1_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE DEFAULT
                   LOCAL_ERROR="The global derivative index of "//TRIM(NUMBER_TO_VSTRING( &
                     & GLOBAL_DERIV_INDEX,"*",ERR,ERROR))// &
                     & " is invalid."
                   CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
               END SELECT
             CASE DEFAULT
               LOCAL_ERROR="The variable type of "//TRIM(NUMBER_TO_VSTRING(variable_type,"*",ERR,ERROR))// &
                 & " is invalid."
               CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
           END SELECT      
         ELSE 
           LOCAL_ERROR="The number of components does not correspond to the number of dimensions."
           CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
         ENDIF

       CASE(EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_2)
         IF(NUMBER_OF_DIMENSIONS==2.AND.NUMBER_OF_COMPONENTS==3) THEN
           !Exponential function
           SELECT CASE(variable_type)
             CASE(FIELD_U_VARIABLE_TYPE)
               SELECT CASE(GLOBAL_DERIV_INDEX)
                 CASE(NO_GLOBAL_DERIV)
                   IF(component_idx==1) THEN
                     !calculate u
                     VALUE= EXP((X(1)-X(2))/10.0_DP)
                   ELSE IF(component_idx==2) THEN
                     !calculate v
                     VALUE= EXP((X(1)-X(2))/10.0_DP)
                   ELSE IF(component_idx==3) THEN
                     !calculate p
                     VALUE= 2.0_DP*MU_PARAM/10.0_DP*EXP((X(1)-X(2))/10.0_DP)
                   ELSE
                     CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                   ENDIF
                 CASE(GLOBAL_DERIV_S1)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE(GLOBAL_DERIV_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE(GLOBAL_DERIV_S1_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE DEFAULT
                   LOCAL_ERROR="The global derivative index of "//TRIM(NUMBER_TO_VSTRING( &
                     & GLOBAL_DERIV_INDEX,"*",ERR,ERROR))// &
                     & " is invalid."
                   CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
               END SELECT
             CASE(FIELD_DELUDELN_VARIABLE_TYPE)
               SELECT CASE(GLOBAL_DERIV_INDEX)
                 CASE(NO_GLOBAL_DERIV)
                   IF(component_idx==1) THEN
                     !calculate u
                     VALUE= 0.0_DP
                   ELSE IF(component_idx==2) THEN
                     !calculate v
                     VALUE= 0.0_DP
                   ELSE IF(component_idx==3) THEN
                     !calculate p
                     VALUE= 0.0_DP
                   ELSE
                     CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                   ENDIF
                 CASE(GLOBAL_DERIV_S1)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE(GLOBAL_DERIV_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)                                    
                 CASE(GLOBAL_DERIV_S1_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE DEFAULT
                   LOCAL_ERROR="The global derivative index of "//TRIM(NUMBER_TO_VSTRING( &
                     & GLOBAL_DERIV_INDEX,"*",ERR,ERROR))// &
                     & " is invalid."
                   CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
               END SELECT
             CASE DEFAULT
               LOCAL_ERROR="The variable type of "//TRIM(NUMBER_TO_VSTRING(variable_type,"*",ERR,ERROR))// &
                 & " is invalid."
               CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
           END SELECT      
         ELSE 
           LOCAL_ERROR="The number of components does not correspond to the number of dimensions."
           CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
         ENDIF

       CASE(EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_3)
         IF(NUMBER_OF_DIMENSIONS==2.AND.NUMBER_OF_COMPONENTS==3) THEN
           !Sine and cosine function
           SELECT CASE(variable_type)
             CASE(FIELD_U_VARIABLE_TYPE)
               SELECT CASE(GLOBAL_DERIV_INDEX)
                 CASE(NO_GLOBAL_DERIV)
                   IF(component_idx==1) THEN
                     !calculate u
                     VALUE=SIN(2.0_DP*PI*X(1)/10.0_DP)*SIN(2.0_DP*PI*X(2)/10.0_DP)
                   ELSE IF(component_idx==2) THEN
                     !calculate v
                     VALUE=COS(2.0_DP*PI*X(1)/10.0_DP)*COS(2.0_DP*PI*X(2)/10.0_DP)
                   ELSE IF(component_idx==3) THEN
                     !calculate p
                     VALUE=4.0_DP*MU_PARAM*PI/10.0_DP*SIN(2.0_DP*PI*X(2)/10.0_DP)*COS(2.0_DP*PI*X(1)/10.0_DP)+ &
                       & 0.5_DP*RHO_PARAM*COS(2.0_DP*PI*X(1)/10.0_DP)*COS(2.0_DP*PI*X(1)/10.0_DP)
                   ELSE
                     CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                   ENDIF
                 CASE(GLOBAL_DERIV_S1)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE(GLOBAL_DERIV_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE(GLOBAL_DERIV_S1_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE DEFAULT
                   LOCAL_ERROR="The global derivative index of "//TRIM(NUMBER_TO_VSTRING( &
                     & GLOBAL_DERIV_INDEX,"*",ERR,ERROR))// &
                     & " is invalid."
                   CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
               END SELECT
             CASE(FIELD_DELUDELN_VARIABLE_TYPE)
               SELECT CASE(GLOBAL_DERIV_INDEX)
                 CASE(NO_GLOBAL_DERIV)
                   IF(component_idx==1) THEN
                     !calculate u
                     VALUE=0.0_DP
                   ELSE IF(component_idx==2) THEN
                     !calculate v
                     VALUE=16.0_DP*MU_PARAM*PI**2/10.0_DP**2*cos(2.0_DP*PI*X(2)/ 10.0_DP)*cos(2.0_DP*PI*X(1)/10.0_DP)
                   ELSE IF(component_idx==3) THEN
                     !calculate p
                     VALUE=0.0_DP
                   ELSE
                     CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                   ENDIF
                 CASE(GLOBAL_DERIV_S1)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE(GLOBAL_DERIV_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)                                    
                 CASE(GLOBAL_DERIV_S1_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE DEFAULT
                   LOCAL_ERROR="The global derivative index of "//TRIM(NUMBER_TO_VSTRING( &
                     & GLOBAL_DERIV_INDEX,"*",ERR,ERROR))// &
                     & " is invalid."
                   CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
               END SELECT
             CASE DEFAULT
               LOCAL_ERROR="The variable type of "//TRIM(NUMBER_TO_VSTRING(variable_type,"*",ERR,ERROR))// &
                 & " is invalid."
               CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
           END SELECT      
         ELSE 
           LOCAL_ERROR="The number of components does not correspond to the number of dimensions."
           CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
         ENDIF
       CASE(EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_4,EQUATIONS_SET_NAVIER_STOKES_EQUATION_TWO_DIM_5)
         IF(NUMBER_OF_DIMENSIONS==2.AND.NUMBER_OF_COMPONENTS==3) THEN
           !Taylor-Green vortex solution
           SELECT CASE(variable_type)
             CASE(FIELD_U_VARIABLE_TYPE)
               SELECT CASE(GLOBAL_DERIV_INDEX)
                 CASE(NO_GLOBAL_DERIV)
                   IF(component_idx==1) THEN
                     !calculate u
                     VALUE=SIN(X(1)/10.0_DP*2.0_DP*PI)*COS(X(2)/10.0_DP*2.0_DP*PI)*EXP(-2.0_DP*MU_PARAM/RHO_PARAM*CURRENT_TIME)
                     VALUE=SIN(X(1)/10.0_DP*PI)*COS(X(2)/10.0_DP*PI)*EXP(-2.0_DP*MU_PARAM/RHO_PARAM*CURRENT_TIME)
!                      VALUE=SIN(X(1))*COS(X(2))
                   ELSE IF(component_idx==2) THEN
                     !calculate v
                     VALUE=-COS(X(1)/10.0_DP*2.0_DP*PI)*SIN(X(2)/10.0_DP*2.0_DP*PI)*EXP(-2.0_DP*MU_PARAM/RHO_PARAM*CURRENT_TIME)
                     VALUE=-COS(X(1)/10.0_DP*PI)*SIN(X(2)/10.0_DP*PI)*EXP(-2.0_DP*MU_PARAM/RHO_PARAM*CURRENT_TIME)
!                      VALUE=-COS(X(1))*SIN(X(2))
                   ELSE IF(component_idx==3) THEN
                     !calculate p
                     VALUE=RHO_PARAM/4.0_DP*(COS(2.0_DP*X(1)/10.0_DP*2.0_DP*PI)+COS(2.0_DP*X(2)/10.0_DP*2.0_DP*PI))* &
                       & EXP(-4.0_DP*MU_PARAM/RHO_PARAM*CURRENT_TIME)                      
                     VALUE=RHO_PARAM/4.0_DP*(COS(2.0_DP*X(1)/10.0_DP*PI)+COS(2.0_DP*X(2)/10.0_DP*PI))* &
                       & EXP(-4.0_DP*MU_PARAM/RHO_PARAM*CURRENT_TIME)                      
!                      VALUE=RHO_PARAM/4.0_DP*(COS(2.0_DP*X(1))+COS(2.0_DP*X(2)))
                   ELSE
                     CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                   ENDIF
                 CASE(GLOBAL_DERIV_S1)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE(GLOBAL_DERIV_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE(GLOBAL_DERIV_S1_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE DEFAULT
                   LOCAL_ERROR="The global derivative index of "//TRIM(NUMBER_TO_VSTRING( &
                     & GLOBAL_DERIV_INDEX,"*",ERR,ERROR))// &
                     & " is invalid."
                   CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
               END SELECT
             CASE(FIELD_DELUDELN_VARIABLE_TYPE)
               SELECT CASE(GLOBAL_DERIV_INDEX)
                 CASE(NO_GLOBAL_DERIV)
                   IF(component_idx==1) THEN
                     !calculate u
                     VALUE=0.0_DP
                   ELSE IF(component_idx==2) THEN
                     !calculate v
                     VALUE=0.0_DP         
                   ELSE IF(component_idx==3) THEN
                     !calculate p
                     VALUE=0.0_DP
                   ELSE
                     CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                   ENDIF
                 CASE(GLOBAL_DERIV_S1)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE(GLOBAL_DERIV_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)                                    
                 CASE(GLOBAL_DERIV_S1_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE DEFAULT
                   LOCAL_ERROR="The global derivative index of "//TRIM(NUMBER_TO_VSTRING( &
                     & GLOBAL_DERIV_INDEX,"*",ERR,ERROR))// &
                     & " is invalid."
                   CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
               END SELECT
             CASE DEFAULT
               LOCAL_ERROR="The variable type of "//TRIM(NUMBER_TO_VSTRING(variable_type,"*",ERR,ERROR))// &
                 & " is invalid."
               CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
           END SELECT      
         ELSE 
           LOCAL_ERROR="The number of components does not correspond to the number of dimensions."
           CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
         ENDIF
       CASE(EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_1)
         IF(NUMBER_OF_DIMENSIONS==3.AND.NUMBER_OF_COMPONENTS==4) THEN
           !Polynomial function
           SELECT CASE(variable_type)
             CASE(FIELD_U_VARIABLE_TYPE)
               SELECT CASE(GLOBAL_DERIV_INDEX)
                 CASE(NO_GLOBAL_DERIV)
                   IF(component_idx==1) THEN
                     !calculate u
                     VALUE=X(2)**2/10.0_DP**2+X(3)**2/10.0_DP**2
                   ELSE IF(component_idx==2) THEN
                     !calculate v
                     VALUE=X(1)**2/10.0_DP**2+X(3)**2/10.0_DP** 2
                   ELSE IF(component_idx==3) THEN
                     !calculate w
                     VALUE=X(1)**2/10.0_DP**2+X(2)**2/10.0_DP** 2
                   ELSE IF(component_idx==4) THEN
                     !calculate p
                     VALUE=2.0_DP/3.0_DP*X(1)*(6.0_DP*MU_PARAM*10.0_DP**2-RHO_PARAM*X(2)*X(1)**2-3.0_DP* & 
                       & RHO_PARAM*X(2)* &
                       & X(3)**2-RHO_PARAM*X(3)*X(1)**2-3.0_DP*RHO_PARAM*X(3)*X(2)**2)/(10.0_DP**4)
                   ELSE
                     CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                   ENDIF
                 CASE(GLOBAL_DERIV_S1)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE(GLOBAL_DERIV_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE(GLOBAL_DERIV_S1_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE DEFAULT
                   LOCAL_ERROR="The global derivative index of "//TRIM(NUMBER_TO_VSTRING( &
                     & GLOBAL_DERIV_INDEX,"*",ERR,ERROR))// &
                     & " is invalid."
                   CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
               END SELECT   
             CASE(FIELD_DELUDELN_VARIABLE_TYPE)
               SELECT CASE(GLOBAL_DERIV_INDEX)
                 CASE(NO_GLOBAL_DERIV)
                   VALUE=0.0_DP
                 CASE(GLOBAL_DERIV_S1)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE(GLOBAL_DERIV_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)                                    
                 CASE(GLOBAL_DERIV_S1_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE DEFAULT
                   LOCAL_ERROR="The global derivative index of "//TRIM(NUMBER_TO_VSTRING( &
                     & GLOBAL_DERIV_INDEX,"*",ERR,ERROR))// &
                     & " is invalid."
                   CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                END SELECT
              CASE DEFAULT
                LOCAL_ERROR="The variable type of "//TRIM(NUMBER_TO_VSTRING(variable_type,"*",ERR,ERROR))// &
                  & " is invalid."
                CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
           END SELECT      
         ELSE 
           LOCAL_ERROR="The number of components does not correspond to the number of dimensions."
           CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
         ENDIF
       CASE(EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_2)
         IF(NUMBER_OF_DIMENSIONS==3.AND.NUMBER_OF_COMPONENTS==4) THEN
           !Exponential function
           SELECT CASE(variable_type)
             CASE(FIELD_U_VARIABLE_TYPE)
               SELECT CASE(GLOBAL_DERIV_INDEX)
                 CASE(NO_GLOBAL_DERIV)
                   IF(component_idx==1) THEN
                     !calculate u
                     VALUE=EXP((X(1)-X(2))/10.0_DP)+EXP((X(3)-X(1))/10.0_DP)
                   ELSE IF(component_idx==2) THEN
                     !calculate v
                     VALUE=EXP((X(1)-X(2))/10.0_DP)+EXP((X(2)-X(3))/10.0_DP)
                   ELSE IF(component_idx==3) THEN
                     !calculate w
                     VALUE=EXP((X(3)-X(1))/10.0_DP)+EXP((X(2)-X(3))/10.0_DP)
                   ELSE IF(component_idx==4) THEN
                     !calculate p
                     VALUE=1.0_DP/10.0_DP*(2.0_DP*MU_PARAM*EXP((X(1)-X(2))/10.0_DP)- & 
                       & 2.0_DP*MU_PARAM*EXP((X(3)-X(1))/10.0_DP)+RHO_PARAM*10.0_DP*EXP((X(1)-X(3))/10.0_DP)+ & 
                       & RHO_PARAM*10.0_DP*EXP((X(2)-X(1))/10.0_DP))
                   ELSE
                     CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                   ENDIF
                 CASE(GLOBAL_DERIV_S1)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE(GLOBAL_DERIV_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE(GLOBAL_DERIV_S1_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE DEFAULT
                   LOCAL_ERROR="The global derivative index of "//TRIM(NUMBER_TO_VSTRING( &
                     & GLOBAL_DERIV_INDEX,"*",ERR,ERROR))// &
                     & " is invalid."
                   CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
               END SELECT   
             CASE(FIELD_DELUDELN_VARIABLE_TYPE)
               SELECT CASE(GLOBAL_DERIV_INDEX)
                 CASE(NO_GLOBAL_DERIV)
                   IF(component_idx==1) THEN
                     !calculate u
                     VALUE=0.0_DP
                   ELSE IF(component_idx==2) THEN
                     !calculate v
                     VALUE=-2.0_DP*MU_PARAM*(2.0_DP*EXP(X(1)-X(2))+EXP(X(2)-X(3)))
                   ELSE IF(component_idx==3) THEN
                     !calculate w
                     VALUE=-2.0_DP*MU_PARAM*(2.0_DP*EXP(X(3)-X(1))+EXP(X(2)-X(3)))
                   ELSE IF(component_idx==4) THEN
                     !calculate p
                     VALUE=0.0_DP
                   ELSE
                     CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                   ENDIF
                 CASE(GLOBAL_DERIV_S1)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE(GLOBAL_DERIV_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)                                    
                 CASE(GLOBAL_DERIV_S1_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE DEFAULT
                   LOCAL_ERROR="The global derivative index of "//TRIM(NUMBER_TO_VSTRING( &
                     & GLOBAL_DERIV_INDEX,"*",ERR,ERROR))// &
                     & " is invalid."
                   CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
               END SELECT
             CASE DEFAULT
               LOCAL_ERROR="The variable type of "//TRIM(NUMBER_TO_VSTRING(variable_type,"*",ERR,ERROR))// &
                 & " is invalid."
               CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
           END SELECT      
         ELSE 
           LOCAL_ERROR="The number of components does not correspond to the number of dimensions."
           CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
         ENDIF
       CASE(EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_3)
         IF(NUMBER_OF_DIMENSIONS==3.AND.NUMBER_OF_COMPONENTS==4) THEN
           !Sine/cosine function
           SELECT CASE(variable_type)
             CASE(FIELD_U_VARIABLE_TYPE)
               SELECT CASE(GLOBAL_DERIV_INDEX)
                 CASE(NO_GLOBAL_DERIV)
                   IF(component_idx==1) THEN
                     !calculate u
                     VALUE=sin(2.0_DP*PI*X(1)/10.0_DP)*sin(2.0_DP*PI*X(2)/10.0_DP)*sin(2.0_DP*PI*X(3)/10.0_DP)
                   ELSE IF(component_idx==2) THEN
                     !calculate v
                     VALUE=2.0_DP*cos(2.0_DP*PI*x(1)/10.0_DP)*sin(2.0_DP*PI*X(3)/10.0_DP)*cos(2.0_DP*PI*X(2)/10.0_DP)
                   ELSE IF(component_idx==3) THEN
                     !calculate w
                     VALUE=-cos(2.0_DP*PI*X(1)/10.0_DP)*sin(2.0_DP*PI*X(2)/10.0_DP)*cos(2.0_DP*PI*X(3)/10.0_DP)
                   ELSE IF(component_idx==4) THEN
                     !calculate p
                     VALUE=-COS(2.0_DP*PI*X(1)/10.0_DP)*(-12.0_DP*MU_PARAM*PI*SIN(2.0_DP*PI*X(2)/10.0_DP)* & 
                       & SIN(2.0_DP*PI*X(3)/10.0_DP)-RHO_PARAM*COS(2.0_DP*PI*X(1)/10.0_DP)*10.0_DP+ &
                       & 2.0_DP*RHO_PARAM*COS(2.0_DP*PI*X(1)/10.0_DP)*10.0_DP*COS(2.0_DP*PI*X(3)/10.0_DP)**2- &
                       & RHO_PARAM*COS(2.0_DP*PI*X(1)/10.0_DP)*10.0_DP*COS(2.0_DP*PI*X(2)/10.0_DP)**2)/10.0_DP/2.0_DP
                   ELSE
                     CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                   ENDIF
                 CASE(GLOBAL_DERIV_S1)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE(GLOBAL_DERIV_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE(GLOBAL_DERIV_S1_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE DEFAULT
                   LOCAL_ERROR="The global derivative index of "//TRIM(NUMBER_TO_VSTRING( &
                     & GLOBAL_DERIV_INDEX,"*",ERR,ERROR))// &
                     & " is invalid."
                   CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                END SELECT   
              CASE(FIELD_DELUDELN_VARIABLE_TYPE)
                SELECT CASE(GLOBAL_DERIV_INDEX)
                  CASE(NO_GLOBAL_DERIV)
                    IF(component_idx==1) THEN
                      !calculate u
                      VALUE=0.0_DP
                    ELSE IF(component_idx==2) THEN
                      !calculate v
                      VALUE=36*MU_PARAM*PI**2/10.0_DP**2*cos(2.0_DP*PI*X(2)/10.0_DP)*sin(2.0_DP*PI*X(3)/10.0_DP)* & 
                        & cos(2.0_DP*PI*X(1)/10.0_DP)
                    ELSE IF(component_idx==3) THEN
                      !calculate w
                      VALUE=0.0_DP
                    ELSE IF(component_idx==4) THEN
                      !calculate p
                      VALUE=0.0_DP
                    ELSE
                      CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                    ENDIF
                  CASE(GLOBAL_DERIV_S1)
                    CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                  CASE(GLOBAL_DERIV_S2)
                    CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)                                    
                  CASE(GLOBAL_DERIV_S1_S2)
                    CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                  CASE DEFAULT
                    LOCAL_ERROR="The global derivative index of "//TRIM(NUMBER_TO_VSTRING( &
                      & GLOBAL_DERIV_INDEX,"*",ERR,ERROR))// &
                      & " is invalid."
                    CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
                END SELECT
              CASE DEFAULT
                LOCAL_ERROR="The variable type of "//TRIM(NUMBER_TO_VSTRING(variable_type,"*",ERR,ERROR))// &
                  & " is invalid."
                CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
            END SELECT      
          ELSE 
            LOCAL_ERROR="The number of components does not correspond to the number of dimensions."
            CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
          ENDIF
       CASE(EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_4,EQUATIONS_SET_NAVIER_STOKES_EQUATION_THREE_DIM_5)
         IF(NUMBER_OF_DIMENSIONS==3.AND.NUMBER_OF_COMPONENTS==4) THEN
           !Taylor-Green vortex solution
           SELECT CASE(variable_type)
             CASE(FIELD_U_VARIABLE_TYPE)
               SELECT CASE(GLOBAL_DERIV_INDEX)
                 CASE(NO_GLOBAL_DERIV)
                   IF(component_idx==1) THEN
                     !calculate u
                     VALUE=SIN(X(1)/10.0_DP*PI)*COS(X(2)/10.0_DP*PI)*EXP(-2.0_DP*MU_PARAM/RHO_PARAM*CURRENT_TIME)
                   ELSE IF(component_idx==2) THEN
                     !calculate v
                     VALUE=-COS(X(1)/10.0_DP*PI)*SIN(X(2)/10.0_DP*PI)*EXP(-2.0_DP*MU_PARAM/RHO_PARAM*CURRENT_TIME)
                   ELSE IF(component_idx==3) THEN
                     !calculate v
                     VALUE=0.0_DP
!                      VALUE=-COS(X(1))*SIN(X(2))
                   ELSE IF(component_idx==4) THEN
                     !calculate p
                     VALUE=RHO_PARAM/4.0_DP*(COS(2.0_DP*X(1)/10.0_DP*PI)+COS(2.0_DP*X(2)/10.0_DP*PI))* &
                       & EXP(-4.0_DP*MU_PARAM/RHO_PARAM*CURRENT_TIME)                      
!                      VALUE=RHO_PARAM/4.0_DP*(COS(2.0_DP*X(1))+COS(2.0_DP*X(2)))
                   ELSE
                     CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                   ENDIF
                 CASE(GLOBAL_DERIV_S1)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE(GLOBAL_DERIV_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE(GLOBAL_DERIV_S1_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE DEFAULT
                   LOCAL_ERROR="The global derivative index of "//TRIM(NUMBER_TO_VSTRING( &
                     & GLOBAL_DERIV_INDEX,"*",ERR,ERROR))// &
                     & " is invalid."
                   CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
               END SELECT
             CASE(FIELD_DELUDELN_VARIABLE_TYPE)
               SELECT CASE(GLOBAL_DERIV_INDEX)
                 CASE(NO_GLOBAL_DERIV)
                   IF(component_idx==1) THEN
                     !calculate u
                     VALUE=0.0_DP
                   ELSE IF(component_idx==2) THEN
                     !calculate v
                     VALUE=0.0_DP         
                   ELSE IF(component_idx==3) THEN
                     !calculate p
                     VALUE=0.0_DP
                   ELSE IF(component_idx==4) THEN
                     !calculate p
                     VALUE=0.0_DP
                   ELSE
                     CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                   ENDIF
                 CASE(GLOBAL_DERIV_S1)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE(GLOBAL_DERIV_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)                                    
                 CASE(GLOBAL_DERIV_S1_S2)
                   CALL FLAG_ERROR("Not implemented.",ERR,ERROR,*999)
                 CASE DEFAULT
                   LOCAL_ERROR="The global derivative index of "//TRIM(NUMBER_TO_VSTRING( &
                     & GLOBAL_DERIV_INDEX,"*",ERR,ERROR))// &
                     & " is invalid."
                   CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
               END SELECT
             CASE DEFAULT
               LOCAL_ERROR="The variable type of "//TRIM(NUMBER_TO_VSTRING(variable_type,"*",ERR,ERROR))// &
                 & " is invalid."
               CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
           END SELECT      
         ELSE 
           LOCAL_ERROR="The number of components does not correspond to the number of dimensions."
           CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
         ENDIF
        CASE DEFAULT
          LOCAL_ERROR="The analytic function type of "// &
            & TRIM(NUMBER_TO_VSTRING(ANALYTIC_FUNCTION_TYPE,"*",ERR,ERROR))// &
            & " is invalid."
          CALL FLAG_ERROR(LOCAL_ERROR,ERR,ERROR,*999)
      END SELECT
    CALL EXITS("NAVIER_STOKES_EQUATION_ANALYTIC_FUNCTIONS")
    RETURN
999 CALL ERRORS("NAVIER_STOKES_EQUATION_ANALYTIC_FUNCTIONS",ERR,ERROR)
    CALL EXITS("NAVIER_STOKES_EQUATION_ANALYTIC_FUNCTIONS")
    RETURN 1
  END SUBROUTINE NAVIER_STOKES_EQUATION_ANALYTIC_FUNCTIONS
  !
  !================================================================================================================================
  !

END MODULE NAVIER_STOKES_EQUATIONS_ROUTINES
