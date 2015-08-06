function ConvErr = GetConvexityError(X, EMs)
%
% Calculate the convexity error given in [1]
%
% Input:
%       X - nData x nVar matrix of observations
%       EMs - nEnd x nVar matirx of end member signatures
%
% Output:
%       ConvErr - the convexity error
%
%
% References:
%
%   [1] Weltje, G.J., 1997. End-member modeling of compositional data: 
%       Numerical-statistical algorithms for solving the explicit mixing 
%       problem. Math. Geol., 29, 503-549, doi: 10.1007/BF02775085.
%

%% Begin...

% Get and check dimentions
[nData, nVar] = size(X);

if size(EMs, 2) ~= nVar
    error('ConvexityError:Input', 'Both X and EMs must contain the same number of variables.')
end


% Get the abundances using only sum-to-one constated LSq
A = Get_SCLS(X, EMs);

% Isolate negative values by setting positive values to zero
Aneg = A;
Aneg(Aneg > 0) = 0;

% Get the proportion of data outside the simplex
Prop = sum( max(Aneg < 0, [],2)==1 )./nData;

% Get the mean squared distance of negative values
Aneg(sum(Aneg >= 0, 2)==0, :) = []; % remove the postive only rows so that they don't bias the mean
Dist = mean(sum(Aneg.^2, 2));

ConvErr = log10(Prop) + log10(Dist);
