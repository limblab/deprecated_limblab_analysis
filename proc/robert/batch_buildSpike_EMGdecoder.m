% this script operates on a folder that contains 1 or more .mat
% files containing FP and EMG data

%% folder/file info
PathName = uigetdir('C:\Documents and Settings\Administrator\Desktop\RobertF\data\','select folder with data files');
if exist(PathName,'dir')~=7
    disp('folder not valid.  aborting...')
    return
end
cd(PathName)
Files=dir(PathName);
diary('r2results.txt')
Files(1:2)=[];
FileNames={Files.name};
MATfiles=FileNames(cellfun(@isempty,regexp(FileNames,'[^EMGonly]\.mat'))==0);
if isempty(MATfiles)
    fprintf(1,'no MAT files found.  Make sure no files have ''only'' in the filename\n.')
    disp('quitting...')
    return
end

% master containment for r2 aggregate data
r2all=cell(length(MATfiles),4);

for n=1:length(MATfiles)
    FileName=MATfiles{n};
    load(FileName,'bdf')
    fnam=FileName(1:end-4);
    
    str=regexp(bdf.meta.datetime,' ','split');
    r2all{n,1}=datestr(str{1},'mm-dd-yyyy');
    r2all{n,2}=fnam;

    % make sure the bdf has a .emg field
    bdf=createEMGfield(bdf);
            
    %% the units - take only sorted units
    uList=unit_list(bdf);
    bdf.units(uList(:,2)==0)=[];

    %% parameters
    try
        emgsamplerate=bdf.emg.emgfreq;
    catch
        emgsamplerate=bdf.emg.freq;
    end
    
    signal='emg';
    numsides=1;
    Use_Thresh=0; words=[]; lambda=1;

    folds=10;
    numlags=10;
    PolynomialOrder=3;
    binsize=0.05;
    cells=[];
    if exist('fnam','var')~=1
        fnam='';
    end
    
    [vaf,vmean,vsd,y_test,y_pred,r2mean,r2sd,r2,vaftr,H,x,y,ytnew,xtnew] = ...
        predictions_mwstikpoly(bdf,signal,cells,binsize,folds,numlags,numsides, ...
        lambda,PolynomialOrder,Use_Thresh);
    close

    fprintf(1,'\n\n\n\n\n=====================\nDONE\n====================\n\n\n\n')
    
    EMGchanNames={'BI','Tri','Adelt','Pdelt'};
    if exist('FileName','var')==1
        disp(FileName)
    end
    fprintf(1,'folds=%d\n',folds)
    fprintf(1,'numlags=%d\n',numlags)
    fprintf(1,'\n')
    fprintf(1,'\n')
    fprintf(1,'PolynomialOrder=%d\n',PolynomialOrder)
    fprintf(1,'\n')
    fprintf(1,'binsize=%.2f\n',binsize)
    fprintf(1,'emgsamplerate=%d\n',emgsamplerate)
    
    r2
    
    r2all{n,3}=r2;

    formatstr='EMG r2 mean across folds: ';
    for k=1:size(r2,2), formatstr=[formatstr, '%.4f   ']; end
    formatstr=[formatstr, '\n'];
    fprintf(1,formatstr,mean(r2,1))
    fprintf(1,'overall mean r2 %.4f\n',mean(r2(:)))
    
    clear FileName fnam bdf emgsamplerate signal numsides
    clear folds numlags PolynomialOrder binsize vaf vmean vsd y_test y_pred r2mean r2sd r2 vaftr
    clear H EMGchanNames Use_Thresh cells lambda str uList words x xtnew y ytnew formatstr k
end
diary off
clear n
