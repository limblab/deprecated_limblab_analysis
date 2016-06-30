function decoderDate=decoderDateFromLogFile(inputPath,suppressInput)

if nargin >= 1
    fid=fopen(inputPath);
else
    [FileNameBR,PathNameBR]=uigetfile('*.txt','select a file');
    fid=fopen(fullfile(PathNameBR,FileNameBR));
    fullfile(PathNameBR,FileNameBR)
end

if nargin < 2
    suppressInput=0;
end

% should be the first line.
modelLine=fgetl(fid);
if ~isempty(regexp(modelLine,'Predictions made .*with model:', 'once'))
    datestring=regexp(modelLine,'[0-9]*(?=poly[0-9])','match','once');
    switch length(datestring)
        case 11
            decoderDate=datenum([datestring(1:2),'-',datestring(3:4),'-',datestring(5:8)]);
        case 3
            if isequal(datestring,'107')
                decoderDate=datenum('08-24-2011');
            else
                % assume linux file separators in model line!
                try
                    decoderDate=datenum(regexp(modelLine,['(?<=(Mini|Chewie)/)', ...
                        '[0-9][0-9]-[0-9][0-9]-','[0-9][0-9][0-9][0-9]'],'match','once'));
                catch
                    decoderDate=NaN;
                end
            end
        otherwise
            datestring=regexp(modelLine,'[0-9]{2}-[0-9]{2}-[0-9]{4}','match','once');
            if ~isempty(datestring)
                decoderDate=datenum(datestring);
            else
                decoderDate=NaN;
            end
    end
    
    if isnan(decoderDate)
        if ~suppressInput
            fprintf(1,'decoder date could not be automatically determined.\m')
            decoderDate=input('Please enter the date of the decoder: ');
        else
            error('decoder date could not be automatically determined\n')
        end
    end
else
    decoderDate=NaN;
end
fclose(fid);



