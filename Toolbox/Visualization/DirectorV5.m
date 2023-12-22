function DirectorV5()

global Show_Bones markerList3 markerList4 markerList5 markerList6 markerList7 AnglesName ForcesName MomentsName PowersName ScalarsName playing data current_frame searchStr textNames color searchBox reset filepath stopLoop n_frames size_factor speedSlider Markers Markers_names progressBar frameLabel activeMarkers;

global lbl xd yd nxd nyd nzd hline ax ax2 ax3 OyF1 OxF1 OzF1 xFP  xF1  yF1  zF1  xF2  yF2  zF2 yFP zFP OyF2 OxF2 OzF2 xFP2 yFP2 zFP2 xcol my3DArrow Force_arrow_sampled Force_arrow my3DArrow2 Force_arrow_sampled2 Force_arrow2 ycol zcol str lineHandles ListName3 ListName1 ListName2 ListName4 ListName5 ListName6 ListName7 textHandles AnalogName popMenu markerList selectedData selectionMode selectedCellsData;

% Initialize variables
xFP = []; yFP = []; zFP = []; xFP2 = []; yFP2 = []; zFP2 = [];
xF1 = []; yF1 = []; zF1 = []; xF2 = []; yF2 = []; zF2 = [];
OxF1 = []; OyF1 = []; OyF1 = []; OxF2 = []; OyF2 = []; OyF2 = [];

% Define grid lines
lbl = (-3100:330:3100);
xd = [lbl,lbl];
xd(1:2:end) = lbl;
xd(2:2:end) = lbl;
yd = xd;
yd(1:4:end) = max(lbl);
yd(2:4:end) = min(lbl);
yd(3:4:end) = min(lbl);
yd(4:4:end) = max(lbl);
nyd = [yd,fliplr(xd)];
nxd = [xd,yd];
nzd = zeros(size(nyd));
nzd(:) = -9;

% Define axis colors
xcol = [1 0 0]; % Red color for x axis arrow
ycol = [0 1 0]; % Green color for y axis arrows
zcol = [0 0 1]; % Blue color for z axis arrows

% Initialize UI components
fig = []; markerList = []; markerList2 = []; markerList3 = []; markerList4 = [];
markerList5 = []; markerList6 = []; markerList7 = []; searchBox = []; fileDisplayName = [];
axBar = []; ax=[]; initGlobals(); createUI(); hline=[]; ax2 = [];
selectionMode = 'single'; selectedCellsData = {}; str = [];
previous_size_factor = []; previous_colors = []; textNames ={};

% Initialize global variables
function initGlobals()
    playing = false;
    current_frame = 1;
    size_factor = 8;
    color = 'w';
    stopLoop = false;
    activeMarkers = [];
    Show_Bones = 0;
end

%%%%%%% Creation of UI %%%%%%%
function createUI()
    % Create figure and axes
    fig = figure('Position', [200, 50, 1100, 800], 'Color', [0 0 0], 'Name', 'Director', 'NumberTitle', 'off','tag','space','MenuBar', 'none', 'ToolBar', 'none');
    ax = axes('Parent', fig, 'Position', [0.11, 0.001, 0.99, 0.95], 'XLim', [-3100, 3100], 'YLim', [-3100, 3100], 'ZLim', [-300, 2100],'Tag', '3Dspace');
    grid on; view(3); set(ax, 'Box', 'off'); set(ax,'visible','off');
    hline = line('parent',ax,'xdata',nxd,'ydata',nyd,'zdata',nzd,'color',[.44 .44 .44],'LineStyle','-');
    set(hline, 'PickableParts', 'none');
    camlight; lighting gouraud;
    axis(ax, 'equal');
    zoomLevelDefault = 1.6; % Niveau de zoom par défaut, 1 étant le zoom normal
camzoom(ax, zoomLevelDefault);

    % Create additional axes for orientation window
    ax2 = axes('parent',fig,'unit','normalized','position',[0.001 0.001 .4 .4],'cameraviewangle', 40,'cameraposition',[2 2 2],'cameratarget',[0 0 0],'color',[.8 .8 .8],'visible','off','tag','orientation window');
    set(ax2, 'hitTest', 'off');

    % Add arrows and labels for orientation window
    [x,y,z] = arrow([0 0 0],[1 0 0],4);
    surface('parent',ax2,'xdata',x,'ydata',y,'zdata',z,'facecolor',xcol,'edgecolor','none','facelighting','gouraud','tag','x');
    text(1.1 , 0 , 0, 'x','Color',[1 1 1]);

    [x,y,z] = arrow([0 0 0],[0 1 0],4);
    surface('parent',ax2,'xdata',x,'ydata',y,'zdata',z,'facecolor',ycol,'edgecolor','none','facelighting','gouraud', 'tag','y');
    text(0 , 1.2 , 0, 'y','Color',[1 1 1]);

    [x,y,z] = arrow([0 0 0],[0 0 1],4);
    surface('parent',ax2,'xdata',x,'ydata',y,'zdata',z,'facecolor',zcol,'edgecolor','none','facelighting','gouraud','tag','z');
    text(0 , 0 , 1.1, 'z','Color',[1 1 1]);


% Get the current view angle of 'ax'
az = -45;
el = 22;
view(ax, az, el);
view(ax2, az, el); % Update the orientation window with the same angle

% Reset button
reset = uicontrol(fig, 'Style', 'pushbutton', 'String', 'reset', 'FontSize', 10, 'Position', [489 785 40 17], 'Callback', @resetCallback);
set(reset, 'visible', 'off');

% Main control panel
controlPanel = uipanel('Position', [0.155, 0.01, 0.84, 0.12], 'BackgroundColor', [.95 .95 .95], 'BorderWidth', 2, 'BorderColor', 'black');
uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Play', 'FontSize', 15, 'Position', [32 15 65 45], 'Callback', @playCallback);
speedSlider = uicontrol(controlPanel, 'Style', 'slider', 'Position', [801 16 90 19], 'backgroundcolor', [1 1 1], 'Min', 1, 'Max', 3, 'Value', 1, 'SliderStep', [0.1, 0.2], 'Callback', @speedCallback);
uicontrol(controlPanel, 'Style', 'text', 'Position', [749 16 55 20], 'String', 'Speed:', 'FontSize', 10);
uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Option', 'FontSize', 10, 'Position', [830 45 70 30], 'Callback', @editAppearanceCallback);
uicontrol(controlPanel, 'Style', 'text', 'Position', [135 55 10 15], 'String', '1', 'FontSize', 12);
uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Update', 'Position', [32 60 50 25], 'Callback', @checkBoxCallback);
uicontrol(controlPanel, 'Style', 'togglebutton', 'String', 'Show Bones', 'FontSize', 10, 'Position', [740 45 90 30], 'Callback', @BonesCallback);


% Progress bar
progressBar = uicontrol(controlPanel, 'Style', 'slider', 'Position', [138 25 491 23], 'backgroundcolor', [1 1 1], 'Min', 1, 'Max', 100, 'Value', 1, 'sliderstep', [1/(100-1) 10/(100-1)], 'Callback', @progressBarCallback);
frameLabel = uicontrol(controlPanel, 'Style', 'text', 'Position', [627.5 23 83 23], 'String', 'Frame: 1', 'FontSize', 11,'tag','frame');

% Event bar
axBar = axes('Parent', controlPanel, 'Position', [0.162, 0.2, 0.5085, 0.57], 'Visible', 'off', 'XLim', [0, 1], 'YLim', [-2, 5]);
set(axBar, 'HitTest', 'off');

for i = 0:0.1:1
    line([i i], [-2 5], 'Color', 'k', 'Parent', axBar);
end

% Secondary control panel
controlPanel2 = uipanel('Position', [0.004, 0.01, 0.15, 0.985], 'BackgroundColor', [.95 .95 .95], 'BorderWidth', 2, 'BorderColor', 'black');
uicontrol(controlPanel2, 'Style', 'pushbutton', 'String', 'Close', 'Position', [85 15 55 30], 'Callback', @closeCallback);
uicontrol(controlPanel2, 'Style', 'pushbutton', 'String', 'Load', 'Position', [20 15 55 30], 'Callback', @loadCallback);
uicontrol(controlPanel2, 'Style', 'togglebutton', 'String', 'Show Graph', 'Position', [89 88 65 25], 'Callback', @toggleGraphCallback);
uicontrol(controlPanel2, 'Style', 'togglebutton', 'String', 'Compare off', 'Position', [8 88 68 25], 'Callback', @toggleSelectionMode);
uicontrol(controlPanel2, 'Style', 'pushbutton', 'Position', [80 55 60 25], 'String', 'Delete event', 'Callback', @showDeleteEventWindow);

% Marker lists
markerList = ListCheckBox(fig, [15 125 146.35 530], {});
markerList2 = ListCheckBox(fig, [15 125 146.35 530], {});
markerList3 = ListCheckBox(fig, [15 125 146.35 530], {});
markerList4 = ListCheckBox(fig, [15 125 146.35 530], {});
markerList5 = ListCheckBox(fig, [15 125 146.35 530], {});
markerList6 = ListCheckBox(fig, [15 125 146.35 530], {});
markerList7 = ListCheckBox(fig, [15 125 146.35 530], {});

% Add CellSelectionCallback to markerList
set(markerList, 'CellSelectionCallback', {@cellSelected, markerList.Data});

uicontrol(controlPanel2, 'Style', 'pushbutton', 'String', 'Deselect All', 'Position', [83 670 65 25], 'Callback', @selectAllCallback);
uicontrol(controlPanel2, 'Style', 'pushbutton', 'String', 'Add event', 'Position', [20 55 60 25], 'Callback', @showAddEventWindow);
searchBox = uicontrol(controlPanel2, 'Style', 'edit', 'Position', [10 700 140 25], 'Callback', {@updateTable, ListName1, ListName2, ListName3, ListName4, ListName5, ListName6, ListName7}, 'Tag', 'searchBox');
uicontrol(controlPanel2, 'Style', 'pushbutton', 'String', 'Search', 'Position', [12 670 65 25], 'Callback', {@updateTable, ListName1, ListName2, ListName3, ListName4, ListName5, ListName6, ListName7});
fileDisplayName = uicontrol(controlPanel2, 'Style', 'text', 'String', 'No file loaded', 'Units', 'normalized', 'Position', [0 0.95 1 0.05], 'FontSize', 11, 'BackgroundColor', [0.9 0.9 0.9]);

% Popup menu for options
menuOptions = {'Markers','Analog','Angles','Forces','Powers','Moments','Scalars'};
popMenu = uicontrol(controlPanel2, 'Style', 'popupmenu', 'String', menuOptions, 'Position', [8 635 146 25], 'Callback', @popMenuCallback);
markerList.Visible = 'on';
markerList2.Visible = 'off';
markerList3.Visible = 'off';
markerList4.Visible = 'off';
markerList5.Visible = 'off';
markerList6.Visible = 'off';
markerList7.Visible = 'off';

        
zoomArea = [-2500 2500 -2500 2500]; % Spécifiez les coordonnées de la zone de zoom
set(fig, 'WindowScrollWheelFcn', @(src, event) zoomFcn(event, ax, zoomArea));


    % Activer la rotation 3D avec la souris
    set(fig, 'WindowButtonDownFcn', @(src, event) rotateStart(src, ax, ax2));
    set(fig, 'WindowButtonMotionFcn', @(src, event) rotating(src, ax, ax2));
    set(fig, 'WindowButtonUpFcn', @(src, event) rotateEnd(src));

    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fonction pour le zoom
function zoomFcn(event, ax, zoomArea)
    zoomLevel = 1.1; % Niveau de zoom
    
    % Obtenez les coordonnées de la souris par rapport à la figure
    currentPoint = ax.CurrentPoint;
    x = currentPoint(1, 1);
    y = currentPoint(1, 2);
    
    % Définissez les coordonnées minimales et maximales de la zone de zoom
    xMin = zoomArea(1);
    xMax = zoomArea(2);
    yMin = zoomArea(3);
    yMax = zoomArea(4);
    
    % Vérifiez si la souris est dans la zone de zoom
    if x >= xMin && x <= xMax && y >= yMin && y <= yMax
        if event.VerticalScrollCount > 0
            % Zoom arrière
            camzoom(ax, 1/zoomLevel);
        elseif event.VerticalScrollCount < 0
            % Zoom avant
            camzoom(ax, zoomLevel);
        end
    end
end

% Fonctions pour la rotation
function rotateStart(fig, ax,ax2)
    global isRotating;
    global lastPoint;
    isRotating = true;
    lastPoint = fig.CurrentPoint;
end

function rotating(fig, ax, ax2)
    global isRotating;
    global lastPoint;
    if isRotating
        currentPoint = fig.CurrentPoint;
        dx = currentPoint(1) - lastPoint(1);
        dy = currentPoint(2) - lastPoint(2);
         sensitivity = 0.2; 
        viewAngle = [dx * sensitivity, dy * sensitivity];
        camorbit(ax, -viewAngle(1), -viewAngle(2), 'data', [0 0 1]);
         camorbit(ax2, -viewAngle(1), -viewAngle(2), 'data', [0 0 1]);
        lastPoint = currentPoint;
    end
end

function rotateEnd(fig)
    global isRotating;
    isRotating = false;
end


%%%%%%% Callbacks %%%%%%%
    function BonesCallback (source, ~)

         state_bones = get(source, 'Value');
  if state_bones == 1
        %clear Bones
bonesToClear = {'LeftClavicle','LeftHumerus', 'LeftRadius','LeftHand','LeftFemur', 'LeftTibia','LeftFoot','LeftToe', 'Pelvis','RightClavicle','RightHumerus', 'RightRadius','RightHand', 'RightFemur', 'RightTibia','RightFoot','RightToe', 'Thorax', 'Head'};

% Loop through each bone and clear its patch
for i = 1:length(bonesToClear)
    bonePatch = findobj('Tag', bonesToClear{i});
    delete(bonePatch);
end
    s = filesep;    % determine slash direction based on computer type
        d = which('director'); % returns path to ensemlber
        path = pathname(d) ;  % local folder where director resides
        bones = [path,'Cinema objects',s,'bones',s,'golembones'];
        openBones(bones);  
        
        DisplayBones;
        Show_Bones = 1;
        set(speedSlider,'value',3);
        btnBones = findobj('String', 'Show Bones');
        if ~isempty(btnBones)
            set(btnBones, 'String', 'Hide Bones');
        end
    else
        Show_Bones = 0;
        btnBones = findobj('String', 'Hide Bones');
        if ~isempty(btnBones)
            set(btnBones, 'String', 'Show Bones');
        end
             %clear Bones
bonesToClear = {'LeftClavicleBis','LeftHumerusBis', 'LeftRadiusBis','LeftHandBis','LeftFemurBis', 'LeftTibiaBis','LeftFootBis','LeftToeBis', 'PelvisBis','RightClavicleBis','RightHumerusBis', 'RightRadiusBis','RightHandBis', 'RightFemurBis', 'RightTibiaBis','RightFootBis','RightToeBis', 'ThoraxBis', 'HeadBis'};

% Loop through each bone and clear its patch
for i = 1:length(bonesToClear)
    bonePatch = findobj('Tag', bonesToClear{i});
    delete(bonePatch);
end
s = filesep;    % determine slash direction based on computer type
        d = which('director'); % returns path to ensemlber
        path = pathname(d) ;  % local folder where director resides
        bones = [path,'Cinema objects',s,'bones',s,'golembones'];
        openBones(bones); 
        clear manipulateBoneByName
        set(speedSlider,'value',1);
  end
    end


function resetCallback(~, ~)
    textNames = {};
    selectedCellsData = {};
    cla(ax3); % Clear the specified axes
end

function toggleSelectionMode(source, ~)
    textNames = {};
    selectedCellsData = {};
    smallGraph = findobj(fig, 'Tag', 'SmallGraph');
    if ~isempty(smallGraph)
        cla(ax3); % Clear the specified axes
    end

    button_state = get(source, 'Value');

    if button_state == 1
        selectionMode = 'multiple';
        btnCompare = findobj('String', 'Compare off');
        if ~isempty(btnCompare)
            set(btnCompare, 'String', 'Compare on');
        end
    else
        selectionMode = 'single';
        btnCompare = findobj('String', 'Compare on');
        if ~isempty(btnCompare)
            set(btnCompare, 'String', 'Compare off');
        end
    end
end

function toggleGraphCallback(src, ~)
    button_state = get(src, 'Value');
    
    if button_state == get(src, 'Max')
        btnShow = findobj('String', 'Show Graph');
        if ~isempty(btnShow)
            set(btnShow, 'String', 'Hide Graph');
        end
        showGraph(); % Show the graph when the button is pressed
        set(reset, 'visible', 'on');
       
    elseif button_state == get(src, 'Min')
        btnHide = findobj('String', 'Hide Graph');
        if ~isempty(btnHide)
            set(btnHide, 'String', 'Show Graph');
        end
        hideGraph(); % Hide the graph when the button is released
        set(reset, 'visible', 'off');
    end
end


    function popMenuCallback(~, ~)
    selectedOption = get(popMenu, 'Value');
    if selectedOption == 1  %  "Markers" 
        markerList.Visible = 'on';  
        markerList2.Visible = 'off';
        markerList3.Visible = 'off';
        markerList4.Visible = 'off';
        markerList5.Visible = 'off';
        markerList6.Visible = 'off';
        markerList7.Visible = 'off';
         set(markerList, 'CellSelectionCallback', {@cellSelected, markerList.Data});

elseif selectedOption == 2  %  "Analog" 
        markerList.Visible = 'off';  
        markerList2.Visible = 'on';
        markerList3.Visible = 'off';
        markerList4.Visible = 'off';
        markerList5.Visible = 'off';
        markerList6.Visible = 'off';
        markerList7.Visible = 'off';
         set(markerList2, 'CellSelectionCallback', {@cellSelected, markerList2.Data});

    elseif selectedOption == 3  %  "Angles" 
        markerList.Visible = 'off';  
        markerList2.Visible = 'off';
        markerList3.Visible = 'on';
        markerList4.Visible = 'off';
        markerList5.Visible = 'off';
        markerList6.Visible = 'off';
        markerList7.Visible = 'off';
         set(markerList3, 'CellSelectionCallback', {@cellSelected, markerList3.Data});
   
    elseif selectedOption == 4  %  "Forces" 
        markerList.Visible = 'off';  
        markerList2.Visible = 'off';
        markerList3.Visible = 'off';
        markerList4.Visible = 'on';
        markerList5.Visible = 'off';
        markerList6.Visible = 'off';
        markerList7.Visible = 'off';
         set(markerList4, 'CellSelectionCallback', {@cellSelected, markerList4.Data});
    
    elseif selectedOption == 5  %  "Powers" 
        markerList.Visible = 'off';  
        markerList2.Visible = 'off';
        markerList3.Visible = 'off';
        markerList4.Visible = 'off';
        markerList5.Visible = 'on';
        markerList6.Visible = 'off';
        markerList7.Visible = 'off';
         set(markerList5, 'CellSelectionCallback', {@cellSelected, markerList5.Data});
   
    elseif selectedOption == 6  %  "Moments" 
        markerList.Visible = 'off';  
        markerList2.Visible = 'off';
        markerList3.Visible = 'off';
        markerList4.Visible = 'off';
        markerList5.Visible = 'off';
        markerList6.Visible = 'on';
        markerList7.Visible = 'off';
         set(markerList6, 'CellSelectionCallback', {@cellSelected, markerList6.Data});
    
    elseif selectedOption == 7  %  "Scalars" 
        markerList.Visible = 'off';  
        markerList2.Visible = 'off';
        markerList3.Visible = 'off';
        markerList4.Visible = 'off';
        markerList5.Visible = 'off';
        markerList6.Visible = 'off';
        markerList7.Visible = 'on';
         set(markerList7, 'CellSelectionCallback', {@cellSelected, markerList7.Data});
    else
         markerList.Visible = 'off';  
        markerList2.Visible = 'off';
        markerList3.Visible = 'off';
        markerList4.Visible = 'off';
        markerList5.Visible = 'off';
        markerList6.Visible = 'off';
        markerList7.Visible = 'off';
    end
end


function selectAllCallback(src, ~)
  
    btnString = src.String;
    databox = markerList.Data;
    
    if strcmp(btnString, 'Deselect All')
        
        for i = 1:size(databox, 1)
            databox{i, 1} = false;
        end
        src.String = 'Select All';  
    else
      
        for i = 1:size(databox, 1)
            databox{i, 1} = true;
        end
        src.String = 'Deselect All'; 
    end
    
    set(markerList, 'Data', databox);
end


function checkBoxCallback(~, ~)
    
    DataBox = markerList.Data;
    checkedItems = [DataBox{:,1}];  
    activeMarkers = zeros(size(Markers_names));
    activeMarkers(checkedItems) = 1;
    updateFrameDisplay();
end

function playCallback(~, ~)
    playing = ~playing;

    if playing
        btnPlay = findobj('String', 'Play');
        if ~isempty(btnPlay)
            set(btnPlay, 'String', 'Pause');
        end
        updateAnimation();
    else
        btnPause = findobj('String', 'Pause');
        if ~isempty(btnPause)
            set(btnPause, 'String', 'Play');
        end
    end
end

function closeCallback(~, ~)
    stopLoop = true;
    closereq;
end

function speedCallback(~, ~)
    
end

%%%%%%%%%% load %%%%%%%%%%

function loadCallback(~, ~)

    [file, path] = uigetfile({'*.zoo;*.c3d'}, 'Sélectionnez un fichier ZOO ou C3D');

    if ~isempty(my3DArrow) && isvalid(my3DArrow)
        delete(my3DArrow);
        my3DArrow = [];
    end

     if ~isempty(my3DArrow2) && isvalid(my3DArrow2)
        delete(my3DArrow2);
        my3DArrow2 = [];
     end


for h = lineHandles'
    try
        if ishandle(h) && h ~= 0  
            delete(h);  
        end
    catch 
        
    end
end
lineHandles = [];  

for h = textHandles'
    try
        if ishandle(h) && h ~= 0
            delete(h);
        end
    catch 
        
    end
end
textHandles = [];  

    if file
        filepath = fullfile(path, file);
        loadZooData(filepath);

        %clear Bones
bonesToClear = {'LeftClavicle','LeftHumerus', 'LeftRadius','LeftHand','LeftFemur', 'LeftTibia','LeftFoot','LeftToe', 'Pelvis','RightClavicle','RightHumerus', 'RightRadius','RightHand', 'RightFemur', 'RightTibia','RightFoot','RightToe', 'Thorax', 'Head'};

% Loop through each bone and clear its patch
for i = 1:length(bonesToClear)
    bonePatch = findobj('Tag', bonesToClear{i});
    delete(bonePatch);
end
s = filesep;    % determine slash direction based on computer type
        d = which('director'); % returns path to ensemlber
        path = pathname(d) ;  % local folder where director resides
        bones = [path,'Cinema objects',s,'bones',s,'golembones'];
        openBones(bones);

        clear manipulateBoneByName;
        updateFrameDisplay();
        if Show_Bones ==1
        DisplayBones;
        end

        zoomArea = [-10000 10000 -10000 10000]; % Spécifiez les coordonnées de la zone de zoom
set(fig, 'WindowScrollWheelFcn', @(src, event) zoomFcn(event, ax, zoomArea));

        ListName1 = Markers_names;
        ListName2 = AnalogName;
        ListName3 = AnglesName;
        ListName4 = ForcesName;
        ListName5 = PowersName;
        ListName6 = MomentsName;
        ListName7 = ScalarsName;

          markerList = ListCheckBox(fig, [15 125 146.35 530], ListName1);
 
    if ~isempty (ListName2)
          markerList2 = ListCheckBox(fig, [15 125 146.35 530], ListName2);  
    end
  
   if ~isempty (ListName3)
          markerList3 = ListCheckBox(fig, [15 125 146.35 530], ListName3);  
   end

     if ~isempty (ListName4)
          markerList4 = ListCheckBox(fig, [15 125 146.35 530], ListName4);  
     end
      
     if ~isempty (ListName5)
          markerList5 = ListCheckBox(fig, [15 125 146.35 530], ListName5);  
     end
        
     if ~isempty (ListName6)
          markerList6 = ListCheckBox(fig, [15 125 146.35 530], ListName6);  
     end

     if ~isempty (ListName7)
          markerList7 = ListCheckBox(fig, [15 125 146.35 530], ListName7);  
     end
       
  activeMarkers = ones(1, numel(Markers_names));
        set(fileDisplayName, 'String', ['Load file : ', file]);
        markerList.Visible = 'on';
        markerList2.Visible = 'off';
        markerList3.Visible = 'off';
        markerList4.Visible = 'off';
        markerList5.Visible = 'off';
        markerList6.Visible = 'off';
        markerList7.Visible = 'off';
         set(markerList, 'CellSelectionCallback', {@cellSelected, markerList.Data});
            

         % Obtient le texte du bouton
    btnString = findobj('String', 'Select All');
    
    % Obtient les données actuelles de markerList
    databox = markerList.Data;
         
    if strcmp(btnString, 'Select All')
            
        for i = 1:size(databox, 1)
            databox{i, 1} = true;
        end
    else
        
        for i = 1:size(databox, 1)
            databox{i, 1} = false;
        end
    end
         
databoxTable = cell2table(databox, 'VariableNames', {'Value', 'Name'});
databoxTableall = cell2table(databox, 'VariableNames', {'Value', 'Name'});

indicesToRemove = ismember(databoxTable.Name, AnglesName);
indicesToRemove2 = ismember(databoxTable.Name, ForcesName);
indicesToRemove3 = ismember(databoxTable.Name, MomentsName);
indicesToRemove4 = ismember(databoxTable.Name, PowersName);
indicesToRemove5 = ismember(databoxTable.Name, ScalarsName);

allIndicesToRemove = indicesToRemove | indicesToRemove2 | indicesToRemove3 | indicesToRemove4 | indicesToRemove5;

databoxTable(allIndicesToRemove, :) = [];

index = ismember(databoxTableall, databoxTable);

Lines = find(index);
    
for i = 1:length(Lines)
    indexLine = Lines(i);
    databox{indexLine, 1} = true;
end

    checkedItems = [databox{:,1}];  
    activeMarkers = zeros(size(Markers_names));
    activeMarkers(checkedItems) = 1;
    updateFrameDisplay();

    set(markerList, 'Data', databox);
    updateFrameDisplay();
    end
    
end

function progressBarCallback(~, ~)
    if ~playing
        
        percentage_progress = get(progressBar, 'Value');
        current_frame = floor(percentage_progress);
        updateFrameDisplay();
        if Show_Bones ==1
        DisplayBones;
        end

    end
end


function updateTable(src, ~, ListName1, ListName2, ListName3, ListName4, ListName5, ListName6, ListName7)
    % Get the string from the search box
    fig = ancestor(src, 'figure');
    searchStr = get(findobj(fig, 'Tag', 'searchBox'), 'String');

    % Determine which marker list is visible and filter items based on the search string
    visibleMarkerLists = {markerList, markerList2, markerList3, markerList4, markerList5, markerList6, markerList7};
    listNames = {ListName1, ListName2, ListName3, ListName4, ListName5, ListName6, ListName7};

    for i = 1:length(visibleMarkerLists)
        if strcmp(visibleMarkerLists{i}.Visible, 'on')
            % Filter items based on the search string for the visible list
            filteredItems = listNames{i}(contains(listNames{i}, searchStr, 'IgnoreCase', true));

            % Update the visible list with filtered items
            databox = cell(numel(filteredItems), 2);
            databox(:, 1) = {false};
            databox(:, 2) = filteredItems';
            set(visibleMarkerLists{i}, 'Data', databox);
            break;
        end
    end
end


function cellSelected(~, event, dataCell)
    
    if ~isempty(event.Indices)
        row = event.Indices(1);
        col = event.Indices(2);
        selectedData = dataCell{row, col};       
 smallGraph = findobj(fig, 'Tag', 'SmallGraph');

    if ~isempty(smallGraph)      
        try
            selectedData = dataCell{row, col};
              x_values = 1:n_frames;

   if strcmp(markerList.Visible, 'on')
   plot(ax3, x_values, data.(num2str(selectedData)).line(:,1), 'r', ... % rouge
          x_values, data.(num2str(selectedData)).line(:,2), 'g', ... % vert
          x_values, data.(num2str(selectedData)).line(:,3), 'b');    % bleu
  
    elseif strcmp(markerList2.Visible, 'on')
       
        if strcmp(selectionMode, 'multiple')
            if isfield(data, 'ForceFx1') == 1
            index = 1:10:length(data.(num2str(selectedData)).line);
            elseif isfield(data, 'fx1') == 1
                index = 1:length(data.(num2str(selectedData)).line);
            end
            selectedCellsData{end+1} = selectedData;  % Ajouter les données à la liste
           
    hold(ax3, 'on'); 
    colors = ['r', 'b', 'g', 'c', 'm', 'y', 'k']; 
  
    for i = 1:length(selectedCellsData)
        colorIndex = mod(i-1, length(colors)) + 1;  
        currentColor = colors(colorIndex);
        plot(ax3, x_values, data.(num2str(selectedCellsData{i})).line(index,1), currentColor);
        
    end

    hold(ax3, 'off');
     
        elseif strcmp(selectionMode, 'single')
            if isfield(data, 'ForceFx1') == 1
            index = 1:10:length(data.(num2str(selectedData)).line);
            elseif isfield(data, 'fx1') == 1
                index = 1:length(data.(num2str(selectedData)).line);
            end
             plot(ax3, x_values, data.(num2str(selectedData)).line(index,1), 'r');
        end

  elseif strcmp(markerList3.Visible, 'on')
    
    if strcmp(selectionMode, 'multiple')
        
        index = 1:length(data.(num2str(selectedData)).line); 
        selectedCellsData{end+1} = selectedData;  % Add data to the list   
        hold(ax3, 'on'); 
        colors = ['r', 'b', 'g', 'c', 'm', 'y', 'k']; 
      
        for i = 1:length(selectedCellsData)
            colorIndex = mod(i-1, length(colors)) + 1;  
            currentColor = colors(colorIndex);
            plot(ax3, x_values, data.(num2str(selectedCellsData{i})).line(index,1), currentColor);
            
        end

        hold(ax3, 'off');
     
    elseif strcmp(selectionMode, 'single')
      
        index = 1:length(data.(num2str(selectedData)).line);       
         plot(ax3, x_values, data.(num2str(selectedData)).line(index,1), 'r');
    end

elseif strcmp(markerList4.Visible, 'on')
   
    if strcmp(selectionMode, 'multiple')
       
        index = 1:length(data.(num2str(selectedData)).line);  
        selectedCellsData{end+1} = selectedData;  % Add data to the list   
        hold(ax3, 'on'); 
        colors = ['r', 'b', 'g', 'c', 'm', 'y', 'k']; 
      
        for i = 1:length(selectedCellsData)
            colorIndex = mod(i-1, length(colors)) + 1;  
            currentColor = colors(colorIndex);
            plot(ax3, x_values, data.(num2str(selectedCellsData{i})).line(index,1), currentColor);
            
        end

        hold(ax3, 'off');
     
    elseif strcmp(selectionMode, 'single')
  
        index = 1:length(data.(num2str(selectedData)).line);     
         plot(ax3, x_values, data.(num2str(selectedData)).line(index,1), 'r');
    end

elseif strcmp(markerList5.Visible, 'on')
   
    if strcmp(selectionMode, 'multiple')
        index = 1:length(data.(num2str(selectedData)).line);    
       selectedCellsData{end+1} = selectedData;  % Add data to the list       
        hold(ax3, 'on'); 
        colors = ['r', 'b', 'g', 'c', 'm', 'y', 'k']; 
     
        for i = 1:length(selectedCellsData)
            colorIndex = mod(i-1, length(colors)) + 1;  
            currentColor = colors(colorIndex);
            plot(ax3, x_values, data.(num2str(selectedCellsData{i})).line(index,1), currentColor);
            
        end

        hold(ax3, 'off');
     
    elseif strcmp(selectionMode, 'single')
        index = 1:length(data.(num2str(selectedData)).line);     
         plot(ax3, x_values, data.(num2str(selectedData)).line(index,1), 'r');
    end

elseif strcmp(markerList6.Visible, 'on')
   
    if strcmp(selectionMode, 'multiple')
    
        index = 1:length(data.(num2str(selectedData)).line);      
        selectedCellsData{end+1} = selectedData;  % Add data to the list      
        hold(ax3, 'on'); 
       colors = ['r', 'b', 'g', 'c', 'm', 'y', 'k']; 
       
        for i = 1:length(selectedCellsData)
            colorIndex = mod(i-1, length(colors)) + 1;  
            currentColor = colors(colorIndex);
            plot(ax3, x_values, data.(num2str(selectedCellsData{i})).line(index,1), currentColor);
            
        end

        hold(ax3, 'off');
     
    elseif strcmp(selectionMode, 'single')
        index = 1:length(data.(num2str(selectedData)).line);
         plot(ax3, x_values, data.(num2str(selectedData)).line(index,1), 'r');
    end

elseif strcmp(markerList7.Visible, 'on')
   
    if strcmp(selectionMode, 'multiple')
  
        index = 1:length(data.(num2str(selectedData)).line);
        selectedCellsData{end+1} = selectedData;  % Add data to the list
        hold(ax3, 'on'); 
      colors = ['r', 'b', 'g', 'c', 'm', 'y', 'k']; 
   
    for i = 1:length(selectedCellsData)
        colorIndex = mod(i-1, length(colors)) + 1;  
        currentColor = colors(colorIndex);
        plot(ax3, x_values, data.(num2str(selectedCellsData{i})).line(index,1), currentColor);      
    end

    hold(ax3, 'off');
     
        elseif strcmp(selectionMode, 'single')
                index = 1:length(data.(num2str(selectedData)).line);
                plot(ax3, x_values, data.(num2str(selectedData)).line(index,1), 'r');
    end
  end
 
 set(ax3, 'Tag', 'SmallGraph','HitTest','off');

xlim = get(ax3, 'XLim'); 
ylim = get(ax3, 'YLim');  
totalHeight = ylim(2) - ylim(1);

  % Calculate top right corner position
posX = xlim(2); 
posY = ylim(2); 
spacing = totalHeight* 0.064;
textNames = {};

if ~isempty(selectedCellsData)
    oldTextObjects = findall(ax3, 'Type', 'text');
    delete(oldTextObjects);
    for i = 1:length(selectedCellsData)
        % Sélection de la couleur en fonction de l'index
        colorIndex = mod(i-1, length(colors)) + 1;  
        currentColor = colors(colorIndex);  
        set(ax3, 'Tag', 'SmallGraph', 'HitTest', 'off');

         % Calculate Y position for each text, assuming vertical spacing
        currentPosY = posY - (i-1) * spacing;

        str = sprintf('%s', num2str(selectedCellsData{i}));
        textNames{end+1} = str;

        hText = text(posX, currentPosY, str, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top');
        set(hText, 'Color', currentColor); 
        set(hText, 'FontSize', 10);  
    end
else
    set(ax3, 'Tag', 'SmallGraph', 'HitTest', 'off');
    hText = text(posX, posY, selectedData,'color','r', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top');
    set(hText, 'FontSize', 10,'color','k');  

end
        end
 
    xlabel(ax3, 'Frames');
  grid on;
ax3.XMinorGrid = 'on';
ax3.YMinorGrid = 'on';
     ax3.GridColor = [0 0 0];   
    ax3.MinorGridColor = [0.1 0.1 0.1];
    ax3.XColor = 'white';
    ax3.YColor = 'white';
          
    hold(ax3, 'on'); 
    currentFrameLine = line(ax3, [current_frame, current_frame], ax3.YLim, 'Color', 'k', 'LineWidth', 1);
    set(currentFrameLine, 'Tag', 'CurrentFrameLine'); 
    hold(ax3, 'off'); 
    else

    end
   end
end

%%%%%%% Markers names %%%%%%%

Markers_names = {};
Markers = struct();

dcm_obj = datacursormode(fig);
set(dcm_obj, 'UpdateFcn', @myDataCursorFunc);

function txt = myDataCursorFunc(~, event_obj)
    pos = get(event_obj, 'Position');
    markerName = findMarkerNameByPosition(pos);
    txt = markerName;
end

function name = findMarkerNameByPosition(position)
    name = 'Unknown'; % Default name is 'Unknown'

    % Iterate through marker names
    for i = 1:numel(Markers_names)
        marker = Markers_names{i};
        if isequal(Markers.(marker)(current_frame, :), position)
            name = marker;
            return;
        end
    end
end


%%%%%%%% Load zoo %%%%%%%%

function loadZooData(filepath)
    % Determine the file extension
    [~,~,ext] = fileparts(filepath);
    if strcmp(ext,'.c3d')
       data = c3d2zoo(filepath); % Convert c3d to zoo format
    else
        data = zload(filepath); % Load zoo format
    end

    % Get channel names excluding 'zoosystem'
    ch_names = setdiff(fieldnames(data), 'zoosystem');

    % Initialize an empty cell array to store marker names
    Markers_names = {};

    % Loop through each field in 'ch_names'
    for i = 1:length(ch_names)
        name = ch_names{i}; % Extract the current field name

        % Check if the 'line' field in the current structure has exactly 3 columns
        if isfield(data.(ch_names{i}), 'line')
            if size(data.(ch_names{i}).line, 2) == 3
                % If true, add the field name to 'Markers_names'
                Markers_names{end + 1} = name;
            end
        end
    end

    % Initialize the Markers structure outside the loop
    Markers = struct();

    for i = 1:numel(Markers_names)
        Markers.(Markers_names{i}) = data.(Markers_names{i}).line;
    end

    % Set initial state of playback and frame information
    playing = false;
    current_frame = 1;
    n_frames = size(data.(Markers_names{1}).line, 1);

    % Update activeMarkers to match the new Marker_names
    activeMarkers = ones(1, numel(Markers_names));
    
xFP = [];
yFP = [];
zFP = [];
xFP2 = [];
yFP2 = [];
zFP2 = [];
 xF1 = [];
 yF1 = [];
 zF1 = [];
 xF2 = [];
 yF2 = [];
 zF2 = [];
 OxF1 = [];
 OyF1 = [];
 OyF1 = [];
 OxF2 = [];
 OyF2 = [];
 OyF2 = [];

       if isfield(data.zoosystem.Analog, 'Channels') == 0
           AnalogName = data.zoosystem.Analog;
       else
           AnalogName = data.zoosystem.Analog.Channels;
       end

              Angles = data.zoosystem.OtherMetaInfo.Parameter.POINT.ANGLES.data';
[nRows, ~] = size(Angles); % Obtenir le nombre de lignes dans Angles
AnglesName = cell(nRows, 1); % Initialiser un cell array vide

for i = 1:nRows
    AnglesName{i} = strtrim(Angles(i, :)); % Extraire chaque ligne et la mettre dans une cellule, en supprimant les espaces de fin
end

  Forces = data.zoosystem.OtherMetaInfo.Parameter.POINT.FORCES.data';
[nRows, ~] = size(Forces); % Obtenir le nombre de lignes dans Angles
ForcesName = cell(nRows, 1); % Initialiser un cell array vide

for i = 1:nRows
    ForcesName{i} = strtrim(Forces(i, :)); % Extraire chaque ligne et la mettre dans une cellule, en supprimant les espaces de fin
end

  Moments = data.zoosystem.OtherMetaInfo.Parameter.POINT.MOMENTS.data';
[nRows, ~] = size(Moments); % Obtenir le nombre de lignes dans Angles
MomentsName = cell(nRows, 1); % Initialiser un cell array vide

for i = 1:nRows
    MomentsName{i} = strtrim(Moments(i, :)); % Extraire chaque ligne et la mettre dans une cellule, en supprimant les espaces de fin
end

  Powers = data.zoosystem.OtherMetaInfo.Parameter.POINT.POWERS.data';
[nRows, ~] = size(Powers); % Obtenir le nombre de lignes dans Angles
PowersName = cell(nRows, 1); % Initialiser un cell array vide

for i = 1:nRows
    PowersName{i} = strtrim(Powers(i, :)); % Extraire chaque ligne et la mettre dans une cellule, en supprimant les espaces de fin
end

  Scalars = data.zoosystem.OtherMetaInfo.Parameter.POINT.SCALARS.data';
[nRows, ~] = size(Scalars); % Obtenir le nombre de lignes dans Angles
ScalarsName = cell(nRows, 1); % Initialiser un cell array vide

for i = 1:nRows
    ScalarsName{i} = strtrim(Scalars(i, :)); % Extraire chaque ligne et la mettre dans une cellule, en supprimant les espaces de fin
end


set(progressBar, 'Max', n_frames,'sliderstep',[1/(n_frames-1) 10/(n_frames-1)]);

uicontrol( 'Style', 'text', 'Position', [795 65 35 15], 'String', [num2str(floor(n_frames))], 'FontSize', 10.5);
  
xpos = 352.5;
for i = 1:1:9
uicontrol( 'Style', 'text', 'Position', [xpos 19.5 35 14], 'String', [num2str(round((i*n_frames)/10))], 'FontSize', 10);
    xpos = xpos + 47;
end
     
 if isfield(data.zoosystem.Analog, 'FPlates') == 1 && isfield(data.zoosystem.Analog.FPlates,'CORNERS') == 1 && ~isempty(data.zoosystem.Analog.FPlates.CORNERS)

xFP = [data.zoosystem.Analog.FPlates.CORNERS(1,1,1) data.zoosystem.Analog.FPlates.CORNERS(1,2,1) data.zoosystem.Analog.FPlates.CORNERS(1,3,1) data.zoosystem.Analog.FPlates.CORNERS(1,4,1)]; 
yFP = [data.zoosystem.Analog.FPlates.CORNERS(2,1,1) data.zoosystem.Analog.FPlates.CORNERS(2,2,1) data.zoosystem.Analog.FPlates.CORNERS(2,3,1) data.zoosystem.Analog.FPlates.CORNERS(2,4,1)];
zFP = [data.zoosystem.Analog.FPlates.CORNERS(3,1,1) data.zoosystem.Analog.FPlates.CORNERS(3,2,1) data.zoosystem.Analog.FPlates.CORNERS(3,3,1) data.zoosystem.Analog.FPlates.CORNERS(3,4,1)]; 

xFP2 = [data.zoosystem.Analog.FPlates.CORNERS(1,1,2) data.zoosystem.Analog.FPlates.CORNERS(1,2,2) data.zoosystem.Analog.FPlates.CORNERS(1,3,2) data.zoosystem.Analog.FPlates.CORNERS(1,4,2)]; 
yFP2 = [data.zoosystem.Analog.FPlates.CORNERS(2,1,2) data.zoosystem.Analog.FPlates.CORNERS(2,2,2) data.zoosystem.Analog.FPlates.CORNERS(2,3,2) data.zoosystem.Analog.FPlates.CORNERS(2,4,2)];
zFP2 = [data.zoosystem.Analog.FPlates.CORNERS(3,1,2) data.zoosystem.Analog.FPlates.CORNERS(3,2,2) data.zoosystem.Analog.FPlates.CORNERS(3,3,2) data.zoosystem.Analog.FPlates.CORNERS(3,4,2)]; 

OxF1 = (data.zoosystem.Analog.FPlates.CORNERS(1,1,1) + data.zoosystem.Analog.FPlates.CORNERS(1,2,1))/2;
OyF1 = (data.zoosystem.Analog.FPlates.CORNERS(2,2,1) + data.zoosystem.Analog.FPlates.CORNERS(2,3,1))/2;
OzF1 = 0;
OxF2 = (data.zoosystem.Analog.FPlates.CORNERS(1,1,2) + data.zoosystem.Analog.FPlates.CORNERS(1,2,2))/2;
OyF2 = (data.zoosystem.Analog.FPlates.CORNERS(2,2,2) + data.zoosystem.Analog.FPlates.CORNERS(2,3,2))/2;
OzF2 = 0;

elseif isfield(data.zoosystem, 'Parameter') == 1

    if isfield(data.zoosystem.Parameter, 'FORCE_PLATFORM') == 1

xFP = [data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(1, :)  data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(4, :) data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(7, :) data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(10, :)]; 
yFP = [data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(2, :) data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(5, :) data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(8, :) data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(11, :)];
zFP = [data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(3, :) data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(6, :) data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(9, :) data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(12, :)]; 

xFP2 = [data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(13, :) data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(16, :) data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(19, :) data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(22, :)]; 
yFP2 = [data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(14, :) data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(17, :) data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(20, :) data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(23, :)];
zFP2 = [data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(15, :) data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(18, :) data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(21, :) data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(24, :)]; 

OxF1 = (data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(1, :) + data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(4, :))/2;
OyF1 = (data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(5, :) + data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(8, :))/2;
OzF1 = 0;
OxF2 = (data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(13, :) + data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(16, :))/2;
OyF2 = (data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(17, :) + data.zoosystem.Parameter.FORCE_PLATFORM.CORNERS.data(20, :))/2;
OzF2 = 0;

    end
end

if isfield(data, 'ForceFx1') == 1

    xF1 = data.ForceFx1.line;
    yF1 = data.ForceFy1.line;
    zF1 = data.ForceFz1.line;
    xF2 = data.ForceFx2.line;
    yF2 = data.ForceFy2.line;
    zF2 = data.ForceFz2.line;
      Force_arrow = [xF1 yF1 zF1];
    Force_arrow2 = [xF2 yF2 zF2];
     Force_arrow_sampled = Force_arrow(1:10:end, :);
    Force_arrow_sampled2 = Force_arrow2(1:10:end, :);  

elseif isfield(data, 'fx1') == 1

    xF1 = data.fx1.line;
    yF1 = data.fy1.line;
    zF1 = data.fz1.line;
    xF2 = data.fx2.line;
    yF2 = data.fy2.line;
    zF2 = data.fz2.line;
      Force_arrow = [xF1 yF1 zF1];
    Force_arrow2 = [xF2 yF2 zF2]; 
      Force_arrow_sampled = Force_arrow(1:end, :);
    Force_arrow_sampled2 = Force_arrow2(1:end, :); 

end

    if ~isempty(my3DArrow) && isvalid(my3DArrow)
        delete(my3DArrow);
        my3DArrow = [];
    end

     if ~isempty(my3DArrow2) && isvalid(my3DArrow2)
        delete(my3DArrow2);
        my3DArrow2 = [];
    end

end


%%%%%%% Show/Hide Graph %%%%%%%

function showGraph()
    str = 'Select data';
    ax3 = axes('Parent', fig, 'Position', [0.2 0.7 0.28 0.28], 'Box', 'on');
    set(ax3, 'Tag', 'SmallGraph', 'HitTest', 'off');

    % Get the current x and y axis limits
    xlim = get(ax3, 'XLim'); 
    ylim = get(ax3, 'YLim'); 

    % Calculate the top right corner position
    posX = xlim(2); % Upper limit of the x-axis
    posY = ylim(2); % Upper limit of the y-axis
    hText = text(posX, posY, str, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top');

    % Modify the font size of the text
    set(hText, 'FontSize', 14); 

    % Adjust the margin for better text positioning
    set(hText, 'Units', 'normalized', 'Position', [0.98, 0.98, 0]); % Values can be adjusted for better positioning

    % Set grid properties
    grid on;
    ax3.XMinorGrid = 'on';
    ax3.YMinorGrid = 'on';
    ax3.GridColor = [0 0 0];   
    ax3.MinorGridColor = [0.1 0.1 0.1];
    ax3.XColor = 'white';
    ax3.YColor = 'white';
    title(ax3, 'My Graph');
    xlabel(ax3, 'Frames');
    ylabel(ax3, 'Y-axis');

    % Add a vertical line at the current frame's X position
    hold(ax3, 'on'); % Keep the current graph and add the line
    currentFrameLine = line(ax3, [current_frame, current_frame], ax3.YLim, 'Color', 'k', 'LineWidth', 1);
    set(currentFrameLine, 'Tag', 'CurrentFrameLine'); % Tag for easy identification
    hold(ax3, 'off'); % Release the graph
end

function hideGraph()
    % Code to hide the graph.
    % Find the axis with the tag and delete it.
    smallGraph = findobj(fig, 'Tag', 'SmallGraph');
    if ~isempty(smallGraph)
        delete(smallGraph);
    end
end

function updateGraph()
    currentFrameLine = findobj(ax3, 'Tag', 'CurrentFrameLine');
    if ~isempty(currentFrameLine)
        set(currentFrameLine, 'XData', [current_frame, current_frame]);
    end
end

%%%%%%% Bones %%%%%%%

  function DisplayBones

  AxBones = findobj('Tag','3Dspace');

% Manipulate bones by name using loop
bonesToManipulate = {'LeftClavicle','LeftHumerus', 'LeftRadius','LeftHand','LeftFemur', 'LeftTibia','LeftFoot','LeftToe', 'Pelvis','RightClavicle','RightHumerus', 'RightRadius','RightHand', 'RightFemur', 'RightTibia','RightFoot','RightToe', 'Thorax', 'Head'};
for i = 1:length(bonesToManipulate)
    manipulateBoneByName(AxBones, bonesToManipulate{i},filepath,current_frame);
end  
    
  end


%%%%%%% Animation %%%%%%%

function updateAnimation()
    speed = get(speedSlider, 'Value');

    while ~stopLoop
        if playing
            current_frame = min(current_frame + ceil(1*speed), n_frames);
            updateFrameDisplay();
            if Show_Bones == 1
            DisplayBones;
            end
            
            if current_frame >= n_frames
                playing = false;
                btnPause = findobj('String', 'Pause');
                if ~isempty(btnPause)
                    set(btnPause, 'String', 'Play');
                end
            else
                pause(0.00001);
            end
        else
            pause(0.01);
        end
    end
end

    function updateFrameDisplay()
    
        persistent sc hFP hFP2 
 
hold(ax, 'on');

      % Update arrow
      
 if current_frame <= size(Force_arrow_sampled, 1) 
        position_actuelle = Force_arrow_sampled(current_frame, :);
        
        xF1_actuel = -position_actuelle(1);
        yF1_actuel = -position_actuelle(2);
        zF1_actuel = -position_actuelle(3);

        u = xF1_actuel ;
        v = yF1_actuel ;
        w = zF1_actuel ;  
        
    if ~isempty(xFP)
        if zF1_actuel ~= 0
            if isempty(my3DArrow) || ~isvalid(my3DArrow)
                my3DArrow = quiver3(ax, OxF1, OyF1, OzF1, u, v, w,'Color', [1, 0.5, 0], 'LineWidth', 3.2);
            else
                if ~isequal([u, v, w], get(my3DArrow, {'UData', 'VData', 'WData'}))
                set(my3DArrow, 'UData', u, 'VData', v, 'WData', w);
                 end
            end
        end
    end
 end


  if current_frame <= size(Force_arrow_sampled2, 1) 
        position_actuelle2 = Force_arrow_sampled2(current_frame, :);
    
        xF2_actuel = -position_actuelle2(1);
        yF2_actuel = -position_actuelle2(2);
        zF2_actuel = -position_actuelle2(3);

        u2 = xF2_actuel ;
        v2 = yF2_actuel ;
        w2 = zF2_actuel ;
    if ~isempty(xFP2)
        if zF2_actuel ~= 0
            if isempty(my3DArrow2) || ~isvalid(my3DArrow2)
                my3DArrow2 = quiver3(ax, OxF2, OyF2, OzF2, u2, v2, w2, 'Color',[1, 0.5, 0], 'LineWidth', 3.2);
            else
                if ~isequal([u2, v2, w2], get(my3DArrow2, {'UData', 'VData', 'WData'}))
                set(my3DArrow2, 'UData', u2, 'VData', v2, 'WData', w2);
                 end
            end
        end
    end
 end

     if ~isempty(my3DArrow) && isvalid(my3DArrow) && zF1_actuel == 0
        delete(my3DArrow);  
         my3DArrow = [];
     end

       if ~isempty(my3DArrow2) && isvalid(my3DArrow2) && zF2_actuel == 0
        delete(my3DArrow2); 
         my3DArrow2 = [];
       end
   
    coords = extractActiveMarkerCoordinates(); 
    colors = color();  

    if isempty(sc) || ~isvalid(sc) || ~isequal(size_factor, previous_size_factor) || ~isequal(colors, previous_colors)
       delete(sc)
       if size_factor == 0
       else
        sc = scatter3(ax, coords(:, 1), coords(:, 2), coords(:, 3), size_factor, colors, 'filled');
        previous_size_factor = size_factor;
        previous_colors = colors;

       end
    else
        set(sc, 'XData', coords(:, 1), 'YData', coords(:, 2), 'ZData', coords(:, 3));
    end

    % Update patch
    if isempty(hFP) || ~isvalid(hFP)
        hFP = patch(ax, 'XData', xFP, 'YData', yFP, 'ZData', zFP, 'FaceColor', 'yellow');
        hFP.FaceAlpha = 0.7;
        quiver3(ax, OxF1, OyF1, OzF1, 0, 0, -250, 'b', 'LineWidth', 1.7);
        quiver3(ax, OxF1, OyF1, OzF1, 0, 300, 0, 'g', 'LineWidth', 1.7); 
        quiver3(ax, OxF1, OyF1, OzF1, 300, 0, 0, 'r', 'LineWidth', 1.7); 
    else
        set(hFP, 'XData', xFP, 'YData', yFP, 'ZData', zFP);
        hFP.FaceAlpha = 0.7; 
    end
    
    set(hFP, 'PickableParts', 'none');
  
    if isempty(hFP2) || ~isvalid(hFP2)
        hFP2 = patch(ax, 'XData', xFP2, 'YData', yFP2, 'ZData', zFP2, 'FaceColor', 'yellow');
         hFP2.FaceAlpha = 0.7;
            quiver3(ax, OxF2, OyF2, OzF2, 0, 0, -250, 'b', 'LineWidth', 1.7);
            quiver3(ax, OxF2, OyF2, OzF2, 0, 300, 0, 'g', 'LineWidth', 1.7); 
            quiver3(ax, OxF2, OyF2, OzF2, 300, 0, 0, 'r', 'LineWidth', 1.7); 
    else
        set(hFP2, 'XData', xFP2, 'YData', yFP2, 'ZData', zFP2);
        hFP2.FaceAlpha = 0.7;
    end
  
    set(hFP2, 'PickableParts', 'none'); 
   percentage_progress = floor(current_frame);  
    set(progressBar, 'Value', percentage_progress); 
    set(frameLabel, 'String', ['Frame: ' num2str(floor(current_frame))]); 
    updateGraph(); 
  
    if ~isempty(Markers_names)  
        events = extractEventsForAllMarkers();  
        plotEventsOnBar(events); 
    end
end


%%%%%%% Events Function %%%%%%%

function events = extractEventsForAllMarkers()
    % Pre-allocate with an estimated size (adjust based on data)
    estimated_num_events = 100; 
    events(estimated_num_events) = struct('marker', [], 'event', [], 'frame', []);
    
    event_count = 0;
    for i = 1:numel(Markers_names)
        marker = Markers_names{i};
        marker_data = data.(marker); % Access once and use multiple times

        if isfield(marker_data, 'event')
            markerEvents = fieldnames(marker_data.event);

            for j = 1:numel(markerEvents)
                event_count = event_count + 1;
                events(event_count) = struct('marker', marker, 'event', markerEvents{j}, 'frame', marker_data.event.(markerEvents{j}));
            end
        end
    end
    
    % Remove unused entries after the loop
    events(event_count+1:end) = [];
end

function plotEventsOnBar(events)
    num_events = numel(events);
    if isempty(lineHandles) || length(lineHandles) ~= num_events
        % Delete old handles to prevent memory clutter
        delete(lineHandles);
        delete(textHandles);

        % Create new handles
        lineHandles = gobjects(num_events, 1);
        textHandles = gobjects(num_events, 1);

        for i = 1:num_events
            event = events(i);
            x_event = event.frame / n_frames;
            lineHandles(i) = line(axBar, [x_event(1, 1), x_event(1, 1)], [0, 4], 'Color', 'red', 'LineWidth', 2);
            textHandles(i) = text(axBar, x_event(1, 1), 5.55, event.event, 'HorizontalAlignment', 'center', 'Visible', 'off');
            
            % Use an anonymous function to minimize function calls
            set(lineHandles(i), 'ButtonDownFcn', @(src,evt) toggleTextVisibility(event.event));
        end
    else
        % Update existing handles
        for i = 1:num_events
            event = events(i);
            x_event = event.frame / n_frames;
            set(lineHandles(i), 'XData', [x_event(1, 1), x_event(1, 1)]);
            set(textHandles(i), 'Position', [x_event(1, 1), 5.55], 'String', event.event);
        end
    end
end

function toggleTextVisibility(eventName)
    textHandle = findobj(axBar, 'Type', 'Text', 'String', eventName);
    currentVisibility = get(textHandle, 'Visible');
    if strcmp(currentVisibility, 'on')
        set(textHandle, 'Visible', 'off');
    else
        set(textHandle, 'Visible', 'on');
    end
end

function coords = extractActiveMarkerCoordinates()
    activeIdx = find(activeMarkers);
    validIdx = activeIdx <= numel(Markers_names); % Logical array: true for valid, false for invalid
    
    if any(~validIdx)
        warning('Invalid indices detected and will be ignored: %s', mat2str(activeIdx(~validIdx)));
        activeIdx = activeIdx(validIdx); % Keep only valid indices
    end
    
    coords = zeros(numel(activeIdx), 3);
    for i = 1:numel(activeIdx)
        marker = Markers_names{activeIdx(i)};
        coords(i, :) = Markers.(marker)(current_frame, :);
    end
end

function showAddEventWindow(~, ~)
    selectedMarkerName = selectedData;

    % Create a new window
    h = figure('Position', [500 500 300 200], 'MenuBar', 'none', 'Name', 'Add Event', 'NumberTitle', 'off');

    % Display the selected marker name
    uicontrol(h, 'Style', 'text', 'Position', [10 160 280 20], 'String', ['Marker: ', selectedMarkerName]);

    % Two text boxes for the event name and frame
    uicontrol(h, 'Style', 'text', 'Position', [10 120 100 20], 'String', 'Event Name:');
    eventNameEdit = uicontrol(h, 'Style', 'edit', 'Position', [120 120 160 25]);

    uicontrol(h, 'Style', 'text', 'Position', [10 80 100 20], 'String', 'Frame:');
    frameEdit = uicontrol(h, 'Style', 'edit', 'Position', [120 80 160 25], 'String', num2str(current_frame));

    % Button to save
    uicontrol(h, 'Style', 'pushbutton', 'Position', [100 20 100 40], 'String', 'Save', 'Callback', @saveEventData);

    function saveEventData(~, ~)
        eventName = get(eventNameEdit, 'String');
        frameNum = str2double(get(frameEdit, 'String'));

        if isempty(eventName) || isnan(frameNum)
            msgbox('Please enter a valid name and frame number.', 'Error', 'error');
            return;
        end

        if ~isfield(data, selectedMarkerName)
            data.(selectedMarkerName) = struct();
        end
        if ~isfield(data.(selectedMarkerName), 'event')
            data.(selectedMarkerName).event = struct();
        end

        data.(selectedMarkerName).event.(eventName) = frameNum;

        zsave(filepath, data);

        close(h);
        msgbox('Event saved!', 'Success');
    end
end

function showDeleteEventWindow(~, ~)
    % Create a new window
    h = figure('Position', [500 500 350 300], 'MenuBar', 'none', 'Name', 'Delete Event', 'NumberTitle', 'off', 'CloseRequestFcn', @onClose);

    % ListBox showing all events
    eventList = uicontrol(h, 'Style', 'listbox', 'Position', [10 50 330 240], 'String', getEventNames(), 'Value', 1); 

    % Button to delete the selected event
    uicontrol(h, 'Style', 'pushbutton', 'Position', [125 10 100 30], 'String', 'Delete', 'Callback', @deleteEvent);

    function eventNames = getEventNames()
        eventNames = {};
        for i = 1:numel(Markers_names)
            marker = Markers_names{i};
            if isfield(data.(marker), 'event')
                markerEvents = fieldnames(data.(marker).event);
                for j = 1:numel(markerEvents)
                    eventNames{end + 1} = sprintf('%s: %s', marker, markerEvents{j});
                end
            end
        end
    end

    function deleteEvent(~, ~)
        selectedIndex = get(eventList, 'Value');
        eventNames = get(eventList, 'String');
        if selectedIndex > 0 % Ensure an item is selected
            fullEventName = eventNames{selectedIndex};
            [marker, eventName] = strtok(fullEventName, ':');
            eventName = strtrim(eventName(2:end)); % Remove space and colon
            
            % Delete the event from the data structure
            if isfield(data.(marker), 'event') && isfield(data.(marker).event, eventName)
                data.(marker).event = rmfield(data.(marker).event, eventName);
                zsave(filepath, data); % Assuming 'zsave' is your custom save function
            end
            cla(axBar);

            % Redefine axBar properties if altered by cla()
            set(axBar, 'Visible', 'off', 'XLim', [0, 1], 'YLim', [-2, 5], 'HitTest', 'off');

            % Recreate necessary graphical elements
            for i = 0:0.1:1
                line([i i], [-2 5], 'Color', 'k', 'Parent', axBar);
            end 
            
            events = extractEventsForAllMarkers(); % Retrieve current events after deletion
            plotEventsOnBar(events); % Redraw the event bar with current events

            % Update the event list
            set(eventList, 'String', getEventNames());
            set(eventList, 'Value', max(1, selectedIndex - 1));
        end
    end

    function onClose(~, ~)
        delete(h);  
    end
end


%%%%%% Option Button %%%%%%%

function editAppearanceCallback(~, ~)
    h = figure('Position', [500 500 300 200], 'MenuBar', 'none', 'Name', 'Edit Appearance', 'NumberTitle', 'off');

    % Marker Size controls
    uicontrol(h, 'Style', 'text', 'Position', [10 160 100 20], 'String', 'Marker Size:');
    markerSizeEdit = uicontrol(h, 'Style', 'slider', 'Position', [120 160 120 25], 'Backgroundcolor', [1 1 1], 'Min', 0, 'Max', 30, 'Value', size_factor, 'SliderStep', [1/(31-1) 2/(31-1)], 'Callback', @sizeCallback);
    sizeLabel = uicontrol(h, 'Style', 'text', 'Position', [245 160 30 25], 'String', num2str(floor(get(markerSizeEdit, 'Value'))), 'FontSize', 11);
    
    function sizeCallback(~, ~)
        set(sizeLabel, 'String', num2str(floor(get(markerSizeEdit, 'Value'))));
    end

    % Marker Color controls
    uicontrol(h, 'Style', 'text', 'Position', [10 120 100 20], 'String', 'Marker Color:');
    markerColorEdit = uicontrol(h, 'Style', 'edit', 'Position', [120 120 160 25],'String', color);

    % Apply button
    uicontrol(h, 'Style', 'pushbutton', 'Position', [100 20 100 40], 'String', 'Apply', 'Callback', @applyAppearance);

    function applyAppearance(~, ~)
        markerSize = get(markerSizeEdit, 'Value');
        markerColor = get(markerColorEdit, 'String');
        
        if isnan(markerSize) || isempty(markerColor)
            msgbox('Please enter a valid size and color.', 'Error', 'error');
            return;
        end

        size_factor = markerSize;
        color = markerColor;
        close(h);
        updateFrameDisplay();
    end
end

end


