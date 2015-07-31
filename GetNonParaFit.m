function [Cancel_Flag, Abunds, EMs, Fit_Quality] = GetNonParaFit(Xin, GS, Fit_Params)
%
% Function that returns the non-parametric endmember fit
%
% Input:
%       Xin - nData x nVar matrix containing the observed data
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
[nData, nVar] = size(X);
% X(X<eps) = eps; % round off very small numbers and zeros (prevents errors)
% X = X./(sum(X,2)*ones(1,nVar)); % set sum of each row to 1

% The min and max End Members to fit
EM_Min =  Fit_Params{1};
EM_Max = Fit_Params{2};

%% Loop through the endmembers

% Pre-allocate variables for speed
R2 = NaN(EM_Max,1);
Spec_R2 = NaN(nData, EM_Max);
Min_Spec_R2 = NaN(EM_Max, 1);
EM_R2 = NaN(EM_Max,1);
Spec_Angle = NaN(nData, EM_Max);
DataSet_Angle = NaN(EM_Max, 1);
% Convexity_Error = NaN(EM_Max, 1);

Stored_Xprime = cell(EM_Max, 1); % for storing the abundance
Stored_EMs = cell(EM_Max, 1); % for storing the end members
Stored_Abunds = cell(EM_Max, 1); % for storing the abundance

tic
% Set up a waitbar to count the loop
h = waitbar(0,'Initializing....', 'Name', 'Calculating end member fits...',...
    'CreateCancelBtn', 'setappdata(gcbf,''Cancelled'',1)');
setappdata(h,'Cancelled',0)
Cancel_Flag = 0;


for k=EM_Min:EM_Max
    
    % Check for Cancel button press
    if getappdata(h,'Cancelled')
        Cancel_Flag = 1;
        break;
    end
    
    % Update the waitbar and continue
    waitbar((k-1)/(EM_Max), h, strcat('Fitting ', sprintf(' %d', k), ' end members....'))
    
    [tmp_EM, tmp_Abunds, Xprime] = HALS_NMF(X, k, 5e3, 10, [5, 0, 0, 0], 0);
    
    Convexity = GetConvexityError(X, tmp_EM);
    
    % Check the convexity
    % define some params for the b2 search
    MaxIter = 1e2;
    Clim1 = -8; % low convexity limit
    Clim2 = -6; % upper convexity limit
    
    if jj ~=1 && Convexity <= Clim1
        % Increase minimum distance too ensure convexity is not too low
        % This makes the fit robust to outliers
        % k = 1 is perfectly convex so skip this case
        
        % Low and upper values for the update
        b2_low = 0;
        C_low = Convexity;
        b2_hi = [];
        C_hi = [];
        
        iter = 2; % Current iteration count
        b2 = 0.4; % New b2 value - relatively large in the hope to ge C > -6 and establish a bound
        
        while iter < MaxIter
            
            [tmp_EMs, tmp_Abunds, Xprime] = HALS_NMF(tmp_Data, jj, 5e3, 10, [5, 0, 0, b2], 0);
            Convexity = GetConvexityError(tmp_Data, tmp_EMs);
            
            if iter > MaxIter
                warning('GetNoParaFit:Find_b2', 'Maximum iterations exceeded. This is unexpected, please let Greig Paterson know.');
                break;
            elseif Convexity <= Clim2 && Convexity > Clim1
                break;
            end
            
            % update b2 for the next iter
            
            if Convexity <= Clim1 && Convexity > C_low
                % New esimate pushes convexity in the right direction,
                % but is still to low
                % Update the lower limits
                b2_low = b2;
                C_low = Convexity;
            end
            
            if ~isempty(b2_hi) && Convexity > Clim2
                % our latest estimate is high, so compare with existing upper bounds
                if Convexity < C_hi
                    % We are closer to desired upper limit, so update
                    b2_hi = b2;
                    C_hi = Convexity;
                end
            end
            
            if isempty(b2_hi) && Convexity > Clim2
                % our latest estimate has jumped right across our
                % bounds, but we have no upper limits, so set them
                b2_hi = b2;
                C_hi = Convexity;
            end
            
            if ~isempty(b2_hi)
                % we have both upper and lower bounds
                % So interpolate between them and aim for a b2 value
                % that is in the middle of the convexity limits
                b2_pts = [b2_low, b2_hi];
                C_pts = [C_low, C_hi];
                b2 = interp1(C_pts, b2_pts, (Clim1+Clim2)/2, 'linear', 'extrap');
            else
                % we have no upper bound so just double the current b2
                b2 = 2*b2;
            end
            
            iter = iter + 1;
        end % end of the while loop
    end %  jj ~=1 && Convexity <= Clim1
    
    
    % Sort the EMs
    [tmp_EM, Sinds] = sortEMs(tmp_EM, GS, 'Median');
    tmp_Abunds = tmp_Abunds(:,Sinds);
    
    Stored_Xprime(k) = {Xprime};
    Stored_EMs(k) = {tmp_EM};
    Stored_Abunds(k) = {tmp_Abunds};
    
    %% Get the correlations and update waitbar
    R2(k) = GetR2(Xprime(:), X(:));
    Spec_R2(:, k) = GetR2(X', Xprime')';
    Min_Spec_R2(k) = min( Spec_R2(:, k) );
    DataSet_Angle(k) = GetAngles(X(:), Xprime(:));
    Spec_Angle(:,k)  = GetAngles(X, Xprime);
    %     Convexity_Error(k) = GetConvexityError(X, tmp_EM);
    
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

delete(h)
toc


if Cancel_Flag == 1
    % User has cancelled so return emptiness
    Abunds=[];
    EMs=[];
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
Transfer.EM_R2 = EM_R2;
% Transfer.Convexity = Convexity_Error;

Return = Select_EndMembers('DataTransfer', Transfer);
Cancel_Flag = Return.Cancel_Flag;

if Cancel_Flag == 1
    % User has cancelled so return emptiness
    Abunds=[];
    EMs=[];
    Fit_Quality=[];
    return
end
Selected_EM = Return.EM;


Xprime = Stored_Xprime{Selected_EM};
EMs = Stored_EMs{Selected_EM};
Abunds = Stored_Abunds{Selected_EM};


% Recalculate the fit quality stats
R2 = GetR2(Xprime(:), X(:));
Spec_R2 = GetR2(X', Xprime')';
DataSet_Angle = GetAngles(X(:), Xprime(:));
Spec_Angle  = GetAngles(X, Xprime);

r = GetR2(EMs');
r = r - diag(diag(r));
EM_R2 = max(max(r.^2));

Fit_Quality = {[R2, DataSet_Angle, EM_R2], [Spec_R2, Spec_Angle]};

% toc
