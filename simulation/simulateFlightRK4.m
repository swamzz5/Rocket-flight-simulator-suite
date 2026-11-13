function results = simulateFlightRK4(rocket, settings, launchAltitude)

%==========================================================
% Rocket Flight Simulator - RK4 Variant
% Rocket Design & Flight Simulation Suite
%
% Same physics as simulation/simulateFlight.m (ascent + unpowered
% descent), but integrated with classical 4th-order Runge-Kutta
% instead of semi-implicit Euler (Euler-Cromer). Exists specifically
% to let validation/integratorComparison.m and
% validation/convergenceStudy.m quantify how much the integration
% method itself affects results like apogee and impact velocity, as
% opposed to it being a stylistic alternative for everyday use.
%
% NOTE: does not model propulsive landing (suicide burn) - see
% flightDerivatives.m for why. Use simulateFlight.m for the full
% feature set; use this specifically for integrator comparison.
%
% Inputs / Outputs: same convention as simulateFlight.m, but the
% results struct only contains time, altitude, velocity, and mach
% (the quantities the validation studies actually compare).
%==========================================================

if nargin < 3
    launchAltitude = 0;
end

dt = settings.dt;
t = 0;
state = [0; 0];   % [altitude; velocity]

timeHistory = [];
altitudeHistory = [];
velocityHistory = [];
machHistory = [];

while t <= settings.maxTime

    k1 = flightDerivatives(t,        state,            rocket, settings, launchAltitude);
    k2 = flightDerivatives(t + dt/2, state + dt/2*k1,   rocket, settings, launchAltitude);
    k3 = flightDerivatives(t + dt/2, state + dt/2*k2,   rocket, settings, launchAltitude);
    k4 = flightDerivatives(t + dt,   state + dt*k3,     rocket, settings, launchAltitude);

    state = state + (dt/6)*(k1 + 2*k2 + 2*k3 + k4);

    if state(1) < 0
        state(1) = 0;
    end

    atm = isaAtmosphere(max(launchAltitude + state(1), 0));
    mach = machNumber(state(2), atm.SpeedOfSound);

    timeHistory(end+1) = t;
    altitudeHistory(end+1) = state(1);
    velocityHistory(end+1) = state(2);
    machHistory(end+1) = mach;

    if state(1) <= 0 && t > rocket.BurnTime && state(2) < 0
        break
    end

    t = t + dt;

end

results.time = timeHistory;
results.altitude = altitudeHistory;
results.velocity = velocityHistory;
results.mach = machHistory;

end
