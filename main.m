% main.m
% Demonstration of ImageEnhancer class

clc; clear; close all;

% Define a 3x3 kernel (example: sharpening)
kernel = [0 -1 0; -1 5 -1; 0 -1 0];

% Create an ImageEnhancer object for a chosen channel
enhancer = ImageEnhancer('peppers.png', kernel, 'G');

% Apply convolution
filteredImage = enhancer.applyConvolution();

% Visualize results
enhancer.visualize(filteredImage);
