function reCrop(frd,cropType)
    %this is a method function of the firingRateData class and should be
    %saved in the @firingRateData folder. 
    %
    %frd.reCrop(cropType)
    %where frd is a firingRateData object and cropType is a string
    %re-does the firing rate matrix cropping based on lags.
    %Cropping removes points at the beginning and end of the time
    %series where data did not exist to generate lags. These points
    %are normally filled with 'nan'.
    %crop types are:
    %'noCrop':      does not crop the data- this is implemented for 
    %               consistency with the firing rate computation, but will 
    %               not do anything here. If the data is already cropped 
    %               reCrop will throw an error
    %'keepSize':    will ensure that the firing rate matrix has the same
    %               window as the source data
    %'tightCrop':   removes all rows that have NaN values. Uses the lags to
    %               identify which rows will have NaNs rather than using
    %               isnan or similar to find offending rows
    %               
    if isempty(frd.data)
        error('reCrop:noData','there is no data in the firingRateData object to crop')
    end

    switch frd.meta.cropType
        case 'noCrop'
            switch cropType
                case 'noCrop'
                    warning('reCrop:AlreadyKeptSize','the firing rate data was already cropped with the keepSize flag. No cropping was performed')
                case 'keepSize'
                    set(frd,'data',frd.data(abs(min(frd.meta.lags))+1:end-max(frd.meta.lags),:));
                case 'tightCrop'
                    tmp=abs(min(frd.meta.lags))+max(frd.meta.lags);
                    set(frd,'data',frd.data(tmp+1:end-tmp,:));
                otherwise
                    error('reCrop:unrecognizedMethod',['reCrop does not recognize the cropping method: ',cropType])
            end
        case 'keepSize'
            switch cropType
                case 'noCrop'
                    error('reCrop:cannotUnCrop','You tried to reCrop the data with noCrop as the method, but the data was already cropped')
                case 'keepSize'
                    warning('reCrop:AlreadyKeptSize','the firing rate data was already cropped with the keepSize flag. No cropping was performed')
                case 'tightCrop'
                    set(frd,'data',frd.data(max(frd.meta.lags)+1:end-abs(min(frd.meta.lags)),:));
                otherwise
                    error('reCrop:unrecognizedMethod',['reCrop does not recognize the cropping method: ',cropType])
            end
        case 'tightCrop'
            switch cropType
                case 'noCrop'
                    error('reCrop:cannotUnCrop','You tried to reCrop the data with noCrop as the method, but the data was already cropped')
                case 'keepSize'
                    error('reCrop:cannotUnCrop','You tried to reCrop the data with keepSize as the method, but the data was already cropped with tightCrop')
                case 'tightCrop'
                    warning('reCrop:alreadyTightCroppped','the firing rate data was already tight cropped, and cannot be further cropped')
                otherwise
                    error('reCrop:unrecognizedOriginalCropping',['could not identify the original cropping method: ',frd.meta.cropType,' unable to re-crop the firing rate data'])
            end

    end
    %% notify the listner so that this can be logged:
    evntData=loggingListenerEventData('reCrop',cropType);
    notify(ex,'ranOperation',evntData)
end