function analyzeMuxedPerformance(data)
% data: numeric matrix, columns = [height, reference, ...]

    if ~isnumeric(data) || size(data, 2) < 2
        error("Input must be a numeric matrix with at least 2 columns.");
    end

    t = (0:size(data, 1)-1)';  % Assume 1s timestep if none provided
    y = data(:,1);             % height
    target = data(:,2);        % reference

    % Match original logic
    N = min([length(t), length(y), length(target)]);
    t = t(1:N);
    y = y(1:N);
    target = target(1:N);
    y_target = target(1);

    % --- Performance Metrics ---
    start_idx = find(y >= 0.1 * y_target, 1);
    rise_idx  = find(y >= 0.9 * y_target, 1);
    if ~isempty(start_idx) && ~isempty(rise_idx)
        rise_time = t(rise_idx) - t(start_idx);
    else
        rise_time = NaN;
    end

    overshoot = (max(y) - y_target) / y_target * 100;

    tol = 0.05 * y_target;
    idx_settle = find(abs(y - y_target) > tol, 1, 'last');
    if isempty(idx_settle)
        settling_time = t(end);
    else
        settling_time = t(idx_settle);
    end

    mse = mean((y - target).^2);

    % Display
    fprintf("\nRL Controller Performance Metrics:\n");
    fprintf(" Rise Time     : %.2f seconds\n", rise_time);
    fprintf(" Overshoot     : %.2f %%\n", overshoot);
    fprintf(" Settling Time : %.2f seconds\n", settling_time);
    fprintf(" MSE           : %.4f\n", mse);

    % Plot
    figure;
    plot(t, y, 'b', 'LineWidth', 2); hold on;
    plot(t, target, 'r--', 'LineWidth', 1.5);
    xlabel('Time (s)');
    ylabel('Water Level');
    legend('Water Level', 'Reference');
    title('Water Tank RL Controller Response');
    grid on;

    annotation('textbox', [0.15 0.7 0.3 0.2], 'String', ...
        sprintf('Rise: %.2fs\nOvershoot: %.1f%%\nSettling: %.2fs\nMSE: %.4f', ...
        rise_time, overshoot, settling_time, mse), ...
        'FitBoxToText', 'on', 'BackgroundColor', 'white');
end
