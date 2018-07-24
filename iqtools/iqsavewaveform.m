function result = iqsavewaveform(Y, fs, varargin)
% Save a waveform to a file (.MAT, .CSV, .IQBIN)
% A dialog will ask the user for a filename
Y = reshape(Y, 1, length(Y));
marker = '';
for i = 1:2:nargin-2
    if (ischar(varargin{i}))
        switch lower(varargin{i})
            case 'marker';   marker = varargin{i+1};
            otherwise error(['unexpected argument: ' varargin{i}]);
        end
    end
end
[FileName,PathName,filterindex] = uiputfile({...
    '.mat', 'MATLAB file (*.mat)'; ...
    '.mat', 'MATLAB v6 file (*.mat)'; ...
    '.csv', 'CSV file (*.csv)'; ...
    '.bin', 'IQBIN file (*.bin)'; ...
    '.csv', 'CSV (X/Y) (*.csv)'}, ...
    'Save Waveform As...');
if (FileName~=0)
    XDelta = 1/fs;
    XStart = 0;
    InputZoom = 1;
    try
        switch(filterindex)
            case 1 
                save(strcat(PathName,FileName), 'Y', 'XDelta', 'XStart', 'InputZoom');
            case 2
                Y = single(Y);
                save(strcat(PathName,FileName), '-v6', 'Y', 'XDelta', 'XStart', 'InputZoom');
            case 3
                csvwrite(strcat(PathName,FileName), [real(Y.') imag(Y.')]);
            case 4
                a1 = real(Y);
                a2 = imag(Y);
                scale = max(max(abs(a1)), max(abs(a2)));
                if (scale > 1)
                    a1 = a1 / scale;
                    a2 = a2 / scale;
                end
                if (isempty(marker))
                    marker = [ones(1,floor(length(a1)/2)) zeros(1,length(a1)-floor(length(a1)/2))];
                end
                data1 = int16(round(16383 * a1) * 2);
                data1 = data1 + int16(bitand(uint16(marker), 1));
                data2 = int16(round(16383 * a2) * 2);
                data2 = data2 + int16(bitand(uint16(marker), 1));
                data = [data1; data2];
                data = data(1:end);
                f = fopen(strcat(PathName,FileName), 'w');
                fwrite(f, data, 'int16');
                fclose(f);
            case 5
                csvwrite(strcat(PathName,FileName), [linspace(0,(length(Y)-1)*XDelta, length(Y))', real(Y.')]);
        end
    catch ex
        errordlg(ex.message);
    end
end   
