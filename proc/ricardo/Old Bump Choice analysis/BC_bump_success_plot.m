function BC_bump_success_plot(bump_table,filename)

bump_magnitudes = unique(bump_table(:,7));
successful = bump_table(bump_table(:,3)==32,:);
unsuccessful = bump_table(bump_table(:,3)==34,:);

success_rate = histc(successful(:,7),bump_magnitudes)./...
    (histc(successful(:,7),bump_magnitudes)+histc(unsuccessful(:,7),bump_magnitudes));
figure;
bar(bump_magnitudes,success_rate)
title([filename 'Bump success rate'])
xlabel('Bump magnitude')
ylabel('Success rate')