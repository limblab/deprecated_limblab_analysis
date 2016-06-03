function Word = getWordStr(Word,task)

w=Words;
Start = hex2dec('10'):hex2dec('1F');
Reach = hex2dec('70'):hex2dec('7F');
OT_On = hex2dec('40'):hex2dec('4F'); % Also outer target On
    
    switch Word
        case Start(Start==Word)
            Word = 'Start';
        case w.Reward
            Word = 'Reward';
        case w.Abort
            Word = 'Abort';
        case w.Failure
            Word = 'Failure';
        case w.Incomplete
            Word = 'Incomplete';
        case w.Empty_Tray
            Word = 'Empty Tray';
        case Reach(Reach==Word)
            Word = sprintf('Tgt %d On',w.GetTgt(Word)+1);
        case OT_On(OT_On==Word)
            Word = sprintf('OT %d On',w.GetGdt(Word)+1);
        case w.Touch_Pad
            Word = 'TP/CT_On';
        case w.Go_Cue
            Word = 'Go Cue';
        case w.Mvmt_Onset
            Word = 'Mvt Onset';
        case w.Catch
            Word = 'Catch';
        case w.Pickup
            Word = 'Pick up';
        case w.CT_Hold
            Word = 'CT_Hold';
        case w.OT_Hold
            Word = 'OT_Hold';
        case w.Adapt
            Word = 'Adapt';
        otherwise
            Word = 'Unknown Word';
    end
             
end