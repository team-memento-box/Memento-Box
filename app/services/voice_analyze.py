# from dotenv import load_dotenv
# from dataclasses import dataclass
# from openai import AzureOpenAI
# import os, time
# import tiktoken
# from pathlib import Path
# import numpy as np
# from datetime import datetime
# import soundfile as sf
# # import sounddevice as sd
# import json

# from services.chat_system import StrangeResponse
# from core.config import settings


# class VoiceAnalyzer:
#     def preprocess_audio_slices(audio_path, save_path, add_noise=True):
#     if not os.path.exists(audio_path): return []
    
#     y, sr = librosa.load(audio_path, sr=SR)
#     slice_length, total_slices = FIXED_DURATION * sr, len(y) // (FIXED_DURATION * sr)
#     if total_slices == 0: return []
    
#     os.makedirs(save_path, exist_ok=True)
#     base_name = os.path.splitext(os.path.basename(audio_path))[0]
#     saved_files = []
    
#     for i in range(total_slices):
#         y_slice = y[i * slice_length:(i + 1) * slice_length]
        
#         if add_noise:
#             noise = 0.005 * np.random.uniform() * np.amax(y_slice) * np.random.normal(size=y_slice.shape[0])
#             y_slice = y_slice + noise
        
#         mel = librosa.feature.melspectrogram(y=y_slice, sr=sr, n_mels=128)
#         mel_norm = (librosa.power_to_db(mel, ref=np.max) - librosa.power_to_db(mel, ref=np.max).min()) / \
#                    (librosa.power_to_db(mel, ref=np.max).max() - librosa.power_to_db(mel, ref=np.max).min())
        
#         save_file = os.path.join(save_path, f"{base_name}_slice{i+1}.jpg")
#         plt.figure(figsize=(10, 4))
#         librosa.display.specshow(mel_norm, sr=sr, x_axis='time', y_axis='mel')
#         plt.axis('off'); plt.tight_layout()
#         plt.savefig(save_file, bbox_inches='tight', pad_inches=0)
#         plt.close()
#         saved_files.append(save_file)
    
#     return saved_files

# def analyze_voice_patterns(audio_path, model_path='models-05-0.7188.hdf5', save_path="./mel_slices/"):
#     """음성 패턴 분석 수행"""
#     saved_images = preprocess_audio_slices(audio_path, save_path, add_noise=False)
#     if not saved_images:
#         return {'success': False, 'message': "슬라이스된 이미지가 생성되지 않았습니다.", 'analysis': {}}
    
#     try:
#         # compile=False 옵션을 추가하여 optimizer 설정 무시
#         model = load_model(model_path, compile=False)
#         # 필요한 경우 여기서 모델 컴파일
#         model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])
#         predictions = []
        
#         for img_path in saved_images:
#             img = image.load_img(img_path, target_size=(250, 250))
#             img_processed = np.expand_dims(image.img_to_array(img) / 255.0, axis=0)
#             pred = model.predict(img_processed)[0]
#             predictions.append(float(pred[0]) if len(pred) > 0 else float(pred))
        
#         threshold, total = 0.5, len(predictions)
#         positive = sum(1 for p in predictions if p >= threshold)
#         ratio = positive / total if total > 0 else 0
        
#         level_map = {ratio >= 0.7: ("높음", "🔴"), ratio >= 0.4: ("중간", "🟠")}.get(True, ("낮음", "🟢"))
#         level, icon = level_map
        
#         return {
#             'success': True, 'predictions': predictions,
#             'analysis': {'total_clips': total, 'positive_clips': positive, 'ratio': ratio, 'level': level, 'icon': icon}
#         }
#     except Exception as e:
#         return {'success': False, 'message': f"분석 중 오류: {str(e)}", 'analysis': {}}

# print("✅ 음성 분석 함수들 정의 완료")