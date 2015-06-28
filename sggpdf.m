function [y] = sggpdf(x, mu, sigma, q, p)
%
% Function to generate the probability density function (PDF) of a Skewed
% Generalized Gaussian (SGG) distribution [1].
%
% Inputs: 
%        x - x points to evaluate the PDF
%        mu - parameter controlling the mean of the distribtuion
%        sigma - parameter controlling the standard deviation of the distribution
%        q - parameter controlling the skewness of the distribtuion
%        p - parameter controlling the kurtosis of the distribtuion
%
%        Default values are for the standard normal distribution
%        mu = 0, sigma = 1, q = 1, p = 2
%
% Outputs:
%        y - the PDF evaluated at the points in x
%
% References:
%
% [1] Egli, R. (2003), Analysis of the field dependence of remanent 
%     magnetization curves, J. Geophys. Res., 108, 2081, doi:
%     10.1029/2002JB002023.
%
%
% Written by Greig A. Paterson
%
% Updated: 17 Apr., 2015

%% Check inputs
if nargin<1
    error('sggpdf:TooFewInputs', 'At least 2 inputs are required');
end
if nargin < 2
    mu = 0;
end
if nargin < 3
    sigma = 1;
end
if nargin < 4
    q = 1;
end
if nargin < 5
    p = 2;
end

% Check the parameter ranges and set to NaN to return null values
% Could also throw back an error

% mu is infinite bound so no check

% Return NaN for out of range parameters.
sigma(sigma <= 0) = NaN;

% 0 < |q| <= 1
q(abs(q) <= 0 || abs(q) > 1) = NaN;

% p > 0
p(p <= 0) = NaN;

%% Get the PDF

try
    x_star = (x - mu)./sigma;
    
    y =  ( 1 ./ ( (2.^(1+1./p)) .* sigma .* gamma(1 + 1/p) ) )...
        .* ( abs( q.*exp(q.*x_star) + exp(x_star./q)./q ) ./ ( exp(q.*x_star) + exp(x_star./q) ) )...
        .* exp( -0.5 .* abs( log( 0.5 .* (exp(q.*x_star) + exp(x_star./q) ) ) ).^p );
    
    % Set NaNs to zero - These are usually casued by one of the
    % exponentials being inf or -inf, or resetting of q and p
    y(isnan(y)) = 0;
    
catch
    error('sggpdf:Input', 'Input error, check the input sizes.');
end


