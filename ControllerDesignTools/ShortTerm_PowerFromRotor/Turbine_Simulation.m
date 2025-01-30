% -----------------------------
% Script: Tests pitch controller at different operation points.
% Exercise 03 of "Controller Design for Wind Turbines and Wind Farms"
% -----------------------------

clearvars;close all;clc;

%% PreProcessing SLOW for all simulations

% Default Parameter Turbine and Controller
Parameter                           = DefaultParameter_SLOW2DOF;
Parameter                           = DefaultParameter_PitchActuator(Parameter);
Parameter                           = DefaultParameter_FBv1_ADv14(Parameter);

% Time
dt                                  = 1/80;
Parameter.Time.dt                   = dt;   % [s] simulation time step              
Parameter.Time.TMax                 = 60;   % [s] simulation length

% Tourque offset
Parameter.Offset.Torque             = 0.1;  % [-] Fraction of nominal Tourque
% positive pulses
Parameter.Offset.positive.period    = 30;   % [s] Period of the pulse
Parameter.Offset.positive.width     = 5;    % [%] Width of the pulse (100 = period) 
Parameter.Offset.positive.delay     = 15;   % [s] dely against 0 sec
% negative pulses
Parameter.Offset.negative.period    = 30;   % [s] Period of the pulse
Parameter.Offset.negative.width     = 5;    % [%] Width of the pulse (100 = period) 
Parameter.Offset.negative.delay     = 30;   % [s] dely against 0 sec
%% Loop over Operation Points

OPs = [12 16 20 24];
nOP = length(OPs);

for iOP=1:nOP   
    
    % get Operation Point
    OP = OPs(iOP);

    % wind for this OP
    Disturbance.v_0.time            = [0; 30; 30+dt;  60];       % [s]      time points to change wind speed
    Disturbance.v_0.signals.values  = [0;  0; 0.0; 0.0]+OP;    % [m/s]    wind speeds

    % Initial Conditions from SteadyStates for this OP
    SteadyStates = load('SteadyStates_FBv1_SLOW2DOF','v_0','Omega','theta','M_g','x_T');                       
    Parameter.IC.Omega          	= interp1(SteadyStates.v_0,SteadyStates.Omega,OP,'linear','extrap');
    Parameter.IC.theta          	= interp1(SteadyStates.v_0,SteadyStates.theta,OP,'linear','extrap');
    Parameter.IC.M_g          	    = interp1(SteadyStates.v_0,SteadyStates.M_g,  OP,'linear','extrap');
    Parameter.IC.x_T          	    = interp1(SteadyStates.v_0,SteadyStates.x_T,  OP,'linear','extrap');

    % Processing SLOW for this OP
    sim_out = sim('FBv1_SLOW2DOF.mdl');
    
    % collect simulation Data
    Omega(:,iOP) = sim_out.logsout.get('y').Values.Omega.Data;
    Power_el(:,iOP) = sim_out.logsout.get('y').Values.P_el.Data;
    Torque(:,iOP) = sim_out.logsout.get('y').Values.M_g.Data;
end


%% PostProcessing SLOW
figure

subplot(311)
hold on;box on;grid on;
plot(sim_out.tout,Omega*60/2/pi)
ylabel('\Omega [rpm]')
legend(strcat(num2str(OPs'),' m/s'))

subplot(312)
hold on;box on;grid on;
plot(sim_out.tout,Power_el./1000)
ylabel('Power [kW]')
legend(strcat(num2str(OPs'),' m/s')) 

subplot(313)
hold on;box on;grid on;
plot(sim_out.tout,Torque)
ylabel('Torque [Nm]')
legend(strcat(num2str(OPs'),' m/s')) 