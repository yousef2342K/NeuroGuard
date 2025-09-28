def build_cnn_lstm_attention_model(n_channels: int, win_length: int, physio_feat_dim: int,
                                   conv_filters: int = 32, lstm_units: int = 64, lr: float = 1e-3) -> tf.keras.Model:

    eeg_input = layers.Input(shape=(n_channels, win_length), name='eeg_input')
    x = layers.Permute((2,1))(eeg_input)
    x = layers.Conv1D(conv_filters, kernel_size=3, padding='same', activation='relu')(x)
    x = layers.MaxPooling1D(2)(x)
    x = layers.Conv1D(conv_filters*2, kernel_size=3, padding='same', activation='relu')(x)
    x = layers.MaxPooling1D(2)(x)
    x = layers.Bidirectional(layers.LSTM(lstm_units, return_sequences=True))(x)

    att = layers.TimeDistributed(layers.Dense(1, activation='tanh'))(x)
    att = layers.Flatten()(att)
    att = layers.Activation('softmax', name='attention_weights')(att)
    att = layers.RepeatVector(2*lstm_units)(att)
    att = layers.Permute((2,1))(att)
    x = layers.Multiply()([x, att])
    x = layers.Lambda(lambda z: K.sum(z, axis=1))(x)

    phys_input = layers.Input(shape=(physio_feat_dim,), name='physio_input')
    p = layers.Dense(32, activation='relu')(phys_input)
    p = layers.Dense(16, activation='relu')(p)

    fused = layers.Concatenate()([x, p])
    fused = layers.Dense(64, activation='relu')(fused)
    fused = layers.Dropout(0.3)(fused)
    out = layers.Dense(1, activation='sigmoid', name='seizure_prob')(fused)

    model = models.Model(inputs=[eeg_input, phys_input], outputs=out)
    model.compile(optimizer=tf.keras.optimizers.Adam(learning_rate=lr),
                  loss='binary_crossentropy',
                  metrics=[tf.keras.metrics.AUC(name='auc')])
    return model
