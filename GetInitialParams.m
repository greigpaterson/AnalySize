function [Lower, Upper, Initial] = GetInitialParams(X, GS, kmin, kmax, Fit_Type)
%
% Function the returns the lower and upper bounds and intial guesses for 
% the parameters of the parametric distributions.
%
% Input:
%       X - nData x nVar matrix containing the observed data
%       GS - nVar x 1 vector of data bins
%       kmin - the minimum number of end members to fit
%       kmax - the maximum number of end members to fit
%       Fit_Type - string containing the name of the distribution to fit
%
% Output:
%       Lower - Matrix containing the parameter lower bounds
%       Upper - Matrix containing the parameter upper bounds
%       Initial - Cell array containing the parameter initial guesses
%

%% Get some basic stuff

% Get dimensions
[nData, nVar] = size(X);

LGS = log(GS); % log grain size

%% Start by getting the lower and upper bounds
%
% These are based on the limits of the data
%

% Get indices of all non-zero data
NZi = sum(X==0)~=nData;
NZi_Lims = [find(LGS == min(LGS(NZi))), find(LGS == max(LGS(NZi)))]; % Grain size indices for start and end points

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
                
        Lower = repmat([1, 2, NZi_Lims(1)], kmax, 1);
        Upper = repmat([length(NZi), length(GS), NZi_Lims(2)], kmax, 1);
        
    case 'Weibull'
        
        Lower = repmat([1, 1], kmax, 1);
        Upper = repmat([length(GS), length(GS)], kmax, 1);
        
    case 'SGG'
        
        % A lower bound on |q| is imposed in Unmix_Para_EMs.m to kept 
        % realistc values of p after the maximum entropy transformation
        Lower = repmat([min(LGS(NZi)), min(abs(diff(LGS(NZi)))), -0.25], kmax,1);
        Upper = repmat([max(LGS(NZi)), max(LGS(NZi)) - min(LGS(NZi)), 1], kmax,1);
        
        % reduce the scale parameter by 2*k
        Upper(:,2) = Upper(:,2) ./ (2.*(1:kmax)') ;
        
    case 'GEV'
        Lower = repmat( [min(LGS(NZi)), 1/( max(LGS) - min(LGS) ), -1 ], kmax, 1);
        Upper = repmat( [max(LGS(NZi)), max(LGS) - min(LGS), 1 ], kmax, 1);
end


%% Get the intial guesses

% suppress rank deficient warnings for this intial search
warning('off', 'MATLAB:rankDeficientMatrix');

% Set options for the search
options=optimset('MaxIter', 1e3, 'MaxFun', 1e3, 'TolX', 1e-4, 'TolFun', 1e-4, 'Display', 'off');

% for storing the parameters
Initial=cell(kmax, 1); 
fval=NaN(kmax,1);
EF=NaN(kmax,1);

% loop through the desired end members
for ii = kmin:kmax
    
    % Get the HALS-NMF solution
    [tmp_EM, tmp_Abunds] = HALS_NMF(X, ii, 5e3, 10);
    
        % Check convexity and adjust b2 if needed
    [tmp_EM, tmp_Abunds, Xprime, Convexity] = Find_b2(X, tmp_EM);
    
    % Sort the EMs by their mean abundances
    [sorted_abunds, Sinds] = sortrows(mean(tmp_Abunds)', -1);
    tmp_EM = tmp_EM(Sinds,:);
    
    % Get the EM gradients
    dE = gradient(tmp_EM);
    
    % Get the number of stationary points for each row
    Stat_pts = diff(sign(dE), [], 2);
    Stat_pts(tmp_EM(:,1:end-1) < 0.01) = 0; % Set stat pts with low density to zero
    
    
    % loop through the end members to identify stationary points
    tmp_sorted = [];
    tmp_sorted2 = [];
    
    for jj = 1:ii
        SP = Stat_pts(jj,:);
        
        % Process the maxima
        Pos2Neg_inds = find(SP==-2);
        
        if isempty(Pos2Neg_inds)
            % No transition in the second derivative
            % Simply take the maximum value of the end member
            Pos2Neg_inds = find( tmp_EM(ii,:) == max(tmp_EM(ii,:)) );
        end
        
        tmp_X = mean([tmp_EM(jj,Pos2Neg_inds)', tmp_EM(jj,Pos2Neg_inds+1)'], 2);
        tmp_GS = mean([LGS(Pos2Neg_inds), LGS(Pos2Neg_inds+1)], 2);
%         keyboard
        % Sort the details by normalized frequency so the first row
        % corresponds to the most prevalant component
        tmp_sorted = [tmp_sorted; sortrows([tmp_X, tmp_GS, abs([tmp_GS(1)/4; diff(tmp_GS)/4]), Pos2Neg_inds' ], -1) ]; %#ok<AGROW>
        
        % Process the minima
        Neg2Pos_inds = find(SP==2);
        
        if ~isempty(Neg2Pos_inds)
            tmp_X2 = mean([tmp_EM(jj,Neg2Pos_inds)', tmp_EM(jj,Neg2Pos_inds+1)'], 2);
            tmp_GS2 = mean([LGS(Neg2Pos_inds), LGS(Neg2Pos_inds+1)], 2);
            
            tmp_sorted2 = [tmp_sorted2; sortrows([tmp_X2, tmp_GS2, abs([tmp_GS2(1)/4; diff(tmp_GS2)/4]), Neg2Pos_inds' ], -1) ]; %#ok<AGROW>
        end
        
    end
    
    n = size(tmp_sorted, 1);
    
    if n < ii
        
        % Take the details and tag on the minima. This is for cases where the
        % number of desired end members is greater than the number of maxima
        tmp_sorted = [tmp_sorted; tmp_sorted2]; %#ok<AGROW>
    end
    
    n = size(tmp_sorted, 1);
            
    % Identify the first and last non-zero indices
    NZi = NaN(ii,2);
    for jj = 1:ii
        NZi(jj,1) = find(tmp_EM(jj,:) > 0, 1, 'first');
        NZi(jj,2) = find(tmp_EM(jj,:) > 0, 1, 'last');
    end
    
    % define limits of the non-zero indices
    % These are used for the Weibull fits
    NZi_Lims =[min(NZi(:,1)), max(NZi(:,2))];   
    
    switch Fit_Type
        
        case 'Lognormal'
            Init = [tmp_sorted(:,2), tmp_sorted(:,3)];
            
            % Catch cases where there are fewer stationary points than desired end members
            if n < ii
                Init(n+1:ii,:) = repmat( mean([Lower(1,:); Upper(1,:)]), ii-n, 1);
            end
                        
        case 'Gen. Weibull'
                        
            % For k (Bhat) >= 2, lambda (Ahat) is approximately the mode,
            % but less the first non-zero index for a general Weibull
            Ahat = tmp_sorted(:,4) - NZi_Lims(1);
            Bhat = Ahat./2; %A hat/2 since for most good fits Bhat < Ahat, but > 2
            Bhat(Bhat<2) = 2;
            
            mu = NZi_Lims(1).*ones(size(Ahat));
                        
            Init = [Ahat, Bhat, mu ];
            
            if n < ii
                Init(n+1:ii,:) = repmat( [Ahat(1), Bhat(1), NZi_Lims(1)], ii-n, 1);
            end
                        
        case 'Weibull'
            
            % For k (Bhat) >= 2, lambda (Ahat) is approximately the mode
            % approximate only if k >= 2
            Ahat = tmp_sorted(:,4);
            Bhat = Ahat./2; % Ahat/2 since for most good fits Bhat < Ahat, but > 2
            Bhat(Bhat<2) = 2;
            
            Init = [Ahat, Bhat];
            
            if n < ii
                % Spread any extra initial estiamtes evenly
                kleft = ii-n;
                Steps = ( NZi_Lims(2) - NZi_Lims(1) ) / kleft;
                
                Ahat = NZi_Lims(1) + Steps.*(1:kleft);
                Bhat = Ahat./2;
                Bhat(Bhat<2) = 2;
                
                Init(n+1:ii,:) = [Ahat', Bhat'];
            end
            
        case 'SGG'
            
            Init = [tmp_sorted(:,2), tmp_sorted(:,3), 0.99.*ones(n,1)];
            % Start with a small skewness (q = 0.99) to avoid starting on
            % the upper boundary
            
            if n < ii
                Init(n+1:ii,:) = repmat( [mean(tmp_sorted(:,2)), mean(tmp_sorted(:,3)), 0.99], ii-n, 1);
            end
            
        case 'GEV'
            
            Init = [tmp_sorted(:,2), tmp_sorted(:,3), zeros(n, 1)];
            
            if n < ii
                Init(n+1:ii,:) = repmat( [mean([Lower(1,2:end); Upper(1,2:end)]), 0 ], ii-n, 1);
            end
            
    end
    
    % Do an intial fitting search to get a more precise initial esimate        
    [Params, fval(ii), EF(ii)]=fminsearchbnd(@(z) Unmix_Para_EMs(tmp_EM, GS, ii, Fit_Type, z, 'Projection'), Init(1:ii,:), Lower(1:ii,:), Upper(1:ii,:), options);
    Initial(ii) = {Params};

end

% Turn the warning back on
warning('on', 'MATLAB:rankDeficientMatrix');

% toc
