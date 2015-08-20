function varargout = Select_EndMembers(varargin)
% SELECT_ENDMEMBERS MATLAB code for Select_EndMembers.fig
%      SELECT_ENDMEMBERS, by itself, creates a new SELECT_ENDMEMBERS or raises the existing
%      singleton*.
%
%      H = SELECT_ENDMEMBERS returns the handle to a new SELECT_ENDMEMBERS or the handle to
%      the existing singleton*.
%
%      SELECT_ENDMEMBERS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECT_ENDMEMBERS.M with the given input arguments.
%
%      SELECT_ENDMEMBERS('Property','Value',...) creates a new SELECT_ENDMEMBERS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Select_EndMembers_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Select_EndMembers_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Select_EndMembers

% Last Modified by GUIDE v2.5 19-May-2015 14:19:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Select_EndMembers_OpeningFcn, ...
    'gui_OutputFcn',  @Select_EndMembers_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Select_EndMembers is made visible.
function Select_EndMembers_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Select_EndMembers (see VARARGIN)

% Choose default command line output for Select_EndMembers
handles.output = hObject;

dontOpen = false;
DataTransfer = find(strcmp(varargin, 'DataTransfer'));
if (isempty(DataTransfer)) ...
        || (length(varargin) <= DataTransfer)
    dontOpen = true;
else
    DataTransfer = varargin{DataTransfer+1};
end

% Get the main window
try
    MainWindow = findall(0,'type','figure', 'name', 'AnalySize');
    parentPosition = get(MainWindow, 'Position');
catch
    error('Select_EndMember:MainWind', 'The Analysize main window cannot be found');
end

% Position to be relative to parent:
currentPosition = get(hObject, 'Position');
newX = parentPosition(1) + (parentPosition(3)/2 - currentPosition(3)/2);
newY = parentPosition(2) + (parentPosition(4)/2 - currentPosition(4)/2);
newW = currentPosition(3);
newH = currentPosition(4);
set(hObject, 'Position', [newX, newY, newW, newH]);

% Get the data from previous window
handles.DataSet_R2 = DataTransfer.DataSet_R2;
handles.Spec_R2 = DataTransfer.Spec_R2;
handles.DataSet_Angle = DataTransfer.DataSet_Angle;
handles.Spec_Angle = DataTransfer.Spec_Angle;
handles.EM_Max = DataTransfer.EM_Max;
handles.EM_Min = DataTransfer.EM_Min;
handles.EM_R2 = DataTransfer.EM_R2;

handles.Version = getappdata(MainWindow, 'Version');

% Update handles structure
guidata(hObject, handles);

% Update the plots
FUnits = 'Pixels';
FontSize1 = 12;
FontSize2 = 14;
FontSize3 = 12;

% Scale the legend font size for different systems
DPI = getappdata(MainWindow, 'DPI');
if DPI > 72
    FontSize3 = FontSize3 * 72 / DPI;
end

plot(handles.Var_Axes, handles.DataSet_R2, '-ok', 'LineWidth', 2)
hold(handles.Var_Axes, 'on')
if ~isempty(handles.EM_R2)
    plot(handles.Var_Axes, handles.EM_R2, '--^', 'LineWidth', 2, 'Color', [0.6, 0.6, 0.6])
    set(handles.Label_EM_R2, 'Visible', 'on')
    set(handles.Text_EM_R2, 'Visible', 'on')
end
plot(handles.Var_Axes, 0, 0, '-r')
plot(handles.Var_Axes, 0, 0, '-xb', 'MarkerEdgeColor', [1,0,0])
hold(handles.Var_Axes, 'off')
Plot_BoxWhisker(handles.Var_Axes, handles.Spec_R2, 'L')

set(handles.Var_Axes, 'Xlim', [0, handles.EM_Max+1], 'YLim', [0.3, 1.01]);
if ~isempty(handles.EM_R2)
    hleg = legend(handles.Var_Axes, 'Data set', 'EM correlation', 'Specimen median', 'Specimen box & whisker', 'Location', 'SouthEast');
else
    hleg = legend(handles.Var_Axes, 'Data set', 'Specimen median', 'Specimen box & whisker', 'Location', 'SouthEast');
end
set(hleg, 'FontUnits', FUnits, 'FontSize', FontSize3);

set(get(handles.Var_Axes, 'XLabel'), 'String', 'Number of end members', 'FontUnits', FUnits, 'FontSize', FontSize1);
set(get(handles.Var_Axes, 'YLabel'), 'String', 'R^2', 'FontUnits', FUnits, 'FontSize', FontSize1);
set(get(handles.Var_Axes, 'Title'), 'String', 'Linear Correlations', 'FontUnits', FUnits, 'FontSize', FontSize2);


% Update the angular dev plot
plot(handles.Angle_Axes, handles.DataSet_Angle, '-ok', 'LineWidth', 2)
hold(handles.Angle_Axes, 'on')
plot(handles.Angle_Axes, -1, 0, '-r')
plot(handles.Angle_Axes, -1, 0, '-xb', 'MarkerEdgeColor', [1,0,0])
hold(handles.Angle_Axes, 'off')
Plot_BoxWhisker(handles.Angle_Axes, handles.Spec_Angle, 'U')

set(handles.Angle_Axes, 'Xlim', [0, handles.EM_Max+1], 'YLim', [0, 15]);
hleg = legend(handles.Angle_Axes, 'Mean Angle', 'Specimen median', 'Specimen box & whisker', 'Location', 'NorthEast');
set(hleg, 'FontUnits', FUnits, 'FontSize', FontSize3);

set(get(handles.Angle_Axes, 'XLabel'), 'String', 'Number of end members', 'FontUnits', FUnits, 'FontSize', FontSize1);
set(get(handles.Angle_Axes, 'YLabel'), 'String', 'Angle (degrees)', 'FontUnits', FUnits, 'FontSize', FontSize1);
set(get(handles.Angle_Axes, 'Title'), 'String', 'Angular Deviation', 'FontUnits', FUnits, 'FontSize', FontSize2);


% update the default selection and labels
set(handles.Selected_EM, 'Value', handles.EM_Min, 'String', sprintf('%d', handles.EM_Min));
Set_Var_Levels(handles);

guidata(hObject,handles);

if dontOpen
    disp('------------------------------------------');
    disp('If you see this, something has gone wrong.')
    disp('      Please contact Greig Paterson       ')
    disp('------------------------------------------');
    
else
    % Set the uiwait
    uiwait(handles.Select_EM_Figure);
end


% --- Outputs from this function are returned to the command line.
function varargout = Select_EndMembers_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

delete(hObject);


% --- Executes when user attempts to close Select_EM_Figure.
function Select_EM_Figure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to Select_EM_Figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set the output and resume
Return.Cancel_Flag = 1;
Return.EM = [];
handles.output = Return;

guidata(hObject,handles);

uiresume(handles.Select_EM_Figure);


% --- Executes on button press in Cancel.
function Cancel_Callback(hObject, eventdata, handles)
% hObject    handle to Cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set the output and resume
Return.Cancel_Flag = 1;
Return.EM = [];
handles.output = Return;

guidata(hObject,handles);

uiresume(handles.Select_EM_Figure);


% --- Executes on button press in OK.
function OK_Callback(hObject, eventdata, handles)
% hObject    handle to OK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set the output and resume
Return.Cancel_Flag = 0;
Return.EM = get(handles.Selected_EM, 'Value');
handles.output = Return;

guidata(hObject,handles);

uiresume(handles.Select_EM_Figure);


% --- Executes on button press in EM_Select_Plus.
function EM_Select_Callback(hObject, eventdata, handles, str)
% hObject    handle to EM_Select_Plus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get the index pointer and the addresses

index = get(handles.Selected_EM, 'Value');

% Depending on whether Prev or Next was clicked change the display
switch str
    case 'Minus'
        % Decrease the index by one
        ind = index - 1;
        % If the index is less then one then set it the number of specimens
        % (Nspec)
        if ind < handles.EM_Min
            ind = handles.EM_Max;
        end
    case 'Plus'
        % Increase the index by one
        ind = index + 1;
        
        % If the index is greater than the snumber of specimens set index
        % to 1
        if ind > handles.EM_Max
            ind = handles.EM_Min;
        end
end

% Set the counter
set(handles.Selected_EM, 'Value', ind, 'String', sprintf('%d', ind));

% Set the descriptions
guidata(hObject,handles);

Set_Var_Levels(handles);

guidata(hObject,handles);


function Set_Var_Levels(handles)

ind = get(handles.Selected_EM, 'Value');

% keyboard

% Get the values for the 2.5 and 97.5 percentiles
nData = size(handles.Spec_R2,1);
CDF = (0:nData-1)./(nData-1);
i95 = [find(CDF < 0.95, 1, 'last'), find(CDF > 0.95, 1, 'first')];

tmp_sorted = 100.*sort(handles.Spec_R2(:,ind), 'descend');
R95 = interp1(CDF(i95), tmp_sorted(i95), 0.95);

tmp_sorted = sort(handles.Spec_Angle(:,ind), 'ascend');
A95 = interp1(CDF(i95), tmp_sorted(i95), 0.95);

% keyboard

set(handles.Label_EM, 'String', sprintf('%d', ind) );
set(handles.Label_Var1, 'String', sprintf('%3.1f', 100.*handles.DataSet_R2(ind)) );
set(handles.Label_Var2, 'String', sprintf('%3.1f', median(100.*handles.Spec_R2(:,ind)) ) );
set(handles.Label_Var3, 'String', sprintf('%3.1f', R95 ) );

set(handles.Label_Ang1, 'String', sprintf('%3.1f', handles.DataSet_Angle(ind)) );
set(handles.Label_Ang2, 'String', sprintf('%3.1f', median(handles.Spec_Angle(:,ind)) ) );
set(handles.Label_Ang3, 'String', sprintf('%3.1f', A95 ) );

if ~isempty(handles.EM_R2)
    set(handles.Label_EM_R2, 'String', sprintf('%3.3f', handles.EM_R2(ind)));
end


% --- Executes on button press in Save_Plot.
function Save_Plot_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uiputfile('Quality_of_Fit_Plots.eps','Save the variance plot...');

if ~ischar(file) && file==0
    % User has cancelled
    % Do nothing and...
    return;
end


tmpFig=figure('Visible', 'off', 'Units', 'Centimeters','PaperPositionMode','auto');
oldPos=get(tmpFig, 'Position');
set(tmpFig, 'Position', [oldPos(1), oldPos(2), 18, 7.5]);
%% Do the first axes
newAxes=copyobj(handles.Var_Axes, tmpFig);
axis(newAxes, 'square');

PlotSize = 4.5;

% Adjust the figure
set(newAxes, 'FontUnits', 'Points', 'FontSize', 9, 'Units', 'Centimeters')
set(get(newAxes, 'XLabel'), 'FontUnits', 'Points', 'FontSize', 10)
set(get(newAxes, 'YLabel'), 'FontUnits', 'Points', 'FontSize', 10);
set(get(newAxes, 'Title'), 'FontUnits', 'Points', 'FontSize', 11);
% Adjust size
NewPos = [1.5, 1.5, PlotSize, PlotSize];
set(newAxes, 'Position', NewPos, 'XColor', [1,1,1], 'YColor', [1,1,1], 'Box', 'off', 'TickDir', 'Out');

% Place a new set of axes on top to create the box
h0 = axes('Units', 'Centimeters', 'Position', NewPos);
set(h0, 'box', 'on', 'XTick', [], 'YTick', [], 'color', 'none');

A1P1 = NewPos(1);

% Reset the line widths
C = get(newAxes, 'Children');
for ii = 1: length(C);
    set(C(ii),'LineWidth',1);
end

% Do legend
hleg1 = legend(newAxes, 'Data set', 'EM correlation', 'Specimen median', 'Specimen box & whisker', 'Location', 'SouthEast');
set(hleg1, 'FontUnits', 'Points', 'FontSize', 7, 'Box', 'on', 'XColor', 'white', 'YColor', 'white', 'color', 'white',...
    'Units', 'Centimeters', 'Position', [12.5, 4, 4, 1.5]);

% Do a MATLAB version check
if handles.Version < 8.4
    
    LegLines = findobj(hleg1, 'type','line');
    XD = get(LegLines(2),'XData');
    LineLen = (2/3) * (XD(2) - XD(1));
    MidPoint = (1/2) * (XD(2) - XD(1));
    
    set(LegLines(2:2:end),'XData', [XD(1), XD(1) + LineLen]);
    set(LegLines,'MarkerSize', 5);
    set(LegLines(1:2:end),'XData', MidPoint);
    
    LegText = findobj(hleg1, 'type','text');
    PosData = cell2mat(get(LegText, 'Position'));
    Short = (XD(2) - XD(1)) - LineLen;
    for ii = 1:size(PosData,1)
        PD = PosData(ii,:);
        PD(1) = PD(1) - Short;
        set(LegText(ii), 'Position', PD);
    end
end


%% Do the second axes
newAxes2=copyobj(handles.Angle_Axes, tmpFig);
axis(newAxes2, 'square')

% Adjust the figure
set(newAxes2, 'FontUnits', 'Points', 'FontSize', 9, 'Units', 'Centimeters')
set(get(newAxes2, 'XLabel'), 'FontUnits', 'Points', 'FontSize', 10)
set(get(newAxes2, 'YLabel'), 'FontUnits', 'Points', 'FontSize', 10);
set(get(newAxes2, 'Title'), 'FontUnits', 'Points', 'FontSize', 11);

NewPos = [A1P1 + PlotSize+1.5, 1.5, PlotSize, PlotSize];
set(newAxes2, 'Position', NewPos, 'XColor', [1,1,1], 'YColor', [1,1,1], 'Box', 'off', 'TickDir', 'Out');

% Place a new set of axes on top to create the box
h0 = axes('Units', 'Centimeters', 'Position', NewPos);
set(h0, 'box', 'on', 'XTick', [], 'YTick', [], 'color', 'none');


% Reset the line widths
C = get(newAxes2, 'Children');
for ii = 1: length(C);
    set(C(ii),'LineWidth',1);
end


print(tmpFig, '-depsc', strcat(path, file));
close(tmpFig);


% --- Executes on button press in DB_Me.
function DB_Me_Callback(hObject, eventdata, handles)
% hObject    handle to DB_Me (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
keyboard
