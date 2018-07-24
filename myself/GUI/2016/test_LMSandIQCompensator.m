function [original,compSig,estCoef,EVM] = test_LMSandIQCompensator(state)
cd 'C:\Users\st144690\Documents\MATLAB\myself\GUI\2016';
% load('C:\Users\st144690\Documents\MATLAB\myself\GUI\2016\gen_data.mat','x','s');
% original=x.'; %original is always column vector 10000 by 1
% refData=s.'; %refData is always column vector 10000 by 1

% load('C:\Users\st144690\Documents\MATLAB\myself\GUI\2016\ISI\isi.mat','-mat','Y');
% load('C:\Users\st144690\Documents\MATLAB\myself\GUI\2016\fdg4.mat','-mat','Y');
load('pn_50db.mat','-mat','y');
Y=y./mean(abs(y));
load ('ISIIQ.mat');
original=Y;
refData=zeros(length(Y),1);
for k=1:length(original)
    refData(k)=sign(real(original(k)))+1j*sign(imag(original(k)));
end
refData=0.707*refData;


% coefficients
M = 4; % Alphabet size for modulation
trainlen = 200; % Length of training sequence
MSE=zeros(length(original)+1,1);
nISI=state.nISI;
mu= 0.001;  % convergence factor (step)  (0 < mu < 1)

%initial
original=double(original);
compSig=original; %compSig is output of adaptive filter, initial value is input
estCoef=0; %describe convergence speed later
% measurements initial
 hEVM = comm.EVM('MaximumEVMOutputPort',true,...
            'XPercentileEVMOutputPort', true, 'XPercentileValue', 90,...
            'SymbolCountOutputPort', true); 
% Calculate measurements, evm_rx & evm_flt is EVM outputs
[EVM_Original,~,~,~] = step(hEVM,refData,original)  %https://de.mathworks.com/help/comm/ref/evmmeasurement.html
release(hEVM);        
evm_rx=num2str(EVM_Original);
evm_flt=num2str(EVM_Original); %evm without filter is evm_origianl


%%
% filter for ISI
N=state.nISI; % N for total no. of coefficients
switch state.ISI
    case 'No Filter'
        compSig=original;
        
    case 'LMS' %matlab 2016a doesn't support string!!!
        % Set up equalizer.
        eqlms = lineareq(N, lms(10*mu)); % Create an equalizer object.
        hMod = comm.QPSKModulator; % constellation
        eqlms.SigConst = step(hMod,(0:M-1)')'; % Set signal constellation.
        release(hMod);
        % Maintain continuity between calls to equalize.
        eqlms.ResetBeforeFiltering = 0;

        % Equalize the received signal, in pieces.
        s1 = equalize(eqlms,original(1:trainlen),refData(1:trainlen));  %equalize(object,rx data,ref data)
        compSig = equalize(eqlms,original); % Full output of equalizer
        [EVM_LMS,~,~,~] = step(hEVM,refData,compSig); 
        release(hEVM);
        evm_flt=num2str(EVM_LMS);
    
    case 'RLS'
        state.ISI
        % RLS Equalizer
        % Create an RLS equalizer object.
        eqrls = lineareq(N,rls(0.99,100*mu)); 
        hMod = comm.QPSKModulator; % constellation
        eqrls.SigConst = step(hMod,(0:M-1)')'; 
        release(hMod);
        eqrls.ResetBeforeFiltering = 0; 

        % Equalize the received signal, in pieces.
        s1 = equalize(eqrls,original(1:trainlen),refData(1:trainlen));%equalize(object,rx data,ref data)
        compSig = equalize(eqrls,original); % Full output of equalizer
        
        [EVM_RLS,~,~,~] = step(hEVM,refData,compSig) 
        release(hEVM);
        evm_flt=num2str(EVM_RLS);
    case 'Godard (blind)'
        state.ISI
        ensemble      = 20;                          % number of realizations within the ensemble
        
        p             = 2.2;                            % p-exponent used required in Godard's algorithm
        q             = 1.5;                            % q-exponent used required in Godard's algorithm
        W=ones(N,length(original)+1);
%         W=ones(N,length(original)+1,ensemble+1);
%         W(:,1,1)=[zeros(round(N/2),1);1;zeros(N-1-round(N/2),1)];
%         for l=1:ensemble,
%             S   =   struct('step',mu,'filterOrderNo',(N-1),'initialCoefficients',W(:,1,l),'pExponent',p,'qExponent',q);
%             [~,~,W(:,:,l)]  =   Godard(original.',S);
%         end
        S   =   struct('step',5*mu,'filterOrderNo',(N-1),'initialCoefficients',W(:,1),'pExponent',p,'qExponent',q);
        [~,~,W]  =   Godard(original.',S);%row vector as input only 
     
        compSig=conv(W(:,end)',compSig);
        compSig=compSig(N:end-N+1);

%         W_av=W(:,end)';
%         compSig=compSig.';
%         compSig=toeplitz([W_av(1),zeros(1,N-1)],[compSig, zeros(1,N-1)]);
%         compSig=W_av*compSig;
%         compSig=compSig.';
%         compSig=compSig(N:end-N+1);
        
        %rotation
        theta=pi/4*0;
        M=[cos(theta) -sin(theta);sin(theta) cos(theta)];
        test=[real(compSig),imag(compSig)]*M;
        compSig=test(:,1)+1j*test(:,2);    
        
        %Normalization
        compSig=compSig/mean(abs(compSig));       

        %demod
        tx=qamdemod(refData,4);
        rx=qamdemod(compSig,4);
        
        % EVM measurements 
        [EVM_Godard,~,~,~] = step(hEVM,refData((N+1)/2:end-(N-1)/2),compSig); 
        release(hEVM);
        evm_flt=num2str(EVM_Godard); 
        
    case 'Constant-Modulus Algorithm (blind)'
        state.ISI
        N             = state.nISI;                            % number of coefficients of the adaptive filter
        mu            = 0.001;                          % convergence factor (step)  (0 < mu < 1)
        it=10;
        W=ones(N,length(original)+1,it+1);
        
        for k=1:it
        S   =   struct('step',mu,'filterOrderNo',(N-1),'initialCoefficients',W(:,end,k))
        [~,~,W(:,:,k+1)]  =   CMA(original.',S);
        end

        % Apply the weights to the rx signal       
%         compSig=conv(W(:,end)',compSig);
%         compSig=compSig(N:end-N+1);

        W_av=W(:,end,end)';
        compSig=compSig.';
        compSig=toeplitz([W_av(1),zeros(1,N-1)],[compSig, zeros(1,N-1)]);
        compSig=W_av*compSig;
        compSig=compSig.';
        compSig=compSig(N:end-N+1);
        
        %Normalization
        compSig=compSig/mean(abs(compSig));  
        
        %rotation
        theta=pi/4*0;
        M=[cos(theta) -sin(theta);sin(theta) cos(theta)];
        test=[real(compSig),imag(compSig)]*M;
        compSig=test(:,1)+1j*test(:,2);    
        
    
        
%         tx=qamdemod(refData,4);
%         rx=qamdemod(compSig,4);

        % EVM measurements 
        [EVM_CMA,~,~,~] = step(hEVM,refData(N:end),compSig); 
        release(hEVM);
        evm_flt=num2str(EVM_CMA);
        
        
        case 'Modified CMA (Blind)'
        state.ISI
        N             = state.nISI;                            % number of coefficients of the adaptive filter
        mu            = 0.001;                          % convergence factor (step)  (0 < mu < 1)
        it=10;
        W=ones(N,length(original)+1,it+1);
        
        for k=1:it
        S   =   struct('step',mu,'filterOrderNo',(N-1),'initialCoefficients',W(:,end,k))
        [~,~,W(:,:,k+1)]  =   MCMA(original.',S);
        end

        % Apply the weights to the rx signal       
%         compSig=conv(W(:,end)',compSig);
%         compSig=compSig(N:end-N+1);

        W_av=W(:,end,end)';
        compSig=compSig.';
        compSig=toeplitz([W_av(1),zeros(1,N-1)],[compSig, zeros(1,N-1)]);
        compSig=conj(W_av)*compSig;
        compSig=compSig.';
        compSig=compSig(N+1:end-N+1);
        
        %Normalization
        compSig=compSig/mean(abs(compSig));  
        
        %rotation
        theta=pi/4*0;
        M=[cos(theta) -sin(theta);sin(theta) cos(theta)];
        test=[real(compSig),imag(compSig)]*M;
        compSig=test(:,1)+1j*test(:,2);    
        
    
        
%         tx=qamdemod(refData,4);
%         rx=qamdemod(compSig,4);

        % EVM measurements 
        [EVM_CMA,~,~,~] = step(hEVM,refData(N+1:end),compSig); 
        release(hEVM);
        evm_flt=num2str(EVM_CMA);   
end

switch state.IQ
    case 'No Filter'
        state.IQ
        [evm_flt,~,~,~] = step(hEVM,getRef(compSig),compSig) 
        evm_flt=num2str(evm_flt);

        compSig=compSig;
    case 'Circularity-based approach'
        state.IQ

        stepSize = 3e-4;

        % Apply the step function to compensate for the I/Q imbalance while setting
        % the step size via an input argument. You can see that the compensated
        % signal constellation is now nearly aligned with the reference
        % constellation.

        [compSig,estCoef] = IQCompensator_my(state.nIQ,compSig,stepSize); %output, weights = function (no. of taps,data,step size)

        compSig=compSig./mean(abs(compSig)); %normalization

%         iqImbComp = comm.IQImbalanceCompensator('StepSizeSource','Input port', ...
%     'CoefficientOutputPort',true);
%         [compSig,estCoef] = step(iqImbComp,original,stepSize);

        %EVM
%         [EVM_Circularity_based_approach,~,~,~] = step(hEVM,refData(1:length(compSig)),compSig) 
        [EVM_Circularity_based_approach,~,~,~] = step(hEVM,getRef(compSig),compSig) 
        release(hEVM);
        evm_flt=num2str(EVM_Circularity_based_approach);
end

EVM=struct('EVM_rx',evm_rx,'EVM_filted',evm_flt);
savevsarecording('fdg_after', compSig, 0.5e9, 77e9);
save('C:\Users\st144690\Documents\MATLAB\myself\GUI\2016\ISI\isi_after.mat','compSig');

function [refData]=getRef(original)

refData=zeros(length(original),1);
for k=1:length(original)
    refData(k)=sign(real(original(k)))+1j*sign(imag(original(k)));
end
refData=0.707*refData;
