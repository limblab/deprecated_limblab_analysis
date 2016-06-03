
function samtec_omnetics = samtec_omnetics_adapters(adapter_version)

if (adapter_version == 1)
    load('D:\Ricardo\Miller Lab\Matlab\s1_analysis\proc\ricardo\samtec_omnetics_adapters_ver_1')
end

for i = 1:length(samtec_omnetics_data)
    samtec_omnetics(i).adapter = samtec_omnetics_textdata(i+1,1);
    samtec_omnetics(i).omnetics_connector = samtec_omnetics_data(i,1);
    samtec_omnetics(i).omnetics_pin = samtec_omnetics_data(i,2);
    samtec_omnetics(i).samtec_pin = samtec_omnetics_data(i,3);
    samtec_omnetics(i).cerebus_channel = samtec_omnetics_data(i,4);
    if ~strcmp(samtec_omnetics_textdata(i+1,6),'')
        samtec_omnetics(i).function = samtec_omnetics_textdata(i+1,6);
    else
        samtec_omnetics(i).function = samtec_omnetics_data(i,5);
    end
end