function [marginCalibers, status] = staticMargin(Cp, Cg, diameter)

%==========================================================
% Static Margin Calculation
% Rocket Design & Flight Simulation Suite
%
% marginCalibers = (Cp - Cg) / diameter
%
% Inputs:
%   Cp        - center of pressure, from nose tip (m)
%   Cg        - center of gravity, from nose tip (m)
%   diameter  - body diameter, used as one "caliber" (m)
%
% Outputs:
%   marginCalibers - static margin in calibers
%   status         - 'STABLE', 'MARGINAL', or 'UNSTABLE'
%
% Convention: distances measured from the nose tip, increasing aft.
% A positive margin means Cp is aft of Cg, which is the stable sense
% for a nose-first, fin-trailing rocket.
%
% CLASSIFICATION (a common amateur-rocketry rule of thumb, not a hard
% physical law - real stability also depends on launch rail length,
% wind, and thrust misalignment):
%   margin <= 0      : UNSTABLE
%   0 < margin < 1    : MARGINAL
%   margin >= 1        : STABLE
%==========================================================

if diameter <= 0
    error('staticMargin:invalidDiameter', 'Diameter must be positive.');
end

marginCalibers = (Cp - Cg) / diameter;

if marginCalibers <= 0
    status = 'UNSTABLE';
elseif marginCalibers < 1
    status = 'MARGINAL';
else
    status = 'STABLE';
end

end
