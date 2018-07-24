%function [y,w]=rls_filter[d,x,oder,lambda]
clear;
x=[1;2;3;4;5;6];
d=[2;3;4;5;6;7];
oder=6;
lambda=0.3;
N=length(x);
%%
xn=zeros(oder,N);
for i=1:oder 
    xn(i,i:oder)=x(N:-1:i);
end
%%
%initialization
S_d=eye(oder,N);
p_d=zeros(N,1);
w=zeros(1,oder);
%%
for k=1:oder
    S_d=1\lambda*(S_d-(S_d*xn(k)*xn(k)'*S_d)/(lambda+xn(k)'*S_d*xn(k)));
    p_d=lambda*p_d+d*xn(k);
    w=S_d*p_d;
end


%%


