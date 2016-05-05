function unitName=getUnitName(units,unitNum)
    %method of the unitData class. Should be saved in the @unitData folder
    %
    %unitName=unitData.getUnitName(unitNum) returns a formatted string with the unit Name
    %corresponding to the unit in the unitNum position of the unitData.data
    %struct array.
    unitName=[units.data(unitNum).array,'CH',num2str(units.data(unitNum).chan),'ID',num2str(units.data(unitNum).ID)];
end