classdef ImageEnhancer
% IMAGEENHANCER  Simple OOP manager for image filtering by 3x3 kernels.
%   obj = ImageEnhancer(imageInput)
%   imageInput can be:
%       - a string path to an image file, OR
%       - an HxWx3 numeric image matrix (uint8/double)
%
%   Methods:
%     processChannel(channelChar, kernelNameOrMatrix)
%     processRGB(kernelNameOrMatrix)
%     getKernelNames()

    properties
        imagePath      % string path (optional)
        imageRGB       % HxWx3 uint8 matrix
        paddingMode    % 'zero', 'replicate', or 'reflect'
        kernels        % struct of named kernels (3x3 matrices)
    end

    methods
        function obj = ImageEnhancer(imageInput)
            % Constructor: accept either filename or image matrix
            if nargin == 0
                error('Provide an image file path or an image matrix.');
            end

            % Initialize kernels and default padding
            obj.kernels = obj.defineKernels();
            obj.paddingMode = 'reflect'; % default

            if ischar(imageInput) || isstring(imageInput)
                imagePath = char(imageInput);
                if ~isfile(imagePath)
                    error('Image file not found: %s', imagePath);
                end
                img = imread(imagePath);
                obj.imagePath = imagePath;
            elseif isnumeric(imageInput)
                img = imageInput;
                obj.imagePath = '';
            else
                error('imageInput must be a filename (string) or an image matrix.');
            end

            % Normalize to HxWx3 uint8
            if ndims(img) == 2
                % grayscale -> duplicate to RGB
                img = cat(3, img, img, img);
            end

            if size(img,3) ~= 3
                error('Unsupported image format. Expect 3-channel RGB or single-channel grayscale.');
            end

            % Convert to uint8 if needed
            if ~isa(img, 'uint8')
                % If double and in [0,1], scale to [0,255]
                if isfloat(img) && max(img(:)) <= 1 && min(img(:)) >= 0
                    img = uint8(round(img * 255));
                else
                    img = uint8(round(img));
                end
            end

            obj.imageRGB = img;
        end

        function names = getKernelNames(obj)
            names = fieldnames(obj.kernels);
        end

        function k = getKernelByName(obj, nameOrMatrix)
            if ischar(nameOrMatrix) || isstring(nameOrMatrix)
                name = char(nameOrMatrix);
                name = strrep(name, ' ', ''); % remove spaces
                if isfield(obj.kernels, name)
                    k = obj.kernels.(name);
                else
                    error('Unknown kernel name: %s', name);
                end
            elseif isnumeric(nameOrMatrix) && isequal(size(nameOrMatrix), [3 3])
                k = double(nameOrMatrix);
            else
                error('Provide either a kernel name or a 3x3 numeric matrix.');
            end
        end

        function outChannel = processChannel(obj, channelChar, kernelNameOrMatrix)
            % Process a single channel ('R','G','B') with given kernel
            if nargin < 3
                error('Usage: processChannel(channelChar, kernelNameOrMatrix)');
            end
            channelChar = upper(channelChar);
            valid = {'R','G','B'};
            if ~ismember(channelChar, valid)
                error('Channel must be ''R'', ''G'', or ''B''.');
            end

            kernel = obj.getKernelByName(kernelNameOrMatrix);

            % Extract channel matrix
            switch channelChar
                case 'R'
                    ch = obj.imageRGB(:,:,1);
                case 'G'
                    ch = obj.imageRGB(:,:,2);
                case 'B'
                    ch = obj.imageRGB(:,:,3);
            end

            % Run manual convolution
            convResult = conv2d_manual(ch, kernel, obj.paddingMode);

            % Clip results to valid display range [0,255]
            convResult = round(convResult); % round to nearest
            convResult(convResult < 0) = 0;
            convResult(convResult > 255) = 255;

            outChannel = uint8(convResult);
        end

        function outRGB = processRGB(obj, kernelNameOrMatrix)
            % Process each channel independently and recombine into an RGB image.
            kernel = obj.getKernelByName(kernelNameOrMatrix);

            % Create three independent instances from the same in-memory image
            enhancerR = ImageEnhancer(obj.imageRGB);
            enhancerR.paddingMode = obj.paddingMode;
            outR = enhancerR.processChannel('R', kernel);

            enhancerG = ImageEnhancer(obj.imageRGB);
            enhancerG.paddingMode = obj.paddingMode;
            outG = enhancerG.processChannel('G', kernel);

            enhancerB = ImageEnhancer(obj.imageRGB);
            enhancerB.paddingMode = obj.paddingMode;
            outB = enhancerB.processChannel('B', kernel);

            % Combine
            outRGB = cat(3, outR, outG, outB);
        end

        function showGrayscaleDemo(obj, kernelNameOrMatrix)
            kernel = obj.getKernelByName(kernelNameOrMatrix);

            gray = rgb2gray(obj.imageRGB);
            filtered = conv2d_manual(gray, kernel, obj.paddingMode);

            % Normalize for display: clip and cast
            filtered = round(filtered);
            filtered(filtered < 0) = 0;
            filtered(filtered > 255) = 255;

            figure('Name','Grayscale Filter Demo');
            subplot(1,2,1);
            imshow(gray);
            title('Original (grayscale)');

            subplot(1,2,2);
            imshow(uint8(filtered));
            if ischar(kernelNameOrMatrix) || isstring(kernelNameOrMatrix)
                t = char(kernelNameOrMatrix);
            else
                t = 'Custom Kernel';
            end
            title(['Filtered (' t ')']);
        end

        function showRGBDemo(obj, kernelNameOrMatrix)
            outRGB = obj.processRGB(kernelNameOrMatrix);
            figure('Name','RGB Filter Demo');
            subplot(1,2,1);
            imshow(obj.imageRGB);
            title('Original RGB');

            subplot(1,2,2);
            imshow(outRGB);
            if ischar(kernelNameOrMatrix) || isstring(kernelNameOrMatrix)
                t = char(kernelNameOrMatrix);
            else
                t = 'Custom Kernel';
            end
            title(['Processed RGB (' t ')']);
        end
    end

    methods (Static, Access = private)
        function kStruct = defineKernels()
            % DEFINEKERNELS returns a struct of named 3x3 kernels.
            kStruct.Identity = [0 0 0; 0 1 0; 0 0 0];

            kStruct.Box = (1/9) * [1 1 1; 1 1 1; 1 1 1];

            kStruct.Sharpen = [0 -1 0; -1 5 -1; 0 -1 0];

            kStruct.Gaussian = (1/16) * [1 2 1; 2 4 2; 1 2 1];

            % Sobel Vertical (detects vertical edges)
            kStruct.SobelV = [1 0 -1; 2 0 -2; 1 0 -1];

            % Sobel Horizontal
            kStruct.SobelH = kStruct.SobelV.';

            % Laplacian (edge detection)
            kStruct.Laplacian = [0 -1 0; -1 4 -1; 0 -1 0];

            % Emboss (visual effect)
            kStruct.Emboss = [-2 -1 0; -1 1 1; 0 1 2];
        end
    end
end
