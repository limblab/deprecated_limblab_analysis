function DataSigs = concatSigs_Matt(binnedData, EMGs, Force, CursPos, Veloc, Targ, CompVeloc, MoveDir)

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
    if Targ
        DataSigs = [DataSigs binnedData.targetanglebin];
    end
    if CompVeloc
        DataSigs = [DataSigs binnedData.compvelocbin];
    end
    if MoveDir
        DataSigs = [DataSigs binnedData.movedirbin];
    end
end

