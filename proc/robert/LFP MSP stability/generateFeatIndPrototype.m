function [featindAll,featIndIndirect_all,featindPrototype,featindIndirectPrototype]=generateFeatIndPrototype(HbankDays,numChan,numFeat,pathToDecoderMAT,undesirableChs)

% syntax [featindAll,featIndIndirect_all,featindPrototype,featindIndirectPrototype]=generateFeatIndPrototype(HbankDays,numChan,numFeat,pathToDecoderMAT,undesirableChs);
%
% all inputs other than HbankDays are optional

if nargin < 2 % defaults
    numChan=96;
    numFeat=6;
end

featindAll=cell(size(HbankDays));
featIndIndirect_all=featindAll;
featindbox=reshape(1:(numChan*numFeat),numFeat,numChan);

if nargin >= 5
    undesirableFeats=featindbox(:,sort(undesirableChs));
    undesirableFeats=undesirableFeats(:);
else
    undesirableFeats=[];
end

for n=1:length(HbankDays)
    if exist('pathToDecoderMAT','var')~=1 || numel(pathToDecoderMAT)<n
        fprintf(1,'finding decoder for %s...\n',HbankDays{n});
        [pathToDecoderMAT{n},~]=decoderPathFromBDF(findBDFonCitadel(HbankDays{n}));
        fprintf(1,'found at \n%s\n',pathToDecoderMAT{n});
        if n==length(pathToDecoderMAT) % if we're doing the initial build...
            save('pathToDecoderMAT.mat','pathToDecoderMAT')
        end
    end
    fprintf(1,'loading \n%s\n',pathToDecoderMAT{n});
    load(pathToDecoderMAT{n},'H','bestc','bestf')
    % featind has the range [1 (numChan*numFeat)] but its indices go from 
    % 1:150 (for example), so we can just index badFeats directly into 
    % featind.  Never mind what the actual values of featind are, 
    % for the purposes of indexing it.
    featind=sort(sub2ind([numFeat numChan],bestf,bestc),'ascend');
    badFeats=find(sum(H(1:10:end,:),2)==0);                                 %#ok<NODEF>
    % badFeats is an index! into H, not into the big 1:576 feature index.
    featind(badFeats)=[];
    if exist('undesirableFeats','var')
        featind=setdiff(featind,undesirableFeats);
    end
    featindAll{n}=featind;
    
    % for indirect channels, take only those channels that had 0 features
    % play a role in the decoder (this will be problematic for LFP2).
    indirectChannels=setdiff(1:numChan,unique(bestc))';
    % but, exclude indirect channels that were noisy or otherwise bad 
    % (according to the H matrix), or were shunted (if undesirableFeats was
    % input).
    indirectChannels=setdiff(indirectChannels,unique(bestc(badFeats)));
    % also, exclude channels that were deemed bad at decoder build, if
    % those were stored.  SIDE NOTE: it would be nice to get rid of all the
    % warnings.  This is technically possible by raising the warning to the
    % level of an error, then using try/catch.  Kind of elaborate for this
    % little piece of code, though.
    load(pathToDecoderMAT{n},'badChannels')
    if exist('badChannels','var')==1
        indirectChannels=setdiff(indirectChannels,badChannels);
    end
    if nargin >= 5
        indirectChannels=setdiff(indirectChannels,undesirableChs);
    end
    featIndIndirect=featindbox(:,indirectChannels);
    featIndIndirect_all{n}=sort(featIndIndirect(:),'ascend');
    clear H bestc bestf featind indirectChannels featIndIndirect badFeats
end, clear n H fileChosenPath featindbox badChannels


featindPrototype=featindAll{1};
featindIndirectPrototype=featIndIndirect_all{1};
if length(featindAll)>1
    for n=2:length(featindAll)
        [~,badInd]=setdiff(featindPrototype,featindAll{n});
        featindPrototype(badInd)=[];
        [~,badInd]=setdiff(featindIndirectPrototype,featIndIndirect_all{n});
        featindIndirectPrototype(badInd)=[];
    end, clear n badInd
end

