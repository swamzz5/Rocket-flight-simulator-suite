function drag = dragForce(rho, velocity, Cd, area)
%==========================================================
% Calculates aerodynamic drag force
%
% Inputs:
%   rho      - Air density (kg/m^3)
%   velocity - Rocket velocity (m/s)
%   Cd       - Drag coefficient
%   area     - Reference area (m^2)
%
% Output:
%   drag     - Drag force (N)
%==========================================================

drag = 0.5 * rho * velocity^2 * Cd * area;

end