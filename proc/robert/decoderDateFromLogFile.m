function decoderDate=decoderDateFromLogFile(inputPath)

if nargin
    fid=fopen(inputPath);
else
    [FileNameBR,PathNameBR]=uigetfile('*.txt','select a file');
    fid=fopen(fullfile(PathNameBR,FileNameBR));
end

% should be the first line.
modelLine=fgetl(fid);
if ~isempty(regexp(modelLine,'Predictions made with model:', 'once'))
    decoderFile=regexp(modelLine,filesep,'split');
    decoderFile=decoderFile{end};
    
    
    datestring=regexp(modelLine,'[0-9]*(?=poly[0-9])','match','once');
    switch length(datestring)
        case 11
            decoderDate=datenum([datestring(1:2),'-',datestring(3:4),'-',datestring(5:8)]);
        case 3
            if isequal(datestring,'107')
                decoderDate=datenum('08-24-2011');
            else
                decoderDate=NaN;
            end
        otherwise
            decoderDate=NaN;
    end
    
    if isnan(decoderDate)
        fprintf(1,'decoder date could not be automatically determined.\m')
        decoderDate=input('Please enter the date of the decoder: ');
    end
else
    decoderDate=NaN;
end


fclose(fid);



