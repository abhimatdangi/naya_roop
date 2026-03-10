NayaRoop

NayaRoop is a mobile application built with Flutter that uses on-device artificial intelligence to identify a user's face shape and recommend hairstyles that best match their facial structure.

The application combines machine learning, face detection, and a clean user interface to deliver practical hairstyle suggestions. All AI inference runs locally on the device, ensuring fast performance and strong user privacy.

Overview

NayaRoop analyzes a user's face from a photo and predicts their most likely face shape using a deep learning model. Based on this prediction, the application suggests hairstyles that typically suit that face structure.

Rather than forcing a single label, the system considers the top two predicted face shapes, allowing the app to provide more realistic and flexible hairstyle recommendations.

Key Features

Face Detection
Detects and crops the user's face using Google ML Kit before running the machine learning model.

AI-Based Face Shape Classification
A deep learning model predicts probabilities for different face shapes.

Hairstyle Recommendations
The app suggests hairstyles based on the predicted face shape.

Top-2 Prediction System
Handles ambiguity by considering the two most probable face shapes.

Favorites System
Users can save hairstyles they like to their account.

Authentication
Secure Google Sign-In using Firebase Authentication.

On-Device Inference
All machine learning predictions run locally on the device.

How the System Works

The user uploads or captures a photo.

The application detects and crops the face using Google ML Kit.

The cropped image is passed to a TensorFlow Lite model.

The model predicts probabilities for multiple face shapes.

The two highest predictions are selected.

Hairstyle recommendations are generated based on those predictions.

Users can save recommended hairstyles to their favorites.

Face Shape Categories

The model classifies faces into the following five categories:

Heart

Oblong

Oval

Round

Square

Because face shape classification can sometimes be subjective, the system uses probability-based predictions rather than forcing a single definitive label.

Technology Stack
Frontend

Flutter

Dart

Machine Learning

TensorFlow / Keras

EfficientNetB0 (ImageNet-pretrained using transfer learning)

TensorFlow Lite for on-device inference

Model Specifications

Input size: 260 × 260 RGB

Classification type: 5-class face shape prediction

Face Detection

Face detection is performed using Google ML Kit, which identifies and crops the face region before it is passed to the machine learning model.

Backend Services

NayaRoop uses Firebase as a backend service provider.

Firebase Authentication (Google Sign-In)

Cloud Firestore (user data and saved hairstyles)

Firebase Security Rules

The backend only stores user-related metadata. No images are uploaded or stored.

Model Performance

Test Accuracy: ~56%

Dataset: Balanced dataset across five classes

Evaluation Method: Held-out test dataset

Face shape labeling is inherently subjective, so predictions are presented probabilistically and combined with rule-based hairstyle recommendations.

Privacy

User privacy is a core design consideration.

All image processing happens locally on the device

No photos are uploaded to external servers

Firebase stores only user account data and saved favorites