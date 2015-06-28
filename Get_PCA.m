function [pc, score, latent] = Get_PCA(x)
% Principal Component Analysis with no centering of the data.
%   [pc, score, latent] = Get_PCA(X) takes a data matrix X and
%   returns the principal components in PC, the so-called Z-scores in SCORES,
%   the eigenvalues of the covariance matrix of X in LATENT
% Based on the MATLAB pca function


[m,n] = size(x);
r = min(m-1,n);     % max possible rank of x


[~,latent,pc] = svd(x./sqrt(m-1),0);
score = x*pc;

if nargout < 3
    return;
end

latent = diag(latent).^2;
if (r<n)
   latent = [latent(1:r); zeros(n-r,1)];
   score(:,r+1:end) = 0;
end
