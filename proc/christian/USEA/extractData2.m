function IOcurves = extractData2()

    %Create a matlab structure from a bunch of .ns4 files recorded during USEA
    %experiments

    %% Find Data log and .ns4 Files

    % prompt user...
    baseDir = 'Y:\archive\Retired_Monkeys\Keedoo_9I3\USEA\';
    [filename, filepath] = uigetfile([baseDir '*.log'],'Select Stimulation Log File');
    logfile = fullfile(filepath,filename);
    Datadir = uigetdir(baseDir,'Where are the .ns4 files?');

    %...or use test file:
    % logfile = 'Y:\archive\Retired_Monkeys\Keedoo_9I3\USEA\results\20110906_Day0\RecruitmentRoutine_Results_20110906-1323_-4V\StimulationLog_20110906-1323.log';
    % Datadir = 'Y:\archive\Retired_Monkeys\Keedoo_9I3\USEA\data\RecruitmentRoutine_DataFiles_20110906-1323_-4V';

    NS4Files = dir(fullfile(Datadir,'*.ns4'));
    NumFiles = length(NS4Files);
    %% Allocate struct
    for i=1:100
        IOcurves.electrode(i) = struct('PW',[],'Filenames',[],'EMGdata',[],'StimData',[],'mWaves',[],'maxmWaves',[]);
        IOcurves.maxmWaves = [];
    end

    %% Import data log

    fid = fopen(logfile);
    % move down six lines to skip header
    for i=1:6 fgetl(fid);
    end

    %line example: -t- Median -t- 1 -t- 512.0 -t- 0.0 -t- 0.0 -t-t- Fidel_08-31-11_io_3p0v_001.ns4 -t-t- 20110831-1300
    %where -t- are tabs

    while true
        tline = fgetl(fid);
        if (tline <0)
            %eof
            break;
        end
        tabs = find(tline==sprintf('\t'));

        if ~tabs
            continue;
        end

        elec = str2double(tline(tabs(2)+1:tabs(3)-1));
        PW   = str2double(tline(tabs(3)+1:tabs(4)-1));
        T    = str2double(tline(tabs(4)+1:tabs(5)-1));
        D    = str2double(tline(tabs(5)+1:tabs(6)-1));
        NSxFileName =    (tline(tabs(7)+1:tabs(8)-1));
        DateTimeStamp=    tline(tabs(9)+1:end);

        IOcurves.electrode(elec).PW = [IOcurves.electrode(elec).PW; PW];
        IOcurves.electrode(elec).Filenames = [IOcurves.electrode(elec).Filenames; NSxFileName];

        %Extract data from .ns4 files
        tmpData = openNSx('read',fullfile(Datadir, NSxFileName),'p:double');
        if isempty(tmpData)
            warning(sprintf('Could not find file: %s', NSxFileName));
            continue;
        end
        IOcurves.electrode(elec).EMGdata = [IOcurves.electrode(elec).EMGdata; tmpData];
        mWaves = calcMWave2(tmpData.Data');
        if isempty(mWaves)
            fprintf('No stim detected for elec %d, file %s\n', elec, NSxFileName);
            IOcurves.electrode(elec).PW = IOcurves.electrode(elec).PW(1:end-1);
            IOcurves.electrode(elec).EMGdata = IOcurves.electrode(elec).EMGdata(1:end-1,:);
            IOcurves.electrode(elec).Filenames = IOcurves.electrode(elec).Filenames(1:end-1,:);
            continue;
        end
        IOcurves.electrode(elec).mWaves   =  [IOcurves.electrode(elec).mWaves; mWaves];
        if isempty(IOcurves.electrode(elec).maxmWaves)
            IOcurves.electrode(elec).maxmWaves = mWaves;
        else IOcurves.electrode(elec).maxmWaves = max(IOcurves.electrode(elec).maxmWaves,mWaves);
        end
        if isempty(IOcurves.maxmWaves)
            IOcurves.maxmWaves = mWaves;
        else
            IOcurves.maxmWaves = max(IOcurves.maxmWaves,mWaves);
        end
    end
    fclose(fid);    

    %% Normalize

    for elec=1:100
        if ~isempty(IOcurves.electrode(elec).mWaves)
            for i=1:size(IOcurves.electrode(elec).mWaves,1)
                IOcurves.electrode(elec).normalized(i,:)=IOcurves.electrode(elec).mWaves(i,:)./IOcurves.maxmWaves;
            end
        end
    end

    [filename,filepath] = uiputfile( fullfile(Datadir,'IOCurves'), 'Save file');
    fprintf('saving file...');
    save(fullfile(filepath,filename),'IOcurves');
    fprintf('done\n');

end
% 
% 
% Datadir = uigetdir(baseDir,'Where are the .ns4 files?');
% 
% NS4Files = dir(fullfile(Datadir,'*.ns4'));
% NumFiles = length(NS4Files);
% 
% for i = 1:NumFiles
%     
%         
%     DATA = openNSx('read',fullfile(Datadir, NS4Files(i).name),'p:double');
% 
%     
% 
% emgNumber = size(tempData.Data,1);
% inputText = ['c:' num2str(emgNumber)];
% inputText1 = ['c:1:' num2str(emgNumber-1)];
% 
% % %% Import data to struct
% % for i=1:size(NUM,1)
% %     
% %     if isempty(IOcurves.electrode(NUM(i,1)).PW)==1
% %         IOcurves.electrode(NUM(i,1)).PW = NUM(i,2);
% %         IOcurves.electrode(NUM(i,1)).Filename = filenames(i);
% %         IOcurves.electrode(NUM(i,1)).EMGdata = openNSx('read',[baseDir filenames{i}],'p:double');
% %         IOcurves.electrode(NUM(i,1)).EMGdata.Data = IOcurves.electrode(NUM(i,1)).EMGdata.Data';
% %     else
% %         IOcurves.electrode(NUM(i,1)).PW = [IOcurves.electrode(NUM(i,1)).PW ; NUM(i,2)];
% %         IOcurves.electrode(NUM(i,1)).Filename = [IOcurves.electrode(NUM(i,1)).Filename ; filenames(i)];
% %         tempData = openNSx('read',[baseDir filenames{i}],inputText1,'p:double');
% %         tempData.Data = tempData.Data';
% %         IOcurves.electrode(NUM(i,1)).EMGdata = [IOcurves.electrode(NUM(i,1)).EMGdata ; tempData];
% %     end
% % end
% 
% %% Calculate mWave
% for i=1:size(NUM,1)
%     tempDataStim = openNSx('read',[baseDir filenames{i}],inputText,'p:double');
%     tempEMG = openNSx('read',[baseDir filenames{i}],inputText1,'p:double');
%     
%     if i==1
%         IOcurves.electrode(NUM(i,1)).StimData = tempDataStim.Data';
%         IOcurves.electrode(NUM(i,1)).mWave = calcMWave(tempEMG.Data', tempDataStim.Data',emgNumber,NUM(i,1));
%     else
%         IOcurves.electrode(NUM(i,1)).StimData = [IOcurves.electrode(NUM(i,1)).StimData ; tempDataStim];
%         IOcurves.electrode(NUM(i,1)).mWave = [IOcurves.electrode(NUM(i,1)).mWave ; calcMWave(tempEMG.Data',tempDataStim.Data',emgNumber,NUM(i,1))];
%     end
%     
%     IOcurves.electrode(NUM(i,1)).maxmWave = max(IOcurves.electrode(NUM(i,1)).mWave,[],1);
% end
% 
% %% Normalization
% IOcurves.norm = zeros(1,emgNumber-1);
% for j=1:100
%     for i=1:emgNumber-1
%         
%         if IOcurves.norm(1,i) < IOcurves.electrode(1,j).maxmWave(1,i)
%             IOcurves.norm(1,i) = IOcurves.electrode(1,j).maxmWave(1,i);
%         end
%     end
% end
% 
% %% Plotting normalized data
% plots=zeros(100,1);
% for i=1:100
%     IOcurves.electrode(i).normalized = normalize(IOcurves.electrode(i),IOcurves.norm);
%     plots(i,1) = scatterPlot( IOcurves.electrode(i),emgNumber,i);
% end
% 
% %% Remember which electrodes are plotted
% plots(plots == 0) = [];
% IOcurves.plots = plots;
% 
% %% Selectivity
% %selec = [];
% for i=1:size(plots,1)
%     IOcurves.electrode(plots(i)).selectivity = selectivity(IOcurves.electrode(plots(i)),emgNumber);
% end
% 
% %% Clean up
% clearvars -except IOcurves
% uisave