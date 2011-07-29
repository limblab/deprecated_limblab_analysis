filelist={'Chewie_Spike_LFP2_115','Chewie_Spike_LFP2_116','Chewie_Spike_LFP2_117','Chewie_Spike_LFP2_118'};

%Declare all variables for predictions code: MRSpredictions_mwstikpoly

signal = 'pos'; 
cells = [];
folds = 10;
numlags= 10;
numsides = 1;
lambda = 1;
Poly = 3; 
Use_Thresh = 0;
emglpf=0;

binlen=100;  %[50,100]

for i=1:length(filelist)

fnam=filelist{i}
load([fnam,'.mat'],'bdf')
%Load File to be analyzed
bdf = bdf;

load('Chewie_Spike_LFP2_105spikes tik pospred 100ms bins lambda1 Poly3_BEST.mat')
%Load Hbest and P if using previous decoder for offline predictions
H = Hbest;
P = P;
neuronIDs = neuronIDs;

    for b=1:length(binlen)

    binsize = binlen(b)/1000;

    [vaf,vmean,vsd,y_test,y_pred,r2m,r2sd,r2,vaftr,H,x,y,ytnew,xtnew,P]=...
    MRSpredictions_mwstikpoly(bdf,signal,cells,binsize,folds,numlags,numsides,lambda,Poly,Use_Thresh,fnam,emglpf,H,P,neuronIDs);
    
    save([fnam,'spikes tik pospred ',num2str(binlen(b)),'ms bins lambda',num2str(lambda),' Poly',num2str(Poly),'.mat'],...%<-Filename
    'v*','y*','r*','x','H','P');%<-What's actually saved

    end

clear bdf v* y* x r* H
end