% -----------------------------
% Script: Designs pitch controller with closed-loop shaping.
% Exercise 03 of "Controller Design for Wind Turbines and Wind Farms"
% -----------------------------

clearvars;close all;clc;

%% Design
OPs         = [9.5];    % [m/s]
D_d         = 0.7;              % [-]
omega_d     = 0.6;              % [rad/s]

%% Default Parameter Turbine and Controller (only M_g_rated and Omega_g_rated needed for LinearizeSLOW1DOF_PC)
Parameter                       = DefaultParameter_SLOW2DOF;
Parameter                       = DefaultParameter_FBv1_ADv14(Parameter);
SteadyStates                    = load('SteadyStatesShakti5MW_classic','v_0','Omega','theta');                       

%% loop over operation points
nOP     = length(OPs);
kp      = NaN(1,nOP);
Ti      = NaN(1,nOP);
theta   = NaN(1,nOP);

for iOP=1:nOP  
    
    % Get operation point
    v_0_OP      = OPs(iOP);
    theta_OP    = interp1(SteadyStates.v_0,SteadyStates.theta,v_0_OP);
    Omega_OP    = interp1(SteadyStates.v_0,SteadyStates.Omega,v_0_OP);
    
    % Linearize at each operation point
    [A,B,C,D] = LinearizeSLOW1DOF_TC(Omega_OP,v_0_OP,Parameter)

    % Determine theta, kp and Ti for each operation point
    theta(iOP)  = theta_OP;
    kp(iOP)     = -(2*D_d*omega_d+A)/(B(1)*C);
    Ti(iOP)     = kp(iOP)/(-(omega_d^2)/(B(1)*C));
    G0(iOP)     = C*B(2)/omega_d^2;
    
end

fprintf('Parameter.CPC.GS.theta                  = [%s];\n',sprintf('%f ',theta));
fprintf('Parameter.CPC.GS.kp                     = [%s];\n',sprintf('%f ',kp));
fprintf('Parameter.CPC.GS.Ti                     = [%s];\n',sprintf('%f ',Ti));  
 
