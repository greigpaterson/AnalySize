function [MisFit, Xprime, EM, A, Validity] = Unmix_Para_EMs(X, GS, k, Fit_Type, Params, Algorithm, Abund_Lim)
%
% Function to determine the end member abundances to fully unmix a given
% data set into specified paramtric end members
%
% Input:
%       X - nData x nVar matrix containing the observed data
%       GS - nVar x 1 vector of data bins
%       k - the number of end members to fit
%       Fit_Type - string containing the name of the distribution to fit
%       Params - the distribution paramters
%       Algorithm - the algorithm to use for determining the abundances.
%                   Either 'Projection" for the SPU algorithm of [1], or 
%                   'FCLS' for the fully constrained least squares 
%                   algorithm of [2].
%
% Output:
%       MisFit - the Forbenius norm of X-Xprime
%       Xprime - nData x nVar matrix of reconstructed data
%                (Normalized to sum-to-one)
%       EMs - k x nVar matrix of end member vectors
%       A - nData x k matrix of abundances
%       Validitity - Flag to indicate the validity of the SPU solution
%
% References:
%
% [1] Heylen et al. (2011), Fully Constrained Least Squares Spectral
%     Unmixing by Simplex Projection, Geoscience and Remote Sensing, IEEE
%     Transactions on, 49, 4112-4122, doi: 10.1109/TGRS.2011.2155070
%
% [2] Heinz, D.C., and C.-I Chang (2001), Fully constrained least squares 
%     linear spectral mixture analysis method for material quantification 
%     in hyperspectral imagery, IEEE Tran. GRS, vol. 39, 529-545.
%

%% Generate the end members
EM=NaN(length(GS), k);

switch Fit_Type
    case 'Lognormal'
        for ii=1:k
            EM(:,ii) = Get_lognpdf(GS, Params(ii,1), Params(ii,2));
        end       
        
    case 'Weibull'
        for ii=1:k
            EM(:,ii) = genwblpdf(1:length(GS), Params(ii,1), Params(ii,2), 0);
        end
        
    case 'Gen. Weibull'
        for ii=1:k
%             EM(:,ii) = genwblpdf(log(GS), Params(ii,1), Params(ii,2), Params(ii,3));
            EM(:,ii) = genwblpdf(1:length(GS), Params(ii,1), Params(ii,2), Params(ii,3));
        end
        
    case 'SGG'
        tmp_p =  2 + 6.*(1-Params(:,3)).^5;
        for ii=1:k
            EM(:,ii) = sggpdf(log(GS), Params(ii,1), Params(ii,2), Params(ii,3), tmp_p(ii));
        end
        
    case 'GEV'
        for ii=1:k
            EM(:,ii) = Get_gevpdf(log(GS), Params(ii,1), Params(ii,2), Params(ii,3));
        end
end

EM=bsxfun(@rdivide, EM, sum(EM))';
EM(isnan(EM)) = 0; %catch distribtion with zero probability across the grain size bins

%% Do the unmixing
% Check the EMs and fix zero abundance

if any(sum(EM,2) == 0)
    % One row is all zeros
    % This happens with the EM PDF is out of range of the data during the
    % search routine
    % We have k-1 end members and a zero abundance endmember
    Z_inds = sum(EM,2) == 0 ;
    
    if isempty(EM(~Z_inds,:))
        % All EMs are out of range
        A = zeros(size(X,1), k);
        Xprime = zeros(size(X));
        Validity = 0;
    else
        A = NaN(size(X,1), k);
        
        % send on the non-zero EMs to simplex projection
        switch Algorithm
            case 'Projection'
                [tmp_A, Xprime, Validity] = ProjectToSimplex(X, EM(~Z_inds,:));
            case 'FCLS'
                [tmp_A, Xprime] = Get_FCLS(X, EM(~Z_inds,:));
                Validity = NaN;
        end
        
        A(:,~Z_inds) = tmp_A;
        A(:,Z_inds) = zeros(size(A,1),sum(Z_inds));
    end
    
else
    
    switch Algorithm
        case 'Projection'
            [A, Xprime, Validity] = ProjectToSimplex(X, EM);
        case 'FCLS'
            [A, Xprime] = Get_FCLS(X, EM);
            Validity = NaN;
    end
end

% on the final check using abundance limit
if nargin == 7
    % Find the zero abundances
    Zero_abunds = find(A < Abund_Lim);
    
    if ~isempty(Zero_abunds)
        
        EM(Zero_abunds,:) = [];
        
        switch Algorithm
            case 'Projection'
                [A, Xprime, Validity] = ProjectToSimplex(X, EM);
            case 'FCLS'
                [A, Xprime] = Get_FCLS(X, EM);
                Validity = NaN;
        end
        
    end
    
end

MisFit = norm(X - Xprime, 'fro');
