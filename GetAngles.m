function [theta, Mtheta] = GetAngles(V1, V2)
%
% Get the angles between the data (V1) and the fitted result (V2)
%
% Inputs: 
%       V1 - the data matrix (nData x nVar)
%       V2 - the reconstructed matrix (nData x nVar)
%
% Outputs:
%       theta - (nData x 1) vector of the angles between each row of V1 and V2
%       Mtheta - the mean angle between V1 and V2
%

theta = rad2deg(acos((sum(V1.*V2,2)./sqrt(sum(V1.^2,2).*sum((V2).^2, 2)))));

Mtheta = rad2deg(acos(mean((sum(V1.*V2,2)./sqrt(sum(V1.^2,2).*sum((V2).^2, 2))))));

