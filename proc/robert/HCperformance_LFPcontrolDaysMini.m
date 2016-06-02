
PathFileNames={'Mini_Spike_LFPL_107','Mini_Spike_LFPL_111','Mini_Spike_LFPL_112','Mini_Spike_LFPL_116', ...
    'Mini_Spike_LFPL_119','Mini_Spike_LFPL_124','Mini_Spike_LFPL_125','Mini_Spike_LFPL_129', ...
    'Mini_Spike_LFPL_130','Mini_Spike_LFPL_138','Mini_Spike_LFPL_139','Mini_Spike_LFPL_140', ...
    'Mini_Spike_LFPL_141','Mini_Spike_LFPL_142','Mini_Spike_LFPL_145','Mini_Spike_LFPL_146', ...
    'Mini_Spike_LFPL_149','Mini_Spike_LFPL_152','Mini_Spike_LFPL_153','Mini_Spike_LFPL_156', ...
    'Mini_Spike_LFPL_158','Mini_Spike_LFPL_163','Mini_Spike_LFPL_164','Mini_Spike_LFPL_167', ...
    'Mini_Spike_LFPL_170','Mini_Spike_LFPL_171','Mini_Spike_LFPL_175','Mini_Spike_LFPL_193', ...
    'Mini_Spike_LFPL_197','Mini_Spike_LFPL_226','Mini_Spike_LFPL_227','Mini_Spike_LFPL_260', ...
    'Mini_Spike_LFPL_261','Mini_Spike_LFPL_294','Mini_Spike_LFPL_295','Mini_Spike_LFPL_296', ...
    'Mini_Spike_LFPL_297','Mini_Spike_LFPL_322','Mini_Spike_LFPL_323',};
beforeAfterFlag={'before','after','before','after','before','after','before','after','before','after', ...
    'before','before','before','before','after','before','after','after','before','after','before','after', ...
    'before','after','after','before','after','before','after','after','after','after','after','after', ...
    'after','after','after','after','after'};

if length(beforeAfterFlag)~=length(PathFileNames)
    disp('length mismatch between beforeAfterFlag array and PathFileNames array.')
    disp('quitting...')
    return
end

% decoderFile=['C:\Documents and Settings\Administrator\Desktop\RobertF\data\Mini\08-24-2011\',...
%         'Mini_Spike_LFPL_107poly3_150featsvel-decoder_badChansZeroed1003.mat'];
decoderFile=['C:\Documents and Settings\Administrator\Desktop\RobertF\data\Mini\08-24-2011\',...
        'Mini_Spike_LFPL_107poly3_150featsvel-decoder_badChansZeroed1003_no2ndBank.mat'];
decoderFileDate=datenum('08-24-2011');

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

copyfile([decoderFile(1:end-4),'_performance.mat'],'Z:\Mini_7H1\FilterFiles\')