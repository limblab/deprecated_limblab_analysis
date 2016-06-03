function electrode_to_cerebus = fma_to_cerebus_mapping(varargin)

if length(varargin)==3
    configuration = cell2mat(varargin(1));
    adapter_version = cell2mat(varargin(2));
    data_file = cell2mat(varargin(3));
else
    configuration = 'TikiFMAs';
    adapter_version = 1;
    data_file = 'Tiki_2011-04-22_RW_001.nev';
end

samtec_omnetics = samtec_omnetics_adapters(adapter_version);
fma_data = load_fma_data(configuration,adapter_version);
array_omnetics_map = array_omnetics_maps(configuration,data_file);
electrode_to_cerebus = [];

for i=1:length(array_omnetics_map)
    fma_data_indexes = [fma_data.array] == array_omnetics_map(i,1);
    fma_electrodes = [fma_data(fma_data_indexes).electrode_number];
    fma_connector_pins = [fma_data(fma_data_indexes).connector_pin];
    fma_tip_area = [fma_data(fma_data_indexes).tip_area];
    fma_length = [fma_data(fma_data_indexes).length];
    
    samtec_indexes = [samtec_omnetics.omnetics_connector] == array_omnetics_map(i,2);
    samtec_omnetics_pins = [samtec_omnetics(samtec_indexes).omnetics_pin];
    cerebus_channel = [samtec_omnetics(samtec_indexes).cerebus_channel];
    
    electrode_to_cerebus = [electrode_to_cerebus;
                            repmat(array_omnetics_map(i,1),length(fma_connector_pins),1),...
                            fma_electrodes',fma_connector_pins', fma_tip_area', fma_length',...
                            cerebus_channel'];                        
end
