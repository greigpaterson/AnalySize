function y = GetPercentile(X, GS, pvals)
%
% Function to return the grain size for a given percentile.
%
%

pvals = pvals./100;

[nData, nVar] = size(X);

XCS = cumsum(X, 2); % The data cumulative sum
XCS = XCS./repmat(sum(X,2), 1, nVar); % Ensure the maximum in 1

% If the data are censored or open ended at low grain sizes the first grain
% size bin is often >1% (needed for the CM plots)
% Grain size bins are typically evenly spaced in logspace so we use the
% average log spacing to determine the next lowest grain size bin, which
% has a density of zero.

if any(XCS(:,1) < min(pvals))
    XCS = [zeros(nData,1), XCS];
    dLGS = mean(diff(log(GS)));
    GS = [exp( log(GS(1)) - dLGS), GS];
end

nPvals = length(pvals);
y = NaN(nData, nPvals);

for ii = 1:nData
    for jj = 1:nPvals
        inds = [find(XCS(ii,:) < pvals(jj), 1, 'last'), find(XCS(ii,:) > pvals(jj), 1, 'first')];
        y(ii,jj) = interp1(XCS(ii,inds), GS(inds), pvals(jj));
    end
end

