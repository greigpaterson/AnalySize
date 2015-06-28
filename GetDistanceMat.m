function Z = GetDistanceMat(X)
% 
% Function that returns the distance matrix of X
%

[n, p] = size(X);

Y = zeros(1,n*(n-1)./2);

k = 1;
for ii = 1:n-1
    dsq = zeros(n-ii,1);
    for jj = 1:p
        dsq = dsq + (X(ii,jj) - X((ii+1):n,jj)).^2;
    end
    Y(k:(k+n-ii-1)) = sqrt(dsq);
    
    k = k + (n-ii);
end

% Turn it into a matrix
m = ceil(sqrt(2*size(Y,2)));

Z = zeros(m);
if m>1
    Z(tril(true(m),-1)) = Y;
    Z = Z + Z';
end

