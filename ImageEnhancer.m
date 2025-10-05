classdef ImageEnhancer
    properties
        imagePath   % path to input image
        kernel      % 3x3 convolution kernel
        channel     % selected channel: 'R', 'G', or 'B'
        imageMatrix % single-channel image matrix (double)
    end

    methods
        % ---------- Constructor ----------
        function obj = ImageEnhancer(imagePath, kernel, channel)
            % Validate kernel
            if ~isequal(size(kernel), [3 3])
                error('Kernel must be a 3x3 matrix.');
            end
            obj.kernel = kernel;

            % Validate channel
            validChannels = {'R','G','B'};
            if ~ismember(upper(channel), validChannels)
                error('Channel must be one of: ''R'', ''G'', or ''B''.');
            end
            obj.channel = upper(channel);

            % Read image
            img = imread(imagePath);
            obj.imagePath = imagePath;

            % Ensure RGB format
            if size(img, 3) ~= 3
                warning('Grayscale image detected — duplicating channels.');
                img = cat(3, img, img, img);
            end

            % Extract chosen channel
            switch obj.channel
                case 'R'
                    channelData = img(:,:,1);
                case 'G'
                    channelData = img(:,:,2);
                case 'B'
                    channelData = img(:,:,3);
            end

            % Store as double
            obj.imageMatrix = double(channelData);
        end

        % ---------- Convolution Function ----------
        function output = applyConvolution(obj)
            % Apply 2D convolution to the chosen channel
            output = conv2(obj.imageMatrix, obj.kernel, 'same');

            % Normalize for display
            output = mat2gray(output);
        end

        % ---------- Visualization Function ----------
        function visualize(obj, filtered)
            % Display the original and filtered channel side by side
            figure;
            subplot(1,2,1);
            imshow(mat2gray(obj.imageMatrix));
            title(['Original ', obj.channel, ' Channel']);

            subplot(1,2,2);
            imshow(filtered);
            title(['Filtered ', obj.channel, ' Channel']);
        end
    end
end