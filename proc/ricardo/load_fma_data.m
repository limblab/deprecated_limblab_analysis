function fma_details = load_fma_data(fma_set,adapter_version)

load(['D:\Ricardo\Miller Lab\Matlab\s1_analysis\proc\ricardo\' fma_set])

samtec_omnetics = samtec_omnetics_adapters(adapter_version);

for i=1:length(fma_data)
    fma_details(i).array = fma_data(i,1);
    fma_details(i).connector_pin = fma_data(i,2);
    fma_details(i).electrode_number = fma_data(i,3);
    fma_details(i).tip_area = fma_data(i,4);
    fma_details(i).impedance = fma_data(i,5);
    fma_details(i).length = fma_data(i,6);
    try %#ok<TRYNC>
        fma_details(i).note = fma_textdata(i+1,7);
    end
end


    

