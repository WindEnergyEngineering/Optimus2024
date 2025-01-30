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
    case 3 % 33% of rated power demand from grid
        demand = 3.4e6/3;
        P_dem.time            = [0; (TMax/2); (TMax/2)+dt;  TMax];      % [s] time points to change power demand
        P_dem.signals.values  = [demand;  demand;   demand; demand];    % [MW]    Power
    case 4 % operation below rated power and higher demand from grid
        demand = 3.6e6/2;
        P_dem.time            = [0; (TMax/2); (TMax/2)+dt;  TMax];      % [s] time points to change power demand
        P_dem.signals.values  = [demand;  demand;   demand*2; demand*2];    % [MW]    Power
    case 5 % grid power demand curtailment scenario
        load('power\PDem_0d06curtailment_Disturbance','Disturbance');
        P_dem = Disturbance.P_dem;
    otherwise 
        disp('No matching scenario found for the given input');
end

end