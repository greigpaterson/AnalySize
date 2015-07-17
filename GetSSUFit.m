function [Cancel_Flag, Abunds, EMs, Dist_Params, Fit_Quality] = GetSSUFit(Xin, GS, Fit_Params)
%
% Function to perform Single Specimen Unmixing (SSU)
%
% Input:
%       Xin - nData x nVar matrix containing the observed data
%       GS - nVar x 1 vector of data bins
%       Fit_Params - 5 x 1 cell of parameters specifying fit options
%
% Output:
%        Cancel_Flag - a flag to indicate whether (= 1) or not (= 0) the
%                      user cancelled the process
%        Abunds - nData x nEnd matrix of end member abundances
%        EMs - nEnd x nVar matrix of end members (NB not multiplied by A)
%        Dist_Params - nEnd x nParams matrix of the best-fit distribution
%                      parameters
%        Fit_Quality - cell array containing measures of the goodness of
%                      fit for the best-fit endmembers{[R2(Selected_EM,
%                      Mean_Angle], [Spec_R2, Spec_Angle]};
%

%% Process the inputs

X = Xin; % Assign the original data to X
[nData,nVar] = size(X);
% X(X<eps) = eps; % round off very small numbers and zeros (prevents errors)
% X = X./(sum(X,2)*ones(1,nVar)); % set sum of each row to 1

% The min and max End Members to fit
k = Fit_Params{1};
Fit_Type = char(Fit_Params{2});
Abund_Lim = Fit_Params{3};
EMA_Initial = Fit_Params{4};

%% Initialize
options=optimset('MaxIter', 1e4, 'MaxFun', 1e4, 'TolX', 1e-4, 'TolFun', 1e-4, 'Display', 'off');

% tic
h = waitbar(0,'Initializing....', 'Name', 'Calculating end member fits...',...
    'CreateCancelBtn', 'setappdata(gcbf,''Cancelled'',1)');
setappdata(h,'Cancelled',0)
Cancel_Flag = 0;

[Lower, Upper, Initial_Params] = GetInitialParams(X, GS, k, k, Fit_Type);
Initial = Initial_Params{k,1};

% Get an intial guess using EMA
if EMA_Initial
    Params = fminsearchbnd(@(z) Unmix_Para_EMs(X, GS, k, Fit_Type, z, 'Projection'), Initial, Lower, Upper, options);
    [~, ~, tmp_EM] = Unmix_Para_EMs(X, GS, k, Fit_Type, Params, 'Projection');

    % Sort the EMs
    [~, Sinds] = sortEMs(tmp_EM, GS, 'Median');
    Initial = Params(Sinds,:);
end

% toc

%% Main loop

fval = NaN(nData, 1);
EF = NaN(nData, 1);
Dist_Params=cell(nData, 1); % for storing the parameters
Xprime = NaN(size(X));
EM_R2 = NaN(nData, 1);

Abunds = cell(nData, 1);
EMs = cell(nData,1);

% tic

for ii = 1:nData
    
    % Check for Cancel button press
    if getappdata(h,'Cancelled')
        Cancel_Flag = 1;
        break;
    end
    
    % Update the waitbar and continue
    waitbar((ii-1)/(nData), h, strcat('Processing specimens...'))
    
    [Params, fval(ii), EF(ii)] = fminsearchbnd(@(z) Unmix_Para_EMs(X(ii,:), GS, k, Fit_Type, z, 'Projection', 0), Initial, Lower, Upper, options);
    
    [~, Xprime(ii,:), tmp_EMs, tmp_Abunds, Validity] = Unmix_Para_EMs(X(ii,:), GS, k, Fit_Type, Params, 'Projection', Abund_Lim);
    
    if Validity ~=1 % Call FCLS
        [~, Xprime(ii,:), tmp_EMs, tmp_Abunds] = Unmix_Para_EMs(X(ii,:), GS, k, Fit_Type, Params, 'FCLS', Abund_Lim);
    end
    
    nFit = size(tmp_EMs, 1); % the number of actual fitted end members
    
    % Sort the EMs
    [tmp_EMs, Sinds] = sortEMs(tmp_EMs, GS, 'Median');
    Params = Params(Sinds,:);
    tmp_Abunds = tmp_Abunds(Sinds);
    
    if nFit >1
        r = GetR2(tmp_EMs');
        r = r - diag(diag(r));
        EM_R2(ii) = max(max(r.^2));
    end
    
    % Get p for SGG fits
    if strcmpi(Fit_Type, 'SGG')
        Params(:,4) = 2 + 6.*(1-Params(:,3)).^5;
    end
    
    
    EMs(ii) = {tmp_EMs};
    Dist_Params(ii) = {Params};
    
    if nFit < k
        % we have reduce endmembers
        Abunds(ii) = {[tmp_Abunds, NaN(1, k - size(tmp_EMs, 1))]};
    else
        Abunds(ii) = {tmp_Abunds};
    end
    
end

delete(h)

if Cancel_Flag == 1
    % User has cancelled so return emptiness
    Abunds=[];
    EMs=[];
    Dist_Params=[];
    Fit_Quality=[];
    return
end

% toc

% Get the correlations
R2 = GetR2(Xprime(:), X(:));
Spec_R2 = GetR2(X', Xprime')';
[Spec_Angle, Mean_Angle]  = GetAngles(X, Xprime);


Fit_Quality = {[R2, Mean_Angle, max(EM_R2)], [Spec_R2, Spec_Angle]};

