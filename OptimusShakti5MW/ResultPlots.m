%% Reading steady State values
clear all; close all; clc;
BaseLine = load("SteadyStatesNREL5MW_FBNREL_SLOW_stud.mat");
Advanced = load("SteadyStatesNREL5MW_FBSWE_SLOW_stud.mat");


%% Plots
figure('Name','Omega')
hold on;grid on;box on;
plot(BaseLine.v_0,radPs2rpm(BaseLine.Omega),'.')
plot(Advanced.v_0,radPs2rpm(Advanced.Omega),'.')
xlabel('v_0 [m/s]')
ylabel('\Omega [rpm]')
legend('Base Line Controller','Advanced Controller')

figure('Name','theta')
hold on;grid on;box on;
plot(BaseLine.v_0,rad2deg(BaseLine.theta),'.')
plot(Advanced.v_0,rad2deg(Advanced.theta),'.')
xlabel('v_0 [m/s]')
ylabel('\theta [deg]')
legend('Base Line Controller','Advanced Controller')

figure('Name','M_g')
hold on;grid on;box on;
plot(BaseLine.v_0,BaseLine.M_g,'.')
plot(Advanced.v_0,Advanced.M_g,'.')
xlabel('v_0 [m/s]')
ylabel('M_g [Nm]')
legend('Base Line Controller','Advanced Controller')

figure('Name','x_T')
hold on;grid on;box on;
plot(BaseLine.v_0,BaseLine.x_T,'.')
plot(Advanced.v_0,Advanced.x_T,'.')
xlabel('v_0 [m/s]')
ylabel('x_T [m]')
legend('Base Line Controller','Advanced Controller')

figure('Name','P')
hold on;grid on;box on;
plot(BaseLine.v_0,BaseLine.P,'.')
plot(Advanced.v_0,Advanced.P,'.')
xlabel('v_0 [m/s]')
ylabel('P [W]')
legend('Base Line Controller','Advanced Controller')

figure('Name','Torque Controller')
hold on;grid on;box on;
plot(radPs2rpm(BaseLine.Omega),BaseLine.M_g/1e3,'.')
plot(radPs2rpm(Advanced.Omega),Advanced.M_g/1e3,'.')
xlabel('Omega [rpm]')
ylabel('M_g [kNm]')
legend('Base Line Controller','Advanced Controller')