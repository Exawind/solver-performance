#11 -*- mode: yaml -*-

Simulations:
  - name: sim1
    time_integrator: ti_1
    optimizer: opt1

linear_solvers:

  - name: solve_scalar
    type: tpetra
    method: gmres
    preconditioner: muelu
    #preconditioner: ilut
    tolerance: 1e-5
    max_iterations: 100
    kspace: 75
    output_level: 0
    write_matrix_files: no
    #recompute_preconditioner: no
    #reuse_preconditioner: yes
    muelu_xml_file_name: ilu.xml

  - name: solve_ke
    type: tpetra
    method: gmres
    preconditioner: sgs
    tolerance: 1e-5
    max_iterations: 100
    kspace: 75
    output_level: 0
    write_matrix_files: no
  
  - name: solve_cont
    type: hypre
    method: hypre_gmres
    preconditioner: boomerAMG
    tolerance: 1e-5
    max_iterations: 200
    kspace: 75
    output_level: 0
    bamg_coarsen_type: 8
    bamg_interp_type: 6
    bamg_cycle_type: 1

  - name: solve_mom
    type: hypre
    method: hypre_gmres
    preconditioner: boomerAMG
    tolerance: 1e-5
    write_matrix_files: no
    max_iterations: 200
    kspace: 75
    output_level: 0
    segregated_solver: yes
    bamg_max_levels: 1
    bamg_relax_type: 6
    bamg_num_sweeps: 1

realms:

  - name: realm_1
    #mesh: du91w2_ndtw.exo
    mesh: results/du91w2.rst
    automatic_decomposition_type: rcb
    use_edges: yes

    time_step_control:
     target_courant: 1000.0
     time_step_change_factor: 1.05
   
    equation_systems:
      name: theEqSys
      max_iterations: 2

      solver_system_specification:
        velocity: solve_ke
        turbulent_ke: solve_ke
        specific_dissipation_rate: solve_ke
        pressure: solve_cont

      systems:

        - LowMachEOM:
            name: myLowMach
            max_iterations: 1
            convergence_tolerance: 1e-8

        - ShearStressTransport:
            name: mySST 
            max_iterations: 1
            convergence_tolerance: 1e-8

    initial_conditions:
      - constant: ic_1
        target_name: [Flow-QUAD,Flow-TRIANGLE]
        value:
          pressure: 0
          velocity: [14.96346075389736,1.046347106161880]
          turbulent_ke: 0.095118
          specific_dissipation_rate: 2266.4

    material_properties:
      target_name: [Flow-QUAD]
      specifications:
        - name: density
          type: constant
          value: 1.225
        - name: viscosity
          type: constant
          value: 9.187500000000000e-06

    boundary_conditions:

    - wall_boundary_condition: bc_wall
      target_name: Airfoil
      wall_user_data:
        velocity: [0,0]
        use_wall_function: no
        turbulent_ke: 0.0


    - inflow_boundary_condition: bc_inflow
      target_name: Inlet
      inflow_user_data:
        velocity: [14.96346075389736,1.046347106161880]
        turbulent_ke: 0.095118
        specific_dissipation_rate: 2266.4

    - inflow_boundary_condition: bc_bottom
      target_name: Bottom
      inflow_user_data:
        velocity: [14.96346075389736,1.046347106161880]
        turbulent_ke: 0.095118
        specific_dissipation_rate: 2266.4

    - open_boundary_condition: bc_open
      target_name: Outlet
      open_user_data:
        velocity: [0,0]
        pressure: 0.0
        turbulent_ke: 0.095118
        specific_dissipation_rate: 2266.4

    - open_boundary_condition: bc_top
      target_name: Top
      open_user_data:
        velocity: [0,0]
        pressure: 0.0
        turbulent_ke: 0.095118
        specific_dissipation_rate: 2266.4

    solution_options:
      name: myOptions
      turbulence_model: sst
      projected_timescale_type: momentum_diag_inv #### Use 1/diagA formulation

      options:
        - hybrid_factor:
            velocity: 1.0 
            turbulent_ke: 1.0
            specific_dissipation_rate: 1.0

        - upw_factor:
            velocity: 1.0
            turbulent_ke: 0.0
            specific_dissipation_rate: 0.0

        - alpha_upw:
            velocity: 1.0
            turbulent_ke: 1.0
            specific_dissipation_rate: 1.0

        - noc_correction:
            pressure: yes

        - limiter:
            pressure: no
            velocity: yes
            turbulent_ke: yes
            specific_dissipation_rate: yes

        - projected_nodal_gradient:
            velocity: element
            pressure: element 
            turbulent_ke: element
            specific_dissipation_rate: element
    
        - input_variables_from_file:
            minimum_distance_to_wall: ndtw

        - relaxation_factor: # Set relaxation factors (works with old formulation also)
            velocity: 0.7 # 0.7
            pressure: 0.3 # 0.3
            turbulent_ke: 0.7
            specific_dissipation_rate: 0.7
            
    post_processing:
    
    - type: surface
      physics: surface_force_and_moment
      output_file_name: results/forces.dat
      frequency: 1 
      parameters: [0,0]
      target_name: Airfoil

    restart:
      restart_data_base_name: results/du91w2.rst
      restart_frequency: 9001
      restart_start: 9001
      restart_time: 199.999999999994
      #restart_time: 248.069

    output:
      output_data_base_name: results/du91w2.e
      output_frequency: 9001
      output_start: 9001
      output_node_set: no 
      output_variables:
       - velocity
       - pressure
       - pressure_force
       - tau_wall 
       - turbulent_ke
       - specific_dissipation_rate
       - minimum_distance_to_wall
       - turbulent_viscosity
       - element_courant
       - element_reynolds
     
Time_Integrators:
  - StandardTimeIntegrator:
      name: ti_1
      start_time: 0
#     time_step: 1.000000000000000e+1
      time_step: 5.000000000000000e-1
#     time_step: 2.500000000000000e-1
#     time_step: 3.333333333333333e-1
#     time_step: 6.666666666666667e-1
#     termination_time:  6.666666666666667e-2
      termination_step_count: 6010
      time_stepping_type: fixed
      time_step_count: 0
      second_order_accuracy: yes

      realms: 
        - realm_1
