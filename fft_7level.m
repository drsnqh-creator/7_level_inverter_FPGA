clc; clearvars; close all;

%% 1. ĐỌC DỮ LIỆU TỪ FILE CSV RIGOL
filename = '7lv5ms.csv';
fprintf('Đang đọc dữ liệu từ file CSV...');
data = readmatrix(filename);
time = data(:, 1);
signal = data(:, 2);

valid_idx = ~isnan(time) & ~isnan(signal);
time = time(valid_idx);
signal = signal(valid_idx);

dt = mean(diff(time));
Fs = 1 / dt;
N = length(signal);
fprintf(' Hoàn tất! (Fs = %.2f MHz, N = %d points)\n', Fs/1e6, N);

%% 2. TÍNH FFT CHUẨN TẤT CẢ ĐIỂM
win = 0.5 * (1 - cos(2*pi*(0:N-1)'/(N-1))); 
v_ac = signal - mean(signal); 
Y = fft(v_ac .* win);
P1 = abs(Y(1:floor(N/2)+1)) / sum(win);
P1(2:end-1) = 2 * P1(2:end-1); 
f = Fs * (0:(floor(N/2))) / N;  

%% 3. THUẬT TOÁN TÍNH THD CHUẨN SPECTRUM ANALYZER (ĐÃ LỌC NOISE FLOOR)
idx_50hz = find(f >= 45 & f <= 55);
[V_fund_peak, rel_idx] = max(P1(idx_50hz));
idx_fund = idx_50hz(rel_idx);
f_fund_real = f(idx_fund);

% Cách ly chân sóng cơ bản 50Hz
fund_bins = find(f >= (f_fund_real - 15) & f <= (f_fund_real + 15));
idx_150k = min(length(P1), floor(150e3 / (Fs/N)));

harmonic_spectrum = P1(1:idx_150k);
harmonic_spectrum(fund_bins) = 0; 
harmonic_spectrum(1:find(f >= 10, 1)) = 0; 

% Lọc đỉnh hài thực sự (Loại bỏ nền nhiễu đáy)
noise_thresh = 0.005 * V_fund_peak;
pks = my_findpeaks(harmonic_spectrum, noise_thresh);
THD = (sqrt(sum(pks.^2)) / V_fund_peak) * 100;

%% 4. IN KẾT QUẢ RA COMMAND WINDOW
fprintf('\n==================================================\n');
fprintf('       THÔNG SỐ PHÂN TÍCH TÍN HIỆU PS-PWM 7 BẬC   \n');
fprintf('==================================================\n');
fprintf(' Tần số lấy mẫu (Fs)        : %.2f MHz\n', Fs / 1e6);
fprintf(' Tần số cơ bản thực tế      : %.2f Hz\n', f_fund_real);
fprintf(' Biên độ sóng cơ bản (50Hz) : %.2f V (Peak)\n', V_fund_peak);
fprintf(' Tổng độ méo sóng hài (THD) : %.2f %%\n', THD);
fprintf('==================================================\n\n');

%% 5. GOM 4 FIGURE VÀO 1 CỬA SỔ DÙNG TAB (GIỮ NGUYÊN TẤT CẢ NỀN TRẮNG CŨ)
main_fig = figure('Name', 'PS-PWM Signal Analyzer - 7 Level', ...
                  'NumberTitle', 'off', ...
                  'Color', 'w', ...
                  'Position', [100, 80, 1000, 650]);

tab_group = uitabgroup(main_fig);

tab1 = uitab(tab_group, 'Title', 'Figure 1: Waveform', 'BackgroundColor', 'w');
tab2 = uitab(tab_group, 'Title', 'Figure 2: FFT Spectrum', 'BackgroundColor', 'w');
tab3 = uitab(tab_group, 'Title', 'Figure 3: Spectrogram', 'BackgroundColor', 'w');
tab4 = uitab(tab_group, 'Title', 'Figure 4: Low-Freq Harmonics', 'BackgroundColor', 'w');

% =========================================================================
% TAB 1: FIGURE 1 GỐC (NỀN TRẮNG)
% =========================================================================
ax1 = axes('Parent', tab1);
plot(ax1, time*1e3, signal, 'Color', [0.0, 0.2, 0.6], 'LineWidth', 1.2); 
grid(ax1, 'on'); box(ax1, 'on');
title(ax1, 'Output Voltage Waveform (7-Level PS-PWM)', 'FontSize', 13, 'FontWeight', 'bold', 'Color', 'k');
xlabel(ax1, 'Time (ms)', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
ylabel(ax1, 'Voltage (V)', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
set(ax1, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'GridColor', [0.8 0.8 0.8], 'LineWidth', 1.2, 'FontSize', 10, 'FontWeight', 'bold');
xlim(ax1, [0, min(40, max(time*1e3))]); 
ylim(ax1, [min(signal)-5, max(signal)+5]);

% =========================================================================
% TAB 2: FIGURE 2 GỐC (NỀN TRẮNG)
% =========================================================================
ax2_1 = subplot(2, 1, 1, 'Parent', tab2);
plot(ax2_1, f/1e3, P1, 'Color', [0.85, 0.0, 0.0], 'LineWidth', 1.5); 
grid(ax2_1, 'on'); box(ax2_1, 'on');
title(ax2_1, 'FFT Harmonic Spectrum (Linear Scale)', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
xlabel(ax2_1, 'Frequency (kHz)', 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'k');
ylabel(ax2_1, 'Magnitude (V)', 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'k');
set(ax2_1, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'GridColor', [0.8 0.8 0.8], 'LineWidth', 1.2, 'FontSize', 10, 'FontWeight', 'bold');
xlim(ax2_1, [0, 200]);

ax2_2 = subplot(2, 1, 2, 'Parent', tab2);
P1_dB = 20*log10(P1 + 1e-12);
plot(ax2_2, f/1e3, P1_dB, 'Color', [0.70, 0.10, 0.10], 'LineWidth', 1.2); 
grid(ax2_2, 'on'); box(ax2_2, 'on');
title(ax2_2, 'FFT Harmonic Spectrum (dB Scale)', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
xlabel(ax2_2, 'Frequency (kHz)', 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'k');
ylabel(ax2_2, 'Magnitude (dB)', 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'k');
set(ax2_2, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'GridColor', [0.8 0.8 0.8], 'LineWidth', 1.2, 'FontSize', 10, 'FontWeight', 'bold');
xlim(ax2_2, [0, 200]); ylim(ax2_2, [-40, max(P1_dB)+5]);

dim = [0.70 0.76 0.18 0.12];
str = {sprintf('V_{fund} = %.2f V', V_fund_peak), ...
       sprintf('THD = %.2f %%', THD)};
annotation(tab2, 'textbox', dim, 'String', str, 'FitBoxToText', 'on', ...
           'BackgroundColor', [0.98 0.98 0.98], 'EdgeColor', 'k', 'LineWidth', 1.5, ...
           'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');

% =========================================================================
% TAB 3: FIGURE 3 GỐC (SPECTROGRAM NỀN TRẮNG CHUẨN CŨ)
% =========================================================================
NFFT_spec = 2048; 
OVERLAP_spec = 0.85;
[sg, fsg, tsg] = my_spectrogram(v_ac, NFFT_spec, Fs, OVERLAP_spec);  
sg_mag = abs(sg);
sg_dBc = 20*log10(sg_mag / max(sg_mag(:)) + 1e-12); 

ax3 = axes('Parent', tab3);
imagesc(ax3, tsg*1e3, fsg/1e3, sg_dBc); 
axis(ax3, 'xy'); 

try
    colormap(ax3, 'turbo');
catch
    colormap(ax3, 'jet');
end

caxis(ax3, [-70, 0]);

cb = colorbar(ax3, 'vert');
cb.Label.String = 'Relative Power (dBc)';
cb.Label.FontSize = 10;
cb.Label.FontWeight = 'bold';
cb.Label.Color = 'k';
cb.Color = 'k';

grid(ax3, 'on'); box(ax3, 'on');
set(ax3, 'Color', 'w', ...
         'XColor', 'k', 'YColor', 'k', ...
         'GridColor', [0.8 0.8 0.8], ...
         'LineWidth', 1.2, 'FontSize', 10, 'FontWeight', 'bold');
ylim(ax3, [0, 150]); 
title(ax3, 'REAL-TIME SPECTROGRAM ANALYZER (PS-PWM 7-LEVEL)', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
xlabel(ax3, 'Time (ms)', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');
ylabel(ax3, 'Frequency (kHz)', 'FontSize', 11, 'FontWeight', 'bold', 'Color', 'k');

% =========================================================================
% TAB 4: FIGURE 4 GỐC (NỀN TRẮNG)
% =========================================================================
idx_5khz = find(f >= 5e3, 1);
if isempty(idx_5khz), idx_5khz = length(f); end
f_sub = f(1:idx_5khz) / 1e3; 
P1_sub = P1(1:idx_5khz);
P1_dB_sub = 20*log10(P1_sub + 1e-12);

ax4_1 = subplot(2, 1, 1, 'Parent', tab4);
plot(ax4_1, f_sub, P1_sub, 'Color', [0.85, 0.0, 0.0], 'LineWidth', 1.3); 
grid(ax4_1, 'on'); box(ax4_1, 'on'); hold(ax4_1, 'on');
patch(ax4_1, [0.02 0.08 0.08 0.02], [0 0 max(P1_sub)*1.05 max(P1_sub)*1.05], ...
      [0.92 0.92 0.92], 'EdgeColor', 'none', 'FaceAlpha', 0.6);
xline(ax4_1, f_fund_real/1e3, '-k', sprintf('%.1f Hz', f_fund_real), 'LineWidth', 1.2, 'FontSize', 9, 'FontWeight', 'bold');
title(ax4_1, 'Low-Frequency Harmonic Spectrum (Linear Scale: 0 - 5 kHz)', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
xlabel(ax4_1, 'Frequency (kHz)', 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'k');
ylabel(ax4_1, 'Magnitude (V)', 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'k');
set(ax4_1, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'GridColor', [0.85 0.85 0.85], 'LineWidth', 1.2, 'FontSize', 10, 'FontWeight', 'bold');
xlim(ax4_1, [0, 5]); ylim(ax4_1, [0, max(P1_sub)*1.05]);

ax4_2 = subplot(2, 1, 2, 'Parent', tab4);
plot(ax4_2, f_sub, P1_dB_sub, 'Color', [0.70, 0.10, 0.10], 'LineWidth', 1.2); 
grid(ax4_2, 'on'); box(ax4_2, 'on'); hold(ax4_2, 'on');
patch(ax4_2, [0.02 0.08 0.08 0.02], [-50 -50 max(P1_dB_sub)+5 max(P1_dB_sub)+5], ...
      [0.92 0.92 0.92], 'EdgeColor', 'none', 'FaceAlpha', 0.6);

harmonics_kHz = f_fund_real * [1, 3, 5, 7, 9, 11, 13] / 1e3;
harm_labels = {'50Hz', 'h3', 'h5', 'h7', 'h9', 'h11', 'h13'};
for k = 1:length(harmonics_kHz)
    if k == 1
        xline(ax4_2, harmonics_kHz(k), '-k', harm_labels{k}, 'LineWidth', 1.2, 'FontSize', 8, 'FontWeight', 'bold');
    else
        xline(ax4_2, harmonics_kHz(k), '--b', harm_labels{k}, 'LabelOrientation', 'aligned', 'FontSize', 8, 'Color', [0 0.4 0.8]);
    end
end
title(ax4_2, 'Low-Frequency Harmonic Spectrum (dB Scale: 0 - 5 kHz)', 'FontSize', 12, 'FontWeight', 'bold', 'Color', 'k');
xlabel(ax4_2, 'Frequency (kHz)', 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'k');
ylabel(ax4_2, 'Magnitude (dB)', 'FontSize', 10, 'FontWeight', 'bold', 'Color', 'k');
set(ax4_2, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', 'GridColor', [0.85 0.85 0.85], 'LineWidth', 1.2, 'FontSize', 10, 'FontWeight', 'bold');
xlim(ax4_2, [0, 5]); ylim(ax4_2, [-40, max(P1_dB_sub)+5]);

% =========================================================================
% HELPER FUNCTIONS
% =========================================================================
function pks = my_findpeaks(x, min_height)
    x = x(:);
    if length(x) < 3
        pks = x(x >= min_height);
        return;
    end
    is_peak = [false; (x(2:end-1) > x(1:end-2)) & (x(2:end-1) > x(3:end)); false];
    pks = x(is_peak & (x >= min_height));
end

function w = my_hanning(N)
    w = 0.5 * (1 - cos(2*pi*(0:N-1)'/(N-1)));
end

function [sg, fsg, tsg] = my_spectrogram(sig, nfft, Fs, overlap)
    sig = sig(:);
    N = length(sig);
    win = my_hanning(nfft);
    step = fix((1 - overlap) * nfft);
    num_frames = fix((N - nfft) / step) + 1;
    
    if rem(nfft, 2)
        num_freqs = (nfft + 1) / 2;
    else
        num_freqs = nfft / 2 + 1;
    end
    
    sg = zeros(num_freqs, num_frames);
    tsg = zeros(1, num_frames);
    
    for i = 1:num_frames
        idx_start = (i - 1) * step + 1;
        idx_end = idx_start + nfft - 1;
        segment = sig(idx_start:idx_end) .* win;
        
        fft_res = fft(segment, nfft);
        sg(:, i) = fft_res(1:num_freqs);
        tsg(i) = (idx_start + nfft/2 - 1) / Fs;
    end
    
    fsg = (0:num_freqs-1)' * (Fs / nfft);
end
