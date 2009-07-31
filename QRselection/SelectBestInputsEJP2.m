function [IDX,vb,MDLneurons,AICneurons,neurons95]=SelectBestInputsEJP2(Xin,Y,nlags);
%Function select the optimal set of inputs based upon their unique
% contributions to the output.  Based upon linear MISO prediction.
%
% IDX indeces of the best inputs according to their location in the
% ORIGINAL dataset
%Last modified Nov 21, 2003 EAP
%1/6/04 corrected the AIC cost function EAP
%1/7/03 correcte MDL&AIC functions to use vaf properly EAP

nInputs=size(Xin,2);

%Initial run with all inputs
[H,v,mcc,vi]=filMISOSVDEJP2(Xin,Y,nlags,1,1,2);

%Store data and results for using all inputs
Xbest=Xin;
vb=v;
vib=vi;
origIDX=1:nInputs;

%Evaluate methods for eliminating inputs
for i=1:nInputs-1
    nLeft=nInputs-i+1;
    disp([num2str(nLeft) ' inputs evaluated'])
    
    %"Best" choice
    [m,idx]=min(vib);    
    idx=setdiff(1:nLeft,idx); %remove smallest contributor
    Xbest=Xbest(:,idx);
    %Repeat after removing input with the lowest unique contribution
    [H,vb(i+1),mcc,vib]=filMISOSVDEJP2(Xbest,Y,nlags,1,1,2);
    
    %Keep track of which indeces in the original data set are being used. 
    IDX{i}=origIDX(idx);
    origIDX=origIDX(idx);
    
end
IDX=fliplr(IDX);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vaf=flipud(vb')    %rank in increasing value of vaf with each neuron
%How many neurons MDL says to use
%original, incorrect eqxn
%MDLvalue(:,1)=(size(Xin,1)+[1:nInputs]'*log(size(Xin,1))).*(var(Y)-(vaf));
%%%Uses the vaf data properly
MDLvalue(:,1)=(size(Xin,1)+[1:nInputs]'*log(size(Xin,1))).*(var(Y)*(1-.01*vaf));
% figure
% plot(MDLvalue)
MDLcutoff=find(MDLvalue==min(MDLvalue));
%How many neurons AIC says to use
%AICvalue(:,1)=size(Xin,1)*log((var(Y)-(vaf))/size(Xin,1))+2*[1:nInputs]';   %Original, incorrect way
%%%Corrected form of AIC, should change nothing since it's dropping a
%%%constant term from all calculations the minimum will still happen in the
%%%same place.  Using vaf properly may change output though
AICvalue(:,1)=size(Xin,1)*log(var(Y)*(1-.01*vaf))+2*[1:nInputs]';   %Corrected AIC equation/extra N division dropped
AICcutoff=find(AICvalue==min(AICvalue));
%How many neurons going within 95% of the peak vaf says to use
bound95=find(vaf>=0.95*max(vaf));
cutoff95=bound95(1,1);
%Identies of the specific neurons to use for each criteria
if MDLcutoff==size(MDLvalue,1)
    MDLneurons=[1:1:size(MDLvalue,1)];
else
    MDLneurons=IDX{1,MDLcutoff}
end
%
if AICcutoff==size(AICvalue,1)
    AICneurons=[1:1:size(AICvalue,1)];
else
    AICneurons=IDX{1,AICcutoff}
end
%
if cutoff95==size(vaf,1)  %I don't think this is necessary
    neurons95=[1:1:size(vaf,1)];
else
    neurons95=IDX{1,cutoff95}
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y=RandPosInt(x)
%return a random integer less than or equal to x
y=ceil(x*rand(1));