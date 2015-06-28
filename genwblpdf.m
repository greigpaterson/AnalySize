function y=genwblpdf(x, A, B, mu)
%
% Function to generate the probability density function (PDF) of a
% Generalized Weibull distribution.
%
% Inputs: 
%        x - x points to evaluate the PDF
%        A - Scale parameter
%        B - Shape parameter
%        mu - location parameter
%
%        Default values are for the standard Weibul distribution
%        mu = 0
%
% Outputs:
%        y - the PDF evaluated at the points in x
%
%
% Written by Greig A. Paterson
%
% Updated: 17 Apr., 2015

%% Check inputs
if nargin<3
    error(message('genwblpdf:TooFewInputs'));
end
if nargin < 4
    mu = 0;
end

% Return NaN for out of range parameters.
A(A <= 0) = NaN;
B(B <= 0) = NaN;


try % catch mis-sized data
    z = (x - mu) ./ A;
    w = exp(-(z.^B));
catch
    error('genwblpdf:Input', 'Input error, check the input sizes.');
end

y = B./A .* z.^(B-1) .* w;

% Force zeros for x values outside of the distributions range
y(x <= mu) = 0;

% Set NaNs to zero - These are usually casued by one of the inputs being
% out of range
y(isnan(y)) = 0;
y(isinf(y)) = 0;

