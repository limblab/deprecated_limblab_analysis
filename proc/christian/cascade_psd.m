clear; clc;
HC = load('Y:\Spike_10I3\BinnedData\2013-10-16\Spike_2013-10-13_WF_002.mat');
HC = HC.binnedData;

% 500 ms filter
options = struct('PredCursPos',1,'fillen',0.5,'EMGcascade',0,'plotflag',1);
N2F500 = BuildModel(HC, options);
[~,~,~,PredData500,ActData500] = mfxval(HC, options);

% % 1000 ms filter
% options.fillen = 1;
% N2F1000 = BuildModel(HC, options);
% % [~,~,~,PredData1000,ActData1000]= mfxval(HC, options);
% 
% %2500ms filter
% options.fillen = 2.5;
% N2F2500 = BuildModel(HC, options);
% % [~,~,~,PredData2500,ActData2500]= mfxval(HC, options);

%EC filter
options.EMGcascade = 1; options.fillen = 0.5; options.PredCursPos = 0;
[~,~,~,PredDataEC,ActDataEC]  = mfxval(HC, options);
options.EMGcascade = 0; options.Use_EMGs = 1; options.PredCursPos = 1;
E2F500 = BuildModel(HC,options);
options.Use_EMGs = 0; options.PredCursPos = 0;options.PredEMGs = 1;
N2E500 = BuildModel(HC,options);


% % test filters
% numlags = 3; numNeur = 96; numForce=2; numEMGs = 4; numNeur = 5;
% N2E500.H = repmat([1:3]',numNeur,numEMGs);
% E2F500.H = repmat([10:10:30]',numEMGs,numForce);
% E2F500.H(:,2) = 2*E2F500.H(:,2);

numlags = 10; numNeur = 96; numForce=2; numEMGs = 7;
N2E2F_EC.H = zeros(numNeur*(2*numlags-1),numForce);

%find single linear equivalent for EC filter:
for F = 1:numForce
    for E = 1:numEMGs
        for N = 1:numNeur
            for L = 1:(2*numlags-1)
                line = (N-1)*(2*numlags-1)+L;
                Wint = 0;
                if L <=numlags
                    for e = 1:L
                        n = L-e+1;        
                        Wint = Wint + N2E500.H((N-1)*numlags+n,E)*E2F500.H((E-1)*numlags+e,F);
                    end
                else
                    for e = numlags:-1:L+1-numlags
                        n = L-e+1;
                        Wint = Wint + N2E500.H((N-1)*numlags+n,E)*E2F500.H((E-1)*numlags+e,F);
                    end
                end
                N2E2F_EC.H(line,F) = N2E2F_EC.H(line,F) + Wint;
            end
        end
    end
end

            
% s = spectrum.welch;
% PSDHCx   = psd(s,HC.cursorposbin(:,1),'Fs',20);
% PSD500x  = psd(s,PredData500.preddatabin(:,1),'Fs',20);
% PSD1000x = psd(s,PredData1000.preddatabin(:,1),'Fs',20);
% PSD2500x = psd(s,PredData2500.preddatabin(:,1),'Fs',20);
% PSDECx    = psd(s,PredDataEC.preddatabin(:,1),'Fs',20);
% figure;
% plot(PSDHCx); hold on;
% plot(PSD500x);
% plot(PSD1000x);
% plot(PSD2500x);
% plot(PSDECx);
% 
% legend('HandControl','N2F 500ms','N2F 1000ms','N2F 2500ms','EMG Cascade (2x500ms)');
% title(sprintf('Welch PSD -- x-axis force'));
% 
% PSDHCy   = psd(s,HC.cursorposbin(:,2),'Fs',20);
% PSD500y  = psd(s,PredData500.preddatabin(:,2),'Fs',20);
% PSD1000y = psd(s,PredData1000.preddatabin(:,2),'Fs',20);
% PSD2500y = psd(s,PredData2500.preddatabin(:,2),'Fs',20);
% PSDECy    = psd(s,PredDataEC.preddatabin(:,2),'Fs',20);
% figure;
% plot(PSDHCy); hold on;
% plot(PSD500y);
% plot(PSD1000y);
% plot(PSD2500y);
% plot(PSDECy);
% 
% legend('HandControl','N2F 500ms','N2F 1000ms','N2F 2500ms','EMG Cascade (2x500ms)');
% title(sprintf('Welch PSD -- y-axis force'));
% 
% H = N2F500.H;
% H = N2F1000.H;
% H = N2F2500.H;
H = N2E2F_EC.H; 
 
numlags = size(H,1)/96; 
NormW = plotH(H,numlags,1);
% MW = mean(abs(NormW(2:end,:,:)));
MW = mean(abs(NormW));
figure;
for o = 1:2
    subplot(1,2,o);
    plot(MW(:,:,o),'k','linewidth',2);
%     hold on;
%     plot(NormW(1,:,o),'b');
    ylim([0 1]);
    xlim([1 numlags]);
    legend('Mean(abs(weights))');
    title('N2F')
%     legend('Mean(abs(weights))','weights for stationary unit input');
end

N2F_EC = N2F500;
N2F_EC.H = N2E2F_EC.H;
N2F_EC.fillen = numlags;

PredData = predictSignals(N2F_EC,HC);
[R2,vaf,mse]= ActualvsOLPred(HC,PredData,1);



