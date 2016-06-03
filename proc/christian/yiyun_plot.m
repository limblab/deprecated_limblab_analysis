%%
function filename = yiyun_plot 

% this function is to calculate and plot successful FES and catch rate,
% BDF files are required to be loaded. Results will be both displayed on
% screen and saved in the struct.

%open BDF files
[filename, pathname] = uigetfile('*.mat', 'load bdf files','MultiSelect','on');

%initiation
t_st=0;
matrix=zeros(length(filename),2);
i=1;
disp('------------------------------------------------------------------------------------------------------------------------------------------------');
disp('            trial                   |                         FES                         |                       Catch                         ');
disp('------------------------------------------------------------------------------------------------------------------------------------------------');
disp('                      | duration(m) |    reward    failure    abort    incomp    rate(%)  |  reward    failure    abort    incomp    rate(%)    ');
disp('------------------------------------------------------------------------------------------------------------------------------------------------');
clf;

%calculate and plot
while i <=length(filename)
    
    load([pathname filename{i}]);
    time1=out_struct.meta.datetime;
        
    rwd_catch=length(Get_Words_ts_pairs(25,50,32,out_struct.words));
    rwd_FES=length(Get_Words_ts_pairs(25,49,32,out_struct.words));
    
    fail_catch=length(Get_Words_ts_pairs(25,50,34,out_struct.words));
    fail_FES=length(Get_Words_ts_pairs(25,49,34,out_struct.words));
    
    abort_catch=length(Get_Words_ts_pairs(25,50,33,out_struct.words));
    abort_FES=length(Get_Words_ts_pairs(25,49,33,out_struct.words));
    
    incmp_FES=length(Get_Words_ts_pairs(25,49,35,out_struct.words));
    incmp_catch=length(Get_Words_ts_pairs(25,50,35,out_struct.words));
    
    total_FES=incmp_FES+rwd_FES;
    total_catch=incmp_catch+rwd_catch;
    
    %successful rate
    suc_FES=rwd_FES/total_FES*100;
    suc_catch=rwd_catch/total_catch*100;
    
    %duration(min)
    dur=out_struct.meta.duration/60;
    t_end=t_st+dur;
    
    x=t_st:0.01:t_end;
    M=ones(1,length(x));
    y=suc_FES*M;
    plot(x,y,'g','LineWidth',5);    
    hold on
    y=suc_catch*M;
    plot(x,y,'r','LineWidth',5);
    grid on
    xlabel('Time(min)');
    ylabel('%');
    
    if i+1 <=length(filename)
        load([pathname filename{i+1}])
        
        %time2 is the beginning of the next trial
        time2=out_struct.meta.datetime;
        temp=time2-time1;
    end
    
    %the duration between two trials, no result will be shown
    if temp(17)<0
        temp(17)=10+temp(17);
        temp(16)=temp(16)-1;
    end
    if temp(16)<0
        temp(16)=6+temp(16);
        temp(14)=temp(14)-1;
    end
    if temp(14)<0
        temp(14)=10+temp(14);
        temp(13)=temp(13)-1;
    end
    if temp(13)<0
        temp(13)=6+temp(13);
    end 
    if temp(13)>=0 && temp(14)>=0 && temp(16)>=0 && temp(17)>=0
        gap=temp(13)*10+temp(14)+(temp(16)*10+temp(17))/60-dur;
    end    

    %print out
    fprintf('%s',filename{i});
    fprintf('   %8s',num2str(dur));
    fprintf('        %3s',num2str(rwd_FES));
    fprintf('        %2s',num2str(fail_FES));
    fprintf('        %2s',num2str(abort_FES));
    fprintf('        %2s',num2str(incmp_FES));
    fprintf('      %7s',num2str(suc_FES));    
    fprintf('        %2s',num2str(rwd_catch));
    fprintf('        %2s',num2str(fail_catch));
    fprintf('        %2s',num2str(abort_catch));
    fprintf('        %2s',num2str(incmp_catch));
    fprintf('      %7s\n',num2str(suc_catch)); 
    disp('------------------------------------------------------------------------------------------------------------------------------------------------');
    
    %save the results
    filename{i} = struct('file', {filename{i}}, 'duration', {num2str(dur)}, 'reward_FES', {num2str(rwd_FES)}, 'fail_FES', {num2str(fail_FES)}, 'abort_FES', {num2str(abort_FES)},...
        'incomplete_FES', {num2str(incmp_FES)}, 'successful_FES_rate', {num2str(suc_FES)}, 'reward_catch', {num2str(rwd_catch)}, 'fail_catch',{num2str(fail_catch)},...
        'abort_catch', {num2str(abort_catch)}, 'incomplete_catch', {num2str(incmp_catch)}, 'successful_catch_rate', {num2str(suc_catch)}); 
    
    t_st=t_end+gap;
    i=i+1;    
end

%add average rate axis
axis([-5,t_end+5,-5,105]);
legend('successful FES rate','successful catch rate',2,'Location','SouthWestOutside');
axes('position',[.08,.25,.3,.65]);
barM=[sum(matrix(:,1))/(i-1) sum(matrix(:,2))/(i-1)]';
bar(barM);
text(0.6,sum(matrix(:,1))/(i-1)+3,num2str(sum(matrix(:,1)/(i-1))));
text(1.7,sum(matrix(:,2))/(i-1)+3,num2str(sum(matrix(:,2)/(i-1))));

title('average rate');
ylabel('%');
ylim([0 100]);

