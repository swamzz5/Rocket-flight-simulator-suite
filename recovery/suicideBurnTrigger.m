function ignite = suicideBurnTrigger(altitude, velocity, mass, landingThrust, g, fuelRemaining)

%==========================================================
% Suicide Burn Ignition Trigger
% Rocket Design & Flight Simulation Suite
%
% Decides whether to ignite the landing engine RIGHT NOW, using the
% idealized "suicide burn" condition: ignite at the exact moment the
% remaining altitude equals the stopping distance achievable under
% maximum available deceleration.
%
% Governing equation (constant-deceleration kinematics):
%   stoppingDistance = velocity^2 / (2*decel)
%   decel = (landingThrust/mass) - g
%   ignite = (altitude <= stoppingDistance)
%
% Inputs:
%   altitude       - current altitude above ground (m), must be >= 0
%   velocity       - current vertical velocity (m/s), negative = falling
%   mass           - current rocket mass (kg)
%   landingThrust  - thrust available for the landing burn (N)
%   g              - local gravitational acceleration (m/s^2)
%   fuelRemaining  - landing propellant remaining (kg)
%
% Output:
%   ignite - true/false
%
% ASSUMPTIONS / LIMITATIONS:
%   - IDEALIZED: instant thrust on/off, no throttle spool-up lag, no
%     guidance/sensor delay, no margin/safety factor. A real vehicle
%     would ignite earlier than this to cover those uncertainties -
%     this trigger represents a best-case, not a flight-safe margin.
%   - This function only decides IGNITION timing. It does not decide
%     when to cut thrust - the caller (simulation/simulateFlight.m) is
%     responsible for terminating the burn once velocity reaches zero,
%     otherwise the burn overshoots into an upward hop as mass (and
%     therefore thrust/mass) decreases during the burn.
%   - If landingThrust/mass <= g (decel <= 0), the vehicle physically
%     cannot arrest its descent no matter when it ignites - this
%     function correctly never fires in that case, but the caller is
%     responsible for warning the user that this is a design failure,
%     not a timing failure.
%==========================================================

if velocity >= 0 || fuelRemaining <= 0
    ignite = false;
    return
end

decel = (landingThrust/mass) - g;

if decel <= 0
    ignite = false;
    return
end

stoppingDistance = velocity^2 / (2*decel);

ignite = altitude <= stoppingDistance;

end
