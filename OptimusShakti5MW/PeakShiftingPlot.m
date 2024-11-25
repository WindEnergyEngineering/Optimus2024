%% Reading steady State values
clear all; close all; clc;
classic = load("SteadyStatesShakti5MW_classic.mat");
PS = load("SteadyStatesShakti5MW_PS.mat");

%% plots
figure('Name','theta')
hold on;grid on;box on;
plot(classic.v_0,classic.x_T,'.')
plot(PS.v_0,PS.x_T,'.')
xlabel('v_0 [m/s]')
ylabel('x_T [m]')
legend('Classic','Peak Shaving')