# 🏗️ Code Anatomy: Where Functions Live & The Rules of the Road

This guide explains **how to structure your code**. It answers the question: *"I know what I want to do, but where do I type it?"*

We will look at the two languages relevant to your project: **Bash** (for the Linux Blocker) and **Kotlin/Android** (for the Phone Blocker).

---

## 🐧 Part 1: The Rules of Bash Scripting

In Bash, the computer reads the file from **top to bottom**. This dictates where everything must live.

### 1. The Shebang (Line 1)
**Rule:** The very first line MUST tell the computer which interpreter to use.
```bash
#!/bin/bash
```
*   **Where it lives:** Line 1, always.
*   **Why:** Without this, Linux doesn't know if this is Python, Perl, or Bash.

### 2. The "Fail Fast" Checks (Line 2-10)
**Rule:** Check for requirements immediately. Don't run 50 lines of code and *then* realize you aren't root.
```bash
# Check for root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root"
  exit 1
fi
```
*   **Where it lives:** Immediately after the Shebang.
*   **Why:** Prevents partial installs or permission errors later.

### 3. Global Variables (Configuration)
**Rule:** Define "Magic Strings" (URLs, File Paths) as variables at the top.
```bash
SOURCE_URL="https://raw.github..."
CONFIG_DIR="/etc/porn-blocker"
```
*   **Where it lives:** Before any logic or functions.
*   **Why:** If you need to change the URL later, you change it in **one place** at the top, not hunting through 100 lines of code.

### 4. Functions (The "Verbs")
**Rule:** You must define a function **before** you call it.
```bash
# Define the function first
download_list() {
    echo "Downloading from $1..."
    curl -s "$1" -o temp_list.txt
}

# Call it later
download_list "$SOURCE_URL"
```
*   **Where it lives:** After variables, but before the "Main Execution".
*   **Why:** Bash reads line-by-line. If you call `download_list` on line 10, but define it on line 20, Bash will crash on line 10 saying "Command not found".

### 5. The "Main" Execution
**Rule:** The script should tell a story at the bottom.
```bash
# --- Main Execution ---
echo "Starting install..."
check_root        # Call function
download_list     # Call function
move_files        # Call function
restart_services  # Call function
echo "Done!"
```
*   **Where it lives:** At the very bottom.

---

## 📱 Part 2: The Anatomy of an Android App (Kotlin)

Android is **Event-Driven**. You don't write a script that runs top-to-bottom. You write "Handlers" that wait for the phone to do something.

### 1. The Manifest (`AndroidManifest.xml`)
**Rule:** If it's not here, it doesn't exist.
*   **What lives here:** Permissions (`INTERNET`), Services (`VpnService`), and Activities (Screens).
*   **Why:** Android OS reads this *before* installing the app to know what it does.

### 2. The Service Class (`MyVpnService.kt`)
**Rule:** This is the entry point for background tasks.
*   **Where the function lives:** `onStartCommand()`
```kotlin
override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
    // This runs when you click "Start" in the app
    startVpnThread()
    return START_STICKY
}
```

### 3. The Background Thread (The "Worker")
**Rule:** NEVER do network tasks on the Main Thread (UI Thread).
*   **Where the function lives:** Inside a `Thread` or `Coroutine`.
```kotlin
private fun runVpn() {
    // This runs in parallel to the UI
    while (isRunning) {
        // 1. Read Packet
        // 2. Check if Porn
        // 3. Block or Pass
    }
}
```
*   **Why:** If you block the Main Thread for more than 5 seconds, Android kills your app ("Application Not Responding").

### 4. The Logic Class (`DnsParser.kt`)
**Rule:** Keep the math separate from the plumbing.
*   **Where the function lives:** A separate file/class.
```kotlin
object DnsParser {
    fun getDomainName(packet: ByteBuffer): String {
        // Complex byte math goes here
        return "pornhub.com"
    }
}
```
*   **Why:** Keeps your VPN Service code clean and readable.

---

## 🎓 Summary: The "Where" Cheat Sheet

| Concept | Bash (Script) | Android (App) |
| :--- | :--- | :--- |
| **Entry Point** | Top of the file | `onCreate()` or `onStartCommand()` |
| **Configuration** | Variables at top | `res/values/strings.xml` or Constants |
| **Permissions** | `if [ root ]` check | `AndroidManifest.xml` |
| **Network Code** | `curl` command | Background Thread (Crucial!) |
| **Looping** | `for` / `while` loops | `while (true)` inside the Thread |
| **Order** | Define BEFORE calling | Order doesn't matter (Compiled) |

### Next Study Session Goal
We will take the **Logic** we wrote in Bash (download list, format list) and translate it into **Kotlin Functions** for the Android app.
