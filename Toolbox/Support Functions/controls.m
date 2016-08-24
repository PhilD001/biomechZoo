function varargout = controls(action,varargin)

switch action
    case 'actor'
        co = finddobj('current object');
        
        uic1 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','text','string','color map','foregroundcolor',[1 1 1],'backgroundcolor',[0 0 0],...
            'createfcn','controls(''createfcn'')','horizontalalignment','right');
        position(uic1,co,'top',[0 .1]);
        
        uic2 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','pushbutton','string','import','foregroundcolor',[1 1 1],'backgroundcolor',[0 0 0],...
            'createfcn','controls(''createfcn'')','callback','actor(''import cmap'')','tag','cmap');
        position(uic2,uic1,'right',[.1 0]);
        
        uic = uicontrol('units','centimeters','position',[0 0 2 .5],'style','text','string','cdata','foregroundcolor',[1 1 1],'backgroundcolor',[0 0 0],...
            'createfcn','controls(''createfcn'')','horizontalalignment','right');
        position(uic,uic1,'top',[0 .1]);
        
        uic2 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','pushbutton','string','import','foregroundcolor',[1 1 1],'backgroundcolor',[0 0 0],...
            'createfcn','controls(''createfcn'')','callback','actor(''import cdata'')','tag','cdata');
        position(uic2,uic,'right',[.1 0]);
        
        uic3 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','text','string','coeff','foregroundcolor',[1 1 1],'backgroundcolor',[0 0 0],...
            'createfcn','controls(''createfcn'')','horizontalalignment','right');
        position(uic3,uic,'top',[0 .1]);
        
        uic4 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','edit','string','1 0','foregroundcolor',[1 1 1],'backgroundcolor',[0 0 0],...
            'createfcn','controls(''createfcn'')','tag','coeff');
        position(uic4,uic3,'right',[.1 0]);
        
        uic5 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','text','string','cvertices','foregroundcolor',[1 1 1],'backgroundcolor',[0 0 0],...
            'createfcn','controls(''createfcn'')','horizontalalignment','right');
        position(uic5,uic3,'top',[0 .1]);
        
        uic6 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','popupmenu','foregroundcolor',[0 0 0],'backgroundcolor',[.8 .8 .8],...
            'createfcn','controls(''createfcn'')','tag','cvertices');
        position(uic6,uic5,'right',[.1 0]);
        
        uic7 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','text','string','color','foregroundcolor',[1 1 1],'backgroundcolor',[0 0 0],...
            'createfcn','controls(''createfcn'')','horizontalalignment','right');
        position(uic7,uic5,'top',[0 .1]);
        
        uic8 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','pushbutton','string','','foregroundcolor',[1 1 1],'backgroundcolor',[.8 .8 .8],...
            'createfcn','controls(''createfcn'')','tag','color','callback','actor(''color button'')');
        position(uic8,uic7,'right',[.1 0]);
        
        uic9 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','text','string','visible','foregroundcolor',[1 1 1],'backgroundcolor',[0 0 0],...
            'createfcn','controls(''createfcn'')','horizontalalignment','right');
        position(uic9,uic7,'top',[0 .1]);
        
        uic10 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','pushbutton','string','import','foregroundcolor',[1 1 1],'backgroundcolor',[0 0 0],...
            'createfcn','controls(''createfcn'')','callback','actor(''import visible'')','tag','visible');        
        position(uic10,uic9,'right',[.1 0]);
        
        uic11 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','text','string','bodypart','foregroundcolor',[1 1 1],'backgroundcolor',[0 0 0],...
            'createfcn','controls(''createfcn'')','horizontalalignment','right');
        position(uic11,uic9,'top',[0 .1]);
        
        uic12 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','text','string','','foregroundcolor',[1 1 1],'backgroundcolor',[0 0 0],...
            'createfcn','controls(''createfcn'')','tag','bodypart');        
        position(uic12,uic11,'right',[.1 0]);
        
        uic13 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','text','string','actor','foregroundcolor',[1 1 1],'backgroundcolor',[0 0 0],...
            'createfcn','controls(''createfcn'')','horizontalalignment','right');
        position(uic13,uic11,'top',[0 .1]);
        
        uic14 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','text','string','','foregroundcolor',[1 1 1],'backgroundcolor',[0 0 0],...
            'createfcn','controls(''createfcn'')','tag','actor');        
        position(uic14,uic13,'right',[.1 0]);
        
        uic15 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','pushbutton','string','enter','foregroundcolor',[1 1 1],'backgroundcolor',[0 0 0],...
            'createfcn','controls(''createfcn'')','callback','actor(''enter controls'')');        
        position(uic15,uic14,'top',[0 .1]);
        
    case 'cameraman'
        co = finddobj('current object');
        
        uic1 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','text','string','roll','foregroundcolor',[1 1 1],'backgroundcolor',[0 0 0],...
            'createfcn','controls(''createfcn'')','horizontalalignment','right');
        position(uic1,co,'top',[0 .1]);
        
        uic2 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','edit','string','0','foregroundcolor',[1 1 1],'backgroundcolor',[0 0 0],...
            'createfcn','controls(''createfcn'')','tag','roll');
        position(uic2,uic1,'right',[.1 0]);
        
        uic = uicontrol('units','centimeters','position',[0 0 2 .5],'style','text','string','yaw','foregroundcolor',[1 1 1],'backgroundcolor',[0 0 0],...
            'createfcn','controls(''createfcn'')','horizontalalignment','right');
        position(uic,uic1,'top',[0 .1]);
        
        uic2 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','edit','string','0','foregroundcolor',[1 1 1],'backgroundcolor',[0 0 0],...
            'createfcn','controls(''createfcn'')','tag','yaw');
        position(uic2,uic,'right',[.1 0]);
        
        uic3 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','text','string','pitch','foregroundcolor',[1 1 1],'backgroundcolor',[0 0 0],...
            'createfcn','controls(''createfcn'')','horizontalalignment','right');
        position(uic3,uic,'top',[0 .1]);
        
        uic4 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','edit','string','0','foregroundcolor',[1 1 1],'backgroundcolor',[0 0 0],...
            'createfcn','controls(''createfcn'')','tag','pitch');
        position(uic4,uic3,'right',[.1 0]);
        
        uic5 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','text','string','zoom','foregroundcolor',[1 1 1],'backgroundcolor',[0 0 0],...
            'createfcn','controls(''createfcn'')','horizontalalignment','right');
        position(uic5,uic3,'top',[0 .1]);
        
        uic6 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','edit','foregroundcolor',[1 1 1],'backgroundcolor',[0 0 0],...
            'createfcn','controls(''createfcn'')','tag','zoom','string','1');
        position(uic6,uic5,'right',[.1 0]);
        
        uic7 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','pushbutton','string','mark','foregroundcolor',[1 1 1],'backgroundcolor',[0 0 0],...
            'createfcn','controls(''createfcn'')','callback','cameraman(''mark'')');        
        position(uic7,uic6,'top',[0 .1]);
        
        uic8 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','pushbutton','string','reset','foregroundcolor',[0 0 0],'backgroundcolor',[1 0 0],...
            'createfcn','controls(''createfcn'')','callback','cameraman(''reset mark'')');        
        position(uic8,uic7,'top',[0 .5]);
        
        
    case 'grips'
        co = finddobj('current object');
        
        uic1 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','text','string','data','foregroundcolor',[1 1 1],'backgroundcolor',[0 0 0],...
            'createfcn','controls(''createfcn'')','horizontalalignment','right');
        position(uic1,co,'top',[0 .1]);
        
        uic2 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','pushbutton','string','import','foregroundcolor',[1 1 1],'backgroundcolor',[0 0 0],...
            'createfcn','controls(''createfcn'')','callback','grips(''import data'')','tag','data');
        position(uic2,uic1,'right',[.1 0]);
                        
        uic3 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','togglebutton','foregroundcolor',[0 0 0],'backgroundcolor',[.8 .8 .8],...
            'createfcn','controls(''createfcn'')','tag','facealpha','string','floor','callback','grips(''toggle callback'')','value',0);
        position(uic3,uic2,'top',[0 .1]);
        
        uic4 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','togglebutton','foregroundcolor',[0 0 0],'backgroundcolor',[.8 .8 .8],...
            'createfcn','controls(''createfcn'')','tag','facealpha','string','facealpha','callback','grips(''toggle callback'')','value',1);
        position(uic4,uic3,'top',[0 .1]);
        
        uic5 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','pushbutton','string','mark','foregroundcolor',[1 1 1],'backgroundcolor',[0 0 0],...
            'createfcn','controls(''createfcn'')','callback','grips(''mark'')');        
        position(uic5,uic4,'top',[0 .1]);
        
        uic6 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','pushbutton','string','reset','foregroundcolor',[0 0 0],'backgroundcolor',[1 0 0],...
            'createfcn','controls(''createfcn'')','callback','grips(''reset mark'')');        
        position(uic6,uic5,'top',[0 .5]);
        
    case 'props'
        co = finddobj('current object');
        
        uic1 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','text','string','x','foregroundcolor',[1 1 1],'backgroundcolor',[.7 0 0],...
            'createfcn','controls(''createfcn'')','horizontalalignment','center','tag','x','buttondownfcn','props(''vertex position'')','enable','inactive');
        position(uic1,co,'top',[0 .1]);
        
        uic2 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','text','string','y','foregroundcolor',[1 1 1],'backgroundcolor',[0 .7 0],...
            'createfcn','controls(''createfcn'')','buttondownfcn','props(''vertex position'')','tag','y','enable','inactive');
        position(uic2,uic1,'right',[.1 0]);
        
        uic3 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','text','string','z','foregroundcolor',[1 1 1],'backgroundcolor',[0 0 .7],...
            'createfcn','controls(''createfcn'')','buttondownfcn','props(''vertex position'')','tag','z','enable','inactive');
        position(uic3,uic2,'right',[.1 0]);
        
        
        uic = uicontrol('units','centimeters','position',[0 0 2 .5],'style','togglebutton','string','rot face','foregroundcolor',[1 1 1],'backgroundcolor',[.3 .3 .3],...
            'createfcn','controls(''createfcn'')','callback','props(''buttondownfxns'')','tag','bdownfxns');
        position(uic,uic1,'top',[0 .1]);
        
        uic2 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','togglebutton','string','add face','foregroundcolor',[1 1 1],'backgroundcolor',[.3 .3 .3],...
            'createfcn','controls(''createfcn'')','callback','props(''buttondownfxns'')','tag','bdownfxns');
        position(uic2,uic,'right',[.1 0]);
        
        uic3 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','togglebutton','string','del vertex','foregroundcolor',[1 1 1],'backgroundcolor',[.3 .3 .3],...
            'createfcn','controls(''createfcn'')','callback','props(''buttondownfxns'')','tag','bdownfxns');
        position(uic3,uic2,'right',[.1 0]);
        
        uic1 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','togglebutton','string','no edges','foregroundcolor',[1 1 1],'backgroundcolor',[.3 .3 .3],...
            'createfcn','controls(''createfcn'')','callback','props(''buttondownfxns'')','tag','bdownfxns');
        position(uic1,uic,'top',[0 .1]);
        
        uic2 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','togglebutton','string','set origin','foregroundcolor',[1 1 1],'backgroundcolor',[.3 .3 .3],...
            'createfcn','controls(''createfcn'')','callback','props(''buttondownfxns'')','tag','bdownfxns');
        position(uic2,uic1,'right',[.1 0]);
        
        uic3 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','pushbutton','string','create marker','foregroundcolor',[1 1 1],'backgroundcolor',[.3 .3 .3],...
            'createfcn','controls(''createfcn'')','callback','props(''create marker'')','tag','bdownfxns');
        position(uic3,uic2,'right',[.1 0]);
        
        uic = uicontrol('units','centimeters','position',[0 0 2 .5],'style','togglebutton','string','color','foregroundcolor',[1 1 1],'backgroundcolor',[.3 .3 .3],...
            'createfcn','controls(''createfcn'')','callback','props(''buttondownfxns'')','tag','bdownfxns');
        position(uic,uic1,'top',[0 .1]);
        
        uic2 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','togglebutton','string','vertex','foregroundcolor',[1 1 1],'backgroundcolor',[.3 .3 .3],...
            'createfcn','controls(''createfcn'')','callback','props(''buttondownfxns'')','tag','bdownfxns');
        position(uic2,uic,'right',[.1 0]);
        
        uic3 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','togglebutton','string','jointer','foregroundcolor',[1 1 1],'backgroundcolor',[.3 .3 .3],...
            'createfcn','controls(''createfcn'')','callback','props(''buttondownfxns'')','tag','bdownfxns');
        position(uic3,uic2,'right',[.1 0]);
        
         uic1 = uicontrol('units','centimeters','position',[0 0 2 .5],'style','togglebutton','string','v normal','foregroundcolor',[1 1 1],'backgroundcolor',[.3 .3 .3],...
            'createfcn','controls(''createfcn'')','callback','props(''buttondownfxns'')','tag','bdownfxns');
        position(uic1,uic,'top',[0 .1]);
end
        