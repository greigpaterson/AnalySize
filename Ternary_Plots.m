function varargout = Ternary_Plots(varargin)
% TERNARY_PLOTS MATLAB code for Ternary_Plots.fig
%      TERNARY_PLOTS, by itself, creates a new TERNARY_PLOTS or raises the existing
%      singleton*.
%
%      H = TERNARY_PLOTS returns the handle to a new TERNARY_PLOTS or the handle to
%      the existing singleton*.
%
%      TERNARY_PLOTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TERNARY_PLOTS.M with the given input arguments.
%
%      TERNARY_PLOTS('Property','Value',...) creates a new TERNARY_PLOTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Ternary_Plots_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Ternary_Plots_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Ternary_Plots

% Last Modified by GUIDE v2.5 10-May-2015 13:36:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Ternary_Plots_OpeningFcn, ...
    'gui_OutputFcn',  @Ternary_Plots_OutputFcn, ...
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


% --- Executes just before Ternary_Plots is made visible.
function Ternary_Plots_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Ternary_Plots (see VARARGIN)

% Choose default command line output for Ternary_Plots
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

handles.Version = getappdata(handles.MainWindow, 'Version');

% Position to be relative to parent:
parentPosition = get(handles.MainWindow, 'Position'); %getpixelposition(handles.MainWindow)
currentPosition = get(hObject, 'Position');
% Set x to be directly in the middle
newX = parentPosition(1) + (parentPosition(3)/2 - currentPosition(3)/2);
newY = parentPosition(2) + (parentPosition(4)/2 - currentPosition(4)/2);
newW = currentPosition(3);
newH = currentPosition(4);
set(hObject, 'Position', [newX, newY, newW, newH]);

% Get the data from previous window
handles.Data = DataTransfer.Data;
handles.GS = DataTransfer.Size;
handles.Phi = DataTransfer.Phi;
handles.All_Names = DataTransfer.Names;

handles.Data_CumSum = cumsum(handles.Data,2);

handles.GS_Fractions = Get_GS_Fractions(handles);

handles.Max_Gravel = 100*max(handles.GS_Fractions(:,4));

% The plot region labels
handles.Label_Color = [1/2, 1/2, 1/2];
handles.Label_FontSize = 12;
handles.Label_Units = 'Pixels';

handles.Plot_Symbol = handles.Defaults.TernSymbol;
handles.Symbol_Color = handles.Defaults.Tern_Plot_Color;
handles.Symbol_Size = handles.Defaults.TernSymbolSize;

if strcmpi(handles.Defaults.TernFaceColor, 'filled')
    handles.Face_Color = handles.Defaults.Tern_Plot_Color;
else
    handles.Face_Color = 'none';
end

% Update handles structure
guidata(hObject, handles);

%% Set up the plot and some defaults
ResetPlot(handles)
Set_Shepard_Fine(handles);


% --- Outputs from this function are returned to the command line.
function varargout = Ternary_Plots_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in Plot_Select.
function Plot_Select_Callback(hObject, eventdata, handles)
% hObject    handle to Plot_Select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Plot_Select contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Plot_Select

contents = cellstr(get(hObject,'String'));

switch contents{get(hObject,'Value')}
    case 'Shepard Fine Plot'
        Set_Shepard_Fine(handles);
    case 'Shepard Coarse Plot'
        Set_Shepard_Coarse(handles);
    case 'Folk Fine Plot'
        Set_Folk_Fine(handles);
    case 'Folk Coarse Plot'
        Set_Folk_Coarse(handles);
end


% --- Executes during object creation, after setting all properties.
function Plot_Select_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Plot_Select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Save_plot.
function Save_plot_Callback(hObject, eventdata, handles)
% hObject    handle to Save_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uiputfile('Ternary_Plot.eps','Save the Ternary plot...');

if ~ischar(file) && file==0
    % User has cancelled
    % Do nothing and...
    return;
end

BaseX = 0.3;
BaseY = 0.3;
Fig_Width = 8.4;
Fig_Height = 7;
FontSize = 6;

if get(handles.Plot_Select, 'Value') == 4 % Folk Coarse plot
BaseX = 0.5;
BaseY = 0.4;
Fig_Width = 9;
end


tmpFig=figure('Visible', 'off', 'Units', 'Centimeters','PaperPositionMode','auto');
oldPos=get(tmpFig, 'Position');
set(tmpFig, 'Position', [oldPos(1), oldPos(2), Fig_Width, Fig_Height]);

newAxes = copyobj(handles.Tern_Axes, tmpFig);

NewMarkerSize = handles.Symbol_Size./2;

% Reset the marker sizes
C = get(newAxes, 'Children');
for ii = 1: length(C);
    try %#ok<TRYNC>
        set(C(ii),'MarkerSize',NewMarkerSize);
    end
end


% Reduce the font size a little
TextObjs = findobj(newAxes, 'Type', 'Text');
set(TextObjs, 'FontUnits', 'Points', 'FontSize', FontSize);

set(newAxes, 'Units', 'Centimeters')
NewPos = [BaseX, BaseY, 8, sqrt(8^2-4^2)];
set(newAxes, 'Position', NewPos);

print(tmpFig, '-depsc', strcat(path, file));
close(tmpFig);


function ResetPlot(handles)

% plot the basic ternary diagram
plot(handles.Tern_Axes, [0 1 0.5 0],[0 0 sin(1/3*pi) 0], '-k' , 'linewidth',1, 'handlevisibility','off')
set(handles.Tern_Axes, 'visible', 'off');

patch('xdata', [0 1 0.5 0], 'ydata', [0 0 sin(1/3*pi) 0], ...
    'edgecolor', 'black', 'linewidth', 1, 'facecolor','white',...
    'handlevisibility','off');

set(handles.Tern_Axes, 'Xlim', [-0.05, 1.05], 'YLim', [-0.05, 0.935]);


function Pcts = Get_GS_Fractions(handles)
%
% Divide the data in to clay, silt, sand, and gravel
%

% some machines do not measure upto -1 phi
sand_lim = -1;
if min(handles.Phi) > -1
    sand_lim = min(handles.Phi);
end


% The data cumulative sum
CS = handles.Data_CumSum;

% The precentages
clay_pct = interp1(handles.Phi, CS', 8)';
silt_pct = interp1(handles.Phi, CS', 4)' - clay_pct;
sand_pct = interp1(handles.Phi, CS', sand_lim)' - interp1(handles.Phi, CS', 4)';
gravel_pct = 1-interp1(handles.Phi, CS', sand_lim)';
gravel_pct(gravel_pct<1e-6) = 0; % remove rounding errors

Pcts = [clay_pct, silt_pct, sand_pct, gravel_pct];


function Set_Shepard_Fine(handles)
%
% Plot the Shepard fines plot
%

if handles.Max_Gravel > 10
    MSG = [{'Some specimens contain more than 10% gravel'}, {'These have been removed from the fines plot'}, ...
        {'Please use the gravel plot'}];    
    set(handles.Gravel_Warning, 'String', MSG, 'Visible', 'On');
else
        set(handles.Gravel_Warning,'Visible', 'Off');
end

% Get the EMs to plot
EMs = [handles.GS_Fractions(:,1), handles.GS_Fractions(:,2), handles.GS_Fractions(:,3)];

% Remove the specimens with gravel fractions
EMs(handles.GS_Fractions(:,4) > 0.1,:) = [];

[Data_x, Data_y] = Get_Tern_Coords(EMs);
[Data_x, inds] = sort(Data_x);
Data_y = Data_y(inds);

% Clear any data and such from the plot
cla(handles.Tern_Axes)

%% Define the regions and add the  labels
% Define the boundaries
[cl_p(1,1), cl_p(1,2)] = Get_Tern_Coords([0.75, 0.25]);
[cl_p(2,1), cl_p(2,2)] = Get_Tern_Coords([0.75, 0]);

[sa_p(1,1), sa_p(1,2)] = Get_Tern_Coords([0.25, 0]);
[sa_p(2,1), sa_p(2,2)] = Get_Tern_Coords([0, 0.25]);

[si_p(1,1), si_p(1,2)] = Get_Tern_Coords([0.25, 0.75]);
[si_p(2,1), si_p(2,2)] = Get_Tern_Coords([0.0, 0.75]);

[c_tri(1,1), c_tri(1,2)] = Get_Tern_Coords([0.6, 0.2]);
[c_tri(2,1), c_tri(2,2)] = Get_Tern_Coords([0.2, 0.6]);
[c_tri(3,1), c_tri(3,2)] = Get_Tern_Coords([0.2, 0.2]);
c_tri(4,:) = c_tri(1,:);

% the "spokes" from the central tirangle
[sp1(1,1), sp1(1,2)] = Get_Tern_Coords([0.75, 0.125]);
sp1(2,:) = c_tri(1,:);

[sp2(1,1), sp2(1,2)] = Get_Tern_Coords([0.5, 0.5]);
[sp2(2,1), sp2(2,2)] = Get_Tern_Coords([0.4, 0.4]);

[sp3(1,1), sp3(1,2)] = Get_Tern_Coords([0.125, 0.75]);
sp3(2,:) = c_tri(2,:);

[sp4(1,1), sp4(1,2)] = Get_Tern_Coords([0, 0.5]);
[sp4(2,1), sp4(2,2)] = Get_Tern_Coords([0.2, 0.4]);

[sp5(1,1), sp5(1,2)] = Get_Tern_Coords([0.125, 0.125]);
sp5(2,:) = c_tri(3,:);

[sp6(1,1), sp6(1,2)] = Get_Tern_Coords([0.5, 0.0]);
[sp6(2,1), sp6(2,2)] = Get_Tern_Coords([0.4, 0.2]);

% The labels
[x, y] = Get_Tern_Coords([0.85, 0.075]);
text(x, y, 'CLAY', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

[x, y] = Get_Tern_Coords([0.075, 0.85]);
text(x, y, 'SILT', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

[x, y] = Get_Tern_Coords([0.075, 0.075]);
text(x, y, 'SAND', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

text(0.615, 0.53, 'SILTY', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')
text(0.615, 0.5, 'CLAY', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

text(0.385, 0.53, 'SANDY', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')
text(0.385, 0.5, 'CLAY', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

text(0.5, 0.33, 'SAND', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')
text(0.5, 0.3, 'SILT', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')
text(0.5, 0.27, 'CLAY', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

text(0.75, 0.28, 'CLAYEY', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')
text(0.75, 0.25, 'SILT', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

text(0.25, 0.28, 'CLAYEY', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')
text(0.25, 0.25, 'SAND', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

text(0.615, 0.1, 'SANDY', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')
text(0.615, 0.07, 'SILT', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

text(0.385, 0.1, 'SILTY', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')
text(0.385, 0.07, 'SAND', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontUnits', handles.Label_Units, 'FontWeight', 'Bold', 'FontName', 'Arial')

%% Plot the data
hold(handles.Tern_Axes, 'on')

plot(cl_p(:,1), cl_p(:,2), '--k')
plot(sa_p(:,1), sa_p(:,2), '--k')
plot(si_p(:,1), si_p(:,2), '--k')
plot(c_tri(:,1), c_tri(:,2), '--k')

plot(sp1(:,1), sp1(:,2), '--k')
plot(sp2(:,1), sp2(:,2), '--k')
plot(sp3(:,1), sp3(:,2), '--k')
plot(sp4(:,1), sp4(:,2), '--k')
plot(sp5(:,1), sp5(:,2), '--k')
plot(sp6(:,1), sp6(:,2), '--k')

plot(handles.Tern_Axes, Data_x, Data_y, handles.Plot_Symbol,...
    'color', handles.Symbol_Color, 'MarkerSize', handles.Symbol_Size, 'MarkerFaceColor', handles.Face_Color);
hold(handles.Tern_Axes, 'off')


function Set_Shepard_Coarse(handles)
%
% Plot the Shepard fines plot
%

set(handles.Gravel_Warning,'Visible', 'Off');

% Get the EMs to plot
% Gravel, caly+silt, sand
EMs = [handles.GS_Fractions(:,4),  handles.GS_Fractions(:,1)+handles.GS_Fractions(:,2), handles.GS_Fractions(:,3)];

[Data_x, Data_y] = Get_Tern_Coords(EMs);
[Data_x, inds] = sort(Data_x);
Data_y = Data_y(inds);
Data_x(Data_x>1) = 1; % remove round off errors

% Clear any data and such from the plot
cla(handles.Tern_Axes)

%% Define the regions and add the  labels
% Define the boundaries
[ssc(1,1), ssc(1,2)] = Get_Tern_Coords([0.1, 0]);
[ssc(2,1), ssc(2,2)] = Get_Tern_Coords([0.1, 0.9]);

[ggs(1,1), ggs(1,2)] = Get_Tern_Coords([0.75, 0.25]);
[ggs(2,1), ggs(2,2)] = Get_Tern_Coords([0.75, 0.125]);
[ggs(3,1), ggs(3,2)] = Get_Tern_Coords([0.6, 0.2]);
[ggs(4,1), ggs(4,2)] = Get_Tern_Coords([0.4, 0.2]);
[ggs(5,1), ggs(5,2)] = Get_Tern_Coords([0.5, 0.0]);

% The labels
text(0.5, 0.72, 'GRAVEL', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

text(0.5, 0.25, 'GRAVELLY SEDIMENT', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

text(0.5, 0.04, 'SAND, SILT, & CLAY (GRAVEL < 10%)', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

%% Plot the data
hold(handles.Tern_Axes, 'on')

plot(ssc(:,1), ssc(:,2), '--k')
plot(ggs(:,1), ggs(:,2), '--k')

plot(handles.Tern_Axes, Data_x, Data_y, handles.Plot_Symbol,...
    'color', handles.Symbol_Color, 'MarkerSize', handles.Symbol_Size, 'MarkerFaceColor', handles.Face_Color);
hold(handles.Tern_Axes, 'off')


function Set_Folk_Fine(handles)
%
% Plot the Shepard fines plot
%


if handles.Max_Gravel > 0.01
    MSG = [{'Some specimens contain more than 0.01% gravel'}, {'These have been removed from the fines plot'}, ...
        {'Please use the gravel plot'}];    
    set(handles.Gravel_Warning, 'String', MSG, 'Visible', 'On');
else
        set(handles.Gravel_Warning,'Visible', 'Off');
end

% Get the EMs to plot
% Sand, silt, clay
EMs = [handles.GS_Fractions(:,3), handles.GS_Fractions(:,2), handles.GS_Fractions(:,1)];

% Remove the specimens with gravel fractions
EMs(handles.GS_Fractions(:,4) > 0.0001,:) = [];

[Data_x, Data_y] = Get_Tern_Coords(EMs);
[Data_x, inds] = sort(Data_x);
Data_y = Data_y(inds);

% Clear any data and such from the plot
cla(handles.Tern_Axes)

%% Define the regions and add the  labels
% Define the boundaries
[H1(1,1), H1(1,2)] = Get_Tern_Coords([0.9, 0]);
[H1(2,1), H1(2,2)] = Get_Tern_Coords([0.9, 0.1]);

[H2(1,1), H2(1,2)] = Get_Tern_Coords([0.5, 0]);
[H2(2,1), H2(2,2)] = Get_Tern_Coords([0.5, 0.5]);

[H3(1,1), H3(1,2)] = Get_Tern_Coords([0.1, 0.9]);
[H3(2,1), H3(2,2)] = Get_Tern_Coords([0.1, 0]);

[sp1(1,1), sp1(1,2)] = Get_Tern_Coords([0.9, 0.1/3]);
[sp1(2,1), sp1(2,2)] = Get_Tern_Coords([0, 1/3]);

[sp2(1,1), sp2(1,2)] = Get_Tern_Coords([0.9, 0.2/3]);
[sp2(2,1), sp2(2,2)] = Get_Tern_Coords([0, 2/3]);

% The labels
text(1/6, 0.04, 'CLAY', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

text(0.5, 0.04, 'MUD', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

text(5/6, 0.04, 'SILT', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

text(0.25, 0.28, 'SANDY', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')
text(0.25, 0.25, 'CLAY', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

text(0.5, 0.28, 'SANDY', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')
text(0.5, 0.25, 'MUD', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

text(0.75, 0.28, 'SANDY', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')
text(0.75, 0.25, 'SILT', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

text(0.37, 0.53, 'CLAYEY', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')
text(0.37, 0.5, 'SAND', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

text(0.5, 0.53, 'MUDDY', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')
text(0.5, 0.5, 'SAND', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

text(0.63, 0.53, 'SILTY', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')
text(0.63, 0.5, 'SAND', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

text(0.498, 0.795, 'SAND', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

%% Plot the data
hold(handles.Tern_Axes, 'on')

plot(H1(:,1), H1(:,2), '--k')
plot(H2(:,1), H2(:,2), '--k')
plot(H3(:,1), H3(:,2), '--k')
plot(sp1(:,1), sp1(:,2), '--k')
plot(sp2(:,1), sp2(:,2), '--k')

plot(handles.Tern_Axes, Data_x, Data_y, handles.Plot_Symbol,...
    'color', handles.Symbol_Color, 'MarkerSize', handles.Symbol_Size, 'MarkerFaceColor', handles.Face_Color);
hold(handles.Tern_Axes, 'off')


function Set_Folk_Coarse(handles)
%
% Plot the Shepard fines plot
%

set(handles.Gravel_Warning,'Visible', 'Off');

% Get the EMs to plot
% Gravel, sand, silt+clay (Mud)
EMs = [handles.GS_Fractions(:,4), handles.GS_Fractions(:,3), handles.GS_Fractions(:,1)+handles.GS_Fractions(:,2)];

% Remove the specimens with gravel fractions
% EMs(handles.GS_Fractions(:,4) <= 0.0001,:) = [];

[Data_x, Data_y] = Get_Tern_Coords(EMs);
[Data_x, inds] = sort(Data_x);
Data_y = Data_y(inds);

% Clear any data and such from the plot
cla(handles.Tern_Axes)

%% Define the regions and add the  labels
% Define the boundaries
[H1(1,1), H1(1,2)] = Get_Tern_Coords([0.8, 0.2]);
[H1(2,1), H1(2,2)] = Get_Tern_Coords([0.8, 0]);

[H2(1,1), H2(1,2)] = Get_Tern_Coords([0.3, 0]);
[H2(2,1), H2(2,2)] = Get_Tern_Coords([0.3, 0.7]);

[H3(1,1), H3(1,2)] = Get_Tern_Coords([0.05, 0.95]);
[H3(2,1), H3(2,2)] = Get_Tern_Coords([0.05, 0]);

[H4(1,1), H4(1,2)] = Get_Tern_Coords([ 0.0001, 0.9999]);
[H4(2,1), H4(2,2)] = Get_Tern_Coords([ 0.0001, 0]);

[sp1(1,1), sp1(1,2)] = Get_Tern_Coords([0.8, 0.1]);
[sp1(2,1), sp1(2,2)] = Get_Tern_Coords([0, 0.5]);

[sp2(1,1), sp2(1,2)] = Get_Tern_Coords([0.8, 0.18]);
[sp2(2,1), sp2(2,2)] = Get_Tern_Coords([0, 0.9]);

[sp3(1,1), sp3(1,2)] = Get_Tern_Coords([0.05, 0.09]);
[sp3(2,1), sp3(2,2)] = Get_Tern_Coords([0, 0.1]);

% The labels
text(0.5, 0.75, 'GRAVEL', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

text(0.375, 0.43, 'MUDDY', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')
text(0.375, 0.4, 'GRAVEL', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

text(0.6, 0.4415, 'MUDDY', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')
text(0.6, 0.415, 'SANDY', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')
text(0.6, 0.385, 'GRAVEL', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

text(0.82, 0.43, 'SANDY', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')
text(0.845, 0.4, 'GRAVEL', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')
line([0.79, 0.76], [0.4, 0.37], 'Color', handles.Label_Color)

text(0.3, 0.17, 'GRAVELLY', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')
text(0.3, 0.14, 'MUD', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

text(0.65, 0.185, 'GRAVELLY', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')
text(0.65, 0.155, 'MUDDY', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')
text(0.65, 0.125, 'SAND', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

text(0.99, 0.17, 'GRAVELLY', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')
text(0.98, 0.14, 'SAND', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')
line([0.94, 0.90], [0.14, 0.11], 'Color', handles.Label_Color)

text(0.3, 0.025, 'SANDY MUD', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

text(0.68, 0.025, 'MUDDY SAND', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

text(0.97, -0.03, 'SLIGHTLY', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')
text(0.97, -0.06, 'GRAVELLY SAND', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')
line([0.97, 0.95], [-.02, 0.025], 'Color', handles.Label_Color)

text(0.03, -0.03, 'SLIGHTLY', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')
text(0.03, -0.06, 'GRAVELLY MUD', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')
line([0.03, 0.06], [-.02, 0.025], 'Color', handles.Label_Color)

text(0.5, -0.025, 'TRACE GRAVEL (< 0.01%)', 'FontUnits', handles.Label_Units, 'FontSize', handles.Label_FontSize, 'HorizontalAlignment', 'Center', 'Color', handles.Label_Color,...
    'FontAngle', 'Italic', 'FontWeight', 'Bold', 'FontName', 'Arial')

%% Plot Data
hold(handles.Tern_Axes, 'on')

plot(H1(:,1), H1(:,2), '--k')
plot(H2(:,1), H2(:,2), '--k')
plot(H3(:,1), H3(:,2), '--k')
plot(H4(:,1), H4(:,2), '--k')
plot(sp1(:,1), sp1(:,2), '--k')
plot(sp2(:,1), sp2(:,2), '--k')
plot(sp3(:,1), sp3(:,2), '--k')

plot(handles.Tern_Axes, Data_x, Data_y, handles.Plot_Symbol,...
    'color', handles.Symbol_Color, 'MarkerSize', handles.Symbol_Size, 'MarkerFaceColor', handles.Face_Color);
hold(handles.Tern_Axes, 'off')
% Set_Labels('Gravel', 'Sand', 'Mud')


% --- Executes on button press in debug_mode.
function debug_mode_Callback(hObject, eventdata, handles)
% hObject    handle to debug_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
keyboard


function [x, y] = Get_Tern_Coords(EMs)

A = EMs(:,1);
B = EMs(:,2);
% C = EMs(:,3);

y = A.*sin(deg2rad(60));
x = B + y*cot(deg2rad(60));


% --- Executes on button press in Set_Symbols.
function Set_Symbols_Callback(hObject, eventdata, handles)
% hObject    handle to Set_Symbols (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Transfer.Plot_Symbol = handles.Plot_Symbol;
Transfer.Symbol_Size = handles.Symbol_Size;
Transfer.Symbol_Color = handles.Symbol_Color;
Transfer.Face_Color = handles.Face_Color;

Return_Data = Tern_Set_Symbol('DataTransfer', Transfer, handles.MainWindow, handles.Tern_Plot_Fig);

if Return_Data.CancelFlag == 1
    return;
end

handles.Plot_Symbol = Return_Data.Plot_Symbol;
handles.Symbol_Size = Return_Data.Symbol_Size;
handles.Symbol_Color = Return_Data.Symbol_Color;
handles.Face_Color = Return_Data.Face_Color;

% Save the changes to session defaults
Defaults = handles.Defaults;

Defaults.TernSymbol = handles.Plot_Symbol;
Defaults.TernSymbolSize = handles.Symbol_Size;
Defaults.Tern_Plot_Color = handles.Symbol_Color;

if strcmpi(handles.Face_Color, 'none')
    Defaults.TernFaceColor = handles.Face_Color;
else
    Defaults.TernFaceColor = 'filled';
end
    
handles.Defaults = Defaults;

setappdata(handles.MainWindow, 'Defaults', handles.Defaults);

guidata(hObject, handles);

% Update the plots
All_Strings = cellstr(get(handles.Plot_Select,'String'));

switch All_Strings{get(handles.Plot_Select, 'Value')}
    case 'Shepard Fine Plot'
        Set_Shepard_Fine(handles);
    case 'Shepard Coarse Plot'
        Set_Shepard_Coarse(handles);
    case 'Folk Fine Plot'
        Set_Folk_Fine(handles);
    case 'Folk Coarse Plot'
        Set_Folk_Coarse(handles);
end


% --- Executes on button press in Export_Data.
function Export_Data_Callback(hObject, eventdata, handles)
% hObject    handle to Export_Data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[file,path] = uiputfile('Ternary_Plot_Data.dat', 'Save the plot data...');

if ~ischar(file) && file==0
    % User has cancelled
    % Do nothing and...
    return;
end

fout = fopen(strcat(path, file), 'wt');

% The format string for printing the data
LineEnd = getappdata(handles.MainWindow, 'LineEnd');

fmt1 = strcat('%s\t%s\t%s\t%s\t%s', LineEnd);
fmt2 = strcat('%s\t%3.2f\t%3.2f\t%3.2f\t%3.2f', LineEnd);

fprintf(fout, fmt1, 'Specimen', '% Clay', '% Silt', '% Sand', '% Gravel');

Data_Out = [handles.All_Names, num2cell(100.*handles.GS_Fractions)]';
fprintf(fout, fmt2, Data_Out{:});

fclose(fout);
