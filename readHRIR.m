%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% IE7-CJ2 WS2023 - Design, Implementation and Evaluation of an Auditory Virtual Environment
% Team 2 - J. Harms, T. Warnakulasooriya, L.Gildenstern, J. Smith
% 
% -------------------------------------------------------------------------------------
%  Module: readHRIR.m
%
%   This module reads the whole HRIR set (provided by MIT) and stores them
%   in a cell matrix. SET{a}{b}, where a is the index separating the
%   folders and b the index for the files inside these folders. a seperates
%   different elevation levels while b separates azimuth angles.
% 
%  Version      Date                Author                  Comment
% -------------------------------------------------------------------------
%   1.0             16.10.23    J.Smith                      initial version  
%   1.1             04.11.23    J.Smith                      comments added, variable names fixed
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [hrir_set] = readHRIR(path)

folder_paths =  fullfile(path, "*");

% Read in the folder structure (elevation levels) and create (allocate) cells for every
% folder
folders = dir(folder_paths);
folders = folders([folders.isdir]);         
folders = folders(~ismember({folders.name}, {'.', '..'}));
hrir_set = cell(length(folders), 1);

% For every folder in the first cell (dimension) read in the file structure
% inside these folders Only store the paths to files with dat extension
for folder_index = 1:length(folders)
    current_folder = fullfile(path, folders(folder_index).name);

    file_paths = fullfile(current_folder, "*.dat");
    files = dir(file_paths);
    
    % For every folder cell, create/allocate the "subcells"/secondary cells
    % The amount of cells for every folder depends on the number of files
    % in that folder
    folderDataCell = cell(1, length(files)); 
    
    % Read in the data. The impulse responses are represented by signed 16
    % bit integers
    for file_index = 1:length(files)
        fullpath = fullfile(current_folder, files(file_index).name);
        file_descriptor = fopen(fullpath, "rb", 'l');
        hrir_data = fread(file_descriptor, Inf, "int16");
        fclose(file_descriptor);
        folderDataCell{file_index} = hrir_data';     
    end
    hrir_set{folder_index} = folderDataCell;
end
end

