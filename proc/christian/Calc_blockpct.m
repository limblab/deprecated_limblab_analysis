function block = Calc_blockpct(decoder,flx,ext,plotflag)
% Calculate the ratio PredictedEMGs/ActualEMGs before and after nerve block
% Inputs : decoder : the decoder to be used to make the predictions
%          flx     : a vector indicating the indexes of flexor muscles to include
%          ext     : a vector indicating the indexes of flexor muscles to include

dataPath = 'C:\Monkey\Jaco\Data\';

% PreBlock file
[PreBlockFile, PreBlockPath] = uigetfile( { [dataPath '\BinnedData\*.mat']},...
    'Select Pre-Block Binned Data File', 'MultiSelect','off' );
if ~PreBlockPath
    disp('User Action Cancelled');
    block = [];
    return;
end
PreBlockFile = {PreBlockFile};

% PostBlock file(s)
[PostBlockFiles, PostBlockPath] = uigetfile( { [dataPath '\BinnedData\*.mat']},...
    'Select Post-Block Binned Data File(s)', 'MultiSelect','on' );
PostBlockFiles = sort(PostBlockFiles);
if ~PostBlockPath
    disp('User Action Cancelled');
    block = [];
    return;
end

if iscell(PostBlockFiles)
    numFiles = size(PostBlockFiles,2);
elseif ischar(PostBlockFiles);
    numFiles = 1;
    PostBlockFiles = {PostBlockFiles};
end

%% Calculate preblock Act/Pred ratios
binnedData = LoadDataStruct(fullfile(PreBlockPath,PreBlockFile{:}),'binned');
PredData = predictSignals(decoder,binnedData);

EMGs      = [flx ext];
flx_idx   = 1:length(flx);
ext_idx   = length(flx)+1:length(flx)+length(ext);
numEMGs   = length(EMGs);
offset    = zeros(1,numEMGs);
slope     = zeros(1,numEMGs);
numLags   = find(binnedData.timeframe == PredData.timeframe(1));

% 
% for i=1:numEMGs
%     x=binnedData.emgdatabin(numLags:end,EMGs(i));
%     y=PredData.preddatabin(:,EMGs(i));
% %     linreg=fit(x,y,'poly1');
% %     offset(1,i) = linreg.p2;
% %     slope(1,i) = linreg.p1;
% 
%     % determine offsets (use min x value that is > to the 2nd prcntile of x)
% %     x = x - min( x(x>prctile(x,2)));
% %     y = y - min( y(y>prctile(y,2)));
%     offset(1,i) = min(
% 
%     % calculate gain
%         
%     if plotflag
%         figure;
%         plot(x,y,'r.');
%         title(sprintf('%s',binnedData.emgguide(EMGs(i),:)));
%         xlabel('Actual Data');
%         ylabel('Predicted Data');
%         hold on;
%         plot(xlim,linreg(xlim));
%         legend(sprintf('offset: %g, slope: %g',offset(1,i),slope(1,i)));
%     end
% end

x=binnedData.emgdatabin(numLags:end,EMGs);
y=PredData.preddatabin(:,EMGs);

%remove offsets
for i = 1:numEMGs
    x(:,i) = x(:,i) - min( x( x(:,i)>prctile(x(:,i),2),i));
    y(:,i) = y(:,i) - min( y( y(:,i)>prctile(y(:,i),2),i));
    
    if plotflag
        figure;
        plot(x(:,i),'k'); hold on;
        plot(y(:,i),'r');
        title(binnedData.emgguide(EMGs(i),:));
        legend('Actual','Pred');
    end
    
end

% preRatios        = slope.*mean(binnedData.emgdatabin(:,EMGs))./(mean(PredData.preddatabin(EMGs))-offset);
preRatios        = mean(x)./mean(y);
preBlockPct      = 1-preRatios;
preBlockPctN     = 1-(preRatios./preRatios);
preBlockFlexPct  = mean(preBlockPct(flx_idx));
preBlockFlexPctN = mean(preBlockPctN(flx_idx));
preBlockExtPct   = mean(preBlockPct(ext_idx));
preBlockExtPctN  = mean(preBlockPctN(ext_idx));
clear PredData binnedData;

%% Calculate postBlock Act/Pred ratios

postBlockPct      = -1*ones(numFiles,numEMGs);
postBlockFlexPct  = -1*ones(numFiles,1);
postBlockExtPct   = -1*ones(numFiles,1);
postBlockPctN     = -1*ones(numFiles,numEMGs);
postBlockFlexPctN = -1*ones(numFiles,1);
postBlockExtPctN  = -1*ones(numFiles,1);

for f = 1:numFiles
    
    binnedData = LoadDataStruct(fullfile(PostBlockPath,PostBlockFiles{:,f}),'binned');
    PredData = predictSignals(decoder,binnedData);

%     for i=1:numEMGs
%         x=binnedData.emgdatabin(numLags:end,EMGs(i));
%         y=PredData.preddatabin(:,EMGs(i));
%         linreg=fit(x,y,'poly1');
%         offset(1,i) = linreg.p2;
%         slope(1,i) = linreg.p1;
%
%         % remove offsets (use min x value that is > to the 2nd prcntile of x)
%         x = x - min( x(x>prctile(x,2)));
%         y = y - min( y(y>prctile(y,2)));
%
%         if plotflag
%             figure;
%             plot(x,y,'r.');
%             title(sprintf('%s',binnedData.emgguide(EMGs(i),:)));
%             xlabel('Actual Data');
%             ylabel('Predicted Data');
%             hold on;
%             plot(xlim,linreg(xlim))
%             legend(sprintf('offset: %g, slope: %g',offset(1,i),slope(1,i)));
%         end
%     end
%

    x=binnedData.emgdatabin(numLags:end,EMGs);
    y=PredData.preddatabin(:,EMGs);

    %remove offsets
    for i = 1:numEMGs
        x(:,i) = x(:,i) - min( x( x(:,i)>prctile(x(:,i),2),i));
        y(:,i) = y(:,i) - min( y( y(:,i)>prctile(y(:,i),2),i));

        if plotflag
            figure;
            plot(x(:,i),'k'); hold on;
            plot(y(:,i),'r');
            title(binnedData.emgguide(EMGs(i),:));
            legend('Actual','Pred');
        end

    end

    % postRatios             = slope.*mean(binnedData.emgdatabin(:,EMGs))./(mean(PredData.preddatabin(EMGs))-offset);
    postRatios             = mean(x)./mean(y);
    postBlockPct(f,:)      = 1-postRatios;
    postBlockPctN(f,:)     = 1-(postRatios./preRatios);
    postBlockFlexPct(f,:)  = mean(postBlockPct(f,flx_idx));
    postBlockFlexPctN(f,:) = mean(postBlockPctN(f,flx_idx));
    postBlockExtPct(f,:)   = mean(postBlockPct(f,ext_idx));
    postBlockExtPctN(f,:)  = mean(postBlockPctN(f,ext_idx));

end
    
%% Outputs


block.files    = [PreBlockFile;     PostBlockFiles'];
block.pctN     = [preBlockPctN;     postBlockPctN];
block.flexPct  = [preBlockFlexPct;  postBlockFlexPct];
block.flexPctN = [preBlockFlexPctN; postBlockFlexPctN];
block.ExtPct   = [preBlockExtPct;   postBlockExtPct];
block.ExtPctN  = [preBlockExtPctN;  postBlockExtPctN];


% block     = -1*ones(numFiles+1, numEMGs+4); % [pctBlockAll pctBlockFlx pctBlockExt pctBlockFlxNorm pctBlockExtNorm]
% block = [pblockflex1 pblockext1 pblockflex2 pblockext2]
% 
% block = struct('Files',             [ PreBlockFile;       PostBlockFiles']   ,...
%                'postBlockPctN',     [{preBlockPctN};     {postBlockPctN}]    ,...
%                'postBlockFlexPct',  [{preBlockFlexPct};  {postBlockFlexPct}] ,...
%                'postBlockFlexPctN', [{preBlockFlexPctN}; {postBlockFlexPctN}],...
%                'postBlockExtPct',   [{preBlockExtPct};   {postBlockExtPct}]  ,...
%                'postBlockExtPctN',  [{preBlockExtPctN};  {postBlockExtPctN}] );
           
           
           
           