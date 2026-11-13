function Re = reynoldsNumber(rho, velocity, length, mu)

%==========================================================
% Reynolds Number Calculator
% Rocket Design & Flight Simulation Suite v1.0
%
% Re = (rho * V * L) / mu
%
% Inputs:
% rho      - Air density (kg/m^3)
% velocity - Rocket velocity (m/s)
% length   - Rocket length (m)
% mu       - Dynamic viscosity (Pa.s)
%
% Output:
% Re       - Reynolds Number
%==========================================================

Re = (rho * abs(velocity) * length) / mu;

end