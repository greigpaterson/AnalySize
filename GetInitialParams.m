function [Lower, Upper, Intial] = GetInitialParams(X, GS, kmax, Fit_Type, Get_Initial)
%
% Function the returns the lower and upper bounds for the parameters of the
% parametric distributions. It also returns intial guesses for parameter
% values that are used for the search rotuine.
% 
%% Get some basic stuff

if nargin < 5
    Get_Initial = 1;
end

% Get indices of all non-zero data
[nData, nVar] = size(X);
Xn = X./repmat(max(X, [], 2), 1, nVar);

LGS = log(GS);

% Get indices of all non-zero data
NZi = sum(X==0)~=nData;


%% Start by getting the lower and upper bounds

switch Fit_Type
    case 'Lognormal'
        
        % Mean values are bounded by min/max GS
        % Standard devaitions by max-min GS
        
        Lower = repmat([min(LGS(NZi)), min(abs(diff(LGS)))], kmax,1);
        Upper = repmat([max(LGS(NZi)), max(LGS(NZi)) - min(LGS(NZi))], kmax,1);
        
        % reduce the scale parameter by 2*k
        % This help to minimize end member correlation
        Upper(:,2) = Upper(:,2) ./ (2.*(1:kmax)') ;

    case 'Gen. Weibull'
        
        Lower = repmat([1e-4, 1 + 1e-4, min(LGS(NZi))], kmax, 1);
%         Upper = repmat([2*( max(LGS) - min(LGS) ), max(GS)/100, max(LGS(NZi))], k, 1);
        Upper = repmat([( max(LGS) - min(LGS) ), 2*( max(LGS) - min(LGS) ), max(LGS(NZi))], kmax, 1);
        
    case 'Weibull'
        
        Lower = repmat([1, 1], kmax, 1);
        Upper = repmat([length(GS), length(GS)], kmax, 1);
        
    case 'SGG'
        
        Lower = repmat([min(LGS(NZi)), min(abs(diff(LGS(NZi)))), -1], kmax,1);
        Upper = repmat([max(LGS(NZi)), max(LGS(NZi)) - min(LGS(NZi)), 1], kmax,1);

        % reduce the scale parameter by 2*k
        Upper(:,2) = Upper(:,2) ./ (2.*(1:kmax)') ;
        
    case 'GEV'
        Lower = repmat( [min(LGS(NZi)), 1/( max(LGS) - min(LGS) ), -1 ], kmax, 1);
        Upper = repmat( [max(LGS(NZi)), max(LGS) - min(LGS), 1 ], kmax, 1);
end


%% Get the intial guesses

if Get_Initial ~= 1
    Intial = [];
    return
end

% tic

% Get the data gradients
dX = gradient(X);
% dX2 = gradient(dX);

% Get the number of stationary points for each row
Stat_pts = diff(sign(dX), [], 2);
Stat_pts(Xn(:,1:end-1) < 0.05) = 0; % Set stat pts with low density to zero

Nstat_pts = sum(Stat_pts ~=0 , 2); % Get the number of pts

[~,inds] = sort(Nstat_pts, 'descend'); % sort the get the maximum
I_data = X(inds(1),:);
% I_data = X(inds(1:max(nData,5)),:);
I_Stat_pts = Stat_pts(inds(1),:);

% I_Stat_pts == -2 corresponds to dX going from positive to negative (dx2
% negative) X is a maxima
% I_Stat_pts == 2 corresponds to dX going from negative to positive (dX2
% positive) X is a minima
Pos2Neg_inds = find(I_Stat_pts==-2);
Neg2Pos_inds = find(I_Stat_pts==2);

tmp_X = mean([I_data(Pos2Neg_inds)', I_data(Pos2Neg_inds+1)'], 2);
tmp_GS = mean([LGS(Pos2Neg_inds), LGS(Pos2Neg_inds+1)], 2);

tmp_sorted = sortrows([tmp_X, tmp_GS, abs([tmp_GS(1)/4; diff(tmp_GS)/4]) ], -1);

tmp_X = mean([I_data(Neg2Pos_inds)', I_data(Neg2Pos_inds+1)'], 2);
tmp_GS = mean([LGS(Neg2Pos_inds), LGS(Neg2Pos_inds+1)], 2);

try 
    % Sometimes tmp_X and/or tmp_GS are empty, so try/catch
    tmp_sorted2 = sortrows([tmp_X, tmp_GS, abs([tmp_GS(1)/4; diff(tmp_GS)/4]) ], -1);
    tmp_sorted = [tmp_sorted; tmp_sorted2];
catch
    % do nothing
end

n = size(tmp_sorted, 1);

% The inital guesses
switch Fit_Type
    
    case 'Lognormal'
        Init = [tmp_sorted(:,2), tmp_sorted(:,3)];
        
        if n < kmax
            Init(n+1:kmax,:) = repmat( mean([Lower(1,:); Upper(1,:)]), kmax-n, 1);
        end
        
    case 'Gen. Weibull'
        
        Bhat = 2.*ones(n, 1);
        Ahat = 2.*ones(n, 1);

        mu = [min(LGS(NZi)); max( min(LGS(NZi)), tmp_sorted(2:end,2)./2)];

        Init = [Ahat, Bhat, mu ];
        
        if n < kmax
            Init(n+1:kmax,:) = repmat( [2, 2, mu(1)], kmax-n, 1);
        end
        
    case 'Weibull'
        
        Ahat = 50.*ones(n, 1);
        Bhat = 5.*ones(n, 1);
        
        Init = [Ahat, Bhat];
        
        if n < kmax
            Init(n+1:kmax,:) = repmat( [50, 5], kmax-n, 1);
        end
        
    case 'SGG'

        Init = [tmp_sorted(:,2), tmp_sorted(:,3), ones(n,1)];
        
        if n < kmax
            Init(n+1:kmax,:) = repmat( [mean(tmp_sorted(:,2)), mean(tmp_sorted(:,3)), 1 ], kmax-n, 1);
        end
        
    case 'GEV'

        Init = [tmp_sorted(:,2), tmp_sorted(:,3), zeros(n, 1)];
        
        if n < kmax
            Init(n+1:kmax,:) = repmat( [mean([Lower(1,2:end); Upper(1,2:end)]), 0 ], kmax-n, 1);
        end
        
end

% The fit loop
Intial=cell(kmax, 1); % for storing the parameters
fval=NaN(kmax,1);
EF=NaN(kmax,1);

options=optimset('MaxIter', 1e3, 'MaxFun', 1e3, 'TolX', 1e-3, 'TolFun', 1e-3, 'Display', 'off');

for ii = 1:kmax
    
    if ii > 1
        Init(1:ii-1,:) = Intial{ii-1};
    end
    
    [Params, fval(ii), EF(ii)]=fminsearchbnd(@(z) Unmix_Para_EMs(I_data, GS, ii, Fit_Type, z, 'Projection'), Init(1:ii,:), Lower(1:ii,:), Upper(1:ii,:), options);
    Intial(ii) = {Params};
    
end

% toc
