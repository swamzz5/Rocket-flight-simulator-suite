function results = test_machAndReynolds()

%==========================================================
% Test: aerodynamics/machNumber.m and aerodynamics/reynoldsNumber.m
% against hand calculations.
%   M = V/a:  V=340.29, a=340.29 -> M=1.0 (speed of sound at sea level)
%   Re = rho*V*L/mu: rho=1.225, V=100, L=2.5, mu=1.789e-5
%     Re = 1.225*100*2.5/1.789e-5 = 1.7118e7
%==========================================================

fprintf('\n-- test_machAndReynolds --\n');
results = [];

M = machNumber(340.29, 340.29);
results(end+1) = assertClose(M, 1.0, 1e-6, 'M=1 at sea-level speed of sound');

M2 = machNumber(-170.145, 340.29);
results(end+1) = assertClose(M2, 0.5, 1e-6, 'Mach uses abs(velocity), sign-independent');

Re = reynoldsNumber(1.225, 100, 2.5, 1.789e-5);
results(end+1) = assertClose(Re, 1.7118e7, 2e4, 'hand-calc Reynolds case');

end
