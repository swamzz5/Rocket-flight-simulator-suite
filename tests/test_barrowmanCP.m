function results = test_barrowmanCP()

%==========================================================
% Test: stability/barrowmanCP.m against an independently computed
% reference value. This exact geometry/result was verified via a
% standalone Python re-implementation before being adopted as the
% Estes Alpha III database entry (see project history) - Cp=0.2468 m,
% CnAlpha=15.826.
%==========================================================

fprintf('\n-- test_barrowmanCP --\n');
results = [];

rocket.NoseLength = 0.080;
rocket.NoseType = 'ogive';
rocket.Diameter = 0.024;
rocket.FinCount = 3;
rocket.FinRootChord = 0.050;
rocket.FinTipChord = 0.020;
rocket.FinSpan = 0.035;
rocket.FinSweepLength = 0.030;
rocket.FinPosition = 0.255;

[Cp, CnAlpha] = barrowmanCP(rocket);

results(end+1) = assertClose(Cp, 0.2468, 1e-3, 'Cp matches independent Python reference');
results(end+1) = assertClose(CnAlpha, 15.826, 1e-2, 'CnAlpha matches independent Python reference');

% Sanity check: CP must lie between the nose tip and the rocket's
% total length-ish range (fin position + some margin) - a CP outside
% the physical vehicle would indicate a sign/unit error.
physicallyPlausible = (Cp > 0) && (Cp < 0.4);
fprintf('  [%s] Cp lies within a physically plausible range for this rocket\n', ...
    maybeStr(physicallyPlausible));
results(end+1) = physicallyPlausible;

end

function s = maybeStr(cond)
if cond
    s = 'PASS';
else
    s = 'FAIL';
end
end
