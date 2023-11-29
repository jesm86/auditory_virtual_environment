function rowData = refPlanePointExtrct(data, nameToFind)
    % Find the index of the row with the specified name
    rowIndex = find(strcmp(data(:, 2), nameToFind));

    % Check if the name was found
    if ~isempty(rowIndex)
        % Extract the row associated with the specified name
        rowData = data{rowIndex, 1};
        % disp(['Data for ', nameToFind, ':']);
        % disp(rowData);
    else
        % disp(['Name "', nameToFind, '" not found.']);
        rowData = [];
    end
end
