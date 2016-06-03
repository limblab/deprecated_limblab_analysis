


%Make sure the spikeguide and spike data are the same
badUnits = checkUnitGuides(IsoBinned.spikeguide, WmBinned.spikeguide);
sg = setdiff(IsoBinned.spikeguide, badUnits, 'rows');
[DifferenceIso index] = setdiff(IsoBinned.spikeguide, sg, 'rows');
IsoBinned.spikeratedata(:,index) = [];
IsoBinned.spikeguide = sg;
IsoBinned.neuronIDs = spikeguide2neuronIDs(sg);

[DifferenceWm index] = setdiff(WmBinned.spikeguide, sg, 'rows');
WmBinned.spikeratedata(:,index) = [];
WmBinned.spikeguide = sg;
WmBinned.neuronIDs = spikeguide2neuronIDs(sg);

[DifferenceSpr index] = setdiff(SprBinned.spikeguide, sg, 'rows');
SprBinned.spikeratedata(:,index) = [];
SprBinned.spikeguide = sg;
SprBinned.neuronIDs = spikeguide2neuronIDs(sg);
