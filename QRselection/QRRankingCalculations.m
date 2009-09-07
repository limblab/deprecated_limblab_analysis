%%%This file (together with SelectBestInputsEJP2 and FilmisoSVDEJP2) tests
%%%the uniqueness of each neural input per each EMG output to find the most
%%%unique inputs.  It compares selection methods of AIC, MDL, and 95% vaf.
%%%Look at the trends of R2 both fitted and x-validated with those methods
%%%to see which should be selected in choosing the necessary number of
%%%inputs.  Compare this with just choosing a fixed (say 10) number of
%%%inputs.
%%%filenumber should be provided by InputMethodSelectionAll when
%%%running multiple files at once
%%%Start is also set by InputSelectionMultiRuns, and save should be turned off
%%%here as well (last line)

%%%Last modified March 3, 2006 EAP
%%%Eric Pohlmeyer

% addpath D:\Data\MatlabRealTime\functions\mad6_rc3
% addpath D:\Data\MatlabRealTime\functions\core_files
% addpath D:\Data\MatlabRealTime\functions

addpath ..\mimo

%function [R2fit, R2xval, IDXall, MDLneuronsall, AICneuronsall,neurons95all]=InputMethodSelectionAnimal(filename, start, finish, goodinputs)

%Use the first 6 minutes of data
start=1;    %comment out if external controller is on
finish=12000;    %50 msec bins, 10 min file, comment out if external controller is on

savefilename = ['InputSelectTheo_5-12-09_004_50ms_05Hz'];

%X-validate in a consistent fashion by using the final 1 minute of data
%FOR 20msec bins
% numpoints=size(emgdatabin,1);
% finishxval=3000*floor(numpoints/3000);
% startxval=finishxval-3000+1;
% nlags=25;

%X-validate in a consistent fashion by using the final 1 minute of data
%FOR 50msec bins
numpoints=size(binnedData.emgdatabin,1);
finishxval=1200*floor(numpoints/1200);
startxval=finishxval-1200+1;
nlags=10;

goodEMGs=[1 3 5 8];   %The EMGs I want to consider - FDSu, FDPu, FCR1, FDI

goodinputs=1:size(binnedData.spikeratedata,2);

totalinputs=binnedData.spikeratedata(start:finish,goodinputs);
totalinputsxval=binnedData.spikeratedata(startxval:finishxval,goodinputs);
%%%Runs the selection file for each relevant EMG
for j=1:length(goodEMGs)
    j
    output=binnedData.emgdatabin(start:finish,[goodEMGs(1,j)]);
    outputxval=binnedData.emgdatabin(startxval:finishxval,[goodEMGs(1,j)]);
    [IDX,vb,MDLneurons,AICneurons,neurons95]=SelectBestInputsEJP2(totalinputs,output,nlags);
    MDLneuronsall(j,:)=size(MDLneurons,2);
    AICneuronsall(j,:)=size(AICneurons,2);
    neurons95all(j,:)=size(neurons95,2);
    IDXall(j,:)=IDX;
    %Check for the first k most significant neural inputs for each EMG
    for k=1:size(totalinputs,2)
        k
        if k~=size(totalinputs,2)
            inputstouse=IDX{1,k};   %Selecting inputs in order of uniqueness
        else
            inputstouse=1:1:size(totalinputs,2);  %using all available inputs
        end        
        inputs=totalinputs(:,inputstouse);
        %%%Fitting data
        [H,v,mcc]=filMIMO3(inputs,output,nlags,1,1);
        [Y,Xnew,Yact]=predMIMO3(inputs,H,1,1,output);
        R=corrcoef(Y,Yact);
        R2fit(j,k)=R(1,2).^2;
        %%%Cross-Validation
        inputsxval=totalinputsxval(:,inputstouse);
        [Y2,Xnew2,Yact2]=predMIMO3(inputsxval,H,1,1,outputxval);
        R=corrcoef(Y2,Yact2);
        R2xval(j,k)=R(1,2).^2;
    end
    clear inputstouse output inputs IDX vb MDLneurons AICneurons neurons95
end
R2fit
R2xval
IDXall

%%%Comment out if external controller is on
save(savefilename, 'R2fit', 'R2xval', 'IDXall', 'MDLneuronsall', 'AICneuronsall', 'neurons95all')