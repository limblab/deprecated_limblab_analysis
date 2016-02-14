%function batch_handControl_decoderPerformance(decoderIn)

% decoderIn is a path, not a matrix of some kind.

 originalPath=pwd;

% BatchList=HC_firstOverall_6targ;
% BatchList=HC_postLFPcontrol_6targ;
% 
% BatchList=BatchList(datenum(regexp(BatchList,'[0-9]{8}','match','once'),'mmddyyyy') >= ...
%     datenum('12272011','mmddyyyy'));
% 
% load('E:\personnel\RobertF\monkey_analyzed\LFPcontrol\HCoffline_withLFPdecoder\BatchList_Chewie_firstFiles0412decoder.mat')
% 
% load('E:\personnel\RobertF\monkey_analyzed\LFPcontrol\HCoffline_withLFPdecoder\BatchList_Mini_firstFiles0411decoder')

BatchList = Chewie_LFP1_FirstFileNames;

for n=1:length(BatchList)
    %BatchList{n}=regexprep(BatchList{n},'\t',''); 

    %try
        %if ~nargin
            %VAFstruct(n)=handControl_decoderPerformance_predictions(BatchList{n});
        %else
            VAFstruct(n)=handControl_decoderPerformance_predictions(BatchList{n},decoderIn);
        %end
    %end
    close
    cd(originalPath)
    save(fullfile(originalPath,'VAFstruct.mat'),'VAFstruct')
    assignin('base','VAFstruct',VAFstruct)
end

% copyfile('VAFstruct.mat',...
%     'Y:\user_folders\Robert\data\monkey\outputs\HCperformance_LFPcontrolDays\VAFstruct.mat')

