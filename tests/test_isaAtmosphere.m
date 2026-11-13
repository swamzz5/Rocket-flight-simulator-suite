function results = test_isaAtmosphere()

%==========================================================
% Test: atmosphere/isaAtmosphere.m against standard ISA reference
% values (widely published, e.g. NASA/ICAO standard atmosphere
% tables). Sea-level and 11,000 m (tropopause) are the two "exact by
% construction" checkpoints for this model's own formulas; 5,000 m
% checks the linear troposphere formula somewhere in the middle.
%==========================================================

fprintf('\n-- test_isaAtmosphere --\n');
results = [];

atm0 = isaAtmosphere(0);
results(end+1) = assertClose(atm0.Temperature, 288.15, 0.01, 'T at 0 m');
results(end+1) = assertClose(atm0.Pressure, 101325, 1, 'P at 0 m');
results(end+1) = assertClose(atm0.Density, 1.225, 0.001, 'rho at 0 m');

atm5000 = isaAtmosphere(5000);
results(end+1) = assertClose(atm5000.Temperature, 255.65, 0.01, 'T at 5000 m');
% Published ISA reference pressure at 5000 m ~54048 Pa
results(end+1) = assertClose(atm5000.Pressure, 54048, 100, 'P at 5000 m');

atm11000 = isaAtmosphere(11000);
results(end+1) = assertClose(atm11000.Temperature, 216.65, 0.01, 'T at 11000 m (tropopause)');

end
