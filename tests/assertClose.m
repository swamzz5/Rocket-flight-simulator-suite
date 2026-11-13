function pass = assertClose(actual, expected, tolerance, testName)

%==========================================================
% Simple tolerance-based assertion for the test suite.
% Prints PASS/FAIL and returns a logical, so runAllTests.m can run
% every test (rather than stopping at the first failure) and report
% a final tally.
%
% Inputs:
%   actual, expected - values to compare
%   tolerance        - absolute tolerance allowed
%   testName         - short description printed with the result
%
% Output:
%   pass - true if |actual-expected| <= tolerance
%==========================================================

err = abs(actual - expected);
pass = err <= tolerance;

if pass
    fprintf('  [PASS] %s (actual=%.6g, expected=%.6g, err=%.3g)\n', ...
        testName, actual, expected, err);
else
    fprintf('  [FAIL] %s (actual=%.6g, expected=%.6g, err=%.3g, tol=%.3g)\n', ...
        testName, actual, expected, err, tolerance);
end

end
