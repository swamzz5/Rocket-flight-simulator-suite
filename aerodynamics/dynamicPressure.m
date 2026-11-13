function q = dynamicPressure(rho, velocity)

%==========================================================
% Dynamic Pressure Calculator
% Rocket Design & Flight Simulation Suite v1.0
%
% q = 1/2 * rho * V^2
%==========================================================

q = 0.5 * rho * velocity.^2;

end