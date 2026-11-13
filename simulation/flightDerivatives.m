function dstate = flightDerivatives(t, state, rocket, settings, launchAltitude)

%==========================================================
% Flight State Derivatives
% Rocket Design & Flight Simulation Suite
%
% Returns d(state)/dt for the 1D vertical flight state, for use by
% any integrator (RK4, ode45, etc.) that needs to evaluate the
% dynamics at an arbitrary (t, state) pair - including the
% intermediate half-step/full-step evaluations RK4 requires, which
% simulateFlight.m's Euler-Cromer loop never needed to do.
%
% NOTE: does not model propulsive landing (suicide burn) - this
% covers ascent + unpowered descent only, so it's a clean apples-to-
% apples comparison against the ascent/descent physics in
% simulateFlight.m, without the extra event-triggered complexity of
% the landing burn muddying an integration-method comparison.
%
% Inputs:
%   t              - current time (s)
%   state          - [altitude (m); velocity (m/s)]
%   rocket         - rocket definition struct
%   settings       - settings struct (needs settings.g)
%   launchAltitude - launch site elevation above sea level (m)
%
% Output:
%   dstate - [d(altitude)/dt; d(velocity)/dt] = [velocity; acceleration]
%==========================================================

altitude = state(1);
velocity = state(2);

atm = isaAtmosphere(max(launchAltitude + altitude, 0));

mass = massModel(t, rocket);
thrust = thrustModel(t, rocket);

mach = machNumber(velocity, atm.SpeedOfSound);
Cd = dragCoefficient(mach);

drag = dragForce(atm.Density, abs(velocity), Cd, rocket.ReferenceArea);
if velocity > 0
    drag = -drag;
end

acceleration = equationsOfMotion1D(thrust, drag, mass, settings.g);

dstate = [velocity; acceleration];

end
