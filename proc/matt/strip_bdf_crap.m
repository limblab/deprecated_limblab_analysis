% load file
useDate = '2014-03-04';
array = 'M1';
pert = 'VR';
task = 'CO';
epoch = 'BL';
monk = 'Mihili';

m = useDate(6:7);
d = useDate(9:10);
y = useDate(1:4);

filedir = ['Z:\Mihili_12A3\Matt\' array '\BDFStructs\' useDate '\'];
filename = [monk '_' array '_' task '_' pert '_' epoch '_' m d y '.mat'];

load(fullfile(filedir,filename));

% build new struct
data.meta = out_struct.meta;
data.units = out_struct.units;
data.pos = out_struct.pos;
data.vel = out_struct.vel;
data.acc = out_struct.acc;
data.force = out_struct.force;
data.target = out_struct.targets;

% remove neurons with channels greater than 96
badInds = [];
for i = 1:length(data.units)
    if data.units(i).id(1) > 96 || data.units(i).id(2) == 0 || data.units(i).id(2) == 255
        badInds = [badInds i];
    end
end

data.units(badInds) = [];

save(filename,'data');