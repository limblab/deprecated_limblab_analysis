%%
% Currently I assume that the spike guide doesn't change between files
% Here is a hack if it does
buM1 = checkUnits(sgM1BL,sgM1AD,sgM1WO);
sgM1BL(sgM1BL(:,1)==buM1,:) = [];
sgM1AD(sgM1AD(:,1)==buM1,:) = [];
sgM1WO(sgM1WO(:,1)==buM1,:) = [];
pdsM1BL(sgM1BL(:,1)==buM1,:) = [];
pdsM1AD(sgM1AD(:,1)==buM1,:) = [];
pdsM1WO(sgM1WO(:,1)==buM1,:) = [];
ciM1BL(sgM1BL(:,1)==buM1,:) = [];
ciM1AD(sgM1AD(:,1)==buM1,:) = [];
ciM1WO(sgM1WO(:,1)==buM1,:) = [];

buPMd = checkUnits(sgPMdBL,sgPMdAD,sgPMdWO);
sgPMdBL(sgPMdBL(:,1)==buPMd,:) = [];
sgPMdAD(sgPMdAD(:,1)==buPMd,:) = [];
sgPMdWO(sgPMdWO(:,1)==buPMd,:) = [];
pdsPMdBL(sgPMdBL(:,1)==buPMd,:) = [];
pdsPMdAD(sgPMdAD(:,1)==buPMd,:) = [];
pdsPMdWO(sgPMdWO(:,1)==buPMd,:) = [];
ciPMdBL(sgPMdBL(:,1)==buPMd,:) = [];
ciPMdAD(sgPMdAD(:,1)==buPMd,:) = [];
ciPMdWO(sgPMdWO(:,1)==buPMd,:) = [];