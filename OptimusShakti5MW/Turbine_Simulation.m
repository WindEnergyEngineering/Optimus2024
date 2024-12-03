% -----------------------------
% Script: Tests pitch controller at different operation points.
% Exercise 03 of "Controller Design for Wind Turbines and Wind Farms"
% -----------------------------

clearvars;clc;close;

%% PreProcessing SLOW for all simulations

% Default Parameter Turbine and Controller
Parameter                       = DefaultParameter_SLOW2DOF;
Parameter                       = DefaultParameter_PitchActuator(Parameter);
Parameter                       = DefaultParameter_FBv1_ADv14(Parameter);

% Time
dt                              = 1/80;
Parameter.Time.dt               = dt;   % [s] simulation time step              
Parameter.Time.TMax             = 200;   % [s] simulation length

%% Loop over Operation Points

OPs = [12];
nOP = length(OPs);

for iOP=1:nOP
    
    % get Operation Point
    OP = OPs(iOP);

    % wind for this OP
    Disturbance.v_0.time            = [0; 30; 30+dt;  60];       % [s]      time points to change wind speed
    Disturbance.v_0.signals.values  = [0;  0;  0.1; 0.1]+OP;    % [m/s]    wind speeds

    % Initial Conditions from SteadyStates for this OP
    SteadyStates = load('SteadyStatesShakti5MW_classic.mat','v_0','Omega','theta','M_g','x_T');                       
    Parameter.IC.Omega          	= interp1(SteadyStates.v_0,SteadyStates.Omega,OP,'linear','extrap');
    Parameter.IC.theta          	= interp1(SteadyStates.v_0,SteadyStates.theta,OP,'linear','extrap');
    Parameter.IC.M_g          	    = interp1(SteadyStates.v_0,SteadyStates.M_g,  OP,'linear','extrap');
    Parameter.IC.x_T          	    = interp1(SteadyStates.v_0,SteadyStates.x_T,  OP,'linear','extrap');

    % Processing SLOW for this OP
    simout = sim('FBv1_SLOW2DOF.mdl');
    
    % collect simulation Data
    Omega(:,iOP)    = simout.logsout.get('y').Values.Omega.Data;
    M_g(:,iOP)      = simout.logsout.get('y').Values.M_g.Data;
    Power_el(:,iOP) = simout.logsout.get('y').Values.P_el.Data;
    lambda(:,iOP)   = simout.logsout.get('y').Values.lambda.Data;
    theta(:,iOP)    = simout.logsout.get('y').Values.theta.Data;
    v_0(:,iOP)      = simout.logsout.get('d').Values.v_0.Data;
 
end

tout = simout.tout;
%% PostProcessing SLOW
figure

subplot(511)
hold on;box on;grid on;
plot(tout,Omega*60/2/pi)
ylabel('\Omega [rpm]')
legend(strcat(num2str(OPs'),' m/s'))

subplot(512)
hold on;box on;grid on;
plot(tout,rad2deg(theta))
ylabel('\theta [°]')
legend(strcat(num2str(OPs'),' m/s'))

subplot(513)
hold on;box on;grid on;
plot(tout,M_g./1000)
ylabel('M_g [kNm]')
legend(strcat(num2str(OPs'),' m/s'))

subplot(514)
hold on;box on;grid on;
plot(tout,Power_el./1000)
ylabel('Power [kW]')
legend(strcat(num2str(OPs'),' m/s'))

subplot(515)
hold on;box on;grid on;
plot(tout,v_0)
ylabel('v_0 [m/s]')
legend(strcat(num2str(OPs'),' m/s')) 