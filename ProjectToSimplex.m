function [Abunds, EM_Fit, Validity] = ProjectToSimplex(X, E, D)
%
% Function to project data given by X to the simplex spanned by endmembers
% given by E. Based on the algorithm from [1] (p6).
% We also add in some validity checks given by [2-3], but only return a
% flag to indicate if they have passed or not.
%
% Input:
%         X - nData x nVar matrix of observations
%         E - nEnd x nVar matrix of end members
%         D - the distance matrix of E (do no use as input, only used for
%             the recursive calling to avoid extra overhead)
%
% Note: rows of both X and E must sum to ones
%
% Output:
%        Abdunds - nData x nEnd matrix of end member abundances
%        EM_Fit - nData x nVar matrix of the fitted end members (EM_Fit = A*E)
%        Validity - a flag to indicate whether the data are suitably
%        projected into the simplex (== 1) or not (== 0)
%
% References:
%
% [1] Heylen et al. (2011), Fully Constrained Least Squares Spectral
%     Unmixing by Simplex Projection, Geoscience and Remote Sensing, IEEE
%     Transactions on, 49, 4112-4122, doi: 10.1109/TGRS.2011.2155070
%
% [2] Heylen & Scheunders (2012), A Fast Geometric Algorithm for Solving
%     the Inversion Problem in Spectral Unmixing, Hyperspectral Image and 
%     Signal Processing: Evolution in Remote Sensing (WHISPERS), 2012 4th 
%     Workshop on, doi: 10.1109/WHISPERS.2012.6874221
%
% [3] Heylen et al. (2013), On Using Projection Onto Convex Sets for 
%     Solving the Hyperspectral Unmixing Problem, Geoscience and Remote 
%     Sensing Letters, IEEE, 10, 1522-1526, doi: 10.1109/LGRS.2013.2261276
%

%% Begin...

eps = 1e-10; % new eps for rounding errors
Validity = 0; % set a default

if nargin < 2
    error('ProjectToSimplex:Input', 'At least 2 inputs are required.');
end

if isempty(X)
    error('ProjectToSimplex:Data', 'No data provided.');
end

% Get the dimensions
[nData, nVar] = size(X);
nEnd = size(E, 1);

% Check the inputs are the right size
if size(E, 2) ~= nVar
    error('ProjectToSimplex:Input', 'Both X and E must contain the same number of variables.')
end


%% Get the trivial case of 1 end member

if nEnd == 1
    Abunds = ones(nData, 1);
    EM_Fit = Abunds*E;
    return;
end

%% Test the inital simplex
%
% Project the points onto the simplex spanned by E and determine what
% points in X fall outside of the simplex

% Project the point to the plane and get projection (y) and partial
% abundances (v)
[y, v] = ProjectToPlane(X, E);


% Check if the partial abundances fit the constriants
% Logial arrays C1 and C2 check for positivity and sum-to-one respectively
% These index columns that don't fit the constraints
C1 = sum(v<0,2)>0; % columns with negative numbers
C2 = sum(v,2)>1 + eps; % columns with abundaces greater than 1 (with small leeway)

Bad_Inds = find(C1|C2 ==1); % Indices where both constraints fail
nBad = length(Bad_Inds);

% Check to see if all points are in the simplex
% If so return
if isempty(Bad_Inds)
    Abunds = v;
    EM_Fit = y;
    Validity = CheckValidity(X, EM_Fit, E);
    return
end

% Set the partial abundances of points not in the simplex to zero
% This saves doing it at the end
v(Bad_Inds,:) = zeros;

%% Simplex space
%
% Determine the size and properties of the simplex space
%

% Get the squared distance matrix of E
if nargin < 3
    D = GetDistanceMat(E).^2;
end

% Calculate the volume of the sub-simplex Vi
Vol = NaN(1, nEnd);
for ii = 1:nEnd
    inds = [1:ii-1, ii+1:nEnd];
    C = [D(inds, inds), ones(nEnd-1, 1); ones(1, nEnd-1), 0]; % Eqn 23
    
    Vol(ii) = sqrt( ( (-1)^(nEnd) / (2^(nEnd-1) * factorial(nEnd-1)^2 ) )  * det(C) );
    % Note, this is not exactly eqn 22, but an alternative formulation from
    % MathWorld http://mathworld.wolfram.com/Cayley-MengerDeterminant.html
    
end

% ac contains the barycentric coordinates of the inceter, c
ac = Vol./sum(Vol); % Eqn 11
c = ac*E; % Eqn 12

% Adjust y and E to defined the cone Z that contains the data points as
% projected on to the simplex (eqns 24-25)
Xc = y - repmat(c, nData, 1);
Ec = E - repmat(c, nEnd, 1);

%% Adjust points outside of the simplex
%
% Reprojects the points that fall outside of the intial simplex to find
% appropriate abundances to push them into the simplex

% Get the points that fall outside of the simplex
Outside_Points = Xc(Bad_Inds,:);

% Loop through the end members
for ii = 1:nEnd
    inds = [1:ii-1, ii+1:nEnd];
    
    % solve for b in eqn 27
    b = Ec(inds,:)'\Outside_Points';
    
    % find the indices where all values of b are > 0
    % This is Iii in the algorithm
    Pos_inds = find( sum(b>0)==size(b,1) );
    
    % If there are points here then adjust the abundances by
    % recursively calling ProjectToSimplex
    if ~isempty(Pos_inds)
        % Get the new abundances by sending the selected data and end
        % members to the recursive call
        % Send the transposes of X and E, since this is what is
        % expected
        ar = ProjectToSimplex(X(Bad_Inds(Pos_inds),:), E(inds,:), D(inds, inds));
        
        % Reassign the partial abundances with the new values
        v(Bad_Inds(Pos_inds),inds)=ar;
        
        % If the points are fixed, we can remove them and get out the loop
        % early
        % Bad_Inds(Pos_inds) has been fixed, so remove it from Bad_Inds
        %         Bad_Inds(Bad_Inds==Bad_Inds(Pos_inds)) =[];
        Keep_Inds=setdiff(1:nBad, Pos_inds);
        Bad_Inds=Bad_Inds(Keep_Inds);
        nBad = length(Bad_Inds);
        Outside_Points=Xc(Bad_Inds,:); % Get the points still outside
        
        
        if isempty(Bad_Inds)
            % all done so...
            break;
        end
        
    end   
    
end


%% Assign the final outputs

Abunds = v;
EM_Fit = (v*E);


%% Do a check to make sure we are in the simplex
% This does not fix poor projections, but is used as a check to decide 
% whether or not the use of FCLS is needed

if nargin < 3 % We are not in the recursive call   
    Validity = CheckValidity(X, EM_Fit, E);
end


function [Validity] = CheckValidity(X, EM_Fit, E)
%
% Function to check the validity of the projection following refs [2-3]
% 
nData = size(X,1);
nEnd = size(E, 1);

dK = 1e-3; % Kolmogorov criterion threshold

% Get the projection difference and endmember difference
Pd = X - EM_Fit;

Fail = NaN(nEnd, 1);
for ii = 1:nEnd
    Ed=repmat(E(1,:), nData,1) - EM_Fit;
    Fail(ii) = sum(sum(Pd .* Ed > dK) );
end

Validity = ~any(Fail);




function [y, v] = ProjectToPlane(X, E)
%
% Project points in X to the plane spaned by E
% Returns:
%          y - the projected points
%          v - the partial abundances

nData = size(X,1);
nEnd = size(E,1);

e1 = E(1,:); % Get the first endmember
Ehat = E(2:end,:) - repmat(e1, nEnd-1, 1); % Eqn 19

% The full version of eqn 19
y = (X-repmat(e1, nData, 1)) * (Ehat' * pinv(Ehat*Ehat') * Ehat) + repmat(e1, nData, 1);

% Get the partial abundances
% nData x nEnd
v = (E'\y')';

