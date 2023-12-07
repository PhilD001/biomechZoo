function DirectorV4_3()

global   markerList3 markerList4 markerList5 markerList6 markerList7 AnglesName ForcesName MomentsName PowersName ScalarsName playing data current_frame searchStr textNames color searchBox reset filepath stopLoop n_frames size_factor speedSlider Markers Markers_names progressBar frameLabel activeMarkers;

 global lbl xd yd nxd nyd nzd hline ax ax2 ax3 OyF1 OxF1 OzF1 xFP  xF1  yF1  zF1  xF2  yF2  zF2 yFP zFP OyF2 OxF2 OzF2 xFP2 yFP2 zFP2 xcol my3DArrow Force_arrow_sampled Force_arrow my3DArrow2 Force_arrow_sampled2 Force_arrow2 ycol zcol str lineHandles ListName3 ListName1 ListName2 ListName4 ListName5 ListName6 ListName7 textHandles AnalogName popMenu markerList selectedData selectionMode selectedCellsData;
     
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
 
 
 lbl = (-3200:330:3200);
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
        
xcol = [1 0 0]; % red color for x axis arrow
ycol = [0 1 0]; % green color for y axis arrows
zcol = [0 0 1]; % blue color for z axis arrows

    fig = [];
     markerList = [];
    markerList2 = [];
    markerList3 = [];
    markerList4 = [];
    markerList5 = [];
    markerList6 = [];
    markerList7 = [];
    searchBox = [];
    fileDisplayName = [];
    axBar = [];
    ax=[];
    initGlobals();
    createUI();
    hline=[];
    ax2 = [];
selectionMode = 'single'; 
selectedCellsData = {};
str = [];
previous_size_factor = [];
previous_colors = [];
 textNames ={};

    function initGlobals()
        playing = false;
        current_frame = 1;
        size_factor = 7;
        color = 'w';
        stopLoop = false;
        activeMarkers = [];
    end

%%%%%%% Creation UI %%%%%%%

  function createUI()
        fig = figure('Position', [200, 50, 1100, 800], 'Color', [0 0 0], 'Name', 'Director', 'NumberTitle', 'off');
        ax = axes('Parent', fig, 'Position', [0.136, 0.001, 0.99, 0.99], 'XLim', [-3200, 3200], 'YLim', [-3200, 3200], 'ZLim', [-700, 2100]);
        grid on;
        view(3);
        set(ax, 'Box', 'off');  
        set(ax,'visible','off')  
       hline = line('parent',ax,'xdata',nxd,'ydata',nyd,'zdata',nzd,'color',[.44 .44 .44],'LineStyle','-');
         set(hline, 'PickableParts', 'none');

          ax2 = axes('parent',fig,'unit','normalized','position',[0.001 0.001 .4 .4],'cameraviewangle',...
            40,'cameraposition',[2 2 2],'cameratarget',[0 0 0],'color',[.8 .8 .8],'visible','off','tag','orientation window');
           set(ax2, 'hitTest', 'off');
        
        [x,y,z] = arrow([0 0 0],[1 0 0],4);
        surface('parent',ax2,'xdata',x,'ydata',y,'zdata',z,'facecolor',xcol,'edgecolor','none','facelighting','gouraud','tag','x');
        text(1.1 , 0 , 0, 'x','Color',[1 1 1]);
        
        [x,y,z] = arrow([0 0 0],[0 1 0],4);
        surface('parent',ax2,'xdata',x,'ydata',y,'zdata',z,'facecolor',ycol,'edgecolor','none','facelighting','gouraud', 'tag','y');
        text(0 , 1.2 , 0, 'y','Color',[1 1 1]);
        
        [x,y,z] = arrow([0 0 0],[0 0 1],4);
        surface('parent',ax2,'xdata',x,'ydata',y,'zdata',z,'facecolor',zcol,'edgecolor','none','facelighting','gouraud','tag','z');
        text(0 , 0 , 1.1, 'z','Color',[1 1 1]);

         [az, el] = view(ax); % Obtenez l'angle de vue actuel de 'ax'
    view(ax2, az, el); % Mettez à jour la fenêtre d'orientation avec le même angle de
       
% Créez un écouteur pour les changements de position de la caméra dans 'ax'
addlistener(ax, 'View', 'PostSet', @(~,~) updateOrientationWindow(ax, ax2));

% Définissez la fonction de mise à jour
function updateOrientationWindow(ax, ax2)
    [az, el] = view(ax); 
    view(ax2, az, el);
end

reset =  uicontrol(fig, 'Style', 'pushbutton', 'String', 'reset', 'FontSize', 10, 'Position', [489 785 40 17], 'Callback', @resetCallback);
 set(reset,'visible','off');

       controlPanel = uipanel('Position', [0.155, 0.01, 0.84, 0.12], 'BackgroundColor',[.95 .95 .95] , 'BorderWidth', 2, 'BorderColor', 'black');
        uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Play', 'FontSize', 14, 'Position', [32 15 65 45], 'Callback', @playCallback);
        speedSlider = uicontrol(controlPanel, 'Style', 'slider', 'Position', [811 16 90 19],'backgroundcolor',[1 1 1],'Min', 0.2, 'Max', 2.5, 'Value', 1.3, 'SliderStep', [0.1, 0.2], 'Callback', @speedCallback);
        uicontrol(controlPanel, 'Style', 'text', 'Position', [759 16 55 20], 'String', 'Speed:', 'FontSize', 10);
        uicontrol(controlPanel, 'Style', 'pushbutton', 'String', 'Option', 'FontSize', 11, 'Position', [790 45 100 30], 'Callback', @editAppearanceCallback);
        uicontrol(controlPanel, 'Style', 'text', 'Position', [135 55 10 15], 'String', '1', 'FontSize', 12);
        uicontrol(controlPanel,'Style', 'pushbutton', 'String', 'Update','Position', [32 60 50 25], 'Callback', @checkBoxCallback);
     
        % ProgressBar
       progressBar = uicontrol(controlPanel, 'Style', 'slider', 'Position', [138 25 491 23],'backgroundcolor',[1 1 1], 'Min', 1, 'Max', 100, 'Value', 1,'sliderstep',[1/(100-1) 10/(100-1)], 'Callback', @progressBarCallback);
        frameLabel = uicontrol(controlPanel, 'Style', 'text', 'Position', [627.5 23 83 23], 'String', 'Frame: 1', 'FontSize', 11);
       
        %Bar évènement 
    axBar = axes('Parent', controlPanel, 'Position', [0.162, 0.2, 0.5085, 0.57], 'Visible', 'off', 'XLim', [0, 1], 'YLim', [-2, 5]);
    set(axBar,'HitTest','off');
   
    for i = 0:0.1:1
        line([i i], [-2 5], 'Color', 'k', 'Parent', axBar);
    end
 

      controlPanel2 = uipanel('Position', [0.004, 0.01, 0.15, 0.985], 'BackgroundColor', [.95 .95 .95], 'BorderWidth', 2, 'BorderColor', 'black');
        uicontrol(controlPanel2, 'Style', 'pushbutton', 'String', 'Close', 'Position', [85 15 55 30], 'Callback', @closeCallback);
        uicontrol(controlPanel2, 'Style', 'pushbutton', 'String', 'Load', 'Position', [20 15 55 30], 'Callback', @loadCallback);
        uicontrol(controlPanel2, 'Style', 'togglebutton', 'String', 'Show Graph', 'Position', [89 88 65 25], 'Callback', @toggleGraphCallback);
        uicontrol(controlPanel2, 'Style', 'togglebutton', 'String', 'Compare off', 'Position', [8 88 68 25], 'Callback', @toggleSelectionMode);
        uicontrol(controlPanel2, 'Style', 'pushbutton', 'Position', [80 55 60 25], 'String', 'Delete event', 'Callback', @showDeleteEventWindow);
       
         markerList = ListCheckBox(fig, [15 125 146.35 530], {});
    markerList2 = ListCheckBox(fig, [15 125 146.35 530], {});
     markerList3 = ListCheckBox(fig, [15 125 146.35 530], {});
     markerList4 = ListCheckBox(fig, [15 125 146.35 530], {});
     markerList5 = ListCheckBox(fig, [15 125 146.35 530], {});
     markerList6 = ListCheckBox(fig, [15 125 146.35 530], {});
     markerList7 = ListCheckBox(fig, [15 125 146.35 530], {});
 % Ajoutez le CellSelectionCallback à markerList
        set(markerList, 'CellSelectionCallback', {@cellSelected, markerList.Data});

        uicontrol(controlPanel2, 'Style', 'pushbutton', 'String', 'Deselect All', 'Position', [83 670 65 25], 'Callback', @selectAllCallback);
        uicontrol(controlPanel2, 'Style', 'pushbutton', 'String', 'Add event', 'Position', [20 55 60 25], 'Callback', @showAddEventWindow);
          searchBox = uicontrol(controlPanel2, 'Style', 'edit', 'Position', [10 700 140 25], 'Callback', {@updateTable, ListName1, ListName2, ListName3, ListName4, ListName5, ListName6, ListName7}, 'Tag', 'searchBox');
        uicontrol(controlPanel2, 'Style', 'pushbutton', 'String', 'Search', 'Position', [12 670 65 25], 'Callback', {@updateTable, ListName1, ListName2, ListName3,ListName4, ListName5, ListName6, ListName7});
        fileDisplayName = uicontrol(controlPanel2, 'Style', 'text', 'String', 'No file loaded', 'Units', 'normalized', 'Position', [0 0.95 1 0.05], 'FontSize', 11, 'BackgroundColor', [0.9 0.9 0.9]);
   menuOptions = {'Markers','Analog','Angles','Forces','Powers','Moments','Scalars'};
    popMenu = uicontrol(controlPanel2, 'Style', 'popupmenu', 'String', menuOptions, 'Position', [8 635 146 25], 'Callback', @popMenuCallback);
markerList.Visible = 'on';
markerList2.Visible = 'off';
markerList3.Visible = 'off';
markerList4.Visible = 'off';
markerList5.Visible = 'off';
markerList6.Visible = 'off';
markerList7.Visible = 'off';

        
    end



%%%%%%% Callbacks %%%%%%%

    function resetCallback(~, ~)
        textNames ={};
       selectedCellsData={};
        cla(ax3);
    end
 
 function toggleSelectionMode(source, ~)
textNames ={};
   selectedCellsData={};
    smallGraph = findobj(fig, 'Tag', 'SmallGraph');
   if ~isempty(smallGraph)
   cla(ax3);
   end

    button_state = get(source, 'Value');

    if button_state == 1
        selectionMode = 'multiple';
         btnCompare= findobj('String', 'Compare off');
        if ~isempty(btnCompare)
            set(btnCompare, 'String', 'Compare on');
        end
    else
        selectionMode = 'single';
         btnCompare= findobj('String', 'Compare on');
        if ~isempty(btnCompare)
            set(btnCompare, 'String', 'Compare off');
        end

    end
end

function toggleGraphCallback(src, ~)
    % Vérifiez l'état du bouton bascule
    button_state = get(src, 'Value');
    
    if button_state == get(src, 'Max')
         btnShow = findobj('String', 'Show Graph');
        if ~isempty(btnShow)
            set(btnShow, 'String', 'Hide Graph');
        end
        % Bouton enfoncé: Affichez le graphique
        showGraph();
        set(reset,'visible','on');
       
    elseif button_state == get(src, 'Min')
         btnHide = findobj('String', 'Hide Graph');
        if ~isempty(btnHide)
            set(btnHide, 'String', 'Show Graph');
        end
        % Bouton relâché: Masquez le graphique
        hideGraph();
        set(reset,'visible','off');

   end
end


    function popMenuCallback(~, ~)
    selectedOption = get(popMenu, 'Value');
    if selectedOption == 1  % Si "Markers" est sélectionné
        markerList.Visible = 'on';  % Affichez la listbox
        markerList2.Visible = 'off';
        markerList3.Visible = 'off';
        markerList4.Visible = 'off';
        markerList5.Visible = 'off';
        markerList6.Visible = 'off';
        markerList7.Visible = 'off';
         set(markerList, 'CellSelectionCallback', {@cellSelected, markerList.Data});

elseif selectedOption == 2  % Si "Analog" est sélectionné
        markerList.Visible = 'off';  
        markerList2.Visible = 'on';
        markerList3.Visible = 'off';
        markerList4.Visible = 'off';
        markerList5.Visible = 'off';
        markerList6.Visible = 'off';
        markerList7.Visible = 'off';
         set(markerList2, 'CellSelectionCallback', {@cellSelected, markerList2.Data});

    elseif selectedOption == 3  % Si "Angles" est sélectionné
        markerList.Visible = 'off';  
        markerList2.Visible = 'off';
        markerList3.Visible = 'on';
        markerList4.Visible = 'off';
        markerList5.Visible = 'off';
        markerList6.Visible = 'off';
        markerList7.Visible = 'off';
         set(markerList3, 'CellSelectionCallback', {@cellSelected, markerList3.Data});
   
    elseif selectedOption == 4  % Si "Angles" est sélectionné
        markerList.Visible = 'off';  
        markerList2.Visible = 'off';
        markerList3.Visible = 'off';
        markerList4.Visible = 'on';
        markerList5.Visible = 'off';
        markerList6.Visible = 'off';
        markerList7.Visible = 'off';
         set(markerList4, 'CellSelectionCallback', {@cellSelected, markerList4.Data});
    
    elseif selectedOption == 5  % Si "Angles" est sélectionné
        markerList.Visible = 'off';  
        markerList2.Visible = 'off';
        markerList3.Visible = 'off';
        markerList4.Visible = 'off';
        markerList5.Visible = 'on';
        markerList6.Visible = 'off';
        markerList7.Visible = 'off';
         set(markerList5, 'CellSelectionCallback', {@cellSelected, markerList5.Data});
   
    elseif selectedOption == 6  % Si "Angles" est sélectionné
        markerList.Visible = 'off';  
        markerList2.Visible = 'off';
        markerList3.Visible = 'off';
        markerList4.Visible = 'off';
        markerList5.Visible = 'off';
        markerList6.Visible = 'on';
        markerList7.Visible = 'off';
         set(markerList6, 'CellSelectionCallback', {@cellSelected, markerList6.Data});
    
    elseif selectedOption == 7  % Si "Angles" est sélectionné
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
  
    % Obtient le texte du bouton
    btnString = src.String;
    
    % Obtient les données actuelles de markerList
    databox = markerList.Data;
    
 
    if strcmp(btnString, 'Deselect All')
        
        for i = 1:size(databox, 1)
            databox{i, 1} = false;
        end
        src.String = 'Select All';  % Change le texte du bouton
    else
      
        for i = 1:size(databox, 1)
            databox{i, 1} = true;
        end
        src.String = 'Deselect All';  % Change le texte du bouton
    end
    
    % Met à jour la liste des checkboxes avec les nouvelles données
    set(markerList, 'Data', databox);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function checkBoxCallback(~, ~)
    
    % Obtient l'état des cases à cocher
    DataBox = markerList.Data;
    checkedItems = [DataBox{:,1}];  % Indices des éléments cochés
    activeMarkers = zeros(size(Markers_names));
    activeMarkers(checkedItems) = 1;
    updateFrameDisplay();
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
        updateFrameDisplay();
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
         
   % Convertir databox en table pour une manipulation plus facile
databoxTable = cell2table(databox, 'VariableNames', {'Value', 'Name'});
databoxTableall = cell2table(databox, 'VariableNames', {'Value', 'Name'});

% Trouver les indices des noms à supprimer dans databox
indicesToRemove = ismember(databoxTable.Name, AnglesName);
indicesToRemove2 = ismember(databoxTable.Name, ForcesName);
indicesToRemove3 = ismember(databoxTable.Name, MomentsName);
indicesToRemove4 = ismember(databoxTable.Name, PowersName);
indicesToRemove5 = ismember(databoxTable.Name, ScalarsName);

% Combiner tous les indices de suppression
allIndicesToRemove = indicesToRemove | indicesToRemove2 | indicesToRemove3 | indicesToRemove4 | indicesToRemove5;

% Supprimer les lignes correspondantes en une seule fois
databoxTable(allIndicesToRemove, :) = [];

% Créer un tableau logique pour trouver les lignes correspondantes
indicesLogiques = ismember(databoxTableall, databoxTable);

% Trouver les numéros des lignes correspondants
numerosDesLignes = find(indicesLogiques);
    
for i = 1:length(numerosDesLignes)
    indiceLigne = numerosDesLignes(i);
    databox{indiceLigne, 1} = true;
end

    checkedItems = [databox{:,1}];  % Indices des éléments cochés
    activeMarkers = zeros(size(Markers_names));
    activeMarkers(checkedItems) = 1;
    updateFrameDisplay();

    % Met à jour la liste des checkboxes avec les nouvelles données
    set(markerList, 'Data', databox);
    updateFrameDisplay();
    end
    
end

function progressBarCallback(~, ~)
    if ~playing
        
        percentage_progress = get(progressBar, 'Value');
        current_frame = floor(percentage_progress);
        updateFrameDisplay();
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    function updateTable(src, ~, ListName1, ListName2, ListName3,ListName4, ListName5, ListName6, ListName7)
    
    % Obtient la chaîne de la boîte de recherche
    fig = ancestor(src, 'figure');
   
    searchStr = get(findobj(fig, 'Tag', 'searchBox'), 'String');
    
   if strcmp(markerList.Visible, 'on')
        % Filtrez les éléments basés sur la chaîne de recherche pour la première liste
        filteredItems = ListName1(contains(ListName1, searchStr, 'IgnoreCase', true));

        % Met à jour la première liste avec les éléments filtrés
        databox = cell(numel(filteredItems), 2);
        databox(:, 1) = {false};
        databox(:, 2) = filteredItems';
        set(markerList, 'Data', databox);
        

    elseif strcmp(markerList2.Visible, 'on')
        % Filtrez les éléments basés sur la chaîne de recherche pour la deuxième liste
        filteredItems = ListName2(contains(ListName2, searchStr, 'IgnoreCase', true));

        % Met à jour la deuxième liste avec les éléments filtrés
        databox = cell(numel(filteredItems), 2);
        databox(:, 1) = {false};
        databox(:, 2) = filteredItems';
        set(markerList2, 'Data', databox);
        
   elseif strcmp(markerList3.Visible, 'on')
        % Filtrez les éléments basés sur la chaîne de recherche pour la deuxième liste
        filteredItems = ListName3(contains(ListName3, searchStr, 'IgnoreCase', true));

        % Met à jour la deuxième liste avec les éléments filtrés
        databox = cell(numel(filteredItems), 2);
        databox(:, 1) = {false};
        databox(:, 2) = filteredItems';
        set(markerList3, 'Data', databox);

   elseif strcmp(markerList4.Visible, 'on')
        % Filtrez les éléments basés sur la chaîne de recherche pour la deuxième liste
        filteredItems = ListName4(contains(ListName4, searchStr, 'IgnoreCase', true));

        % Met à jour la deuxième liste avec les éléments filtrés
        databox = cell(numel(filteredItems), 2);
        databox(:, 1) = {false};
        databox(:, 2) = filteredItems';
        set(markerList4, 'Data', databox);
       
   elseif strcmp(markerList5.Visible, 'on')
        % Filtrez les éléments basés sur la chaîne de recherche pour la deuxième liste
        filteredItems = ListName5(contains(ListName5, searchStr, 'IgnoreCase', true));

        % Met à jour la deuxième liste avec les éléments filtrés
        databox = cell(numel(filteredItems), 2);
        databox(:, 1) = {false};
        databox(:, 2) = filteredItems';
        set(markerList5, 'Data', databox);
        
   elseif strcmp(markerList6.Visible, 'on')
        % Filtrez les éléments basés sur la chaîne de recherche pour la deuxième liste
        filteredItems = ListName6(contains(ListName6, searchStr, 'IgnoreCase', true));

        % Met à jour la deuxième liste avec les éléments filtrés
        databox = cell(numel(filteredItems), 2);
        databox(:, 1) = {false};
        databox(:, 2) = filteredItems';
        set(markerList6, 'Data', databox);
        
   elseif strcmp(markerList7.Visible, 'on')
        % Filtrez les éléments basés sur la chaîne de recherche pour la deuxième liste
        filteredItems = ListName7(contains(ListName7, searchStr, 'IgnoreCase', true));

        % Met à jour la deuxième liste avec les éléments filtrés
        databox = cell(numel(filteredItems), 2);
        databox(:, 1) = {false};
        databox(:, 2) = filteredItems';
        set(markerList7, 'Data', databox);
        
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
    function cellSelected(~, event, dataCell)
    % Vérifiez si event.Indices est non vide
    if ~isempty(event.Indices)
        % Obtenez les indices de la cellule sélectionnée
        row = event.Indices(1);
        col = event.Indices(2);

        selectedData = dataCell{row, col};
          

 smallGraph = findobj(fig, 'Tag', 'SmallGraph');

    if ~isempty(smallGraph)      

        % Facultativement, vous pouvez utiliser les données de la cellule sélectionnée
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
          
            index = 1:length(data.(num2str(selectedData)).line);
            
             plot(ax3, x_values, data.(num2str(selectedData)).line(index,1), 'r');
        end


 elseif strcmp(markerList4.Visible, 'on')
       
        if strcmp(selectionMode, 'multiple')
           
          
                index = 1:length(data.(num2str(selectedData)).line);
           
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
      
                index = 1:length(data.(num2str(selectedData)).line);
          
             plot(ax3, x_values, data.(num2str(selectedData)).line(index,1), 'r');
        end

          elseif strcmp(markerList5.Visible, 'on')
       
        if strcmp(selectionMode, 'multiple')
     
                index = 1:length(data.(num2str(selectedData)).line);
         
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
    
                index = 1:length(data.(num2str(selectedData)).line);
         
             plot(ax3, x_values, data.(num2str(selectedData)).line(index,1), 'r');
        end

          elseif strcmp(markerList6.Visible, 'on')
       
        if strcmp(selectionMode, 'multiple')
        
                index = 1:length(data.(num2str(selectedData)).line);
            
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
    
                index = 1:length(data.(num2str(selectedData)).line);
          
             plot(ax3, x_values, data.(num2str(selectedData)).line(index,1), 'r');
        end

          elseif strcmp(markerList7.Visible, 'on')
       
        if strcmp(selectionMode, 'multiple')
       
                index = 1:length(data.(num2str(selectedData)).line);
           
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
        
                index = 1:length(data.(num2str(selectedData)).line);
           
             plot(ax3, x_values, data.(num2str(selectedData)).line(index,1), 'r');
        end

    end
 
 set(ax3, 'Tag', 'SmallGraph','HitTest','off');

xlim = get(ax3, 'XLim'); 
ylim = get(ax3, 'YLim');  
totalHeight = ylim(2) - ylim(1);

% Calcule la position du coin supérieur droit
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

        % Configuration des propriétés de l'axe
        set(ax3, 'Tag', 'SmallGraph', 'HitTest', 'off');

        % Calculer la position Y pour chaque texte, en supposant un espacement vertical
        currentPosY = posY - (i-1) * spacing;

        str = sprintf('%s', num2str(selectedCellsData{i}));
        textNames{end+1} = str;

        % Créer un objet texte à la position calculée avec la couleur sélectionnée
        hText = text(posX, currentPosY, str, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top');
        set(hText, 'Color', currentColor);  % Appliquer la couleur

        % Ajustements supplémentaires (taille de la police, etc.)
        set(hText, 'FontSize', 10);  
    end
else
    set(ax3, 'Tag', 'SmallGraph', 'HitTest', 'off');
    % Gérer le cas où aucune donnée n'est sélectionnée
    hText = text(posX, posY, selectedData,'color','r', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top');
    set(hText, 'FontSize', 10,'color','k');  % Ajustements de la police

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
          
    % Ajoutez une ligne verticale à la position X de la frame actuelle
    hold(ax3, 'on'); % Gardez le graphique actuel et ajoutez la ligne
    currentFrameLine = line(ax3, [current_frame, current_frame], ax3.YLim, 'Color', 'k', 'LineWidth', 1);
    set(currentFrameLine, 'Tag', 'CurrentFrameLine'); % Ajoutez un tag pour retrouver cette ligne plus tard
    hold(ax3, 'off'); % Relâchez le graphique

    else

    end
   end
end

%%%%%%% MArkers names %%%%%%%

% Créez une structure pour stocker les noms des marqueurs
Markers_names = {};

% Initialisez une structure vide pour les marqueurs
Markers = struct();

% Utilisez la fonction datacursormode une seule fois en dehors de la boucle
dcm_obj = datacursormode(fig);
set(dcm_obj, 'UpdateFcn', @myDataCursorFunc);

function txt = myDataCursorFunc(~, event_obj)
    pos = get(event_obj, 'Position');
    markerName = findMarkerNameByPosition(pos);
    txt = markerName;
end

function name = findMarkerNameByPosition(position)
    name = 'Unknown'; % Par défaut, le nom est inconnu

    % Parcourez les noms des marqueurs
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

    [~,~,ext] = fileparts(filepath);
        if strcmp(ext,'.c3d')
           data = c3d2zoo(filepath);
        else
            data = zload(filepath);
        end

   ch_names = setdiff(fieldnames(data), 'zoosystem');

% Initialisation d'un cell array vide pour stocker les noms des marqueurs
Markers_names = {};

% Boucle à travers chaque champ dans 'ch_names'
for i = 1:length(ch_names)
    name = ch_names{i}; % Extraire le nom du champ actuel
    
    % Vérifier si le champ 'line' dans la structure actuelle a exactement 3 colonnes
    if  isfield(data.(ch_names{i}), 'line')
     if size(data.(ch_names{i}).line, 2) == 3
        % Si la condition est vraie, ajouter le nom du champ à 'Markers_names'
        Markers_names{end + 1} = name;
    end
   end
end

    % Initialisez la structure des marqueurs en dehors de la boucle
    Markers = struct();

    for i = 1:numel(Markers_names)
        Markers.(Markers_names{i}) = data.(Markers_names{i}).line;
    end

    playing = false;
    current_frame = 1;
    n_frames = size(data.(Markers_names{1}).line, 1);
     % Update activeMarkers to match the new Marker_names
    activeMarkers = ones(1, numel(Markers_names));   
    VirtualMarker = plugingaitchannels;
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
     set(ax3, 'Tag', 'SmallGraph','HitTest','off');

    xlim = get(ax3, 'XLim');  % obtient les limites actuelles de l'axe des x
ylim = get(ax3, 'YLim');  % obtient les limites actuelles de l'axe des y

% Calcule la position du coin supérieur droit
posX = xlim(2); % ceci prend la limite supérieure de l'axe des x
posY = ylim(2); % ceci prend la limite supérieure de l'axe des y
    hText = text(posX, posY, str, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top');

% Modifiez la taille de la police du texte
set(hText, 'FontSize', 14); 

% Ajuste la marge si nécessaire pour mieux positionner le texte
set(hText, 'Units', 'normalized', 'Position', [0.98, 0.98, 0]); % Les valeurs peuvent être ajustées pour mieux positionner votre texte
        
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
    set(ax3, 'Tag', 'SmallGraph','HitTest','off'); % Ajoutez un tag pour retrouver cet axe plus tard
   % Ajoutez une ligne verticale à la position X de la frame actuelle
    hold(ax3, 'on'); % Gardez le graphique actuel et ajoutez la ligne
    currentFrameLine = line(ax3, [current_frame, current_frame], ax3.YLim, 'Color', 'k', 'LineWidth', 1);
    set(currentFrameLine, 'Tag', 'CurrentFrameLine'); % Ajoutez un tag pour retrouver cette ligne plus tard
    hold(ax3, 'off'); % Relâchez le graphique
end

function hideGraph()
    % Code pour masquer le graphique.
    % Trouvez l'axe avec le tag et supprimez-le.
    smallGraph = findobj(fig, 'Tag', 'SmallGraph');
    if ~isempty(smallGraph)
        delete(smallGraph);
    end
end

function updateGraph()
    % Trouvez la ligne avec le tag et mettez à jour sa position X
    currentFrameLine = findobj(fig, 'Tag', 'CurrentFrameLine');
    if ~isempty(currentFrameLine)
        set(currentFrameLine, 'XData', [current_frame, current_frame]);
    end
end
%%%%%%% Animation %%%%%%%

function updateAnimation()
    speed = get(speedSlider, 'Value');

    while ~stopLoop
        if playing
            current_frame = min(current_frame + ceil(2*speed), n_frames);
            updateFrameDisplay();
            if current_frame >= n_frames
                playing = false;
                btnPause = findobj('String', 'Pause');
                if ~isempty(btnPause)
                    set(btnPause, 'String', 'Play');
                end
            else
                pause(0.001);
            end
        else
            pause(0.1);
        end
    end
end

    function updateFrameDisplay()
    
        persistent sc hFP hFP2 
 
hold(ax, 'on');

      % Mise à jour de la flèche 3D
      
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
                my3DArrow = quiver3(ax, OxF1, OyF1, OzF1, u, v, w, 'r', 'LineWidth', 1.5);
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
                my3DArrow2 = quiver3(ax, OxF2, OyF2, OzF2, u2, v2, w2, 'r', 'LineWidth', 1.5);
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

    % Mise à jour du nuage de points
    if isempty(sc) || ~isvalid(sc) || ~isequal(size_factor, previous_size_factor) || ~isequal(colors, previous_colors)
       delete(sc)
        sc = scatter3(ax, coords(:, 1), coords(:, 2), coords(:, 3), size_factor, colors, 'filled');
        previous_size_factor = size_factor;
        previous_colors = colors;
    else
        set(sc, 'XData', coords(:, 1), 'YData', coords(:, 2), 'ZData', coords(:, 3));
    end


    % Mise à jour du patch
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


%%%%%%% Fonction Events %%%%%%%

function events = extractEventsForAllMarkers()
    % Pré-allocation avec une estimation de la taille (à ajuster en fonction des données)
    estimated_num_events = 100; 
    events(estimated_num_events) = struct('marker', [], 'event', [], 'frame', []);
    
    event_count = 0;
    for i = 1:numel(Markers_names)
        marker = Markers_names{i};
        marker_data = data.(marker); % Accéder une fois et utiliser plusieurs fois

        if isfield(marker_data, 'event')
            markerEvents = fieldnames(marker_data.event);

            for j = 1:numel(markerEvents)
                event_count = event_count + 1;
                events(event_count) = struct('marker', marker, 'event', markerEvents{j}, 'frame', marker_data.event.(markerEvents{j}));
            end
        end
    end
    
    % Supprimer les entrées non utilisées après la boucle
    events(event_count+1:end) = [];
end



function plotEventsOnBar(events)
    num_events = numel(events);
    if isempty(lineHandles) || length(lineHandles) ~= num_events
        % Supprimer les anciens handles pour éviter l'encombrement de la mémoire
        delete(lineHandles);
        delete(textHandles);

        % Créer de nouveaux handles
        lineHandles = gobjects(num_events, 1);
        textHandles = gobjects(num_events, 1);

        for i = 1:num_events
            event = events(i);
            x_event = event.frame / n_frames;
            lineHandles(i) = line(axBar, [x_event(1, 1), x_event(1, 1)], [0, 4], 'Color', 'red', 'LineWidth', 2);
            textHandles(i) = text(axBar, x_event(1, 1), 5.55, event.event, 'HorizontalAlignment', 'center', 'Visible', 'off');
            
            % Utilisation d'une fonction anonyme pour réduire les appels de fonction
            set(lineHandles(i), 'ButtonDownFcn', @(src,evt) toggleTextVisibility(event.event));
        end
    else
        % Mise à jour des handles existants
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
    validIdx = activeIdx <= numel(Markers_names);  % logical array: true for valid, false for invalid
    
    if any(~validIdx)
        warning('Invalid indices detected and will be ignored: %s', mat2str(activeIdx(~validIdx)));
        activeIdx = activeIdx(validIdx);  % keep only valid indices
    end
    
    coords = zeros(numel(activeIdx), 3);
    for i = 1:numel(activeIdx)
        marker = Markers_names{activeIdx(i)};
        coords(i, :) = Markers.(marker)(current_frame, :);
    end
end


function showAddEventWindow(~, ~)

    selectedMarkerName = selectedData;

    % Créez une nouvelle fenêtre
    h = figure('Position', [500 500 300 200], 'MenuBar', 'none', 'Name', 'Ajouter Événement', 'NumberTitle', 'off');

    % Affichez le nom du marqueur sélectionné
    uicontrol(h, 'Style', 'text', 'Position', [10 160 280 20], 'String', ['Marker: ', selectedMarkerName]);

    % Deux zones de texte pour le nom de l'événement et la frame
    uicontrol(h, 'Style', 'text', 'Position', [10 120 100 20], 'String', 'Nom de l''événement:');
    eventNameEdit = uicontrol(h, 'Style', 'edit', 'Position', [120 120 160 25]);

    uicontrol(h, 'Style', 'text', 'Position', [10 80 100 20], 'String', 'Frame:');
    frameEdit = uicontrol(h, 'Style', 'edit', 'Position', [120 80 160 25],'string',num2str(current_frame));

    % Bouton pour sauvegarder
    uicontrol(h, 'Style', 'pushbutton', 'Position', [100 20 100 40], 'String', 'Sauvegarder', 'Callback', @saveEventData);

    function saveEventData(~, ~)
        eventName = get(eventNameEdit, 'String');
        frameNum = str2double(get(frameEdit, 'String'));

        if isempty(eventName) || isnan(frameNum)
            msgbox('Veuillez entrer un nom valide et un numéro de frame.', 'Erreur', 'error');
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
        msgbox('Événement sauvegardé!', 'Succès');
    end
end


function showDeleteEventWindow(~, ~)
    % Créez une nouvelle fenêtre
    h = figure('Position', [500 500 350 300], 'MenuBar', 'none', 'Name', 'Supprimer Événement', 'NumberTitle', 'off', 'CloseRequestFcn', @onClose);

    % ListBox montrant tous les événements
    eventList = uicontrol(h, 'Style', 'listbox', 'Position', [10 50 330 240], 'String', getEventNames(), 'Value', 1); 

    % Bouton pour supprimer l'événement sélectionné
    uicontrol(h, 'Style', 'pushbutton', 'Position', [125 10 100 30], 'String', 'Supprimer', 'Callback', @deleteEvent);

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
        if selectedIndex > 0  % assurez-vous qu'un élément est sélectionné
            fullEventName = eventNames{selectedIndex};
            [marker, eventName] = strtok(fullEventName, ':');
            eventName = strtrim(eventName(2:end));  % enlevez l'espace et le deux-points
            
            % Supprimez l'événement de la structure de données
            if isfield(data.(marker), 'event') && isfield(data.(marker).event, eventName)
                data.(marker).event = rmfield(data.(marker).event, eventName);
                zsave(filepath, data);  % suppose que 'zsave' est votre fonction de sauvegarde personnalisée
            end
           cla(axBar);

    % Redéfinissez les propriétés de axBar si elles sont altérées par cla()
    set(axBar, 'Visible', 'off', 'XLim', [0, 1], 'YLim', [-2, 5], 'HitTest', 'off');

    % Recréez les éléments graphiques nécessaires
    for i = 0:0.1:1
        line([i i], [-2 5], 'Color', 'k', 'Parent', axBar);
    end 
            
            events = extractEventsForAllMarkers();  % récupérez les événements actuels après la suppression
            plotEventsOnBar(events);  % redessinez la barre d'événements avec les événements actuels

            % Mettez à jour la liste des événements 
            set(eventList, 'String', getEventNames());
            set(eventList, 'Value', max(1, selectedIndex - 1));
        end
    end

    function onClose(~, ~)
        delete(h);  
    end
end


%%%%%% Bouton Option %%%%%%%

function editAppearanceCallback(~, ~)
    h = figure('Position', [500 500 300 200], 'MenuBar', 'none', 'Name', 'Edit Appearance', 'NumberTitle', 'off');

    uicontrol(h, 'Style', 'text', 'Position', [10 160 100 20], 'String', 'Marker Size:');
    markerSizeEdit = uicontrol(h, 'Style', 'slider', 'Position', [120 160 120 25],'backgroundcolor',[1 1 1],'Min', 1, 'Max', 30, 'Value', 8, 'SliderStep', [1/(30-1) 2/(30-1)], 'Callback', @Sizecallback);
   SizeLabel = uicontrol(h, 'Style', 'text', 'Position', [245 160 30 25], 'String', num2str(floor(get(markerSizeEdit, 'Value'))), 'FontSize', 11);
    
    function Sizecallback(~, ~)
             set(SizeLabel, 'String', num2str(floor(get(markerSizeEdit, 'Value'))));
        end
   
        uicontrol(h, 'Style', 'text', 'Position', [10 120 100 20], 'String', 'Marker Color:');
    markerColorEdit = uicontrol(h, 'Style', 'edit', 'Position', [120 120 160 25]);

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

