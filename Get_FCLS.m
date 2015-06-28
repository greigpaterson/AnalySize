function [Abunds, EM_Fit] = Get_FCLS(X, E)
%
% Function to get the least squares solution for A from AE = X under the
% constraints that A >= 0 and sum(A) = 1
%
% Based on the algorithm from [1].
%
% Input:
%         X - nData x nVar matrix of observations
%         E - nEnd x nVar matrix of end members
%
% Note: rows of both X and E must sum to ones
%
% Output:
%        Abdunds - nData x nEnd matrix of end member abundances
%        EM_Fit - nData x nVar matrix of the fitted end members (EM_Fit = A*E)
%
% References:
%
% [1] Heinz, D.C., and C.-I Chang (2001), Fully constrained least squares 
%     linear spectral mixture analysis method for material quantification 
%     in hyperspectral imagery, IEEE Tran. GRS, vol. 39, 529-545.
%

%% Begin...

% Get the dimensions
[nData, nVar] = size(X);
nEnd = size(E, 1);

if size(E, 2) ~= nVar
    error('Get_FCNLS:Input', 'Both X and E must contain the same number of variables.')
end

%% Get the trivial case of 1 end member

if nEnd == 1
    Abunds = ones(nData, 1);
    EM_Fit = Abunds*E;
    return;
end


%% Loop through the data

% Preallocate and assign defaults
Abunds = zeros(nData, nEnd);

for ii = 1:nData
    %% Set up the inital parameters and get the inital estimate
    r = X(ii,:)'; % our column vector of observations
    M = E'; % Our end members
    
    Orig_Inds = 1:nEnd; % The original indices, which are progressivley trimmed
    
    % Get the least squares solution
    a_ls = M\r;
    
    % Get estimates for s and lambda, then the fully constrained
    % abundances (a_fcls)
    s = (M'*M)\ones(size(M,2), 1);
    lambda_hat = (ones(1,size(M,2))*a_ls - 1)./(ones(1, size(M,2))*s);
    a_fcls = a_ls - lambda_hat*s;
    
    Sum_Neg = sum(a_fcls < 0); % Negative elements
    
    A = a_fcls; % Assign to the abudance vector
        
    %% enter the while loop if we have negative components
    while Sum_Neg > 0
        
        % Find the negative indices
        inds = find(a_fcls < 0);
        
        % Divide the negative abundaces by the correspond s values
        a_fcls(inds) = a_fcls(inds)./s(inds);
        
        % Find the index of the maximum value
        [~, MaxInd] = max(abs(a_fcls(inds)));
        
        % Remove MaxInd from the endmembers
        M(:, inds(MaxInd)) = [];
        Orig_Inds(inds(MaxInd)) =[];
        
        % Recalculate the fits
        a_ls = M\r;
        s = (M'*M)\ones(size(M,2), 1);
        lambda_hat = (ones(1,size(M,2))*a_ls - 1)./(ones(1, size(M,2))*s);
        a_fcls = a_ls - lambda_hat*s;
        
        Sum_Neg = sum(a_fcls < 0);
        
        if Sum_Neg == 0
            % We are done - Reset A to zero and add the postive values
            A = zeros(nEnd, 1);
            A(Orig_Inds) = a_fcls;
            break
        end
        
        
    end
    
    Abunds(ii,:) = A;
    
end

EM_Fit = Abunds*E;

