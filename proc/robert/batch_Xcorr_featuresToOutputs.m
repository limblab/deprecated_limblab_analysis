days={...
    '09-02-2011', ...
    '09-06-2011', ...
    '09-07-2011', ...
    '09-08-2011', ...
    '09-09-2011', ...
    '03-19-2012', ...
    '03-21-2012', ...
    '03-26-2012', ...
    '03-28-2012', ...
    '03-30-2012', ...
    };

Chewie_days={...
    '09-02-2011', ...
    '09-06-2011', ...
    '09-07-2011', ...
    '09-08-2011', ...
    '09-09-2011', ...
    '09-12-2011', ...
    '09-15-2011', ...
    '09-16-2011', ...
    '09-19-2011', ...
    '09-23-2011', ...
    '09-26-2011', ...
    '10-07-2011', ...
    '10-17-2011', ...
    '10-21-2011', ...
    '10-24-2011', ...
    '11-21-2011', ...
    '11-23-2011', ...
    '11-30-2011', ...
    '12-01-2011', ...
    '12-02-2011', ...
    '12-06-2011', ...
    '12-07-2011', ...
    '12-08-2011', ...
    '12-09-2011', ...
    '12-12-2011', ...
    '01-09-2012', ...
    '01-13-2012', ...
    '01-16-2012', ...
    '01-17-2012', ...    
    '03-19-2012', ...
    '03-21-2012', ...
    '03-26-2012', ...
    '03-28-2012', ...
    '03-30-2012', ...
    };

Chewie_days={...
    '03-28-2012', ...
    '03-30-2012', ...
    '04-02-2012', ...
    };

peakIndAll_x_Chewie=[]; peakIndAll_y_Chewie=[];
peakValAll_x_Chewie=[]; peakValAll_y_Chewie=[];
BDFlist_all=[];
originalDir=pwd;
if isempty(regexp(pwd,'featMats','once')), mkdir('featMats'), end
for n=1:length(Chewie_days)
    % take a day, find the kinStruct, and identifies all the
    % files of the given control type that were included.
    BDFlist=findBDF_withControl('Chewie',Chewie_days{n},'LFP');
    BDFlist_all=[BDFlist_all; BDFlist'];
    for k=1:length(BDFlist)
        if isempty(regexp(pwd,'featMats','once')), cd('featMats'), end
%         if ~exist(BDFlist{k},'file')~=2
            run_makefmatc_causal(BDFlist{k},500)
            peakIndAll_x_Chewie=[peakIndAll_x_Chewie; evalin('base','peakInd_x')];
            peakIndAll_y_Chewie=[peakIndAll_y_Chewie; evalin('base','peakInd_y')];
            peakValAll_x_Chewie=[peakValAll_x_Chewie; evalin('base','peakVal_x')];
            peakValAll_y_Chewie=[peakValAll_y_Chewie; evalin('base','peakVal_y')];
            clear peakInd_* peakVal_*
%         else
%             % not going to work in current incarnation
%             load(BDFlist{k},'featMat','sigTrimmed','out_struct')
%             [~,~,timelags,peakInd_x,peakInd_y,peakVal_x,peakVal_y]= ...
%                 featureOutputXcorr(out_struct,numlags,featMat,sigTrimmed,numfp);
%         end
    end
end

% save('C:\Documents and Settings\Administrator\Desktop\Mike_Data\Spike LFP Decoding\Chewie','peak*')
cd(originalDir)
return
peakIndAll_x_Mini=[]; peakIndAll_y_Mini=[];
peakValAll_x_Mini=[]; peakValAll_y_Mini=[];
% days for Mini
Mini_days={...
    '09-02-2011', ...
    '09-07-2011', ...
    '09-08-2011', ...
    '09-09-2011', ...
    '09-12-2011', ...
    '03-19-2012', ...
    '03-21-2012', ...
    '03-28-2012', ...
    '03-30-2012', ...
    '04-02-2012', ...
    };
% for n=1:length(Mini_days)
%     % take a day, find the kinStruct, and identifies all the
%     % files of the given control type that were included.
%     BDFlist=findBDF_withControl('Mini',Mini_days{n},'LFP');
%     BDFlist_all=[BDFlist_all; BDFlist'];
%     for k=1:length(BDFlist)
%         if isempty(regexp(pwd,'featMats','once')), cd('featMats'), end
%         run_makefmatc_causal(BDFlist{k},500)
%         peakIndAll_x_Mini=[peakIndAll_x_Mini; evalin('base','peakInd_x')];
%         peakIndAll_y_Mini=[peakIndAll_y_Mini; evalin('base','peakInd_y')];
%         peakValAll_x_Mini=[peakValAll_x_Mini; evalin('base','peakVal_x')];
%         peakValAll_y_Mini=[peakValAll_y_Mini; evalin('base','peakVal_y')];
%     end
% end
% cd(originalDir)

% save('Y:\user_folders\Robert\data\monkey\outputs\LFPcontrol\Xcorr stuff\XCcorr_batch_peakVal_All.mat', ...
%     'peakIndAll_x_Chewie','peakIndAll_y_Chewie','peakValAll_x_Chewie', ...
%     'peakValAll_y_Chewie','peakIndAll_x_Mini','peakIndAll_y_Mini', ...
%     'peakValAll_x_Mini','peakValAll_y_Mini')