%% Rocket Design & Flight Simulation Suite

% Developed by Swayam Rout

%% Initialization 
clc;
clear;
close all;

appVersion = "0.1";     % FIX: renamed from "version" - that name shadows
                        % MATLAB's built-in version() function

addpath(genpath(pwd));

disp('===============================================')
disp(' Rocket Design & Flight Simulation Suite')
fprintf(' Version %s\n', appVersion)
disp('===============================================')

%% Load Rocket Database
rocketDB = rocketDatabase();

% Display Rocket List
disp(' ')
disp('Available Rockets')
disp('----------------------------')

for i = 1:length(rocketDB)
    fprintf('%d. %s\n', i, rocketDB(i).Name);
end

fprintf('%d. Custom Rocket\n', length(rocketDB)+1);

%% User Selection
choice = input('Select Rocket : ');

if choice == length(rocketDB)+1

    rocket.Name = input('Rocket Name : ','s');
    rocket.Diameter = input('Diameter (m) : ');
    rocket.Length = input('Length (m) : ');
    rocket.EmptyMass = input('Empty Mass (kg) : ');
    rocket.FuelMass = input('Fuel Mass (kg) : ');
    rocket.BurnTime = input('Burn Time (s) : ');
    rocket.MaxThrust = input('Maximum Thrust (N) : ');
    rocket.Cd = input('Drag Coefficient : ');

    % FIX: basic input validation for custom rocket parameters.
    % Physically nonsensical inputs (negative/zero mass, diameter,
    % burn time, etc.) previously passed through silently and only
    % surfaced as confusing NaN/Inf results much later in the sim.
    if rocket.Diameter <= 0
        error('RocketInput:invalidDiameter', 'Diameter must be positive (got %.4f m).', rocket.Diameter);
    end
    if rocket.Length <= 0
        error('RocketInput:invalidLength', 'Length must be positive (got %.4f m).', rocket.Length);
    end
    if rocket.EmptyMass <= 0
        error('RocketInput:invalidEmptyMass', 'Empty mass must be positive (got %.4f kg).', rocket.EmptyMass);
    end
    if rocket.FuelMass < 0
        error('RocketInput:invalidFuelMass', 'Fuel mass cannot be negative (got %.4f kg).', rocket.FuelMass);
    end
    if rocket.BurnTime <= 0
        error('RocketInput:invalidBurnTime', 'Burn time must be positive (got %.4f s).', rocket.BurnTime);
    end
    if rocket.MaxThrust <= 0
        error('RocketInput:invalidThrust', 'Maximum thrust must be positive (got %.4f N).', rocket.MaxThrust);
    end
    if rocket.Cd <= 0
        error('RocketInput:invalidCd', 'Drag coefficient must be positive (got %.4f).', rocket.Cd);
    end

    rocket.ReferenceArea = pi*(rocket.Diameter/2)^2;

    % --- Stability geometry (for Barrowman CP calculation) ---
    disp(' ')
    disp('Stability Geometry (for static margin calculation)')
    disp('----------------------------')

    rocket.NoseLength = input('Nose Length (m) : ');
    rocket.NoseType = input('Nose Type (''ogive'' or ''conical'') : ','s');
    rocket.FinCount = input('Number of Fins : ');
    rocket.FinRootChord = input('Fin Root Chord (m) : ');
    rocket.FinTipChord = input('Fin Tip Chord (m) : ');
    rocket.FinSpan = input('Fin Span (m) : ');
    rocket.FinSweepLength = input('Fin Sweep Length (m) : ');
    rocket.FinPosition = input('Fin Position, nose tip to fin root LE (m) : ');
    rocket.CG = input('Center of Gravity, from nose tip (m) : ');

    if rocket.NoseLength <= 0
        error('RocketInput:invalidNoseLength', 'Nose length must be positive.');
    end
    if ~(strcmpi(rocket.NoseType,'ogive') || strcmpi(rocket.NoseType,'conical'))
        error('RocketInput:invalidNoseType', 'Nose type must be ''ogive'' or ''conical''.');
    end
    if rocket.FinCount < 3
        error('RocketInput:invalidFinCount', 'Fin count must be at least 3.');
    end
    if rocket.FinRootChord <= 0 || rocket.FinTipChord < 0 || rocket.FinSpan <= 0
        error('RocketInput:invalidFinGeometry', ...
            'Fin root chord and span must be positive; tip chord must be non-negative.');
    end
    if rocket.CG <= 0 || rocket.CG >= rocket.Length
        error('RocketInput:invalidCG', ...
            'CG (%.3f m) must be between 0 and rocket Length (%.3f m).', rocket.CG, rocket.Length);
    end

    % --- Propulsive landing (reserved landing propellant) ---
    disp(' ')
    disp('Propulsive Landing (relights the main engine for a suicide burn)')
    disp('----------------------------')

    rocket.LandingFuelMass = input('Landing Fuel Mass, reserved (kg) : ');
    rocket.LandingThrust = rocket.MaxThrust;   % assumes same engine relit at same thrust

    if rocket.LandingFuelMass < 0
        error('RocketInput:invalidLandingFuel', ...
            'Landing fuel mass cannot be negative (got %.4f kg).', rocket.LandingFuelMass);
    end

else

    if choice < 1 || choice > length(rocketDB)
        error('RocketInput:invalidSelection', 'Invalid Rocket Selection')
    end

    rocket = rocketDB(choice);

end

disp(' ')
disp('Rocket Loaded Successfully!')
disp('----------------------------')

fprintf('Name           : %s\n', rocket.Name);
fprintf('Diameter       : %.3f m\n', rocket.Diameter);
fprintf('Length         : %.3f m\n', rocket.Length);
fprintf('Empty Mass     : %.3f kg\n', rocket.EmptyMass);
fprintf('Fuel Mass      : %.3f kg\n', rocket.FuelMass);
fprintf('Burn Time      : %.3f s\n', rocket.BurnTime);
fprintf('Maximum Thrust : %.3f N\n', rocket.MaxThrust);
fprintf('Drag Coefficient : %.3f\n', rocket.Cd);
fprintf('Reference Area : %.6f m^2\n', rocket.ReferenceArea);

%% Stability Module

disp(' ')
disp('===============================================')
disp('Stability Module')
disp('===============================================')

[Cp, CnAlpha] = barrowmanCP(rocket);
[margin, stabilityStatus] = staticMargin(Cp, rocket.CG, rocket.Diameter);

fprintf('Center of Pressure  : %.4f m (from nose tip)\n', Cp);
fprintf('Center of Gravity   : %.4f m (from nose tip)\n', rocket.CG);
fprintf('CnAlpha (total)     : %.3f per radian\n', CnAlpha);
fprintf('Static Margin       : %.2f calibers\n', margin);
fprintf('Stability Status    : %s\n', stabilityStatus);

if strcmp(stabilityStatus,'UNSTABLE')
    warning(['Static margin is %.2f calibers - configuration is UNSTABLE. ' ...
             'CP is ahead of (or at) CG; this rocket will not fly straight.'], margin);
elseif strcmp(stabilityStatus,'MARGINAL')
    warning(['Static margin is %.2f calibers - below the 1-caliber rule of ' ...
             'thumb. May be unstable in practice (wind, thrust misalignment).'], margin);
end

disp(' ')
disp(['NOTE: Barrowman CP is a subsonic, small-angle-of-attack estimate. ' ...
      'It does not capture the CP shift near Mach 1 - treat this margin ' ...
      'as most trustworthy during the low-speed portion of flight.'])

%% Simulation Settings
% FIX: moved up so settings.g exists before it's needed for the
% "Derived Parameters" section below - this removes the second,
% independent hardcoded gravity constant that used to live down there.

settings = simSettings();

%% Derived Parameters
initialMass = rocket.EmptyMass + rocket.FuelMass;
massRatio = initialMass / rocket.EmptyMass;
finalMass = rocket.EmptyMass;

weight = initialMass * settings.g;   % FIX: was hardcoded 9.81; now the
                                      % single source of truth is
                                      % settings.g, same value the
                                      % simulator itself uses

thrustToWeight = rocket.MaxThrust / weight;

disp(' ')
disp('Derived Values')
disp('----------------------------')

fprintf('Initial Mass : %.3f kg\n', initialMass);
fprintf('Mass Ratio   : %.3f\n', massRatio);
fprintf('Final Mass     : %.3f kg\n', finalMass);
fprintf('Weight         : %.3f N\n', weight);
fprintf('Thrust/Weight  : %.2f\n', thrustToWeight);

if thrustToWeight <= 1
    warning(['Thrust-to-weight ratio is %.2f (<= 1). This rocket cannot ' ...
             'lift off vertically under its own thrust.'], thrustToWeight);
end

% FIX: landing-capability check, now that settings.g is available.
% If LandingThrust can't even overcome EmptyMass*g, no suicide-burn
% timing can save the landing - this is a design failure the user
% should know about before running the sim, not just an "impact
% velocity was high" surprise afterward.
if isfield(rocket,'LandingFuelMass') && rocket.LandingFuelMass > 0
    landingTWR = rocket.LandingThrust / (rocket.EmptyMass * settings.g);
    if landingTWR <= 1
        warning(['Landing thrust-to-weight ratio is %.2f (<= 1). The landing ' ...
                 'engine cannot decelerate the rocket regardless of ignition ' ...
                 'timing - expect a hard landing / crash.'], landingTWR);
    end
end

%% Atmosphere Module

disp(' ')
disp('===============================================')
disp('Atmosphere Module')
disp('===============================================')

altitude = input('Enter Launch Altitude (m): ');

atm = isaAtmosphere(altitude);   % isaAtmosphere.m now validates altitude itself
                                  % (errors on negative, warns above 20 km)

disp(' ')
disp('Atmospheric Conditions')
disp('----------------------------')

fprintf('Temperature          : %.2f K\n', atm.Temperature);
fprintf('Pressure             : %.2f Pa\n', atm.Pressure);
fprintf('Density              : %.4f kg/m^3\n', atm.Density);
fprintf('Speed of Sound       : %.2f m/s\n', atm.SpeedOfSound);
fprintf('Dynamic Viscosity    : %.6e Pa.s\n', atm.DynamicViscosity);
fprintf('Kinematic Viscosity  : %.6e m^2/s\n', atm.KinematicViscosity);

%% Aerodynamics Module
% NOTE: this is a standalone demonstration calculation at a single,
% manually entered velocity. It is NOT connected to the flight
% simulation below - simulateFlight computes its own velocity history
% starting from rest. This block exists to show the drag/Reynolds
% functions working in isolation.

disp(' ')
disp('===============================================')
disp('Aerodynamics Module')
disp('===============================================')

velocity = input('Enter Rocket Velocity (m/s): ');

drag = dragForce( ...
    atm.Density, ...
    velocity, ...
    rocket.Cd, ...
    rocket.ReferenceArea);

Re = reynoldsNumber( ...
    atm.Density, ...
    velocity, ...
    rocket.Length, ...
    atm.DynamicViscosity);

disp(' ')
disp('Aerodynamic Results')
disp('----------------------------')

fprintf('Velocity      : %.2f m/s\n', velocity);
fprintf('Drag Force    : %.3f N\n', drag);
fprintf('Reynolds Number : %.3e\n', Re);

fprintf('\n');
disp('Simulation Settings')
disp('----------------------------')

fprintf('Time Step      : %.3f s\n', settings.dt);
fprintf('Maximum Time   : %.1f s\n', settings.maxTime);
fprintf('Gravity        : %.2f m/s^2\n', settings.g);

%% Flight Simulation

results = simulateFlight(rocket, settings, altitude);   % FIX: launch altitude now actually reaches the simulation
plotFlightResults(results);
events = flightEvents(results,rocket);



disp(' ')
disp('======================================')
disp('FLIGHT EVENTS')
disp('======================================')

fprintf('Burnout Time        : %.2f s\n',events.BurnoutTime);
fprintf('Burnout Altitude    : %.2f m\n',events.BurnoutAltitude);
fprintf('Burnout Velocity    : %.2f m/s\n',events.BurnoutVelocity);

fprintf('\n');

fprintf('Apogee Time         : %.2f s\n',events.ApogeeTime);
fprintf('Maximum Altitude    : %.2f m\n',events.ApogeeAltitude);

fprintf('\n');

fprintf('Maximum Velocity    : %.2f m/s\n',events.MaxVelocity);
fprintf('Maximum Acceleration: %.2f m/s^2\n',events.MaxAcceleration);

fprintf('\n');

fprintf('Landing Time        : %.2f s\n',events.LandingTime);
fprintf('Impact Velocity : %.2f m/s (Downward)\n',abs(events.ImpactVelocity));

fprintf('Maximum Mach Number : %.2f\n', events.MaxMach);
fprintf('Reached At          : %.2f s\n', events.MaxMachTime);
% FIX: removed duplicate repeat of the two lines above

fprintf('\n');
disp('======================================')
disp('PROPULSIVE LANDING / REUSABILITY')
disp('======================================')

if events.LandingBurnIgnited
    fprintf('Landing Burn Ignited At : %.2f s\n', events.LandingBurnIgnitionTime);
    fprintf('Ignition Altitude       : %.2f m\n', events.LandingBurnIgnitionAltitude);
else
    disp('Landing Burn Ignited At : never (fuel exhausted, no descent, or landing T/W <= 1)');
end

fprintf('Landing Fuel Used       : %.4f kg\n', events.LandingFuelUsed);
fprintf('Landing Fuel Remaining  : %.4f kg\n', events.LandingFuelRemaining);
fprintf('Landing Outcome         : %s\n', events.LandingOutcome);

%% Automated Mission Report
% Packages everything already computed above into mission.m's expected
% struct shape and writes a Markdown report - reuses runMission.m's
% report format without requiring this interactive script to be
% refactored to call runMission.m itself (that would duplicate the
% simulateFlight/flightEvents calls above, running the sim twice).

mission.rocket = rocket;
mission.settings = settings;
mission.launchAltitude = altitude;
mission.results = results;
mission.events = events;
mission.Cp = Cp;
mission.CnAlpha = CnAlpha;
mission.staticMargin = margin;
mission.stabilityStatus = stabilityStatus;

reportPath = generateMissionReport(mission, 'mission_report.md');

fprintf('\n');
fprintf('Mission report written to: %s\n', reportPath);
