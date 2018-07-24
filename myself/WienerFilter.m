
function [yn,Wopt,error] = WienerFilter(xn,dn,M)
K=length(xn);
u=1/sqrt(2)*(1/max(eig(xn(1:M)*xn(1:M)'))); %step
n=0;
W=zeros(M,1);
error=zeros(K,1);
for k=M:10*M %use only the first 100 points for calculating weight matrix W
    x=xn(K:-1:K-M+1);
    y=W'*x;
    error(k)=dn-y;
    W=W+2*u*error(k)*x;
    n=n+1;
end

Wopt=W;

yn=zeros(size(xn));
for k=M:K
    x=xn(k:-1:k-M+1);
    yn(k)=W'*x;
end

