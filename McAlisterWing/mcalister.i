Simulations:
  - name: sim1
    time_integrator: ti_1
    optimizer: opt1

linear_solvers:

  - name: solve_scalar
    type: tpetra
    method: gmres
    preconditioner: riluk
    tolerance: 1e-5
    max_iterations: 200
    kspace: 200
    output_level: 0

  - name: solve_cont
    type: hypre
    method: hypre_gmres
    preconditioner: boomerAMG
    tolerance: 1e-5
    max_iterations: 300
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
    max_iterations: 200
    kspace: 75
    output_level: 0
    segregated_solver: yes
    bamg_max_levels: 1
    bamg_relax_type: 6
    bamg_num_sweeps: 1

  - name: solve_momentum
    type: tpetra
    method: gmres
    preconditioner: muelu
    #preconditioner: ilut
    #preconditioner: sgs
    tolerance: 1e-5
    max_iterations: 1000
    kspace: 500
    output_level: 0
    write_matrix_files: no
    muelu_xml_file_name: ilu.xml

realms:

  - name: realm_1
    mesh: ./meshes/freestream-wing1-tipvortex1-mirror-aoa12.exo
    automatic_decomposition_type: rcb
    use_edges: yes

    equation_systems:
      name: theEqSys
      max_iterations: 4

      solver_system_specification:
        velocity: solve_scalar
        turbulent_ke: solve_scalar
        specific_dissipation_rate: solve_scalar
        pressure: solve_cont
        ndtw: solve_cont

      systems:
        - WallDistance:
            name: myNDTW
            max_iterations: 1
            convergence_tolerance: 1.0e-8

        - LowMachEOM:
            name: myLowMach
            max_iterations: 1
            num_pressure_correctors: 3
            convergence_tolerance: 1e-8

        - ShearStressTransport:
            name: mySST
            max_iterations: 1
            convergence_tolerance: 1e-8

    initial_conditions:
      - constant: ic_1
        target_name:
          - background-HEX
          - wing-HEX
          - wing-WEDGE
          - tipvortex-HEX
        value:
          pressure: 0
          velocity: [46.0, 0.0, 0.0]
          turbulent_ke: 0.69
          specific_dissipation_rate: 230.0

    material_properties:
      target_name:
        - background-HEX
        - wing-HEX
        - wing-WEDGE
        - tipvortex-HEX
      specifications:
        - name: density
          type: constant
          value: 1.225
        - name: viscosity
          type: constant
          value: 0.00003756

    boundary_conditions:

    - open_boundary_condition: bc_open
      target_name: outlet
      open_user_data:
        velocity: [0,0,0]
        pressure: 0.0
        turbulent_ke: 0.69
        specific_dissipation_rate: 230.0

    - inflow_boundary_condition: bc_inflow
      target_name: inlet
      inflow_user_data:
        velocity: [46.0, 0.0, 0.0]
        turbulent_ke: 0.69
        specific_dissipation_rate: 230.0

    - wall_boundary_condition: bc_wing
      target_name: wing
      wall_user_data:
        velocity: [0,0,0]
        use_wall_function: no
        turbulent_ke: 0.0

    - symmetry_boundary_condition: bc_tunnel_wall
      target_name: tunnel_wall
      symmetry_user_data:

    - overset_boundary_condition: bc_overset
      overset_connectivity_type: tioga
      overset_user_data:
        tioga_populate_inactive_part: false
        mesh_group:
          - overset_name: wing
            mesh_parts: [ wing-HEX, wing-WEDGE ]
            ovset_parts: [ outerbc_wingblock ]
            wall_parts: [wing]

          - overset_name: tipvortex
            mesh_parts: [ tipvortex-HEX ]
            ovset_parts: [ outerbc_tipvortexblock ]

          - overset_name: background
            mesh_parts: [ background-HEX ]

    solution_options:
      name: myOptions
      turbulence_model: sst
      projected_timescale_type: momentum_diag_inv

      options:
        - hybrid_factor:
            velocity: 1.0
            turbulent_ke: 1.0
            specific_dissipation_rate: 1.0

        - alpha_upw:
            # to disable upwinding, set velocity to 0
            velocity: 1.0
            turbulent_ke: 1.0
            specific_dissipation_rate: 1.0

        - upw_factor:
            velocity: 1.0
            turbulent_ke: 0.0
            specific_dissipation_rate: 0.0

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
            ndtw: element

        - relaxation_factor:
            velocity: 0.7
            pressure: 0.3
            turbulent_ke: 0.7
            specific_dissipation_rate: 0.7

        - turbulence_model_constants:
            SDRWallFactor: 0.625

    post_processing:

      - type: surface
        physics: surface_force_and_moment
        output_file_name: forces.dat
        frequency: 1
        parameters: [0,0,0]
        target_name: wing

    restart:
      restart_data_base_name: rst/mcalister.rst
      restart_frequency: 50
      restart_start: 5

    output:
      output_data_base_name: out/mcalister.e
      output_frequency: 50
      output_node_set: no
      output_variables:
       - velocity
       - pressure
       - pressure_force
       - viscous_force
       - turbulent_ke
       - specific_dissipation_rate
       - minimum_distance_to_wall
       - sst_f_one_blending
       - turbulent_viscosity
       - element_courant
       - iblank
       - iblank_cell
       - element_courant
       - assembled_area_force_moment

Time_Integrators:
  - StandardTimeIntegrator:
      name: ti_1
      start_time: 0
      time_step: 0.001
      termination_step_count: 10000
      time_stepping_type: fixed
      time_step_count: 0
      second_order_accuracy: yes

      realms:
        - realm_1
