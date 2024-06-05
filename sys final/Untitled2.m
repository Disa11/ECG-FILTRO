clc;close all;clear;
%cargar señal
load('rec_1m.mat');
%ajustar amplitud
G = 30; %1mv
ecg_mv = val/G;%amplitud ajustada

figure;

%plot(ecg_mv);
%ylabel('Amplitud (mv)');
%xlim([0 1000])

%vector de tiempo Fs
Fs = 250; %[Hz]
Ts = 1/Fs; %[s]

N = length(val);
vect = (1:1:N);
t = vect*Ts;

ecg_final = (ecg_mv - mean(ecg_mv)/std(ecg_mv))%señal centrada en 0%


%FFT%

F = fft(val);%comando de la transformada de fourier%
F = abs(F);%calcula el valor absoluto de la señal%
%particion de la señal a la mitad y se agarra con ceil el mas aproximado
F = F(1:ceil(end/2));
%ajuste de la magnitud de 0 a 1%
F = F/max(F);

%vector de frecuencia
L = length(F);
f = (1:1:L) * ((Fs/2)/L);
%plot(f,F)
%xlabel('Frecuencia(Hz)');
%ylabel('Magnitud Normalizada');
%title('ECG en frecuencia');

%Filtro tipo FIR%
%caracterizticas del filtro
orden = 200;
limi = 20;
lims = 28;

%normalizar los limites%
limi_n = limi/(Fs/2);
lims_n = lims/(Fs/2);

%creacion del filtro%
a = 1;
b = fir1(orden,[limi_n lims_n], 'stop');

%filtrar la señal%
ecg_clean = filtfilt(b,a,F);%para corroborrar donde esta el filtro escribe freqz(b,a)

subplot(2,2,1);
plot(val);
title('señal no filtrada');

subplot(2,2,2);
plot(t,ecg_final);
ylabel('amplitud mv');
xlabel ('tiempo s');
title('señal filtrada');
xlim([0 4])

subplot(2,2,3)
plot(f,F)
xlabel('Frecuencia(Hz)');
ylabel('Magnitud Normalizada');
title('ECG en frecuencia');

%---------------------------------------------------------------------------
%filto de filterDesigner%

Fs = 250;  % Sampling Frequency

N   = 10;  % Order
Fc1 = 20;  % First Cutoff Frequency
Fc2 = 26;  % Second Cutoff Frequency

% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.bandstop('N,F3dB1,F3dB2', N, Fc1, Fc2, Fs);
Hd = design(h, 'butter');

ecg_clean2 = filter(Hd,F);

subplot(2,2,4)
plot(ecg_clean2)
xlabel('frecuencia (Hz)');
ylabel ('magnitud normalizada con filtro FIR');
title('ECG en frecuencia');

