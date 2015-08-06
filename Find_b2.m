function [tmp_EMs, tmp_Abunds, Xprime, Convexity] = Find_b2(X, tmp_EMs)
%
% Function to search for the HALS-NMF minimum distance regularizer, b2, that yields 
% acceptble convexity error. This makes the fit robust to noise and
% outliers.
%

%% Set up parameters and do an inital check
% Define some params for the b2 search
MaxIter = 1e2; % maximum iterations before stopping
Clim1 = -7; % lower convexity limit
Clim2 = -6; % upper convexity limit

% Get the number of EMs and initial convexity error
k = size(tmp_EMs, 1);
Convexity = GetConvexityError(X, tmp_EMs);

InLim = Convexity <= Clim2 && Convexity > Clim1;

% Check we are satified, or simplex is smaller than convexity limit and return
if k==1 || InLim || Convexity > Clim2
    [tmp_Abunds, Xprime] = Get_FCLS(X, tmp_EMs);
    return;
end

%% Do the main loop
% k >= 2 and b2 can give us a better convexity error

% Define values to remember duirng the updates
b2_low = 0; 
C_low = Convexity;
C_old = Convexity;
b2_hi = [];
C_hi = [];

iter = 2; % Current iteration count
b2 = 0.4; % New b2 value - relatively large in the hope to ge C > -6 and establish a bound

while iter < MaxIter
    
    [tmp_EMs, tmp_Abunds, Xprime] = HALS_NMF(X, k, 5e3, 10, [5, 0, 0, b2], 0);
    Convexity = GetConvexityError(X, tmp_EMs);
    
    % Get the convexity change - use this check for
    % non-monotonic increase
    dC = Convexity - C_old;
    
    
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
        % our latest estimate is high
        % Compare with existing upper bounds and check it is moving in the right
        % direction
        if Convexity < C_hi  || dC >= 0
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
    C_old = Convexity;
    
end % end of the while loop

