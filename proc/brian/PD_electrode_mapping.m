% PD electrode mapping

% data should contain a struct array with at least fields b, id, and monkey
load all_cells_webber.mat

n = length(data);
pds = zeros(1,n);

th = 1:.25:360;
th = th*2*pi/360;
vel_test = [50.*cos(th') 50.*sin(th')];
speed = sqrt(vel_test(:,1).^2 + vel_test(:,2).^2);
test_params = [zeros(length(vel_test),2) vel_test speed];

for i = 1:n
    % get pd
    fr = glmval(data(i).b, test_params, 'log');    
    pd = th(find(fr==max(fr),1));
    pds(i) = pd;
end

pd_diffs = acos(cos(repmat(pds,n,1) - repmat(pds',1,n)));

same_electrode = [];
%diff_electrode = [];
same_monkey = [];
diff_monkey = [];

% Can't define subfunctions in a script
are_same_electrode = @(a,b) a.id(1) == b.id(1) && strcmp(a.monkey, b.monkey);
are_same_monkey = @(a,b) strcmp(a.monkey, b.monkey);

% Sort PD diffs by whether they are on the same electrode
for i = 1:n
    for j = i+1:n
        if are_same_electrode(data(i), data(j))
            same_electrode = [same_electrode pd_diffs(i,j)];
        elseif are_same_monkey(data(i), data(j))
            same_monkey = [same_monkey pd_diffs(i,j)];
        else
            diff_monkey = [diff_monkey pd_diffs(i,j)];
        end
        %else
        %    diff_electrode = [diff_electrode pd_diffs(i,j)];
        %end
    end
end

% Convert to degrees :(
same_electrode = same_electrode*180/pi;
%diff_electrode = diff_electrode*180/pi;
same_monkey = same_monkey*180/pi;
diff_monkey = diff_monkey*180/pi;

% Plot histograms
%figure; hist(diff_electrode, 5:10:175);
%figure; hist(same_electrode, 5:10:175);

figure; 
subplot(3,1,1), hist(same_electrode, 5:10:175);
subplot(3,1,2), hist(diff_monkey, 5:10:175);
subplot(3,1,3), hist(same_monkey, 5:10:175);

figure; hist(same_monkey, 5:10:175); title('Same Monkey / Different Electrode');

% Plot K-S looking thing
figure; hold on;
%plot( (1:length(diff_electrode))/length(diff_electrode), sort(diff_electrode), 'k-')
plot( (1:length(same_electrode))/length(same_electrode), sort(same_electrode), 'k-')
plot( (1:length(diff_monkey))/length(diff_monkey), sort(diff_monkey), 'r-')
plot( (1:length(same_monkey))/length(same_monkey), sort(same_monkey), 'b-')
