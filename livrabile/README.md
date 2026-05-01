Overview -> AnyBase is a cognitive translation system that converts raw text into adaptive flashcards tailored for neurodivergent users (ADHD, Autism, Dyslexia) and audio-based learning.

===================================================================================

AnyBase App Business Pitch: https://youtu.be/AJpDsLtV8Rc

AnyBase App Demo: https://youtu.be/A4DgnyQfWiY

===================================================================================

File: AnyBase.apk -> Install on Android device or emulator
Recommended: Android Emulator (preconfigured networking)

System Architecture -> The application requires 3 components:
  1. Mobile App (APK)
  2. Backend Server (Spring Boot)
  3. Local AI Model (Ollama)

**IMPORTANT**: The APK does NOT work standalone. Backend + AI model are required.

HOW TO RUN:

1. Install Ollama
     https://ollama.com/

2. Pull the required model (example):
     ollama pull llama3

3. Start Ollama
     ollama run llama3
   
**IMPORTANT**: In case of using another AI model, the "api-key","url" and "model" fields in application.yaml will need to be changed promptly to which model/from which api/with what url.
===================================================================================

4. Run Backend (Spring Boot)

Navigate to:
  anybase_backend/

Run:
  ./mvnw spring-boot:run

OR from IDE:
  Run AnybaseApplication.java

Server will start on:
  http://localhost:8080

===================================================================================

5. Run the Mobile App

OPTION A (Recommended – Emulator):
  - Use Android Emulator
  - Install and open app-release.apk
  - Works directly (uses 10.0.2.2 → localhost)

OPTION B (Physical Phone):
  - Connect phone to same Wi-Fi as your PC
  - Find your IPv4 using:
  ipconfig

  - Modify in Flutter:
  ApiService.dart:
  
    Replace:
    http://10.0.2.2:8080/api

    With:
    http://YOUR_IP:8080/api (ex. http://192.168.1.153:8080/api)

  - Rebuild APK if needed
===================================================================================
 IMPORTANT NOTES

- Backend MUST be running before opening the app
- Ollama MUST be running with the correct model
- Without backend → app will show network error

===================================================================================
 
 Key Features

- ADHD Mode → micro-learning, high focus cards
- Autism Mode → literal, structured content
- Dyslexia Mode → simplified, readable text + font
- Audio Mode → TTS-friendly segmentation
- Offline Library
- Light/Dark Mode Toggle
