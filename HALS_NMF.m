function [EMs, Abunds, Xprime] = HALS_NMF(X, k, MaxIter, Reps, Regs, Verbose)
%
% Determines the nonnegative matrix factors of X using the Hierarchical
% Alternating Least-Squares (HALS) algorithm with flexible constriants
% given by [1].
%
%
% Input:
%       X - nData x nVar matrix of data observations
%       k - The number of componets in the factor matrices
%       MaxIter - the maximum number of iterations
%       Reps - The number of repetitions of the iterative routine
%       Regs - 4 x 1 matrix of constraint regularizers [a1, a2, b1, b2]
%
% Outputs:
%         EMs - k x nVar matrix of end member vectors
%         Adunds - nData x k matrix of abundances
%         Xprime - nData x nVar matrix of reconstructed data
%                  (Normalized to sum-to-one)
%
%
% Refereneces:
%
% [1] Chen & Guillaume (2012), HALS-based NMF with flexible constraints for
%     hyperspectral image unmixing, EURASIP Journal of Advances in Signal
%     Processing, 54, doi: 10.1186/1687-6180-2012-54
%

%% Inputs checks, defaults and warnings

if nargin < 2
    error('HALS_NMF:Input', 'At least 2 inputs are required.');
end

if isempty(X)
    error('HALS_NMF:Data', 'No data provided.');
end

[nData, nVar] = size(X);

if k > nVar ||  rem(k,1) %check integer
    error('HALS_NMF:EM', 'Number of endmembers must be an integer between 1 and %d.', nVar);
end

if nargin < 3
    MaxIter = 1e3;
end

if nargin < 4
    Reps = 10;
end

if nargin < 5
    Regs = [5, 0];
end

if nargin < 6
    Verbose = 0;
end

% Tolerances for stopping (N.B. these are relative tolerances)
eps = 1e-6;
sqrteps = sqrt(eps);
TolX = eps;
TolFun = eps;


% Suppress singular matrix warnings
% This affects very low noise data sets that are over-fitted
% Gernerally, this is synthetic data sets
warning('off', 'MATLAB:singularMatrix');


%% The main function

% The regularization parameters
a1 = Regs(1); % Sum-to-one constraint on abundances
b2 = Regs(2); % Minimum distance constraint

% preallocate for speed
final_resid = NaN(Reps, 1);
All_A = cell(Reps, 1);
All_S = cell(Reps, 1);

for Rep_ind = 1:Reps
    
    % Initialize the matrices
    % X is the data (nData nVar)
    % A is teh EM adundances (nData x nEnd)
    % S is the endmembers (nEnd x nVar)
        
    % SISAL initialization
    S0 = SISAL(X, k);
    S0(S0<0) = 0; % Remove negative values
    S0 = S0./repmat(sum(S0,2), 1,nVar);% Sum-to-one
    A0 = Get_FCLS(X, S0); % use FCLS to get the initial abundances
        
    % Assign the inital values to new matrices that are updated over the
    % iterations
    A = A0;
    S = S0;
    
    % Store the residuals for each iteration
    tmp_resid = NaN(MaxIter, 1);
    
    for Iter_ind = 1:MaxIter
        
        for k_ind = 1:k
            
            % Get the Sk, Ak, and Xk vectors
            Sk = S(k_ind, :);
            Ak = A(:, k_ind);
            Xk = X - A*S + Ak*Sk;
            
                         
           % Update Sk, the end members
            S_sum = sum(S,1) - Sk;
            
            Sk = (Ak'*Xk + ( (b2/k)*(1-1/k)*(eye(nVar) - ones(nVar)./nVar)*S_sum' )' )...
                / (norm(Ak).^2*eye(nVar) + b2.*(eye(nVar) - ones(nVar)./nVar) .* (1-1/k)^2) ;
            
            % Update Sk with the maximum function and add to S
            Sk(Sk > 1) = 1;
            Sk = max(0, Sk);
            Sk = Sk./sum(Sk); % Renormalize to sum to one
            S(k_ind,:) = Sk;
            
            
            % Update Ak, the abundaces
            A_sum = sum(A,2) - Ak;

            Ak = (Xk*Sk' + a1.*(ones(nData,1) - A_sum) ) ./ (norm(Sk).^2 + a1);
            
            % Update Sk with the maximum function and add to S
            Ak(Ak > 1) = 1;
            Ak = max(0, Ak);
            A(:,k_ind) = Ak;
                        
        end
        
        % tolerance check
        % if changes are too small break out
        tmp_resid(Iter_ind) =  norm( (A*S)-X,'fro');
        
        if Iter_ind > 1
            
            dA = max(max(abs(A-S0) / (sqrteps+max(max(abs(S0))))));
            dS = max(max(abs(S-A0) / (sqrteps+max(max(abs(A0))))));
            delta = max(dA, dS);
            
            if delta <= TolX %
                final_resid(Rep_ind) = tmp_resid(Iter_ind);
                All_S(Rep_ind) = {S};
                All_A(Rep_ind) = {A};
                break;
            elseif tmp_resid(Iter_ind)-tmp_resid(Iter_ind-1) <= TolFun*max(1,tmp_resid(Iter_ind))
                final_resid(Rep_ind) = tmp_resid(Iter_ind);
                All_S(Rep_ind) = {S};
                All_A(Rep_ind) = {A};
                break;
            elseif Iter_ind == MaxIter
                final_resid(Rep_ind) = tmp_resid(Iter_ind);
                All_S(Rep_ind) = {S};
                All_A(Rep_ind) = {A};
                break;
            end
            
        end
        
        % Update the old values
        S0 = A;
        A0 = S;
        
    end
    
end


% Pick the solution with the smallest residual
Min_ind = find(final_resid == min(final_resid));
A = All_A{Min_ind};
S = All_S{Min_ind};


% Assign to the output variables and redo sum to one to remove rounding errors
EMs = S;
EMs = EMs./repmat(sum(EMs,2), 1,nVar);

% Apply FCLS to ensure all constraints are met
Abunds = Get_FCLS(X, EMs);


% Get the estimated data and redo sum to one to remove rounding errors
Xprime = Abunds*EMs;
Xprime = Xprime./repmat(sum(Xprime,2), 1,nVar);


% Turn the warnings back on
warning('on', 'MATLAB:singularMatrix');

%% OUTPUT CHECK FOR TESTING

if Verbose == 1
    Max_EM_Sum = max(abs(1-sum(S,2)));
    Max_Abund_Sum = max(abs(1-sum(A,2)));
    
    Xprime_Orig = A*S;
    
    N1 = norm(X-Xprime_Orig, 'fro');
    N2 = norm(X-Xprime, 'fro');
    
    % OUTPUT CHECK FOR TESTING
    disp(' ')
    disp('%%%%%%%%%%%% HALS NMF OUTPUT CHECK %%%%%%%%%%%%')
    disp(sprintf('%s\t%d', 'Number of end members to be fitted:', k) ) %#ok<*DSPS>
    disp(sprintf('%s\t%5.5f', 'Maximum abundance difference (%)  :', 100*Max_Abund_Sum) )
    disp(sprintf('%s\t%5.5f', 'Maximum endmember difference (%)  :', 100*Max_EM_Sum) )
    disp(sprintf('%s\t%5.5f', 'Norm before endmember adjustment  :', N1) )
    disp(sprintf('%s\t%5.5f', 'Norm after endmember adjustment   :', N2) )
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
    disp(' ')
    
end


