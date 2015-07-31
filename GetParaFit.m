function [Cancel_Flag, Abunds, EMs, Dist_Params, Fit_Quality, Transfer] = GetParaFit(Xin, GS, Fit_Params, Sel_EM_Data)
%
% Function that returns the parametric endmember fit
%
% Input:
%       Xin - nData x nVar matrix containing the observed data
%       GS - nVar x 1 vector of data bins
%       Fit_Params - 5 x 1 cell of parameters specifying fit options
%       Sel_EM_Data - Previous parametric fit data
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
%

%% Process the inputs

X = Xin; % Assign the original data to X
[nData,nVar] = size(X);
% X(X<eps) = eps; % round off very small numbers and zeros (prevents errors)
% X = X./(sum(X,2)*ones(1,nVar)); % set sum of each row to 1

% The min and max End Members to fit
EM_Min =  Fit_Params{1};
EM_Max = Fit_Params{2};
Fit_Type = char(Fit_Params{3});

%% Check for previous input
switch Fit_Type
    case 'Lognormal'
        ind = 1;
    case 'Gen. Weibull'
        ind = 2;
    case 'Weibull'
        ind = 3;
    case 'SGG'
        ind = 4;
    case 'GEV'
        ind = 5;
end

Transfer = Sel_EM_Data{ind};

Flag = 0;
if isstruct(Transfer)
    
    EM1 = Transfer.EM_Min;
    EM2 = Transfer.EM_Max;
    
    MSG = [ {['Variance data for ', Fit_Type, ' fits with ', num2str(EM1), ' to ', num2str(EM2), ' end members is available.']},...
        {'Do you wish to use the existing fits or generate new ones?'} ];
    
    choice = questdlg(MSG, 'Use existing variance data?', 'Use Existing', 'Get New', 'Use Existing');
    
    switch choice
        case 'Use Existing'
            Flag = 1;
            Stored_Params = Transfer.Params;
        otherwise
            Flag = 0;
    end
end

if Flag == 0
    
    %% Pre-allocate stuff
    R2 = NaN(EM_Max,1);
    Spec_R2 = NaN(nData, EM_Max);
    Min_Spec_R2 = NaN(EM_Max, 1);
    EM_R2 = NaN(EM_Max,1);
    Spec_Angle = NaN(nData, EM_Max);
    DataSet_Angle = NaN(EM_Max, 1);
    
    Stored_Params=cell(EM_Max, 1); % for storing the parameters
    
    fval=NaN(EM_Max,1);
    EF=NaN(EM_Max,1);
    
%     tic
    
    % Set up a waitbar to count the loop
    h = waitbar(0,'Initializing....', 'Name', 'Calculating end member fits...',...
        'CreateCancelBtn', 'setappdata(gcbf,''Cancelled'',1)');
    setappdata(h,'Cancelled',0)
    Cancel_Flag = 0;

    [Lower, Upper, Initial_Params] = GetInitialParams(X, GS, EM_Min, EM_Max, Fit_Type);

    %     toc

    %% The main loop
    
    % suppress rank deficient warnings. This is often needed for high numbers
    % of end members, which are over-fitting the data
    warning('off', 'MATLAB:rankDeficientMatrix');
    
    % Set options for the search
    options=optimset('MaxIter', 1e4, 'MaxFun', 1e4, 'TolX', 1e-4, 'TolFun', 1e-4, 'Display', 'off');
    
    % Check for Cancel button press
    if getappdata(h,'Cancelled')
            Cancel_Flag = 1;
    end
    
    
    for k = EM_Min:EM_Max
        
        % Check for Cancel button press
        if Cancel_Flag == 1 || getappdata(h,'Cancelled')
            Cancel_Flag = 1;
            break;
        end
        
        % Update the waitbar and continue
        waitbar((k-1)/(EM_Max), h, strcat('Fitting ', sprintf(' %d', k), ' end members....'))
        
        Initial = Initial_Params{k,1};
        
        [Params, fval(k), EF(k)] = fminsearchbnd(@(z) Unmix_Para_EMs(X, GS, k, Fit_Type, z, 'Projection'), Initial(1:k,:), Lower(1:k,:), Upper(1:k,:), options);
        
        [~, Xprime, tmp_EM] = Unmix_Para_EMs(X, GS, k, Fit_Type, Params, 'Projection');
        
        % Sort the EMs
        [tmp_EM, Sinds] = sortEMs(tmp_EM, GS, 'Median');
        Params = Params(Sinds,:);
        
        Stored_Params(k) = {Params};
        
        %% Get the correlations and update waitbar
        R2(k) = GetR2(Xprime(:), X(:));
        Spec_R2(:, k) = GetR2(X', Xprime')';
        Min_Spec_R2(k) = min( Spec_R2(:, k) );
        DataSet_Angle(k) = GetAngles(X(:), Xprime(:));
        Spec_Angle(:,k)  = GetAngles(X, Xprime);
        
        if k >1
            r = GetR2(tmp_EM');
            r = r - diag(diag(r));
            EM_R2(k) = max(max(r.^2));
        end
        
        % Check for cancelling
        if getappdata(h,'Cancelled')
            Cancel_Flag = 1;
            break;
        end
        
    end
    
    % Turn the warning back on
    warning('on', 'MATLAB:rankDeficientMatrix');
    
    delete(h) % delete the waitbar
%     toc
    
    if Cancel_Flag == 1
        % User has cancelled so return emptiness
        Abunds=[];
        EMs=[];
        Dist_Params=[];
        Fit_Quality=[];
        return
    end
    
    
    % Get the selected number of end members
    Transfer.DataSet_R2 = R2;
    Transfer.Spec_R2 = Spec_R2;
    Transfer.DataSet_Angle = DataSet_Angle;
    Transfer.Spec_Angle = Spec_Angle;
    Transfer.EM_Min = EM_Min;
    Transfer.EM_Max = EM_Max;
    Transfer.Params = Stored_Params;
    Transfer.EM_R2 = EM_R2;
    
end

Return = Select_EndMembers('DataTransfer', Transfer);
Cancel_Flag = Return.Cancel_Flag;

if Cancel_Flag == 1
    % User has cancelled so return emptiness
    Abunds=[];
    EMs=[];
    Dist_Params=[];
    Fit_Quality=[];
    return
end
Selected_EM = Return.EM;


%% Check the final fit

% Check the validity of the simplex projection and run FCLS if needed
Dist_Params = Stored_Params{Selected_EM};
[~, ~, EMs, Abunds, Validity] = Unmix_Para_EMs(X, GS, Selected_EM, Fit_Type, Dist_Params, 'Projection');

if Validity ~=1
    [~, ~, EMs, Abunds] = Unmix_Para_EMs(X, GS, Selected_EM, Fit_Type, Dist_Params, 'FCLS');
end

% Get p for SGG fits
if strcmpi(Fit_Type, 'SGG')
    Dist_Params(:,4) = 2 + 6.*(1-Dist_Params(:,3)).^5;
end

% Recalculate the fit quality stats
Xprime = Abunds*EMs;
R2 = GetR2(Xprime(:), X(:));
Spec_R2 = GetR2(X', Xprime')';
DataSet_Angle = GetAngles(X(:), Xprime(:));
Spec_Angle  = GetAngles(X, Xprime);

r = GetR2(EMs');
r = r - diag(diag(r));
EM_R2 = max(max(r.^2));

Fit_Quality = {[R2, DataSet_Angle, EM_R2], [Spec_R2, Spec_Angle]};


