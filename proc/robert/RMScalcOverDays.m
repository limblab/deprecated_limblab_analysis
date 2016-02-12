function RMSstruct=RMScalcOverDays(decoderIn)

% decoderIn is a path, not a matrix of some kind.

originalPath=pwd;

[decoderPath,decoderName,~]=FileParts(decoderIn);
% To use the decoder's "stated" date, i.e. the date of the hand control
% data file that serves as the original basis for the decoder:
decoderDay=datenum(regexp(decoderPath,'[0-9]{2}-[0-9]{2}-[0-9]{4}','match','once'),'mm-dd-yyyy');
animal=regexp(decoderName,'Chewie|Mini','match','once');
% Alternately: to use the date on which the handed-in version of the decoder
% was actually built (differs from the stated date in cases of zeroing
% channels, or other later manipulations).
%     D=dir(decoderPath);
%     decoderDay=floor(datenum(D(strcmp([decoderName,'.mat'],{D.name})).date));
cd(originalPath)
if exist('BatchList.mat','file')~=2
    [BatchList,datenames,decoderAge]=getDataByControlType(animal,decoderDay,'hand',1);
    save('BatchList.mat','BatchList','datenames')
else
    load('BatchList.mat')
end

for RMSCaldInd=1:length(BatchList)
    BatchList{RMSCaldInd}=regexprep(BatchList{RMSCaldInd},'\t',''); 
    try
        % if they're hand control, load the local copy, save some time
        load(findBDF_local(BatchList{RMSCaldInd}))
        numTargets(RMSCaldInd)=floor(mean(getNumTargets(out_struct)));
        if out_struct.meta.duration < 510
            % require at least an 8.5 min file.  should there be other
            % constraints, i.e. #targets?
            fprintf(1,'\n\nskipping %s because it is too short\n(duration %.2f s)\n\n',...
                BatchList{RMSCaldInd},out_struct.meta.duration)
            continue
        end
        fpAssignScript
        RMSstruct(RMSCaldInd).name=BatchList{RMSCaldInd};
        RMSstruct(RMSCaldInd).decoder_age=decoderAge(RMSCaldInd);
        RMSstruct(RMSCaldInd).rms=sqrt(sum(fp.^2,2)/size(fp,2));
        clear fp
    catch ME
        fprintf(2,['\n\n\n\n************************************', ...
            '\n*\n* %s\t*\n*\n************************************\n\n\n'],ME.message)
        continue
    end
    close
    % to make it here assumes we haven't hit a continue statement
    % somewhere, so n should line up properly.
    cd(originalPath)
    save(fullfile(originalPath,'RMSstruct.mat'),'RMSstruct')
end

for RMSCaldInd=1:length(RMSstruct)
    if ~isempty(RMSstruct(RMSCaldInd).name)
        RMSstruct(RMSCaldInd).datename=datenames{RMSCaldInd};
        RMSstruct(RMSCaldInd).numTargets=numTargets(RMSCaldInd);
    end
end
cd(originalPath)
save(fullfile(originalPath,'RMSstruct.mat'),'RMSstruct')




