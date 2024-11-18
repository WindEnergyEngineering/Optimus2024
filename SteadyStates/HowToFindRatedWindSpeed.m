% -----------------------------
% Script: Finds rated wind speed.
% Exercise 08 of Master Course 
% "Controller Design for Wind Turbines and Wind Farms"
% ----------------------------------
clearvars;clc;close all;
Parameter                       	= DefaultParameter_SLOW2DOF;
Parameter                           = DefaultParameter_FBv1_ADv14(Parameter);   
v_0                                     = 5:.1:30; % [m/s]
v_0_min                                 = 0;
v_0_max                                 = 30;        
Omega                                   = Parameter.CPC.Omega_g_rated/Parameter.Turbine.r_GB;
theta                                   = Parameter.CPC.theta_min;  
M_g                                     = Parameter.VSC.M_g_rated;        
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
%% Optimization using fminbnd
fun = @(v)(OmegaDot(Omega,theta,M_g,v,Parameter))^2;
v1 = 5;
v2 = 30;
[v_rated,Omega_dot_Sq,exitflag] = fminbnd(fun,v1,v2,optimset('Display','iter'));
%% Optimization using fminunc
v_start = 12;
[v_rated,Omega_dot_Sq,exitflag] = fminunc(fun,v_start,optimset('Display','iter'));