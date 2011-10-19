PathFileNames={'Chewie_Spike_LFP_09022011001','Chewie_Spike_LFP_09022011004','Chewie_Spike_LFP_09022011007', ...
    'Chewie_Spike_LFP_09062011001','Chewie_Spike_LFP_09062011005','Chewie_Spike_LFP_09072011001', ...
    'Chewie_Spike_LFP_09072011006','Chewie_Spike_LFP_09082011001','Chewie_Spike_LFP_09082011004', ...
    'Chewie_Spike_LFP_09082011007','Chewie_Spike_LFP_09092011001','Chewie_Spike_LFP_09092011004', ...
    'Chewie_Spike_LFP_09092011007','Chewie_Spike_LFP_09122011002','Chewie_Spike_LFP_09122011005', ...
    'Chewie_Spike_LFP_09192011001','Chewie_Spike_LFP_09192011003','Chewie_Spike_LFP_09262011002', ...
    'Chewie_Spike_LFP_09262011003','Chewie_Spike_LFP_10032011001','Chewie_Spike_LFP_10032011002', ...
    'Chewie_Spike_LFP_10102011001','Chewie_Spike_LFP_10102011002','Chewie_Spike_LFP_10142011001', ...
    'Chewie_Spike_LFP_10172011003','Chewie_Spike_LFP_10172011004'};

beforeAfterFlag={'before','after','after','before','after','before','after','before','after','after', ...
    'before','after','after','before','after','before','after','after','after','before','before', ...
    'before','before','before','after','after'};

if length(beforeAfterFlag)~=length(PathFileNames)
    disp('length mismatch between beforeAfterFlag array and PathFileNames array.')
    disp('quitting...')
    return
end

decoderFile=['C:\Documents and Settings\Administrator\Desktop\RobertF\data\Chewie\09-01-2011\',...
        'Chewie_Spike_LFP_09012011001poly3_150featsvel-decoder_badChansZeroed1003.mat'];
decoderFileDate=datenum('09-01-2011');

HCperformance_LFPcontrolDays_data=cell(1,5);
save([decoderFile(1:end-4),'_performance.mat'],'HCperformance_LFPcontrolDays_data')

for n=1:length(PathFileNames)
    % cd back up to top directory so we can find our data file.
    cd('C:\Documents and Settings\Administrator\Desktop\RobertF\data')
    [status,result]=dos(['dir /B /S ',PathFileNames{n},'.mat']);
    if status~=0
        [status,result]=dos(['dir /B /S ',PathFileNames{n},'.plx']);
        if status~=0
            fprintf('problem at %s.\n',PathFileNames{n})
            return
        end
    end
%     fid=fopen([decoderFile(1:end-4),'_data.txt'],'w');
%     fprintf(fid,'%s\t',PathFileNames{n})
%     fclose(fid);
    load([decoderFile(1:end-4),'_performance.mat'],'HCperformance_LFPcontrolDays_data')
    if n==1
        HCperformance_LFPcontrolDays_data{n,1}=PathFileNames{n};
        HCperformance_LFPcontrolDays_data{n,3}=beforeAfterFlag{n};
    else
        HCperformance_LFPcontrolDays_data=[HCperformance_LFPcontrolDays_data; cell(1,5)];
        HCperformance_LFPcontrolDays_data{end,1}=PathFileNames{n};
        HCperformance_LFPcontrolDays_data{end,3}=beforeAfterFlag{n};        
    end
    save([decoderFile(1:end-4),'_performance.mat'],'HCperformance_LFPcontrolDays_data')
    % don't forget to strip out the linefeed at the end of 'result'
    result(end)='';
    evalLFPpositionDecoderRDF(decoderFile,decoderFileDate,result)
    close
end