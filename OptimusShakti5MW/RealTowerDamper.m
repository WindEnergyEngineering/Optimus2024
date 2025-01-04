%% Tower Daper Test Environment
% Choose the task of the Program:
% 1: Tower-Damper(TD) Design
% 2: Wind Step Test
% 3: Turbulent Test
clearvars;close all;clc;

TestFlag = 3;

% Default Parameter Turbine and Controller
Parameter                           = DefaultParameter_SLOW2DOF;
Parameter                           = DefaultParameter_PitchActuator(Parameter);
Parameter                           = DefaultParameter_FBv1_ADv14(Parameter);

%% Tower Damper Design

if TestFlag == 1 

    f_3P            = Parameter.CPC.Omega_g_rated/2/pi; % [Hz]      3P under rated conditions. Here the TD is active
    f_Tower         = 0.28;                             % [Hz]      Eigenfrequency of the Tower

    % LP Design
    f_c_LP = 0.5;
    w_0_LP = f_c_LP*2*pi;
    num_LP = [w_0_LP];
    denum_LP = [1 w_0_LP];
    H_LP = tf(num_LP,denum_LP)
    disp('--- LP-Filter ---------------------------------------------')
    damp(H_LP)
    disp('---------------------------------------------------------------------')
    figure
    hold on;grid on;
    bode(H_LP)

    % HP Design
    f_c_HP = 0.2;
    w_0_HP = f_c_HP*2*pi;
    num_HP = [1 0];
    denum_HP = [1 w_0_HP];
    H_HP = tf(num_HP,denum_HP)
    disp('--- HP-Filter ---------------------------------------------')
    damp(H_HP)
    disp('---------------------------------------------------------------------')
    figure
    grid on
    bode(H_HP)

    % Lag
    T_1 = 0.125;
    T_2 = 100;
    H_Lag = tf([1 T_2],[1 T_1])
    disp('--- Lag-Filter ---------------------------------------------')
    damp(H_Lag)
    disp('---------------------------------------------------------------------')
    figure
    grid on
    bode(H_Lag)
    
    % PZ map
    figure
    hold on
    pzmap(H_Lag)

    % Lead-Lag 
    tau_1 = 0.01;
    tau_2 = 35;%28.2;
    tau_3 = 8;%5;
    tau_4 = 0.5;
    H_LL = tf([tau_1*tau_3 tau_1+tau_3 1],[tau_2*tau_4 tau_2+tau_4 1])
    disp('--- LL-Filter ---------------------------------------------')
    damp(H_LL)
    disp('---------------------------------------------------------------------')
    figure
    grid on
    bode(H_LL)
    
    % PZ map
    figure
    hold on
    pzmap(H_LL)
    z1 = -100;
    z2 = -0.2;
    p1 = -0.125;%-2;%-1.7762;
    p2 = -2.86e-2;%-0.0355;
end

%% Test TD: Windstep

if TestFlag ==2
    
    % Time
    Parameter.Time.dt                   = 1/10;            % [s] simulation time step            
    Parameter.Time.TMax                 = 60;            % [s] simulation length
    
    % Wind
    DeltaU                              = 1;
    URef                                = 20;                
    Disturbance.v_0.time                = [0;     0.01;      	30];            % [s]      time points to change wind speed
    Disturbance.v_0.signals.values      = [URef;  URef+DeltaU;  URef+DeltaU];   % [m/s]    wind speeds  
    
    % Initial Conditions from SteadyStates
    SteadyStates = load('SteadyStatesShakti5MW_classic.mat','v_0','Omega','theta','x_T','M_g');                       
    Parameter.IC.Omega          	    = interp1(SteadyStates.v_0,SteadyStates.Omega   ,URef,'linear','extrap');
    Parameter.IC.theta          	    = interp1(SteadyStates.v_0,SteadyStates.theta   ,URef,'linear','extrap');
    Parameter.IC.x_T                    = interp1(SteadyStates.v_0,SteadyStates.x_T     ,URef,'linear','extrap');
    Parameter.IC.M_g          	        = interp1(SteadyStates.v_0,SteadyStates.M_g     ,URef,'linear','extrap');

    % Processing SLOW
    FlagFiltertype = 1; 
    Parameter.TD.gain = 0;
    TDFlag = 0;
    simout_pure = sim('FBv1_SLOW2DOF_with_TowerDamper.mdl');
    Parameter.TD.gain = 0.0424;
    simoutClassic = sim('FBv1_SLOW2DOF_with_TowerDamper.mdl');
    
    t = simoutClassic.tout;
    x_dotdot = simoutClassic.logsout.get('y').Values.x_T_dotdot.Data;
    x_dot = simoutClassic.logsout.get('y').Values.x_T_dot.Data;

    Parameter.TD.gain = 0.00085;
    TDFlag = 1;
    FlagFiltertype = 1;             % Lead-Lag:= 1; Lag:= 0
    simout = sim('FBv1_SLOW2DOF_with_TowerDamper.mdl');
    x_dot_est = simout.logsout.get('logTD').Values.x_dot_est.Data;
    
    FlagFiltertype = 0;             % Lead-Lag:= 1; Lag:= 0
    simout_lag = sim('FBv1_SLOW2DOF_with_TowerDamper.mdl');
    x_dot_est_lag = simout.logsout.get('logTD').Values.x_dot_est.Data;

    % Plot Results
    figure
    title('Tower Damper Estimated Tower-Top-Speed')
    hold on; grid on;
    plot(t,simoutClassic.logsout.get('logTD').Values.x_dot_est.Data)
    %plot(simout.tout,x_dot_est.*0.01)
    plot(simout_lag.tout,x_dot_est_lag.*0.01)
    plot(t,x_dotdot)
    ylabel('$\dot x_T$ [m/s]','Interpreter','latex')
    xlabel('$t$ [s]','Interpreter','latex')
    xlim([0 60])
    legend('Integrator speed estimation','Lag-Compensator speed estimation','acceleration reference',Location='best')
    
    figure
    %title('Tower-Top-Speed')
    hold on; grid on;
    plot(simout_pure.tout,simout_pure.logsout.get('y').Values.x_T_dot.Data)
    plot(t,x_dot)
    %plot(simout.tout,simout.logsout.get('y').Values.x_T_dot.Data)
    plot(simout_lag.tout,simout_lag.logsout.get('y').Values.x_T_dot.Data)
    ylabel('$\dot x_T$ [m/s]','Interpreter','latex')
    xlabel('$t$ [s]','Interpreter','latex')
    xlim([0 60])
    legend('No TD','TD: Integrator','TD: Lag-Compensator',Location='best')
end

%% Test TD: Turbulent Wind

if TestFlag ==3

    % Time
    Parameter.Time.dt                   = 1/10;             % [s] simulation time step            
    Parameter.Time.TMax                 = 3600;             % [s] simulation length
    
    
    % wind
    OP = 20;                            
    load(['wind/URef_',num2str(OP,'%02d'),'_Disturbance'],'Disturbance')              
    
    % Initial Conditions from SteadyStates
    SteadyStates = load('SteadyStatesShakti5MW_classic.mat','v_0','Omega','theta','x_T','M_g');                       
    Parameter.IC.Omega          	    = interp1(SteadyStates.v_0,SteadyStates.Omega   ,OP,'linear','extrap');
    Parameter.IC.theta          	    = interp1(SteadyStates.v_0,SteadyStates.theta   ,OP,'linear','extrap');
    Parameter.IC.x_T                    = interp1(SteadyStates.v_0,SteadyStates.x_T     ,OP,'linear','extrap');
    Parameter.IC.M_g                    = interp1(SteadyStates.v_0,SteadyStates.M_g     ,OP,'linear','extrap');
    
    % Processing SLOW
    FlagFiltertype = 1;             % Lead-Lag:= 1; Lag:= 0
    Parameter.TD.gain = 0;
    TDFlag = 0;
    simout_pure = sim('FBv1_SLOW2DOF_with_TowerDamper.mdl');
    Parameter.TD.gain = 0.0424;
    simoutClassic = sim('FBv1_SLOW2DOF_with_TowerDamper.mdl');
    Parameter.TD.gain = 0.00085;
    TDFlag = 1;
    simout = sim('FBv1_SLOW2DOF_with_TowerDamper.mdl');
    t = simoutClassic.tout;
    FlagFiltertype = 0;             % Lead-Lag:= 1; Lag:= 0
    simout_lag = sim('FBv1_SLOW2DOF_with_TowerDamper.mdl');

    % Spectrum analysis
    % estimate spectra
    nBlocks                 = 6;
    SamplingFrequency       = 1/Parameter.Time.dt;
    nDataPerBlock           = round(length(t)/nBlocks);
    M_yT_pure               = simout_pure.logsout.get('y').Values.M_yT.Data;
    [S_M_yT_pure,~]         = pwelch(detrend(M_yT_pure,  'constant'),nDataPerBlock,[],[],SamplingFrequency);
    M_yT_ref                = simoutClassic.logsout.get('y').Values.M_yT.Data;
    [S_M_yT_ref,~]          = pwelch(detrend(M_yT_ref,  'constant'),nDataPerBlock,[],[],SamplingFrequency);
    M_yT_est_lag            = simout_lag.logsout.get('y').Values.M_yT.Data;
    [S_M_yT_est_lag,~]      = pwelch(detrend(M_yT_est_lag,  'constant'),nDataPerBlock,[],[],SamplingFrequency);
    M_yT_est                = simout.logsout.get('y').Values.M_yT.Data;
    [S_M_yT_est,f_est]      = pwelch(detrend(M_yT_est,  'constant'),nDataPerBlock,[],[],SamplingFrequency);
    
    figure
    hold on;grid on;box on
%     title('Spectrum of the tower base bending moment')
    plot(f_est,S_M_yT_pure)
    plot(f_est,S_M_yT_ref)
%     plot(f_est,S_M_yT_est)
    plot(f_est,S_M_yT_est_lag)
    set(gca,'xScale','log')
    set(gca,'yScale','log')
    ylabel('[(Nm)^2/Hz]')
    legend('No TD','TD: Integrator','TD: Lag-Compensator','Location','best')
    xlabel('frequency [Hz]')
end






