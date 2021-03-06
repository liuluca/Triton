function ct_cc_save_plots_gui(hObject,eventdata)

global REMORA

if ~isfield(REMORA.ct,'CC')
    warning('No composite clusters loaded')
    ct_load_composite_clusters
elseif ~isfield(REMORA.ct.CC,'output')
    warning('No composite clusters loaded')
    ct_load_composite_clusters
end

initAxes = 0;
if isfield(REMORA.fig, 'ct')
    % check if the figure already exists. If so, don't move it.
    if isfield(REMORA.fig.ct, 'cc_saveFigs') && isvalid(REMORA.fig.ct.cc_saveFigs)
        defaultPos = get(REMORA.fig.ct.cc_saveFigs,'Position');
    else
        initAxes = 1;
    end
else 
    initAxes = 1;
end

default_pos = [0.35,.45,.3,.15];

if initAxes
    REMORA.fig.ct.cc_saveFigs = figure;
    
    set(REMORA.fig.ct.cc_saveFigs,...
        'Units','normalized',...
        'ToolBar', 'none',...
        'MenuBar','none',...
        'NumberTitle','off','Name',...
        'Composite Clustering Tool - v1.0: Plot Saving Options',...
        'Position',default_pos,...
        'Visible','on');    %
end

clf

% Title
REMORA.ct.CC.saveFigs = [];
labelStr = 'Figure Saving Options';
btnPos=[0 .8 1 .2];
REMORA.ct.CC.saveFigs.headtext = uicontrol(REMORA.fig.ct.cc_saveFigs, ...
    'Style','text', ...
    'Units','normalized', ...
    'Position',btnPos, ...
    'String',labelStr, ...
    'FontUnits','points', ...
    'FontWeight','bold',...
    'FontSize',12,...
    'Visible','on');  %'BackgroundColor',bgColor3,...

%% Output Folder Text
labelStr = 'Output Folder';
btnPos=[.02 .6 .15 .15];
REMORA.ct.CC.saveFigs.outDirTxt = uicontrol(REMORA.fig.ct.cc_saveFigs,...
    'Style','text',...
    'Units','normalized',...
    'Position',btnPos,...
    'HorizontalAlignment','Right',...
    'String',sprintf(labelStr,'Interpreter','tex'),...
    'FontUnits','normalized', ...
    'Visible','on');

% Select output directory
if ~isfield(REMORA.ct.CC.output,'figDir') && ...
        isfield(REMORA.ct, 'CC_params') && isfield(REMORA.ct.CC_params, 'inDir')
    % To start, assume output folder = cluster_bins folder 
    REMORA.ct.CC.output.figDir =  REMORA.ct.CC_params.inDir;
elseif ~isfield(REMORA.ct.CC.output,'figDir') && ~isfield(REMORA.ct.CC.output,'inDir')
    REMORA.ct.CC.output.figDir = 'C:\';
end

% Output Folder Editable Text
btnPos=[.2 .65 .70 .15];
REMORA.ct.CC.saveFigs.outDirEdTxt = uicontrol(REMORA.fig.ct.cc_saveFigs,...
    'Style','edit',...
    'Units','normalized',...
    'Position',btnPos,...
    'BackgroundColor','white',...
    'HorizontalAlignment','left',...
    'String',REMORA.ct.CC.output.figDir,...
    'FontUnits','normalized', ...
    'Visible','on',...
    'Callback',{@ct_cc_save_plots_control,'setOutDir'});

% all cluster plots checkbox
REMORA.ct.CC.output.saveCombinedPlotsTF = 1;
labelStr = 'Save Combined Cluster Plots';
btnPos=[.2 .45 .5 .15];
REMORA.ct.CC.saveFigs.saveCombinedPlotsCheck = uicontrol(REMORA.fig.ct.cc_saveFigs,...
    'Style','checkbox',...
    'Units','normalized',...
    'Position',btnPos,...
    'HorizontalAlignment','left',...
    'String',sprintf(labelStr,'Interpreter','tex'),...
    'FontUnits','normalized', ...
    'Value',REMORA.ct.CC.output.saveCombinedPlotsTF,...
    'Callback',{@ct_cc_save_plots_control,'combined'},...
    'Visible','on');


% per cluster plots checkbox
labelStr = 'Save Individual Cluster Plots';
REMORA.ct.CC.output.saveIndivPlotsTF = 1;
btnPos = [.2 .25 .5 .15];
REMORA.ct.CC.saveFigs.saveIndivPlotsCheck = uicontrol(REMORA.fig.ct.cc_saveFigs,...
    'Style','checkbox',...
    'Units','normalized',...
    'Position',btnPos,...
    'HorizontalAlignment','left',...
    'String',sprintf(labelStr,'Interpreter','tex'),...
    'FontUnits','normalized', ...
    'Value',REMORA.ct.CC.output.saveIndivPlotsTF ,...
    'Callback',{@ct_cc_save_plots_control,'individual'},...
    'Visible','on');

% put a "Save" button
labelStr = 'Save';
btnPos=[.4, 0.05, .2, .15];

REMORA.ct.CC.saveFigs.saveBtn = uicontrol(REMORA.fig.ct.cc_saveFigs,...
    'Style','pushbutton',...
    'Units','normalized',...
    'Position',btnPos,...
    'BackgroundColor','green',...
    'String',labelStr,...
    'FontUnits','normalized', ...
    'FontSize',.5,...
    'Visible','on',...
    'FontWeight','bold',...
    'Callback',@ct_cc_save_plots);

% bring to top
figure(REMORA.fig.ct.cc_saveFigs)

end

function ct_cc_save_plots_control(hObject,eventdata,myEvent)

global REMORA

if strcmp(myEvent, 'setOutDir')
    REMORA.ct.CC.output.figDir = get(REMORA.ct.CC.saveFigs.outDirEdTxt,'String');    
elseif strcmp(myEvent, 'combined')
    REMORA.ct.CC.output.saveCombinedPlotsTF = get(REMORA.ct.CC.saveFigs.saveCombinedPlotsCheck,'Value');
elseif strcmp(myEvent, 'individual')
    REMORA.ct.CC.output.saveIndivPlotsTF = get(REMORA.ct.CC.saveFigs.saveIndivPlotsCheck,'Value');
end

end
