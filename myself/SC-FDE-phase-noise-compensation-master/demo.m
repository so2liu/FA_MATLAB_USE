sim_options.FrameNum = 250;                                                                 %Tx & Rx tansmittion times



for PNdB = -80 : -50 : -180
    sim_options.PhaseNoisedB = PNdB;
    err = zeros(1,9);
    for SNR_dB = 0 : 1 : 8
        sim_options.SNR = SNR_dB;
        %多帧收发得到统计平均误码率
        %multi-frame tx and rx to get error rate
        for i = 1 : sim_options.FrameNum
            thserr = single_packet();
            err(SNR_dB + 1) = err(SNR_dB + 1) + thserr;
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
%     legend('仿真误比特率','理论误比特率');
end