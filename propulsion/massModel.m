function mass = massModel(time, rocket)

%==========================================================
% Rocket Mass Model
% Calculates rocket mass during fuel burn
%==========================================================

initialMass = rocket.EmptyMass + rocket.FuelMass;

if time <= rocket.BurnTime

    fuelRemaining = rocket.FuelMass * ...
        (1 - time/rocket.BurnTime);

    mass = rocket.EmptyMass + fuelRemaining;

else

    mass = rocket.EmptyMass;

end

end