import tensorflow as tf
from tensorflow.keras.layers import Input, Conv1D, MaxPooling1D, Bidirectional, LSTM, Dense, Dropout, Attention, Flatten, Concatenate
from tensorflow.keras.models import Model

def build_cnn_lstm_attention_model(n_channels, win_len, n_phys):
    eeg_in = Input(shape=(win_len, n_channels))
    x = Conv1D(32, kernel_size=5, activation="relu")(eeg_in)
    x = MaxPooling1D(pool_size=2)(x)
    x = Bidirectional(LSTM(64, return_sequences=True))(x)
    x = Attention()([x, x])
    x = Flatten()(x)

    phys_in = Input(shape=(n_phys,))
    y = Dense(16, activation="relu")(phys_in)

    fused = Concatenate()([x, y])
    fused = Dense(64, activation="relu")(fused)
    fused = Dropout(0.5)(fused)
    out = Dense(1, activation="sigmoid")(fused)

    return Model(inputs=[eeg_in, phys_in], outputs=out)
