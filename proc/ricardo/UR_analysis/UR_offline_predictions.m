function params = UR_offline_predictions(data_struct,params)

UR = data_struct.UR;
bdf = data_struct.bdf;

binnedData = convertBDF2binned(bdf);
filter = load(params.offline_decoder);
if isfield(filter,'filter')
    filter = filter.filter;
end
PredData = predictEMGs(filter,binnedData);