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
    type: tpetra
    method: gmres
    preconditioner: muelu
    tolerance: 1e-5
    max_iterations: 50
    kspace: 50
    output_level: 0
    recompute_preconditioner: no
    summarize_muelu_timer: no
    muelu_xml_file_name: milestone.xml

realms:

  - name: realm_1
    mesh: ../mesh/grid07_conformal04_lowAR_ndtw.exo 
    use_edges: no
    check_for_missing_bcs: yes
    automatic_decomposition_type: rcb

    time_step_control:
     target_courant: 2.0
     time_step_change_factor: 1.025

    equation_systems:
      name: theEqSys
      max_iterations: 2

      solver_system_specification:
        velocity: solve_scalar
        pressure: solve_cont

      systems:

        - LowMachEOM:
            name: myLowMach
            max_iterations: 1
            convergence_tolerance: 1e-3

    material_properties:

      target_name: [Upstream-HEX,TipVortex-HEX,WingBox-9-HEX,WingBox-9-WEDGE,TestSection-PYRAMID,WingBox-9-PYRAMID,TestSection-TETRA,WingBox-9-TETRA]

      specifications:
 
        - name: density
          type: constant
          value: 0.00238

        - name: viscosity
          type: constant
          value: 3.8e-7

    initial_conditions:
      - constant: ic_1
        target_name: [Upstream-HEX,TipVortex-HEX,WingBox-9-HEX,WingBox-9-WEDGE,TestSection-PYRAMID,WingBox-9-PYRAMID,TestSection-TETRA,WingBox-9-TETRA]
        value:
          pressure: 0
          velocity: [239.4958,0.0,0.0]

  
    boundary_conditions:

    - symmetry_boundary_condition: bc_tunnel_walls
      target_name: TunnelWalls
      symmetry_user_data:

    - symmetry_boundary_condition: bc_support
      target_name: Support
      symmetry_user_data:

    - inflow_boundary_condition: bc_inflow
      target_name: TunnelInlet
      inflow_user_data:
        velocity: [239.4958,0.0,0.0]

    - open_boundary_condition: bc_outflow
      target_name: TunnelOutlet
      open_user_data:
        velocity: [0.0,0,0]
        pressure: 0.0

    - wall_boundary_condition: bc_wing
      target_name: Wing
      wall_user_data:
        velocity: [0,0,0]
        use_wall_function: no 

    solution_options:
      name: myOptions
      turbulence_model: laminar 
      shift_cvfem_mdot: no
      reduced_sens_cvfem_poisson: yes 
 
      use_consolidated_solver_algorithm: yes

      options:

        - shifted_gradient_operator:
            velocity: no
            pressure: no

        - projected_nodal_gradient:
            pressure: element
            velocity: element
        
        - element_source_terms:
            momentum: [lumped_momentum_time_derivative, advection_diffusion, NSO_2ND_KE]
            continuity: [advection]
    
    post_processing:
    
    - type: surface
      physics: surface_force_and_moment
      output_file_name: wingForces.dat
      frequency: 1
      parameters: [0,0,0]
      target_name: Wing

    output:
      output_data_base_name: output300M/mcalisterWing.e
      output_frequency: 100
      output_node_set: no
      output_variables:
       - velocity
       - pressure

    restart:
      restart_data_base_name: restart300M/mcalisterWing.rst
      output_frequency: 250

Time_Integrators:
  - StandardTimeIntegrator:
      name: ti_1
      start_time: 0
      termination_step_count: 20000
      time_step: 1.0e-9
      time_stepping_type: adaptive
      time_step_count: 0
      second_order_accuracy: yes 

      realms:
        - realm_1
