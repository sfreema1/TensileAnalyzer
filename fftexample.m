%% Grab loaded data
    time = data_cell{2}.time;
    force = data_cell{2}.force;
    Fs = (time(4,1)-time(3,1))^-1; % samples per second
    dt = 1/Fs;                     % seconds per sample
    N = length(time);
%% Fourier Transform:
   X = fftshift(fft(force));
   %% Frequency specifications:
   dF = Fs/N;                      % hertz
   f = -Fs/2:dF:Fs/2-dF;           % hertz
%% Plot the spectrum:
   subplot(1,2,1);
   plot(time,force);
   xlabel('Time (s)');
   ylabel('Force (N)');
   title('Force Reponse');
   subplot(1,2,2);
   plot(f,abs(X)/N);
   xlabel('Frequency (in hertz)');
   title('Magnitude Response');