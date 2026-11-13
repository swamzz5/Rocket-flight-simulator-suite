function thrust = thrustModel(time, rocket)
%==========================================================
% Returns rocket thrust at a given time
%==========================================================

if time <= rocket.BurnTime
    thrust = rocket.MaxThrust;
else
    thrust = 0;
end

end