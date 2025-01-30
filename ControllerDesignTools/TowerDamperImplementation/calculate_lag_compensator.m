function [z, p] = calculate_lag_compensator(f, phase_target_deg)
    % f: Frequency in Hz
    % phase_target_deg: Target phase shift in degrees

    % Convert phase from degrees to radians
    phase_target = deg2rad(phase_target_deg);
    
    % Calculate angular frequency (omega) from frequency (f)
    omega = 2 * pi * f;

% Range of values for z and p (search grid)
    z_range = linspace(1, 50, 100);  % Example range for z (1 to 50)
    p_range = linspace(0.1, 5, 100);  % Example range for p (0.1 to 5)

    % Initialize variables to store the best results
    min_error = inf;  % Start with a large error
    best_z = 0;
    best_p = 0;

    % Brute force search over all combinations of z and p
    for z = z_range
        for p = p_range
            % Calculate phase shift for current values of z and p
            phase_calc = atan(omega / z) - atan(omega / p);
            
            % Calculate the error between the calculated and target phase
            error = abs(phase_calc - phase_target);
            
            % Update the best solution if the error is smaller
            if error < min_error
                min_error = error;
                best_z = z;
                best_p = p;
            end
        end
    end

    % Return the best solution found
    z = best_z;
    p = best_p;
    
    % Display the results
    fprintf('Zero (z): %.4f rad/s\n', z);
    fprintf('Pole (p): %.4f rad/s\n', p);
end

