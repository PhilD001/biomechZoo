function [data, text, rawData, customOutput]=xlsread1(file,sheet,range,mode,customFun)
% XLSREAD Get data and text from a spreadsheet in an Excel workbook.
%   [NUMERIC,TXT,RAW]=XLSREAD(FILE) reads the data specified in the Excel 
%   file, FILE. The numeric cells in FILE are returned in NUMERIC, the text 
%   cells in FILE are returned in TXT, while the raw, unprocessed cell 
%   content is returned in RAW.  
%
%   [NUMERIC,TXT,RAW]=XLSREAD(FILE,SHEET,RANGE) reads the data specified
%   in RANGE from the worksheet SHEET, in the Excel file specified in FILE. 
%   It is possible to select the range of data interactively (see Examples
%   below). Please note that the full functionality of XLSREAD depends on 
%   the ability to start Excel as a COM server from MATLAB. 
%
%   [NUMERIC,TXT,RAW]=XLSREAD(FILE,SHEET,RANGE,'basic') reads an XLS file as
%   above, using basic input mode. This is the mode used on UNIX platforms
%   as well as on Windows when Excel is not available as a COM server.  
%   In this mode, XLSREAD does not use Excel as a COM server, which limits
%   import ability. Without Excel as a COM server, RANGE will be ignored
%   and, consequently, the whole active range of a sheet will be imported. 
%   Also, in basic mode, SHEET is case-sensitive and must be a string.
%
%   [NUMERIC,TXT,RAW]=XLSREAD(FILE,SHEET,RANGE,'',CUSTOMFUN)
%   [NUMERIC,TXT,RAW,CUSTOMOUTPUT]=XLSREAD(FILE,SHEET,RANGE,'',CUSTOMFUN)
%   When the Excel COM server is used, allows passing in a handle to a
%   custom function.  This function will be called just before retrieving 
%   the actual data from Excel. It must take an Excel Range object (e.g. of
%   type 'Interface.Microsoft_Excel_5.0_Object_Library.Range') as input,
%   and return one as output.  Optionally, this custom function may return
%   a second output argument, which will be returned from XLSREAD as the
%   fourth output argument, CUSTOMOUTPUT.  For details of what is possible 
%   using the EXCEL COM interface, please refer to Microsoft documentation.
%
%   INPUT PARAMETERS:
%   FILE: string defining the file to read from. Default directory is pwd.
%         Default extension is 'xls'.
%   SHEET: string defining worksheet name in workbook FILE.
%          double scalar defining worksheet index in workbook FILE. See
%          NOTE 1.
%   RANGE: string defining the data range in a worksheet. See NOTE 2.
%   MODE: string enforcing basic import mode. Valid value = 'basic'.  This
%   is the mode always used when COM is not available (e.g. on Unix).
%
%   RETURN PARAMETERS:
%   NUMERIC = n x m array of type double.
%   TXT = r x s cell string array containing text cells in RANGE.
%   RAW = v x w cell array containing unprocessed numeric and text data.
%   Both NUMERIC and TXT are subsets of RAW.
%
%   EXAMPLES:
%   1. Default operation:  
%      NUMERIC = xlsread(FILE);
%      [NUMERIC,TXT]=xlsread(FILE);
%      [NUMERIC,TXT,RAW]=xlsread(FILE);
%
%   2. Get data from the default region:
%      NUMERIC = xlsread('c:\matlab\work\myspreadsheet')
%
%   3. Get data from the used area in a sheet other than the first sheet:
%      NUMERIC = xlsread('c:\matlab\work\myspreadsheet','sheet2')
%
%   4. Get data from a named sheet:
%      NUMERIC = xlsread('c:\matlab\work\myspreadsheet','NBData')
%
%   5. Get data from a specified region in a sheet other than the first
%      sheet:
%      NUMERIC = xlsread('c:\matlab\work\myspreadsheet','sheet2','a2:j5')
% 
%   6. Get data from a specified region in a named sheet:
%      NUMERIC = xlsread('c:\matlab\work\myspreadsheet','NBData','a2:j5')
% 
%   7. Get data from a region in a sheet specified by index:
%      NUMERIC = xlsread('c:\matlab\work\myspreadsheet',2,'a2:j5')
% 
%   8. Interactive region selection:
%      NUMERIC = xlsread('c:\matlab\work\myspreadsheet',-1);
%      You have to select the active region and the active sheet in the
%      EXCEL window that will come into focus. Click OK in the Data 
%      Selection Dialog when you have finished selecting the active region.
%
%   9. Using the custom function:
%      [NUMERIC,TXT,RAW,CUSTOMOUTPUT] = xlsread('equity.xls', ..., @MyCustomFun)
%      Where the CustomFun is defined as:
%
%      function [DataRange, customOutput] = MyCustomFun(DataRange)
%         DataRange.NumberFormat = 'Date';
%         customOutput = 'Anything I want';
%     
%      This will convert to dates all cells where that is possible.
%
%   NOTE 1: The first worksheet of the workbook is the default sheet. If 
%         SHEET is -1, Excel comes to the foreground to enable interactive 
%         selection (optional). In interactive mode, a dialogue will prompt 
%         you to click the OK button in that dialogue to continue in MATLAB. 
%          (Only supported when Excel COM server is available.)
%   NOTE 2: The regular form is: 'D2:F3' to select rectangular region D2:F3 
%         in a worksheet. RANGE is not case sensitive and uses Excel A1 
%         notation (see Excel Help). (Only supported when Excel COM server 
%         is available.)
%   NOTE 3: Excel formats other than the default can also be read.
%          (Only supported when Excel COM server is available.)
%
%   See also XLSWRITE, CSVREAD, CSVWRITE, DLMREAD, DLMWRITE, TEXTSCAN.

%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 1.23.4.24 $  $Date: 2007/12/06 13:30:15 $
%=============================================================================

% Excel = evalin('base','Excel'); % added command (Brandao 12/09/2008)


try 
    Excel = evalin('base','Excel'); 
catch err 
    Excel = evalin('caller','Excel'); 
end


% initialise variables
data = [];
text = {};
rawData = {};

Sheet1 = 1;
if nargin < 2
    sheet = Sheet1;
    range = '';
elseif nargin < 3
    range = '';
end

% handle input values
if nargin < 1 || isempty(file)
    error('MATLAB:xlsread:FileName','Filename must be specified.');
end

if ~ischar(file)
    error('MATLAB:xlsread:InputClass','Filename must be a string.');
end

if nargin > 1
    % Verify class of sheet parameter
    if ~ischar(sheet) && ...
            ~(isnumeric(sheet) && length(sheet)==1 && ...
              floor(sheet)==sheet && sheet >= -1)
        error('MATLAB:xlsread:InputClass',...
            'Sheet argument must a string or an integer.');
    end

    if isequal(sheet,-1)
        range = ''; % user requests interactive range selection.
    elseif ischar(sheet)
        if ~isempty(sheet)
            % Parse sheet and range strings
            if isempty(strfind(sheet,':'))
            else
                range = sheet; % only range was specified. 
                sheet = Sheet1;% Use default sheet.
            end
        else
            sheet = Sheet1; % set sheet to default sheet.
        end
    end
end
if nargin > 2
    % verify class of range parameter
    if ~ischar(range)
        error('MATLAB:xlsread:InputClass',...
            'Range argument must a string. See HELP XLSREAD.');
    end
end
if nargin >= 4
    % verify class of mode parameter
    if ~isempty(mode) && ~(strcmpi(mode,'basic'))
        warning('MATLAB:xlsread:InputClass',...
            'Import mode string is invalid. XLSREAD resets mode to normal.');
        mode = '';
    end
else
    mode = '';
end

custom = false;
if nargin >= 5 
    if strcmpi(mode,'basic') || ~ispc
        warning('MATLAB:xlsread:Incompatible',...
         ['Custom functions cannot be used in basic mode or on non-Windows platforms.\n'...
          'The custom function argument will be ignored.'])
    elseif ~isa(customFun,'function_handle')
            warning('MATLAB:xlsread:NotHandle', ...
                'The fifth argument to XLSREAD must be a function handle.');
    else
        custom = true;
    end
end 
    
%==============================================================================
% block command crossed out (Brandao 12/09/2008)
% handle requested Excel workbook filename
% try
%     file = validpath(file,'.xls');
% catch exception
%     err = MException('MATLAB:xlsread:FileNotFound','XLSREAD unable to open file %s.\n%s',...
%                            file,exception.message);
%     throw(err);
% end
%==============================================================================
% select import mode from either normal or basic mode.
if strcmpi(mode,'basic') || ~ispc
    warning('MATLAB:xlsread:Mode',...
        ['XLSREAD has limited import functionality on non-Windows platforms\n'...
            'or in basic mode.  Refer to HELP XLSREAD for more information.']);
    try
		if nargout > 2
	        [data,text,rawData] = xlsreadold(file,sheet);
		else
			[data,text] = xlsreadold(file,sheet);
		end
    catch exception
        if isempty(exception.identifier)
            exception = MException('MATLAB:xlsreadold:FormatError','%s', exception.message);
        end
        throw(exception);
    end
    return;
% else  % block command crossed out (Brandao 12/09/2008)
%     % Attempt to start Excel as ActiveX server process.
%     try
%         Excel = actxserver('excel.application');
%     catch exc1
%         % revert to old XLSREAD that uses BIFFREAD
%         warning('MATLAB:xlsread:ActiveX',...
%             ['Could not start Excel server for import. '...
%                 'Refer to documentation.']);
%         try
% 			if nargout > 2
% 				[data,text,rawData] = xlsreadold(file,sheet);
% 			else
% 				[data,text] = xlsreadold(file,sheet);
% 			end
%         catch exc2
%             message=sprintf('%s\n%s', exc1.message, exc2.message);
%             if isempty(exc2.identifier)
%                 exception = MException('MATLAB:xlsreadold:FormatError', message);
%             else
%                 exception = MException(exc2.identifier, message);                
%             end
%             throw(exception);
%         end
%         return;
%     end
end
%==============================================================================
try
     % open workbook
    Excel.DisplayAlerts = 0; 
    
    
    %Workaround for G313142.  For certain files, unless a workbook is
    %opened prior to openiong the file, various COm calls return an error:
    %0x800a9c64.  The line below works around this flaw.  Since we have
    %seen only one example of such a file, we have decided not to incur the
    %time penalty involved here.
%     aTemp = Excel.workbooks.Add(); aTemp.Close();
    
%     try % block command crossed out (Brandao 12/09/2008)
%         ExcelWorkbook = Excel.workbooks.Open(file,0,true);
%     catch exception  %#OK
%         %do not pollute lasterror state
%     end
    
%     % block command crossed out (Brandao 12/09/2008)
%     format = ExcelWorkbook.FileFormat;
%     if  strcmpi(format, 'xlCurrentPlatformText') == 1
%         error('MATLAB:xlsread:FileFormat', 'File %s not in Microsoft Excel Format.', file);
%     end

    if nargin >= 2
        % User specified at least a worksheet or interactive range selection.
        if ~isequal(sheet,-1)
            % Activate indicated worksheet.
            activate_sheet(Excel,sheet);

            try % importing a data range.
                if ~isempty(range)
                    % The range is specified.
                    Select(Range(Excel,sprintf('%s',range)));
                    DataRange = get(Excel,'Selection');
                else
                    % Only the worksheet is specified. 
                    % Activate upper left cell on sheet. 
                    Activate(Range(Excel,'A1'));
                    
                    % Select range of occupied cells in active sheet.
                    DataRange = Excel.ActiveSheet.UsedRange;
                end
            catch % data range error.
                error('MATLAB:xlsread:RangeSelection',...
                    'Data range is invalid.');
            end

        else
            % User requests interactive range selection.
            % Set focus to first sheet in Excel workbook.
            activate_sheet(Excel,Sheet1);

            % Make Excel interface the active window.
            set(Excel,'Visible',true);

            % bring up message box to prompt user.
            uiwait(warndlg({'Select data region in Excel worksheet.';...
                    'Click OK to continue in MATLAB'},...
                    'Data Selection Dialogue','modal'));
            DataRange = get(Excel,'Selection');
            set(Excel,'Visible',false); % remove Excel interface from desktop
        end
    else
        % No sheet or range or interactive range selection. 
        % Activate default worksheet.
        activate_sheet(Excel,Sheet1);
        
        % Select range of occupied cells in active sheet.
        DataRange = Excel.ActiveSheet.UsedRange;
    end

    %Call the custom function if it was given.  Provide customOutput if it
    %is possible.
    if custom
		if nargout(customFun) < 2
			DataRange = customFun(DataRange);
            customOutput = {};
		else
			[DataRange, customOutput] = customFun(DataRange);	
		end
	end
	
    % get the values in the used regions on the worksheet.
    rawData = DataRange.Value;
    % parse data into numeric and string arrays
    [data,text] = parse_data(rawData); 
    
catch exception
%     try % block command crossed out (Brandao 12/09/2008)
%         ExcelWorkbook.Close(false); % close workbook without saving any changes
%     catch exc2  %#OK
%         %Do not pollute lasterror state
%     end
    rethrow(exception);	% rethrow original error
end
    
% try % block command crossed out (Brandao 12/09/2008)
%     ExcelWorkbook.Close(false); % close workbook without saving any changes
%     %This call could fail if the file is "locked".  This is the same
%     %message you would get if you opened the file in Excel, and then tried
%     %to close the workbook (NOT the application).
%     Excel.Quit;
% catch exception
%     warning(exception.identifier, '%s', exception.message);
%     Excel.Quit;
% end

%--------------------------------------------------------------------------
function [numericArray,textArray] = parse_data(data)
% PARSE_DATA parse data from raw cell array into a numeric array and a text
% cell array.
% [numericArray,textArray] = parse_data(data)
% Input:
%        data: cell array containing data from spreadsheet
% Return:
%        numericArray: double array containing numbers from spreadsheet
%        textArray: cell string array containing text from spreadsheet
%==========================================================================

% ensure data is in cell array
if ischar(data)
    data = cellstr(data);
elseif isnumeric(data) || islogical(data)
    data = num2cell(data);
end

% Check if raw data is empty
if isempty(data)
    % Abort when all data cells are empty.
    textArray = {};
    numericArray = [];
    return
else
    % Trim empty leading and trailing rows
    % find empty cells
    emptycells = cellfun('isempty',data);
    nrows = size(emptycells,1);
    firstrow = 1;
    % find last of leading empty rows
    while (firstrow<=nrows && all(emptycells(firstrow,:)))
         firstrow = firstrow+1;
    end
    % remove leading empty rows
    data = data(firstrow:end,:);
    
    % find start of trailing empty rows
    nrows = size(emptycells,1);
    lastrow = nrows;
    while (lastrow>0 && all(emptycells(lastrow,:)))
        lastrow = lastrow-1;
    end
    % remove trailing empty rows
    data = data(1:lastrow,:);
    
    % find start of trailing NaN rows
    warning('off', 'MATLAB:nonIntegerTruncatedInConversionToChar');
    while (lastrow>0 && ~(any(cellfun('islogical', data(lastrow,:)))) && ...
                        all(isnan([data{lastrow,:}])))
        lastrow = lastrow-1;
    end
    warning('on', 'MATLAB:nonIntegerTruncatedInConversionToChar');
    % remove trailing NaN rows    
    data=data(1:lastrow,:);
    
    [n,m] = size(data);
    textArray = cell(size(data));
    textArray(:) = {''};
end

vIsNaN = false(n,m);

% find non-numeric entries in data cell array
vIsText = cellfun('isclass',data,'char');
vIsNaN = cellfun('isempty',data)|strcmpi(data,'nan')|cellfun('isclass',data,'char');

% place text cells in text array
if any(vIsText(:))
    textArray(vIsText) = data(vIsText);
else
    textArray = {};
end
% Excel returns COM errors when it has a #N/A field.
textArray = strrep(textArray,'ActiveX VT_ERROR: ','#N/A');

% place NaN in empty numeric cells
if any(vIsNaN(:))
    data(vIsNaN)={NaN};
end

% extract numeric data
data = reshape(data,n,m);
rows = size(data,1);
m = cell(rows,1);
% Concatenate each row first
for n=1:rows
    m{n} = cat(2,data{n,:});
end
% Now concatenate the single column of cells into a matrix
numericArray = cat(1,m{:});

    
% trim all-NaN leading rows and columns from numeric array
% trim all-empty trailing rows and columns from text arrays
[numericArray,textArray]=trim_arrays(numericArray,textArray);

% ensure numericArray is 0x0 empty.
if isempty(numericArray)
    numericArray = [];
end

%--------------------------------------------------------------------------
function activate_sheet(Excel,Sheet)
% Activate specified worksheet in workbook.

% Initialise worksheet object
WorkSheets = Excel.sheets;

% Get name of specified worksheet from workbook
try
    TargetSheet = get(WorkSheets,'item',Sheet);
catch
    error('MATLAB:xlsread:WorksheetNotFound',...
          'Specified worksheet was not found.');
end

%Activate silently fails if the sheet is hidden
set(TargetSheet, 'Visible','xlSheetVisible');
% activate worksheet
Activate(TargetSheet);

%--------------------------------------------------------------------------
function [matrixResult,cellResult,rawResult]=xlsreadold(filename,sheet)
% Basic import mode. Range specification not available.
% Interactive range selection not available.
% Read Excel file as binary image file
if nargin > 1
    if isequal(sheet,1) || isequal(sheet,-1)
        sheet = ''; 
    elseif ~ischar(sheet)
        error('MATLAB:xlsread:WorksheetNotFound',...
            'In basic mode, sheet argument must be a string.');
    end
end
% read XLS file
biffvector = biffread(filename);

% get sheet names
[data, names] = biffparse(biffvector);

% if the names array is empty, this is an old style biff record with 
% no sheet name.  Just return data and empty text cell array.
if isempty(names) 
    matrixResult = data;
    cellResult = cell(names);
	if nargout > 2
	    rawResult = num2cell(data);
	end
    return;
end

if nargin == 1 || isempty(sheet)
    % just get the first sheet
    [n, s] = biffparse(biffvector, names{1});
else
    % try to read this sheet
    try
        [n, s] = biffparse(biffvector, sheet);
    catch
        error('MATLAB:xlsread:WorksheetNotFound',...
            'Specified worksheet was not found.');
    end
end

% trim trailing empty text cells and NaN matrix elements
[matrixResult, cellResult] = trim_arrays(n,s);
% replace empty text cells with char([]).
cellResult(cellfun('isempty',cellResult))={''};

if nargout > 2
	% create raw data return
	if isempty(s)
		rawResult = num2cell(n);
	else
		rawResult = cell(max(size(n),size(s)));
		rawResult(1:size(n,1),1:size(n,2)) = num2cell(n);
		for i = 1:size(s,1)
			for j = 1:size(s,2)
				if (~isempty(s{i,j}) && (i > size(n,1) || j > size(n,2) || isnan(n(i,j))))
					rawResult(i,j) = s(i,j);
				end
			end
		end
	end
	% trim all-empty-string leading rows from raw array
	while size(rawResult,1)>1 && all(cellfun('isempty',rawResult(1,:)))
		rawResult = rawResult(2:end,:);
	end
	% trim all-empty-string leading columns from raw array
	while size(rawResult,2)>1 && all(cellfun('isempty',rawResult(:,1)))
		rawResult = rawResult(:,2:end);
	end
	% replace empty raw data with NaN, to comply with specification
	rawResult(cellfun('isempty',rawResult))={NaN};
end	

%--------------------------------------------------------------------------
function [numericArray,textArray] = trim_arrays(numericArray,textArray)
% trim leading rows or cols
% if the string result has dimensions corresponding to a column or row of
% zeros in the matrix result, trim the zeros.
if ~isempty(numericArray) && ~isempty(textArray)
    [mn, nn] = size(numericArray);
    [ms, ns] = size(textArray);

    if ms == mn
        % trim leading column(textArray) from numeric data
        firstcolm = 1;
        while (firstcolm<=nn && all(isnan(numericArray(:,firstcolm))))
            firstcolm = firstcolm+1;
        end
        numericArray=numericArray(:,firstcolm:end);
    end

    if ns == nn
        % trim leading NaN row(s) from numeric data
        firstrow = 1;
        while (firstrow<=mn && all(isnan(numericArray(firstrow,:))))
            firstrow = firstrow+1;
        end
        numericArray=numericArray(firstrow:end,:);
        
        % trim leading empty rows(s) from text data
        firstrow = 1;
        while (firstrow<=ms && all(cellfun('isempty',textArray(firstrow,:))))
            firstrow = firstrow+1;
        end
        textArray=textArray(firstrow:end,:);
    end
    
    % trim all-empty-string trailing rows from text array
	lastrow = size(textArray,1);
    while (lastrow>0 && all(cellfun('isempty',textArray(lastrow,:))))
        lastrow = lastrow-1;
    end
	textArray=textArray(1:lastrow,:);
    
    % trim all-empty-string trailing columns from text array
	lastcolm = size(textArray,2);
    while (lastcolm>0 && all(cellfun('isempty',textArray(:,lastcolm))))
        lastcolm = lastcolm-1;
    end
	textArray=textArray(:,1:lastcolm);

    % trim all-NaN trailing rows from numeric array
	lastrow = size(numericArray,1);
    while (lastrow>0 && all(isnan(numericArray(lastrow,:))))
        lastrow=lastrow-1;
    end
	numericArray=numericArray(1:lastrow,:);
    
    % trim all-NaN trailing columns from numeric array
	lastcolm = size(numericArray,2);
    while (lastcolm>0 && all(isnan(numericArray(:,lastcolm))))
        lastcolm=lastcolm-1;
    end
	numericArray=numericArray(:,1:lastcolm);
end
