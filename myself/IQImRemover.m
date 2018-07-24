function [yn,W_r,W_i,error_r,error_i,error]=IQImRemover (xn,dn,M)
%xn=recieved signal
%dn=ideal signal 
%M=filter length

xn_r=real(xn);
xn_i=imag(xn);

[yn_r,W_r,error_r] = WienerFilter2(xn_r,real(dn),M);
[yn_i,W_i,error_i] = WienerFilter2(xn_i,imag(dn),M);


yn=yn_r+yn_i*1i;
error=abs(error_r+1i*error_i);



function [yn,Wopt,error] = WienerFilter2(xn,dn,M)
K=length(xn);
u=1/sqrt(2)*(1/max(eig(xn(1:M)*xn(1:M)'))); %step
n=0;
W=zeros(M,1);
error=zeros(K,1);
for k=M:10*M %use only the first 100 points for calculating weight matrix W
    x=xn(K:-1:K-M+1);
    y=W'*x;
    error(k)=x(1)-y;
    W=W+2*u*error(k)*x;
    n=n+1;
end

Wopt=W;

yn=zeros(size(xn));
for k=M:K
    x=xn(k:-1:k-M+1);
    yn(k)=W'*x;
end

