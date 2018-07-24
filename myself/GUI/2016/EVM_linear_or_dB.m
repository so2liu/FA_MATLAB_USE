function [ EVM_norm ] = EVM_linear_or_dB( a_i,a_q,k,phi_Tx,b_i,b_q,l,phi_Rx,alpha_d,alpha_r,C_N,B,f_s,P,format)

%Calculate EVM normalized to average symbol power for the following
%imperfections following ZhenQi Chen et al. Effects of LO Phase and Amplitude Imbaöances and Phase Noise on M-WAM Transceiver Performances:
% a_i,a_q:      Tx DC-offset[V]
% k, phi_Tx:    transmitter amplitude [dB] and phase imbalance [degree], k~1, phi << pi/2
% b_i,b_q:      Rx DC_offset
% l, phi_Rx:    receiver amplitude[dB] and phase imbalance[degree]
% alpha_d:      constant phase difference [degree] between Tx and Rx LO due to
% nonideal synchronization
% alpha_r:      LO phase difference[radius] due to phase noise Ñ(0,phi_rms^2)
% for phi_rms <<1!
% C_N:          carrier to noise [dB]
% B:            channel bandwidth [GHz]
% f_s:          symbol rate [GBd]
% P:            average signal power [dB]
%format:        0 for EVM in % 1 for EVM in dB
%
%Like EVM_norm_woPN but with the influence of PN, which shows two impacts:
% random phase imbalances in the modualtor and demodulator plus random
% phase difference between the two LOs; phase noise is approximated as a
% zweo-mean Gaussian noise with a variance definded as the LO mean square
% error

%Convert amplitude imbalance k,l to linear
k=10^(k/20);
l=10^(l/20);

%Convert phi_Tx,Rx alpha to rad
phi_Tx=degtorad(phi_Tx);
phi_Rx=degtorad(phi_Rx);
alpha_d=degtorad(alpha_d);
%alpha_r=degtorad(alpha_r);

%Convert carrier to noise to linear value
C_N_lin=10^(C_N/10);

%Convert avergae signal power to linear value
P_lin=10^(P/10);

%Calculate Energy per Symbol from linear c/n, symbole rate and bandwidth
E_N_lin = C_N_lin*((B*10^9)/(f_s*10^9));

%Calculate Error matrix with respect to alpha_d 
H_d=[k*l*cos(alpha_d) l*sin(phi_Tx-alpha_d); k*sin(alpha_d+phi_Rx) cos(alpha_d+phi_Rx-phi_Tx)];

%Calculate Error matrix with respect to alpha_d 
H_r=[-k*l*sin(alpha_d) -l*cos(phi_Tx-alpha_d); k*cos(alpha_d+phi_Rx) -sin(alpha_d+phi_Rx-phi_Tx)];

%Offset vector
a=[a_i,a_q]';
b=[b_i,b_q]';

offset=a'*H_d'*H_d*a+a'*H_d'*b+b'*H_d*a+b'*b;

%Calculate normalized EVM with
% 0.5*trace(H_d'*H_d)-trace(H_d)+1 representing the contribution due to amplitude
% and phase imbalances
% alpha_r/2*trace(H_r'*H_r) representing increased contribution from phase
% noise to the EVM
% (l^2+1)/(4*E_N_lin) representing the contribution of the channel noise
% alpha_r*a'*H_r*H_r*a+offset)/P_lin representing the contribution of the
% constant offset increased by a term related to phase noise. The latter
% appears due to the continuous drift between both LOs due to PN

if format==0
%EVM in %
EVM_norm=100* sqrt(0.5*trace(H_d'*H_d)-trace(H_d)+1+(alpha_r^2/2*trace(H_r'*H_r))+(((l^2)+1)/(4*E_N_lin))+(alpha_r^2*a'*H_r*H_r*a+offset)/P_lin);

elseif format==1
%EVM in dB    
EVM_norm=20*log10( sqrt(0.5*trace(H_d'*H_d)-trace(H_d)+1+(alpha_r^2/2*trace(H_r'*H_r))+(((l^2)+1)/(4*E_N_lin))+(alpha_r^2*a'*H_r'*H_r*a+offset)/P_lin));

end

