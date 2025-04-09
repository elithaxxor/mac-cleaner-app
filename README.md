# MacCleanerApp

MacCleanerApp is a macOS application that provides a user-friendly graphical interface for performing system cleanup tasks. The app leverages a robust bash script that contains various cleanup functions (such as removing temporary files, cleaning caches, analyzing disk usage, etc.) while the SwiftUI front end invokes these routines via specific command-line arguments.

---

## What the Program Does

- **System Information:**  
  Retrieves and displays system details (OS, hardware, network configuration, disk usage, etc.) to the user.

- **Disk Usage Analysis:**  
  Analyzes various directories to report on disk usage, helping to highlight where space may be reclaimed.

- **Cleanup Operations:**  
  Provides options to clean user cache, temporary files, trash/recycle bin, logs, and other macOS-specific caches and data (such as Time Machine snapshots, mail attachments, iMessage attachments, and more).

- **Logging:**  
  All actions (operations, deletions, errors) are logged to files in the user's home directory, facilitating transparency and auditing.

---

## How It Works

1. **Bash Script Core:**  
   The `cleanup.sh` script contains all the logic for performing cleanup tasks. It is modularized so that each function (e.g., `get_system_info`, `clean_user_cache`, etc.) can be called individually by passing a command-line argument.

2. **Command Dispatcher:**  
   At the beginning of the bash script, a case statement inspects the first command-line argument and runs the corresponding cleanup function. This design allows the SwiftUI front end to invoke any desired routine directly.

3. **SwiftUI Front End:**  
   The macOS app is built using SwiftUI. It features:
   - **A Sidebar Menu:** Contains buttons for each cleanup option. When a button is clicked, the app launches the `cleanup.sh` script with the appropriate argument.
   - **A Scrollable Output Area:** Captures and displays all output from the script, so users see the results of their cleanup operations.
   - **Exit Option:** Allows the user to terminate the app gracefully.

4. **Process Integration:**  
   The app uses the `Process` API in Swift to run the bash script as a child process, redirecting its standard output and error so that results are shown in real time.

---

## Project Diagram

```mermaid

flowchart TD
    A[User Clicks Menu Option] --> B[SwiftUI Front End]
    B --> C[Launch Process (cleanup.sh)]
    C --> D[Command Dispatcher in Bash Script]
    D --> E[Run Specific Cleanup Function]
    E --> F[Log & Output Results]
    F --> B

```

Note: The diagram above (rendered with Mermaid) illustrates the overall flow of information from the user action to executing the correct cleanup function and showing the output back in the app.

⸻
```markdown
Intended Outcomes
	•	Cleaner System:
With periodic cleanup, the system should show improved performance and disk space management.
	•	User-Friendly Experience:
The graphical front end removes the need for users to interact with the terminal, making cleanup operations more accessible.
	•	Transparency and Safety:
Every operation is logged, giving the user confidence in what changes are being applied.

⸻

Future Plans
	•	Enhanced Interactivity:
Integrate confirmation dialogs and alerts directly into the SwiftUI interface to replace some text-based prompts.
	•	Progress Indicators & Graphs:
Add real-time progress bars and disk usage graphs before and after cleanup operations to give users visual feedback.
	•	Automated Scheduling:
Include an option to schedule periodic cleanups and send notifications upon completion.
	•	Extended Functionality:
Add additional cleanup functions and integration with third-party applications or cloud storage management.
	•	Improved Error Handling:
Enhance the logging and notification system to alert users in case an operation fails.

⸻

Expected Results
	•	Efficient Disk Management:
After running cleanup operations, users should see a noticeable reduction in disk usage, especially in temporary and cache files.
	•	Enhanced System Performance:
The removal of old, unused files should lead to better system responsiveness.
	•	Clear Visibility:
With detailed logs and output, users gain clear insight into what cleanups are performed and the overall effect on their system.

⸻

How to Build and Run
	1.	Clone or Download the Repository.
	2.	Open the Xcode Project:
Open MacCleanerApp.xcodeproj in Xcode.
	3.	Add the Bash Script:
Ensure cleanup.sh is in the Resources folder and added to the “Copy Bundle Resources” build phase.
	4.	Set Script Permissions:
Make sure the script is executable (e.g., run chmod +x cleanup.sh in Terminal).
	5.	Build and Run the App:
Run the project in Xcode. The SwiftUI window will appear with a sidebar menu, and pressing any option will execute the corresponding cleanup routine.
```
⸻

MacCleanerApp is designed to help users maintain a clean and efficient system with minimal hassle. Enjoy a streamlined cleanup process with a modern macOS interface!

