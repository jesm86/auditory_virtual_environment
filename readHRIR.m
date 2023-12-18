function [hrir_set] = readHRIR(path)
%READHRIR Summary of this function goes here
%   Detailed explanation goes here

folder_paths =  fullfile(path, "*");

folders = dir(folder_paths);
folders = folders([folders.isdir]);         % Remove items, that arent folders
folders = folders(~ismember({folders.name}, {'.', '..'}));
hrir_set = cell(length(folders), 1);

for folder_index = 1:length(folders)
    current_folder = fullfile(path, folders(folder_index).name);

    file_paths = fullfile(current_folder, "*.dat");
    files = dir(file_paths);

    folderDataCell = cell(1, length(files)); % Initialize empty cell array
    
    for file_index = 1:length(files)
        fullpath = fullfile(current_folder, files(file_index).name);
        file_descriptor = fopen(fullpath, "rb", 'l'); % Little endian
        hrir_data = fread(file_descriptor, Inf, "int16");
        fclose(file_descriptor);
        folderDataCell{file_index} = hrir_data';      % Preallocation for speed. But how to know size before reading in all files?
    end
    hrir_set{folder_index} = folderDataCell;
end
end

