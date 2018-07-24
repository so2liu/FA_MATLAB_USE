% used by test_LMSandIQCompensator
function [compSig,estCoef] = IQCompensator_my(order,data,stepSize) 
N=order;
x=data;
x_v=zeros(N,1);
w_v=zeros(N,length(data)+1);
y_v=data(N:-1:1);
y=zeros(size(data));
for m=N:length(data)
    for k=1:N
        x_v(k)=data(m-k+1);
    end %vector x_v with length=N
    
    y(m)=x(m)+w_v(:,m).'*conj(x_v);
    y_v=[y(m);y_v(N:-1:2)];
    w_v(:,m+1)=w_v(:,m)-stepSize*y_v*y(m);
end

data=data.';
data_v=toeplitz([data(1) zeros(1,N-1)],[data zeros(1,N-1)]);
compSig=(data+w_v(:,end).'*data_v(:,1:length(data))'.').';


%  compSig=data+w_v(:,end).'*data'.';
estCoef=w_v;

