function DataSigs = concatSigs(binnedData, EMGs, Force, CursPos, Veloc)

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
    if Veloc
        DataSigs = [DataSigs binnedData.velocbin];
    end

end

