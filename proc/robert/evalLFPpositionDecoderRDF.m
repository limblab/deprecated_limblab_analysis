function evalLFPpositionDecoderRDF(DecoderPath,DecoderDatenum,PathFileName)

if ~nargin
	[FileName,PathName,~] = uigetfile('C:\Documents and Settings\Administrator\Desktop\RobertF\data\','select a *.plx file','*.*');
	[FileNameDecoder,PathNameDecoder,~] = uigetfile('C:\Documents and Settings\Administrator\Desktop\RobertF\data\','select a decoder file','*.*');
    DecoderPath=fullfile(PathNameDecoder,FileNameDecoder);
else
    % assume both are full path/file names.  DecoderPath is fine as is.
    [PathName,FileName,ext]=fileparts(PathFileName);
    FileName=[FileName,ext];
    [PathNameDecoder,FileNameDecoder,decoderExt]=fileparts(DecoderPath);
    FileNameDecoder=[FileNameDecoder,decoderExt];
end
cd(PathName)

if isequal(get(0,'Diary'),'off')
    % if ~nargin, this seems stupid and repetitive, but making it
    % inconsistent would be stupider.
    diary(fullfile(PathNameDecoder,[FileNameDecoder(1:end-4),'HCperformance_LFPcontrolDays.txt']))
end
fprintf(1,'evaluating %s.\n',FileName)
%% load the file 
switch FileName(end-3:end)
    case '.mat'
        disp(['loading BDF structure from ',FileName])
        load(fullfile(PathName,FileName))
    case '.plx'
        out_struct=get_plexon_data(FileName);
        save([regexp(FileName,'.*(?=\.plx)','match','once'),'.mat'],'out_struct')
end
if ~isfield(out_struct,'raw')
    % if there was an error in the .plx file such that no event 257 was
    % recorded (no handle data), then the new get_plexon_data will have 
    % regurgitated an out_struct with only a .meta field.
    % Whether this is being loaded in via get_plexon_data, or it is 
    % somehow still around in .mat form, the thing to do is to cut it 
    % out completely from the results.mat file.
    fprintf(1,'\n\n\n===========================\n no out_struct.raw field.\nHCperformance_LFPcontrolDays_data')
    load([DecoderPath(1:end-4),'_performance.mat'],'HCperformance_LFPcontrolDays_data')
    fprintf(1,'being reduced from %d rows to ',size(HCperformance_LFPcontrolDays_data,1))
    HCperformance_LFPcontrolDays_data(find(cellfun(@isempty,HCperformance_LFPcontrolDays_data(:,2)),1,'first'):end,:)=[];
    save([DecoderPath(1:end-4),'_performance.mat'],'HCperformance_LFPcontrolDays_data')
    fprintf(1,'%d rows.\n===========================\n',size(HCperformance_LFPcontrolDays_data,1))
    return
end
disp(sprintf('\n\n\n\n\n=====================\nFILE LOADED\n===================='))

fnam=FileName(1:end-4);
% store the results in a file that can be imported to excel.  Add a blank
% tab for the before/after_BC column, that just leaves performance
% fid=fopen([DecoderPath(1:end-4),'_data.txt'],'a');
% fprintf(fid,'%d\t\t',DecoderDatenum-datenum(regexp(out_struct.meta.datetime,'.*(?=\s)','match','once')))
% fclose(fid);
% store in a .mat file
load([DecoderPath(1:end-4),'_performance.mat'],'HCperformance_LFPcontrolDays_data')
HCperformance_LFPcontrolDays_data{find(cellfun(@isempty,HCperformance_LFPcontrolDays_data(:,2)),1,'first'),2}= ...
    datenum(regexp(out_struct.meta.datetime,'.*(?=\s)','match','once'))-DecoderDatenum;
disp(sprintf('\n\n\n\n\n=====================\nFILE LOADED\n===================='))
%% input parameters - Do not Change, just run.
disp('assigning static variables')

% behavior
signal='vel';
sig=out_struct.(signal);
analog_times=sig(:,1);

% assign FPs, offloaded to script so it can be used in other places.
fpAssignScript
% since we are evaluating rather than building a decoder, we want to leave
% all channels intact rather than finding & removing badChannels.  If any
% channels are bad, we want that to be revealed by the poor performance of
% the decoder
disp('static variables assigned')
%%
% 1st (and last?) second of data gets eliminated by calc_from_raw for the encoder
% timestampe (see out_struct.raw.analog.pos or .vel, so is inappropriate to
% include them in the fp signals.
if 0
    fp(:,fptimes<1 | fptimes>analog_times(end))=[];
    fptimes(fptimes<1 | fptimes>analog_times(end))=[];
end
%%
% downsample, so the delta band isn't empty at wsz=256; this is a current
% limitation of BrainReader.
if 0%samprate > 1000
    % want final fs to be 1000
    disp('downsampling to 1 kHz')
    samp_fact=samprate/1000;
    downsampledTimeVector=linspace(fptimes(1),fptimes(end),length(fptimes)/samp_fact);
    fp=interp1(fptimes,fp',downsampledTimeVector)';
    fptimes=downsampledTimeVector;
    downsampledTimeVector=linspace(analog_times(1),analog_times(end),length(analog_times)/samp_fact);
    downSampledBehaviorSignal=interp1(analog_times,sig(:,2:3),downsampledTimeVector);
    analog_times=downsampledTimeVector; clear downsampledTimeVector
    sig=[rowBoat(analog_times),downSampledBehaviorSignal];
    samprate=1000;
end

numfp=size(fp,1);
numsides=1;
Use_Thresh=0; words=[]; emgsamplerate=[]; lambda=1;
disp('done')
%% Input parameters to play with.
disp('assigning tunable parameters and building the decoder...')
numlags=10; 
wsz=256; 
nfeat=150;
PolynomialOrder=3; 
smoothfeats=0;
binsize=0.05;

%%
% DecoderPath is the entire path to the file, including the file name and
% the extension.
disp('loading decoder file')
load(DecoderPath,'H','bestc','bestf')
fprintf(1,'%s loaded.\n',DecoderPath)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%CROSS-FOLD TESTING%%%%%%%%%%%%%%%%%%%%%%%%%%
folds=10;
Hcell=cell(1,folds);
[Hcell{1:folds}]=deal(H);
[vaf,vmean,vsd,y_test,y_pred,r2mean,r2sd,r2,vaftr,bestf,bestc,H,bestfeat,x,y, ...
    featMat,ytnew,xtnew,predtbase,P,featind,sr] = ...
    predictionsfromfp6_inputDecoder(sig,signal,numfp,binsize,folds,numlags,numsides, ...
    samprate,fp,fptimes,analog_times,fnam,wsz,nfeat,PolynomialOrder, ...
    Use_Thresh,Hcell,words,emgsamplerate,lambda,smoothfeats,[bestc; bestf]);


% examine vaf
fprintf(1,'file %s\n',fnam)
fprintf(1,'decoding %s\n',signal)
fprintf(1,'numlags=%d\n',numlags)
fprintf(1,'wsz=%d\n',wsz)
fprintf(1,'nfeat=%d\n',nfeat)
fprintf(1,'PolynomialOrder=%d\n',PolynomialOrder)
fprintf(1,'smoothfeats=%d\n',smoothfeats)
fprintf(1,'binsize=%.2f\n',binsize)

vaf

formatstr='vaf mean across folds: ';
for k=1:size(vaf,2), formatstr=[formatstr, '%.4f   ']; end
formatstr=[formatstr, '\n'];

fprintf(1,formatstr,mean(vaf,1))
fprintf(1,'overall mean vaf %.4f\n',mean(vaf(:)))

diary off

HCperformance_LFPcontrolDays_data{find(cellfun(@isempty,HCperformance_LFPcontrolDays_data(:,4)),1,'first'),4}= ...
    vaf(:,1);
HCperformance_LFPcontrolDays_data{find(cellfun(@isempty,HCperformance_LFPcontrolDays_data(:,5)),1,'first'),5}= ...
    vaf(:,2);
save([DecoderPath(1:end-4),'_performance.mat'],'HCperformance_LFPcontrolDays_data')
