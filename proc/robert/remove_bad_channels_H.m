function Hout=remove_bad_channels_H(Hin,bestc,badChannels,numlags)

% syntax Hout=remove_bad_channels_H(Hin,bestc,badChannels,numlags);
%
% zeros the corresponding rows of an H matrix, so that an old decoder can
% continue to be used in spite of channels going bad.
%
%           INPUTS:
%
%                       Hin         - the original matrix of decoder weights
%                       bestc       - indices of channels included in Hin
%                       badChannels - channels to remove; based on bestc
%                       numlags     - number of lags
%
%           OUTPUTS:
%
%                       Hout        - the output matrix.  everything 
%                                     associated with badChannels will be
%                                     zeroed.
%
% Hin is assumed to be NxM, where N=numlags*[#features selected during
% decoder build].  Will often be 1500, for 10 lags, 150 features.  M is 2
% for kinematic (position or velocity) decoding.

Hout=Hin;

badChannelInds=find(ismember(sort(bestc),badChannels));
badChannelStartInds=(badChannelInds-1)*numlags+1;
indMat=repmat(badChannelStartInds,numlags,1)+repmat([0:9]',1,length(badChannelInds));
Hout(indMat(:),:)=0;
