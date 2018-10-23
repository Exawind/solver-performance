Simulations:
  - name: nrel_5mw_g1.rst0
    time_integrator: ti_1
    optimizer: opt1

linear_solvers:

  - name: solve_scalar
    type: tpetra
    method: gmres
    preconditioner: sgs
    tolerance: 1e-5
    max_iterations: 300
    kspace: 100
    output_level: 0

  - name: solve_cont
    type: tpetra
    method: gmres
    preconditioner: muelu
    tolerance: 1e-5
    max_iterations: 300
    kspace: 100
    output_level: 0
    #muelu_xml_file_name: v27.xml
    muelu_xml_file_name: muelu-sgs.xml
    #muelu_xml_file_name: muelu-l1gs2-drop0.02-unsmoo-noqr-rebaltarg10k-explR-rebalPR-aggsize-quiet.xml
    #muelu_xml_file_name: muelu-l1gs2-prepost.xml

realms:

  - name: realm_1
    #mesh: mesh/nrel_5mw_g1.exo
    mesh: restart/nrel_5mw_g1.rst0
    check_jacobians: no
    use_edges: no
    activate_aura: no
    check_for_missing_bcs: yes
    #automatic_decomposition_type: rcb

    time_step_control:
     target_courant: 10.0
     time_step_change_factor: 1.05

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
        target_name: [block_101, block_201, block_104, block_204, block_105, block_205, block_106, block_106.Tetrahedron_4._urpconv, block_206, block_206.Tetrahedron_4._urpconv]
        value:
          pressure: 0
          velocity: [8.0,0.0,0.0]

    material_properties:
      target_name: [block_101, block_201, block_104, block_204, block_105, block_205, block_106, block_106.Tetrahedron_4._urpconv, block_206, block_206.Tetrahedron_4._urpconv]
      specifications:
        - name: density
          type: constant
          value: 1.2
        - name: viscosity
          type: constant
          value: 1.8e-5

    boundary_conditions:

    - inflow_boundary_condition: front
      target_name: surface_1
      inflow_user_data:
        velocity: [8.0,0.0,0.0]

    - open_boundary_condition: back
      target_name: surface_3
      open_user_data:
        pressure: 0.0

    - symmetry_boundary_condition: sides
      target_name: surface_2
      symmetry_user_data:

    - symmetry_boundary_condition: top
      target_name: surface_4
      symmetry_user_data:

    - symmetry_boundary_condition: bottom
      target_name: surface_5
      symmetry_user_data:

    #- wall_boundary_condition: bottom
    #  target_name: surface_5
    #  wall_user_data:
    #    velocity: [0,0,0]
    #    use_wall_function: no

    - wall_boundary_condition: nacelle
      target_name: surface_11
      wall_user_data:
        velocity: [0,0,0]
        use_wall_function: no

    - wall_boundary_condition: tower
      target_name: surface_10
      wall_user_data:
        velocity: [0,0,0]
        use_wall_function: no

    - wall_boundary_condition: blade_1
      target_name: surface_6
      wall_user_data:
        user_function_name:
         velocity: wind_energy
        user_function_string_parameters:
         velocity: [mesh_motion_rotor]
        use_wall_function: no

    - wall_boundary_condition: blade_2
      target_name: surface_7
      wall_user_data:
        user_function_name:
         velocity: wind_energy
        user_function_string_parameters:
         velocity: [mesh_motion_rotor]
        use_wall_function: no

    - wall_boundary_condition: blade_3
      target_name: surface_8
      wall_user_data:
        user_function_name:
         velocity: wind_energy
        user_function_string_parameters:
         velocity: [mesh_motion_rotor]
        use_wall_function: no

    - wall_boundary_condition: hub_rot
      target_name: surface_9
      wall_user_data:
        user_function_name:
         velocity: wind_energy
        user_function_string_parameters:
         velocity: [mesh_motion_rotor]
        use_wall_function: no

    - non_conformal_boundary_condition: back_rot
      current_target_name: [surface_18]
      opposing_target_name: [surface_16]
      non_conformal_user_data:
        expand_box_percentage: 15.0
        search_tolerance: 0.05
        search_method: stk_kdtree

    - non_conformal_boundary_condition: back_stat
      current_target_name: [surface_16]
      opposing_target_name: [surface_18]
      non_conformal_user_data:
        expand_box_percentage: 15.0
        search_tolerance: 0.05
        search_method: stk_kdtree

    - non_conformal_boundary_condition: front_rot
      current_target_name: [surface_14]
      opposing_target_name: [surface_17]
      non_conformal_user_data:
        expand_box_percentage: 15.0
        search_tolerance: 0.05
        search_method: stk_kdtree

    - non_conformal_boundary_condition: front_stat
      current_target_name: [surface_17]
      opposing_target_name: [surface_14]
      non_conformal_user_data:
        expand_box_percentage: 15.0
        search_tolerance: 0.05
        search_method: stk_kdtree

    - non_conformal_boundary_condition: out_rot
      current_target_name: [surface_12]
      opposing_target_name: [surface_13]
      non_conformal_user_data:
        expand_box_percentage: 15.0
        search_tolerance: 0.05
        search_method: stk_kdtree

    - non_conformal_boundary_condition: out_stat
      current_target_name: [surface_13]
      opposing_target_name: [surface_12]
      non_conformal_user_data:
        expand_box_percentage: 15.0
        search_tolerance: 0.05
        search_method: stk_kdtree

    solution_options:

      name: myOptions
      turbulence_model: wale
      use_consolidated_solver_algorithm: yes

      mesh_motion:

        - name: mesh_motion_rotor
          target_name: [block_101, block_104, block_105, block_106, block_106.Tetrahedron_4._urpconv]
          #omega: 0.8888888888888888 #TSR=7 @ 8.0 m/s inflow velocity
          omega: 0.9587301587301587 #TSR=7.55 @ 8.0 m/s inflow velocity
          #centroid: [-14.673948 0.0 1.2838041]
          unit_vector: [0.9961946980917455, 0.0, -0.08715574274765817]
          compute_centroid: yes

        - name: mesh_motion_outer_domain
          target_name: [block_201, block_204, block_205, block_206, block_206.Tetrahedron_4._urpconv]
          omega: 0.0

      options:

        - element_source_terms:
            momentum: [lumped_momentum_time_derivative, advection_diffusion, NSO_2ND_ALT]
            continuity: advection

        - non_conformal:
            gauss_labatto_quadrature: no
            algorithm_type: dg
            upwind_advection: yes
            current_normal: yes
            include_png_penalty: no
            activate_coincident_node_error_check: no

        - consistent_mass_matrix_png:
            pressure: no
            velocity: no

        - shifted_gradient_operator:
            velocity: no
            pressure: yes

#    turbulence_averaging:
#      time_filter_interval: 100000.0

      specifications:

        - name: one
          target_name: [block_101, block_201, block_104, block_204, block_105, block_205, block_106, block_106.Tetrahedron_4._urpconv, block_206, block_206.Tetrahedron_4._urpconv]
          reynolds_averaged_variables:
            - velocity
          compute_q_criterion: no
          compute_vorticity: no

    post_processing:

    - type: surface
      physics: surface_force_and_moment
      output_file_name: output/nrel_5mw_g1.dat
      frequency: 1000
      parameters: [0, 0, 0]
      target_name: [surface_6, surface_7, surface_8, surface_9]

    output:
      output_data_base_name: output/nrel_5mw_g1.e
      output_frequency: 1000
      output_start: 1000
      output_node_set: no
      output_variables:
       - velocity
       - pressure
       - turbulent_viscosity
       - mesh_displacement

    restart:
      restart_data_base_name: restart/nrel_5mw_g1.rst0
      restart_frequency: 50
      restart_start: 50
      #restart_forced_wall_time: 19000
      #restart_time: 1000000.0
      restart_time: 3.47192518080328e-07

Time_Integrators:
  - StandardTimeIntegrator:
      name: ti_1
      start_time: 0
      termination_step_count: 30
      #termination_step_count: 20
      time_step: 1.0e-8
      time_stepping_type: adaptive
      time_step_count: 0
      second_order_accuracy: yes

      realms:
        - realm_1
