function [P_dem] = Scenarios(Selector, TMax, dt)
%Scenarios for the battery storage dummy
switch Selector
    case 1 % No grid power demand
        demand = 0;
        P_dem.time            = [0; (TMax/2); (TMax/2)+dt;  TMax];      % [s] time points to change power demand
        P_dem.signals.values  = [demand;  demand;   demand; demand];    % [MW]    Power
    case 2 % rated power demand from grid
        demand = 3.6e6;
        P_dem.time            = [0; (TMax/2); (TMax/2)+dt;  TMax];      % [s] time points to change power demand
        P_dem.signals.values  = [demand;  demand;   demand; demand];    % [MW]    Power
    case 3 % 50% of rated power demand from grid
        demand = 3.6e6/2;
        P_dem.time            = [0; (TMax/2); (TMax/2)+dt;  TMax];      % [s] time points to change power demand
        P_dem.signals.values  = [demand;  demand;   demand; demand];    % [MW]    Power
    otherwise
        disp('No matching scenario found for the given input');
end

end