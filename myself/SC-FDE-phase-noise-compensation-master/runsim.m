global sim_options;

%% Simulation Control Parameters
sim_options.PacketLength = 240;                                                             %Bit Steam Length
sim_options.iter = 0;
sim_options.mu = 0.1;
sim_options.M = 4;                                                                          %M Points
sim_options.k = log2(sim_options.M);                                                        %M-Modulation
sim_options.FrameNum = 250;                                                                 %Tx & Rx tansmittion times

%% Channel Estimate Parameters
sim_options.packetNum = 4;                                                                  % Packet number per frame
sim_options.FFT_Num = 256;
sim_options.CP_Num = 16;
[sim_options.Ga, sim_options.Gb] = GolayGenerate(sim_options.FFT_Num);
sim_options.CP = sim_options.Ga(1:sim_options.CP_Num)';
sim_options.CES = [sim_options.Ga';sim_options.CP;sim_options.Gb';sim_options.CP];
sim_options.CES_Num = length(sim_options.CES);

sim_options.N_carr = sim_options.CES_Num+sim_options.packetNum*(sim_options.CP_Num+sim_options.PacketLength);
sim_options.alpha = 0.05;                                                                   % exponential fading   alpha = 0 ���ȷֲ���
sim_options.fd = 0;                                                                         % ��������Ƶ�� Max Doppler Frequency
sim_options.L = 4;                                                                          % �ྶ���� Channel No.
sim_options.Ts = 1/(1.79*1e9);                                                              % ���ų����� Symbol holding time
sim_options.Tb = sim_options.Ts/sim_options.N_carr;                                         % ������� sampling interval

[sim_options.tap, pdb] = get_channel(sim_options.L, sim_options.alpha);
tau = sim_options.tap*sim_options.Tb;
sim_options.chn = rayleighchan(sim_options.Tb, sim_options.fd, tau, pdb);                   % �����ྶ�����ŵ� generate multi-path rayleign channel
sim_options.chn.StorePathGains = 1;
sim_options.chn.ResetBeforeFiltering = 1;

%% Interleaved Coded Parameters
sim_options.trel = poly2trellis(7, [171 133]);                                              %generate trelis
sim_options.tblen = 5*7;
sim_options.interleave_table = interleav_matrix( ones(1, sim_options.PacketLength*sim_options.packetNum*sim_options.k) );     %����α�����֯�� generate pseudo-random interleaved code

%% Simulation and Execution
digits(12);
for PNdB = -80 : -50 : -180
    sim_options.PhaseNoisedB = PNdB;
    err = zeros(1,9);
    for SNR_dB = 0 : 1 : 8
        sim_options.SNR = SNR_dB;
        %��֡�շ��õ�ͳ��ƽ��������
        %multi-frame tx and rx to get error rate
        for i = 1 : sim_options.FrameNum
            tic;
            thserr = single_packet();
            err(SNR_dB + 1) = err(SNR_dB + 1) + thserr;
            toc;
        end
        err(SNR_dB + 1) = err(SNR_dB + 1) / (sim_options.FrameNum*sim_options.BitLength);
    end
    SNR_dB = (0:1:8);
    SNR = 10.^(SNR_dB/10);
%     Pe = (4/sim_options.k) * (1 - 1/sqrt(sim_options.M)) * ...
%         qfunc( sqrt(3*sim_options.k*SNR/(sim_options.M-1)) );
    semilogy(SNR_dB, err,'*-');
    hold on;
    %semilogy(SNR_dB, err_comp,'o-');
%     semilogy(SNR_dB, Pe);
%     legend('�����������','�����������');
end
xlabel('SNR');
ylabel('BER');
title('QPSK,Rayleigh,-80dBc/Hz@1MHz Phase Noise');
legend('No Compensation','No Phase Noise','LMS Compensation');
grid on;
hold on;