function [compcons,maxval] = bmech_continuous_stats_ensembler4(fld,ch,r,alpha,ax,nboots,maxval,check)

% bmech_continuous_stats_ensembler4 computes continuous stats based on Bootstrap confidence intervals
%
%
% ARGUMENTS
% fld          ...   directory where data resides
% ch           ...   channel of zoo file to investigate (string)
% alpha        ...   significance level (default 0.05)
% ax           ...   axis handle
% check        ...   check the summary statistics
%
%
% RETURNS
% compconsstk  ...   used for ensembler. cons gives order of colorbars
% maxval       ...   maxval of all differences for color bar legend
%
%
% NOTE: Creating patch fails in MAC. No solution provided
%
%
% Created May 2012 by Philippe C. Dixon
%
%
%
% Updated June 2012
% - fixed small error with color reporting
% - better visualisation of color bars
%
% Updated August 2012
% -optimized for use in ensembler
%
% Updated November 2012
% - function can handle empty emsembler channels
% - small changes can be expressed over numerous colors
%
% updated Jan 12th 2013
% - complies with zoosystem v1.1
%
% updated Jan 19th 2013
% - maxval and mult are set here as default
%
% updated Feb 28th 2013
% - mult dependent on maxval
%
% updated July 27th 2013
% - function restructured for speed and clarity
% - mult and maxval computed automatically by function
% - function can handle unequal samples sizes
%
% Updatec October 23rd 2013
% - conditions can handle the '+' identifier in ensembler




%---EXTRACT DATA INFORMATION------------------------------------------------------------
%
fl = engine('path',fld,'extension','zoo');
ln = findobj(ax,'type','line');

cons = cell(1,length(ln));

for i = 1:length(ln)
    
    if ~isempty(get(ln(i),'Tag')) && ~isin(get(ln(i),'Tag'),'hline')
        rr =  get(ln(i),'Tag');
        
        if isin(rr,'+')
            indx = strfind(rr,'+');
            part1 = rr(1:indx-1);
            part2 = rr(indx+1:end);
            
            cons{i}= [part1,'_and_',part2];
            
        else
            
            cons{i} =rr;
            
        end
        
    end
end

cons = sort(cons);




%---EXTRACT SUBJECT AND INFO--------------------------------------------------------------------
%
% subs = getsubs_allconditions(fld,cons);
%
% if isempty(subs)
%     disp('WARNING: not all subjects have performed all conditions')
%     [~,subs] = bmech_getsubs(fld);
% end


%---CREATE R STRUCT-----------------------------------------------------------------------
%
% r = grouplines(fld,cons);

%---COMPUTE CONFIDENCE BAND QUANTITIES---------------------------------------------------
%
[mdiffdata,~,mult,~,SigDiffIndx,frames,compcons] = computecolorbars(r,cons,ch,fl,nboots,alpha,check);


if isempty(check)
    
    %---PLOT CONFIDENCE BAND QUANTITIES---------------------------------------------------
    %
    plotcolorbars(mdiffdata,maxval,mult,compcons,frames,SigDiffIndx,ax)
    
end


%======EMBEDDED FUNCTIONS====================================================================


function plotcolorbars(mdiffdata,maxval,mult,compcons,frames,SigDiffIndx,ax)


for i=1:length(compcons)
    
    %---set up faces----------
    p = get(ax,'Position');
    
    verts = [];
    
    for j = 1:length(SigDiffIndx)
        plate = [j-1 1; ...
            j 1; ...
            j 2; ...
            j-1 2];
        
        verts = [verts ; plate];
    end
    verts(:,1) = verts(:,1)+frames(1);
    
    %--create faces by combining vertices in the order indicated.
    faces = [];
    for j = 1:4:length(verts)
        plate = [j j+1 j+2 j+3];
        faces = [faces; plate];
    end
    
    %----matchp data to color----
    yd = abs(mdiffdata(i,:));
    
    c = colormap(jet(maxval*mult));  %uses the jet color map with maxP colors
    
    yd_round = ceil(yd*mult); % ceil must be used since any 0 value would not work
    
    %     if isin(ch,'OFM')  % make OFM data the correct length
    %         nanpad = NaN*ones(1,indx-1);
    %         yd_round = [nanpad yd_round];
    %     end
    
    yd_round(isnan(SigDiffIndx(i,:)))=2;
    av_color = c(yd_round,:);
    
    for j = 1:length(SigDiffIndx(i,:))
        if isnan(SigDiffIndx(i,j))
            av_color(j,:) = [1 1 1] ; % make the nans white
        end
    end
    
    %---set up color bar size-------
    height =p(4)*0.06;   % the amount of space each color graph will take
    left = p(1);
    bottomc  = p(2) - i*1.35*height -0.25;
    width = p(3);
    
    a = axes('units','inches','position',[left bottomc width height],'tag','colormap');
    
    set(a,'XLim',[frames(1)-0.8 frames(end)+1.8])
    set(a,'XTick',[])
    set(a,'YTick',[])
    set(a,'Ylim',[0.9 2.1])
    set(a,'YAxisLocation','right')
    set(a,'Color',[0 0 0])
    
    patch('Faces',faces,'Vertices',verts,'FaceColor','flat','FaceVertexCData',av_color,'EdgeAlpha',0);

    
    tx = {'A','B','C','D','E','F','G','H','I','J','K','L'};
    
    if i>length(tx)
        error('too many comparisons add more letters to tx')
    end
    
    set(get(a,'YLabel'),'String',tx{i})
    set(get(a,'YLabel'),'Rotation',0)
    tpos = get(get(a,'YLabel'),'Position');
    npos = get(gca,'YLim');
    set(get(a,'YLabel'),'Position',[tpos(1) npos(2) tpos(3)])
    
    
    
end








