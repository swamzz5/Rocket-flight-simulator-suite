function results = test_dragForce()

%==========================================================
% Test: aerodynamics/dragForce.m against a hand calculation.
% D = 0.5 * rho * V^2 * Cd * A
% rho=1.225, V=100, Cd=0.5, A=0.01
% D = 0.5*1.225*100^2*0.5*0.01 = 30.625 N
%==========================================================

fprintf('\n-- test_dragForce --\n');
results = [];

D = dragForce(1.225, 100, 0.5, 0.01);
results(end+1) = assertClose(D, 30.625, 1e-6, 'hand-calc case');

% Zero velocity should give zero drag
D0 = dragForce(1.225, 0, 0.5, 0.01);
results(end+1) = assertClose(D0, 0, 1e-9, 'zero velocity -> zero drag');

end
