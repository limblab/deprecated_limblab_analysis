Newsome_mode = 1;
coherence = 80; % percent of coherent dots
iDir = iDir+1;
direction = iDir*pi/8;
speed = 1.5; % display units/s
num_dots = 10;
dot_size = 30;

frame_rate = 20;
duration = 5; % seconds

red_dot = 1;

num_frames = frame_rate*duration;
dotx = zeros(num_dots,num_frames);
doty = zeros(num_dots,num_frames);

num_coherent_dots = round(num_dots*coherence/100);

dotx(:,1) = rand(num_dots,1);
doty(:,1) = rand(num_dots,1);

for iFrame=2:num_frames;
    if Newsome_mode
        dotx(1:num_coherent_dots,iFrame) = dotx(1:num_coherent_dots,iFrame-1)+speed*cos(direction)/frame_rate;    
        doty(1:num_coherent_dots,iFrame) = doty(1:num_coherent_dots,iFrame-1)+speed*sin(direction)/frame_rate;
        if ((num_coherent_dots+1) < num_dots)
            dotx(num_coherent_dots+1:end,iFrame) = rand(length(dotx(num_coherent_dots+1:end,iFrame)),1);
            doty(num_coherent_dots+1:end,iFrame) = rand(length(doty(num_coherent_dots+1:end,iFrame)),1);
        end
    else
        rand_dir = 2*pi*rand(num_dots,1);
%         displacement_x = 0.01*coherence*cos(direction) + (1-0.01*coherence)*cos(rand_dir);
%         displacement_y = 0.01*coherence*sin(direction) + (1-0.01*coherence)*sin(rand_dir);
%         displacement_x = (speed/frame_rate)*displacement_x./(sqrt(displacement_x.^2+displacement_y.^2));
%         displacement_y = (speed/frame_rate)*displacement_y./(sqrt(displacement_x.^2+displacement_y.^2));
        
        displacement_x = sqrt(0.01*coherence)*cos(direction) + sqrt(1-0.01*coherence)*cos(rand_dir);
        displacement_y = sqrt(0.01*coherence)*sin(direction) + sqrt(1-0.01*coherence)*sin(rand_dir);
        displacement_x = (speed/frame_rate)*displacement_x./(sqrt(displacement_x.^2+displacement_y.^2));
        displacement_y = (speed/frame_rate)*displacement_y./(sqrt(displacement_x.^2+displacement_y.^2));
        
        dotx(:,iFrame) = dotx(:,iFrame-1)+displacement_x;
        doty(:,iFrame) = doty(:,iFrame-1)+displacement_y;
        
%         dotx(:,iFrame) = dotx(:,iFrame-1)+speed*cos(direction)/frame_rate+...
%             (1-0.01*coherence)*speed*cos(rand_dir)/frame_rate;
%         doty(:,iFrame) = doty(:,iFrame-1)+speed*sin(direction)/frame_rate+...
%             (1-0.01*coherence)*speed*sin(rand_dir)/frame_rate;
    end
    for iDot = 1:num_dots
        if dotx(iDot,iFrame)<=0
            dotx(iDot,iFrame) = 1-dotx(iDot,iFrame);
            doty(iDot,iFrame) = rand;
        elseif dotx(iDot,iFrame)>=1
            dotx(iDot,iFrame) = dotx(iDot,iFrame)-1;
            doty(iDot,iFrame) = rand;
        end
        if doty(iDot,iFrame)<=0
            doty(iDot,iFrame) = 1-doty(iDot,iFrame);
            dotx(iDot,iFrame) = rand;
        elseif doty(iDot,iFrame)>=1
            doty(iDot,iFrame) = doty(iDot,iFrame)-1;
            dotx(iDot,iFrame) = rand;
        end
    end
%     dotx(dotx(:,iFrame)>1,iFrame) = rand(sum(dotx(:,iFrame)>1),1);
%     dotx(dotx(:,iFrame)<0,iFrame) = rand(sum(dotx(:,iFrame)<0),1);
%     doty(doty(:,iFrame)>1,iFrame) = rand(sum(doty(:,iFrame)>1),1);
%     doty(doty(:,iFrame)<0,iFrame) = rand(sum(doty(:,iFrame)<0),1);
end

figure(1);
total_time_start = clock;
for iFrame=1:num_frames
    tic
    hold off
    plot(dotx(:,iFrame),doty(:,iFrame),'.','Color',[1 1 1],'MarkerSize',dot_size)
    if red_dot
        hold on
        plot(dotx(1,iFrame),doty(1,iFrame),'.','Color','r','MarkerSize',dot_size)
    end
    xlim([0 1])
    ylim([0 1])
    axis square
    set(gca,'Color','k')
    drawnow
    elapsed_time = toc;
    pause(1/frame_rate-elapsed_time)
end
total_time = clock-total_time_start;
total_time = total_time(4)*24+total_time(5)*60+total_time(6);
disp(' ')
disp(['frame rate: ' num2str(num_frames/total_time) ' frames/s'])
disp(['direction param: ' num2str(180*direction/pi) ' deg'])
disp(['mean direction: ' num2str(mod(360+180*atan2(mean(displacement_y),mean(displacement_x))/pi,360)) ' deg'])
disp(['speed param: ' num2str(speed)])
disp(['mean speed: ' num2str(frame_rate*sqrt(mean(displacement_y).^2+mean(displacement_x).^2))])