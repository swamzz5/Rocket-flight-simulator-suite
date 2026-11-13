function events = flightEvents(results, rocket)

%==========================================================
% Flight Events Analysis
% Version 1.0
% Developed by Swayam Rout
%
% Detects important flight events from simulation results
%==========================================================

%% Burnout

events.BurnoutTime = rocket.BurnTime;

burnIndex = find(results.time >= rocket.BurnTime,1);

events.BurnoutAltitude = results.altitude(burnIndex);
events.BurnoutVelocity = results.velocity(burnIndex);

%% Apogee

[events.ApogeeAltitude, apogeeIndex] = max(results.altitude);

events.ApogeeTime = results.time(apogeeIndex);
events.ApogeeVelocity = results.velocity(apogeeIndex);

%% Maximum Velocity

[events.MaxVelocity, velIndex] = max(results.velocity);

events.MaxVelocityTime = results.time(velIndex);

%% Maximum Mach Number

[events.MaxMach, machIndex] = max(results.mach);

events.MaxMachTime = results.time(machIndex);

%% Maximum Acceleration

[events.MaxAcceleration, accIndex] = max(results.acceleration);

events.MaxAccelerationTime = results.time(accIndex);

%% Landing

events.LandingTime = results.time(end);
events.ImpactVelocity = results.velocity(end);

%% Flight Duration

events.FlightDuration = results.time(end);

%% Maximum Drag Coefficient

events.MaxCd = max(results.cd);

%% Propulsive Landing (Suicide Burn)

ignitionIndex = find(results.landingBurnActive, 1);

if isempty(ignitionIndex)
    events.LandingBurnIgnited = false;
    events.LandingBurnIgnitionTime = NaN;
    events.LandingBurnIgnitionAltitude = NaN;
else
    events.LandingBurnIgnited = true;
    events.LandingBurnIgnitionTime = results.time(ignitionIndex);
    events.LandingBurnIgnitionAltitude = results.altitude(ignitionIndex);
end

events.LandingFuelRemaining = results.landingFuelRemaining(end);
events.LandingFuelUsed = rocket.LandingFuelMass - events.LandingFuelRemaining;

% Classification threshold: a common rule-of-thumb "survivable/reusable
% touchdown" cutoff, not a rigorous structural-loads calculation.
softLandingThreshold = 5;   % m/s

if abs(events.ImpactVelocity) <= softLandingThreshold
    events.LandingOutcome = 'SOFT LANDING (REUSABLE)';
else
    events.LandingOutcome = 'HARD LANDING (CRASH)';
end

end