function [pc, score, latent] = Get_PCA(x)
%
% Principal Component Analysis with no centering of the data.
% Based on the MATLAB pca function
%
% Inputs: 
%       x - the data matrix
%
% Outputs:
%       pc - the principal components
%       score - principal component score (x projected into the PC space)
%       latent - the eigenvalues of the covariance matrix of X
%

[m,n] = size(x);
r = min(m-1,n);     % max possible rank of x


[u,latent,pc] = svd(x./sqrt(m-1),0);
score = x*pc;

if nargout < 3
    return;
end

latent = diag(latent).^2;
if (r<n)
   latent = [latent(1:r); zeros(n-r,1)];
   score(:,r+1:end) = 0;
end
