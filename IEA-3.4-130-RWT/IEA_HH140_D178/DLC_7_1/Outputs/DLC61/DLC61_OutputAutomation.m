clearvars;
%% Processing FAST
extreeeeme = configureDictionary("string","double");
for h = 1:6
    OutputFile  = "OPT-MP-V37_S"+h+".out";

    % PostProcessing FAST
    Loads = ["Time" 'YawPzn' 'Wind1VelX' 'BldPitch1'	'BldPitch2'	'BldPitch3'	'Azimuth'	'RotSpeed'	'RotTorq'	'RotPwr'	'HSSBrTq'	'TipClrnc1'	'TipClrnc2'	'TipClrnc3'	'TTDspFA'	'TTDspSS'	'RootFxb1'	'RootFyb1'	'RootFzb1'	'RootMxb1'	'RootMyb1'	'RootMzb1'	'RootFxc1'	'RootFyc1'	'RootMxc1'	'RootMyc1'	'LSShftFxa'	'LSShftFya'	'LSShftFza'	'LSShftMxa'	'LSSTipMya'	'LSSTipMza'	'LSShftFys'	'LSShftFzs'	'LSSTipMys'	'LSSTipMzs'	'YawBrFxp'	'YawBrFyp'	'YawBrFzp'	'YawBrMxp'	'YawBrMyp'	'YawBrMzp'	'TwrBsFxt'	'TwrBsFyt'	'TwrBsFzt'	'TwrBsMxt'	'TwrBsMyt'	'TwrBsMzt'];
    fid         = fopen(OutputFile);
    formatSpec  = repmat('%f',1,48);
    FASTResults = textscan(fid,formatSpec,'HeaderLines',8);
    Load_Table = dictionary(Loads, FASTResults);
    fclose(fid);
    
    % Root 
    Root = Load_Table(Loads(17:26));
    m= 1; 
    for i = 1:length(Root)   %Maximum/Minimum von Load i // i = Loadvariable für die Zeile
        clear max_Root min_Root max_num min_num
        max_num = find(Root{:,i}==max(Root{:,i}));     %Zeilennummer der maxima  
        min_num = find(Root{:,i}==min(Root{:,i}));
            for j = 1:length(Root)                      % j = Loadvariable für die Spalte 
                for k = 1:length(max_num)               % k = Reihenzahl der maxima und minima 
                    max_Root(k,j)=Root{j}(max_num(k));  % maximum der loads mit dem maximalen Wert für Load i
                end
                for k = 1:length(min_num)
                    min_Root(k,j)=Root{j}(min_num(k));
                end
            end
            
            if length(max_num) == 1                 %Erstbesetzung der extreme Root loads
                extreme_Root(m,:)= max_Root;
            else
                extreme_Root(m,:) = max(max_Root);
            end 
            if length(min_num) == 1 
                extreme_Root(m+1,:)= min_Root;
            else 
                extreme_Root(m+1,:)= min(min_Root);
            end 

        m= m+2;
    end
    
    % Yaw Bearing 
    TowerTop = Load_Table(Loads(37:42));
    m= 1; 
    for i = 1:length(TowerTop)   %Maximum/Minimum von Load i // i = Loadvariable für die Zeile
        clear max_TT min_TT max_num min_num
        max_num = find(TowerTop{:,i}==max(TowerTop{:,i}));     %Zeilennummer der maxima  
        min_num = find(TowerTop{:,i}==min(TowerTop{:,i}));
        for j = 1:length(TowerTop)                      % j = Loadvariable für die Spalte 
            for k = 1:length(max_num)               % k = Reihenzahl der maxima und minima 
                max_TT(k,j)=TowerTop{j}(max_num(k));  % maximum der loads mit dem maximalen Wert für Load i
            end
            for k = 1:length(min_num)
                min_TT(k,j)=TowerTop{j}(min_num(k));
            end
        end
        if length(max_num) == 1                 %Erstbesetzung der extreme Root loads
            extreme_TT(m,:)= max_TT;
        else
            extreme_TT(m,:) = max(max_TT);
        end 
        if length(min_num) == 1 
            extreme_TT(m+1,:)= min_TT;
        else 
            extreme_TT(m+1,:)= min(min_TT);
        end 
        m= m+2;
    end

    % TowerBottom 
    TowerBottom = Load_Table(Loads(43:48));
    m= 1; 
    for i = 1:length(TowerBottom)   %Maximum/Minimum von Load i // i = Loadvariable für die Zeile
        clear max_TB min_TB max_num min_num
        max_num = find(TowerBottom{:,i}==max(TowerBottom{:,i}));     %Zeilennummer der maxima  
        min_num = find(TowerBottom{:,i}==min(TowerBottom{:,i}));
        for j = 1:length(TowerBottom)                      % j = Loadvariable für die Spalte 
            for k = 1:length(max_num)               % k = Reihenzahl der maxima und minima 
                max_TB(k,j)=TowerBottom{j}(max_num(k));  % maximum der loads mit dem maximalen Wert für Load i
            end
            for k = 1:length(min_num)
                min_TB(k,j)=TowerBottom{j}(min_num(k));
            end
        end
        if length(max_num) == 1                 %Erstbesetzung der extreme Root loads
            extreme_TB(m,:)= max_TB;
        else
            extreme_TB(m,:) = max(max_TB);
        end 
        if length(min_num) == 1 
            extreme_TB(m+1,:)= min_TB;
        else 
            extreme_TB(m+1,:)= min(min_TB);
        end 
        m= m+2;
    end
    writematrix(Loads(17:26),"Extreme"+h+".txt",'Delimiter','tab');
    writematrix(extreme_Root,"Extreme"+h+".txt",'WriteMode','append','Delimiter','tab');
    writematrix(Loads(37:42),"Extreme"+h+".txt",'WriteMode','append','Delimiter','tab');
    writematrix(extreme_TT,"Extreme"+h+".txt",'WriteMode','append','Delimiter','tab');
    writematrix(Loads(43:48),"Extreme"+h+".txt",'WriteMode','append','Delimiter','tab');
    writematrix(extreme_TB,"Extreme"+h+".txt",'WriteMode','append','Delimiter','tab');
    All_extreme_Root{h} = extreme_Root;
    All_extreme_TT{h} = extreme_TT;
    All_extreme_TB{h} = extreme_TB;
end
%%
for i = 1:length(All_extreme_Root{1}(1,:))
    for j = 1:length(All_extreme_Root{1}(:,1))
        for k = 1:length(All_extreme_Root)
            new_value(k) = All_extreme_Root{k}(j,i);
        end
        new_extreme_Root(j,i)=mean(new_value);
    end
end
for i = 1:length(All_extreme_TT{1}(1,:))
    for j = 1:length(All_extreme_TT{1}(:,1))
        for k = 1:length(All_extreme_TT)
            new_value(k) = All_extreme_TT{k}(j,i);
        end
        new_extreme_TT(j,i)=mean(new_value);
    end
end
for i = 1:length(All_extreme_TB{1}(1,:))
    for j = 1:length(All_extreme_TB{1}(:,1))
        for k = 1:length(All_extreme_TB)
            new_value(k) = All_extreme_TB{k}(j,i);
        end
        new_extreme_TB(j,i)=mean(new_value);
    end
end
writematrix(Loads(17:26),"Extreme.txt",'Delimiter','tab');
writematrix(new_extreme_Root,"Extreme.txt",'WriteMode','append','Delimiter','tab');
writematrix(Loads(37:42),"Extreme.txt",'WriteMode','append','Delimiter','tab');
writematrix(new_extreme_TT,"Extreme.txt",'WriteMode','append','Delimiter','tab');
writematrix(Loads(43:48),"Extreme.txt",'WriteMode','append','Delimiter','tab');
writematrix(new_extreme_TB,"Extreme.txt",'WriteMode','append','Delimiter','tab');
