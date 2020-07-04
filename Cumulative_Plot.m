function varargout = Cumulative_Plot(varargin)
% CUMULATIVE_PLOT MATLAB code for Cumulative_Plot.fig
%      CUMULATIVE_PLOT, by itself, creates a new CUMULATIVE_PLOT or raises the existing
%      singleton*.
%
%      H = CUMULATIVE_PLOT returns the handle to a new CUMULATIVE_PLOT or the handle to
%      the existing singleton*.
%
%      CUMULATIVE_PLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CUMULATIVE_PLOT.M with the given input arguments.
%
%      CUMULATIVE_PLOT('Property','Value',...) creates a new CUMULATIVE_PLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Cumulative_Plot_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Cumulative_Plot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Cumulative_Plot

% Last Modified by GUIDE v2.5 24-Feb-2020 11:41:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Cumulative_Plot_OpeningFcn, ...
    'gui_OutputFcn',  @Cumulative_Plot_OutputFcn, ...
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


% --- Executes just before Cumulative_Plot is made visible.
function Cumulative_Plot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Cumulative_Plot (see VARARGIN)

% Choose default command line output for Cumulative_Plot
handles.output = hObject;

DataTransfer = find(strcmp(varargin, 'DataTransfer'));
if (isempty(DataTransfer)) ...
        || (length(varargin) <= DataTransfer)% ...
    
    disp('------------------------------------------');
    disp('If you see this, something has gone wrong.')
    disp('      Please contact Greig Paterson       ')
    disp('------------------------------------------');
    
else
    DataTransfer = varargin{DataTransfer+1};
    handles.MainWindow = varargin{3};
    handles.Defaults = getappdata(varargin{3}, 'Defaults');
end

% Position to be relative to parent:
parentPosition = get(handles.MainWindow, 'Position'); %getpixelposition(handles.MainWindow)
currentPosition = get(hObject, 'Position');
% Set x and y to be directly in the middle
newX = parentPosition(1) + (parentPosition(3)/2 - currentPosition(3)/2);
newY = parentPosition(2) + (parentPosition(4)/2 - currentPosition(4)/2);
newW = currentPosition(3);
newH = currentPosition(4);
set(hObject, 'Position', [newX, newY, newW, newH]);

% Get the version
Ver = ver('MATLAB');
handles.Version = str2double(Ver.Version);

% Get the data from previous window
handles.Data = DataTransfer.Data;
handles.GS = DataTransfer.GS;
handles.LGS = log(handles.GS);
handles.Phi = DataTransfer.Phi;
handles.All_Names = DataTransfer.Names;
handles.nData = size(handles.Data, 1);

% Set the logic for the table check boxes
handles.Table_Logic = ones(handles.nData, 1);

% Set the table
set(handles.Spec_Table, 'Data', [num2cell(logical(handles.Table_Logic)), handles.All_Names]);

% Set the current data to all the data and then plot
handles.Current_Data = handles.Data;
Update_Plots(handles);

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = Cumulative_Plot_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in Plot_Type.
function Plot_Type_Callback(hObject, eventdata, handles)
% hObject    handle to Plot_Type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Plot_Type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Plot_Type

Update_Plots(handles);

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Plot_Type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Plot_Type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Save_Plot.
function Save_Plot_Callback(hObject, eventdata, handles)
% hObject    handle to Save_Plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uiputfile('Multiple_Specimen_Plot.eps','Save the specimen plot...');

if ~ischar(file) && file==0
    % User has cancelled
    % Do nothing and...
    return;
end

tmpFig=figure('Visible', 'off', 'Units', 'Centimeters');
oldPos=get(tmpFig, 'Position');
set(tmpFig, 'Position', [oldPos(1), oldPos(2), 7.5, 7.5]); % make the figure bigger than needed (300x300)

% Copy and adjust the axes
newAxes=copyobj(handles.Plot_Axes, tmpFig);
set(newAxes, 'Units', 'Centimeters');
axis(newAxes, 'square');
set(newAxes, 'FontUnits', 'Points', 'FontSize', 9)
set(get(newAxes, 'XLabel'), 'FontUnits', 'Points', 'FontSize', 10)
set(get(newAxes, 'YLabel'), 'FontUnits', 'Points', 'FontSize', 10);
set(get(newAxes, 'Title'), 'FontUnits', 'Points', 'FontSize', 11);

% Readjust the x-axis scale and tickmarks
set(newAxes, 'Xlim', get(handles.Plot_Axes, 'Xlim'))
set(newAxes, 'XTick', get(handles.Plot_Axes, 'XTick'))
set(newAxes, 'XTickLabel', get(handles.Plot_Axes, 'XTickLabel'))


NewPos = [1.5, 1.5, 4.5, 4.5];
set(newAxes, 'Position', NewPos, 'XColor', [1,1,1], 'YColor', [1,1,1], 'Box', 'off', 'TickDir', 'Out');

% Place a new set of axes on top to create the box
if handles.Version <= 8.3 % 2014a and before
    h0 = axes('Units', 'Centimeters', 'Position', NewPos);
    set(h0, 'box', 'on', 'XTick', [], 'YTick', [], 'color', 'none');
else% 2014b and later
    h0=copyobj(newAxes, tmpFig);
    cla(h0);
    set(h0, 'box', 'on', 'XTick', [], 'YTick', [], 'color', 'none');
    set(h0, 'Title', [], 'XLabel', [], 'YLabel', []);
end

print(tmpFig, '-depsc', strcat(path, file));
close(tmpFig);


function Update_Plots(handles)

Plot_Type = get(handles.Plot_Type, 'Value');

FUnits = 'Pixels';
FontSize1 = 12;
FontSize2 = 14;


switch Plot_Type
    case 1 % Log Scale
        Xplot=handles.LGS;
        plot(handles.Plot_Axes, Xplot, 100.*cumsum(handles.Current_Data,2), '-k');
        set(get(handles.Plot_Axes, 'XLabel'), 'String', 'Ln(grain size in \mu{m})', 'FontUnits', FUnits, 'FontSize', FontSize1);
        set(get(handles.Plot_Axes, 'YLabel'), 'String', 'Cumulative abundance [%]', 'FontUnits', FUnits, 'FontSize', FontSize1);
        set(get(handles.Plot_Axes, 'Title'), 'String', 'Multiple GSDs', 'FontUnits', FUnits, 'FontSize', FontSize2);
        
    case 2 % Log-Linear Scale
        Xplot=handles.GS;
        plot(handles.Plot_Axes, Xplot, 100.*cumsum(handles.Current_Data,2), '-k');
        set(handles.Plot_Axes, 'XScale', 'Log');
        set(get(handles.Plot_Axes, 'XLabel'), 'String', 'Grain size [\mu{m}]', 'FontUnits', FUnits, 'FontSize', FontSize1)
        set(get(handles.Plot_Axes, 'YLabel'), 'String', 'Cumulative abundance [%]', 'FontUnits', FUnits, 'FontSize', FontSize1);
        set(get(handles.Plot_Axes, 'Title'), 'String', 'Multiple GSDs', 'FontUnits', FUnits, 'FontSize', FontSize2);
        
    case 3 % Phi scale
        Data = sortrows([handles.Phi, handles.Current_Data'], 1);
                plot(handles.Plot_Axes, Data(:,1), 100.*cumsum((Data(:,2:end))), '-k');
% 
%         Xplot=handles.Phi;
%         plot(handles.Plot_Axes, Xplot, 100.*cumsum((handles.Current_Data),2), '-k');
        set(get(handles.Plot_Axes, 'XLabel'), 'String', '\phi', 'FontUnits', FUnits, 'FontSize', FontSize1)
        set(get(handles.Plot_Axes, 'YLabel'), 'String', 'Cumulative abundance [%]', 'FontUnits', FUnits, 'FontSize', FontSize1);
        set(get(handles.Plot_Axes, 'Title'), 'String', 'Multiple GSDs', 'FontUnits', FUnits, 'FontSize', FontSize2);
end

% Set the y-scale to a nice value
set(handles.Plot_Axes, 'Ylim', [0 102]);

% Reset the button down function
set(handles.Plot_Axes, 'ButtonDownFcn', {@Plot_Axes_ButtonDownFcn, handles});


% --- Executes when entered data in editable cell(s) in Spec_Table.
function Spec_Table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to Spec_Table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)


Inds = eventdata.Indices(1);

% Readjust table position to keep in frame
try
    jscrollpane = javaObjectEDT(findjobj(handles.Spec_Table));
    viewport    = javaObjectEDT(jscrollpane.getViewport);
    P = viewport.getViewPosition();
    obj_fail = 0; % flag to indicate if findjobj failed or not
catch
    % findjobj not avaiable so resort to default behaviour
    obj_fail = 1;
end

Tdata = get(hObject,'Data'); % get the data cell array of the table
New_Status = Tdata{Inds,1};
if New_Status == 1 % is true
    Tdata{Inds, 1} = true(1); % switch True to False
else
    Tdata{Inds, 1} = false(1); % switch False to True
end

set(hObject,'Data',Tdata); % now set the table's data to the updated data cell array

% Get the numeric array for the logicals
handles.Table_Logic = cellfun(@(x) double(x), Tdata(:,1));

% set the current data and update the plot
handles.Current_Data = handles.Data(logical(handles.Table_Logic),:);

if isempty(handles.Current_Data)
    handles.Current_Data = NaN(1, size(handles.Data, 2));
end

Update_Plots(handles);
guidata(hObject, handles);

% Restore the table position
if obj_fail == 0
    drawnow()
    viewport.setViewPosition(P);
end

% --- Executes on button press in Select_All.
function Select_All_Callback(hObject, eventdata, handles)
% hObject    handle to Select_All (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set the logic for the table check boxes
handles.Table_Logic = ones(handles.nData, 1);

% Set the table
set(handles.Spec_Table, 'Data', [num2cell(logical(handles.Table_Logic)), handles.All_Names]);

handles.Current_Data = handles.Data;

Update_Plots(handles);

guidata(hObject, handles);


% --- Executes on button press in Deselect_All.
function Deselect_All_Callback(hObject, eventdata, handles)
% hObject    handle to Deselect_All (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set the logic for the table check boxes
handles.Table_Logic = zeros(handles.nData, 1);

% Set the table
set(handles.Spec_Table, 'Data', [num2cell(logical(handles.Table_Logic)), handles.All_Names]);

handles.Current_Data = NaN(1, size(handles.Data, 2));

Update_Plots(handles);

guidata(hObject, handles);


% --- Executes on button press in DB_ME.
function DB_ME_Callback(hObject, eventdata, handles)
% hObject    handle to DB_ME (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
keyboard


% --- Executes on mouse press over axes background.
function Plot_Axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Plot_Axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

PopOutFigure(handles.Plot_Axes, 'Multi-Specimen Plot')
