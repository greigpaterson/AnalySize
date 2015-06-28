function y = Get_gevpdf(x, mu, sigma, eta)
%
% Function to generate the probability density function (PDF) of a
% generalized extreme value (GEV) distribution.
%
% Inputs:
%        x - x points to evaluate the PDF
%        mu - location parameter
%        sigma - scale parameter
%        eta - shape parameter
%
%        Default values are for the standard Gumbel distribution
%        mu = 0, sigma = 1, eta = 0
%
% Outputs:
%        y - the PDF evaluated at the points in x
%
%
% Written by Greig A. Paterson
%
% Updated: 20 April, 2015


%% Check inputs
if nargin < 1
    error('Get_gevpdf:TooFewInputs', 'At least 1 inputs are required');
end
if nargin < 2
    mu = 0;
end
if nargin < 3
    sigma = 1;
end
if nargin < 4
    eta = 0;
end

if ~any(size(x)==1)
    error('Get_gevpdf:Input', 'Input x must be a column vector.');
end

if ~isscalar(mu) || ~isscalar(sigma) || ~isscalar(eta)
    error('Get_gevpdf:Input', 'Input parameters must be scalars.');
end

% expand the inputs to vectors
mu = repmat(mu, size(x,1),1);
sigma = repmat(sigma, size(x,1),1);
eta = repmat(eta, size(x,1),1);


% Check the parameter ranges and set to NaN to return null values
% [Could also throw back an error]
sigma(sigma <= 0) = NaN;

y = zeros(size(x));

try
    
    % Deal with the zero eta values
    inds = abs(eta) < eps;
    
    z = (x-mu)./sigma;
    y(inds) = exp(-exp(-z(inds)) - z(inds));
    
    
    % The non-zero eta cases
    t = z.*eta;
    
    inds = ~inds;    
    y(inds) =(1 + t(inds)).^( (-1./eta(inds))-1) .* exp( -(1+t(inds)).^(-1./eta(inds)) );
    
    
    % Check for the supported range    
    lim = mu - sigma./eta;
    
    if eta > 0
        y(x < lim) = 0;
    elseif eta < 0
         y(x > lim) = 0;
    end
    
    y = y./sigma;
    
    % Set NaNs to zero - These are usually casued by one of the inputs being
    % out of range
    y(isnan(y)) = 0;
    y(isinf(y)) = 0;

    
catch
    error('Get_gevpdf:Input', 'Input error, check the input sizes.');
end



