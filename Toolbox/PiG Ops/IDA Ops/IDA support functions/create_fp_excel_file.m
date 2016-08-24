function create_fp_excel_file

% CREATE_FP_EXCEL_FILE.m generates an excel file required for
% PLUGINGAIT2IDA. A sample file is available in public ("force plate
%      coordinates example file.xls)

% please complete, DOES NOT WORK

%--create blank excel file-----
[f,p] = uigetfile('*.xls','select xls file to save data to');
xlsfile = [p,f];


%--set up excel sheet----
xlswrite(xlsfile,{'Subject'},'Sheet1','A2');
xlswrite(xlsfile,{'Condition'},'Sheet1','B2');
xlswrite(xlsfile,{'FP1: bottom left (LF1)'},'Sheet1','C2');
xlswrite(xlsfile,{'FP1: top left (LF2)'},'Sheet1','F2');
xlswrite(xlsfile,{'FP1: top right (LF3)'},'Sheet1','I2');
xlswrite(xlsfile,{'FP1: bottom right (LF4)'},'Sheet1','L2');

xlswrite(xlsfile,{'x'},'Sheet1','C3');
xlswrite(xlsfile,{'y'},'Sheet1','D3');
xlswrite(xlsfile,{'z'},'Sheet1','E3');
xlswrite(xlsfile,{'x'},'Sheet1','F3');
xlswrite(xlsfile,{'y'},'Sheet1','G3');
xlswrite(xlsfile,{'z'},'Sheet1','H3');
xlswrite(xlsfile,{'x'},'Sheet1','I3');
xlswrite(xlsfile,{'y'},'Sheet1','J3');
xlswrite(xlsfile,{'z'},'Sheet1','K3');
xlswrite(xlsfile,{'x'},'Sheet1','L3');
xlswrite(xlsfile,{'y'},'Sheet1','M3');
xlswrite(xlsfile,{'z'},'Sheet1','N3');

xlswrite(xlsfile,{'S01'},'Sheet1','A4');
xlswrite(xlsfile,{'S02'},'Sheet1','A6');
xlswrite(xlsfile,{'S03'},'Sheet1','A8');
xlswrite(xlsfile,{'S04'},'Sheet1','A10');
xlswrite(xlsfile,{'S05'},'Sheet1','A12');
xlswrite(xlsfile,{'S06'},'Sheet1','A14');
xlswrite(xlsfile,{'S07'},'Sheet1','A16');
xlswrite(xlsfile,{'S08'},'Sheet1','A18');
xlswrite(xlsfile,{'S09'},'Sheet1','A20');
xlswrite(xlsfile,{'S10'},'Sheet1','A22');

xlswrite(xlsfile,{'flat'},'Sheet1','B4');
xlswrite(xlsfile,{'cross'},'Sheet1','B5');
xlswrite(xlsfile,{'flat'},'Sheet1','B6');
xlswrite(xlsfile,{'cross'},'Sheet1','B7');
xlswrite(xlsfile,{'flat'},'Sheet1','B8');
xlswrite(xlsfile,{'cross'},'Sheet1','B9');
xlswrite(xlsfile,{'flat'},'Sheet1','B10');
xlswrite(xlsfile,{'cross'},'Sheet1','B11');
xlswrite(xlsfile,{'flat'},'Sheet1','B12');
xlswrite(xlsfile,{'cross'},'Sheet1','B13');
xlswrite(xlsfile,{'flat'},'Sheet1','B14');
xlswrite(xlsfile,{'cross'},'Sheet1','B15');
xlswrite(xlsfile,{'flat'},'Sheet1','B16');
xlswrite(xlsfile,{'cross'},'Sheet1','B17');
xlswrite(xlsfile,{'flat'},'Sheet1','B18');
xlswrite(xlsfile,{'cross'},'Sheet1','B19');
xlswrite(xlsfile,{'flat'},'Sheet1','B20');
xlswrite(xlsfile,{'cross'},'Sheet1','B21');
xlswrite(xlsfile,{'flat'},'Sheet1','B22');
xlswrite(xlsfile,{'cross'},'Sheet1','B23');

 %-----collect data-------

fld = uigetfolder('select root of data');
cd(fld);

sub= subdir(fld);

cdatastk = [];
subjectstk=[];
conditionstk=[];


fl = engine('path',fld,'extension','zoo');

for i = 1:length(fl)
    
    data = load(fl{i},'-mat');
    disp(['extracting force plate coordinates from :',fl{i}]);
    data = data.data;
    [cdata,subject,condition] = fpdata(data,fl{i});
    
    cdatastk = [cdatastk cdata];
    subjectstk = [subjectstk subject];
    condiitonstk = [conditionstk condition];
    
end

xlswrite(xlsfile,cdatastk,'Sheet1','C4');

function [cdata,subject,condition] = fpdata(data,zfilename)

indx= findstr(zfilename,'subject');           %choose correct coordinate system based on subject/condition
subject = zfilename(indx+7:indx+8);

indx = findstr(zfilename,'\');
indx = indx(end-1:end);
condition = zfilename(indx(1)+1: indx(2)-1);


cdata = [mean(data.LF1.line(:,1))  mean(data.LF1.line(:,2))  mean(data.LF1.line(:,3))...
                mean(data.LF2.line(:,1))  mean(data.LF2.line(:,2))  mean(data.LF2.line(:,3))...
                mean(data.LF3.line(:,1))  mean(data.LF3.line(:,2))  mean(data.LF3.line(:,3)) ...
                mean(data.LF4.line(:,1))  mean(data.LF4.line(:,2))  mean(data.LF4.line(:,3)) ] ; 
            
            
            
