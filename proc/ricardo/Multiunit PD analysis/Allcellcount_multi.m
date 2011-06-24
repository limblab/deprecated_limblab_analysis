clc;clear;
pathnamesorted='D:\Data\Tiki_4C1\FMAs\Sorted\';
pathname='D:\Data\Tiki_4C1\FMAs\Processed\';
pathnameout='D:\Ricardo\Miller Lab\Results\Tiki\Multiunit PDs\';
pathnamePDs='D:\Ricardo\Miller Lab\Matlab\s1_analysis\proc\ricardo\Multiunit PD analysis\';
% roots={'Tiki_2011-05-17_RW_001-s_thres2','Tiki_2011-05-19_RW_001-s_thres',...
%     'Tiki_2011-05-23_RW_001-s_thres','Tiki_2011-05-24_RW_001-s_thres',...
%     'Tiki_2011-05-25_RW_001-s_thres','Tiki_2011-05-26_RW_001',...
%     'Tiki_2011-05-27_RW_001-s_thres','Tiki_2011-06-02_RW_001-xcr-5-5'};.
% roots={'Tiki_2011-06-02_RW_001-xcr-5-5-single_units'};
roots = {'Tiki_2011-06-07_RW_001-single_units'};
%  roots={'Tiki_2011-06-02_RW_001-xcr-5-5'};

for iFile=1:length(roots)
    disp(['File: ' num2str(iFile) ' of ' num2str(length(roots))])
    root = roots(iFile);
    if ~exist([cell2mat(strcat(pathname,root)) '.mat'],'file')
        data=get_cerebus_data([pathnamesorted,char(root),'.nev']);
        save([pathname,char(root)], 'data');
    end
    
    if ~exist([pathnamePDs,char(root),'_multi.mat'],'file')
        PDfromspikesFtic_cell_count_multi
        save([pathnamePDs,char(root),'_multi.mat'], 'allfilesPDs');
        figureformulti
    end
end