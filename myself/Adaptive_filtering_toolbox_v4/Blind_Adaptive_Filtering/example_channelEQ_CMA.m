%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        Example: Channel Equalization                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                               %
%  In this example we have a typical channel equalization scenario. We want     %
% to estimate the transmitted sequence with 4-QAM symbols. In                   %
% order to accomplish this task we use an adaptive filter with N coefficients   %
% The procedure is:                                                             %
% 1)  Apply the originally transmitted signal distorted by the channel plus     %
%   environment noise as the input signal to an adaptive filter.                %
%   In this case, the transmitted signal is a random sequence with 4-QAM        %
%   symbols and unit variance. The channel is a multipath complex-valued        %
%   channel whose impulse response is h = [1.1+j*0.5, 0.1-j*0.3, -0.2-j*0.1]^T  %
%   In addition, the environment noise is AWGN with zero mean and               %
%   variance 10^(-2.5).                                                         %
% 2)  Choose an adaptive filtering algorithm to govern the rules of coefficient %
%   updating.                                                                   %
%                                                                               %
%     Adaptive Algorithm used here: CMA                                         %
%                                                                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear;
close all;

%   Definitions:
ensemble      = 1;                          % number of realizations within the ensemble
K             = 10000;                         % number of iterations
Ksim          = 400;                          % number of iterations used to simulate the resulting system
H             = [1.1 + j*0.5, 0.1-j*0.3, -0.2-j*0.1]; % Channel taps
sigma_x2      = 1;                            % transmitted-signal power
sigma_n2      = 10^(-2.5);                    % noise power
N             = 5;                            % number of coefficients of the adaptive filter
mu            = 0.001;                          % convergence factor (step)  (0 < mu < 1)
delay         = 0;                            % the desired signals are delayed versions of the pilot symbols
constellation = qammod(0:3, 4)/sqrt(2);       % symbols from 4-QAM constellation
HMatrix       = toeplitz([H(1) zeros(1,N-1)],[H zeros(1,N-1)]); % Toeplitz channel matrix


% Finding the Wiener Filter 
Rx       = sigma_x2*eye(N+length(H)-1);
Rn       = sigma_n2*eye(N);
Ry       = HMatrix*Rx*(HMatrix') + Rn;

RxDeltaY = [zeros(1,delay)  sigma_x2 ...
            zeros(1,N+length(H)-2-delay) ]...
           *(HMatrix');
Wiener  = (RxDeltaY*inv(Ry)).';


%   Initializing & Allocating memory:
W       = repmat(Wiener,[1,(K+1-delay),ensemble])+ (randn(N,(K+1-delay),ensemble)+j*randn(N,(K+1-delay),ensemble))/4; % coefficient vector for each iteration and realization;
%  W       = (randn(N,(K+1-delay),ensemble)+j*randn(N,(K+1-delay),ensemble))/4; % coefficient vector for each iteration and realization;
MSE     = zeros(K-delay,ensemble);                % MSE for each realization
% W(:,1,1)= [2.011934 + 1i*0.157299;...
% 0.281061 + 1i*0.324327;...
% -0.017917 + 1i*0.836021;...
% -0.391982 + 1i*1.144051;...
% -0.185579 - 1i*0.89806];
W(:,:,1)=ones(5,(K+1-delay));

%   Computing:

% Finding the adaptive filter 

for k=1:ensemble,

    n         = sqrt(sigma_n2)*wgn(1,K,0,'complex');
    s         = randsrc(1,K,constellation);
    x         = filter(H,1,s) + n;

    S   =   struct('step',mu,'filterOrderNo',(N-1),'initialCoefficients',W(:,1,k));

    [y,e,W(:,:,k)]  =   CMA(x(1+delay:end),S);

    MSE(:,k)    =   MSE(:,k)+(abs(e(:,1))).^2;

end


%   Averaging:
W_av = sum(W,3)/ensemble;
MSE_av = sum(MSE,2)/ensemble;


% Simulating the system                
% maybe here is sth. wrong. inputMatrix is a random 5 by 400 Matrix
% equalizerOutput is a 1 by 400 vector.
inputMatrix           = randsrc(N+length(H)-1, Ksim,...
                                constellation);
noiseMatrix           = sqrt(sigma_n2)*wgn(N,Ksim,0,'complex');
equalizerInputVector  = HMatrix*inputMatrix + noiseMatrix;
equalizerOutputVector = (W_av(:,end)')*equalizerInputVector;
equalizerOutputVector=equalizerOutputVector/mean(abs(equalizerOutputVector));
equalizerOutputVectorWiener = Wiener.'*equalizerInputVector;

% Presentation
close all;
thetaVector = -pi:0.1:pi;

figure;
subplot(2,2,2)
plot(cos(thetaVector),sin(thetaVector),'r-','LineWidth',1);
hold on;
plot(real(equalizerOutputVector),imag(equalizerOutputVector),'bx');
plot(real(constellation),imag(constellation),'ro',...
         'MarkerSize',10,'LineWidth',3);
hold off;
axis([-2 2 -2 2]);
grid on;
xlabel('in-phase');
ylabel('quadrature-phase');
title('equlizerOutputVector')

subplot(2,2,1)
plot(cos(thetaVector),sin(thetaVector),'r-','LineWidth',1);
hold on;
plot(real(equalizerInputVector),imag(equalizerInputVector),'bx');
plot(real(constellation),imag(constellation),'ro',...
         'MarkerSize',10,'LineWidth',3);
hold off;
axis([-2 2 -2 2]);
grid on;
xlabel('in-phase');
ylabel('quadrature-phase');
title('equlizerInputVector')

subplot(2,2,3)
plot(cos(thetaVector),sin(thetaVector),'r-','LineWidth',1);
hold on;
plot(real(equalizerOutputVectorWiener),imag(equalizerOutputVectorWiener),'bx');
plot(real(constellation),imag(constellation),'ro',...
         'MarkerSize',10,'LineWidth',3);
hold off;
axis([-2 2 -2 2]);
grid on;
xlabel('in-phase');
ylabel('quadrature-phase');
title('equlizerOutputVector-Wiener')

subplot(2,2,4)
semilogy(1:K-delay,abs(MSE_av),'-');
grid on;
