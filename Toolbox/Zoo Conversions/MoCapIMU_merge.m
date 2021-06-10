function MoCapIMU_merge(fld)
% 
% It assumes that files are arranged in the following order
% MoCap file --> fld\MoCap\Subject_name\filename.zoo or MoCap in the name
% of file
% IMU file --> fld\IMU\Subject_name\filename.zoo or IMU in the name
% of file
% It also assumes files are in chronological order
% MoCapIMU_merge combines MoCap and IMU .zoo files created using Xsens2zoo 
% It cuts IMU files depending on original start and end of the MoCap file
% and explodes MoCap data into _x, _y and _z before mergeing both files.
% zoosystem contains MoCap file zoosystem data and IMUzoosystem has IMU
% zoosystem data.
% It saves file in fld\Merged_files\Subject_name\filename.zoo
%
% ARGUMENTS
% fld    ...   string, folder to operate on
%
% RETURNS
%  data  ...  zoo data. Return if fld is individual file 


fl=engine('fld',fld,'ext','.zoo');
MoCap=fl(contains(fl,'MoCap'));
IMU=fl(contains(fl,'IMU'));
strcell=strfind(MoCap,'\');
foldername=[fld,'\','Merged_files'];
MyFolderInfo = dir(foldername);
if isempty(MyFolderInfo)
    mkdir(foldername)
end
for i=1:length(MoCap)
    strduble=strcell{i};
    size=length(strduble);
    S=strduble(size-1)+1;
    E=strduble(size)-1;
    Sname=MoCap{i}(S:E);
    fodname=[foldername,'\',Sname];
    MyFolderInfo = dir(fodname);
    if isempty(MyFolderInfo)
        mkdir(fodname)
    end
    
    zname=MoCap{i}(E+2:end);
    fname=[fld,'\','Merged_files','\',Sname,'\',zname];
    disp(['Merging MoCap and IMU',zname])
    MoCapData=zload(MoCap{i});
    IMUData=zload(IMU{i});
    data=Merge(MoCapData,IMUData);
    disp(['Saving File to --->',fname])
    zsave(fname,data,'MoCapIMU_merge')
end

function MoCapData=Merge(MoCapData,IMUData)
IMUData.Frames.event.Start=MoCapData.zoosystem.Video.ORIGINAL_START_FRAME;
IMUData.Frames.event.END=MoCapData.zoosystem.Video.ORIGINAL_END_FRAME;
IMUData=partition_data(IMUData,'Start','END');
MoCapData=explode_data(MoCapData);
IMUData=rmfield(IMUData,'Frames');
IMUZooinfo=IMUData.zoosystem;
IMUData=rmfield(IMUData,'zoosystem');
fields=fieldnames(IMUData);
for j=1:length(fields)
    MoCapData = addchannel_data(MoCapData,fields{j},IMUData.(fields{j}).line,'Video');
end
MoCapData.IMUzoosystem=IMUZooinfo;