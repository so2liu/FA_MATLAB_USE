function [mse]=MSE(data,refdata,w1,w2)
N=length(data);
data_o=ones(N,1);
item=data*w1;
item2=data*w2;
data_o(2:N)=item(1:N-1)+item2(2:N);
mse=((abs(data_o-refdata)).^2)'*ones(100,1)/N;