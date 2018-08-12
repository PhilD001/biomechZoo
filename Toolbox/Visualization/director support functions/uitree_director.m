function uitree_director(hnd,data)

% UITREE_DIRECTOR controls the display of the tree representation of loaded
% data in director
%
% ARGUMENTS
%  hnd    ...  handle to director figure or tab
%  data   ...  loaded zoo file

% NOTES: 
% - currently only video data can be displayed

import javax.swing.*
import javax.swing.tree.*;

% Set Defaults
%
ch_PiG = {'LFHD','LBHD','RFHD','RBHD','C7','T10','RBAK','CLAV','STRN',...
    'LSHO','LELB','LWRA','LWRB','LFIN','RSHO','RELB','RWRA','RWRB','RFIN',...
    'SACR','RASI','LASI','LTHI','LKNE','LTIB','LANK','LHEE','LTOE','RTHI',...
    'RKNE','RTIB','RANK','RHEE','RTOE'};

% b1 = uicontrol( 'string','add Node', ...
%     'units' , 'normalized', ...
%     'position', [0 0.5 0.5 0.5], ...
%     'callback', @b1_cb);
% 
% b2 = uicontrol( 'string','remove Node', ...
%     'units' , 'normalized', ...
%     'position', [0.5 0.5 0.5 0.5], ...
%     'callback', @b2_cb);

%[I,map] = imread([matlab_work_path, '/checkedIcon.gif']);
[I,map] = checkedIcon;
javaImage_checked = im2java(I,map);

%[I,map] = imread([matlab_work_path, '/uncheckedIcon.gif']);
[I,map] = uncheckedIcon;
javaImage_unchecked = im2java(I,map);

% javaImage_checked/unchecked are assumed to have the same width
iconWidth = javaImage_unchecked.getWidth;

% create top node
rootNode = uitreenode('v0','data', 'data', [], 0);
video  = uitreenode('v0', 'video', 'video', [], false);
analog = uitreenode('v0', 'analog', 'analog', [], false);
rootNode.add(video);
rootNode.add(analog);



% create  children with checkboxes

% (a) video channels
%
vch = data.zoosystem.Video.Channels;
for i = 1:length(vch)
    if ismember(vch{i},ch_PiG)
        cNode = uitreenode('v0', 'selected',  vch{i},  [], 1);
        cNode.setIcon(javaImage_checked);
    else
        cNode = uitreenode('v0', 'unselected',  vch{i},  [], 0);
        cNode.setIcon(javaImage_unchecked);
    end
    video.add(cNode);
end

% (b) analog channels
ach = data.zoosystem.Analog.Channels;
for i = 1:length(ach)
    %     if strfind(ach{i},'F')
    %         cNode = uitreenode('v0', 'selected',  ach{i},  [], 1);
    %         cNode.setIcon(javaImage_checked);
    %     else
    cNode = uitreenode('v0', 'unselected',  ach{i},  [], 0);
    cNode.setIcon(javaImage_unchecked);

    %     end
    analog.add(cNode);
end


% set treeModel
treeModel = DefaultTreeModel( rootNode );

% create the tree
[tree,container] = uitree('v0');
tree.setModel( treeModel );
% we often rely on the underlying java tree
jtree = handle(tree.getTree,'CallbackProperties');
% some layout
drawnow;
set(tree, 'Units', 'normalized', 'position', [0 0 1 0.5]);
set(tree, 'NodeSelectedCallback', @selected_cb );

% make root the initially selected node
tree.setSelectedNode( rootNode );

% MousePressedCallback is not supported by the uitree, but by jtree
set(jtree, 'MousePressedCallback', @mousePressedCallback);

set(container, 'Parent', hnd,'units','normalized','tag','director_tree');  % fix the uitree Parent
set(findobj('tag','director_tree'),'position',[0 0 1 1 ])

% Set the mouse-press callback
    function mousePressedCallback(hTree, eventData) %,additionalVar)
        % if eventData.isMetaDown % right-click is like a Meta-button
        % if eventData.getClickCount==2 % how to detect double clicks
        
        % Get the clicked node
        clickX = eventData.getX;
        clickY = eventData.getY;
        treePath = jtree.getPathForLocation(clickX, clickY);
        % check if a node was clicked
        if ~isempty(treePath)
            % check if the checkbox was clicked
            if clickX <= (jtree.getPathBounds(treePath).x+iconWidth)
                node = treePath.getLastPathComponent;
                nodeValue = node.getValue;
                % as the value field is the selected/unselected flag,
                % we can also use it to only act on nodes with these values
                switch nodeValue
                    case 'selected'
                        node.setValue('unselected');
                        node.setIcon(javaImage_unchecked);
                        jtree.treeDidChange();
                        set(findobj('tag',char(node.getName)),'visible','off')   
                     
                    case 'unselected'
                        nodeParent = node.getParent.getName;
                        node.setValue('selected');
                        node.setIcon(javaImage_checked);
                        jtree.treeDidChange();
                        
                        ch_hnd = findobj('tag',char(node.getName));

                        if strcmp(nodeParent,'video')
                            
                            if isempty(ch_hnd)
                                xyz = data.(char(node.getName)).line;
                                dis = clean(xyz);
                                tg = char(node.getName);
                                indx = randi(10,1,9);
                                clr = newcolor(indx(1));
                                marker('create',tg,1.5,dis,clr)
                                ch_hnd = findobj('tag',char(node.getName));
                            end
                            
                            set(ch_hnd,'visible','on');
                            
                            
                            display_director_graph(data,get(ch_hnd,'tag'))
                            
                        elseif strcmp(nodeParent,'analog')
                            display_director_graph(data,char(node.getName))
                            
                        end
                end
            end
        end
    end % function mousePressedCallback

    function selected_cb( tree, ev )
        nodes = tree.getSelectedNodes;
        node = nodes(1);
        path = node2path(node);
    end

    function path = node2path(node)
        path = node.getPath;
        for i=1:length(path);
            p{i} = char(path(i).getName);
        end
        if length(p) > 1
            path = fullfile(p{:});
        else
            path = p{1};
        end
    end

% add node
    function b1_cb( h, env )
        nodes = tree.getSelectedNodes;
        node = nodes(1);
        parent = node;
        childNode = uitreenode('v0','dummy', 'Child Node', [], 0);
        treeModel.insertNodeInto(childNode,parent,parent.getChildCount());
        
        % expand to show added child
        tree.setSelectedNode( childNode );
        
        % insure additional nodes are added to parent
        tree.setSelectedNode( parent );
    end

% remove node
    function b2_cb( h, env )
        nodes = tree.getSelectedNodes;
        node = nodes(1);
        if ~node.isRoot
            nP = node.getPreviousSibling;
            nN = node.getNextSibling;
            if ~isempty( nN )
                tree.setSelectedNode( nN );
            elseif ~isempty( nP )
                tree.setSelectedNode( nP );
            else
                tree.setSelectedNode( node.getParent );
            end
            treeModel.removeNodeFromParent( node );
        end
    end
end % of main function treeExperiment6

function [I,map] = checkedIcon()
I = uint8(...
    [1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0;
    2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,1;
    2,2,2,2,2,2,2,2,2,2,2,2,0,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,0,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,0,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,0,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,0,0,1,1,2,2,3,1;
    2,2,1,0,0,1,1,0,0,1,1,1,2,2,3,1;
    2,2,1,1,0,0,0,0,1,1,1,1,2,2,3,1;
    2,2,1,1,0,0,0,0,1,1,1,1,2,2,3,1;
    2,2,1,1,1,0,0,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,0,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1;
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1;
    1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1]);
map = [0.023529,0.4902,0;
    1,1,1;
    0,0,0;
    0.50196,0.50196,0.50196;
    0.50196,0.50196,0.50196;
    0,0,0;
    0,0,0;
    0,0,0];
end

function [I,map] = uncheckedIcon()
I = uint8(...
    [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1;
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1;
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,1,1,1,1,1,1,1,1,1,1,2,2,3,1;
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1;
    2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1;
    1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1]);
map = ...
    [0.023529,0.4902,0;
    1,1,1;
    0,0,0;
    0.50196,0.50196,0.50196;
    0.50196,0.50196,0.50196;
    0,0,0;
    0,0,0;
    0,0,0];
end





