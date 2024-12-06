% -----------------------------
% Script: Designs tower damper.
% Exercise 05 of Course "Controller Design for Wind Turbines and Wind Farms"
% -----------------------------

%% 1. Initialization 
clearvars;close all;clc;

%% 2. Values for 20 m/s
% Linear wind turbine model
% x_dot = A x + B u
% y     = C x + D u
% with
% x_1   = Omega
% x_2   = x_T
% x_3   = x_T_dot
% u_1   = theta
% u_2   = v_0
% y_1   = Omega_g
% y_2   = x_T_dot

%% Design
OPs         = [20];    % [m/s]
D_d         = 0.7;              % [-]
omega_d     = 0.5;              % [rad/s]

%% Default Parameter Turbine and Controller (only M_g_rated and Omega_g_rated needed for LinearizeSLOW1DOF_PC)
Parameter                       = DefaultParameter_SLOW2DOF;
SteadyStates                    = load('SteadyStatesShakti5MW_classic.mat','v_0','Omega','theta');                       

%% loop over operation points
nOP     = length(OPs);
kp      = NaN(1,nOP);
Ti      = NaN(1,nOP);
theta   = NaN(1,nOP);

for iOP=1:nOP  
    
    % Get operation point
    OP = OPs(iOP);
    theta_OP = interp1(SteadyStates.v_0,SteadyStates.theta,OP,'linear','extrap');
    Omega_OP = interp1(SteadyStates.v_0,SteadyStates.Omega,OP,'linear','extrap');

    % Linearize at each operation point
    [A,B,C,D] = LinearizeSLOW2DOF(theta_OP,Omega_OP,OP,Parameter);

    kp(iOP) = -(2*D_d*omega_d + A(1,1)) / (B(1,1)*C(1,1));
    ki = -(omega_d^2) / (B(1,1)*C(1,1));
    Ti(iOP) = kp(iOP)/ki;

    % Display the matrices
    disp('Matrix A:');
    disp(A);
    
    disp('Matrix B:');
    disp(B);
    
    disp('Matrix C:');
    disp(C);
    
    disp('Matrix D:');
    disp(D);
    
    fprintf('kp                     = [%s];\n',sprintf('%f ',kp));
    fprintf('Ti                     = [%s];\n',sprintf('%f ',Ti));  

        
end


%% 3. Define Wind Turbine
WT_2DOF             = ss(A,B,C,D);
WT_2DOF.InputName  	= {'theta','v_0'};
WT_2DOF.OutputName 	= {'Omega_g','x_T_dot'};   

%% 4. Define Pitch Controller
s                   = tf('s');    
PC                  = (kp + kp/Ti*1/s);             %0*s; % Ex.5.1b: Please adjust!
PC.InputName        = {'Omega_g'};    
PC.OutputName       = {'theta'};  

%% 5. Closed Loop without Tower Damper
CL_2DOF             = connect(WT_2DOF,PC,'v_0',{'Omega_g','x_T_dot'});
disp('--- Closed Loop without Tower Damper --------------------------------')
damp(CL_2DOF)
disp('---------------------------------------------------------------------')

%% 6. Desired Closed loop
D_d                 = 0.7;
omega_0_d           = 0.5;
G_0                 = B(1,2)/omega_0_d.^2.*C(1,1);
CL_1DOF             = tf([G_0*omega_0_d^2 0],[1 2*D_d*omega_0_d omega_0_d^2]);
disp('--- Desired Closed loop ---------------------------------------------')
damp(CL_1DOF)
disp('---------------------------------------------------------------------')

%% 7. Define Tower Damper 
% triples the damping of the coupled tower motion
gain                = 0.0424; % Ex.5.1c: Please adjust! 
TD                  = tf(gain); 
TD.InputName        = {'x_T_dot'};    
TD.OutputName       = {'theta'};    
    
%% 8. Closed Loop with Tower damper
CL_2DOF_TD       	= connect(WT_2DOF,[PC TD],'v_0',{'Omega_g','x_T_dot'});
disp('--- Closed Loop with Tower damper -----------------------------------')
damp(CL_2DOF_TD)
disp('---------------------------------------------------------------------')

%% 9. Compare Step response
figure
step(CL_1DOF,CL_2DOF,CL_2DOF_TD)
legend('Desired CL','CL without TD','CL with TD')
xlim([0 30])

figure
bode(CL_1DOF,CL_2DOF,CL_2DOF_TD)
legend('Desired CL','CL without TD','CL with TD')

%% PZ map
figure
hold on
pzmap(CL_1DOF,CL_2DOF,CL_2DOF_TD)
legend('Desired CL','CL without TD','CL with TD')
