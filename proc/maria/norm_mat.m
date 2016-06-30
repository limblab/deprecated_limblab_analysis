function ret = norm_mat(a_matrix)
%gets a matrix and normalizes each column
for i=1:size(a_matrix, 2)
    mmax = max(a_matrix(:, i));
    mmin = min(a_matrix(:, i));
    for j=1:length(a_matrix(:, i))
        a_matrix(j, i) = (a_matrix(j, i)-mmin)/mmax;
    end
end

ret = a_matrix; 
end