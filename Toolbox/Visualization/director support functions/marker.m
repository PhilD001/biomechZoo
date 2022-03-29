function varargout = marker(action,varargin)

% varargout = marker(action,varargin) performs various actions for director
%
% Updated by JJ Loh and Philippe C. Dixon June 2015
% - new case added to load the skate props
%
% Updated by Philippe C. Dixon Jan 2016
% - Bug fixes for backwards comp
%
% Updated by Philippe C. Dixon June 2017
% - clean up pop up window for marker selection
%
% Updated by Philippe C. Dixon July 2017
% - added creation of PiG bones, if available
%
% Updated by Philippe C. Dixon August 2017
% - Exploded PiG data are automatically merged in order to build bones, if available
%
% Updated by Philippe C. Dixon January 2018
% - Improved search for markers to display
% - Attempts to merge exploded marker data to display markers in director

switch action
    
    case 'buttondown'
        if strcmp(get(gcf,'selectiontype'),'alt')
            hnd1 = finddobj('highlight');
            caliper(hnd1,gcbo);
        end
        set(finddobj('current object'),'string',get(gcbo,'tag'));
        set(finddobj('highlight'),'ambientstrength',.3);
        set(gcbo,'ambientstrength',.6);
        if ~strcmp(currentperson,'props')
            cameraman('buttondown');
            return
        end
        if ~strcmp(get(gcf,'selectiontype'),'alt')
            caliper;
        end
        
        buttondownfxn;
        
    case 'create'
        %createmarker(name,size,position,color)
        varargout{1} = createmarker(varargin{1},varargin{2},varargin{3},varargin{4});
        
  
    case {'load c3d','load zoo','load file'}
        delete(finddobj('marker'));
        data = loadfile(varargin{1});
        props('refresh');
        varargout{1} = data;
        
    case 'goto'
        mark(varargin{1});
       
end

function caliper(varargin)

if nargin == 2
    h1 = varargin{1};
    h2 = varargin{2};
    if isempty(h1)||isempty(h2)
        return
    end
    vr1 = mean(get(h1,'vertices'));
    vr2 = mean(get(h2,'vertices'));
    delta = vr2-vr1;
else
    bm = finddobj('bomb');
    vr = get(gco,'vertices');
    midpt = mean(vr);
    if isempty(bm)
        set(gcf,'name','');
        return
    else
        bud = get(bm(1),'userdata');
        vr = get(bud.object,'vertices');
        vr = vr(bud.vindex,:);
        delta = midpt-vr;
    end
end
mg = sqrt(delta*delta');
set(gcf,'name',num2str([delta,mg]));




function data = loadfile(filename)

s = filesep;    % determine slash direction based on computer type

% Determine file type for processing
%
ext = extension(filename);

if isin(ext,'zoo')
    data = zload(filename);
    
elseif isin(ext,'c3d')
    data = c3d2zoo(filename);
    
else
    error('unknown file type')
end

% Hard code footwear type (Uncomment to show skates)
%
% data.zoosystem.Anthro.Feet = 'skates';


% check if data were exploded
%
[explode,ch_exp] = checkExplode(data);
if explode
    for i = 1:length(ch_exp)
        data = mergechannel_data(data,ch_exp{i});
    end
end

% Extract all channels in file
%
if ~isfield(data.zoosystem.Video,'Channels')
    ch = setdiff(fieldnames(data),'zoosystem');
else
    ch = data.zoosystem.Video.Channels;
end


% Load Plug-in Gait bones
%
[data,isPiG] = getPiG(data,ch);
props('zoo plugin gait',data);

% director_loadbones                  



% Loads force plates (if any)
%
props('load analog zoo',data);


% Attempt to limit marker list to 'true' markers
%
v = cell(size(ch));

for i = 1:length(ch)
    
    if ~isin(ch{i},{'x1','y1','z1','x2','y2','z2','Force','Moment','Angle','Power',...
            'GRF','star'})
        [~,cc] = size(data.(ch{i}).line);
        if cc==3
            
            v{i} = ch{i};
            
        end
    end
end
v(cellfun(@isempty,v)) = [];


% Display markers in animation
%
if ~isPiG
    indx = listdlg('liststring',v,'PromptString','add markers','name','add markers');
    v = v(indx);
else
    ch_PiG = {'LFHD','LBHD','RFHD','RBHD','C7','T10','RBAK','CLAV','STRN',...
    'LSHO','LELB','LWRA','LWRB','LFIN','RSHO','RELB','RWRA','RWRB','RFIN',...
    'SACR','RASI','LASI','LTHI','LKNE','LTIB','LANK','LHEE','LTOE','RTHI',...
    'RKNE','RTIB','RANK','RHEE','RTOE'};
    v = intersect(v,ch_PiG);
end
    
for i = 1:length(v)
    xyz = data.(v{i}).line;
    dis = clean(xyz);
    tg = v{i};
    marker('create',tg,1.5,dis,newcolor(i));
end



% Load foot props (modify feet to skates if subject is a skater)
%
if isfield(data.zoosystem.Anthro,'Feet')
    
    feet = data.zoosystem.Anthro.Feet;
    
    if isin(feet,'skates')
        
        d = which('director'); % returns path to ensemlber
        p = pathname(d) ;  % local folder where director resides
        p = [p,s,'Cinema objects',s,'skate'];
        
        skate_fl = engine('fld',p,'extension','prop');
        
        for i = 1:length(skate_fl)
            props('load skates',skate_fl{i});
        end
        
        %    remove feet
        
        fpatch = {'LeftToe','RightToe','LeftFoot','RightFoot'};
        for i = 1:length(fpatch)
            hnd =  findobj('type','patch','tag',fpatch{i});
            set(hnd,'FaceColor','none');
        end
    end
    
end

function [data,isPiG] = getPiG(data,ch)

isPiG = true;

PiG_common = {'LASI', 'LKNE', 'LTHI', 'LTIB', 'LANK', 'LTOE',...
             'RASI', 'RKNE' 'RTHI', 'RTIB', 'RANK', 'RTOE'};

PiG_common_exp = explodelist(PiG_common);

if ~isempty(intersect(ch,{'PELO'})) && ~isempty(findobj(finddobj('props'),'tag','Pelvis'))
    disp('PiG bones detected')
    
elseif length(intersect(PiG_common, ch)) == length(PiG_common)
    disp('Creating PiG bones from existing PiG markers')
    data = makebones_data(data);
    
elseif length(intersect(PiG_common_exp, ch)) == length(PiG_common_exp)
    disp('Creating PiG bones from exploded data of existing Pig markers')
    
    for i = 1:length(ch)
        if length(ch{i})==6 && ~isempty(strfind(ch{i},'_x'))
            chn = ch{i};
            chn = chn(1:4);
            data = mergechannel_data(data,chn);
        end
        
    end
    data = makebones_data(data);
    
elseif ismember({'RPSI','LPSI'},ch)
    disp('Creating PiG bones from alternative PiG marker set')
    if ~isfield(data.zoosystem.Anthro,'RAnkleWidth')
        disp('Estimating knee and ankle joint centre for display purposes only')
        data = addchannel_data(data,'RKneeJC',data.RKNE.line,'video');
        data = addchannel_data(data,'LKneeJC',data.LKNE.line,'video');
        data = addchannel_data(data,'RAnkleJC',data.RANK.line,'video');
        data = addchannel_data(data,'LAnkleJC',data.LANK.line,'video');
    end
    data = makebones_data(data);
    
elseif ismember({'RPSI_x','LPSI_x'},ch)
    disp('Creating PiG bones from alternative exploded PiG marker set')
    
    for i = 1:length(ch)
        if length(ch{i})==6 && ~isempty(strfind(ch{i},'_x'))
            chn = ch{i};
            chn = chn(1:4);
            data = mergechannel_data(data,chn);
        end
        
    end
    
    data = makebones_data(data);
else
    isPiG = false;
    
end

function buttondownfxn

switch getbdownfxn
    case 'del vertex'
        delete(gco);
end

function mark(frm)
mrk = finddobj('marker');
for i = 1:length(mrk)
    mud = get(mrk(i),'userdata');
    indx = min(max(1,frm),length(mud.dis(:,1)));
    dis = mud.dis(indx,:);
    vr = displace(mud.vertices,dis);
    set(mrk(i),'vertices',vr);
end

function r = getbdownfxn
hnd = findobj(findobj(finddobj('figure'),'tag','bdownfxns'),'value',1);

if isempty(hnd)
    r = 'nothing';
else
    r = get(hnd,'string');
end

function r = createmarker(nm,sz,pos,clr)

[x,y,z] = sphere(15);
x = (x*sz/2);
y = (y*sz/2);
z = (z*sz/2);

[vr,fc] = surface2patch(x,y,z);
ud.vertices = vr;
ud.faces = fc;
ud.color = clr;
ud.dis = pos;
ud.size = sz;
ax = finddobj('axes');

r = patch('parent',ax,'tag',nm,'facecolor',ud.color,'edgecolor','none','buttondownfcn',...
    'marker(''buttondown'')','vertices',ud.vertices,'faces',ud.faces,'userdata',ud,...
    'FaceLighting','gouraud','createfcn','marker(''createfcn'')','clipping','off');
mark(finddobj('frame','number'));
