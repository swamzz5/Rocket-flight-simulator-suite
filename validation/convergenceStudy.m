function convergenceStudy(rocket, settings, launchAltitude)

%==========================================================
% Timestep Convergence Study
% Rocket Design & Flight Simulation Suite
%
% Runs the same rocket/settings configuration at dt = 0.1, 0.01, and
% 0.001 s and reports how apogee, max velocity, max Mach, and impact
% velocity change as the timestep shrinks. This is the standard way
% to build confidence that a chosen timestep (e.g. the 0.01 s default
% in config/simSettings.m) is fine enough that results have actually
% converged, rather than being an artifact of a too-coarse timestep.
%
% Usage:
%   rocket = rocketDatabase(); rocket = rocket(3);  % Sounding Rocket
%   settings = simSettings();
%   convergenceStudy(rocket, settings, 0)
%==========================================================

if nargin < 3
    launchAltitude = 0;
end

dtList = [0.1, 0.01, 0.001];

fprintf('\n');
disp('======================================')
disp('Timestep Convergence Study')
disp('======================================')
fprintf('Rocket: %s\n\n', rocket.Name);

fprintf('%10s | %12s | %12s | %10s | %14s\n', ...
    'dt (s)', 'Apogee (m)', 'MaxVel (m/s)', 'MaxMach', 'ImpactV (m/s)');
disp(repmat('-',1,70))

results_all = cell(length(dtList),1);

for i = 1:length(dtList)
    s = settings;
    s.dt = dtList(i);

    r = simulateFlight(rocket, s, launchAltitude);
    results_all{i} = r;

    apogee = max(r.altitude);
    maxVel = max(r.velocity);
    maxMach = max(r.mach);
    impactV = r.velocity(end);

    fprintf('%10.4f | %12.3f | %12.3f | %10.3f | %14.4f\n', ...
        dtList(i), apogee, maxVel, maxMach, impactV);
end

% Reference the finest-timestep run as the "converged" estimate and
% report how far the coarser runs deviate from it.
disp(' ')
disp('Deviation from finest timestep (dt = 0.001 s), as a sanity check')
disp('that the default dt is not introducing meaningful error:')
disp(repmat('-',1,70))

refApogee = max(results_all{end}.altitude);

for i = 1:length(dtList)-1
    apogee_i = max(results_all{i}.altitude);
    pctError = 100*abs(apogee_i - refApogee)/refApogee;
    fprintf('dt = %.4f s : apogee error = %.3f m (%.3f %%)\n', ...
        dtList(i), apogee_i-refApogee, pctError);
end

end
