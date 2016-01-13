function [M] = SISAL(X, k)
%
% Estimate endmember signatures using the simplex identification via split 
% augmented Lagrangian (SISAL) of [1].
% This version of the algorthm does not include data sphering.
%
%
% Input:
%       X - nData x nVar matrix of observations
%       k - an integer number of end members to fit. This is the number of
%       vertices of the (k-1) dimensional simplex.
%
% Output:
%       M - k x nVar matrix of end member signatures
%
%
% Note:
% The is a modification of the SISAL funtion written by Jos? Bioucas-Dias. 
% The original code was downloaded from (http://www.lx.it.pt/~bioucas/code.htm).
% This script has a separate licence agreement.
% All modifications were made by Greig A. Paterson.
%
%
% References:
%
% [1] Bioucas-Dias, J.M., 2009. A variable splitting augmented Lagrangian 
%     approach to linear spectral unmixing. In: First IEE GRSS workshop on 
%     Hyperspectral Image and Signal Processing: WHISPERS 2009, 1-4, 
%     doi: 10.1109/WHISPERS.2009.5289072.
%

%% Do some basic check and input processing

if nargin < 2
    error('SISAL:Input', 'At least 2 inputs are required.');
end

if isempty(X)
    error('SISAL:Data', 'No data provided.');
end

[nData, nVar] = size(X);

if k > nVar || k < 1 || rem(k,1) %check integer
    error('SISAL:EM', 'Number of endmembers must be an integer between 1 and %d.', nVar);
end

% Transponse X to be nVar x nData (to fit the convention of the algorithm)
X0 = X;
X = X0';

%% Set up some defaults
% maximum number of quadratic QPs
MaxIter = 1e2;

% soft constraint regularization parameter
% Lager values of tau result in simplex expansion
tau = 1;

% Augmented Lagrangian regularization parameter
mu = k*1000/nData;

% quadractic regularization parameter for the Hesssian
lam_quad = 1e-6;

% minimum number of AL iterations per quadratic problem
AL_iters = 4;


%% Identify the affine space that best represents the data set X

% Detrend X and perform SVD
Xbar = mean(X,2);
X = X - repmat(Xbar, 1, nData);

% Sometimes svds spits out a matrix instead of one dimension small
% This seems to be a MATLAB bug, but repeating the svds seems to fix it
Try = 0;
while Try <= 1e2
    try
        [Up, S, V] = svds(X*X'/nData, k-1);
        break
    catch
        Try = Try + 1;
    end
end

% represent X in the subspace R^(k-1)
X = Up*Up'*X;

% Shift X up
X = X + repmat(Xbar,1,nData);

% compute the orthogonal component of Xbar
Xbar_ortho = Xbar-Up*Up'*Xbar;

% define another orthonormal direction
Up = [Up Xbar_ortho/sqrt(sum(Xbar_ortho.^2))];

% get coordinates in R^k
X = Up'*X;


%% Initialization
 
% VCA initial simplex
M = GetVCA(X', k)';
Xm = mean(M,2);
Xm = repmat(Xm,1,k);
dQ = M - Xm;

% Multiply by k is to make sure Q0 starts with a feasible initial value.
M = M + k*dQ;

Q0 = inv(M);
Q=Q0;


%% Build constant matrices

% Eqn 6
AAT = kron(X*X',eye(k));    % size k^2 x k^2
B = kron(eye(k),ones(1,k)); % size k^2 x k^2
qm = sum((X*X')\X, 2);

H = lam_quad * eye(k^2);
F = H+mu*AAT;          % equation (11) of [1]

% auxiliar constant matrices
G = (F\(B')) / (B/F*B');
qm_aux = G*qm;
G = inv(F) - G*B/F;


%% Main loop
% The sequence of quadratic-hinge subproblems

% initializations
Z = Q*X;
Bk = 0*Z;


for ii = 1:MaxIter
    
    g = -inv(Q)';
    g = g(:);
    
    baux = H*Q(:)-g;
    
    q0 = Q(:);
    Q0 = Q;
    
    if ii==MaxIter
        AL_iters = 100;
    end
    
    while 1 > 0
        q = Q(:);
        % initial function values (true and quadratic)
        f0_val = -log(abs(det(Q)))+ tau*sum(sum(hinge(Q*X)));
        f0_quad = (q-q0)'*g+1/2*(q-q0)'*H*(q-q0) + tau*sum(sum(hinge(Q*X)));

        
        for i=2:AL_iters
            %-------------------------------------------
            % solve quadratic problem with constraints
            %-------------------------------------------
            dq_aux = Z+Bk;             % matrix form
            dtz_b = dq_aux*X';
            dtz_b = dtz_b(:);
            b = baux+mu*dtz_b;        % (11) of [1]
            q = G*b+qm_aux;           % (10) of [1]
            Q = reshape(q,k,k);
            
            %-------------------------------------------
            % solve hinge
            %-------------------------------------------
            Z = soft_neg(Q*X -Bk,tau/mu);
                        
            %-------------------------------------------
            % update Bk
            %-------------------------------------------
            Bk = Bk - (Q*X-Z);
            
        end
        f_quad = (q-q0)'*g+1/2*(q-q0)'*H*(q-q0) + tau*sum(sum(hinge(Q*X)));
        
        f_val = -log(abs(det(Q)))+ tau*sum(sum(hinge(Q*X)));
        if f0_quad >= f_quad    %quadratic energy decreased

            while  f0_val < f_val
                
                % do line search
                Q = (Q+Q0)/2;
                f_val = -log(abs(det(Q)))+ tau*sum(sum(hinge(Q*X)));
            end
            
            break
        end
    end
    
end


M = Up/Q;

% Transpose to get k x nVar matrix
M = M';


%% Required sub-functions

function z = soft_neg(y,tau)
%
%  negative soft (proximal operator of the hinge function)
%

z = max(abs(y+tau/2) - tau/2, 0);
z = z./(z+tau/2) .* (y+tau/2);


function z = hinge(y)
%
%   hinge function
%

z = max(-y,0);
