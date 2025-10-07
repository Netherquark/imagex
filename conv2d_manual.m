function output = conv2d_manual(inputImage, kernel, paddingMode)
% CONV2D_MANUAL  2-D convolution implemented with nested loops (no conv2).
%   output = conv2d_manual(inputImage, kernel, paddingMode)
%
%   - inputImage: 2D numeric matrix (grayscale channel). Can be uint8/double.
%   - kernel: 3x3 numeric matrix (use normalized kernel if needed).
%   - paddingMode: 'zero' (default), 'replicate', or 'reflect' (symmetric).
%
%   Returns 'output' as double (same size as inputImage). Caller should
%   handle clipping/casting to uint8 if desired.

    if nargin < 3 || isempty(paddingMode)
        paddingMode = 'reflect';
    end

    % Validate kernel
    if ~isnumeric(kernel) || ~isequal(size(kernel), [3 3])
        error('Kernel must be a numeric 3x3 matrix.');
    end

    % Convert input to double for computation
    in = double(inputImage);
    [h, w] = size(in);

    pad = 1; % for 3x3 kernel
    paddedH = h + 2*pad;
    paddedW = w + 2*pad;

    % Prepare padded matrix
    padded = zeros(paddedH, paddedW);

    % Place interior
    padded(pad+1:pad+h, pad+1:pad+w) = in;

    switch lower(paddingMode)
        case 'zero'
            % already zero-padded
        case 'replicate'
            % replicate edges
            % top and bottom rows
            padded(1, pad+1:pad+w) = in(1, :);
            padded(end, pad+1:pad+w) = in(end, :);
            % left and right columns
            padded(pad+1:pad+h, 1) = in(:, 1);
            padded(pad+1:pad+h, end) = in(:, end);
            % corners
            padded(1,1) = in(1,1);
            padded(1,end) = in(1,end);
            padded(end,1) = in(end,1);
            padded(end,end) = in(end,end);

            % handle degenerate small dimensions (h==1 or w==1)
            if h == 1
                % only one row - replicate that row to top and bottom
                padded(1, pad+1:pad+w) = in(1,:);
                padded(end, pad+1:pad+w) = in(1,:);
                padded(pad+1:pad+h, 1) = in(:,1);
                padded(pad+1:pad+h, end) = in(:,end);
            end
            if w == 1
                padded(pad+1:pad+h, 1) = in(:,1);
                padded(pad+1:pad+h, end) = in(:,1);
                padded(1, pad+1:pad+w) = in(1,:);
                padded(end, pad+1:pad+w) = in(end,:);
            end

        case {'reflect','symmetric'}
            % reflect (mirror) edges across the border
            % For a single-pad with 3x3 kernel:
            % top row of padded = second row of 'in' (if exists), else first row
            if h >= 2
                padded(1, pad+1:pad+w) = in(2, :);        % top
                padded(end, pad+1:pad+w) = in(end-1, :);  % bottom
            else
                % fallback: replicate if only one row
                padded(1, pad+1:pad+w) = in(1, :);
                padded(end, pad+1:pad+w) = in(1, :);
            end

            if w >= 2
                padded(pad+1:pad+h, 1) = in(:, 2);        % left
                padded(pad+1:pad+h, end) = in(:, end-1);  % right
            else
                padded(pad+1:pad+h, 1) = in(:, 1);
                padded(pad+1:pad+h, end) = in(:, 1);
            end

            % corners
            if h >= 2 && w >= 2
                padded(1,1) = in(2,2);
                padded(1,end) = in(2,end-1);
                padded(end,1) = in(end-1,2);
                padded(end,end) = in(end-1,end-1);
            else
                % fallback to replicate corners
                padded(1,1) = in(1,1);
                padded(1,end) = in(1,end);
                padded(end,1) = in(end,1);
                padded(end,end) = in(end,end);
            end

        otherwise
            error('Unsupported padding mode. Use ''zero'', ''replicate'', or ''reflect''.');
    end

    % Flip kernel for convolution (mathematical definition)
    kf = rot90(kernel, 2);

    % Preallocate output
    output = zeros(h, w);

    % Manual nested loop convolution (3x3)
    for row = 1:h
        for col = 1:w
            window = padded(row:row+2*pad, col:col+2*pad); % 3x3 window
            % Element-wise multiply and sum (unrolled sum for slight speed in plain MATLAB)
            value = window .* kf;
            s = value(1,1) + value(1,2) + value(1,3) + ...
                value(2,1) + value(2,2) + value(2,3) + ...
                value(3,1) + value(3,2) + value(3,3);
            output(row, col) = s;
        end
    end
end
