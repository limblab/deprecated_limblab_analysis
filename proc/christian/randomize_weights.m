function filter = randomize_weights(filter)

[m,n] = size(filter.H);

H_new = zeros(m,n);

r = round(m*rand(m,n)+0.5);
c = round(n*rand(m,n)+0.5);

for i = 1:m
    for j=1:n
        H_new(i,j) = filter.H(r(i,j),c(i,j));
    end
end

filter.H = H_new;