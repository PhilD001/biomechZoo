function cutdata(indx1,indx2);


prp = finddobj('props');

for i = 1:length(prp);
    ud = get(prp(i),'userdata');
    if isfield(ud,'dis');
        if indx2 < length(ud.dis(:,1))
            ud.dis = ud.dis(indx1:indx2,:);
        end
    end
    if isfield(ud,'ort');
        if indx2 < length(ud.ort)
            ud.ort = ud.ort(indx1:indx2);
        end
    end
    if isfield(ud,'fx')
        ud.fx = ud.fx(indx1:indx2);
        ud.fy = ud.fy(indx1:indx2);
        ud.fz = ud.fz(indx1:indx2);
        ud.mx = ud.mx(indx1:indx2);
        ud.my = ud.my(indx1:indx2);
        ud.mz = ud.mz(indx1:indx2);
    end
    if isfield(ud,'JointCenter');
        ud.JointCenter = ud.JointCenter(indx1:indx2,:);
    end
    
    if isfield(ud,'GrootSuntay');
        ud.GrootSuntay.flexion = ud.GrootSuntay.flexion(indx1:indx2,:);
        ud.GrootSuntay.abduction = ud.GrootSuntay.abduction(indx1:indx2,:);
        ud.GrootSuntay.twist = ud.GrootSuntay.twist(indx1:indx2,:);
        ud.GrootSuntay.vectors = ud.GrootSuntay.vectors(indx1:indx2);
    end
    set(prp(i),'userdata',ud);
end
    