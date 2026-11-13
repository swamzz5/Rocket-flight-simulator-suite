function [Cp, CnAlpha] = barrowmanCP(rocket)

%==========================================================
% Barrowman Center-of-Pressure Calculation
% Rocket Design & Flight Simulation Suite
%
% Computes the total center of pressure location and normal-force-
% coefficient slope for a nose + fin configuration using the
% Barrowman method (component build-up).
%
% Inputs (all fields of the `rocket` struct, distances in meters):
%   rocket.NoseLength      - nose cone length (m)
%   rocket.NoseType        - 'ogive' or 'conical'
%   rocket.Diameter        - body diameter at the fins (m)
%   rocket.FinCount        - number of fins, N (integer >= 3 typical)
%   rocket.FinRootChord    - fin root chord, Cr (m)
%   rocket.FinTipChord     - fin tip chord, Ct (m)
%   rocket.FinSpan         - fin semispan, s (m) - root to tip height
%   rocket.FinSweepLength  - axial sweep length, l (m) - distance from
%                            root leading edge to tip leading edge
%   rocket.FinPosition     - distance from nose tip to fin root
%                            leading edge (m)
%
% Outputs:
%   Cp       - total center of pressure, measured from the nose tip (m)
%   CnAlpha  - total normal-force-coefficient slope (per radian)
%
% GOVERNING EQUATIONS
%
%   Nose:      CnAlpha_nose = 2
%              Cp_nose = k * NoseLength
%                where k = 0.466 (ogive) or 0.666 (conical)
%
%   Fins:      Kfb = 1 + r/(r+s)                  [body interference]
%              CnAlpha_fins = Kfb * (4*N*(s/d)^2) / ...
%                              (1 + sqrt(1+(2*l/(Cr+Ct))^2))
%              Xf_bar = (l/3)*(Cr+2*Ct)/(Cr+Ct) + ...
%                       (1/6)*[(Cr+Ct) - (Cr*Ct)/(Cr+Ct)]
%              Cp_fins = FinPosition + Xf_bar
%
%   Combined:  CnAlpha = CnAlpha_nose + CnAlpha_fins
%              Cp = (CnAlpha_nose*Cp_nose + CnAlpha_fins*Cp_fins) / CnAlpha
%
% ASSUMPTIONS / LIMITATIONS (read before trusting the output):
%   - Subsonic, small-angle-of-attack theory. Does NOT capture the
%     aft CP shift real rockets experience approaching Mach 1 - treat
%     this as a low-Mach estimate, not valid near/above this project's
%     simulated peak Mach (~1.35 for the Sounding Rocket case).
%   - Thin flat-plate fins: no fin thickness, airfoil shape, or fin
%     cant/dihedral effects.
%   - No body-alone lift contribution away from the nose.
%   - Assumes N identical, evenly spaced, trapezoidal fins.
%   - No boat-tail / diameter-change effects.
%==========================================================

%% Input Validation

if rocket.NoseLength <= 0
    error('barrowmanCP:invalidNose', 'NoseLength must be positive.');
end
if ~(strcmpi(rocket.NoseType,'ogive') || strcmpi(rocket.NoseType,'conical'))
    error('barrowmanCP:invalidNoseType', ...
        'NoseType must be ''ogive'' or ''conical'' (got ''%s'').', rocket.NoseType);
end
if rocket.FinCount < 3
    error('barrowmanCP:invalidFinCount', ...
        'FinCount must be at least 3 for this build-up (got %d).', rocket.FinCount);
end
if rocket.FinRootChord <= 0 || rocket.FinTipChord < 0 || rocket.FinSpan <= 0
    error('barrowmanCP:invalidFinGeometry', ...
        'Fin root chord and span must be positive; tip chord must be non-negative.');
end

%% Nose Contribution

CnAlpha_nose = 2;

if strcmpi(rocket.NoseType,'ogive')
    k = 0.466;
else
    k = 0.666;
end

Cp_nose = k * rocket.NoseLength;

%% Fin Contribution

N  = rocket.FinCount;
Cr = rocket.FinRootChord;
Ct = rocket.FinTipChord;
s  = rocket.FinSpan;
l  = rocket.FinSweepLength;
d  = rocket.Diameter;
r  = d/2;

Kfb = 1 + r/(r+s);

CnAlpha_fins = Kfb * (4*N*(s/d)^2) / (1 + sqrt(1+(2*l/(Cr+Ct))^2));

Xf_bar = (l/3)*(Cr+2*Ct)/(Cr+Ct) + (1/6)*((Cr+Ct) - (Cr*Ct)/(Cr+Ct));

Cp_fins = rocket.FinPosition + Xf_bar;

%% Combine (Component Build-Up)

CnAlpha = CnAlpha_nose + CnAlpha_fins;

Cp = (CnAlpha_nose*Cp_nose + CnAlpha_fins*Cp_fins) / CnAlpha;

end
