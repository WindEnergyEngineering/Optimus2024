% -----------------------------
% Script: Finds rated wind speed.
% Exercise 08 of Master Course 
% "Controller Design for Wind Turbines and Wind Farms"
% ----------------------------------
clearvars;clc;close all;
Parameter                       	= DefaultParameter_SLOW2DOF;
Parameter                           = DefaultParameter_FBv1_ADv14(Parameter);  
v_0                                     = 0:.1:30; % [m/s]
v_0_min                                 = 0;
v_0_max                                 = 30;        
theta                                   = Parameter.CPC.theta_min;
k                                       = Parameter.VSC.k;  
Omega                           = Parameter.VSC.Omega_g_1d5/Parameter.Turbine.r_GB;
M_g                             = 0;   
%% Brute Force Optimization       
for  iv_0=1:length(v_0)        
    Residual(iv_0)=OmegaDot(Omega,theta,M_g,v_0(iv_0),Parameter); 
end        

figure
hold on
plot(v_0,Residual*60/2/pi)
plot([v_0(1) v_0(end)],[0,0])
xlabel('wind speed [m/s]')
ylabel('rotor acceleration [rpm/s]')
%% Optimization using fminbnd M_g=0;
fun = @(v)(OmegaDot(Omega,theta,M_g,v,Parameter))^2;
[v,Omega_dot_Sq,exitflag] = fminbnd(fun,v_0_min,v_0_max,optimset('Display','iter'));

