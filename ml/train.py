import numpy as np
from sklearn.model_selection import train_test_split
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.callbacks import EarlyStopping, ModelCheckpoint
from utils.data_preprocessing import create_windows, simulate_physiological_signals
from utils.evaluation_metrics import evaluate_predictions, plot_and_save_roc, plot_confusion_matrix
from models.lstm_model import build_cnn_lstm_attention_model

def train_model(X_eeg, X_phys, y, out_dir="models/saved_models", epochs=10, batch=16):
    X_eeg = np.transpose(X_eeg, (0, 2, 1))  # reshape for Conv1D
    X_eeg_train, X_eeg_val, X_phys_train, X_phys_val, y_train, y_val = train_test_split(
        X_eeg, X_phys, y, test_size=0.2, stratify=y
    )

    model = build_cnn_lstm_attention_model(X_eeg.shape[2], X_eeg.shape[1], X_phys.shape[1])
    model.compile(loss="binary_crossentropy", optimizer=Adam(1e-3), metrics=["accuracy"])

    es = EarlyStopping(monitor="val_loss", patience=3, restore_best_weights=True)
    mc = ModelCheckpoint(f"{out_dir}/seizure_lstm.h5", save_best_only=True)

    model.fit([X_eeg_train, X_phys_train], y_train, validation_data=([X_eeg_val, X_phys_val], y_val),
              epochs=epochs, batch_size=batch, class_weight={0:1,1:5}, callbacks=[es, mc])

    y_prob = model.predict([X_eeg_val, X_phys_val]).ravel()
    y_pred = (y_prob > 0.5).astype(int)

    metrics = evaluate_predictions(y_val, y_pred, y_prob)
    print(metrics)

    plot_and_save_roc(y_val, y_prob, f"{out_dir}/roc.png")
    plot_confusion_matrix(y_val, y_pred, f"{out_dir}/confusion.png")

    return model, metrics
