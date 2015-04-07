function [H,G] = plot_emg_PD(binnedData, varargin)

EMGvector = 1:size(binnedData.emgdatabin,2);
if nargin>1
    EMGvector = varargin{1};
end
n_emgs = length(EMGvector);

% Use FIR filter:
% H = MIMOCE1(binnedData.emgdatabin(:,EMGvector),binnedData.cursorposbin,1);
% H(:,1) = -H(:,1); %invert x axis(left hand vs. right hand)

% Use correlation between EMG and force
% binnedData.cursorposbin(:,1) = -binnedData.cursorposbin(:,1); % invert x axis

nlag = 20;
c    = get_emg_xcov(binnedData.cursorposbin,binnedData.emgdatabin(:,EMGvector),nlag);


% Plot H, matrix of the Fx, Fy peaks of the x-cov
H = nan(n_emgs,2);
for e = 1:n_emgs
%     figure; plot(-nlag:nlag,c(:,:,e),'LineWidth',2);
%     title(binnedData.emgguide(EMGvector(e),:),'FontSize',20);
%     legend('Fx','Fy')
    for f = 1:2
        H(e,f) = c(abs(c(:,f,e))==max(abs(c(:,f,e))),f,e);
    end
end

% scale each to unit vectors
for e = 1:n_emgs
   H(e,:) = H(e,:)/sqrt(sum(H(e,:).^2));
end

% scale H using mean ratio between actual and predicted Euclidian magnitudes
G = mean(  sqrt(sum(binnedData.cursorposbin.^2,2)) ./ ...
           sqrt(sum((binnedData.emgdatabin(:,EMGvector)*H).^2,2))  );
       
H = H*G;

% % scale all with one scalar
% G = zeros(1,2);
% for f = 1:2
%     G(:,f) = sqrt(sum(binnedData.cursorposbin(:,f)'/(binnedData.emgdatabin*H(:,f))';
% end
% H = H*max(G);

% % scale H with scalars
% for f = 1:2
%     G = binnedData.cursorposbin(:,f)'/(binnedData.emgdatabin*H(:,f))';
%     H(:,f) = G*H(:,f);
% end

% scale H with polynomial
% for f = 1:2
%     P = polyfit(binnedData.emgdatabin*H(2:end,f),binnedData.cursorposbin(:,f),1);
%     H(:,f) = [P(2); H(2:end,f)*P(1)];
% end

%EMG Preferred Direction
figure;

for i = 1:n_emgs
    hold on;
%     plot([0 H(i,1)],[0 H(i,2)],colors{EMGvector(i)},'LineWidth',2);
    plotLM([0 H(i,1)],[0 H(i,2)],'o-');
end

legend(binnedData.emgguide{EMGvector},'Location','NorthEastOutside');
axis square;
mxy = ceil(max(max(H)));
ylim([-mxy mxy]); xlim([-mxy mxy]);
