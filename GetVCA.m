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
        [Ud, ~, ~] = svds(X*X'/nData, k);  % projection matrix ([1] algorithm line 4)
        Xp =  Ud' * X;
        
        M = Ud * Xp; % The mixing matrix [nVar x nData]
        
        Y = Xp ./ repmat( sum(Xp.*repmat(mean(Xp,2), 1, nData)), k, 1); % ([1] algorithm line 6)
        break
    catch
        Try = Try + 1;
    end
end

%% The Main loop

% Initialize the auxiliary matrix ([1] algorithm line 14)
Am = zeros(k, k);
Am(k, 1) = 1;

% Random matirx ([1] algorithm line 16)
W = rand(k,k);

% Matrix for storing the specimen indices
Inds = NaN(k,1);

for ii = 1:k
    
    % Isolate a random vector
    w = W(:,ii); 
    
    % [1] algorithm lines 17-18
    f = w - Am*pinv(Am)*w; % Note - eye(k)*w = w
    f = f./norm(f);
    v = f'*Y;
    
    % Find the index of the extreme value
    [~, Inds(ii)] = max( abs(v) );
    
    % Update the auxiliary matrix 
    Am(:,ii) = Y(:,Inds(ii));
        
end


% The endmember signature - transposed to be nEnd x nVar
A = M(:,Inds)';
