function [val, ecg_final, t, f, F, ecg_clean2] = loadMatFile(dir)
    % -- Cargar la señal -- %
    data = load(dir);
    val = data.val;
    
    % Ajustar amplitud
    G = 30; %1mv
    ecg_mv = val / G; % Amplitud ajustada

    % Vector de tiempo Fs
    Fs = 250; % [Hz]
    Ts = 1 / Fs; % [s]

    N = length(val);
    vect = (1:1:N);
    t = vect * Ts;

    ecg_final = (ecg_mv - mean(ecg_mv)) / std(ecg_mv); % Señal centrada en 0

    % FFT
    F = fft(val); % Comando de la transformada de Fourier
    F = abs(F); % Calcula el valor absoluto de la señal
    F = F(1:ceil(end / 2)); % Partición de la señal a la mitad
    F = F / max(F); % Ajuste de la magnitud de 0 a 1

    % Vector de frecuencia
    L = length(F);
    f = (1:1:L) * ((Fs / 2) / L);

    % Filtro tipo FIR
    orden = 200;
    limi = 20;
    lims = 28;

    % Normalizar los límites
    limi_n = limi / (Fs / 2);
    lims_n = lims / (Fs / 2);

    % Creación del filtro
    a = 1;
    b = fir1(orden, [limi_n lims_n], 'stop');

    % Filtrar la señal
    ecg_clean = filtfilt(b, a, F); % Para corroborar donde está el filtro escribe freqz(b, a)

    % Filtro de filterDesigner
    Fs = 250;  % Sampling Frequency
    N = 10;  % Order
    Fc1 = 20;  % First Cutoff Frequency
    Fc2 = 26;  % Second Cutoff Frequency

    % Construct an FDESIGN object and call its BUTTER method.
    h = fdesign.bandstop('N,F3dB1,F3dB2', N, Fc1, Fc2, Fs);    
    Hd = design(h, 'butter');

    ecg_clean2 = filter(Hd, F);

    % Devuelve los datos necesarios para las gráficas
end

