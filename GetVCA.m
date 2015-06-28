function [A] = GetVCA(X, k)
%
% Estimate endmember signatures using the vertex component analysis of [1].
% This version of the algorthm does not include the noise threshold
% criteria of the original algorithm, which is based on hyperspectral
% signature noise. Here the data are projected onto all k dimensions.
%
% Input:
%       X - nData x nVar matrix of data observations
%       k - The number of end members to be estimated
%
% Outputs:
%         A - k x nVar matrix of basis vectors
%
% References:
%
% [1] Nascimento & Bioucas-Dias (2005), Vertex component analysis: a fast 
%     algorithm to unmix hyperspectral data, Geoscience and Remote Sensing, 
%     IEEE Trans. on, 43, 898-910, doi: 10.1109/TGRS.2005.844293
%

%% Do some basic check and input processing

if nargin < 2
    error('GetVCA:Input', 'At least 2 inputs are required.');
end

if isempty(X)
    error('GetVCA:Data', 'No data provided.');
end

[nData, nVar] = size(X);

if k > nVar || k < 1 || rem(k,1) %check integer
    error('GetVCA:EM', 'Number of endmembers must be an integer between 1 and %d.', nVar);
end

% Transponse X to be nVar x nData (to fit the convention of the algorithm)
X = X';

%% Get the projected data

% Sometimes svds spits out a k-1 matrix instead of k
% This seems to be a MATLAB bug, but repeating the svds seems to fix it
Try = 0;
while Try <= 1e2
    try
        % project using all k components and original data
        [Ud, ~, ~] = svds(X*X'/nData, k);  % projection matrix
        Xp =  Ud' * X;
        
        M = Ud * Xp; % The mixing matrix [nVar x nData]
        
        Y= Xp ./ repmat( sum(Xp.*repmat(mean(Xp,2), 1, nData)), k, 1);
        break
    catch
%         disp('Caught an SVDS errror')
        Try = Try + 1;
    end
end

%% The Main loop

% The auxiliary matrix
Am = zeros(k, k);
Am(k, 1) = 1;

Inds = NaN(k,1);

W = rand(k,k);
% W = mvnrnd(ones(k,1), eye(k), k)';

for ii = 1:k
    
    w = W(:,ii);
    
    f = w - Am*pinv(Am)*w;
    f = f./norm(f);
    v = f'*Y;
    
    [~, Inds(ii)] = max( abs(v) );
    
    Am(:,ii) = Y(:,Inds(ii));
        
end


% The endmember signature
% nEnd x nVar
A = M(:,Inds)';
