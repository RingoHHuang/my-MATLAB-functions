function [Y,Ty] = resample_with_nans(X,Tx,Fs,varargin)
%Convenience function of resample (Signal Processing Toolbox) that
%preserves NaNs (instead of interpolating over them). Also automatically
%adds padding to the start and end of the timeseries to avoid edge
%artifacts. In contrast, original assumes the adjacent samples are 0.
%
% This function is based on this implementation of resample:
%
%     [Y,Ty] = resample(X,Tx,Fs) uses interpolation and an anti-aliasing
%     filter to resample the signal at a uniform sample rate, Fs, expressed
%     in hertz (Hz)
%
% Author: Ringo Huang
% Date Created: 11/29/2020

%% Handle arguments
narginchk(3,4);         % 3 or 4 input arguments
nargoutchk(2,2);        % 2 output arguments

% Handle pad_length
if nargin == 4
    if isnumeric(varargin{1})
        pad_length = varargin{1};
    else
        error('pad_length must be a double');
    end
elseif nargin == 3
    pad_length = 20;    % default
end

%% Check for common issues
if sum(size(X) == size(Tx)) ~= 2
    error('Size of X and Tx must be the same');
end

%% Handle 1xN vectors
transpose_flag = 0;     % flag for transposing Y and Ty output if needed
if size(X, 2) == 1
    transpose_flag = 1;
    X=X';               % transpose
    Tx=Tx';
end

%% Add front and rear padding
X = [repmat(X(1),1,pad_length), X, repmat(X(end),1,pad_length)];
Tx = [Tx(1)-pad_length/Fs:1/Fs:Tx(1)-1/Fs, Tx, Tx(end)+1/Fs:1/Fs:Tx(end)+pad_length/Fs];

%% Find NaN timestamp ranges
nan_la = isnan(X);
nan_la_diff = [nan_la 0] - [0 nan_la];  % Why append with 0? If X(1) == NaN, then nan_la_diff(1) == 1 (i.e., nan_la_diff tells you X(1) is the start of a NaN sequence)
nan_start_ts_la = nan_la_diff == 1;     % Why use [1:end-1]? start ts corresponds to the sample WHEN nan_la_diff == 1
nan_end_ts_la = nan_la_diff == -1;      % Why use [1:end-1]? end ts corresponds to the sample WHEN nan_la_diff == -1; this would be the start of the first valid sample;

Tx_start = [Tx(1)-1/Fs, Tx];            % Shift Tx forward, such that nan_start_ts_la == 1 corresponds to Tx_start of NaN sequence
Tx_end = [Tx, Tx(end) + 1/Fs];          % Shift Tx backward, such that nan_end_ts_la == 1 corresponds to Tx_end of NaN sequence

nan_start_ts = Tx_start(nan_start_ts_la);   % Vector of timestamps corresponding to start of NaN sequence
nan_end_ts = Tx_end(nan_end_ts_la);             % Vecotr of timestamps corresponding to end of NaN sequence

% Don't think this is necessary:
%X = fillmissing(X, 'nearest');              % Replace NaNs in X with nearest neighbor; this avoids weird interpolation behavior at the start and end

%% Resample and Refill with NaNs
[Y, Ty] = resample(X, Tx, Fs);

% Replace with NaNs
tolerance = 1/(4*Fs);   % set tolerance as half of sampling interval; i.e., to catch for rounding approximations at the start and end of the nan sequence
for i=1:numel(nan_start_ts)
    nan_refill_la = Ty > nan_start_ts(i) + tolerance & Ty < nan_end_ts(i) - tolerance;
    Y(nan_refill_la) = NaN;
end

% Trim padding
Y = Y(pad_length+1:end-pad_length);
Ty = Ty(pad_length+1:end-pad_length);

%% Transpose (if needed)
if transpose_flag == 1
    Y=Y';
    Ty=Ty';
end
end