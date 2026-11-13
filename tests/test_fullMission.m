function results = test_fullMission()

%==========================================================
% Test: runMission.m end-to-end for the Sounding Rocket database
% entry. Checks physically-required invariants rather than exact
% numbers (exact numbers would be too brittle to small future
% physics tweaks) - this test exists to catch REGRESSIONS (a change
% elsewhere breaking the pipeline), not to re-verify the physics
% itself (see test_barrowmanCP, test_massConservation, etc. for that).
%==========================================================

fprintf('\n-- test_fullMission --\n');
results = [];

rocketDB = rocketDatabase();
rocket = rocketDB(3);   % Sounding Rocket
settings = simSettings();

mission = runMission(rocket, settings, 0);

% Apogee must be positive and the rocket must have actually flown
apogeePositive = max(mission.results.altitude) > 0;
fprintf('  [%s] apogee is positive\n', maybeStr(apogeePositive));
results(end+1) = apogeePositive;

% Mass must never be negative anywhere in the flight
massNeverNegative = all(mission.results.mass >= 0);
fprintf('  [%s] mass never negative during flight\n', maybeStr(massNeverNegative));
results(end+1) = massNeverNegative;

% Landing fuel used must not exceed what was reserved
fuelBudgetRespected = mission.events.LandingFuelUsed <= rocket.LandingFuelMass + 1e-9;
fprintf('  [%s] landing fuel used does not exceed reserved budget\n', ...
    maybeStr(fuelBudgetRespected));
results(end+1) = fuelBudgetRespected;

% Landing fuel remaining must never be negative
fuelNeverNegative = all(mission.results.landingFuelRemaining >= 0);
fprintf('  [%s] landing fuel remaining never negative\n', maybeStr(fuelNeverNegative));
results(end+1) = fuelNeverNegative;

% Static margin must be a finite real number
marginFinite = isfinite(mission.staticMargin);
fprintf('  [%s] static margin is a finite value\n', maybeStr(marginFinite));
results(end+1) = marginFinite;

% Stability status must be one of the three valid strings
validStatus = ismember(mission.stabilityStatus, {'STABLE','MARGINAL','UNSTABLE'});
fprintf('  [%s] stability status is a recognized classification\n', maybeStr(validStatus));
results(end+1) = validStatus;

end

function s = maybeStr(cond)
if cond
    s = 'PASS';
else
    s = 'FAIL';
end
end
