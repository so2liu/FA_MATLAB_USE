function y = iqimbal(x, ampimb, varargin)
%IQIMBAL Apply an I/Q amplitude and phase imbalance to an input signal.
%   Y = IQIMBAL(X,A) applies an I/Q amplitude imbalance to real or complex
%   input signal X, which is a column vector or matrix. If X is a matrix,
%   the number of columns corresponds to the number of channels. A is the
%   amplitude imbalance in dB and must be a scalar or a row vector having
%   the same number of columns as X. Y is the impaired output signal having
%   the same dimensions as X.
%
%   Y = IQIMBAL(X,A,P) specifies the phase imbalance, P, in degrees and
%   must be a scalar or a row vector having the same number of columns as
%   X.
%
%   % EXAMPLE 1:
%   % Apply an I/Q imbalance of 3 dB and 10 degrees to a 16-QAM signal.
%   x = qammod(randi([0 15],100,1),16);
%   y = iqimbal(x,3,10);
%   scatterplot(y)
%   grid
%
%   % EXAMPLE 2:
%   % Apply a 1 dB, 5 degree I/Q imbalance to a QPSK signal. Then apply a
%   % 0.5 + 0.3i DC offset. Visualize the offset using a spectrum analyzer.
%   x = pskmod(randi([0 3],1e4,1),4,pi/4);
%   y = iqimbal(x,1,5);
%   z = y + complex(0.5,0.3);
%
%   spectAnal = dsp.SpectrumAnalyzer('SampleRate',1000,'YLimits',[-50 30]);
%   spectAnal(z)
%
%   See also IQCOEF2IMBAL, IQIMBAL2COEF, comm.IQImbalanceCompensator.

%   Copyright 2016 The MathWorks, Inc.

%#codegen

% Validate number of arguments
narginchk(2,3)

% If phase imbalance is not specified, set it to zero
if nargin == 2    
    phimb = 0;
else
    phimb = varargin{1};
end

% Validate attributes
validateattributes(x,{'double','single'}, ...
    {'2d','nonnan','finite','nonempty'}, 'iqimbal', 'InputSignal');
validateattributes(ampimb, {'double','single'}, {'real', ...
    'nonnan', 'finite', 'nonempty'}, 'iqimbal', 'AmpImbalanceDB');

if nargin == 3
    validateattributes(phimb, {'double','single'}, {'real', ...
        'nonnan', 'finite', 'nonempty'}, 'iqimbal', 'PhaseImbalanceDeg');
end

% Check for dimension mismatch: Number of columns in x should equal the
% number of columns in ampimb or phimb.
if (size(x,2) ~= size(ampimb,2) && numel(ampimb) > 1)
    error(message('comm:iqimbal:ampimbDims'));
end

if (size(x,2) ~= size(phimb,2) && numel(phimb) > 1)
    error(message('comm:iqimbal:phimbDims'));
end


% Cast amplitude and phase imbalance to have same data type as input signal
A = cast(ampimb,'like',x);
P = cast(phimb,'like',x);

% Apply I/Q amplitude and phase imbalance in to input signal
gainI = 10.^(0.5*A/20).*exp(-0.5i*P*pi/180);
gainQ = 10.^(-0.5*A/20).*exp(0.5i*P*pi/180)*1i;
imbI = bsxfun(@times,real(x),gainI);
imbQ = bsxfun(@times,imag(x),gainQ);
y = imbI + imbQ;

% EOF