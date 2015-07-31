function [Abunds, EMs, Fit_Quality] = GetDefinedFit(Xin, GS, EM_in)
%
% Function that returns the parametric endmember fit
%
% Input:
%       Xin - nData x nVar matrix containing the observed data
%       GS - nVar x 1 vector of data bins
%       EM_in - nData x nEnd+1 matrix of the pre-defined end members to fit
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
[~,nVar] = size(X);

EM_GS = EM_in(:,1);
Input_EMs = EM_in(:,2:end)';
Input_EMs = Input_EMs./repmat(sum(Input_EMs,2), 1, size(Input_EMs,2)); % sum-to-one
k = size(Input_EMs, 1);


%% Regularize the data
% Interpolate the end members to the grain size bins used for the observed
% data
EMs = NaN(k, nVar);
for ii = 1:k
    EMs(ii,:) = interp1(EM_GS, Input_EMs(ii,:), GS, 'linear', 0)';
end


%% Unmix and get the fit qualities

[Abunds, Xprime] = Get_FCLS(X, EMs);

R2 = GetR2(Xprime(:), X(:));
Spec_R2 = GetR2(X', Xprime')';
DataSet_Angle = GetAngles(X(:), Xprime(:));
Spec_Angle  = GetAngles(X, Xprime);


Fit_Quality = {[R2, DataSet_Angle], [Spec_R2, Spec_Angle]};
