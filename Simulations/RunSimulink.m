clearvars;close all;clc;bdclose;
addpath(genpath('..\WetiMatlabFunctions'))
addpath(genpath('Simulink'))
%% PreProcessing SLOW for all simulations

% Parameter to optimize:
% Region 2 -> k: OptFlag = 1;
% Region 3 -> k_p:  OptFlag = 2; 
% Region 2.5 -> delta P: OptFlag = 3;
% Region 3 -> theta_k:  OptFlag = 4;
OptFlag = 2; 

% Default Parameter Turbine and Controller
Parameter                       = DefaultParameter_SLOW2DOF;
Parameter                       = DefaultParameter_PitchActuator(Parameter);
Parameter                       = DefaultParameter_FBv1_ADv14(Parameter);

% Time
Parameter.Time.dt                   = 0.25;             % [s] simulation time step            
Parameter.Time.TMax                 = 3600-Parameter.Time.dt;             % [s] simulation length  !!! 3600 !!! for good results in DEL

% Postprocessing Parameter
C                               = 2/sqrt(pi)*7.5;% [m/s] TC III
k                               = 2;            % [-]
WoehlerExponent                 = 4;            % [-]   for steel
N_REF                           = 2e6/(20*8760);% [-]   fraction of 2e6 in 20 years for 10 min 

% Steady States
SteadyStates = load('SteadyStatesShakti5MW_classic.mat','v_0','Omega','theta','x_T','M_g'); 

%% DLC 1.2

if OptFlag == 1
    Delta           = [44:2:48]; % Values for k [Nm/(rad/s)^2]
elseif OptFlag == 2
    Delta           = [0.01:0.005:0.05]; % Values for k_p pitch [s]
elseif OptFlag == 3
    Delta           = [4.8e6:1e5:5.2e6]; % Values for delta P [W]
elseif OptFlag == 4
    Delta           = [10:5:25]; % Values for theta_k [deg]
else
    fprintf('ERROR: No proper control parameter has been choosen!')
end

% Mean wind speeds for DLC 1.2
URef_v          = [4:2:24];
nURef           = length(URef_v);
Seeds           = [1:6];
nSeeds          = length(Seeds);
n               = length(Delta);
Distribution    = k/C*(URef_v/C).^(k-1).*exp(-(URef_v/C).^k);
Weights         = Distribution/sum(Distribution); % relative frequency

for i = 1:n

    if OptFlag == 1
        Parameter.VSC.k = Delta(i);
    elseif OptFlag == 2
        Parameter.CPC.kp = Delta(i);
    elseif OptFlag == 3
        Parameter.VSC.Delta_P       = Delta(i);
    elseif OptFlag == 4
        Parameter.CPC.theta_K = deg2rad(Delta(i)); 
    end
         
    for iURef = 1:nURef
        
        % Load wind speed
        URef                	= URef_v(iURef);
%         load(['wind\URef_',num2str(URef,'%02d'),'_Disturbance'],'Disturbance')
        for iSeed = 1:nSeeds
            TurbSimResultFile = ['TurbulentWind/URef_',num2str(URef,'%02d'),'_Seed_',num2str(iSeed,'%02d'),'.wnd'];
            [v_0,t] = CalculateREWSfromWindField(TurbSimResultFile,Parameter.Turbine.R,1);
            u_RE(:,iSeed) = v_0;
        end
        U_RE = u_RE';
        U_RE = U_RE(:);
                 
        Disturbance.v_0.time = [0:Parameter.Time.dt:Parameter.Time.TMax]';
        Disturbance.v_0.signals.values = U_RE;
        
        % Initial Conditions from SteadyStates
        Parameter.IC.Omega      = interp1(SteadyStates.v_0,SteadyStates.Omega   ,URef,'linear','extrap');
        Parameter.IC.theta   	= interp1(SteadyStates.v_0,SteadyStates.theta   ,URef,'linear','extrap');
        Parameter.IC.x_T    	= interp1(SteadyStates.v_0,SteadyStates.x_T     ,URef,'linear','extrap');
        Parameter.IC.M_g     	= interp1(SteadyStates.v_0,SteadyStates.M_g     ,URef,'linear','extrap');
        
        % Processing SLOW
        fprintf('Simulating %02d m/s for iDelta=%d of OptFlag=%d\n',URef,i,OptFlag)
        sim_out = sim('FBv1_SLOW2DOF.mdl');
        
        % Collect statistics
        Omega_max(iURef)        = max(sim_out.logsout.get('y').Values.Omega.Data);
        P_mean(iURef)           = mean(sim_out.logsout.get('y').Values.P_el.Data);
        c                       = rainflow(sim_out.logsout.get('y').Values.M_yT.Data);
        Count                   = c(:,1);
        Range                   = c(:,2);
        DEL_MyT(iURef)          = (sum(Range.^WoehlerExponent.*Count)/N_REF).^(1/WoehlerExponent);       
    end
    
    % Calculate Annual energy production and lifetime-weighted DEL
    AEP(i)  = sum(P_mean .* Weights) * 8760;                                                         % [Wh] converted to GWh in plotting
    DEL(i)  = sum(Weights .*DEL_MyT .^WoehlerExponent).^(1/WoehlerExponent);                         % [Nm]
    Overspeed(:,i) = Omega_max./(Parameter.CPC.Omega_g_rated/Parameter.Turbine.r_GB);
    DEL_MyT_LTW(:,i) = (Weights .*DEL_MyT .^WoehlerExponent).^(1/WoehlerExponent); 
end

%% Plot Brute Force Optimization Results
figure
subplot(211)
box on; hold on
plot(Delta,AEP/1e9,'.-','Markersize',20)
ylabel('AEP [GWh]')
xlabel('k [-]')
subplot(212)
box on; hold on
plot(Delta,DEL/1e6,'.-','Markersize',20)
%plot([min(Delta) max(Delta)],[1 1]*30,'k') % 36 MNm as max Tower base bending Moment first guess 
ylabel('DEL(M_{yT}) [MNm]')
xlabel('k [-]')

[AEP_max, index] = max(AEP);
AEP_max = AEP_max/1e9;
k_opt = Delta(index);

fprintf('Maximum AEP: %02d [GWh]\n',AEP_max)
fprintf('Optimum Control Parameter: %02d \n',k_opt)

if OptFlag == 4 || OptFlag == 2
    
    % Convert the array values to strings
    legendEntries = arrayfun(@num2str, Delta, 'UniformOutput', false);

    figure
    subplot(211)
    box on; hold on;
    for j = 1:n
        plot(URef_v,Overspeed(:,j),'.-','Markersize',20)
%         plot([URef_v(1) URef_v(end)],[1 1],'k')
    end
    ylabel('Overspeed')
    xlabel('mean wind speed [m/s]');
    xlim([8 24])
    legend(legendEntries, 'Location', 'best');
    
    subplot(212)
    box on; hold on;
    for j = 1:n
        plot(URef_v,DEL_MyT_LTW(:,j)/1e6,'.-','Markersize',20)
        % plot([URef_v(1) URef_v(end)],[1 1],'k')
    end
    ylabel('DEL M_yT [MNm]')
    xlabel('mean wind speed [m/s]');
    xlim([8 24])
    legend(legendEntries, 'Location', 'best');
end

