function VAFstruct=batch_handControl_decoderPerformance2(decoderIn)

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
    [BatchList,datenames]=getDataByControlType(animal,decoderDay,'hand',1);
    save('BatchList.mat','BatchList','datenames')
else
    load('BatchList.mat')
end

load(findBDF_local(BatchList{1}))
out_structOriginal=out_struct;

for n=1:length(BatchList)
    BatchList{n}=regexprep(BatchList{n},'\t',''); 
    try
        % if they're hand control, load the local copy, save some time
        load(findBDF_local(BatchList{n}))
        numTargets(n)=floor(mean(getNumTargets(out_struct)));
        if out_struct.meta.duration < 510
            % require at least an 8.5 min file.  should there be other
            % constraints, i.e. #targets?
            fprintf(1,'\n\nskipping %s because it is too short\n(duration %.2f s)\n\n',...
                BatchList{n},out_struct.meta.duration)
            continue
        end
        if numTargets(n) <= 3
            fprintf(1,'\n\n%s has %d targets.  skipping...\n\n',...
                BatchList{n},numTargets(n))
            continue
        end
        % if spike decoder is being used, make sure the number of units in
        % the current file is the same as the number of units in the
        % original file.
        out_struct=alignSpikeUnits(out_struct,out_structOriginal);
        if ~nargin
            VAFstruct(n)=handControl_decoderPerformance_predictions2(out_struct);
        else
            VAFstruct(n)=handControl_decoderPerformance_predictions2(out_struct,decoderIn);
        end, close
        if VAFstruct(n).decoder_age==0
            % replace day 0 HC testing file that is the same file as that used to build
            % the decoder, with day 0 other HC testing file.  If there is no second day 0
            % HC file, eliminate that day from BatchList
            if strcmp(VAFstruct(n).name,regexp(decoderName,'.*(?=(poly|-spike))','match','once'))
                BL1=getDataByControlType(animal,decoderDay+[0 0],'hand',2);
                if ~isempty(BL1)
                    load(findBDF_local(BL1{1}))
                    numTargets(n)=floor(mean(getNumTargets(out_struct)));
                    if out_struct.meta.duration < 510
                        % require at least an 8.5 min file.  should there be other
                        % constraints, i.e. #targets?
                        fprintf(1,'\n\nskipping %s because it is too short\n(duration %.2f s)\n\n',...
                            BL1{1},out_struct.meta.duration)
                        % if we're here, it means the 1st file was no good
                        % and the 2nd file has to be skipped.  So, must
                        % delete the 1st file.
                        VAFstruct(n)=[];
                        continue
                    end
                    if ~nargin
                        VAFstruct(n)=handControl_decoderPerformance_predictions2(out_struct);
                    else
                        VAFstruct(n)=handControl_decoderPerformance_predictions2(out_struct,decoderIn);
                    end
                else % no 2nd file was found.
                    % still have to get rid of the first file, we'll 
                    VAFstruct(n)=[];
                end
            end
        end
    catch ME
        fprintf(2,['\n\n\n\n************************************', ...
            '\n*\n* %s\t*\n*\n************************************\n\n\n'],ME.message)
        continue
    end
    close
    % to make it here assumes we haven't hit a continue statement
    % somewhere, so n should line up properly.
    cd(originalPath)
    save(fullfile(originalPath,'VAFstruct.mat'),'VAFstruct')
end

for n=1:length(VAFstruct)
    if ~isempty(VAFstruct(n).name)
        VAFstruct(n).datename=datenames{n};
        VAFstruct(n).numTargets=numTargets(n);
    end
end
cd(originalPath)
save(fullfile(originalPath,'VAFstruct.mat'),'VAFstruct')




