function updateMeta(frd,meta)
    %this is a method function of the firingRateData class and should be
    %saved in the @firingRateData folder. 
    %
    %this is a wrapper function intended to allow the experiment
    %class to set the meta field of the firingRateData. It is not
    %really intended for public use
    set(frd,'meta',meta)
end