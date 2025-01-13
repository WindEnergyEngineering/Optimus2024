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

    f_Tower         = 0.28;                             % [Hz]      Eigenfrequency of the Tower

    % LP Design
    f_c_LP = f_Tower;%0.5;
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
    xline(f_Tower*2*pi)

    % HP Design
    f_c_HP = f_Tower;%0.2;
    w_0_HP = f_c_HP*2*pi;
    num_HP = [1 0];
    denum_HP = [1 w_0_HP];
    H_HP = tf(num_HP,denum_HP)
    disp('--- HP-Filter ---------------------------------------------')
    damp(H_HP)
    disp('---------------------------------------------------------------------')
    figure
    grid on; hold on;
    bode(H_HP)
    xline(f_Tower*2*pi)

    % Lag
    phase_target_deg = -30;             %[deg]
    [z,p] = calculate_lag_compensator(f_Tower,phase_target_deg);
    T_1 = -0.125;
    T_2 = -100;
    H_Lag = tf([1 z],[1 p])
    disp('--- Lag-Filter ---------------------------------------------')
    damp(H_Lag)
    disp('---------------------------------------------------------------------')
    figure
    grid on; hold on;
    bode(H_Lag)
    xline(f_Tower*2*pi)
    
    
    % PZ map
    figure
    hold on
    pzmap(H_Lag)

    % Pitch Actuator (PT-2)
    omega = Parameter.PitchActuator.omega;
    D = Parameter.PitchActuator.xi;
    H_PA = tf([omega^2],[1 2*D*omega omega^2])
    disp('--- Pitch Actuator ---------------------------------------------')
    damp(H_PA)
    disp('---------------------------------------------------------------------')
    figure
    grid on; hold on;
    bode(H_PA)
    xline(f_Tower*2*pi)
    
    % Connect the model
    % Name inputs and outputs for each block
    H_LP.InputName = 'x_dotdot';
    H_LP.OutputName = 'x1_dotdot';
    
    H_HP.InputName = 'x1_dotdot';
    H_HP.OutputName = 'x2_dotdot';
    
    H_Lag.InputName = 'x2_dotdot';
    H_Lag.OutputName = 'Theta_TD';
    
    H_PA.InputName = 'Theta_TD';  % Input to Pitch Actuator is the sum of Theta (TD-Filter) and Theta_c (Out of CPC)
    H_PA.OutputName = 'Theta';
    
    
    
    % Connect all systems
    % Specify overall system inputs as {'x_dotdot', 'Theta_c'} and outputs as {'y'}
    Sys = connect(H_LP,  H_HP, H_Lag , H_PA, {'x_dotdot'}, {'Theta'});
    
    % Bode plot
    figure
    bodeplot(Sys);
    grid on; hold on;
    xline(f_Tower*2*pi)
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

    % No TD but real PA (Pitch Actuator)
    Parameter.TD.gain = 0;
    simout_pure = sim('FBv1_SLOW2DOF_TD_PA.mdl');
    
    % No PA Integrator
    Parameter.TD.gain = 0.0424;
    simout_ideal = sim('FBv1_SLOW2DOF_with_TowerDamper.mdl');
    
    t = simout_ideal.tout;
    x_dotdot = simout_ideal.logsout.get('y').Values.x_T_dotdot.Data;
    x_dot = simout_ideal.logsout.get('y').Values.x_T_dot.Data;

    % PA + Lag filter string
    %Parameter.TD.gain = 0.00085;
    Parameter.TD.gain = Parameter.TD.gain / 15;
    simout_lag = sim('FBv1_SLOW2DOF_TD_PA.mdl');
    x_dot_lag = simout_lag.logsout.get('y').Values.x_T_dot.Data;

    % Plot Results
    figure
    title('Tower Top Speed (1 m/s Wind Step Response)')
    hold on; grid on;
    plot(simout_pure.tout,simout_pure.logsout.get('y').Values.x_T_dot.Data)
    plot(t,x_dot)
    plot(simout_lag.tout,x_dot_lag)
    ylabel('$\dot x_T$ [m/s]','Interpreter','latex')
    xlabel('$t$ [s]','Interpreter','latex')
    xlim([0 40])
    legend('No TD','TD: Integrator NO PA','TD: Lag-Compensator',Location='best')
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
    Parameter.TD.gain = 0;
    simout_pure = sim('FBv1_SLOW2DOF_TD_PA.mdl');
    Parameter.TD.gain = 0.0424;
    simout_ideal = sim('FBv1_SLOW2DOF_with_TowerDamper.mdl');
    Parameter.TD.gain = Parameter.TD.gain / 15;    
    simout_lag = sim('FBv1_SLOW2DOF_TD_PA.mdl');
    t = simout_ideal.tout;

    % Spectrum analysis
    % estimate spectra
    nBlocks                 = 6;
    SamplingFrequency       = 1/Parameter.Time.dt;
    nDataPerBlock           = round(length(t)/nBlocks);
    M_yT_pure               = simout_pure.logsout.get('y').Values.M_yT.Data;
    [S_M_yT_pure,~]         = pwelch(detrend(M_yT_pure,  'constant'),nDataPerBlock,[],[],SamplingFrequency);
    M_yT_ref                = simout_ideal.logsout.get('y').Values.M_yT.Data;
    [S_M_yT_ref,~]          = pwelch(detrend(M_yT_ref,  'constant'),nDataPerBlock,[],[],SamplingFrequency);
    M_yT_est_lag            = simout_lag.logsout.get('y').Values.M_yT.Data;
    [S_M_yT_est_lag,f_est]      = pwelch(detrend(M_yT_est_lag,  'constant'),nDataPerBlock,[],[],SamplingFrequency);
    
    
    figure
    hold on;grid on;box on
    title('Spectrum of the Tower Base Bending Moment')
    plot(f_est,S_M_yT_pure)
    plot(f_est,S_M_yT_ref)
    plot(f_est,S_M_yT_est_lag)
    set(gca,'xScale','log')
    set(gca,'yScale','log')
    ylabel('[(Nm)^2/Hz]')
    legend('No TD','TD: Integrator NO PA','TD: Lag-Compensator','Location','best')
    xlabel('frequency [Hz]')
end






