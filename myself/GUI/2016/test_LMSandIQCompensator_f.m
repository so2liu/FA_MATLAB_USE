function [original,compSig,estCoef,EVM] = test_LMSandIQCompensator(state)

% state= struct('ISI',isi,'nISI',nisi,'IQ',iq,'nIQ',niq);

M = 4; % Alphabet size for modulation
hMod = comm.QPSKModulator;
trainlen = 200; % Length of training sequence

  
state
% load('C:\Users\st144690\Documents\MATLAB\myself\data\5GB_withoutfilter.mat','-mat','DemodType','Y');

%%
%test data, refData should be also changed!!! (s is test refData)
DemodType=4;
load('C:\Users\st144690\Documents\MATLAB\myself\GUI\2016\gen_data.mat');
Y=x.';
s=s.';
refData=s(1:end-state.nISI+1);
%%
original=double(Y);
compSig=original;
estCoef=0;

% refData=zeros(length(Y),1);
% for k=1:length(original)
%     refData(k)=sign(real(original(k)))+1j*sign(imag(original(k)));
% end
% refData=0.707*refData;
filtmsg=original;
modmsg=refData;

% measurements initial
 hEVM = comm.EVM('MaximumEVMOutputPort',true,...
            'XPercentileEVMOutputPort', true, 'XPercentileValue', 90,...
            'SymbolCountOutputPort', true); 
% Calculate measurements
[EVM_Original,~,~,~] = step(hEVM,s,double(Y))  %https://de.mathworks.com/help/comm/ref/evmmeasurement.html
release(hEVM);        
evm_rx=num2str(EVM_Original);
evm_flt=num2str(EVM_Original);

switch state.ISI
    case 'No Filter'
        compSig=original;
        estCoef=0;
    case 'LMS' %matlab 2016a doesn't support string!!!
        % Set up equalizer.
        eqlms = lineareq(state.nISI, lms(0.01)); % Create an equalizer object.
        eqlms.SigConst = step(hMod,(0:M-1)')'; % Set signal constellation.
        release(hMod);
        % Maintain continuity between calls to equalize.
        eqlms.ResetBeforeFiltering = 0;

        % Equalize the received signal, in pieces.
        % 1. Process the training sequence.
        s1 = equalize(eqlms,filtmsg(1:trainlen),modmsg(1:trainlen));

        % 3. Process the rest of the data in decision-directed mode.
        s = equalize(eqlms,filtmsg); % Full output of equalizer
        [EVM_LMS,~,~,~] = step(hEVM,refData,s) 
        release(hEVM);
        evm_flt=num2str(EVM_LMS);
        compSig=s;

    case 'RLS'
        state.ISI
        %% RLS Equalizer
        % Create an RLS equalizer object.
        eqrls = lineareq(state.nISI,rls(0.99,0.1)); 
        eqrls.SigConst = step(hMod,(0:M-1)')'; 
        release(hMod);
        eqrls.ResetBeforeFiltering = 0; 

        % Equalize the received signal, in pieces.
        % 1. Process the training sequence.
        s1 = equalize(eqrls,filtmsg(1:trainlen),modmsg(1:trainlen));

        % 3. Process the rest of the data in decision-directed mode.
        s = equalize(eqrls,filtmsg); % Full output of equalizer
        [EVM_RLS,~,~,~] = step(hEVM,refData,s) 
        release(hEVM);
        evm_flt=num2str(EVM_RLS);
        compSig=s;
    case 'Godard (blind)'
        state.ISI
        ensemble      = 20;                          % number of realizations within the ensemble
        mu            = 0.001;                          % convergence factor (step)  (0 < mu < 1)
        
        p             = 2.2;                            % p-exponent used required in Godard's algorithm
        q             = 1.5;                            % q-exponent used required in Godard's algorithm
        N=state.nISI;
        W=ones(N,length(original)+1,ensemble+1);
%         W(:,1,1)=[zeros(round(N/2),1);1;zeros(N-1-round(N/2),1)];
%         for l=1:ensemble,
%             S   =   struct('step',mu,'filterOrderNo',(N-1),'initialCoefficients',W(:,1,l),'pExponent',p,'qExponent',q);
%             [~,~,W(:,:,l)]  =   Godard(original.',S);
%         end
        S   =   struct('step',mu,'filterOrderNo',(N-1),'initialCoefficients',W(:,1,1),'pExponent',p,'qExponent',q);
        [~,~,W(:,:,1)]  =   Godard(original.',S);
        %   Averaging:
        W_av = W(:,end,1);

        % Simulating the system                

        equalizerInputVector  = original.';
        equalizerInputVector=toeplitz([equalizerInputVector(1) zeros(1,N-1)],[equalizerInputVector zeros(1,N-1)]);

        equalizerOutputVector = (W_av(:,end)')*equalizerInputVector(:,1:end-N+1);
        equalizerOutputVector=equalizerOutputVector(N/2+1.5:end-N/2+1.5); %the first N/2 and last N/2 can't be used
        equalizerOutputVector=equalizerOutputVector/mean(abs(equalizerOutputVector));
        compSig=equalizerOutputVector.';
        
        ori=qamdemod(refData,4);
        
        compSig=conv(W_av',original);
        sig=qamdemod(compSig,4);
        
        [EVM_Godard,~,~,~] = step(hEVM,refData,compSig(1:end-1)); 
        release(hEVM);
        evm_flt=num2str(EVM_Godard);       
    case 'Constant-Modulus Algorithm (blind)'
        state.ISI
        ensemble      = 2;                          % number of realizations within the ensemble
        K             = length(Y);                         % number of iterations
        N             = state.nISI;                            % number of coefficients of the adaptive filter
        mu            = 0.001;                          % convergence factor (step)  (0 < mu < 1)
        original=original.';

        W=ones(N,K+1,ensemble);
%         W(:,1,1)=[zeros(round(N/2)-2,1);1;zeros(N-round(N/2)+1,1)];
% W(:,1,1)=[0.0240390675072360 + 0.0219160937042131i;0.810033943699183 - 0.350963114002706i;-0.0488967286240096 - 0.128786826815265i;0.0985263798658774 - 0.0512700868953633i;-0.0237697189479412 - 0.0304424573329079i]';

        e=zeros(K,ensemble);

        % Finding the adaptive filter 
        S   =   struct('step',mu,'filterOrderNo',(N-1),'initialCoefficients',W(:,1,1))

        [~,e(:,1),W(:,:,1)]  =   CMA(original(1:end),S);

        for k=2:ensemble

            S   =   struct('step',mu/ensemble,'filterOrderNo',(N-1),'initialCoefficients',W(:,1,k));
            [~,e(:,k),W(:,:,k+1)]  =   CMA(original,S);
            e(:,k)=(abs(e(:,k))).^2;

        end
%   W(:,end,end)=[1.02026182775515 + 0.491090740339170i;0.155987172640818 - 0.256022166097846i;0.127785793713089 + 0.0400387639282921i;0.0390209644560373 - 0.0804341288155758i;0.00347234622702491 - 0.00702656358952204i]';

        % Simulating the system                
        equalizerInputVector  = toeplitz([original(1) zeros(1,N-1)],[original zeros(1,N-1)]);
        equalizerOutputVector = (W(:,end,end)')*equalizerInputVector(:,1:end-N+1);
        equalizerOutputVector=equalizerOutputVector/mean(abs(equalizerOutputVector));
        compSig = equalizerOutputVector(N/2+0.5:end-N/2-0.5).';
    
        
        [CMAEVM,~,~,~] = step(hEVM,refData(1:length(compSig)),compSig) 
        release(hEVM);
        evm_flt=num2str(CMAEVM);

end

%%
%presentation

% thetaVector = -pi:0.1:pi;
% constellation = qammod(0:3, 4)/sqrt(2);       % symbols from 4-QAM constellation
% 
% subplot(1,3,1)
% plot(Data,'.');
% hold on;
% plot(cos(thetaVector),sin(thetaVector),'r-','LineWidth',1);
% plot(real(constellation),imag(constellation),'ro',...
%          'MarkerSize',10,'LineWidth',3);
% axis([-1.5 1.5 -1.5 1.5])
% title('Original Data, EVM=23.6957')
% 
% subplot(1,3,2)
% plot(compSig(state.nISI-1:end),'.');
% hold on;
% plot(cos(thetaVector),sin(thetaVector),'r-','LineWidth',1);
% plot(real(constellation),imag(constellation),'ro',...
%          'MarkerSize',10,'LineWidth',3);
% axis([-1.5 1.5 -1.5 1.5])
% title('After LMS Filter, EVM=20.8817')

%%
switch state.IQ
    case 'No Filter'
        compSig=compSig;
    case 'Circularity-based approach'
        state.IQ
        %IQImbalanceCompensator

        % Specify the step size parameter for the I/Q imbalance compensator.
        stepSize = 3e-4;

        % Apply the step function to compensate for the I/Q imbalance while setting
        % the step size via an input argument. You can see that the compensated
        % signal constellation is now nearly aligned with the reference
        % constellation.

        [compSig,estCoef] = IQCompensator_my(3,compSig,stepSize); %output, weights = function (no. of taps,data,step size)

        comSig=compSig./mean(abs(compSig)); %normalization

%         plot(s_iq,'.');
%         hold on;
%         plot(cos(thetaVector),sin(thetaVector),'r-','LineWidth',1);
%         plot(real(constellation),imag(constellation),'ro',...
%                  'MarkerSize',10,'LineWidth',3);
%         axis([-1.5 1.5 -1.5 1.5])
%         title('After IQ Imbalance Compensator, EVM=9.8326')
%         hold off;
        %EVM
        [EVM_Circularity_based_approach,~,~,~] = step(hEVM,refData,comSig(1:9996)) 
        release(hEVM);
        evm_flt=num2str(EVM_Circularity_based_approach);
end

rx_de=qamdemod(original.',M);
flt_de=qamdemod(compSig,M);
% figure;
% plot(rx_de(1:length(flt_de))-flt_de);

EVM=struct('EVM_rx',evm_rx,'EVM_filted',evm_flt);


