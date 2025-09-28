import tensorflow as tf

def convert_model(h5_path, tflite_path):
    model = tf.keras.models.load_model(h5_path)
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    tflite_model = converter.convert()
    with open(tflite_path, "wb") as f:
        f.write(tflite_model)
    print(f" Converted {h5_path} to {tflite_path}")
