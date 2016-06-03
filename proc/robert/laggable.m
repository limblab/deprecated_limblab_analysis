function laggable(PathName)

if ~nargin
    PathName=pwd;
end
cd(PathName)
% create a folder for the outputs.  Create them with trailing numbers that
% will increment so that no folder is ever overwritten.
folderStr='laggable_LFP_Spike1';
% outputs will be saved in folderNew
for numlags=[1 2 5 10 15 20 30 50]
    if exist(folderStr,'dir')~=0
        D=dir(PathName);
        folderStrNoNumbers=regexp(folderStr,'.*(?=[0-9])','match','once');
        folderNumbers=cellfun(@(x) str2num(x),regexp({D.name}, ...
            ['(?<=',folderStrNoNumbers,')[0-9]+'],'match','once'),'UniformOutput',0);
        folderNew=[folderStrNoNumbers, num2str(max(cat(2,folderNumbers{:}))+1)];
    else
        folderNew=folderStr;
    end
    mkdir(folderNew)

    batch_buildLFPspikesEMGdecoder_lagFunction('C:\Documents and Settings\Administrator\Desktop\RobertF\data\sorted', ...
    numlags,folderNew)
end