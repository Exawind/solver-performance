Simulations:
  - name: sim1
    time_integrator: ti_1
    optimizer: opt1

linear_solvers:

  - name: solve_scalar
    type: tpetra
    method: gmres
    preconditioner: sgs 
    tolerance: 1e-5
    max_iterations: 50
    kspace: 50
    output_level: 0

  - name: solve_cont
    type: hypre
    method: hypre_gmres
    preconditioner: boomerAMG
    tolerance: 1e-5
    max_iterations: 75
    kspace: 20
    output_level: 0
    recompute_preconditioner: no
    reuse_preconditioner: no
    summarize_muelu_timer: off
    write_matrix_files: off
    bamg_output_level: 1
    bamg_coarsen_type: 8
    #bamg_interp_type: 6
    bamg_interp_type: 13
    bamg_cycle_type:  1
    bamg_relax_type: 3
    bamg_relax_order: 1
    bamg_num_sweeps: 2
    bamg_keep_transpose: 1
    bamg_max_levels: 9
    #bamg_trunc_factor: 0.1
    bamg_trunc_factor: 0.25
    bamg_agg_num_levels: 2
    bamg_agg_interp_type: 4
    bamg_agg_pmax_elmts: 2
    bamg_pmax_elmts: 2
    bamg_strong_threshold: 0.25
    bamg_non_galerkin_tol: 0.05
    bamg_non_galerkin_level_tols:
      levels: [0, 1, 2]
      tolerances: [0.0, 0.01, 0.01]

realms:

  - name: realm_1
    mesh: ../../../meshes/V27/V27_41_R0.exo
    use_edges: no       
    activate_aura: no
    automatic_decomposition_type: rcb
    check_for_missing_bcs: yes 
    activate_memory_diagnostic: yes

    time_step_control:
     target_courant: 5.0
     time_step_change_factor: 1.15
   
    equation_systems:
      name: theEqSys
      max_iterations: 2 
   
      solver_system_specification:
        pressure: solve_cont
        velocity: solve_scalar
        dpdx: solve_scalar
 
      systems:
        - LowMachEOM:
            name: myLowMach
            max_iterations: 1
            convergence_tolerance: 1e-5

    initial_conditions:
      - constant: ic_1
        target_name: [block_101, block_201, block_104, block_204, block_105, block_205, block_106, block_206]
        value:
          pressure: 0
          velocity: [7.6,0.0,0.0]

    material_properties:
      target_name: [block_101, block_201, block_104, block_204, block_105, block_205, block_106, block_206]
      specifications:
        - name: density
          type: constant
          value: 1.2

        - name: viscosity
          type: constant
          value: 1.8e-5

    boundary_conditions:

    - inflow_boundary_condition: bc_front
      target_name: surface_1
      inflow_user_data:
        velocity: [7.6,0.0,0.0]

    - open_boundary_condition: bc_back
      target_name: surface_2
      open_user_data:
        pressure: 0.0

    - symmetry_boundary_condition: bc_top
      target_name: surface_3
      symmetry_user_data:

    - symmetry_boundary_condition: bc_sides
      target_name: surface_4
      symmetry_user_data:

    - wall_boundary_condition: bc_ground
      target_name: surface_6
      wall_user_data:
        velocity: [0.0,0.0,0.0]

    - wall_boundary_condition: bc_tower
      target_name: surface_7
      wall_user_data:
        velocity: [0.0,0.0,0.0]

    - wall_boundary_condition: bc_nacelle
      target_name: surface_8
      wall_user_data:
        user_function_name:
         velocity: wind_energy
        user_function_string_parameters:
         velocity: [mmOne]

    - wall_boundary_condition: bc_back_strip
      target_name: surface_9
      wall_user_data:
        velocity: [0.0,0.0,0.0]

    - wall_boundary_condition: bc_cone
      target_name: surface_10
      wall_user_data:
        user_function_name:
         velocity: wind_energy
        user_function_string_parameters:
         velocity: [mmOne]

    - wall_boundary_condition: bc_blade1
      target_name: surface_11
      wall_user_data:
        user_function_name:
         velocity: wind_energy
        user_function_string_parameters:
         velocity: [mmOne]

    - wall_boundary_condition: bc_blade2
      target_name: surface_12
      wall_user_data:
        user_function_name:
         velocity: wind_energy
        user_function_string_parameters:
         velocity: [mmOne]

    - wall_boundary_condition: bc_blade3
      target_name: surface_13
      wall_user_data:
        user_function_name:
         velocity: wind_energy
        user_function_string_parameters:
         velocity: [mmOne]

    - non_conformal_boundary_condition: bc_in_out
      current_target_name: [surface_19, surface_15, surface_17]
      opposing_target_name: [surface_18, surface_14, surface_16]
      non_conformal_user_data:
        expand_box_percentage: 5.0 
        search_tolerance: 0.01 
        search_method: stk_kdtree

    - non_conformal_boundary_condition: bc_out_in
      current_target_name: [surface_18, surface_14, surface_16]
      opposing_target_name: [surface_19, surface_15, surface_17]
      non_conformal_user_data:
        expand_box_percentage: 5.0 
        search_tolerance: 0.01 
        search_method: stk_kdtree

    solution_options:
      name: myOptions
      turbulence_model: wale 
      use_consolidated_solver_algorithm: no 

      mesh_motion:

        - name: mmOne
          target_name: [block_101, block_104, block_105, block_106]
          omega: 4.237
          unit_vector: [0.9975641, 0.0, -0.06975647] 
          compute_centroid: yes

        - name: mmTwo
          target_name: [block_201, block_204, block_205, block_206]
          omega: 0.0

      options:

        - element_source_terms:
            momentum: [NSO_2ND_ALT]

        - consistent_mass_matrix_png:
            pressure: no 
            velocity: no

        - non_conformal:
            gauss_labatto_quadrature: no
            algorithm_type: dg
            upwind_advection: yes 
            current_normal: yes 
            include_png_penalty: no
            activate_coincident_node_error_check: yes 
          
        - shifted_gradient_operator:
            velocity: no
            pressure: yes 
  
    post_processing:
    
    - type: surface
      physics: surface_force_and_moment
      output_file_name: fullV27_41.dat
      frequency: 20 
      parameters: [-0.206163, 4.66517e-08, 0.0135008] 
      target_name: [surface_11, surface_12, surface_13]

    output:
      output_data_base_name: out_hypre/fullV27_41.e
      output_frequency: 50 
      output_node_set: no 
      output_variables:
       - velocity
       - pressure
       - mesh_displacement

    restart:
      restart_data_base_name: rst_hypre/fullV27_41.rst
      restart_frequency: 200
      restart_start: 200
      restart_forced_wall_time: 47.8
 
Time_Integrators:
  - StandardTimeIntegrator:
      name: ti_1
      start_time: 0
      termination_step_count: 20
      time_step: 5.0e-6 
      time_stepping_type: adaptive
      time_step_count: 0
      second_order_accuracy: no 

      realms:
        - realm_1
