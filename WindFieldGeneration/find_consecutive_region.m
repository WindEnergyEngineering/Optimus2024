function startIndex = find_consecutive_region(indexArray, consecutiveCount)
    % Initialize variables
    startIndex = []; % This will store the starting index of the first sequence found
    
    % Loop through the index array to find consecutive numbers
    for i = 1:length(indexArray) - consecutiveCount + 1
        % Check if the subarray from i to i + consecutiveCount - 1 is consecutive
        if all(diff(indexArray(i:i + consecutiveCount - 1)) == 1)
            startIndex = indexArray(i); % Store the start value of this region
            return; % Stop after finding the first region
        end
    end
    
    % If no consecutive region is found
    if isempty(startIndex)
        disp('No region with the specified number of consecutive values was found.');
    end
end
