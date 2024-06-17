clc;close all;clear;
%cargar señal
load('rec_1m.mat');
%ajustar amplitud
G = 30; %1mv
ecg_mv = val/G;%amplitud ajustada

%plot(ecg_mv);
%ylabel('Amplitud (mv)');
%xlim([0 1000])

%vector de tiempo Fs
Fs = 500; %[Hz]
Ts = 1/Fs; %[s]

N = length(val);
vect = (1:1:N);
t = vect*Ts;

ecg_final = (ecg_mv - mean(ecg_mv)/std(ecg_mv))%señal centrada en 0%


%FFT-------------------------------------------------------%

F = fft(val);%comando de la transformada de fourier%
F = abs(F);%calcula el valor absoluto de la señal%
%particion de la señal a la mitad y se agarra con ceil el mas aproximado
F = F(1:ceil(end/2));
%ajuste de la magnitud de 0 a 1%
F = F/max(F);

%vector de frecuencia
L = length(F);
f = (1:1:L) * ((Fs/2)/L);

%---------------------------------------------------------------------------
%filto de filterDesigner%
%Bandstop Filter%

Fs = 500;  % Sampling Frequency

N   = 10;  % Order
Fc1 = 45;  % First Cutoff Frequency
Fc2 = 55;  % Second Cutoff Frequency

% Construct an FDESIGN object and call its BUTTER method.
h  = fdesign.bandstop('N,F3dB1,F3dB2', N, Fc1, Fc2, Fs);
Hd = design(h, 'butter');

ecg_final2 = filter(Hd,ecg_final);%en el tiempo

ecg_cleanf = filter(Hd,F);%en la frecuencia
ecg_cleanf = abs(ecg_cleanf);

%--------------------------------------------------------------------------
% Equiripple Lowpass filter designed using the FIRPM function.
%Lowpass Filter%

% All frequency values are in Hz.
Fs = 500;  % Sampling Frequency

N     = 10;  % Order
Fpass = 49.5;  % Passband Frequency
Fstop = 51.5;  % Stopband Frequency
Wpass = 1;   % Passband Weight
Wstop = 1;   % Stopband Weight
dens  = 20;  % Density Factor

% Calculate the coefficients using the FIRPM function.
b  = firpm(N, [0 Fpass Fstop Fs/2]/(Fs/2), [1 1 0 0], [Wpass Wstop], ...
           {dens});
Hd2 = dfilt.dffir(b);

%------------------------------------------------------------------------
% Equiripple Highpass filter designed using the FIRPM function.

% All frequency values are in Hz.
Fs = 500;  % Sampling Frequency

N     = 10;  % Order
Fstop = 49.5;  % Stopband Frequency
Fpass = 51.5;  % Passband Frequency
Wstop = 1;   % Stopband Weight
Wpass = 1;   % Passband Weight
dens  = 20;  % Density Factor

% Calculate the coefficients using the FIRPM function.
b  = firpm(N, [0 Fstop Fpass Fs/2]/(Fs/2), [0 0 1 1], [Wstop Wpass], ...
           {dens});
Hd3 = dfilt.dffir(b);



ecg_final3 = filter(Hd2,ecg_final2);

ecg_cleanf = filter(Hd2,ecg_cleanf);
ecg_cleanf = abs(ecg_cleanf);
%-------------------------------------------------------------------------
figure(1);
subplot(2,2,1);
plot(val);
title('ECG');

subplot(2,2,3)
plot(f,F)
xlabel('Frecuencia(Hz)');
ylabel('Magnitudnormalizada');
title('ECG en frecuencia');

%ploteo de señales filtradas---------------------------------------------------------
subplot(2,2,2);
plot(t,ecg_final3);
ylabel('amplitud mv');
xlabel ('tiempo s');
title('ECG filtrado FIR');
xlim([0 2])


subplot(2,2,4)
plot(f,ecg_cleanf)
xlabel('frecuencia (Hz)');
ylabel ('magnitud normalizada con filtro FIR');
title('ECG en frecuencia FIR');


%extraccion de caracteristicas-----------------------


ecg_final = ecg_final3;
umbral_y = 6*mean(abs(ecg_final));
umbral_x = 0.02*Fs;

[PKS, LOCS] = findpeaks(ecg_final, 'MinpeakHeight',umbral_y,'minpeakDistance',umbral_x);

figure(2);
hold on;
plot(t,ecg_final);
scatter(t(LOCS),PKS);
ylabel('amplitud mv');
xlabel ('tiempo s');
title('ECG filtrado FIR');
xlim([0 4])
hold off;

%ubicacion en el tiempo de los picos
R_loc_time = t(LOCS);

%calcular HRV
HRV = diff(R_loc_time);

 %RMSSD%
 %primer paso
 
 resta_RR = diff(HRV);
 
 %segundo paso
 resta_RR2 = resta_RR.^2;
 
 %tercer paso
 suma_resta_RR2 = sum(resta_RR2);
 
 %cuarto paso
 norm_resta_RR2 = suma_resta_RR2/lenght(resta_RR);
 
%ultimo paso
RMSSD = sqrt(norm_resta_RR2);

RMSSD_ms = RMSSD*1000;










