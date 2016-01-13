function R2 = GetR2(X, Y)
%
% function to determine the squared Pearson linear correlation between two input
% vector, X and Y
%

corrXX = 0; % cross-correlation flag
if nargin == 1
    Y = X;
    corrXX = 1;
end

Xd=detrend(X, 0); % (x-xbar)
Yd=detrend(Y, 0); % (y-ybar)

if corrXX ~= 1
    R2 = sum((Xd.*Yd)).^2 ./ ( sum(Xd.^2).*sum(Yd.^2) );    
else
    [DummyVar,n] = size(X);
    
    R2 = NaN(n, n);
    
    for ii=1:n
        for jj = 1:n
            R2(ii,jj) = sum((Xd(:,ii).*Yd(:,jj))).^2 ./ ( sum(Xd(:,ii).^2).*sum(Yd(:,jj).^2) );
        end
        
    end
    
end
