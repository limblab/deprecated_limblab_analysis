% $Id$
% Evaluates what cells in BDF have tactile responses

%%%
%%% Method One:
%%% Take the short time xcorr between the tapping and spikes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% touches = debounce(bdf.raw.events.timestamps{7},.1);
% touches = train2bins(touches, 0:0.001:1700);
% 
% for i = 1:length(bdf.units)
%     disp(sprintf('i = %d of %d', i, length(bdf.units)));
%     
%     b = train2bins(bdf.units(i).ts, 0:0.001:1700);
%     [r, c] = stxcorr(touches, b, 10000, 5000, 300);
%     c = c./1000;
%     
%     figure;
%     plot(c,r);
%     title(sprintf('Unit %d-%d', bdf.units(i).id(1), bdf.units(i).id(2)));    
% end


%%%
%%% Method two:
%%% take 10 sequential taps and compare the firing rates for 50ms before
%%% tap to 50ms after
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% window_size = .05;
% num_taps = 10;
% 
% touches = debounce(bdf.raw.events.timestamps{7},.1);
% ratio = zeros(length(touches)-num_taps,1);
% 
% for cell = 1:length(bdf.units)
%     disp(sprintf('i = %d of %d', cell, length(bdf.units)));
%     
%     for i = 1:length(touches)-num_taps
%         before = 0;
%         after = 0;
%         for j = 0:num_taps-1
%             before = before + sum(bdf.units(cell).ts > touches(i+j)-window_size & bdf.units(cell).ts < touches(i+j));
%             after = after + sum(bdf.units(cell).ts < touches(i+j)+window_size & bdf.units(cell).ts > touches(i+j));
%         end
%         ratio(i) = after/before;    
%     end
% 
%     figure;
%     plot(ratio);
%     title(sprintf('Unit %d-%d', bdf.units(cell).id(1), bdf.units(cell).id(2)));
% end

%%%
%%% Method three:
%%% Just display all the rasters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for cell = 1:length(bdf.units)
    figure;
    raster(bdf.units(cell).ts, touches, -.05, .05);
    title(sprintf('Unit %d-%d', bdf.units(cell).id(1), bdf.units(cell).id(2)));
    xlabel('time (0 is contact)')
    ylabel('taps')
end
    
    
    
    
    
    
