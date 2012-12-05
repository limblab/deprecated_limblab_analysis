%this file assumes a snippet length of 32 samples


%get name of file to convert
[fname,fpath]=uigetfile('*.plx', 'Select file to convert');
filename=strcat(fpath,fname);
fullread=1;%bool setteing whether to scan the whole file or just the header
%read basic file information:
[tscounts, wfcounts, evcounts] = plx_info(filename, fullread);
%extract number of channels and units from basic info:
[numunits,numchans]=size(tscounts);

%set neuralynx write parameters:
AppendToFileFlag=1;%1 overwrites 0 appends
ExportMode=1;% 1 exports all data
ExportModeVector=[]; %ignored with ExportMode=1
FieldSelectionFlags=[1 1 1 1 1 0];%exports timestamps,spike channel numbers, cell numbers,spike features,and samples. does not export header
Header=[];
data=[];

numspikesbychan=sum(tscounts,1);
%isolate single channel of data
for channel=1:numchans
    %if this channel has any data loop through each unit
    if (numspikesbychan(channel)>0)
        %concatenate data from each unit on that channel:
        for unit=1:numunits
            if tscounts(unit,channel)>0 %ignore the unit if there are no spikes
                disp(strcat('Reading channel: ',num2str(channel),' unit: ',num2str(unit)))
                disp(strcat('Expecting: ',num2str(tscounts(unit,channel)),' snippets'))
                [n, npw, ts, wave] = plx_waves(filename, channel-1, unit-1);
                %rescale wave so that neuralynx will display it properly:
                wave=wave*10;
                disp(strcat('Read in: ', num2str(n),' snippets'))
                %compute features
                %max
                features=zeros(n,1);
                features(:,1)=max(wave(:,1:8),[],2);
                %min
                features(:,2)=min(wave(:,1:8),[],2);
                %height of the AP:
                features(:,3)=features(:,1)-features(:,2);
                %energy
                tmp1=wave(:,2:31);
                tmp2=wave(:,1:30);
                tmp3=wave(:,3:32);
                features(:,4)=sum(tmp1.*tmp1-tmp2.*tmp3,2)/32;
                features(:,5:8)=wave(:,[4 8 16 24]);
%                 features=zeros(n,8);%dummy to be replaced with real feature calculations
                %assemble data array from imported arrays
                data=[data;ts, unit*ones(n,1), features, wave];
            end
        end
    
        %sort data by timestamp to get into neuralynx format
        data=sortrows(data,1);
        %set filename to write:
        filename2=strcat(filename(1:end-4),'_ch',num2str(channel),'.nse');
        disp(strcat('writing new data file: ',filename2))

        %%export data to .nlx file
        Timestamps=1000000*data(:,1)';
        ScNumbers=Timestamps*0;
        CellNumbers=data(:,2)';
        Features=data(:,3:10)';
        Samples=zeros(32,1,length(Timestamps));
        Samples(:,1,:)=data(:,11:end)';%convert mV to fV
        Mat2NlxSpike( filename2, AppendToFileFlag, ExportMode, ExportModeVector,FieldSelectionFlags, Timestamps, ScNumbers, CellNumbers,Features, Samples, Header);
        data=[];
    end
end







