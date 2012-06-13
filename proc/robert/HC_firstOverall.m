function BatchList=HC_firstOverall(decoderIn)

% decoderIn is just a seed, to anchor us in time.

% get animal and dayIn from decoderIn.  
if nargin
    % go semi-dumb for now, at least in terms of assumptions.
    [decoderPath,decoderName,~]=FileParts(decoderIn);
    animal=regexp(decoderName,'Chewie|Mini','match','once');
    decoderDay=datenum(regexp(decoderPath,'[0-9]{2}-[0-9]{2}-[0-9]{4}','match','once'),'mm-dd-yyyy');
    m=1;
    for timeTravelIndex=decoderDay:today
        try
            BDFlist_HC=findBDF_withControl(animal,datestr(timeTravelIndex,'mm-dd-yyyy'),'hand');
            BDFlist_LFP=findBDF_withControl(animal,datestr(timeTravelIndex,'mm-dd-yyyy'),'LFP');
            BDFlist_Spike=findBDF_withControl(animal,datestr(timeTravelIndex,'mm-dd-yyyy'),'Spike');
            BDFlist_all=[rowBoat(BDFlist_HC), num2cell(ones(length(BDFlist_HC),1)); ...
                rowBoat(BDFlist_LFP), num2cell(1+ones(length(BDFlist_LFP),1)); ...
                rowBoat(BDFlist_Spike), num2cell(2+ones(length(BDFlist_Spike),1))];
            [~,sortInd]=sort(cat(1,BDFlist_all{:,2}),'ascend');
            if BDFlist_all{sortInd(1),2}==1
                BatchList{m}=BDFlist_all{sortInd(1),1};
                m=m+1;
            end
        catch ME
            if ~isempty(regexp(ME.message,'file not found', 'once'))
                % if it's a simple matter of the day not being there, no
                % need to quit over that.
                continue
            else
                % if there was some other kind of message, well we need to
                % know
                rethrow(ME)
            end
        end
    end
else
    if ~input('using hard-coded BatchList.  Proceed?')
        return
    end
end