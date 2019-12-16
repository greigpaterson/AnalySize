function Plot_BoxWhisker(Axis_Handles, data, UL_Flag, C1, C2, C3, Msymbol, Msize, Mfill)
%
% Function to plot a box and whisker diagram for end member selection
%
% Input:
%      Axis_Hanldes -  the axis handle to plot on
%      data -  the data to plot
%      UL_Flag - signifies if upper ('U'), lower ('L'), or both ('B')
%                percentile limits are to be used
%      C1 - color of the box and whiskers [1x3] RGB vector
%      C2 - color of the median [1x3] RGB vector
%      C3 - color of the outliers [1,3] RGB vector
%      Msymbol - the symbol for the outliers (see doc plot for more details)
%      Mize - the outliers marker size
%      Mfill - the outliers marker fill color (either 'none', or [1x3] RGB
%              vector)
%

%% Input checks
if nargin < 2
    error('Plot_BoxWhisker:Input', 'At least two input arguments are required.')
end

if nargin < 3
    UL_Flag = 'U';
    C1 = [0,0,1];
    C2 = [1,0,0];
    C3 = C2;
    Msymbol = 'x';
    Msize = 6;
    Mfill = 'none';
end

if nargin < 4
    C1 = [0,0,1];
    C2 = [1,0,0];
    C3 = C2;
    Msymbol = 'x';
    Msize = 6;
    Mfill = 'none';
end

if nargin < 5
    C2 = [1,0,0];
    C3 = C2;
    Msymbol = 'x';
    Msize = 6;
    Mfill = 'none';
end

if nargin < 6
    C3 = C2;
    Msymbol = 'x';
    Msize = 6;
    Mfill = 'none';
end

if nargin < 7
    Msymbol = 'x';
    Msize = 6;
    Mfill = 'none';
end

if nargin < 8
    Msize = 6;
    Mfill = 'none';
end

if nargin < 9
    Mfill = 'none';
end

%% Set up the plot

width = 0.1;
LineWidth = 1;

m = size(data,1);
% CDF = (0:m-1)./(m-1);
pvals = [0.025, 0.05, 0.25, 0.5, 0.75, 0.95, 0.975];
nPvals = length(pvals);

n = size(data, 2);

m = NaN(n, 1); % The number of data per bin
draw_data = NaN(nPvals,n); % The matrix for the lines
OL = cell(n, 1); % The cell to contain the outliers

for ii = 1:n
    
    if iscell(data)
        tmp_data = data{ii};
        tmp_data = sort(tmp_data, 1);
        
        m(ii) = length(tmp_data);
        CDF = (0:m(ii)-1)./(m(ii)-1);
        
    else
        tmp_data = sort(data(:,ii), 1);
        
        m(ii) = length(tmp_data);
        CDF = (0:m(ii)-1)./(m(ii)-1);
        
    end
    
    % Skip bins with no data
    if m(ii) == 0
        continue
    end
    
    if any(isnan(tmp_data))
        OL(ii) = {NaN};
    else
        
        for jj= 1:nPvals
            
            if m(ii) > 1
                inds = [find(CDF < pvals(jj), 1, 'last'), find(CDF > pvals(jj), 1, 'first')];
                draw_data(jj,ii) = interp1(CDF(inds), tmp_data(inds), pvals(jj));
            else
                % For
                draw_data(jj,ii) = tmp_data;
            end
        end
        
        if strcmpi(UL_Flag, 'U')
            OL(ii) = {tmp_data(tmp_data > draw_data(6,ii))};
            %             OL(ii) = {data(data(:,ii) > draw_data(6,ii), ii)};
            
        elseif strcmpi(UL_Flag, 'L')
            OL(ii) = {tmp_data(tmp_data < draw_data(2,ii))};
            %             OL(ii) = {data(data(:,ii )< draw_data(2,ii), ii)};
            
        else
            OL(ii) = {[tmp_data(tmp_data < draw_data(1,ii))', tmp_data(tmp_data > draw_data(7,ii))']};
            %             OL(ii) = {[data(data(:,ii )< draw_data(1,ii), ii), data(data(:,ii) > draw_data(7,ii), ii)]};
        end
    end
    
end

n = size(draw_data, 2);

unit = (1-1/(1+n))/(1+9/(width+3));

hold(Axis_Handles, 'on')

for ii = 1:n
    
    Line = draw_data(:,ii);
    
    % Skip bins with no data
    if sum(isnan(Line)) == length(Line)
        continue
    end
    
    if m(ii) >= 5
        if strcmpi(UL_Flag, 'U') % Draw upper limit percentiles
            % Draw the max line
            plot(Axis_Handles, [ii-unit, ii+unit], [Line(6), Line(6)], '-', 'Color', C1, 'LineWidth', LineWidth);
            % Draw vertical lines
            plot(Axis_Handles, [ii, ii], [Line(6), Line(5)], '-', 'Color', C1, 'LineWidth', LineWidth);
            
        elseif strcmpi(UL_Flag, 'L') % Draw lower limit percentiles
            % Draw the min line
            plot(Axis_Handles, [ii-unit, ii+unit], [Line(2), Line(2)], '-', 'Color', C1, 'LineWidth', LineWidth);
            % Draw vertical lines
            plot(Axis_Handles, [ii, ii], [Line(3), Line(2)], '-', 'Color', C1, 'LineWidth', LineWidth);
            
        else % Draw upper and lower percentiles
            
            % Draw the min line
            plot(Axis_Handles, [ii-unit, ii+unit], [Line(1), Line(1)], '-', 'Color', C1, 'LineWidth', LineWidth);
            % Draw vertical lines
            plot(Axis_Handles, [ii, ii], [Line(3), Line(1)], '-', 'Color', C1, 'LineWidth', LineWidth);
            
            % Draw the max line
            plot(Axis_Handles, [ii-unit, ii+unit], [Line(7), Line(7)], '-', 'Color', C1, 'LineWidth', LineWidth);
            % Draw vertical lines
            plot(Axis_Handles, [ii, ii], [Line(5), Line(7)], '-', 'Color', C1, 'LineWidth', LineWidth);
            
        end
        
        
        % Draw box
        plot(Axis_Handles, [ii-unit, ii+unit, ii+unit, ii-unit, ii-unit], [Line(3), Line(3), Line(5), Line(5), Line(3)], '-', 'Color', C1, 'LineWidth', LineWidth);
        
        % Draw the outliers
        if ~isempty(OL{ii})
            plot(Axis_Handles, ii, OL{ii}, 'Marker', Msymbol, 'Color', C3, 'LineWidth', LineWidth, 'MarkerSize', Msize, 'MarkerFaceColor', Mfill);
        end
        
        % Draw median line
        plot(Axis_Handles, [ii-unit, ii+unit], [Line(4), Line(4)], '-', 'Color', C2, 'LineWidth', LineWidth);
        
    else
        
        if iscell(data)
            tmp_data = data{ii};
        else
            tmp_data = sort(data(:,ii), 1);
        end
        
        if ~isempty(tmp_data)
            plot(Axis_Handles, ii, tmp_data, 'Marker', Msymbol, 'Color', C3, 'LineWidth', LineWidth, 'MarkerSize', Msize, 'MarkerFaceColor', Mfill);
        end
        
    end
    
end

hold(Axis_Handles, 'off')

