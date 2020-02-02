function [ DataArray , OutputHeaders , DataName ] = XPSFileSelector ( )

%% Opens user interface to select XPS peak report files generated by CasaXPS to import for analysis.
% Could also be used to import any multi-column set of spectra .txt data.

[ FileGroup , DataPath ] = uigetfile ( '*.txt' , 'DialogTitle' , 'Select XPS .txt files' , 'MultiSelect' , 'on' ) ; % Gets file names and location.
DataName = FileGroup { 1 } ;
DataName ( end - 7 : end ) = [] ;

SingleFile = double ( ischar ( FileGroup ) ) ; % Used to account for the case where only a single file is selected.

if  SingleFile > 0

    NFC = 1 ;
    
else
    
    NFC = length ( FileGroup ) ;  % Number of files to import.
    
end

FileSet = repmat ( { '' } , 1 , NFC ) ; % Generates cell array to place filenames into.

cd ( DataPath ) ; % Sets target directory to current folder.


%% Generates array of files for analysis.

for i = 1 : NFC
    
    if SingleFile > 0
            
        FileSet ( i ) = cellstr ( strcat ( DataPath , FileGroup ) ) ; % Concatenates path and file strings and adds to output array,
    
    else
        
        FileSet ( i ) = strcat ( DataPath , FileGroup ( i ) ) ; % Concatenates path and file strings and adds to output array,
    
    end
    
end


%% Uses column headers so user can choose which data to extract and process.

Delimiter = '\t' ; % Could be specified in textscan to avoid variable creation.
NFile = fopen ( char ( FileSet ( : , 1 ) ) , 'r' ) ; % Chosen file to determine number of columns, set to 1 to use first specified file.
StartRow = 4 ; % First row of data. Might need to be changed for different file types/sources.

for i = 1 : StartRow - 1
    
    Headers = fgetl ( NFile ) ;
  
end

Headers = textscan ( Headers , '%s' , 'Delimiter' , Delimiter ) ;
NF = numel ( Headers { 1 } ) ;
[ DataChoices ] = listdlg ( 'ListString' , Headers { 1 } ) ;
N = length ( DataChoices ) ; % Specifies number of columns of data.
FormatSpec = repmat ( '%n' , 1 , NF ) ; % Specifies import format;
DataArray = repmat ( { '' } , 1 , N , NFC ) ; % Generates cell array to place data into.
OutputHeaders = repmat ( { '' } , 1 , N ) ;

%% Opens, reads and closes data files.

for i = 1 : NFC

    % Chooses file.
    FileChoice = char ( FileSet ( : , i ) ) ;

    FileID = fopen ( FileChoice , 'r' ) ;
    FileArray = textscan ( FileID , FormatSpec , 'Delimiter' , Delimiter , 'EmptyValue' , NaN , 'HeaderLines' , StartRow - 1 , 'ReturnOnError' , false ) ;
    fclose ( FileID ) ;
    
    for k = 1 : N
        
        % Places array data into pre-defined recipient array.
        DataArray { 1 , k , i } = FileArray { DataChoices ( k ) } ;
        OutputHeaders{ k } = char ( Headers { 1 } ( DataChoices ( k ) ) ) ;
        
    end

end