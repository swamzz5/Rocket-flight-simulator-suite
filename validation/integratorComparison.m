function integratorComparison(rocket, settings, launchAltitude)

%==========================================================
% Integrator Comparison: Euler-Cromer vs RK4
% Rocket Design & Flight Simulation Suite
%
% Runs the SAME rocket/settings/timestep through both integrators and
% reports the difference in apogee and impact velocity. Demonstrates
% that a higher-order integrator (RK4) is more accurate than the
% simpler Euler-Cromer scheme at the same timestep - useful evidence
% when deciding whether the extra complexity of RK4 is worth adopting
% for production use versus keeping the simpler Euler-Cromer method.
%
% NOTE: simulateFlightRK4.m models ascent + unpowered descent only (no
% propulsive landing), so this comparison necessarily excludes the
% landing-burn phase to keep it an apples-to-apples comparison of the
% integration method itself.
%
% Usage:
%   rocket = rocketDatabase(); rocket = rocket(3);
%   settings = simSettings();
%   integratorComparison(rocket, settings, 0)
%==========================================================

if nargin < 3
    launchAltitude = 0;
end

resultsEuler = simulateFlight(rocket, settings, launchAltitude);
resultsRK4 = simulateFlightRK4(rocket, settings, launchAltitude);

apogeeEuler = max(resultsEuler.altitude);
apogeeRK4 = max(resultsRK4.altitude);

impactEuler = resultsEuler.velocity(end);
impactRK4 = resultsRK4.velocity(end);

fprintf('\n');
disp('======================================')
disp('Integrator Comparison: Euler-Cromer vs RK4')
disp('======================================')
fprintf('Rocket: %s,  dt = %.4f s\n\n', rocket.Name, settings.dt);

fprintf('%20s | %14s | %14s\n', '', 'Euler-Cromer', 'RK4');
disp(repmat('-',1,55))
fprintf('%20s | %14.3f | %14.3f\n', 'Apogee (m)', apogeeEuler, apogeeRK4);
fprintf('%20s | %14.4f | %14.4f\n', 'Impact Velocity (m/s)', impactEuler, impactRK4);

pctDiff = 100*abs(apogeeEuler-apogeeRK4)/apogeeRK4;
fprintf('\nApogee difference: %.3f m (%.3f %% of RK4 value)\n', ...
    apogeeEuler-apogeeRK4, pctDiff);

if pctDiff > 1
    disp('NOTE: >1% difference at this timestep - consider a finer dt')
    disp('or switching to RK4 if apogee precision matters for your use case.')
else
    disp('NOTE: difference is small at this timestep - Euler-Cromer is an')
    disp('acceptable choice here, though RK4 remains more accurate per step.')
end

end
