function bmech_bodyCOM(fld)

% bmech_bodyCOM computes the overall body center of mass based on weightings of individual
% segment COM and adds information as new channel in file
%
% ARGUMENTS
%  fld    ... folder to operate on
%
% NOTES
% - Formula for whole body COM based on ratios from Demster 
%  COM = sum(m_i com_i) / sum (m_i)
%  COM = (m_1 *com_1 + m_2*com_2 + ... + m_n * com_n )  / sum (m_i)
%  COM = m_1*com_1 / sum(m_i) + m_2*com_2 / sum(m_i) + .. + m_n*com_n / sum(m_i)
%  COM = r_1 *com_1 + r_2 *com_2 + ... + r_n *com_n 
%  for each m_i the ratio r_i was used. 
%
% see http://health.uottawa.ca/biomech/csb/Software/dempster.pdf for list
% of ratios


% Revision History
%
% Created by Philippe C. Dixon Oct 23rd 2015
% - based on code from Shiu-Ling (Evelyn) Chiu
%
% Updated by Philippe C. Dixon Feb 17th 2016
% - changed output channel to 'BodyCOM'



if nargin==0
    fld = uigetfolder;
end


cd(fld);
fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    data = zload(fl{i});
    batchdisp(fl{i},'computing body COM');
    data = bodyCOM_data(data);
    zsave(fl{i},data);
end


