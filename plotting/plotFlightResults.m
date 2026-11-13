function plotFlightResults(results)

%% Altitude
figure('Name','Altitude')
plot(results.time,results.altitude,'LineWidth',2)
grid on
xlabel('Time (s)')
ylabel('Altitude (m)')
title('Altitude vs Time')

%% Velocity
figure('Name','Velocity')
plot(results.time,results.velocity,'LineWidth',2)
grid on
xlabel('Time (s)')
ylabel('Velocity (m/s)')
title('Velocity vs Time')

%% Acceleration
figure('Name','Acceleration')
plot(results.time,results.acceleration,'LineWidth',2)
grid on
xlabel('Time (s)')
ylabel('Acceleration (m/s^2)')
title('Acceleration vs Time')

%% Thrust
figure('Name','Thrust')
plot(results.time,results.thrust,'LineWidth',2)
grid on
xlabel('Time (s)')
ylabel('Thrust (N)')
title('Thrust vs Time')

%% Drag
figure('Name','Drag')
plot(results.time,results.drag,'LineWidth',2)
grid on
xlabel('Time (s)')
ylabel('Drag (N)')
title('Drag vs Time')

%% Mass
figure('Name','Mass')
plot(results.time,results.mass,'LineWidth',2)
grid on
xlabel('Time (s)')
ylabel('Mass (kg)')
title('Mass vs Time')

%% Mach Number  
figure('Name','Mach Number')
plot(results.time,results.mach,'LineWidth',2)
grid on
xlabel('Time (s)')
ylabel('Mach Number')
title('Mach Number vs Time')

%% Drag Coefficient
figure('Name','Drag Coefficient')
plot(results.time, results.cd, 'LineWidth',2)
grid on
xlabel('Time (s)')
ylabel('Drag Coefficient')

title('Drag Coefficient vs Time')

end