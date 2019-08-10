function dt_mkTPWS_gui

global REMORA
% button grid layouts
% 14 rows, 4 columns
% button grid layouts
% 14 rows, 4 columns
r = 19; % rows      (extra space for separations btw sections)
c = 4;  % columns
h = 1/r;
w = 1/c;
dy = h * 0.8;
% dx = 0.008;
ybuff = h*.2;
% y position (relative units)
y = 1:-h:0;
xbuff = w*.1;

% x position (relative units)
x = 0:w:1;


% colors
bgColor = [1 1 1];  % white
bgColor3 = [.75 .875 1];
bgColor4 = [.76 .87 .78];
bgColorGray = [.86 .86 .86];  % gray
bgColorGrayLight = [.9 .9 .9];  % gray

% Setup variables:
defaultPos = [0.4,0.4,0.5,0.45];
% open and setup figure window

REMORA.fig.dt_mkTPWS = figure( ...
    'NumberTitle','off', ...
    'Name','Make TPWS from detections',...
    'Units','normalized',...
    'MenuBar','none',...
    'Position',defaultPos, ...
    'Visible', 'on');

REMORA.dt_mkTPWS = [];
labelStr = 'Specify Detection Information';
btnPos=[0 y(2) w*c h];
REMORA.dt_mkTPWS.headtext = uicontrol(REMORA.fig.dt_mkTPWS, ...
    'Style','text', ...
    'Units','normalized', ...
    'Position',btnPos, ...
    'String',labelStr, ...
    'FontUnits','points', ...
    'FontWeight','bold',...
    'FontSize',11,...
    'Visible','on',...
    'BackgroundColor',bgColor3);

%***********************************
% Detection Files Folder Text
%***********************************

labelStr = 'Detection Files Folder';
btnPos=[x(1)+xbuff y(3) w dy];
REMORA.dt_mkTPWS.detDirTxt = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','text',...
    'Units','normalized',...
    'Position',btnPos,...
    'HorizontalAlignment','left',...
    'String',sprintf(labelStr,'Interpreter','tex'),...
    'FontUnits','normalized', ...
    'Visible','on');

% Detection Files Folder Editable Text
labelStr = '';
btnPos=[x(2) y(3) w*2.5 dy];% btnPos=[x(1)+xbuff y(3) (w*c)*.7 dy];
REMORA.dt_mkTPWS.detDirEdTxt = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','edit',...
    'Units','normalized',...
    'Position',btnPos,...
    'BackgroundColor',bgColor,...
    'String',labelStr,...
    'FontUnits','normalized', ...
    'HorizontalAlignment','left',...
    'Visible','on',...
    'Callback','dt_TPWS_control(''setDetDir'')');

% Detection Files Folder Checkbox
labelStr = 'Run on Subfolders';
btnPos=[x(2)  y(4) (w*c)*.7 dy];
REMORA.dt_mkTPWS.subDirCheckBox = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','checkbox',...
    'Units','normalized',...
    'Position',btnPos,...
    'String',labelStr,...
    'FontUnits','normalized', ...
    'HorizontalAlignment','left',...
    'Visible','on',...
    'Callback','dt_TPWS_control(''setSubDirTF'')');

% Detection Files Extension Popupmenu
labelStr = {'.cTg','.pgdf','.cHR','other'};
btnPos=[x(2)  y(5) (w*c)*.2 dy];
REMORA.dt_mkTPWS.detExtPopup = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','popupmenu',...
    'Units','normalized',...
    'Position',btnPos,...
    'String',labelStr,...
    'FontUnits','normalized', ...
    'HorizontalAlignment','left',...
    'Visible','on',...
    'Value',1,...
    'Callback','dt_TPWS_control(''setDetFileExt'')');

%***********************************
% Audio Files Folder Text
%***********************************

% Audio Files Folder Text
labelStr = 'Audio File Folder';
btnPos=[x(1)+xbuff y(6)-ybuff*2 w dy];
REMORA.dt_mkTPWS.xwavDirTxt = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','text',...
    'Units','normalized',...
    'HorizontalAlignment','left',...
    'Position',btnPos,...
    'String',sprintf(labelStr,'Interpreter','tex'),...
    'FontUnits','normalized', ...
    'Visible','on');%   'BackgroundColor',bgColor3,...

% Audio Files Folder Editable Text
labelStr = '';
btnPos=[x(2) y(6)-ybuff*2 w*2.5 dy];
REMORA.dt_mkTPWS.xwavDirEdTxt = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','edit',...
    'Units','normalized',...
    'Position',btnPos,...
    'BackgroundColor',bgColor,...
    'HorizontalAlignment','left',...
    'String',labelStr,...
    'FontUnits','normalized', ...
    'Visible','on',...
    'Callback','dt_TPWS_control(''setXwavDir'')');

% Audio Files Extension Popupmenu
labelStr = {'x.wav','.wav'};
btnPos=[x(2)  y(7)-ybuff*2 (w*c)*.2 dy];
REMORA.dt_mkTPWS.xwavExtPopup = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','popupmenu',...
    'Units','normalized',...
    'Position',btnPos,...
    'String',labelStr,...
    'FontUnits','normalized', ...
    'HorizontalAlignment','left',...
    'Visible','on',...
    'Value',1,...
    'Callback','dt_TPWS_control(''setXwavFileExt'')');

%***********************************
% Output Folder Text
%***********************************

% Output Folder Text
labelStr = 'Output Folder';
btnPos=[x(1)+xbuff y(9) w dy];
REMORA.dt_mkTPWS.outDirTxt = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','text',...
    'Units','normalized',...
    'HorizontalAlignment','left',...
    'Position',btnPos,...
    'String',sprintf(labelStr,'Interpreter','tex'),...
    'FontUnits','normalized', ...
    'Visible','on');%   'BackgroundColor',bgColor3,...

% Output Folder Editable Text
labelStr = '';
btnPos=[x(2)  y(9) w*2.5 dy];
REMORA.dt_mkTPWS.outDirEdTxt = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','edit',...
    'Units','normalized',...
    'Position',btnPos,...
    'BackgroundColor',bgColor,...
    'HorizontalAlignment','left',...
    'String',labelStr,...
    'FontUnits','normalized', ...
    'Visible','on',...
    'Callback','dt_TPWS_control(''setTPWSOutDir'')');

%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Commonly-Modified
labelStr = 'Commonly-Modified';
btnPos=[x(1) y(11) w*2 h];
REMORA.dt_mkTPWS.modifyHeading = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','text',...
    'Units','normalized',...
    'Position',btnPos,...
    'String',labelStr,...
    'FontWeight','bold',...
    'FontUnits','normalized', ...
    'Visible','on',...
    'BackgroundColor',bgColor3);

% Parameter Text
labelStr = 'Parameter';
btnPos=[x(1) y(12) w h];
REMORA.dt_mkTPWS.parameterHeading = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','text',...
    'Units','normalized',...
    'Position',btnPos,...
    'String',labelStr,...
    'FontUnits','normalized', ...
    'Visible','on',...
    'BackgroundColor',bgColorGrayLight);

% Minimum Parameter Text
labelStr = 'Min';
btnPos=[x(2) y(12) w/2 h];
REMORA.dt_mkTPWS.minHeading = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','text',...
    'Units','normalized',...
    'Position',btnPos,...
    'String',labelStr,...
    'FontUnits','normalized', ...
    'Visible','on',...
    'BackgroundColor',bgColorGrayLight);

% Maximum Parameter Text
labelStr = 'Max';
btnPos=[x(2)+w/2 y(12) w/2 h];
REMORA.dt_mkTPWS.maxHeading = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','text',...
    'Units','normalized',...
    'Position',btnPos,...
    'String',labelStr,...
    'FontUnits','normalized', ...
    'Visible','on',...
    'BackgroundColor',bgColorGrayLight);

%***********************************
% Bandpass Filter Edges Text
%***********************************

% Bandpass Filter Edges Text
labelStr = 'Bandpass Filter Edges (Hz)';
btnPos=[x(1)+xbuff y(13) w h];
REMORA.dt_mkTPWS.bpEdgeTxt = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','text',...
    'Units','normalized',...
    'Position',btnPos,...
    'HorizontalAlignment','left',...
    'String',labelStr,...
    'FontUnits','normalized', ...
    'Visible','on');

% Minimum Parameter Text
labelStr = '5000';
btnPos=[x(2) y(13) w/2 h];
REMORA.dt_mkTPWS.bpEdgeMinEdTxt = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','edit',...
    'Units','normalized',...
    'Position',btnPos,...
    'String',labelStr,...
    'FontUnits','normalized', ...
    'Visible','on',...
    'Callback','dt_TPWS_control(''setbpEdgeMin'')');

% Maximum Parameter Text
labelStr = '92000';
btnPos=[x(2)+w/2 y(13) w/2 h];
REMORA.dt_mkTPWS.bpEdgeMaxEdTxt = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','edit',...
    'Units','normalized',...
    'Position',btnPos,...
    'String',labelStr,...
    'BackgroundColor',bgColor,...
    'FontUnits','normalized', ...
    'Visible','on',...
    'Callback','dt_TPWS_control(''setbpEdgeMax'')');

%***********************************
% Frame Length Text
%***********************************

% Frame Length Text
labelStr = 'Frame Length (us)';
btnPos=[x(1)+xbuff y(14) w h];
REMORA.dt_mkTPWS.frameTxt = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','text',...
    'Units','normalized',...
    'Position',btnPos,...
    'HorizontalAlignment','left',...
    'String',labelStr,...
    'FontUnits','normalized', ...
    'Visible','on');

% Frame Length Value
labelStr = '1200';
btnPos=[x(2)+w/2 y(14) w/2 h];
REMORA.dt_mkTPWS.frameEdTxt = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','edit',...
    'Units','normalized',...
    'Position',btnPos,...
    'String',labelStr,...
    'FontUnits','normalized', ...
    'Visible','on',...
    'Callback','dt_TPWS_control(''setFrame'')');

%***********************************
% Bandpass Filter Order Text
%***********************************

% Bandpass Filter Order Text
labelStr = 'Filter Order';
btnPos=[x(1)+xbuff y(15) w h];
REMORA.dt_mkTPWS.bpOrderTxt = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','text',...
    'Units','normalized',...
    'Position',btnPos,...
    'HorizontalAlignment','left',...
    'String',labelStr,...
    'FontUnits','normalized', ...
    'Visible','on');

% Bandpass Filter Order Value
labelStr = '5';
btnPos=[x(2)+w/2 y(15) w/2 h];
REMORA.dt_mkTPWS.bpOrderEdTxt = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','edit',...
    'Units','normalized',...
    'Position',btnPos,...
    'String',labelStr,...
    'FontUnits','normalized', ...
    'Visible','on',...
    'Callback','dt_TPWS_control(''setOrder'')');

%***********************************
% Overlap Text
%***********************************

% Overlap Text
labelStr = 'Overlap (%)';
btnPos=[x(1)+xbuff y(16) w h];
REMORA.dt_mkTPWS.overlapTxt = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','text',...
    'Units','normalized',...
    'Position',btnPos,...
    'HorizontalAlignment','left',...
    'String',labelStr,...
    'FontUnits','normalized', ...
    'Visible','on');

% Overlap Value
labelStr = '50';
btnPos=[x(2)+w/2 y(16) w/2 h];
REMORA.dt_mkTPWS.overlapEdTxt = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','edit',...
    'Units','normalized',...
    'Position',btnPos,...
    'String',labelStr,...
    'FontUnits','normalized', ...
    'Visible','on',...
    'Callback','dt_TPWS_control(''setOverlap'')');

%% Optional settings
labelStr = 'Optional settings';
btnPos=[x(3)+xbuff/5 y(11) w*2 h];
REMORA.dt_mkTPWS.optionalHeading = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','text',...
    'Units','normalized',...
    'Position',btnPos,...
    'String',labelStr,...
    'FontWeight','bold',...
    'BackgroundColor',bgColor,...
    'FontUnits','normalized', ...
    'Visible','on',...
    'BackgroundColor',bgColor3);

%***********************************
% Transfer Function Text
%***********************************

% Transfer Function Text
labelStr = 'Transfer Function Path';
btnPos=[x(3)+xbuff y(12) w dy];
REMORA.dt_mkTPWS.tfPathTxt = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','text',...
    'Units','normalized',...
    'HorizontalAlignment','left',...
    'Position',btnPos,...
    'String',sprintf(labelStr,'Interpreter','tex'),...
    'FontUnits','normalized', ...
    'Visible','on');%   'BackgroundColor',bgColor3,...

% Transfer Function Editable Text
labelStr = '';
btnPos=[x(4)  y(12) w*.9 dy];
REMORA.dt_mkTPWS.tfPathEdTxt = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','edit',...
    'Units','normalized',...
    'Position',btnPos,...
    'BackgroundColor',bgColor,...
    'HorizontalAlignment','left',...
    'String',labelStr,...
    'FontUnits','normalized', ...
    'Visible','on',...
    'Callback','dt_TPWS_control(''setTFPath'')');

%***********************************
% Filter String Text
%***********************************

% Filter String Text
labelStr = 'Partial String to Match';
btnPos=[x(3)+xbuff y(13) w dy];
REMORA.dt_mkTPWS.filterStringTxt = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','text',...
    'Units','normalized',...
    'Position',btnPos,...
    'HorizontalAlignment','left',...
    'String',sprintf(labelStr,'Interpreter','tex'),...
    'FontUnits','normalized', ...
    'Visible','on');%   'BackgroundColor',bgColor3,...

%  Filter String Editable Text
labelStr = '';
btnPos=[x(4)  y(13) w*.9 dy];% btnPos=[x(2)-xbuff/2 y(11) w*.9 dy];
REMORA.dt_mkTPWS.filterStringEdTxt = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','edit',...
    'Units','normalized',...
    'Position',btnPos,...
    'BackgroundColor',bgColor,...
    'HorizontalAlignment','left',...
    'String',labelStr,...
    'FontUnits','normalized', ...
    'Visible','on',...
    'Callback','dt_TPWS_control(''setTPWSFilterString'')');

%***********************************
% Received Level Text
%***********************************

% Min RL Text
labelStr = 'Min. RL Threshold (dBpp)';
btnPos=[x(3)+xbuff y(14) w*1.5 dy];
REMORA.dt_mkTPWS.minRLTxt = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','text',...
    'Units','normalized',...
    'Position',btnPos,...
    'HorizontalAlignment','left',...
    'String',sprintf(labelStr,'Interpreter','tex'),...
    'FontUnits','normalized', ...
    'Visible','on');%   'BackgroundColor',bgColor3,...

%  Min RL Editable Text
labelStr = '';
btnPos=[x(4)  y(14) w/2*.8 dy];
REMORA.dt_mkTPWS.minRLEdTxt = uicontrol(REMORA.fig.dt_mkTPWS,...
    'Style','edit',...
    'Units','normalized',...
    'Position',btnPos,...
    'BackgroundColor',bgColor,...
    'HorizontalAlignment','left',...
    'String',labelStr,...
    'FontUnits','normalized', ...
    'Visible','on',...
    'Callback','dt_TPWS_control(''setTPWSminRL'')');

labelStr = 'Make TPWS Files';
btnPos=[x(2)+w/2  y(19) w 1.5*h];
REMORA.dt_mkTPWS.refresh = uicontrol(REMORA.fig.dt_mkTPWS, ...
    'Style','pushbutton', ...
    'Units','normalized', ...
    'Position',btnPos, ...
    'BackgroundColor',bgColor4,...
    'String',labelStr, ...
    'FontUnits','points', ...
    'FontWeight','bold',...
    'FontSize',11,...
    'Callback','dt_TPWS_control(''run_mkTPWS'')');


