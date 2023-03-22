function Stats = Get_Descriptive_Stats(X, GS, Type_Flag)
%
% Function to get the descriptive statistics of grain size data
%
% Input:
%        X - Grain size PDF data
%        GS - grain size bin in microns
%        Type_Flag - flag to denote what type of stats to return
%                    1) Geometric moments
%                    2) Log moments
%                    3) Geometic graphic
%                    4) Log graphic
%                    5) Percentiles
%                    6) Size fractions
%                    7) Sortable silt
%
% Output:
%        Stats - nData x 4 matrix [Mean, StDev, Skewness, Kurtosis]
%

%% Do some basic checks

if nargin < 3
    error('Get_Descriptive_Stats:Input', 'At least three inputs are required.');
end

[nData, nVar] = size(X);
nVar2 = length(GS);

if nVar ~= nVar2
    error('Get_Descriptive_Stats:Input', 'Both the data matrix and grain size vector must contain the same number of variables.');
end

GS = repmat(GS', nData, 1); % Repmat GS to same size as X
Phi = -log2(GS./1e3); % grain size in phi units

pvals1 = [5, 16, 25, 50, 75, 84, 95]; % Percentiles for the graphic stats
pvals2 = [10, 25, 50, 75, 90]; % Percentiles for the percentile stats

%% Do the main bits

switch Type_Flag
    case 1 % Geometric moments
        
        GSbar = exp(sum(X.*log(GS), 2));
        Sigma = exp( sqrt( sum( X .* bsxfun(@minus, log(GS), log(GSbar)).^2, 2) ) );
        Sk = sum( X .* bsxfun(@minus, log(GS), log(GSbar)).^3, 2)./log(Sigma).^3;
        Kurt = sum( X .* bsxfun(@minus, log(GS), log(GSbar)).^4, 2)./log(Sigma).^4;
        
    case 2 % Log moments
        
        GSbar =sum(X.*Phi, 2);
        Sigma = sqrt( sum( X .* bsxfun(@minus, Phi, GSbar).^2, 2) );
        Sk = sum( X .* bsxfun(@minus, Phi, GSbar).^3, 2)./Sigma.^3;
        Kurt = sum( X .* bsxfun(@minus, Phi, GSbar).^4, 2)./Sigma.^4;
        
    case 3 % Geometric graphic
        
        P = GetPercentile(X, GS(1,:), pvals1);
        P05 = log(P(:,1));
        P16 = log(P(:,2));
        P25 = log(P(:,3));
        P50 = log(P(:,4));
        P75 = log(P(:,5));
        P84 = log(P(:,6));
        P95 = log(P(:,7));
        
        GSbar = exp( (P16 + P50 + P84)./3 );
        Sigma = exp( (P84 - P16)./4 + (P95 - P05)./6.6 );
        Sk = (P16 + P84 - 2.*P50) ./ (2.*(P84 - P16)) + (P05 + P95 - 2.*P50) ./ (2.*(P95 - P05));
        Kurt = (P05 - P95) ./ (2.44.*(P25 - P75));
               
    case 4 % Log graphic
        
        P = GetPercentile(X, Phi(1,:), pvals1);
        P05 = P(:,1);
        P16 = P(:,2);
        P25 = P(:,3);
        P50 = P(:,4);
        P75 = P(:,5);
        P84 = P(:,6);
        P95 = P(:,7);
        
        GSbar = (P16 + P50 + P84)./3;
        Sigma = (P16 - P84)./4 + (P05 - P95)./6.6;       
        Sk = (P16 + P84 - 2.*P50) ./ (2.*(P16 - P84)) + (P05 + P95 - 2.*P50) ./ (2.*(P05 - P95));
        Kurt = (P95 - P05) ./ (2.44.*(P75 - P25));
        
    case 5 % Percentiles
        
        P = GetPercentile(X, GS(1,:), pvals2);
        Stats = [P(:,1), P(:,2), P(:,3), P(:,4), P(:,5)];
        
    case 6 % Size fractions

        Phi = Phi(1,:); % Isolate a single vector
        
        % some machines do not measure upto -1 phi
        sand_lim = -1;
        if min(Phi) > -1
            sand_lim = min(Phi);
        end
        
        
        % The data cumulative sum
        CS = cumsum(X,2);
        
        % The precentages
        clay_pct = interp1(Phi, CS', 8)';
        silt_pct = interp1(Phi, CS', 4)' - clay_pct;
        sand_pct = interp1(Phi, CS', sand_lim)' - interp1(Phi, CS', 4)';
        gravel_pct = 1-interp1(Phi, CS', sand_lim)';
        gravel_pct(gravel_pct<1e-6) = 0; % remove rounding errors
        
        Stats = [clay_pct, silt_pct, sand_pct, gravel_pct].*100;
        
    case 7 % Sortable silt
        
        % Get the indices of soratble silt fraction
        GS_idx = GS(1,:)>=10 & GS(1,:)<=63;

        % Get the geometric and log moment means
        GSbar_GM = exp(sum(X(:,GS_idx).*log(GS(:,GS_idx)), 2));
        GSbar_LM =sum(X(:,GS_idx).*Phi(:,GS_idx), 2);
        
        % The data cumulative sum
        CS = cumsum(X,2);
        
        % The precentage
        sortable_pct = 100.*(interp1(GS(1,:), CS', 63)' - interp1(GS(1,:), CS', 10)');
       
        Stats = [GSbar_GM, GSbar_LM, sortable_pct];
                       
    otherwise
        error('Get_Descriptive_Stats:Type_Flag', 'Unrecognized statistics flag requested.');
end

if Type_Flag <= 4
    Stats = [GSbar, Sigma, Sk, Kurt];
end


