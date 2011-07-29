%runpredfp6 
%Uses MRSpredictionsfromfp6allDecoderBuild
dir = 'C:\Documents and Settings\Administrator\Desktop\ChewieData\Spike LFP Pos Decoder\';
%Set directory to desired directory

filelist={'Chewie_Spike_LFP2_115','Chewie_Spike_LFP2_116','Chewie_Spike_LFP2_117'};
%Set file to desired filenames(s)

load('Chewie_Spike_LFP_164tik6 pospred 100 feats lambda1poly0_BEST.mat')
%Load previous H matrix for offline predictions if desired
%H = []; %<- Use if not inputting H matrix
H = Hbest; %<- Use if inputting H matrix

%Variables are declared inside and outside loop the same order they are input
%to fxn: MRSpredictionsfromfp6allDecoderBuild

%***Declare all input arguments that stay constant through all loop
%iterations outside loop (vars declared inside loop are commented out):

%sig 
signalType = 'pos';
%numberOfFps
binsize = .1;
folds = 10;
numlags = 10;
numsides = 1;
%samprate
%fp
%fptimes
%analog_times
%fnam

%***Variable Arguments In***
windowsize= 256;
nfeat = 100;
PolynomialOrder = 0;  %for Wiener Nonlinear cascade
Use_Thresh = 0;
%H          
%words                      
emgsamplerate = 1000;
lambda = 1;
%smoothfeats

for i=1:length(filelist)
    fnam=filelist{i}
    fname=[dir,fnam,'.mat'];
    sname=[dir,fnam];
    load(fname);
    
    %Declare input variables within loop that vary in each loop iteration:
    sig = bdf.pos;
    samplerate= bdf.raw.analog.adfreq(1,1);
    %Sample Rate for this file
 
    fpchans=find(cellfun(@isempty,regexp(bdf.raw.analog.channels,'FP[0-9]+'))==0);
    fp=double(cat(2,bdf.raw.analog.data{fpchans}))';
    %Concatenate lfp channels and put into one matrix
    numberOfFps = size(fp,1);
    
    adfreq = samplerate;
    fp_start_time = 1/adfreq;
    fp_stop_time = length(fp)/1000;
    fptimes = fp_start_time:1/adfreq:fp_stop_time;
    %Set time base for fps
    
    analog_time_base = bdf.pos(:,1);
    %Set analog time base for other signals recorded (Pos/Vel/EMG)
      
    words=bdf.words;
    %If script is running without using previous H matrix for predictions words
    %should be varargin 5, or 17th input (remove H input).

    [vaf,vmean,vsd,y_test,y_pred,r2m,r2sd,r2,vaftr,bestf,bestc,H,bestfeat,x,...
     y,featMat,ytnew,xtnew,predtbase,P,featind,sr] =...
     MRSpredictionsfromfp6allDecoderBuild(sig,signalType,numberOfFps,binsize,folds,numlags,numsides,samplerate,fp,...
     fptimes,analog_time_base,fnam,windowsize,nfeat,PolynomialOrder,Use_Thresh,H,words,emgsamplerate,lambda);
     
    save([sname,'tik6 pospred ',num2str(nfeat),' feats lambda',num2str(lambda),'poly',num2str(PolynomialOrder),'.mat'],'v*','y*','x*','r*','best*','H','feat*','P*','Use*','binsize');

    clear fp bdf v* y* x* r*
    close all
    
end