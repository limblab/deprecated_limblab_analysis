function [figures,data]=testEncoderSkips(folderPath)
    %intended to be called from run_data_processing
    %testEncoderSkips accepts a folder path, and a structure containing
    %input data.  Scans the current folder for nev files. If a shortcut is
    %encountered, follows the link and then checks whether the target file
    %is an NEV

    figures=[];
    foldercontents=dir(folderPath);
    fnames={foldercontents.name};%extracts just the names from the foldercontents
    data.fileList={};
    data.numPoints=[];
    data.allSteps=[];
    data.tSteps=[];
    data.minSteps=[];
    data.maxSteps=[];
    data.stepHists=[];
    bins=0:.01:1.95;
    for i=1:length(foldercontents)
        if (length(fnames{i})>3)
            if exist(strcat(folderPath,fnames{i}),'file')~=2
                continue
            end
            temppath=follow_links(strcat(folderPath,fnames{i}));
            [~,fname,tempext]=fileparts(temppath);
            if strcmp(tempext,'.nev') 
                data.fileList{end+1}=temppath;
                try
                    disp(strcat('Working on: ',temppath))
                    NEV=openNEVLimblab('read', temppath,'nosave');
                    disp('   opened NEV, clearing spikes to free up memory')
                    NEV.Data.Spikes=[];
                    disp('   reading event data')
                    event_ts = NEV.Data.SerialDigitalIO.TimeStampSec';       
                    event_data = double(NEV.Data.SerialDigitalIO.UnparsedData);
                    DateTime = [int2str(NEV.MetaTags.DateTimeRaw(2)) '/' int2str(NEV.MetaTags.DateTimeRaw(4)) '/' int2str(NEV.MetaTags.DateTimeRaw(1)) ...
                    ' ' int2str(NEV.MetaTags.DateTimeRaw(5)) ':' int2str(NEV.MetaTags.DateTimeRaw(6)) ':' int2str(NEV.MetaTags.DateTimeRaw(7)) '.' int2str(NEV.MetaTags.DateTimeRaw(8))];
                    duration=NEV.MetaTags.DataDurationSec;
                    disp('   events loaded, clearing NEV')
                    clear NEV
                    disp('   computing encoder values from event strobes')
                    %clear off the beginning of the data if the timestamps
                    %reset:
                    dn = diff(event_ts);
                    if any(dn<0) %test whether there was a ts reset in the file
                        idx = find(dn<0,1,'last');
                        if length(idx)>1
                            warning('skip_resets:MultipleResets', ['timeseries contains more than one ts reset.'...
                                    'Only the data after the last reset is extracted.']);
                        end
                    else
                        idx=[];%if there were no resets, set the index to empty
                    end
                    if ~isempty(idx)
                        event_data = event_data( (idx(end)+1):end);
                        event_ts   = event_ts(   (idx(end)+1):end);
                    end
                    clear idx;
                    
                    
                    %get encoder data from serial digital data:
                    if datenum(DateTime) - datenum('14-Jan-2011 14:00:00') < 0 
                        % The input cable for this time was bugged: Bits 0 and 8
                        % are swapped.  The WORD is mostly on the high byte (bits
                        % 15-9,0) and the ENCODER is mostly on the
                        % low byte (bits 7-1,8).
                        encStrobes = [event_ts, bitand(hex2dec('00FE'),event_data) + bitget(event_data,9)];
                    else
                        %The WORD is on the high byte (bits
                        % 15-8) and the ENCODER is on the
                        % low byte (bits 8-1).
                        encStrobes = [event_ts, bitand(hex2dec('00FF'),event_data)];
                    end   

                    %now that we have the encoder strobes, convert those to actual encoder values  
                    enc = strb2enc(encStrobes,[0 duration]);
                    clear encStrobes
                    disp('   computing timing and making histograms')

                    tSteps=diff(enc(:,1));
                    data.allSteps=[data.allSteps;tSteps];
                    data.numPoints(end+1)=numel(tSteps);
                    data.minSteps(end+1)=min(tSteps);
                    data.maxSteps(end+1)=max(tSteps);
                    %tSteps=tSteps(tSteps>mode(tSteps));
                    
                    %get the breakdown of sample spacing for this specific
                    %file
                    data.stepHists(end+1,:)=hist(tSteps,bins);
                    %plot the histogram and set the figure properties
                    h=figure;
                    bar(bins,data.stepHists(end,:));
                    set(gca,'YScale','log')
                    set(h,'Name',['Hist_',fname])
                    set(h,'Position',[100 100 1200 1200])
                    title(['Histogram of lags between data points ',fname])
                    xlabel('latency between samples(s)')
                    ylabel('log count of number of points')
                    %write figure out and close it so we don't have to keep all the figures
                    %in active memory:
                    fname(fname==' ')='_';%replace spaces in name for saving
                        print('-dpdf',h,strcat(folderPath,'Raw_Figures\PDF\',fname,'.pdf'))
                        print('-deps',h,strcat(folderPath,'Raw_Figures\EPS\',fname,'.eps'))
                        print('-dpng',h,strcat(folderPath,'Raw_Figures\PNG\',fname,'.png'))
                        saveas(h,strcat(folderPath,'Raw_Figures\FIG\',fname,'.fig'),'fig')
                    close(h)
                     
                catch temperr
                    disp(strcat('Failed to process: ', temppath))
                    disp(temperr.identifier)
                    disp(temperr.message)
                    for k=1:length(temperr.stack)
                        disp(['in function: ',temperr.stack(k).name])
                        disp(['on line: ',num2str(temperr.stack(k).line)])
                    end
                end
            end
        end
    end
    %get histogram data for the whole data set:
    %file
    bins=[0:.01:ceil(data.allSteps)];
    data.allNumPoints=numel(data.allSteps); 
    data.allHist=hist(data.allSteps,bins);
    %plot the histogram and set the figure properties
    figures(end+1)=figure;
    bar(bins,data.allHist);
    set(gca,'YScale','log')
    set(figures(end),'Name','Hist_All_Data')
    set(figures(end),'Position',[100 100 1200 1200])
    title(['Histogram of lags between data points for all data'])
    xlabel('latency between samples(s)')
    ylabel('log count of number of points')
      
end
function varargout = strb2enc(strobed_events,varargin)
    if ~isempty(varargin)
        %variable input used to pass times that this function will ignore step
        %shifts in the output. particularly important for ignoring shifts that
        %occur when files are concatenated together.
        ignore_windows=varargin{1};
    else
        ignore_windows=[];
    end

    if (size(strobed_events,2) ~= 2)
        error('get_encoder:BadMatrix','input strobed_events must be a two column matrix');
    end

    % get time-stamps of the first strobe in a set of four
    ts = strobed_events(:,1);
    ts_index = find( diff(ts) > .000275 )+1;
    ts_index = ts_index( diff(ts_index) == 4 ); % throw out bad points
    time_stamps = ts( ts_index );

    %make mask vector to use as flag for ignoring timepoints
    mask=ones(size(time_stamps));
    temp=[];
    if ~isempty(ignore_windows)
        for i=1:size(ignore_windows,1)
            range=[find(time_stamps>=ignore_windows(i,1),1,'first'),find( time_stamps<=ignore_windows(i,2),1,'last')];
            %if there are no points inside the window, as the case with
            %fileseparateions, the first point of range will be larger than the
            %second. Thus we use min and max to get the actual window for all
            %cases
            temp=[temp;[min(range):max(range)]'];
        end
        mask(temp)=0;
    end

    % assemble encoder signals
    encoder = zeros(length(ts_index)-2, 3);
    if (length(ts_index)-2>=1)
        encoder(:,1) = time_stamps(1:end-2);
        encoder(:,2) = strobed_events(ts_index(1:end-2),2) + strobed_events(ts_index(1:end-2)+1,2)*2^8 - 32765;
        encoder(:,3) = strobed_events(ts_index(1:end-2)+2,2) + strobed_events(ts_index(1:end-2)+3,2)*2^8 - 32765;
    end

    %fix steps in encoder 1
    temp_indices = find( (diff(encoder(:,2))>50 | diff(encoder(:,2))<-50) & mask(1:end-3));
    data_jumps=0;
    jump_times=encoder(temp_indices,1);
    if ~isempty(temp_indices)
        for i=length(temp_indices):-1:1
            if mask(temp_indices(i))
                encoder(temp_indices(i)+1:end,2) = encoder(temp_indices(i)+1:end,2)-(encoder(temp_indices(i)+1,2)-encoder(temp_indices(i),2));
            end
        end
        data_jumps=length(temp_indices);
    end

    %fix steps in encoder 2
    temp_indices = find( (diff(encoder(:,3))>50 | diff(encoder(:,3))<-50) & mask(1:end-3));
    jump_times=[jump_times;encoder(temp_indices,1)];
    if ~isempty(temp_indices)
        for i=length(temp_indices):-1:1
            if mask(temp_indices(i))
                encoder(temp_indices(i)+1:end,3) = encoder(temp_indices(i)+1:end,3)-(encoder(temp_indices(i)+1,3)-encoder(temp_indices(i),3));
            end
        end
        data_jumps=data_jumps+length(temp_indices);
    end

    if data_jumps
        warning('get_encoder:corruptEncoderSignal','The encoder data contains large jumps. These jumps were removed in get_encoder')
        disp(['Found',num2str(data_jumps),' step offsets in the data'])
        if ~isempty(ignore_windows)
            disp('Steps associated with some time points such as file concatination times may have been ignored')
        end
    end
    varargout{1}=encoder;
    if nargout>1
        varargout{2}=jump_times;
    end
end