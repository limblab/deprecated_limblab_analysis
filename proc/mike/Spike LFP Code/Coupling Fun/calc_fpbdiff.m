function [h,p,hh,ph,crit_p,adj_p,crit_ph,adj_ph,varargout]=calc_fpbdiff(fp,samprate,siglev,signal)
%This function calculates p-values between movement and rest (computed from the signal
%"signal") for the fp in different freq bands.
%outputs:   h = significant or not, using log(fft(bandpower))
%           hh = significance using Hilbert transform to compute bandpower
%           p = p-val using log(fft(bandpower))
%ph uses Hilbert transform

%inputs: siglev is significance level
%           signal = force, e.g.
tic
[b,a]=butter(2,[58 62]/(samprate/2),'stop');
fpf=filtfilt(b,a,fp')';
clear fp
[b2,a2]=butter(2,4/(samprate/2),'low');
[b3,a3]=butter(2,[7 20]/(samprate/2));
[b4,a4]=butter(2,[70 110]/(samprate/2));
[b5,a5]=butter(2,[130 200]/(samprate/2));
if samprate>600
    [b6,a6]=butter(2,[200 300]/(samprate/2));
end

fp2=filtfilt(b2,a2,fpf')';  %fpf is channels X samples
fp3=filtfilt(b3,a3,fpf')';  %fpf is channels X samples
fp4=filtfilt(b4,a4,fpf')';  %fpf is channels X samples
fp5=filtfilt(b5,a5,fpf')';  %fpf is channels X samples
if samprate>600
    fp6=filtfilt(b6,a6,fpf')';  %fpf is channels X samples
end

numfp=size(fpf,1);
if samprate>600
    numbands=6;
else
    numbands=5;
end
PB=zeros(numbands,numfp,length(fpf));
% PB(1,:,:)=zeros(size(fpf));
PB(2,:,:)=10*log10(fp2.^2);%-repmat % PB has dims freqs X chans X bins
PB(3,:,:)=10*log10(fp3.^2);%-repm
PB(4,:,:)=10*log10(fp4.^2);%-repm
PB(5,:,:)=10*log10(fp5.^2);%-repm
if samprate>600
    PB(6,:,:)=10*log10(fp6.^2);
end
toc
disp('Done with bpfiltering')
%% now use hilbert transform
tic
x2=hilbert(fp2')';
X{2}=abs(x2);
x3=hilbert(fp3')';
X{3}=abs(x3);
x4=hilbert(fp4')';
X{4}=abs(x4);
x5=hilbert(fp5')';
X{5}=abs(x5);
if samprate>600
    x6=hilbert(fp6')';
    X{6}=abs(x6);
end
clear x*
toc
disp('done with hilbert transform')
%% calculate movement and rest times
thresh= (min(signal)-max(signal))/20; %threshold for detecting movement, 5% of total amplitude
binoffset=10;
move=find(signal<thresh)-binoffset;
rest=setdiff(1:length(fpf),move);


h=zeros(numbands,numfp);
hh=h;
p=h;
ph=h;

for b=2:numbands
    
    for i=1:numfp
        [h(b,i),p(b,i)]=ttest2(squeeze(PB(b,i,move)),squeeze(PB(b,i,rest)),siglev,'both'); %prob that move ><rest
        [hh(b,i),ph(b,i)]=ttest2(X{b}(i,move),X{b}(i,rest),siglev,'both');
        
    end
end
%% correct p-values using FDR (Benjamini Hochberg) without assuming independence of tests
[hcorr, crit_p, adj_p]=fdr_bh(p,.05,'dep','yes');
[hhcorr, crit_ph, adj_ph]=fdr_bh(ph,.05,'dep','yes');

if nargout>8
    varargout{1}=PB;
    if nargout>9
        varargout{2}=X;
    end
end