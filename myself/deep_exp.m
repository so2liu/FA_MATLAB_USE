clear all
close all
clc

load('C:\Users\st144690\Documents\MATLAB\myself\data\5GB_withoutfilter.mat','-mat');
Data=Y(1:100);
refData=Data(1:100);
for k=1:length(Data)
    refData(k)=sign(real(Data(k)))+1j*sign(imag(Data(k)));
end
refData=0.707*refData;

w1=-2:0.1:2;
w2=-2:0.1:2;
NoTaps=2;
N=2;
mu=0.1;

[W1, W2] = meshgrid(w1,w2);
Z=ones(length(w2),length(w1));
newData=Data;
for k=1:length(w1)
    for u=1:length(w2)
        Z(u,k)=MSE(Data,refData,w1(k),w2(u));
    end
end
        

surf(W1,W2,Z,'FaceAlpha','flat','AlphaDataMapping','scaled','AlphaData',gradient(Z));
axis( [-2,2,-2,2,0,3]);
hold on;
colormap summer;
meshgrid off;
close all
%%
% NTapWt(1:NoTaps,1) = 0;
% NFiltOut(1:length(Data),1) = 0;
% NErr(1:length(Data),1) = 0;
% n = 1:1:NoTaps;
%  
% for CurDtaPtr = NoTaps+1:1:length(Data)
% % NLMS
% NFiltOut(CurDtaPtr,1) = NTapWt(n,1)'*Data(CurDtaPtr-n);  
% NErr(CurDtaPtr,1)= refData(CurDtaPtr,1) - NFiltOut(CurDtaPtr,1); 
% PwrNFilt = sum(Data(CurDtaPtr-n).^2) + 10^(-6);
% NetDelta = 0.5/PwrNFilt;
% NTapWt(n,1)= NTapWt(n,1)+ NetDelta*Data(CurDtaPtr-n,1)*NErr(CurDtaPtr,1l)';
%    
% plot3(NTapWt(1),NTapWt(2),MSE(Data,refData,NTapWt(1),NTapWt(2)),'.','MarkerSize',20)
% 
% end

%%
%  S   =   struct('step',mu,'filterOrderNo',(N-1),'initialCoefficients',ones(N,1));
%  [y,e,W]  =   LMS(refData,transpose(Data),S);
%%
%   Computing:
ensemble=200;
K=100;
W       = rand(N,(K+1),ensemble);   % coefficient vector for each iteration and realization; w(0) = [1 1 1 1].'
for l=1:ensemble,

    S   =   struct('step',mu,'filterOrderNo',(N-1),'initialCoefficients',W(:,1,l));
    [y,e,W(:,:,l)]  =   LMS(refData,transpose(Data),S);

end
W_av = sum(W,3)/ensemble;
figure;
plot(y,'*');
figure;
plot(Data,'.');
%%

% x0 = zeros(1000,2);
% 
% %x0(1,:) = randint(1,2,10);
% x0(1,:) = [10 10];
% x0(1,:)
% plot3(x0(1,1),x0(1,2),(x0(1,1).^2 + x0(1,2).^2),'ro','MarkerSize',20);
% 
% i=2;
% while(1)
%     %pause
%     % Gradient descent equation..
%     x0(i,:) = x0(i-1,:) - alpha.*2.*(x0(i-1,:));
%     if x0(i,:)<1e-5
%         break
%     end
%     plot3(x0(i,1),x0(i,2),(x0(i,1).^2 + x0(i,2).^2),'.','MarkerSize',20)
%     i=i+1;    
% end
% 
% 
figure;
plot(Y,'.');
figure;
plot(W_av,'.');
L=length(Y);
Y=W_av(101)*Y;
plot(Y,'.')