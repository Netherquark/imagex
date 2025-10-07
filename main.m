% MAIN Demonstration script for ImageEnhancer
% Place this script in the same folder as the other files, then run.

clc; clear; close all;

% Example image included with MATLAB (if not available, replace path)
exampleImage = 'peppers.png';
if ~isfile(exampleImage)
    error('Example image %s not found. Put an RGB image named peppers.png in this folder or change exampleImage.', exampleImage);
end

% Create enhancer
enhancer = ImageEnhancer(exampleImage);

% Print available kernels
disp('Available kernels:');
disp(enhancer.getKernelNames());

% 1) Grayscale demo: show original + 5 standard filters in a 2x3 tiled figure
kernelNames = {'Identity','Box','Gaussian','Sharpen','SobelV','SobelH'};
figure('Name','Grayscale Filters Comparison','Units','normalized','Position',[0.1 0.1 0.8 0.6]);
tiledlayout(2,3, 'Padding','compact', 'TileSpacing','compact');

grayImg = rgb2gray(enhancer.imageRGB);
for k = 1:numel(kernelNames)
    nexttile;
    kernelName = kernelNames{k};
    kernel = enhancer.getKernelByName(kernelName);
    filtered = conv2d_manual(grayImg, kernel, enhancer.paddingMode);
    filtered = round(filtered);
    filtered(filtered < 0) = 0;
    filtered(filtered > 255) = 255;
    imshow(uint8(filtered));
    title(kernelName);
end
% Also show original grayscale in an extra figure (or replace one tile)
figure('Name','Original Grayscale');
imshow(grayImg);
title('Original Grayscale');

% 2) RGB demo: apply a filter to each channel (three instantiations) and show
selectedKernel = 'Sharpen';
enhancer.paddingMode = 'reflect'; % ensure default
outRGB = enhancer.processRGB(selectedKernel);

figure('Name','RGB Processing Demo');
subplot(1,2,1);
imshow(enhancer.imageRGB);
title('Original RGB');
subplot(1,2,2);
imshow(outRGB);
title(['Processed RGB (' selectedKernel ')']);

% Optional: save demo figures to PDF files
disp('Saving demo figures as PDF...');
try
    saveas(gcf, 'RGB_Demo.pdf');
    % Save the grayscale figure too (if desired)
catch
    warning('Could not save PDF files (permissions or environment issue).');
end

disp('Done. Use mainUI() to run the interactive GUI.');
