function Plot_BoxWhisker(Axis_Handles, data, UL_Flag)
%
% Function to plot a box and whisker diagram for end member selection
%
% Input:
%      Axis_Hanldes -  the axis handle to plot on
%      data -  the data to plot
%      UL_Flag - signifies if upper ('U') or lower ('L') percentile limits
%      are to be used
%

if nargin < 2
    error('Plot_BoxWhisker:Input', 'At least two input arguments are required.')
end

if nargin < 3
    UL_Flag = 'U';
end

width = 0.1;
lineWidth = 1;

m = size(data,1);
CDF = (0:m-1)./(m-1);
pvals = [0.05 0.25, 0.5, 0.75, 0.95];
nPvals = length(pvals);

n = size(data, 2);

draw_data = NaN(nPvals,n);
OL = cell(n, 1);

for ii = 1:n
    
    tmp_data = sort(data(:,ii), 1);
    
    if any(isnan(tmp_data))
        OL(ii) = {NaN};
    else
        
        for jj= 1:nPvals
            inds = [find(CDF < pvals(jj), 1, 'last'), find(CDF > pvals(jj), 1, 'first')];
            draw_data(jj,ii) = interp1(CDF(inds), tmp_data(inds), pvals(jj));
        end
        
        if strcmpi(UL_Flag, 'U')
            OL(ii) = {data(data(:,ii) > draw_data(5,ii), ii)};
        else
            OL(ii) = {data(data(:,ii )< draw_data(1,ii), ii)};
        end
    end
    
end

n = size(draw_data, 2);

unit = (1-1/(1+n))/(1+9/(width+3));

hold(Axis_Handles, 'on')

for ii = 1:n
    
    Line = draw_data(:,ii);
    
    if strcmpi(UL_Flag, 'U')
        % Draw the min line
        plot(Axis_Handles, [ii-unit, ii+unit], [Line(5), Line(5)], '-b', 'LineWidth', lineWidth);
        % Draw vertical lines
        plot(Axis_Handles, [ii, ii], [Line(5), Line(4)], '-b', 'LineWidth', lineWidth);
    else
        % Draw the max line
        plot(Axis_Handles, [ii-unit, ii+unit], [Line(1), Line(1)], '-b', 'LineWidth', lineWidth);
        % Draw vertical lines
        plot(Axis_Handles, [ii, ii], [Line(2), Line(1)], '-b', 'LineWidth', lineWidth);

    end
    
    % Draw middle line
    plot(Axis_Handles, [ii-unit, ii+unit], [Line(3), Line(3)], '-r', 'LineWidth', lineWidth);
    
    % Draw box
    plot(Axis_Handles, [ii-unit, ii+unit, ii+unit, ii-unit, ii-unit], [Line(2), Line(2), Line(4), Line(4), Line(2)], '-b', 'LineWidth', lineWidth);
    
    % Draw the outliers
    plot(Axis_Handles, ii, OL{ii}, 'xr');
    
end;

hold(Axis_Handles, 'off')

