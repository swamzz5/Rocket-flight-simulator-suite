function mission = runMission(rocket, settings, launchAltitude)

%==========================================================
% Run a full, non-interactive mission
% Rocket Design & Flight Simulation Suite
%
% This is the callable core the interactive RocketFlightSimulator.m
% script is built on top of. It exists so that tests/, validation/,
% and reports/ can run a complete rocket+settings configuration
% programmatically, without any input() prompts in the way.
%
% Inputs:
%   rocket         - rocket definition struct (see database/rocketDatabase.m)
%   settings       - simulation settings struct (dt, maxTime, g)
%   launchAltitude - launch site elevation above sea level (m), optional (default 0)
%
% Output:
%   mission - struct containing:
%     .rocket, .settings, .launchAltitude  - the inputs, for reference
%     .results         - full time-history from simulateFlight
%     .events          - flightEvents summary (apogee, burnout, landing, etc.)
%     .Cp, .CnAlpha    - Barrowman center of pressure / normal force slope
%     .staticMargin    - static margin in calibers
%     .stabilityStatus - 'STABLE' / 'MARGINAL' / 'UNSTABLE'
%==========================================================

if nargin < 3
    launchAltitude = 0;
end

mission.rocket = rocket;
mission.settings = settings;
mission.launchAltitude = launchAltitude;

mission.results = simulateFlight(rocket, settings, launchAltitude);
mission.events = flightEvents(mission.results, rocket);

[mission.Cp, mission.CnAlpha] = barrowmanCP(rocket);
[mission.staticMargin, mission.stabilityStatus] = staticMargin(mission.Cp, rocket.CG, rocket.Diameter);

end
