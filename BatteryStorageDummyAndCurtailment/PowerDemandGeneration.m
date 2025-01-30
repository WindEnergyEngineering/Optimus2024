clear;close all;clc;
% grid demand curve

P_dem = 3.369e6; % [MW]
curtailment_rate = 0.06;
curtailment_duration = 4*3600; % [s]

dt = 0.1; % [s]
Tmax = 3600*25; % [s]
t = 0:0.1:Tmax-dt; % [s]

p_begin_i   = 3600*11; % [s]
p_end_i     = 3600*15; % [s]
delta = abs(p_end_i - p_begin_i); % [s]
curtailment_time = p_begin_i:dt:p_end_i; % [s]

syms a b c
eqn1 = a*(p_begin_i)^2 + b*p_begin_i + c == 1;
eqn2 = a*(p_begin_i+delta/2)^2 + b*(p_begin_i+delta/2) + c == (1-curtailment_rate);
eqn3 = a*(p_end_i)^2 + b*p_end_i + c == 1;

[A,B] = equationsToMatrix([eqn1,eqn2,eqn3],[a,b,c]);
X = linsolve(A,B);

parabel = double(X(1))*curtailment_time.^2 + double(X(2))*curtailment_time + double(X(3));
figure;
plot(parabel)

values1 = P_dem * ones(1,(p_begin_i)/dt);
values2 = P_dem * ones(1,length(t)-(length(values1)+length(curtailment_time)));
Disturbance.P_dem.signals.values = [values1, parabel*P_dem, values2]';
Disturbance.P_dem.time = t';
figure;
plot(t,Disturbance.P_dem.signals.values);

save(['power\PDem_0d06curtailment','_Disturbance'],'Disturbance')