import numpy as np
import tensorflow as tf

def run_inference(model_path, X_eeg, X_phys):
    model = tf.keras.models.load_model(model_path)
    X_eeg = np.transpose(X_eeg, (0, 2, 1))
    y_prob = model.predict([X_eeg, X_phys]).ravel()
    return y_prob
