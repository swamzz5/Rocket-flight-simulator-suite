    function results = simulateFlight(rocket, settings, launchAltitude)
    
    %==========================================================
    % Rocket Flight Simulator
    % Version 0.4
    % Developed by Swayam Rout
    %
    % Simulates 1D vertical rocket flight using semi-implicit
    % (Euler-Cromer) integration.
    %
    % Inputs:
    %   rocket         - rocket definition struct
    %   settings       - simulation settings struct (dt, maxTime, g)
    %   launchAltitude - launch site elevation above sea level (m).
    %                    Optional; defaults to 0 (sea level) if omitted.
    %                    FIX: previously the sim always computed
    %                    atmosphere from 0 regardless of what launch
    %                    altitude the user entered in the main script -
    %                    that input was silently disconnected from the
    %                    simulation. It is now used to offset every
    %                    atmosphere lookup during the flight.
    %==========================================================
    
    if nargin < 3
        launchAltitude = 0;
    end
    
    %% Initial Conditions
    
    time = 0;
    dt = settings.dt;
    
    altitude = 0;               % height ABOVE THE LAUNCH SITE (AGL), not MSL
    velocity = 0;
    mach = 0;                  % FIX: initialized so it exists before first loop pass
    
    mass = rocket.EmptyMass + rocket.FuelMass;
    
    landed = false;             % FIX: tracks whether landing was actually detected,
                                 % as opposed to the loop simply running out of maxTime
    
    %% Propulsive Landing State
    % Landing propellant is reserved mass carried the entire flight,
    % separate from ascent FuelMass, unused until the suicide-burn
    % trigger fires. The landing engine reuses the ascent engine's
    % mass-flow characteristic (FuelMass/BurnTime), scaled to whatever
    % thrust level the landing burn uses - this models "relight the
    % main engine" rather than a separate dedicated thruster.
    
    landingFuelRemaining = rocket.LandingFuelMass;
    landingBurnActive = false;
    massFlowPerNewton = (rocket.FuelMass / rocket.BurnTime) / rocket.MaxThrust;
    
    %% Storage Arrays
    
    timeHistory = [];
    altitudeHistory = [];
    velocityHistory = [];
    accelerationHistory = [];
    dragHistory = [];
    thrustHistory = [];
    massHistory = [];
    machHistory = [];
    dynamicPressureHistory = [];
    reynoldsHistory = [];
    cdHistory = [];
    landingBurnHistory = [];
    landingFuelHistory = [];
    
    
    %% Simulation Loop
    
    while time <= settings.maxTime
    
        %--------------------------------------
        % Atmospheric Properties
        %--------------------------------------
    
        atm = isaAtmosphere(max(launchAltitude + altitude, 0));
    
        %--------------------------------------
        % Rocket Mass
        %--------------------------------------
    
        mass = massModel(time, rocket);
    
        % Reserved landing propellant is onboard mass from launch until
        % it's actually burned, regardless of whether the landing engine
        % has ignited yet.
        mass = mass + landingFuelRemaining;
    
        %--------------------------------------
        % Thrust
        %--------------------------------------
    
        thrust = thrustModel(time, rocket);
    
        %--------------------------------------
        % Propulsive Landing (Suicide Burn)
        %--------------------------------------
    
        if ~landingBurnActive && time > rocket.BurnTime && velocity < 0 && landingFuelRemaining > 0
            landingBurnActive = suicideBurnTrigger( ...
                altitude, velocity, mass, rocket.LandingThrust, settings.g, landingFuelRemaining);
        end
    
        % FIX: cut the landing burn the instant velocity reaches/crosses
        % zero. Without this, the burn keeps firing until fuel runs out
        % even after velocity has been nulled - since thrust/mass
        % increases as landing propellant burns off, the vehicle
        % overshoots into a small upward hop, then free-falls once fuel
        % is exhausted mid-air. This was caught by independent testing
        % (see conversation) before shipping, not something the
        % original "idealized instant on/off" description alone
        % implied - it needed an explicit termination condition.
        if landingBurnActive && velocity >= 0
            landingBurnActive = false;
        end
    
        if landingBurnActive && landingFuelRemaining > 0
            thrust = rocket.LandingThrust;   % overrides the (zero) post-ascent-burnout thrust
        end
    
        %--------------------------------------
        % Mach Number
        %--------------------------------------
        % FIX: computed here, from the velocity/atmosphere already known
        % at the start of this timestep, so Cd below always sees a
        % defined, same-timestep-consistent Mach value. Previously this
        % was computed AFTER integration further down, so Cd used an
        % undefined variable on the first pass (crash) and a
        % post-integration value on every later pass (an inconsistency,
        % not just an initialization bug).
    
        mach = machNumber(velocity, atm.SpeedOfSound);
    
        %--------------------------------------
        % Aerodynamic Drag
        %--------------------------------------
    
        Cd = dragCoefficient(mach);
    
        drag = dragForce( ...
            atm.Density, ...
            abs(velocity), ...
            Cd, ...
            rocket.ReferenceArea);
    
        % Drag always opposes motion
        if velocity > 0
            drag = -drag;
        elseif velocity < 0
            drag = drag;
        end
    
        %--------------------------------------
        % Dynamic Pressure and Reynolds Number
        %--------------------------------------
        % FIX: these were already implemented as standalone functions
        % but never called from inside the simulation loop. Wiring them
        % in here is what makes Max-Q and Reynolds-vs-time trackable.
    
        q  = dynamicPressure(atm.Density, velocity);
        Re = reynoldsNumber(atm.Density, velocity, rocket.Length, atm.DynamicViscosity);
    
        %--------------------------------------
        % Equations of Motion
        %--------------------------------------
        % FIX (Phase 3 refactor): weight/netForce/acceleration used to
        % be computed inline here. That physics now lives in
        % dynamics/equationsOfMotion1D.m so the simulation loop below
        % is pure orchestration - the physics can be swapped for a 2D/3D
        % model later without touching this loop structure.
    
        acceleration = equationsOfMotion1D(thrust, drag, mass, settings.g);
    
        %--------------------------------------
        % Semi-Implicit (Euler-Cromer) Integration
        %--------------------------------------
    
        velocity = velocity + acceleration * dt;
    
        altitude = altitude + velocity * dt;
    
        % Prevent rocket going underground
        if altitude < 0
            altitude = 0;
        end
    
        %--------------------------------------
        % Landing Propellant Consumption
        %--------------------------------------
        % FIX: consumed AFTER this step's force/acceleration calc, same
        % ordering convention as ascent (massModel uses mass at the
        % start of the step). If fuel runs out mid-burn, thrust drops
        % to zero next iteration - a flamed-out landing attempt, which
        % flightEvents.m will classify as a hard landing / crash.
    
        if landingBurnActive && landingFuelRemaining > 0
            burnMdot = massFlowPerNewton * rocket.LandingThrust;
            landingFuelRemaining = max(0, landingFuelRemaining - burnMdot*dt);
            if landingFuelRemaining <= 0
                landingBurnActive = false;
            end
        end
    
        %--------------------------------------
        % Store Results
        %--------------------------------------
    
        timeHistory(end+1) = time;
        altitudeHistory(end+1) = altitude;
        velocityHistory(end+1) = velocity;
        accelerationHistory(end+1) = acceleration;
        dragHistory(end+1) = (drag);
        thrustHistory(end+1) = thrust;
        massHistory(end+1) = mass;
        machHistory(end+1) = mach;
        dynamicPressureHistory(end+1) = q;
        reynoldsHistory(end+1) = Re;
        cdHistory(end+1) = Cd;
        landingBurnHistory(end+1) = landingBurnActive;
        landingFuelHistory(end+1) = landingFuelRemaining;
    
        %--------------------------------------
        % Stop when rocket lands
        %--------------------------------------
    
        if altitude <= 0 && time > rocket.BurnTime && velocity < 0
            altitude = 0;
            landed = true;
            break
        end
    
        %--------------------------------------
        % Advance Time
        %--------------------------------------
    
        time = time + dt;
    
    end
    
    %% Physical Sanity Check
    % FIX: if the loop exited because time exceeded settings.maxTime rather
    % than because the landing condition was met, the flight was cut off
    % mid-descent. Results up to that point are still valid data, but
    % "Flight Time", "Landing Velocity", etc. do NOT represent an actual
    % landing and should not be trusted as such.
    
    if ~landed
        warning(['Simulation reached maxTime (%.1f s) before the rocket landed. ' ...
                 'Results reflect an incomplete flight - increase settings.maxTime ' ...
                 'and rerun before trusting landing time/velocity.'], settings.maxTime);
    end
    
    %% Store Results Structure
    
    results.time = timeHistory;
    results.altitude = altitudeHistory;
    results.velocity = velocityHistory;
    results.acceleration = accelerationHistory;
    results.drag = dragHistory;
    results.thrust = thrustHistory;
    results.mass = massHistory;
    results.mach = machHistory;
    results.dynamicPressure = dynamicPressureHistory;
    results.reynolds = reynoldsHistory;
    results.cd = cdHistory;
    results.landingBurnActive = landingBurnHistory;
    results.landingFuelRemaining = landingFuelHistory;
    
    %% Flight Summary
    
    fprintf('\n');
    disp('======================================')
    disp('Simulation Complete')
    disp('======================================')
    
    fprintf('Flight Time     : %.2f s\n', timeHistory(end));
    fprintf('Maximum Altitude: %.2f m\n', max(altitudeHistory));
    fprintf('Maximum Velocity: %.2f m/s\n', max(velocityHistory));
    fprintf('Maximum Mach    : %.2f\n', max(machHistory));
    
    end
