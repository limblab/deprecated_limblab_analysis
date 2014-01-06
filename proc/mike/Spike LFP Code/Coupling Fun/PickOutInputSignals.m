function [xOnline] = PickOutInputSignals(LFPInds,SpikeInds,ControlType,PB,x)

if ~isempty(SpikeInds)
    if length(SpikeInds) == 1
        if ControlType{2}(1) == 2
            xOnline(:,1) = x(:,SpikeInds{1}(1));
        elseif ControlType{2}(2) == 2
            xOnline(:,2) = x(:,SpikeInds{1}(1));
        end
    elseif length(SpikeInds) == 2
        if ControlType{2}(1) == 2 && ControlType{2}(2) == 2
            xOnline(:,1) = x(:,SpikeInds{1}(1));
            xOnline(:,2) = x(:,SpikeInds{2}(1));
        else
            disp('Mismatch in Spike Index length and Control Signal Type')
            return
        end
    end
elseif ~isempty(LFPInds)
    if length(LFPInds) == 1
        if ControlType{2}(1) == 1
            xOnline(:,1) = PB(LFPInds{1}(2),LFPInds{1}(1),:);
        elseif ControlType{2}(2) == 1
            xOnline(:,2) = PB(LFPInds{1}(2),LFPInds{1}(1),:);
        end
    elseif length(LFPInds) == 2
        if ControlType{2}(1) == 1 && ControlType{2}(2) == 1
            xOnline(:,1) = PB(LFPInds{1}(2),LFPInds{1}(1),:);
            xOnline(:,2) = PB(LFPInds{2}(2),LFPInds{2}(1),:);
        else
            disp('Mismatch in LFP Index length and Control Signal Type')
            return
        end
    end
end