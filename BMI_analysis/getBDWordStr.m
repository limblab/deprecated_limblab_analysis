function Word = getBDWordStr(Word)

w=BD_Words;
Start = hex2dec('10'):hex2dec('1F');
Reach = hex2dec('70'):hex2dec('7F');
Gadget_on = hex2dec('40'):hex2dec('4F');

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
        case Gadget_on(Gadget_on==Word)
            Word = sprintf('Gdt %d On',w.GetGdt(Word)+1);
        case w.Touch_Pad
            Word = 'Touch Pad';
        case w.Go_Cue
            Word = 'Go Cue';
        case w.Mvmt_Onset
            Word = 'Mvt Onset';
        case w.Catch
            Word = 'Catch';
        case w.Pickup
            Word = 'Pick up';
        otherwise
            Word = 'Unknown Word';
    end
             
end