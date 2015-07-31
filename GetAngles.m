function Theta = GetAngles(V1, V2)
%
% Get the angles between the data (V1) and the fitted result (V2)
%
% Inputs: 
%       V1 - the data matrix (nData x nVar)
%       V2 - the reconstructed matrix (nData x nVar)
%
%       V1 and V2 can also be row vectors
%
% Outputs:
%       Theta - (nData x 1) vector of the angles between each row of V1 and V2
%

if nargin ~=2
    error('GetAngles:Input', 'Two inputs are rquired.');
end

if ~isequal(size(V1), size(V2))
    error('GetAngles:InputSize', 'Inputs must have the same size.');
end


if size(V1,2) == 1
    % column vector - should be row vector
    V1 = V1';
    V2 = V2';
end

Theta = rad2deg(acos((sum(V1.*V2,2)./sqrt(sum(V1.^2,2).*sum((V2).^2, 2)))));

