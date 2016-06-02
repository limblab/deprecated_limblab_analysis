

file_1='E:\processing\NEVNSx_testing\Kramer_RW_05152013_tucker_002.nev';
file_2='E:\processing\NEVNSx_testing\Kramer_RW_05162013_tucker_001.nev';
savename='E:\processing\NEVNSx_testing\Kramer_RW_05152013_tucker_grouped.nev';

NEV1=openNEV(file_1,'report','read');
NEV2=openNEV(file_2,'report','read');
%clear out encoder data. Concatenating the Nev's wit the addNEV function
%won't work unless you do this first.
% %    NEV1.Data.SerialDigitalIO.TimeStamp=[];
% %    NEV1.Data.SerialDigitalIO.TimeStampSec=[];
% %    NEV1.Data.SerialDigitalIO.InsertionReason=[];
%     NEV1.Data.SerialDigitalIO.UnparsedData=[];
% %    NEV2.Data.SerialDigitalIO.TimeStamp=[];
% %    NEV2.Data.SerialDigitalIO.TimeStampSec=[];
% %    NEV2.Data.SerialDigitalIO.InsertionReason=[];
%     NEV2.Data.SerialDigitalIO.UnparsedData=[];

NEV = addNEV(NEV1, NEV2, 'report', 'offset', uint(10));
saveNEV(NEV, savename, 'report');