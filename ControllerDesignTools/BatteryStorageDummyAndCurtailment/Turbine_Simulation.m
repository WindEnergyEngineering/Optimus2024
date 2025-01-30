% -----------------------------
% Script: Tests pitch controller at different operation points.
% Exercise 03 of "Controller Design for Wind Turbines and Wind Farms"
% -----------------------------

clearvars;close all;clc;

%% PreProcessing SLOW for all simulations

% Default Parameter Turbine and Controller
Parameter                       = DefaultParameter_SLOW2DOF;
Parameter                       = DefaultParameter_PitchActuator(Parameter);
Parameter                       = DefaultParameter_FBv1_ADv14(Parameter);
Parameter                       = DefaultParameter_Storage(Parameter);

% Time
dt                              = 0.1;
Parameter.Time.dt               = dt;   % [s] simulation time step              
Parameter.Time.TMax             = 25*3600;   % [s] simulation length

%% Loop over Operation Points

OPs = [12];
nOP = length(OPs);

for iOP=1:nOP
    
    % get Operation Point
    OP = OPs(iOP);
    % wind for this OP
    Disturbance.v_0.time            = [0; Parameter.Time.TMax/2; Parameter.Time.TMax/2+dt;  Parameter.Time.TMax];       % [s]      time points to change wind speed
    Disturbance.v_0.signals.values  = [0;  0;   0.0; 0.0]+OP;    % [m/s]    wind speeds
    
    % Battery storage scenario
    Select = 5;
    Disturbance.P_dem = Scenarios(Select,Parameter.Time.TMax,dt);

    % Initial Conditions from SteadyStates for this OP
    SteadyStates = load('SteadyStates_FBv1_SLOW2DOF','v_0','Omega','theta','M_g','x_T');                       
    Parameter.IC.Omega          	= interp1(SteadyStates.v_0,SteadyStates.Omega,OP,'linear','extrap');
    Parameter.IC.theta          	= interp1(SteadyStates.v_0,SteadyStates.theta,OP,'linear','extrap');
    Parameter.IC.M_g          	    = interp1(SteadyStates.v_0,SteadyStates.M_g,  OP,'linear','extrap');
    Parameter.IC.x_T          	    = interp1(SteadyStates.v_0,SteadyStates.x_T,  OP,'linear','extrap');
    
    % Processing SLOW for this OP
    simout = sim('FBv1_SLOW2DOF.mdl');
    
    % collect simulation Data
    Omega(:,iOP) = simout.logsout.get('y').Values.Omega.Data;
    Power_el(:,iOP) = simout.logsout.get('y').Values.P_el.Data;
    Energy_el(:,iOP) = simout.logsout.get('z').Values.E_storage.Data;
    v_0(:,iOP) = simout.logsout.get('d').Values.v_0.Data;
    P_dem(:,iOP) = simout.logsout.get('z').Values.P_dem.Data;
end


%% PostProcessing SLOW
figure
subplot(411)
hold on;box on;grid on;
plot(simout.tout./3600,v_0)
ylabel('v_0 [m/s]')
legend(strcat(num2str(OPs'),' m/s')) 

Select_str = num2str(Select);
title("Scenario " + Select_str)

subplot(412)
hold on;box on;grid on;
plot(simout.tout./3600,P_dem./1000)
ylabel('P_{dem} [MW]')

subplot(413)
hold on;box on;grid on;
plot(simout.tout./3600,Power_el./1000)
ylabel('Power [kW]')
% legend(strcat(num2str(OPs'),' m/s'))

subplot(414)
hold on;box on;grid on;
plot(simout.tout./3600,Energy_el./Parameter.Storage.Capacity*100)
ylabel('Storage Lvl. [%]')
xlabel('Time [h]')
% legend(strcat(num2str(OPs'),' m/s')) 