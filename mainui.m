function mainUI()
    % Create a simple UI window
    fig = uifigure('Name', 'Digital Image Enhancement Demonstrator', ...
                   'Position', [300 200 500 400]);

    % --- Upload button ---
    uilabel(fig, 'Position', [30 340 150 20], 'Text', 'Upload Image:');
    btnUpload = uibutton(fig, 'push', 'Position', [150 335 100 30], ...
        'Text', 'Browse...', 'ButtonPushedFcn', @(~,~)uploadImage());

    % --- Channel selection ---
    uilabel(fig, 'Position', [30 290 150 20], 'Text', 'Select Channel:');
    ddChannel = uidropdown(fig, 'Items', {'R', 'G', 'B'}, ...
        'Position', [150 285 100 30]);

    % --- Kernel input field ---
    uilabel(fig, 'Position', [30 230 250 20], ...
        'Text', 'Enter 3x3 Kernel (comma-separated rows):');
    edtKernel = uieditfield(fig, 'text', ...
        'Position', [30 205 400 25], ...
        'Value', '0 -1 0, -1 5 -1, 0 -1 0');

    % --- Apply button ---
    btnApply = uibutton(fig, 'push', 'Position', [180 150 120 35], ...
        'Text', 'Apply Filter', 'ButtonPushedFcn', @(~,~)applyFilter());

    % --- Store uploaded image path ---
    imgPath = '';

    % Nested function: upload image
    function uploadImage()
        [file, path] = uigetfile({'*.jpg;*.png;*.jpeg;*.bmp'}, 'Select an Image');
        if isequal(file, 0)
            uialert(fig, 'No image selected.', 'Error');
            return;
        end
        imgPath = fullfile(path, file);
        uialert(fig, 'Image uploaded successfully!', 'Success');
    end

    % Nested function: apply filter
    function applyFilter()
        if isempty(imgPath)
            uialert(fig, 'Please upload an image first!', 'Missing Image');
            return;
        end

        % Parse kernel input
        try
            rows = split(edtKernel.Value, ',');
            kernel = cellfun(@(r) str2num(r), rows, 'UniformOutput', false);
            kernel = vertcat(kernel{:});
            if ~isequal(size(kernel), [3,3])
                error('Kernel must be 3x3');
            end
        catch
            uialert(fig, 'Invalid kernel format.', 'Error');
            return;
        end

        % Create object and apply filter
        enhancer = ImageEnhancer(imgPath, ddChannel.Value, kernel);
        outputImg = enhancer.applyConvolution();
        enhancer.visualize(outputImg);
    end
end
