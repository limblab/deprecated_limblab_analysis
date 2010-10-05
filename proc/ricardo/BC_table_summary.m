function [table_summary] = BC_table_summary(table,bump_directions)

bump_magnitudes = unique(table(:,7));

table_summary = zeros(2*length(bump_magnitudes),2);
table_summary_new = zeros(2*length(bump_magnitudes),2);
bumps_ordered = 2*[-bump_magnitudes(end:-1:1);bump_magnitudes];

for j = 1:length(bump_magnitudes)
    local_succ = length(table(table(:,6) == bump_directions(1) &...
        table(:,3)==32 &...
        table(:,7)==bump_magnitudes(j),1));
    local_unsucc = length(table(table(:,6) == bump_directions(1) &...
        table(:,3)==34 &...
        table(:,7)==bump_magnitudes(j),1));
    table_summary(end-j-(length(bump_magnitudes)-1),:) = [local_succ local_unsucc];

    local_succ = length(table(table(:,6) == bump_directions(2) &...
        table(:,3)==32 &...
        table(:,7)==bump_magnitudes(j),1));
    local_unsucc = length(table(table(:,6) == bump_directions(2) &...
        table(:,3)==34 &...
        table(:,7)==bump_magnitudes(j),1));
    table_summary(j+length(bump_magnitudes),:) = [local_unsucc local_succ];
end

table_summary_new(bumps_ordered~=0,:) = table_summary(bumps_ordered~=0,:);
table_summary_new(find(bumps_ordered==0,1,'first'),:) = sum(table_summary(bumps_ordered==0,:));
table_summary = table_summary_new(~(table_summary_new(:,1)==0 & table_summary_new(:,2)==0),:);

