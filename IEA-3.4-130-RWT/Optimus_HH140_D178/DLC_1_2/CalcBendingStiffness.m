% -----------------------------
% Script: Tool to plot the openfast result file.
% In this raw version the windspeed, rotational speed, Power and tower top
% deflection are plotted. See OutListParameters.xlsx for a listing of available output channels
% ------------
% Modified:
% 
% ------------
% History: 
% Felix Lehmann on 29-09-2024
% ----------------------------------
% References:
% - used model: IEA-3.4-130-RWT
% - code based on: SummerGames2024 IEA Task52

clearvars;close all;
%% select wind speed range
wind = 3:0.5:6; % wind speed range
%% Generate FAST simulation outputs
for i = 1:length(wind)
    
    % find parameter placeholder in inflow file and replace with wind speed
    windstr = num2str(wind(i),'%02.1f');
    filename = 'TemplateIEA-3.4-130-RWT_InflowFile.dat';
    new_filename = 'IEA-3.4-130-RWT_InflowFile.dat';
    S = fileread(filename);
    S = regexprep(S, 'PlaceholderWind', windstr); % replace with wind speed
    fid = fopen(new_filename, 'w');
    fwrite(fid, S);
    fclose(fid);
    
    % run FAST
    dos('.\openfast_x64.exe IEA-3.4-130-RWT.fst');
    
    % rename output and move file to output directory
    OutputFile  = 'IEA-3.4-130-RWT.out';
    new_filename = "OutputFiles\" + "IEA-3.4-130-RWT" + num2str(wind(i),'%02.1f') + ".out";
    movefile(OutputFile,new_filename);
end

%% PostProcessing FAST
V_test = wind;

StadyStatesFAST.v_0     = zeros(1,length(V_test));
StadyStatesFAST.Omega   = zeros(1,length(V_test));
StadyStatesFAST.theta   = zeros(1,length(V_test));
StadyStatesFAST.x_t     = zeros(1,length(V_test));
StadyStatesFAST.M_g     = zeros(1,length(V_test));
StadyStatesFAST.F_a     = zeros(1,length(V_test));


for idx = 1:length(V_test)
    FileName = ['IEA-3.4-130-RWT',num2str(V_test(idx),'%02.1f')];
    OutputFileFAST = ['OutputFiles\',FileName,'.out'];
%     [Channels, ChanName, ChanUnit, FileID, DescStr] =  ReadFASTbinary(OutputFileFAST);

    fid         = fopen(OutputFileFAST);
    formatSpec  = repmat('%f',1,13);
    FASTResults = textscan(fid,formatSpec,'HeaderLines',8);
    Time        = FASTResults{:,1};
    Wind1VelX   = FASTResults{:,2};
    RotSpeed    = FASTResults{:,4};
    TTDspFA     = FASTResults{:,5};
    TwrTpTDxi   = FASTResults{:,9};
    YawBrTDxp   = FASTResults{:,10};
    RtAeroFxi   = FASTResults{:,11};
    GenPwr      = FASTResults{:,12};
    fclose(fid);

    % last 3 revolutions
    Omega_end   = RotSpeed(end)/60;             % [1/s]
    t_3Rev      = 3 * Omega_end^-1;             % [s]
    dt_FAST     = 0.0125;                       % [s]
    index_t     = round(t_3Rev/dt_FAST);        % [-]

    % Mean of the last 3 revolutions
    % windspeed
    StadyStatesFAST.v_0(idx) = mean(Wind1VelX(index_t:end));
    % Omega
    StadyStatesFAST.Omega(idx) = mean(RotSpeed(index_t:end));    % [rpm]
    % theta
%     StadyStatesFAST.theta(idx) = mean(BldPitch1(index_t:end));   % [deg]
    % Tower top deflection
    StadyStatesFAST.x_t(idx)    = mean(TTDspFA(index_t:end));      % [m]
    StadyStatesFAST.x_ti(idx)   = mean(TwrTpTDxi(index_t:end));      % [m]
    StadyStatesFAST.x_tp(idx)   = mean(YawBrTDxp(index_t:end));      % [m]

    % Generator torque 
%     StadyStatesFAST.M_g(idx) = mean(GenTq(index_t:end));         % [kNm]
    % Aerodynamic force
    StadyStatesFAST.F_a(idx) = mean(RtAeroFxi(index_t:end));     % [Nm]

end
%% Plot FAST Steady States
% figure('Name','Omega')
% hold on;grid on;box on;
% % plot(v_0,radPs2rpm(Omega),'.')
% plot(StadyStatesFAST.v_0,StadyStatesFAST.Omega,'.')
% xlabel('v_0 [m/s]')
% ylabel('\Omega [rpm]')
% legend('SLOW','FAST','Location','southeast')

% figure('Name','theta')
% hold on;grid on;box on;
% plot(v_0,rad2deg(theta),'.')
% plot(StadyStatesFAST.v_0,StadyStatesFAST.theta,'.')
% xlabel('v_0 [m/s]')
% ylabel('\theta [deg]')
% legend('SLOW','FAST','Location','southeast')

% figure('Name','M_g')
% hold on;grid on;box on;
% % plot(v_0,M_g,'.')
% plot(StadyStatesFAST.v_0,StadyStatesFAST.M_g*1e3,'.')
% xlabel('v_0 [m/s]')
% ylabel('M_g [Nm]')
% legend('SLOW','FAST','Location','southeast')

figure('Name','x_T')
hold on;grid on;box on;
% plot(v_0,x_T,'.')
plot(StadyStatesFAST.v_0,StadyStatesFAST.x_t,'.')
xlabel('v_0 [m/s]')
ylabel('x_T [m]')
legend('FAST','Location','southeast')

% figure('Name','Torque Controller')
% hold on;grid on;box on;
% plot(radPs2rpm(Omega),M_g/1e3,'.-')
% plot(StadyStatesFAST.Omega,StadyStatesFAST.M_g,'.-')
% xlabel('Omega [rpm]')
% ylabel('M_g [kNm]')
% legend('SLOW','FAST','Location','southeast')

cut = 0;
x_t = StadyStatesFAST.x_t(1:end-cut);
x_ti = StadyStatesFAST.x_ti(1:end-cut);
x_tp = StadyStatesFAST.x_tp(1:end-cut);
F_a = StadyStatesFAST.F_a(1:end-cut);
figure('Name','tower equvivalent bending stiffness')
hold on;box on;grid on;
plot(x_t,F_a)
plot(x_ti,F_a)
plot(x_tp,F_a)
xlabel('TTDspFA tower top position [m]')
ylabel('RtAeroFxi [N]')
legend('TTDspFA','TwrTpTDxi','YawBrTDxp')

k_t = F_a./(x_t)
mean(k_t)
