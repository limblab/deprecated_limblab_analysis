function VAFstruct=batch_handControl_decoderPerformance2(decoderIn)

% decoderIn is a path, not a matrix of some kind.

originalPath=pwd;

% all list-type inputs should be superseded by some logic similar to that
% which goes into HC_firstOverall.m
BatchList=HC_firstOverall(decoderIn);

for n=1:length(BatchList)
    BatchList{n}=regexprep(BatchList{n},'\t',''); 

    try
        % if they're hand control, load the local copy, save some time
        load(findBDF_local(BatchList{n}))
        if ~nargin
            VAFstruct(n)=handControl_decoderPerformance_predictions2(out_struct);
        else
            VAFstruct(n)=handControl_decoderPerformance_predictions2(out_struct,decoderIn);
        end
    end
    close
    cd(originalPath)
    save(fullfile(originalPath,'VAFstruct.mat'),'VAFstruct')
    assignin('base','VAFstruct',VAFstruct)
end




