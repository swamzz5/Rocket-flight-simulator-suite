function runAllTests()

%==========================================================
% Automated Test Suite Runner
% Rocket Design & Flight Simulation Suite
%
% Runs every test_*.m function in this folder and prints a final
% pass/fail summary. This is what makes the project's correctness
% claims checkable by someone other than the author, rather than
% "trust me, I ran it and it looked right."
%
% Usage (from the project root, with the whole folder tree on path):
%   runAllTests()
%==========================================================

fprintf('\n');
disp('==========================================================')
disp(' Rocket Design & Flight Simulation Suite - Test Suite')
disp('==========================================================')

testFunctions = { ...
    @test_isaAtmosphere, ...
    @test_dragForce, ...
    @test_machAndReynolds, ...
    @test_massConservation, ...
    @test_barrowmanCP, ...
    @test_fullMission ...
    };

allResults = [];

for i = 1:length(testFunctions)
    r = testFunctions{i}();
    allResults = [allResults, r]; %#ok<AGROW>
end

nPass = sum(allResults);
nTotal = length(allResults);

fprintf('\n');
disp('==========================================================')
fprintf('SUMMARY: %d / %d checks passed\n', nPass, nTotal);
disp('==========================================================')

if nPass < nTotal
    fprintf(2, 'ONE OR MORE TESTS FAILED - see [FAIL] lines above.\n');
else
    disp('All tests passed.')
end

end
