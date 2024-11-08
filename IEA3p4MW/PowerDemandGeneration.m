clear;close all;clc;
% grid demand curve

P_dem = 3.4e6; % [MW]
curtailment_rate = 0.06; %
curtailment_duration = 4*3600; % [s]

dt = 0.1; % [s]
Tmax = 3600*25; % [s]

t = 0:0.1:Tmax-dt;

% p_begin_i   = 3600*11;
% p_end_i     = 3600*15;
% delta = abs(p_end_i - p_begin_i);
% curtailment_time = -delta/2:0.1:delta/2;

% parabel =(curtailment_time).^2 - max((curtailment_time).^2);
% figure;
% plot(curtailment_time,parabel)

% values1 = P_dem * ones(1,(p_begin_i)/dt);
% values2 = P_dem * ones(1,length(t)-(length(values1)+length(curtailment_time)));
% v = [values1, parabel, values2];
% figure;
% plot(t,v);

syms a b c
eqn1 = a*(39600)^2 + b*39600 + c == 3.4e6;
eqn2 = a*(46800)^2 + b*46800 + c == 3.4e6*0.94;
eqn3 = a*(54000)^2 + b*54000 + c == 3.4e6;

[A,B] = equationsToMatrix([eqn1,eqn2,eqn3],[a,b,c]);
X = linsolve(A,B)

p_begin_i   = 3600*11;
p_end_i     = 3600*15;
delta = abs(p_end_i - p_begin_i);
curtailment_time = p_begin_i:dt:p_end_i;

c_square = curtailment_time.^2;

parabel = X(1)*c_square + X(2)*curtailment_time + X(3);
figure;
plot(parabel)

