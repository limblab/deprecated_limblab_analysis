function kinStructOut=Mini_datenames(kinStructIn)

% syntax kinStructOut=Mini_datenames(kinStructIn)
%
% generate datename-style names for Mini's data files, which are numbered
% 1-N by default.
%
% this function makes use of (and therefore assumes the presence of) a
% variable called kinStruct.mat in a folder named for the date on
% citadel/data/[animal]/FilterFiles, or appropriate.

% why not just take the date off the folder?  because you can't know how
% many files were recorded in a given day from that info, or where the
% current file occurred in that list.  Not even well enough to keep the 
% file names unique, unless you're willing to make additional assumptions.
% You can only know the date.

if ispc
else
    [status,result]=unix('find /Volumes/data/Mini_7H1/FilterFiles -name "kinStruct.mat" -print');
    if status~=0
        fprintf(1,'\n\ncheck to see if citadel/data is mounted\n\n')
        error(result)
    end
    [status,res2]=unix('find /Volumes/data/Mini_7H1/bdf -name "kinStruct.mat" -print');
    if status==0
        result=[result, res2];
    end
    clear res2
end
returns=[1 regexp(result,sprintf('\n'))];
p=1;
for k=2:length(returns)
    thisKSpath=result(returns(k-1):returns(k));
    thisKSpath(regexp(thisKSpath,sprintf('\n')))='';
    % find the date in thisKSpath
    datestring=regexprep(regexp(thisKSpath, ...
        '[0-9]{2}-[0-9]{2}-[0-9]{4}','match','once'),'-','');
    if datenum(datestring,'mmddyyyy') <= datenum('03-26-2012','mm-dd-yyyy')
        S=load(thisKSpath);
        kinStruct=S.kinStruct; clear S
        
        for m=1:length(kinStruct)
            datenames{p}=['Mini_Spike_LFPL_',datestring,sprintf('%03d',m),'.mat'];
            filenames{p}=kinStruct(m).name;
            p=p+1;
        end
        clear kinStruct
    end
end

for n=1:length(kinStructIn)
    kinStructIn(n).datename=datenames{strcmp(kinStructIn(n).name,filenames)};
end

kinStructOut=kinStructIn;