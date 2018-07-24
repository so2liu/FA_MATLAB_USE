excel=xlsread('C:\Users\st144690\Documents\MATLAB\myself\GUI\2016\EVM_gain&phase.xlsx');
evm_rx=excel(2:7,2:7);
evm_flt=excel(11:16,2:7);

[gain,phase] = meshgrid(0:5);

s=surf(gain,phase,evm_rx,'FaceAlpha',0.4);
s.EdgeColor = 'interp';
xlabel('GainIm/dB');ylabel('PhaseIm/dB'),zlabel('EVM/dB')
hold on;
surf(gain,phase,evm_flt);
