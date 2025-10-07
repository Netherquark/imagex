function mainUI()
% MAINUI  Simple GUI to upload an image, pick a kernel and apply filter.
% Run by typing mainUI in the MATLAB command window.

    % Create window
    fig = uifigure('Name', 'Digital Image Enhancement Demonstrator', ...
                   'Position', [300 200 520 420]);

    % Upload button and label
    uilabel(fig, 'Position', [20 360 100 20], 'Text', 'Upload Image:');
    btnUpload = uibutton(fig, 'push', 'Position', [120 355 100 30], ...
        'Text', 'Browse...', 'ButtonPushedFcn', @(~,~)onUpload());

    % Kernel selection
    uilabel(fig, 'Position', [20 310 120 20], 'Text', 'Select Kernel:');
    % Create a temporary enhancer to get kernel names for dropdown
    tmpEnh = ImageEnhancer(getSampleImage());
    kernelNames = tmpEnh.getKernelNames();
    ddKernel = uidropdown(fig, 'Items', kernelNames, 'Value', kernelNames{3}, ...
        'Position', [120 305 140 30]);

    % Mode selection: single-channel or RGB
    uilabel(fig, 'Position', [20 260 120 20], 'Text', 'Mode:');
    ddMode = uidropdown(fig, 'Items', {'RGB (all channels)', 'Single Channel'}, ...
        'Position', [120 255 140 30], 'Value', 'RGB (all channels)', ...
        'ValueChangedFcn', @(dd,event) onModeChange(dd));

    % Channel dropdown (hidden by default)
    lblChannel = uilabel(fig, 'Position', [280 260 70 20], 'Text', 'Channel:', 'Visible','off');
    ddChannel = uidropdown(fig, 'Items', {'R','G','B'}, 'Position', [350 255 60 30], 'Visible','off');

    % Padding selection
    uilabel(fig, 'Position', [20 210 120 20], 'Text', 'Padding Mode:');
    ddPad = uidropdown(fig, 'Items', {'reflect','replicate','zero'}, 'Position', [120 205 140 30], 'Value','reflect');

    % Apply button
    btnApply = uibutton(fig, 'push', 'Position', [120 150 140 35], ...
        'Text', 'Apply Filter', 'ButtonPushedFcn', @(~,~)onApply());

    % Status label
    lblStatus = uilabel(fig, 'Position', [20 100 480 30], 'Text', 'No image loaded.', 'HorizontalAlignment','left');

    % Stored image path
    uploadedPath = '';

    % --- Nested functions ---
    function onUpload()
        [file, path] = uigetfile({'*.jpg;*.png;*.jpeg;*.bmp','Image Files (*.jpg,*.png,*.bmp)'}, 'Select an Image');
        if isequal(file, 0)
            uialert(fig, 'No image selected.', 'Upload cancelled');
            return;
        end
        uploadedPath = fullfile(path, file);
        lblStatus.Text = ['Loaded: ' file];
    end

    function onModeChange(dd)
        if strcmp(dd.Value, 'Single Channel')
            lblChannel.Visible = 'on';
            ddChannel.Visible = 'on';
        else
            lblChannel.Visible = 'off';
            ddChannel.Visible = 'off';
        end
    end

    function onApply()
        if isempty(uploadedPath)
            uialert(fig, 'Please upload an image first.', 'No Image');
            return;
        end

        % Create enhancer
        try
            enhancer = ImageEnhancer(uploadedPath);
        catch ME
            uialert(fig, ['Error reading image: ' ME.message], 'Error');
            return;
        end

        % Set padding
        enhancer.paddingMode = ddPad.Value;

        % Get kernel
        kernelChoice = ddKernel.Value;

        % Apply according to mode
        if strcmp(ddMode.Value, 'RGB (all channels)')
            outRGB = enhancer.processRGB(kernelChoice);
            enhancer.showRGBDemo(kernelChoice); % separate figure for visualization
            lblStatus.Text = 'Applied kernel to all R,G,B channels and displayed result.';
        else
            ch = ddChannel.Value;
            outCh = enhancer.processChannel(ch, kernelChoice);
            % Show original and filtered side-by-side
            figure('Name','Single Channel Result');
            subplot(1,2,1);
            switch ch
                case 'R'; imshow(enhancer.imageRGB(:,:,1)); title('Original R channel');
                case 'G'; imshow(enhancer.imageRGB(:,:,2)); title('Original G channel');
                case 'B'; imshow(enhancer.imageRGB(:,:,3)); title('Original B channel');
            end
            subplot(1,2,2);
            imshow(outCh); title(['Filtered ' ch ' channel (' kernelChoice ')']);
            lblStatus.Text = sprintf('Applied kernel to channel %s and displayed result.', ch);
        end
    end

    function imgFile = getSampleImage()
        % helper to return a sample image path present on most MATLAB installs
        if isfile('peppers.png')
            imgFile = 'peppers.png';
        else
            % fallback to creating a small gray image on temp file
            tmp = uint8(ones(100,100,3) * 128);
            tmpName = fullfile(tempdir, 'tmp_sample_image.png');
            imwrite(tmp, tmpName);
            imgFile = tmpName;
        end
    end

end

