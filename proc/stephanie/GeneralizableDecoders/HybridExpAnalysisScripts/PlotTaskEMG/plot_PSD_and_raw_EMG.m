% Plot PSD and raw trace for each important muscle
function plot_PSD_and_raw_EMG

% Initialize folders
%  LoadingFolder = 'Z:\Kevin_12A2\FES\BDFStructs\Generalizability\';
%  BaseFolder = 'Y:\User_folders\Stephanie\Data Analysis\Generalizability\Kevin\EMGanalysis\';
% DateList = {'05-15-15\','05-15-15\','05-15-15\','05-15-15\','05-19-15\','05-19-15\','05-19-15\','05-19-15\','05-19-15\','05-20-15\','05-20-15\','05-20-15\','05-20-15\',...
%     '05-21-15\','05-21-15\','05-21-15\','05-21-15\','05-21-15\',...
%     '05-25-15\','05-25-15\','05-25-15\','05-25-15\','05-25-15\','05-26-15\','05-26-15\','05-26-15\','05-26-15\','06-03-15\','06-03-15\','06-03-15\',...
%     '06-04-15\','06-04-15\','06-04-15\','06-04-15\','06-04-15\','06-06-15\','06-06-15\','06-08-15\','06-08-15\'};
% SubFile = {'Kevin_20150515_WmHandleHoriz_Utah14EMGs_SN_001-s','Kevin_20150515_IsoHandleHoriz_Utah14EMGs_SN_002-s','Kevin_20150515_IsoHandleHoriz_Utah14EMGs_SN_003-s','Kevin_20150515_WmHandleHoriz_Utah14EMGs_SN_004-s',...
%     'Kevin_20150519_SprHandleHoriz_Utah14EMGs_SN_001-s','Kevin_20150519_WmHandleHoriz_Utah14EMGs_SN_002-s','Kevin_20150519_IsoHandleHoriz_Utah14EMGs_SN_003-s','Kevin_20150519_WmHandleHoriz_Utah14EMGs_SN_004-s','Kevin_20150519_SprHandleHoriz_Utah14EMGs_SN_005-s',...
%     'Kevin_20150520_SprHandleHoriz_Utah14EMGs_SN_001-s','Kevin_20150520_WmHandleHoriz_Utah14EMGs_SN_002-s','Kevin_20150520_IsoHandleHoriz_Utah14EMGs_SN_003-s','Kevin_20150520_IsoHandleHorizOnlyXaxis_Utah14EMGs_SN_004-s',...
%     'Kevin_20150521_WmHandleHoriz_Utah14EMGs_SN_001-s','Kevin_20150521_SprHandleHoriz_Utah14EMGs_SN_002-s','Kevin_20150521_IsoHandleHoriz_Utah14EMGs_SN_003-s','Kevin_20150521_IsoHandleHorizXaxisonly_Utah14EMGs_SN_004-s','Kevin_20150521_WmHandleHorizXaxisonly_Utah14EMGs_SN_005-s'...
%     'Kevin_20150525_WmHandleHoriz_Utah14EMGs_SN_001-s','Kevin_20150525_IsoHandleHoriz_Utah14EMGs_SN_002-s','Kevin_20150525_SprHandleHoriz_Utah14EMGs_SN_003-s','Kevin_20150525_WmHandleHoriz_Utah14EMGs_SN_004-s','Kevin_20150525_IsoBoxCenterOut_Utah14EMGs_SN_005-s',...
%     'Kevin_20150526_WmHandleHoriz_Utah14EMGs_SN_001-s','Kevin_20150526_SprHandleHoriz_Utah14EMGs_SN_002-s','Kevin_20150526_IsoHandleHoriz_Utah14EMGs_SN_003-s','Kevin_20150526_WmHandleHoriz_Utah14EMGs_SN_004-s',...
%     'Kevin_20150603_WmHandleHoriz_Utah14EMGs_SN_001-s','Kevin_20150603_IsoHandleHoriz_Utah14EMGs_SN_002-s','Kevin_20150603_WmHandleHoriz_Utah14EMGs_SN_003-s',...
%     'Kevin_20150604_IsoHandleHoriz_Utah14EMGs_SN_001-s','Kevin_20150604_IsoHandleHoriz_Utah14EMGs_SN_002-s','Kevin_20150604_WmHandleHoriz_Utah14EMGs_SN_003-s','Kevin_20150604_SprHandleHoriz_Utah14EMGs_SN_004-s','Kevin_20150604_IsoBoxCenterOut_Utah14EMGs_SN_005-s',...
%     'Kevin_20150606_IsoHandleHoriz_Utah14EMGs_SN_001-s','Kevin_20150606_WmHandleHoriz_Utah14EMGs_SN_002-s',...
%     'Kevin_20150608_WmHandleHoriz_Utah14EMGs_SN_001-s','Kevin_20150608_IsoHandleHoriz_Utah14EMGs_SN_002-s'};

LoadingFolder = 'Z:\Jango_12a1\BDFStructs\Generalizability\WithHandle\';
BaseFolder = 'Y:\User_folders\Stephanie\Data Analysis\Generalizability\Jango\EMGanalysis\';
% DateList = {'07-23-14\','07-23-14\','07-23-14\','07-24-14\','07-24-14\','07-24-14\','07-25-14\',...
%     '07-25-14\','07-25-14\','08-19-14\','08-19-14\','08-19-14\','08-20-14\','08-20-14\','08-20-14\',...
 DateList={'08-21-14\','08-21-14\','08-21-14\','09-23-14\','09-23-14\','09-23-14\','09-25-14\','09-25-14\',...
    '09-26-14\','09-26-14\','10-04-14\','10-04-14\','10-04-14\',...
     '10-10-14\','10-10-14\','10-10-14\','10-11-14\','10-11-14\','10-11-14\','10-12-14\','10-12-14\',...
    '10-12-14\','11-06-14\','11-06-14\','11-07-14\','11-07-14\','11-07-14\'};
DateList = {'05-15-15\','05-15-15\','05-15-15\'};
SubFile = {'Jango_SprHoriz_UtahEMGs_051515_SN_001-s','Jango_IsoHoriz_UtahEMGs_051515_SN_003-s','Jango_WmHoriz_UtahEMGs_051515_SN_004-s'};
% SubFile = {'Jango_20140723_IsoHandleHoriz_Utah10ImpEMGs_SN_001-s','Jango_20140723_WmHandleHoriz_Utah10ImpEMGs_SN_002-s','Jango_20140723_SprHandleHoriz_Utah10ImpEMGs_SN_003-s',...
% 'Jango_20140724_IsoHandleHoriz_Utah10ImpEMGs_SN_001-s','Jango_20140724_WmHandleHoriz_Utah10ImpEMGs_SN_002-s','Jango_20140724_SprHandleHoriz_Utah10ImpEMGs_SN_003-s'...
% 'Jango_20140725_IsoHandleHoriz_Utah10ImpEMGs_SN_001','Jango_20140725_WmHandleHoriz_Utah10ImpEMGs_SN_002','Jango_20140725_SprHandleHoriz_Utah10ImpEMGs_SN_003',...
% 'Jango_20140819_IsoHandleHoriz_Utah10ImpEMGs_SN_001-s','Jango_20140819_WmHandleHoriz_Utah10ImpEMGs_SN_002-s','Jango_20140819_SprHandleHoriz_Utah10ImpEMGs_SN_003-s',...
% 'Jango_20140820_IsoHandleHoriz_Utah10ImpEMGs_SN_001-s','Jango_20140820_WmHandleHoriz_Utah10ImpEMGs_SN_002-s','Jango_20140820_SprHandleHoriz_Utah10ImpEMGs_SN_003-s',...
% 'Jango_20140821_IsoHandleHoriz_Utah10ImpEMGs_SN_001-s','Jango_20140821_WmHandleHoriz_Utah10ImpEMGs_SN_002-s','Jango_20140821_SprHandleHoriz_Utah10ImpEMGs_SN_003-s',...
%  'Jango_20140923_IsoHandleHoriz_Utah10ImpEMGs_SN_001-s','Jango_20140923_WmHandleHoriz_Utah10ImpEMGs_SN_002-s','Jango_20140923_SprHandleHoriz_Utah10ImpEMGs_SN_003-s',...
%  'Jango_20140925_IsoHandleHoriz_UtahEMGs_SN_001-s','Jango_20140925_WmHandleHoriz_UtahEMGs_SN_002-s',...
%  'Jango_20140926_IsoHandleHoriz_UtahEMGs_SN_003-s','Jango_20140926_WmHandleHoriz_UtahEMGs_SN_002-s',...
%  'Jango_20141004_IsoHandleHoriz_UtahEMGs_SN_001-s','Jango_20141004_WmHandleHoriz_UtahEMGs_SN_002-s','Jango_20141004_SprHandleHoriz_UtahEMGs_SN_003-s',...
%  'Jango_20141010_IsoHandleHoriz_UtahEMGs_SN_001-s','Jango_20141010_WmHandleHoriz_UtahEMGs_SN_002-s','Jango_20141010_SprHandleHoriz_UtahEMGs_SN_003-s',...
%  'Jango_20141011_IsoHandleHoriz_UtahEMGs_SN_001-s','Jango_20141011_WmHandleHoriz_UtahEMGs_SN_002-s','Jango_20141011_SprHandleHoriz_UtahEMGs_SN_003-s',...
% 'Jango_20141012_IsoHandleHoriz_UtahEMGs_SN_001-s','Jango_20141012_WmHandleHoriz_UtahEMGs_SN_002-s','Jango_20141012_SprHandleHoriz_UtahEMGs_SN_003-s',...
% 'Jango_20141106_IsoHandle_UtahEMGs_SN_001-s','Jango_20141106_WmHandle_UtahEMGs_SN_002-s',...
% 'Jango_20141107_IsoHandle_UtahEMGs_SN_001-s','Jango_20141107_WmHandle_UtahEMGs_SN_002-s','Jango_20141107_SprHandle_UtahEMGs_SN_003-s'};


% Initialize Excel Spreadsheet
col_header={'FileName','EMG','MaxAround60','MaxAround120','MaxAround180','MaxAround240','PeakValue','HzAtPeak','Max60AndHarmonicsOverPeakValue','SNR'};
xlswrite(strcat(BaseFolder,'EMGQualitySummary','.xls'),col_header)
for a = 1:length(SubFile)
    
  load(char(strcat(LoadingFolder,DateList(a),SubFile{a})));
  vars = whos;
  for b = 1:length(vars)
    pos_bdf(b) = strncmp(vars(b).name,'bdf',3);
  end
   eval(['out_struct = ' vars(pos_bdf).name])

      
      
    foldername = BaseFolder;
    
    names = strsplit(SubFile{a},'_');
    

    emgList = ['FCU'; 'FCR';'ECU'; 'ECR'; 'EDC'; 'FDS'; 'FDP'];
    for i = 1:length(emgList)
        
        allEMGind = strmatch(strcat('EMG_',emgList(i,:)),(out_struct.emg.emgnames));
        if ~isempty(allEMGind)
            EMGind(i) = allEMGind(1);
        else
            EMGind(i) = nan;
        end
    end
    nonexistentEMGind = find(isnan(EMGind));
    EMGind(nonexistentEMGind)=[]; emgList(nonexistentEMGind,:)=[];
    
    %PSD setup
    Fs = 2000;

    appendedPDF = strcat('Summary-',names{1},'-',names{2},names{3},'-','EMGs.pdf');
    output = strcat(foldername,appendedPDF);
    
    for j = 1:length(EMGind)
        rawEMG = out_struct.emg.data(:,EMGind(j)+1);
        meanOverVar = mean(rawEMG)/var(rawEMG);
        emgMean = mean(rawEMG);
        emgVar = var(rawEMG);
        
        % Plot PSD
        figure;
        emgPSD = pwelch(rawEMG,10000,0,Fs);
        loglog(emgPSD)
        title(strcat(names{1},'-',names{2},names{3},'-',emgList(j,:)))
        % Plot fft
        %subplot(2,1,2)
        %plot_fft(rawEMG, Fs);
        % Save
         saveas(gcf, strcat(foldername,names{1},'-',names{2},names{3},'-',emgList(j,:),'-PSD', '.pdf'))
        input1 = strcat(foldername,names{1},'-',names{2},names{3},'-',emgList(j,:),'-PSD','.pdf');
        
        
        % Plot raw signals
        figure
        subplot(3,1,1); title([emgList(j,:) ' raw EMG'])
        plot(out_struct.emg.data(:,1),rawEMG); MillerFigure
        title(strcat(names{1},'-',names{2},names{3},'-',emgList(j,:)))
        subplot(3,1,2)
        plot(out_struct.emg.data(1:20000,1),rawEMG(1:20000)); MillerFigure
        subplot(3,1,3);
        plot(out_struct.emg.data(1:3000,1),rawEMG(1:3000)); MillerFigure
        xlabel(['Mean = ',sprintf('%.4f',emgMean), ' | Var = ', sprintf('%.4f',emgVar), ' | Mean/Variance = ', sprintf('%.4f',meanOverVar)]);
        saveas(gcf, strcat(foldername,names{1},'-',names{2},names{3},'-',emgList(j,:),'-raw', '.pdf'))
        input2 = strcat(foldername,names{1},'-',names{2},names{3},'-',emgList(j,:),'-raw','.pdf');
        
        % append figures
        append_pdfs(output,input1,input2)
        
        % Evaluate EMG quality and save excel file
        [excel_data] = EvaluateEMGquality(SubFile{a},emgList(j,:),emgPSD);
       ExcelLength = size(xlsread(strcat(BaseFolder,'EMGQualitySummary','.xls')),1);
        xlswrite(strcat(BaseFolder,'EMGQualitySummary','.xls'),excel_data,['A', num2str(ExcelLength+2), ':I', num2str(ExcelLength+2)])
    end
    
     % Convert bdf to binnedData
        % Initialize variables  -----------------------------------------
        input.binsize = 0.05; input.starttime=0; input.stoptime=0;input.TimeWind=0;
        input.EMG_hp=50; input.EMG_lp=10; input.minFiringRate=0; inputNormData=0;input.NumChan = 10; 
        input.FindStates=0;input.Unsorted=0;input.TriKernel=0;input.sig=0.04;input.ArtRemEnable=0;
        binnedData = convertBDF2binned_noLPfilter(out_struct,input);
        SNR = computeAllSNR(binnedData,EMGind);
        xlswrite(strcat(BaseFolder,'EMGQualitySummary','.xls'),SNR(:,2),['J', num2str(ExcelLength+3-length(SNR)), ':J',num2str(ExcelLength+2)]);
    
    close all
    clearvars -except BaseFolder LoadingFolder DateList SubFile a
end


end

