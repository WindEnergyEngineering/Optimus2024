% -----------------------------
% Script: Tests pitch controller at different operation points.
% Exercise 03 of "Controller Design for Wind Turbines and Wind Farms"
% -----------------------------

clearvars;%close all;clc;

%% PreProcessing SLOW for all simulations

% Default Parameter Turbine and Controller
Parameter                       = DefaultParameter_SLOW2DOF;
Parameter                       = DefaultParameter_PitchActuator(Parameter);
Parameter                       = DefaultParameter_FBv1_ADv14(Parameter);

% Time
dt                              = 1/80;
Parameter.Time.dt               = dt;   % [s] simulation time step              
Parameter.Time.TMax             = 60;   % [s] simulation length

%% Loop over Operation Points

OPs = [15];
nOP = length(OPs);

for iOP=1:nOP
    
    % get Operation Point
    OP = OPs(iOP);

    % wind for this OP
    Disturbance.v_0.time            = [0; 30; 30+dt;  60];       % [s]      time points to change wind speed
    Disturbance.v_0.signals.values  = [0;  0;  0; 0]+OP;    % [m/s]    wind speeds

    % Initial Conditions from SteadyStates for this OP
    SteadyStates = load('SteadyStatesShakti5MW_classic.mat','v_0','Omega','theta','M_g','x_T');                       
    Parameter.IC.Omega          	= interp1(SteadyStates.v_0,SteadyStates.Omega,OP,'linear','extrap');
    Parameter.IC.theta          	= interp1(SteadyStates.v_0,SteadyStates.theta,OP,'linear','extrap');
    Parameter.IC.M_g          	    = interp1(SteadyStates.v_0,SteadyStates.M_g,  OP,'linear','extrap');
    Parameter.IC.x_T          	    = interp1(SteadyStates.v_0,SteadyStates.x_T,  OP,'linear','extrap');

    % Processing SLOW for this OP
    sim('FBv1_SLOW2DOF.mdl')
    
    % collect simulation Data
    Omega(:,iOP)    = logsout.get('y').Values.Omega.Data;
    Power_el(:,iOP) = logsout.get('y').Values.P_el.Data;
    lambda(:,iOP)   = logsout.get('y').Values.lambda.Data;
    theta(:,iOP)    = logsout.get('y').Values.theta.Data;
    v_0(:,iOP)      = logsout.get('d').Values.v_0.Data;
 
end


%% PostProcessing SLOW
figure

subplot(511)
hold on;box on;grid on;
plot(tout,Omega*60/2/pi)
ylabel('\Omega [rpm]')
legend(strcat(num2str(OPs'),' m/s'))

subplot(512)
hold on;box on;grid on;
plot(tout,Power_el./1000)
ylabel('Power [kW]')
legend(strcat(num2str(OPs'),' m/s'))

subplot(513)
hold on;box on;grid on;
plot(tout,lambda)
ylabel('\lambda [-]')
legend(strcat(num2str(OPs'),' m/s'))

subplot(514)
hold on;box on;grid on;
plot(tout,rad2deg(theta))
ylabel('\theta [°]')
legend(strcat(num2str(OPs'),' m/s'))

subplot(515)
hold on;box on;grid on;
plot(tout,v_0)
ylabel('v_0 [m/s]')
legend(strcat(num2str(OPs'),' m/s')) 