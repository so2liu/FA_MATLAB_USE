function    [outputVector,...
             errorVector,...
             coefficientVector] =   rls_cma(input, order)       
%% RLS-CMA Filter according https://ieeexplore.ieee.org/document/4909145/

%normalization
input = input./mean(abs(input));
% initialization
delta = 0.01;
C = 1/delta*eye(order);
p = 2;
w = ones(order, 1);
lambda = 0.999; % forgetting factor 0<lambda<1
N = length(input);
% RLS Update
for it = 1:N-order+1
% for it = 1:order
    x = input(it:it+order-1); % x: 5*1
    z = x*x'*w*(x'*w)^(p-2);
    % 5*1 = 5*1 * 1*5 * 5*1 * (1*5 * 5*1)^2
    h = z'*C;
    % 1*5 = 1*5 * 5*5
    g = C*z/(lambda+h*z);
    % 5*1 = 5*5 * 5*1 / (1*1 + 1*5 * 5*1)
    C = (C-g*h)/lambda;
    % 5*5 = (5*5 - 5*1 * 1*5) / 1*1
    e = 1-w'*z;
    % 1*1 = 1*1 - 1*5 * 5*1
    w = w+g*e.';
    % 5*1 = 5*1 + 5*1 * 1*1
end
outputVector = conv(w, input);
outputVector = outputVector(order:N);

errorVector = 0;
coefficientVector = w;
