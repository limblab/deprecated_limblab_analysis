function SNRout=fp_spikeSNR(bdfNameIn)

% syntax SNRout=fp_spikeSNR(bdfNameIn)

fsep=[filesep filesep];
if ~ispc, fsep(1)=''; end

BRpath=regexprep(findBDFonCitadel(bdfNameIn), ...
    {'bdf|BDFs','\.mat'},{['Brainreader logs',fsep,'online'],'.txt'});
BRpath(regexp(BRpath,sprintf('\n')))=[];

if exist(BRpath,'file')==2
    dType=decoderTypeFromLogFile(BRpath);
end

switch dType
    case 'LFP'
        % looking for a viable calculation.
        
    case 'Spike'
        % rely on waveforms.  If .mat file exists, load it...
        
        % ... otherwise, need to open from .plx
        pathToPLX=findPLXonCitadel(regexprep(bdfNameIn,'\.mat','.plx'),1);
        units=get_waveforms_plx(pathToPLX,struct('verbose',1));
        units(cellfun(@isempty,{units.id}))=[];
        save(fullfile('E:\personnel\RobertF\monkey_analyzed\LFPcontrol\waveforms', ...
            bdfNameIn),'units')
        
        
        SNRout=zeros(size(units));
        for n=1:length(units)
            SNRout(n)=(mean(max(units(n).waveforms,[],2)-min(units(n).waveforms,[],2)))/ ...
                (2*mean(std(units(n).waveforms,0,1)));
        end
end




