function [ signal ] = gendata_test(numSym, Nqam, format)

% Modulate

switch format
    case 'QAM'
        if Nqam == 8
            h_mod =  modem.genqammod('Constellation',...
                [(-1-1i) * (1+sqrt(3))/sqrt(2),...
                -1 * sqrt(2),...
                1i * sqrt(2),...
                (-1+1i) * (1+sqrt(3))/sqrt(2),...
                -1i * sqrt(2),...
                (1-1i) * (1+sqrt(3))/sqrt(2),...
                (1+1i) * (1+sqrt(3))/sqrt(2),...
                1 * sqrt(2)],...
                'InputType', 'bit'); 
        else
            h_mod = modem.qammod('M', Nqam, 'symbolorder', 'Gray', 'InputType', 'bit');             
        end
    case 'PSK'
        h_mod = modem.pskmod('M', Nqam, 'PhaseOffset', pi/Nqam, 'SymbolOrder', 'Gray', 'InputType', 'bit');
    otherwise
        h_mod = modem.qammod('M', Nqam, 'symbolorder', 'Gray', 'InputType', 'bit');
        fprintf(['Error, wrong Format specified, falling back to QAM', '\n']);
end

prbs01 = idinput(numSym,'prbs',[0, 1],[0, 1]);    % generate PRBS with length: 2^polynom-1

prbs02 = repmat(prbs01,log2(Nqam),1);             % repeat PRBS log2(Nqam) times for modulation
    
signal = modulate(h_mod,prbs02);                  % modulate, same length as prbs01

if strcmp (format, 'QAM') && Nqam == 2    % for BPSK
   signal = (1+1i)*signal;
end

end
