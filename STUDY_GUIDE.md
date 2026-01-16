# 🛡️ The Hacker's Guide to Network Blocking & Protocols
*From "Magic Commands" to Deep Understanding*

This guide breaks down the "Porn Blocker" project we built into core networking concepts. It explains **why** we used specific tools, **how** the protocols work, and **where** else you can use these skills (Cybersecurity, DevOps, Backend Engineering).

---

## 📚 Module 1: The Phonebook of the Internet (DNS)

### The Concept
Computers don't know what `google.com` is. They only know IP addresses like `142.250.190.46`.
**DNS (Domain Name System)** is the system that translates names to numbers.

### What We Did
We used **DNS Sinkholing**.
1.  **Normal**: You ask "Where is pornhub.com?" -> DNS says "66.254.114.41".
2.  **Our Hack**: You ask "Where is pornhub.com?" -> Our DNS says "0.0.0.0".
3.  **Result**: Your computer tries to call "0.0.0.0" (which means "this computer") and fails.

### The Commands & Tools
*   **`dig`**: The #1 tool for debugging DNS.
    *   `dig google.com` -> Ask default DNS.
    *   `dig @127.0.0.1 google.com` -> Ask a *specific* server (our localhost blocker).
    *   **Skill**: Used by Site Reliability Engineers (SREs) to debug why a website is down.
*   **`dnsmasq`**: A lightweight DNS server.
    *   `address=/domain/0.0.0.0`: The config line that tells it to lie about an address.
    *   **Skill**: Used in routers (OpenWRT), Docker containers, and Kubernetes to manage internal networks.

### Real World Application
*   **Ad Blockers**: Pi-hole uses this exact same method to block ads for your whole house.
*   **Malware Protection**: Companies block "Command & Control" servers so infected laptops can't talk to hackers.

---

## 🚦 Module 2: The Traffic Cop (Proxy & Squid)

### The Concept
A **Proxy** stands between you and the internet. You talk to the proxy, and the proxy talks to the website.
*   **Forward Proxy**: Protects the client (You). "I want to visit X, but don't let X know who I am, or block X if it's bad."
*   **Reverse Proxy**: Protects the server (Google). "I am Google, but I'm actually just a guard checking your password before letting you in."

### What We Did
We set up **Squid** as a Forward Proxy.
*   **ACL (Access Control List)**: Rules for who gets in.
    *   `acl localnet src 192.168.0.0/16`: "If the request comes from the local network..."
    *   `http_access allow localnet`: "...let it pass."
    *   `http_access deny porn_domains`: "...unless it's on the bad list."

### The Commands & Tools
*   **`curl`**: The Swiss Army knife of HTTP.
    *   `curl -x http://localhost:3128 http://example.com`: "Fetch example.com using my proxy."
    *   **Skill**: Essential for Backend Developers testing APIs.
*   **`systemctl`**: The manager of Linux services.
    *   `systemctl restart squid`: "Turn it off and on again."
    *   **Skill**: Linux System Administration (SysAdmin) 101.

### Real World Application
*   **Corporate Firewalls**: Why you can't access Facebook at work.
*   **Caching**: ISPs use proxies to save bandwidth (download a Netflix movie once, serve it to 100 neighbors).

---

## 🔒 Module 3: The Unbreakable Lock (Linux Permissions)

### The Concept
Linux is built on permissions: **Read (r)**, **Write (w)**, **Execute (x)**.
But `root` (the admin) can ignore these. So how do we stop `root` (or a script running as root) from deleting our blocker?

### What We Did
We used **File Attributes**, a deeper layer than permissions.
*   **`chattr +i filename`**: Sets the **Immutable** bit.
    *   Even `rm -rf filename` will fail!
    *   Even `sudo` cannot write to it.
    *   You must run `chattr -i` to unlock it first.

### The Commands & Tools
*   **`chmod +x script.sh`**: "Make this text file executable as a program."
*   **`chown root:root file`**: "This file belongs to the King (root)."
*   **`ls -l`**: View permissions.

### Real World Application
*   **Server Security**: Protecting log files so hackers can't delete the evidence of their break-in.
*   **Database Safety**: Locking critical configuration files in production.

---

## 🤖 Module 4: Automation (Bash Scripting)

### The Concept
"If you have to do it twice, automate it."
Bash is the language of the Linux terminal.

### What We Did
We wrote `install.sh` and `update_blocklists.sh`.
*   **Variables**: `SOURCE_URL="https://..."` (Store data once, use many times).
*   **Pipes (`|`)**: `cat file | grep "bad"`. Pass the output of one command to the input of another.
*   **Redirection (`>`)**: `echo "hello" > file.txt`. Save output to a file.
*   **Awk**: `awk '{print $2}'`. A powerful tool to extract specific columns of text (like getting just the domain name from a list).

### Real World Application
*   **DevOps**: Writing CI/CD pipelines (GitHub Actions) to deploy code automatically.
*   **Data Science**: Cleaning messy text data before analyzing it.

---

## 📱 Module 5: The Android Challenge (VPNs & Packets)

### The Concept
On a phone, you don't have a terminal. You have **APIs**.
To block traffic on Android without root, you must become the network.

### The Protocol: TCP/IP & UDP
*   **IP**: The address (Where to go).
*   **TCP**: Reliable connection (Like a phone call). "Did you hear me? Okay, I'll repeat." (Websites).
*   **UDP**: Fast, fire-and-forget (Like mailing a letter). "Hope it gets there." (DNS, Gaming, Streaming).

### What You Will Do (Android)
You will use the **VPNService API**.
1.  **Intercept**: You tell Android "I am a VPN."
2.  **Inspect**: You get raw **Packets** (bytes of data).
3.  **Filter**: You look at the **Header** of the packet.
    *   "Is this UDP?" (Protocol 17)
    *   "Is destination Port 53?" (DNS)
    *   "Does the payload say 'pornhub'?"
4.  **Drop**: If yes, you throw the packet in the trash.

### Real World Application
*   **VPN Apps**: NordVPN, ExpressVPN.
*   **Firewalls**: NetGuard.
*   **Network Analysis**: Wireshark (Tool used to see every packet on a network).

---

## 🚀 Your Learning Path

1.  **Master the Terminal**: Stop using the mouse. Learn to move files, grep text, and check processes (`ps aux`, `top`) in the terminal.
2.  **Learn Networking Basics**: Watch videos on "OSI Model", "TCP vs UDP", and "DNS Resolution Process".
3.  **Build the Android App**: Start simple. Just make an app that logs every website you visit. Then add the blocking.
4.  **Cloud**: Rent a cheap Linux server ($5/mo) and try to set up this blocker there, then point your phone to it (Private DNS).

You are no longer just a "coder." You are becoming a **Systems Engineer**.
