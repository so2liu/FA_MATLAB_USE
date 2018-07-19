% used by test_LMSandIQCompensator
function [compSig, error, w_v] = CircularityBasedApproach(input, order, stepSize, iteration) 
%%
w_v = rand(order, iteration-order+2);
y_v = zeros(order, 1);
M = ones(order)*stepSize;
error = zeros(iteration-order+1,1);

for k = order:iteration
    x = input(k);
    x_v = input(k:-1:k-order+1);
    y = x+w_v(k).'*x_v'.';
    y_v = [y;y_v(order:-1:2)];
    w_v(k+1) = w_v(k)-M*y_v*y;
    error(k-order+1) = sum(y_v*y);
end
% w_v = fliplr(w_v);


input=input.';
data_v=toeplitz([input(1) zeros(1,order-1)],[input zeros(1,order-1)]);
compSig=(input+w_v(end).'*data_v(:,1:length(input))'.').';

