function G_S = g_s(LKIN)

 
% G_S outputs the G_S Local Coordinate system axes for each lower-limb
% segment
%
% ARGUMENTS
%    LKIN     ...   the original i,j,k LCS axes for each limb
%
% RETURNS
%   G_S       ...   the Grood and Suntay axes (i distal, k proximal and l
%                   floating for each segment)
%
% Update 20 May 2008
% THIS FUNCTION HAS BEEN REPLACED BY ANGULAR_KIN

%---------------SEGMENT EMBEDDED AXES--------



i_pelvis = LKIN.Segment.Pelvis.Axes.i;
%j_pelvis = LKIN.Segment.Pelvis.Axes.j;
k_pelvis = LKIN.Segment.Pelvis.Axes.k;

i1 = LKIN.Segment.RightThigh.Axes.i;
%j1 = LKIN.Segment.RightThigh.Axes.j;
k1 = LKIN.Segment.RightThigh.Axes.k;

i2 = LKIN.Segment.LeftThigh.Axes.i;
%j2 =LKIN.Segment.LeftThigh.Axes.j;
k2 = LKIN.Segment.LeftThigh.Axes.k;

i3 =LKIN.Segment.RightShank.Axes.i;
j3 =LKIN.Segment.RightShank.Axes.j;
k3 = LKIN.Segment.RightShank.Axes.k;

i4 = LKIN.Segment.LeftShank.Axes.i;
j4 = LKIN.Segment.LeftShank.Axes.j;
k4 = LKIN.Segment.LeftShank.Axes.k;

i5 = LKIN.Segment.RightFoot.Axes.i;
%j5 = LKIN.Segment.RightFoot.Axes.j;
k5 = LKIN.Segment.RightFoot.Axes.k;

i6 = LKIN.Segment.LeftFoot.Axes.i; 
%j6 = LKIN.Segment.LeftFoot.Axes.j; 
k6 = LKIN.Segment.LeftFoot.Axes.k; 


%---GROOD AND SUNTAY AXES------


% i_dist_pelvis = i_pelvis;            %Pelvis                         
% k_prox_pelvis = k_thorax;
% l_pelvis = cross(k_thorax,i_pelvis,2);


i_dist_rh = i1;                     %Right Hip                         
k_prox_rh = k_pelvis;
l_rh = cross(k_pelvis,i1,2);

i_dist_lh = i2;                     %Left Hip                         
k_prox_lh = k_pelvis;
l_lh = cross(k_pelvis,i2,2);

i_dist_rk = i3;                     %Right knee                        
k_prox_rk = k1;
l_rk = cross(k1,i3,2);

i_dist_lk = i4;                     %left knee
k_prox_lk = k2;
l_lk =  cross(k2,i4,2);                                           
                                            
i_dist_ra = i5;                     %Right ankle                    
k_prox_ra = k3;
l_ra = cross(k3,i5,2);

i_dist_la = i6;                     %Left ankle                       
k_prox_la = k4;
l_la = cross(k4,i6,2);




%-------------EXPORT AS STRUCTURED ARRAY AND FIX SIGNS-----
G_S = struct;




G_S.RightHip.Axes.i=i_dist_rh;                                         
G_S.RightHip.Axes.k=k_prox_rh;
G_S.RightHip.Axes.l=l_rh;

G_S.LeftHip.Axes.i=i_dist_lh;
G_S.LeftHip.Axes.k=k_prox_lh;
G_S.LeftHip.Axes.l=l_lh;

G_S.RightKnee.Axes.i=i_dist_rk;
G_S.RightKnee.Axes.k=k_prox_rk;
G_S.RightKnee.Axes.l=l_rk;

G_S.LeftKnee.Axes.i=i_dist_lk;
G_S.LeftKnee.Axes.k=k_prox_lk;
G_S.LeftKnee.Axes.l=l_lk;

G_S.RightAnkle.Axes.i=i_dist_ra;
G_S.RightAnkle.Axes.k=k_prox_ra;
G_S.RightAnkle.Axes.l=l_ra;

G_S.LeftAnkle.Axes.i=i_dist_la;
G_S.LeftAnkle.Axes.k=k_prox_la;
G_S.LeftAnkle.Axes.l=l_la;
