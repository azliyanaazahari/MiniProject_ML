%% 🎯 SETUP: Set desired water level
desiredLevel = 15;
assignin('base', 'desiredLevel', desiredLevel);  % So RL resetFcn can access it

%% 🧠 RL SIMULATION
% Update simulation options
Ts = 1.0;
Tf = 200;
simOpts = rlSimulationOptions( ...
    MaxSteps=ceil(Tf/Ts), ...
    StopOnError="on");

% Simulate RL
experiences = sim(env, agent, simOpts);

% Extract data from RL simulation
h_ts = experiences.Observation.observations;
h_rl_all = squeeze(h_ts.Data)';       % [201 × 3] — transpose!
h_rl = h_rl_all(:, 3);                % Water level = 3rd column
t_rl = h_ts.Time;

% Match length
minLen = min(length(t_rl), length(h_rl));
t_rl = t_rl(1:minLen);
h_rl = h_rl(1:minLen);

%% ⚙️ PI SIMULATION
simOut_pi = sim('watertank_pi');      % Run PI controller model
h_pi = simOut_pi.waterlevel.signals.values;
t_pi = simOut_pi.tout;

% Match length
minLen = min(length(t_pi), length(h_pi));
t_pi = t_pi(1:minLen);
h_pi = h_pi(1:minLen);

%% 📊 PLOT RESULTS
figure;
plot(t_pi, h_pi, 'b', 'LineWidth', 2); hold on;
plot(t_rl, h_rl, 'g', 'LineWidth', 2);
yline(desiredLevel, '--r', 'Setpoint');
grid on;
xlabel('Time (s)');
ylabel('Water Level (m)');
title('Water Level Response: PI vs RL');
legend('PI Controller', 'RL Controller', 'Setpoint');

%% 📈 METRICS FUNCTION
function metrics = computePerformance(t, h, setpoint)
    % Rise Time
    above10 = find(h >= 0.9*setpoint, 1);
    below10 = find(h <= 0.1*setpoint, 1, 'last');
    if ~isempty(above10) && ~isempty(below10)
        riseTime = t(above10) - t(below10);
    else
        riseTime = NaN;
    end

    % Settling Time
    tol = 0.02 * setpoint;
    idx = find(abs(h - setpoint) > tol);
    if isempty(idx)
        settlingTime = 0;
    else
        lastOutOfBounds = idx(end);
        settlingTime = t(lastOutOfBounds);
    end

    % Overshoot
    peak = max(h);
    overshoot = ((peak - setpoint) / setpoint) * 100;

    % Mean Squared Error
    mse = mean((h - setpoint).^2);

    % Package
    metrics = struct(...
        'RiseTime', riseTime, ...
        'SettlingTime', settlingTime, ...
        'Overshoot', overshoot, ...
        'MSE', mse);
end

%% 📋 PRINT METRICS
m_rl = computePerformance(t_rl, h_rl, desiredLevel);
m_pi = computePerformance(t_pi, h_pi, desiredLevel);

fprintf('\n📈 Performance Metrics Comparison:\n');
fprintf('   %-18s | %-10s | %-10s\n', 'Metric', 'PI', 'RL');
fprintf('   -------------------+------------+------------\n');
fprintf('   Rise Time (s)      | %-10.2f | %-10.2f\n', m_pi.RiseTime, m_rl.RiseTime);
fprintf('   Settling Time (s)  | %-10.2f | %-10.2f\n', m_pi.SettlingTime, m_rl.SettlingTime);
fprintf('   Overshoot (%%)      | %-10.2f | %-10.2f\n', m_pi.Overshoot, m_rl.Overshoot);
fprintf('   Mean Squared Error | %-10.2f | %-10.2f\n', m_pi.MSE, m_rl.MSE);