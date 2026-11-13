function atm = isaAtmosphere(altitude)

%==========================================================
% International Standard Atmosphere (ISA)
% Rocket Design & Flight Simulation Suite v1.1
%
% Inputs:
%   altitude (m)
%
% Outputs:
%   Temperature (K)
%   Pressure (Pa)
%   Density (kg/m^3)
%   Speed of Sound (m/s)
%   Dynamic Viscosity (Pa.s)
%   Kinematic Viscosity (m^2/s)
%
% VALIDITY RANGE:
%   0 - 11,000 m  : ISA troposphere (linear lapse rate). Fully valid.
%   11,000 - 20,000 m : ISA lower stratosphere (isothermal layer).
%                       Fully valid.
%   > 20,000 m : NOT physically valid. Real ISA temperature begins
%                rising again above ~20 km (ozone heating), but this
%                model keeps extrapolating the isothermal formula
%                indefinitely. Results above 20 km are an
%                EXTRAPOLATION, not a validated atmosphere model, and
%                the function issues a warning rather than silently
%                returning them as if trustworthy.
%   < 0 m : Not physical. Errors rather than extrapolating.
%==========================================================

%% Input Validation

if altitude < 0
    error('isaAtmosphere:negativeAltitude', ...
        'Altitude cannot be negative (got %.2f m). Check upstream calculation.', altitude);
end

if altitude > 20000
    warning('isaAtmosphere:extrapolation', ...
        ['Altitude %.1f m exceeds this model''s validated range (0-20,000 m). ' ...
         'Returning an EXTRAPOLATED isothermal-layer estimate, not a validated ' ...
         'ISA value. Do not trust these results above 20 km without a proper ' ...
         'stratosphere/mesosphere model.'], altitude);
end

%% Constants

T0 = 288.15;          % Sea-level temperature (K)
P0 = 101325;          % Sea-level pressure (Pa)
L  = 0.0065;          % Temperature lapse rate (K/m)

R  = 287.05;          % Gas constant (J/kg.K)
g  = 9.80665;         % Gravity (m/s^2)
gamma = 1.4;          % Ratio of specific heats

%% Temperature

if altitude <= 11000

    T = T0 - L*altitude;

    P = P0 * (T/T0)^(g/(R*L));

else

    T = 216.65;

    P11 = P0*(216.65/T0)^(g/(R*L));

    P = P11*exp(-g*(altitude-11000)/(R*T));

end

%% Density

rho = P/(R*T);

%% Speed of Sound

a = sqrt(gamma*R*T);

%% Dynamic Viscosity (Sutherland's Law)

mu0 = 1.716e-5;      % Reference viscosity
Tref = 273.15;       % Reference temperature
S = 110.4;           % Sutherland constant

mu = mu0*(T/Tref)^(3/2)*(Tref+S)/(T+S);

%% Kinematic Viscosity

nu = mu/rho;

%% Store Results

atm.Temperature = T;
atm.Pressure = P;
atm.Density = rho;
atm.SpeedOfSound = a;
atm.DynamicViscosity = mu;
atm.KinematicViscosity = nu;

end