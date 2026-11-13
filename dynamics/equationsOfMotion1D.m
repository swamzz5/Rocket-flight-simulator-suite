function acceleration = equationsOfMotion1D(thrust, drag, mass, g)

%==========================================================
% 1D Vertical Equations of Motion
% Rocket Design & Flight Simulation Suite
%
% Governing equation:
%   m*Vdot = T - D - m*g
%
% This is the 1D baseline equations-of-motion module. It is
% deliberately isolated from the integration loop (see
% simulation/simulateFlight.m) so that upgrading to a 2D or 3D
% flight-dynamics model later means adding a new function here
% (e.g. equationsOfMotion2D.m) rather than rewriting the simulation
% loop itself.
%
% Inputs:
%   thrust (N)  - propulsive force, positive = upward
%   drag   (N)  - aerodynamic drag force, signed opposite to velocity
%                 (caller is responsible for the sign convention -
%                 see dragForce.m / simulateFlight.m)
%   mass   (kg) - current rocket mass (must be > 0)
%   g      (m/s^2) - local gravitational acceleration
%
% Output:
%   acceleration (m/s^2) - net vertical acceleration, positive = upward
%
% Assumptions:
%   - Vertical (1D) flight only: no horizontal motion, no wind, no
%     angle of attack, rocket treated as a point mass.
%   - Weight acts downward as mass*g using the g passed in (caller
%     supplies this so there is a single source of truth - see
%     settings.g in config/simSettings.m).
%==========================================================

if mass <= 0
    error('equationsOfMotion1D:invalidMass', ...
        'Mass must be positive (got %.4f kg). Check mass model / burnout handling.', mass);
end

weight = mass * g;

netForce = thrust + drag - weight;

acceleration = netForce / mass;

end
