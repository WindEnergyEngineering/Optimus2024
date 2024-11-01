function [P_dem] = Scenarios(Selector, TMax, dt)
%Scenarios for the battery storage dummy
switch Selector
    case 1 % No grid power demand
        P_dem.time            = [0; (TMax/2); (TMax/2)+dt;  TMax];    % [s] time points to change power demand
        P_dem.signals.values  = [0;  0;   0.0; 0.0];    % [MW]    Power
    otherwise
        disp('No matching scenario found for the given input');
end

end