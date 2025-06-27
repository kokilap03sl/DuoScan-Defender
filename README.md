# DuoScan-Defender
An Advanced Mobile QR and Barcode Scanner for Ultimate Protection

DuoScan Defender is a secure, cross- platform mobile app designed to scan QR codes and barcodes while performing real- time threat detection using the VirusTotal API. Built using Flutter for the frontend and Node.js with MongoDB for the backend, the app offers a smooth, ad- free user experience on both Android and iOS.

Key features include:

•	Secure QR and barcode scanning

•	Real- time URL safety analysis

•	Scan history log with user education

•	Customizable filters and permission settings

•	Integrated feedback and rating system


Installation Process:

•	Prerequisites- Flutter SDK installed on your system, node.js and npm installed, all devices (PC & test phone) must be on the same Wi-Fi network

•	Steps:
1. Extract the zip file containing the project.

2. Open two VS Code windows- One for the frontend/ folder (Flutter), one for the backend/ folder (Node.js).

3. Get your PC's IP address- Open Command Prompt, type "ipconfig", copy the IPv4 address (e.g., 192.168.1.10).

4. Update the IP address in the following files:
Frontend- lib/services/api_services.dart, lib/history_log.dart, lib/user_page.dart
Backend- server/server.js (Node.js backend)

5. Install frontend dependencies using "flutter pub get"

6. In the backend terminal run "npm init -y" 

7. Then type "npm install express axios mysql2 cors dotenv express-rate-limit helmet validator" in the backend terminal.

8. Start the backend server by running the command "nodemon server.js" in the backend terminal.

9. Allow USB debugging on your phone using the following steps:

Android- Enable Developer Options by connecting your Android to your lap with a USB cable. Go to settings > about phone. Tap the build number 7 times quickly until it says you’re a developer. The go back to Settings, then open Developer options > find and toggle on USB debugging. Confirm any prompts.

iOS- Enable Developer Mode (iOS 16 and later) by connecting your iPhone to your Mac with a USB cable. On your iPhone, you may get a prompt: “Developer Mode is required to run apps from Xcode.” Go to Settings > Privacy & Security > Developer Mode. Toggle Developer Mode on. Restart your iPhone if prompted. After restart, confirm enabling Developer Mode. When you connect the iPhone to a computer, a prompt “Trust This Computer?” will appear. Tap Trust and enter your passcode.

10. Then run in your frontend terminal "flutter pub get" and then "flutter run"

11. A list of all the devices connected to your computer and the options you can select to run DuoScan Defender will appear. Select the correct device by entering the corresponding number in the terminal.  


Viewing the MongoDB Data (Admin Use Only)

•	Prerequisites- Download and install MongoDB Compass

•	Steps:
1. Use this connection string and click connect: mongodb+srv://admin:kokila_p@duoscan-defender.xrbimw6.mongodb.net/duoscan_db?retryWrites=true&w=majority&authSource=admin&appName=duoscan-defender

2. Access the duoscan_db
 
3. View, edit, or export data as needed. 


