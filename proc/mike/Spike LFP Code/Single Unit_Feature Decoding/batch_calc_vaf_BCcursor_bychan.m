function [SingleChanVAF_AllFiles bestc_bychan bestf_bychan] = batch_calc_vaf_BCcursor_bychan(out_struct, PB, H, P, bestc, bestf, iostrat)

% This function calculates the vaf contribution of each feature to online BC cursor position

% FileList  - list of files to run
% PBList    - list of PB (power band) files to load in order to save time calculating power

% H         - decoder to test
% featind   - features to test

% iostrat   - enter 1 to use the findBDFon... enter 2 if files organized in
%             a folder structure format

% for i = 1:length(FileList)
%     if iostrat == 1
%         fnam = findBDFonCitadel(FileList{i})
%         load(fnam)
%     else
%         direct = 'C:\Users\M.R.Scheid\Desktop\Chewie Data';
%         %Set directory to desired directory
%         cd(direct);
%         Days=dir(direct);
%         Days(1:2)=[];
%         DaysNames={Days.name};
%     end

% for j = 1:length(featind)
%     bestc(j) = ceil(featind(j)/6);
%     
%     if rem(featind(j),6) ~=0
%         bestf(j) = rem(featind(j),6);
%     else
%         bestf(j) = 6;
%     end
%     
% end

[C,sortInd]=sortrows([bestc' bestf']);
bestc_bychan = C(:,1);
bestf_bychan = C(:,2);

[sig, samplerate, words, fp, numberOfFps, fp_start_time, fp_stop_time,...
    fptimes, analog_time_base, y_test] = SetPredictionsInputVar_Withsignal(out_struct);

[SingleChanVAF] = calc_vaf_BCcursor_bychan(PB, y_test, H, bestc_bychan, bestf_bychan, P);

SingleChanVAF_AllFiles(i,:) = SingleChanVAF;


