# 🎙️ Voice Command To-Do App

A simple yet powerful Flutter to-do list application that supports voice command inputs, shared preferences for local data persistence, and elegant animations — built entirely without Firebase or backend services.

## 🌟 Features

- 🎤 **Voice Command Input**  
  Use your voice to add tasks to your to-do list! Just say your task followed by the word `"stop"` and it will be added automatically.

- 📝 **Text Input Dialog**  
  Easily add tasks manually via a clean and intuitive dialog with `Add` and `Clear` options.

- ✅ **Task Management**  
  - Mark tasks as complete or incomplete.
  - Delete tasks with a single tap.
  - Task state persists even after restarting the app.

- 💾 **Persistent Storage using SharedPreferences**  
  All tasks are saved locally using `SharedPreferences` in JSON format, ensuring your tasks are always available.

- 🔄 **State Management**  
  Maintains state in a clean and readable `StatefulWidget` structure with dynamic task updates.

- 🔊 **Microphone Permission Handling**  
  Uses `permission_handler` to manage microphone access securely.

- 🔁 **Smooth Animations**  
  Microphone button pulses with `ScaleTransition` when actively listening.

## 🚀 Technologies Used

| Tech                    | Purpose                                  |
|-------------------------|------------------------------------------|
| Flutter                 | Core framework                           |
| speech_to_text          | Speech recognition                       |
| shared_preferences      | Local storage                            |
| permission_handler      | Microphone permissions                   |
| AnimationController     | Custom pulsing animation                 |
| JSON (encode/decode)    | Task serialization/deserialization       |

## 📸 Screenshots

> _Add screenshots here if available for better presentation_


## 🧠 What I Learned
- How to serialize and deserialize data using JSON in Flutter.

- Using SharedPreferences to save complex model lists persistently.

- Managing user permissions using permission_handler.

- Implementing smooth UI animations using AnimationController and Tween.

- Real-time speech-to-text integration with control over voice input flow.

- Handling edge cases like empty inputs, multiple state toggles, and cleanup.
