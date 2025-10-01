import numpy as np
import scipy.signal as signal
from scipy.stats import skew, kurtosis

def bandpass_filter(data, sfreq, low=0.5, high=80, order=5):
    nyquist = 0.5 * sfreq
    b, a = signal.butter(order, [low / nyquist, high / nyquist], btype='band')
    return signal.lfilter(b, a, data)

def bandpower_psd_flat(sig, sfreq, bands=[(0.5,4),(4,8),(8,12),(12,30),(30,80)]):
    freqs, psd = signal.welch(sig, sfreq, nperseg=sfreq*2)
    total_power = np.sum(psd)
    return [np.sum(psd[(freqs >= low) & (freqs < high)]) / total_power for (low, high) in bands]

def eeg_time_feats(sig):
    return [np.mean(sig), np.std(sig), skew(sig), kurtosis(sig), np.sqrt(np.mean(sig**2))]

def compute_hrv(hr_series, fs=4):
    diff = np.diff(hr_series)
    return [np.std(diff), np.sqrt(np.mean(diff**2))]

def simulate_physiological_signals(length_sec, fs=4, seizure_times=[]):
    n = length_sec * fs
    hr = np.random.normal(70, 5, n)
    spo2 = np.random.normal(98, 1, n)
    accel = np.random.normal(0, 0.1, (n, 3))
    for t in seizure_times:
        idx = int(t * fs)
        if idx < n:
            hr[idx:idx+fs*30] += 20
            spo2[idx:idx+fs*30] -= 5
            accel[idx:idx+fs*30] += np.random.normal(0, 1, (fs*30, 3))
    return hr, spo2, accel

def create_windows(eeg, hr, spo2, accel, labels, sfreq, win_sec=30, step_sec=10, horizon_sec=300):
    n_samples = eeg.shape[1]
    win_len = win_sec * sfreq
    step_len = step_sec * sfreq
    horizon_len = horizon_sec * sfreq
    X_eeg, X_phys, y = [], [], []
    for start in range(0, n_samples - win_len - horizon_len, step_len):
        end = start + win_len
        future = end + horizon_len
        X_eeg.append(eeg[:, start:end])
        X_phys.append([np.mean(hr[start:end]), np.std(hr[start:end]),
                       np.mean(spo2[start:end]), np.std(spo2[start:end]),
                       np.mean(accel[start:end,0]**2 + accel[start:end,1]**2 + accel[start:end,2]**2)])
        y.append(int(np.any(labels[end:future])))
    return np.array(X_eeg), np.array(X_phys), np.array(y)
