function Cd = dragCoefficient(mach)

%==========================================================
% Drag Coefficient Model
% Version 0.3
% Developed by Swayam Rout
%==========================================================

if mach < 0.3

    Cd = 0.40;

elseif mach < 0.8

    Cd = 0.42;

elseif mach < 1.0

    Cd = 0.50;

elseif mach < 1.2

    Cd = 0.65;

elseif mach < 2.0

    Cd = 0.55;

else

    Cd = 0.45;

end

end  