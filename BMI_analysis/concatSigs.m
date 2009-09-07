function DataSigs = concatSigs(binnedData, EMGs, Force, CursPos)

    DataSigs = [];

    if EMGs
        DataSigs = binnedData.emgdatabin;
    end
    if Force
        DataSigs = [DataSigs binnedData.forcedatabin];
    end
    if CursPos
        DataSigs = [DataSigs binnedData.cursorposbin];
    end

end

