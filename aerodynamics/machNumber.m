function M = machNumber(velocity, speedOfSound)

%==========================================================
% Mach Number Calculator
% Rocket Design & Flight Simulation Suite v1.0
%
% M = V / a
%
% Inputs:
%   velocity     - Rocket velocity (m/s)
%   speedOfSound - Local speed of sound (m/s)
%
% Output:
%   M            - Mach number (dimensionless)
%==========================================================

M = abs(velocity) / speedOfSound;

end
