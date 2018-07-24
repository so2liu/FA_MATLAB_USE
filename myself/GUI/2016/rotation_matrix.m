clear
load('gen_data.mat')
load('godard.mat')
s=s(5:end);
s=s.';
data=qamdemod(s,4);

theta=pi/4*5+7*pi/180;
M=[cos(theta) -sin(theta);sin(theta) cos(theta)];

test=[real(compSig),imag(compSig)]*M;
test_complex=test(:,1)+1j*test(:,2);

guess=qamdemod(test_complex,4);
figure
plot(test_complex,'.');