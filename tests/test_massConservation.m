function results = test_massConservation()

%==========================================================
% Test: propulsion/massModel.m conserves mass sensibly:
%   - mass at t=0 equals EmptyMass + FuelMass
%   - mass decreases monotonically during the burn
%   - mass at/after BurnTime equals exactly EmptyMass
%   - mass is never negative at any sampled time
%==========================================================

fprintf('\n-- test_massConservation --\n');
results = [];

rocket.EmptyMass = 8.5;
rocket.FuelMass = 3.0;
rocket.BurnTime = 6.0;

m0 = massModel(0, rocket);
results(end+1) = assertClose(m0, rocket.EmptyMass + rocket.FuelMass, 1e-9, 'mass at t=0');

mBurnout = massModel(rocket.BurnTime, rocket);
results(end+1) = assertClose(mBurnout, rocket.EmptyMass, 1e-9, 'mass exactly at burnout');

mAfter = massModel(rocket.BurnTime + 10, rocket);
results(end+1) = assertClose(mAfter, rocket.EmptyMass, 1e-9, 'mass well after burnout');

% Monotonic decrease during burn, and never negative
tSamples = linspace(0, rocket.BurnTime, 50);
mSamples = arrayfun(@(t) massModel(t, rocket), tSamples);

monotonic = all(diff(mSamples) <= 1e-9);
noneNegative = all(mSamples >= 0);

fprintf('  [%s] mass strictly non-increasing during burn\n', tern(monotonic,'PASS','FAIL'));
fprintf('  [%s] mass never negative during burn\n', tern(noneNegative,'PASS','FAIL'));
results(end+1) = monotonic;
results(end+1) = noneNegative;

end

function s = tern(cond, a, b)
if cond
    s = a;
else
    s = b;
end
end
