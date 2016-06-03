function bdf = addKinDataToBDF(filename_kin, filename_neural, filename_save)
% Takes a bdf that only has neural data and adds continuous data (e.g.
% kinematic, encoder, force, etc) from another BDF. I wrote this for the
% dual cerebus recordings, where one cerebus capture continuous data but
% both have neural data. If filename_save is not empty, saves data with
% that filename.

if nargin < 3
    filename_save = [];
end

load(filename_kin);
bdf = out_struct;

clear out_struct;
load(filename_neural);
bdf.meta = out_struct.meta;
bdf.units = out_struct.units;
clear out_struct;

if ~isempty(filename_save)
    save(filename_save,'bdf');
end
