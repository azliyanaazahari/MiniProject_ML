%% Step 1: Define time
% Assuming simulation time is from 0 to 20 seconds (adjust if different)
simTime = linspace(0, 20, length(waterlevel))';

%% Step 2: Output signal
y = waterlevel;

%% Step 3: Define setpoint
setpoint = 10; % Example setpoint

%% Step 4: Calculate performance metrics
stepInfo = stepinfo(y, simTime, setpoint);

disp('Performance Metrics:')
fprintf('Rise Time: %.4f seconds\n', stepInfo.RiseTime);
fprintf('Settling Time: %.4f seconds\n', stepInfo.SettlingTime);
fprintf('Overshoot: %.2f %%\n', stepInfo.Overshoot);
fprintf('Peak Time: %.4f seconds\n', stepInfo.PeakTime);

%% Step 5: Calculate Mean Squared Error (MSE)
error = setpoint - y;
MSE = mean(error.^2);
fprintf('Mean Squared Error (MSE): %.6f\n', MSE);

%% Step 6: Plot
figure;
plot(simTime, y, 'b', 'LineWidth', 2);
hold on;
yline(setpoint, 'r--', 'Setpoint');
xlabel('Time (s)');
ylabel('Water Level');
title('Water Tank PI Response');
legend('Water Level','Setpoint');
grid on;