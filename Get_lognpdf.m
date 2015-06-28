function y = Get_lognpdf(x, mu, sigma)
%
% Function to generate the probability density function (PDF) of a
% lognormal distribution.
%
% Inputs: 
%        x - x points to evaluate the PDF
%        mu - parameter controlling the mean of the underlying normal distribtuion
%        sigma - parameter controlling the standard deviation of the underlying normal distribution
%
%        Default values are for the standard normal distribution
%        mu = 0, sigma = 1
%
% Outputs:
%        y - the PDF evaluated at the points in x
%
%
% Written by Greig A. Paterson
%
% Updated: 17 April, 2015

%% Check inputs
if nargin<1
    error('Get_lognpdf:TooFewInputs', 'At least 1 inputs are required');
end
if nargin < 2
    mu = 0;
end
if nargin < 3
    sigma = 1;
end


% Check the parameter ranges and set to NaN to return null values
% Could also throw back an error
sigma(sigma <= 0) = NaN;

x(x <= 0 ) = NaN; % Avoid negative x values

%% Get the PDF

try
    y = exp(-0.5 * ((log(x) - mu)./sigma).^2) ./ (x .* sqrt(2*pi) .* sigma);
    
    % Set NaNs to zero - These are usually casued by one of the
    % exponentials being inf or -inf
    y(isnan(y)) = 0;
    
catch
    error('Get_lognpdf:Input', 'Input error, check the input sizes.');
end

