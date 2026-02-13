# NayaRoop

NayaRoop is an AI-powered application that helps users identify their face shape and discover hairstyles that suit them best.
The app combines on-device machine learning with a clean user experience to deliver practical hairstyle recommendations based on facial structure.

The current version focuses on accurate face-shape detection and clear hairstyle suggestions, without live previews or virtual try-on features.


🚀 Features: lets talk about feature

📸 Face detection using on-device ML
🧠 AI-based face shape classification
✂️ Hairstyle recommendations based on predicted face shape

⭐ Save favorite hairstyles

🔐 Google Sign-In with Firebase Authentication
⚡ Fast, private, on-device inference (no server-side ML)
🧠 How It Works (High Level)
User uploads or captures a photo
Face is detected and cropped on-device
Cropped face is passed to a deep learning model
Model predicts probabilities for multiple face shapes
Top predictions are used to recommend suitable hairstyles
Users can save favorites to their account

🧩 Face Shape Categories

The model predicts the following face shapes:
Heart
Oblong
Oval
Round
Square

Instead of forcing a single label, NayaRoop uses the top-2 predictions to provide more realistic and flexible recommendations.

🛠️ Tech Stack
🎨 Frontend
Flutter
Dart

🤖 Machine Learning

TensorFlow / Keras
EfficientNetB0 (ImageNet-pretrained, transfer learning)
TensorFlow Lite (on-device inference)
Input size: 260 × 260 RGB
5-class face-shape classification model

📷 Face Detection
Google ML Kit (Face Detection)
Used for detecting and cropping faces before ML inference

🔐 Backend (Backend-as-a-Service)
Firebase Authentication (Google Sign-In)
Cloud Firestore (user data & favorites)
Firebase Security Rules

All ML inference runs fully on-device. No images are sent to a server.

📊 Model Performance (Honest Metrics)
Test accuracy: ~56%
Dataset: balanced, 5 classes
Evaluation uses a held-out test set

Given the subjective nature of face-shape labeling, predictions are presented probabilistically and combined with rule-based hairstyle recommendations to improve user experience.

🔒 Privacy
Photos are processed locally on the device
No face images are uploaded to a server
Firebase stores only user-related data (e.g., favorites)
