---
title: Azure DevOps Network Diagnostic Lab (Windows + Linux Agents)  
difficulty: intermediate  
duration: "2-4 hours"  
objectives:  
  - Identify potential causes of intermittent network failures in Azure DevOps pipelines  
  - Capture essential diagnostic data on Windows and Linux self-hosted agents  
  - Verify the completeness and integrity of collected network logs  
  - Package and organize diagnostics for efficient escalation  
prerequisites:  
  - Azure DevOps project with permissions to run pipelines and manage agents  
  - One Windows and one Linux machine configured as self-hosted Azure DevOps agents  
  - Internet connectivity from the agent machines to Azure services (ARM endpoints)  
  - *(Optional)* Azure subscription with Network Watcher enabled (for advanced network diagnostics)  
---

## Executive Summary

Intermittent network failures in Azure DevOps pipelines – especially when self-hosted build agents communicate with Azure Resource Manager (ARM) endpoints – can be challenging to diagnose. This hands-on lab provides a **concise, repeatable playbook** for Azure DevOps engineers to **capture, verify, and package** all data needed to troubleshoot such issues. We will systematically gather network configuration, DNS resolution data, connectivity tests, and relevant logs from both **Windows** and **Linux** agents, with immediate verification after each step. The lab also covers organizing the collected information into a sharable bundle, enabling efficient collaboration or escalation. By completing this lab, engineers will gain a structured approach to diagnosing network connectivity problems without diving into root-cause analysis, ensuring that no critical evidence is missed before handing off to others.

<!-- Copilot-Researcher-Visualization -->
<style>
    :root {
        --accent: #464feb;
        --timeline-ln: linear-gradient(to bottom, transparent 0%, #b0beff 15%, #b0beff 85%, transparent 100%);
        --timeline-border: #ffffff;
        --bg-card: #f5f7fa;
        --bg-hover: #ebefff;
        --text-title: #424242;
        --text-accent: var(--accent);
        --text-sub: #424242;
        --radius: 12px;
        --border: #e0e0e0;
        --shadow: 0 2px 10px rgba(0, 0, 0, 0.06);
        --hover-shadow: 0 4px 14px rgba(39, 16, 16, 0.1);
        --font: "Segoe UI";
    }

    @media (prefers-color-scheme: dark) {
        :root {
            --accent: #7385ff;
            --timeline-ln: linear-gradient(to bottom, transparent 0%, transparent 3%, #6264a7 30%, #6264a7 50%, transparent 97%, transparent 100%);
            --timeline-border: #424242;
            --bg-card: #1a1a1a;
            --bg-hover: #2a2a2a;
            --text-title: #ffffff;
            --text-sub: #ffffff;
            --shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
            --hover-shadow: 0 4px 14px rgba(0, 0, 0, 0.5);
            --border: #3d3d3d;
        }
    }

    @media (prefers-contrast: more),
    (forced-colors: active) {
        :root {
            --accent: ActiveText;
            --timeline-ln: ActiveText;
            --timeline-border: Canvas;
            --bg-card: Canvas;
            --bg-hover: Canvas;
            --text-title: CanvasText;
            --text-sub: CanvasText;
            --shadow: 0 2px 10px Canvas;
            --hover-shadow: 0 4px 14px Canvas;
            --border: ButtonBorder;
        }
    }

    .insights-container {
        display: grid;
        grid-template-columns: repeat(2,minmax(240px,1fr));
        padding: 0px 16px 0px 16px;
        gap: 16px;
        margin: 0 0;
        font-family: var(--font);
    }

    .insight-card:last-child:nth-child(odd){
        grid-column: 1 / -1;
    }

    .insight-card {
        background-color: var(--bg-card);
        border-radius: var(--radius);
        border: 1px solid var(--border);
        box-shadow: var(--shadow);
        min-width: 220px;
        padding: 16px 20px 16px 20px;
    }

    .insight-card:hover {
        background-color: var(--bg-hover);
    }

    .insight-card h4 {
        margin: 0px 0px 8px 0px;
        font-size: 1.1rem;
        color: var(--text-accent);
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .insight-card .icon {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 20px;
        height: 20px;
        font-size: 1.1rem;
        color: var(--text-accent);
    }

    .insight-card p {
        font-size: 0.92rem;
        color: var(--text-sub);
        line-height: 1.5;
        margin: 0px;
    }

    .insight-card p b, .insight-card p strong {
        font-weight: 600;
    }

    .metrics-container {
        display:grid;
        grid-template-columns:repeat(2,minmax(210px,1fr));
        font-family: var(--font);
        padding: 0px 16px 0px 16px;
        gap: 16px;
    }

    .metric-card:last-child:nth-child(odd){
        grid-column:1 / -1; 
    }

    .metric-card {
        flex: 1 1 210px;
        padding: 16px;
        background-color: var(--bg-card);
        border-radius: var(--radius);
        border: 1px solid var(--border);
        text-align: center;
        display: flex;
        flex-direction: column;
        gap: 8px;
    }

    .metric-card:hover {
        background-color: var(--bg-hover);
    }

    .metric-card h4 {
        margin: 0px;
        font-size: 1rem;
        color: var(--text-title);
        font-weight: 600;
    }

    .metric-card .metric-card-value {
        margin: 0px;
        font-size: 1.4rem;
        font-weight: 600;
        color: var(--text-accent);
    }

    .metric-card p {
        font-size: 0.85rem;
        color: var(--text-sub);
        line-height: 1.45;
        margin: 0;
    }

    .timeline-container {
        position: relative;
        margin: 0 0 0 0;
        padding: 0px 16px 0px 56px;
        list-style: none;
        font-family: var(--font);
        font-size: 0.9rem;
        color: var(--text-sub);
        line-height: 1.4;
    }

    .timeline-container::before {
        content: "";
        position: absolute;
        top: 0;
        left: calc(-40px + 56px);
        width: 2px;
        height: 100%;
        background: var(--timeline-ln);
    }

    .timeline-container > li {
        position: relative;
        margin-bottom: 16px;
        padding: 16px 20px 16px 20px;
        border-radius: var(--radius);
        background: var(--bg-card);
        border: 1px solid var(--border);
    }

    .timeline-container > li:last-child {
        margin-bottom: 0px;
    }

    .timeline-container > li:hover {
        background-color: var(--bg-hover);
    }

    .timeline-container > li::before {
        content: "";
        position: absolute;
        top: 18px;
        left: -40px;
        width: 14px;
        height: 14px;
        background: var(--accent);
        border: var(--timeline-border) 2px solid;
        border-radius: 50%;
        transform: translateX(-50%);
        box-shadow: 0px 0px 2px 0px #00000012, 0px 4px 8px 0px #00000014;
    }

    .timeline-container > li h4 {
        margin: 0 0 5px;
        font-size: 1rem;
        font-weight: 600;
        color: var(--accent);
    }

    .timeline-container > li * {
        margin: 0;
        font-size: 0.9rem;
        color: var(--text-sub);
        line-height: 1.4;
    }

    .timeline-container > li * b, .timeline-container > li * strong {
        font-weight: 600;
    }

    @media (max-width:600px){
      .metrics-container,
      .insights-container{
        grid-template-columns:1fr;
      }
    }
</style>
<div class="insights-container">
  <div class="insight-card">
    <h4>Data Source Mapping</h4>
    <p>Identify each likely failure point (DNS, firewall, routing, service health, agent config) and map it to logs or commands that reveal its status.</p>
  </div>
  <div class="insight-card">
    <h4>Comprehensive Collection</h4>
    <p>Execute step-by-step instructions (Windows & Linux) to collect network info, agent logs, and Azure-side data (NSG flow logs, Connection Monitor, DNS metrics) for a full picture.</p>
  </div>
  <div class="insight-card">
    <h4>Immediate Verification</h4>
    <p>Perform quick sanity checks (file existence, log snippets, command output) after each data capture to confirm the information is complete and uncorrupted before moving on.</p>
  </div>
  <div class="insight-card">
    <h4>Packaging & Handoff</h4>
    <p>Organize all findings in a structured folder with timestamps and a README. This bundle can be zipped and attached to support tickets for seamless collaboration.</p>
  </div>
  <div class="insight-card">
    <h4>Focused Analysis</h4>
    <p>Limit analysis to confirming capture success (e.g. “DNS response received, size X bytes”) without attempting to solve the issue, keeping the investigation unbiased and data-driven.</p>
  </div>
</div>

**What "Success" Looks Like:**  
| Focus Area                      | Outcome                                                                                                                                                                      |
| ------------------------------  | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Discovery of data sources**   | A checklist mapping each likely failure surface (DNS, firewall, routing, service health, agent config) to the exact logs, commands, or Azure Monitor signals that reveal it.   |
| **Step-by-step collection**     | Copy-and-paste commands for Windows *and* Linux agents, plus pointers for portal-side artifacts (NSG flow logs, Connection Monitor runs, DNS resolver metrics).               |
| **Verification**                | Fast sanity checks—hash totals, sample queries, or one-line `grep`/`Select-String` commands—to confirm each capture is complete and uncorrupted *before* escalation.           |
| **Packaging for collaboration** | A ready-made folder structure & README template teams can zip and attach to tickets, including timestamps and environment metadata.                                            |
| **Minimal analysis**            | Only enough interpretation to confirm the capture succeeded (e.g., “DNS response seen, size = ... bytes”)—deep root-cause analysis is out-of-scope at this stage.             |

> **Prerequisites:** This lab assumes you have access to an **Azure DevOps organization** with a project where you can run pipelines and manage service connections. You should have one **Windows** machine and one **Linux** machine registered as **self-hosted agents** for your project. Both agents need outbound Internet connectivity to Azure (specifically, the ability to reach Azure Resource Manager endpoints). Basic familiarity with command-line operations on Windows and Linux is required. Optionally, having an **Azure subscription** with **Network Watcher** enabled is beneficial for using advanced diagnostics (like Connection Monitor and NSG flow logs), though not strictly necessary for the core lab steps.

## Lab Exercises

In this lab, you will perform a series of steps to collect and verify diagnostic information from both a Windows-based and a Linux-based Azure DevOps agent machine. Each step provides commands for both operating systems, along with a ✅ **Verify** instruction to validate the results. By the end, you will package the collected data for analysis or escalation.

### Step 1: Prepare Environment & Collect System Info

Intermittent network issues can be influenced by the agent’s environment. We start by gathering basic system and network configuration details on each agent, and setting up a folder structure to store all diagnostics.

- **1.1 Create a Diagnostics Folder:** On each agent machine, create a dedicated directory to store logs and outputs collected during this lab. For consistency, use a path like `~/Diagnostics/NetworkLab` on Linux and `C:\Diagnostics\NetworkLab` on Windows.

   **Windows (PowerShell):**
   ```powershell
   New-Item -Path C:\Diagnostics\NetworkLab -ItemType Directory -Force
   New-Item -Path C:\Diagnostics\NetworkLab\System -ItemType Directory -Force
   New-Item -Path C:\Diagnostics\NetworkLab\Network -ItemType Directory -Force
   New-Item -Path C:\Diagnostics\NetworkLab\DNS -ItemType Directory -Force
   New-Item -Path C:\Diagnostics\NetworkLab\AgentLogs -ItemType Directory -Force
   ```
   ✅ **Verify:** Ensure the `C:\Diagnostics\NetworkLab` folder now exists with `System`, `Network`, `DNS`, and `AgentLogs` subfolders (`Get-ChildItem C:\Diagnostics\NetworkLab` should list these subdirectories).

   **Linux (Bash):**
   ```bash
   mkdir -p ~/Diagnostics/NetworkLab/{System,Network,DNS,AgentLogs}
   ```
   ✅ **Verify:** Check that the `~/Diagnostics/NetworkLab` directory and the `System`, `Network`, `DNS`, `AgentLogs` subdirectories were created (run `ls ~/Diagnostics/NetworkLab` and confirm the folder names).

- **1.2 System Information:** Gather detailed system info for each agent. This helps in understanding the OS version, system architecture, and hardware resources, which can provide context (e.g., knowing if the OS is up to date or if there are resource constraints that might indirectly cause network issues).

   **Windows (PowerShell):**
   ```powershell
   systeminfo | Out-File C:\Diagnostics\NetworkLab\System\windows_systeminfo.txt
   ```
   *Alternative:* You can also use `Get-ComputerInfo > C:\Diagnostics\NetworkLab\System\windows_systeminfo.txt` on newer PowerShell versions for a more structured output[1](https://learn.microsoft.com/en-us/azure/devops/pipelines/troubleshooting/review-logs?view=azure-devops). Both commands may require a few seconds to run.

   ✅ **Verify:** Open or type the beginning of the `windows_systeminfo.txt` file (`Get-Content C:\Diagnostics\NetworkLab\System\windows_systeminfo.txt | Select-Object -First 5`) and ensure it contains system details (OS Name, Version, etc.).

   **Linux (Bash):**
   ```bash
   uname -a > ~/Diagnostics/NetworkLab/System/linux_uname.txt
   lsb_release -a >> ~/Diagnostics/NetworkLab/System/linux_uname.txt 2>/dev/null
   ```
   *Note:* The second command (`lsb_release`) captures Linux distribution details (if the system has `lsb_release` installed; it’s present on Ubuntu/Debian by default). The `2>/dev/null` part ignores errors in case `lsb_release` isn't available.

   ✅ **Verify:** View the `linux_uname.txt` file (`head -n 5 ~/Diagnostics/NetworkLab/System/linux_uname.txt`). It should show the kernel version and possibly the distribution info (e.g., Ubuntu release number). For example, you might see a line with `Linux <hostname> <kernel-version> ...` from `uname -a`, and distribution info from `lsb_release`.

- **1.3 Network Configuration:** Collect information about network interfaces, IP configuration, and DNS settings on each machine. Misconfigurations or unexpected settings here can lead to connectivity problems (e.g., wrong DNS server or IP address conflicts).

   **Windows (PowerShell):**
   ```powershell
   ipconfig /all | Out-File C:\Diagnostics\NetworkLab\Network\windows_ipconfig.txt
   ```
   This captures the IP addresses, DNS servers, gateway, and NIC details for the Windows agent.

   ✅ **Verify:** Open the first few lines of the output (`Select-String "IPv4 Address" C:\Diagnostics\NetworkLab\Network\windows_ipconfig.txt`) to ensure an IPv4 address is listed for the active adapter. Also verify the DNS Servers listed match your expected network configuration.

   **Linux (Bash):**
   ```bash
   ifconfig -a > ~/Diagnostics/NetworkLab/Network/linux_ifconfig.txt 2>/dev/null || ip addr show > ~/Diagnostics/NetworkLab/Network/linux_ifconfig.txt
   printf "\nDNS Configuration:\n" >> ~/Diagnostics/NetworkLab/Network/linux_ifconfig.txt
   cat /etc/resolv.conf >> ~/Diagnostics/NetworkLab/Network/linux_ifconfig.txt
   ```
   This command tries `ifconfig` (older tool) and falls back to `ip addr show` if needed, then appends DNS resolver settings from `/etc/resolv.conf`. (Most Linux distros list current DNS servers in that file.)

   ✅ **Verify:** Open `linux_ifconfig.txt` (`head -n 15 ~/Diagnostics/NetworkLab/Network/linux_ifconfig.txt`) and confirm it contains IP address information for the network interface(s). Scroll or search within the file for lines like `inet ` (for IPv4) or `inet6` (for IPv6) addresses. Also check that DNS nameserver entries (from `resolv.conf`) are present under a "DNS Configuration" section.

- **1.4 Firewall Status:** Determine if the local firewall is enabled and if it might be blocking outbound traffic. A host-based firewall could intermittently block connections if not configured properly.

   **Windows (PowerShell):**
   ```powershell
   Get-NetFirewallProfile -All | Select-Object Name, Enabled | Out-File C:\Diagnostics\NetworkLab\Network\windows_firewall.txt
   ```
   This will list each firewall profile (Domain, Private, Public) and whether it’s enabled (True/False).

   ✅ **Verify:** Open `windows_firewall.txt` and ensure it shows the status of each profile. For example, you might see `Domain  True/False`, etc. If the profile corresponding to your network (likely Domain or Private for enterprise networks) is enabled, outbound rules could affect connectivity. Save this info for later analysis.

   **Linux (Bash):**
   ```bash
   sudo iptables -L -v -n > ~/Diagnostics/NetworkLab/Network/linux_iptables.txt
   ```
   This lists firewall rules if the system uses iptables. On systems with `ufw` (Ubuntu’s Uncomplicated Firewall) or `firewalld` (CentOS/Fedora), you could use `sudo ufw status verbose` or `sudo firewall-cmd --list-all` respectively. Adjust as needed for your distribution.

   ✅ **Verify:** Check `linux_iptables.txt` for any rules. If the file is empty or shows default policies as ACCEPT (and no specific DROP rules for outbound traffic), the Linux firewall is likely not blocking egress. If using `ufw` or others, verify their status outputs similarly. (If unsure, note it down and proceed; the key is to document whatever firewall state exists.)

By the end of Step 1, you should have basic environment and network configuration data for both agents saved in your `NetworkLab` folder (under `System` and `Network` subfolders). This establishes a baseline and captures any obvious misconfigurations early.

### Step 2: DNS Resolution and Service Reachability

DNS issues are a common cause of intermittent connectivity problems. If an agent occasionally fails to resolve the ARM endpoint, that could explain intermittent failures. In this step, we’ll test DNS name resolution and basic network reachability to Azure Resource Manager endpoints from each agent.

- **2.1 DNS Lookup for ARM Endpoint:** Test the DNS resolution of the Azure Resource Manager endpoint (typically `management.azure.com`) from each agent.

   **Windows (PowerShell):**
   ```powershell
   Resolve-DnsName management.azure.com | Out-File C:\Diagnostics\NetworkLab\DNS\windows_dns.txt
   ```
   This uses the Windows DNS client to resolve the name. It should return one or more IP addresses for `management.azure.com`.

   ✅ **Verify:** Open `windows_dns.txt` and look for an “Answer” section with an IP address. For example, it might show a record like `management.azure.com.  -> <IP_ADDRESS>`. If the resolution fails or times out, that indicates a DNS problem. If multiple DNS servers are configured on the machine, the output will show which server responded.

   **Linux (Bash):**
   ```bash
   dig +ANSWER management.azure.com > ~/Diagnostics/NetworkLab/DNS/linux_dns.txt
   ```
   *Alternative:* If `dig` is not installed, use `nslookup management.azure.com` instead. The `+ANSWER` flag in dig outputs only the answer section for brevity.

   ✅ **Verify:** Check `linux_dns.txt` for one or more IP addresses corresponding to `management.azure.com`. For instance, you should see an `ANSWER SECTION` with A record(s). Note whether the response is quick and successful – any delays or failures here suggest DNS issues.

- **2.2 Connectivity Test (Ping/Port Check):** Now verify network connectivity to the ARM endpoint. Many Azure endpoints do not respond to ICMP (ping), but we can still check if the TCP port 443 is reachable.

   **Windows (PowerShell):**
   ```powershell
   Test-NetConnection -ComputerName management.azure.com -Port 443 | Out-File C:\Diagnostics\NetworkLab\Network\windows_connectivity.txt
   ```
   This command attempts a TCP connection on port 443 (HTTPS) to the specified host. It will report `TcpTestSucceeded: True` if the connection was established. It also outputs the resolved IP and the latency.

   ✅ **Verify:** Open `windows_connectivity.txt` and find the `TcpTestSucceeded` line. If it says `True`, the agent can reach the ARM endpoint on port 443. Also note the `PingSucceeded` (which might be false if ICMP is blocked) and the `RoundtripTime` if available. If `TcpTestSucceeded` is False, the agent couldn’t connect at that moment – this could indicate a network block or issue.

   **Linux (Bash):**
   ```bash
   ping -c 4 management.azure.com > ~/Diagnostics/NetworkLab/Network/linux_ping.txt 2>&1
   ```
   Then, to specifically test the port (since ping may not get replies):
   ```bash
   echo | timeout 5 nc -vz management.azure.com 443 > ~/Diagnostics/NetworkLab/Network/linux_port443.txt 2>&1
   ```
   Here we use `nc` (netcat) to attempt a connection to port 443. We pipe `echo` to `nc` to immediately close after connecting, and use `timeout 5` to avoid hanging too long. If the connection is successful, `nc` will report "succeeded" or show the TLS handshake. If it fails, it will report an error.

   ✅ **Verify:** Examine `linux_ping.txt`. Even if Azure dropped ping, the file will show if DNS resolved (ping will list the IP it’s trying to ping). Next, check `linux_port443.txt`. A successful connection will typically contain something like `management.azure.com [<IP>] 443 (https) open` or an SSL handshake message. If you see "open", it means the TCP connection succeeded. If it says "Connection timed out" or "Host unreachable", the agent could not reach the endpoint on that port at that time.

- **2.3 Azure Service URL Access (Optional):** As an extra verification, you can try to perform an HTTPS request to the ARM endpoint. We don’t expect to get data without proper authentication, but getting an HTTP **status code** response (even 401 Unauthorized) confirms end-to-end connectivity including TLS handshake.

   **Windows (PowerShell):**
   ```powershell
   try { Invoke-WebRequest -Uri "https://management.azure.com/subscriptions?api-version=2020-01-01" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop } catch { $_.Exception.Response.StatusCode | Out-File C:\Diagnostics\NetworkLab\Network\windows_http_status.txt }
   ```
   This tries a simple Azure REST API call (listing subscriptions) with no auth, expecting a 401. We capture the HTTP status code from the exception. Ensure you have PowerShell 5+ for `Invoke-WebRequest -UseBasicParsing`.

   ✅ **Verify:** Open `windows_http_status.txt`. It should contain `Unauthorized` or status code `401` if the request reached Azure (which is good – it means the networking is fine, we just aren’t authorized, as expected). If it shows a different error (e.g., *Name or service not known* or *Request timed out*), that indicates a network problem rather than a successful connectivity test.

   **Linux (Bash):**
   ```bash
   curl -I https://management.azure.com/subscriptions?api-version=2020-01-01 -m 10 -o ~/Diagnostics/NetworkLab/Network/linux_http_head.txt -w "%{http_code}" 2>~/Diagnostics/NetworkLab/Network/linux_http_error.txt
   ```
   This cURL command attempts the same request, writing the headers to `linux_http_head.txt` and capturing the HTTP status code in the output. It uses a 10-second timeout.

   ✅ **Verify:** Check `linux_http_head.txt` for any HTTP response headers. If connectivity is successful, you should see response headers like `WWW-Authenticate: Bearer` (indicating Azure is asking for a token) and an HTTP/1.1 401 status line. The HTTP status code output (which was written to console by `%{http_code}`) can be seen by opening `linux_http_error.txt` to ensure no network errors were logged. A `401` or `HTTP/1.1 401 Unauthorized` confirms that the agent reached the service (expected outcome since no credentials were provided). Any other result (such as no response or an SSL error) would hint at network issues.

At this stage, you have confirmed whether **DNS resolution** and **basic network connectivity** to Azure Resource Manager are working from each agent. If these tests passed (names resolve and port 443 is reachable), the intermittent issue might lie elsewhere. If any of these tests failed or were flaky (e.g. DNS sometimes resolving slowly or certain pings failing), keep these observations as they might correlate with the pipeline failures.

### Step 3: Route & Network Path Diagnostics

Understanding the network path from the agent to Azure can reveal issues like routing loops or intermediate drops (for example, a specific hop intermittently failing). In this step, we run traceroute and examine routing configurations. We’ll also gather any network-specific logs on the agent (like Azure Network Watcher logs, if applicable).

- **3.1 Traceroute to Azure Endpoint:** Perform a traceroute from each agent to see the path taken to reach Azure’s ARM service. This can show if traffic is going through a proxy, VPN, or encountering a problematic hop.

   **Windows (Command Prompt via PowerShell):**
   ```powershell
   tracert -d management.azure.com | Out-File C:\Diagnostics\NetworkLab\Network\windows_traceroute.txt
   ```
   The `-d` flag avoids resolving intermediate hop IPs to names (faster output). Running `tracert` from PowerShell will launch the command-prompt tool and pipe output back.

   ✅ **Verify:** Open `windows_traceroute.txt`. You should see a list of hops (lines numbered 1, 2, 3, ...) showing the route. If the traceroute reaches an Azure edge, one of the last hops may mention azure or have an IP known to Azure’s range. If some hops show `* * * Request timed out` intermittently, that hop doesn’t respond to traceroute probes (common for certain network devices) – not necessarily a failure, unless it’s the final target. Ensure the trace either completes to the destination or gets close (Azure may not respond at the final endpoint but prior hops should show progress).

   **Linux (Bash):**
   ```bash
   traceroute -n management.azure.com > ~/Diagnostics/NetworkLab/Network/linux_traceroute.txt 2>&1 || tracepath management.azure.com > ~/Diagnostics/NetworkLab/Network/linux_traceroute.txt 2>&1
   ```
   This tries `traceroute` and falls back to `tracepath` if needed. The `-n` option in traceroute prevents DNS lookups for speed.

   ✅ **Verify:** View `linux_traceroute.txt`. Similar to Windows, you’ll see the hops. Ensure multiple hops are listed. If the traceroute doesn’t complete, note where it stops. Consistent failures at a certain hop might indicate an issue at or beyond that network node. Save this information for correlation (e.g., if always failing at hop 5, is that hop part of your corporate network or ISP?).

- **3.2 Check Route Tables (Optional):** If the agent is in a complex network (such as behind multiple routers or in Azure vNet with user-defined routes), it’s useful to capture the routing table.

   **Windows (PowerShell):**
   ```powershell
   route print > C:\Diagnostics\NetworkLab\Network\windows_routes.txt
   ```
   This lists the IPv4 and IPv6 routing table entries on the Windows machine.

   ✅ **Verify:** Open `windows_routes.txt`. Look for the default route (usually `0.0.0.0` in the IPv4 table) to confirm which gateway is used. If multiple default routes or unusual entries exist (like persistent routes to specific Azure IP ranges), note them as they could influence connectivity.

   **Linux (Bash):**
   ```bash
   ip route show > ~/Diagnostics/NetworkLab/Network/linux_routes.txt
   ```
   This shows the current routing table on Linux.

   ✅ **Verify:** Check `linux_routes.txt` for the default route (look for a line starting with `default via`). Ensure it points to the expected gateway (likely your local router or cloud VM gateway). If there are any routes specifically for Azure IP ranges or unusual static routes, they will be listed here.

- **3.3 Network Watcher & NSG Logs (Conditional):** If your agent VM is in Azure and you have https://learn.microsoft.com/azure/network-watcher enabled, you can leverage its tools:
   - **Connection Troubleshoot:** You could run a connectivity check from the Azure portal or via Azure CLI to test reaching `management.azure.com` from the VM’s perspective.[2](https://learn.microsoft.com/en-us/answers/questions/2260076/best-practices-for-preventing-and-mitigating-inter)[3](https://cloudopszone.com/how-to-troubleshoot-using-azure-network-watcher-connection-troubleshoot/) This can detect NSG (Network Security Group) or UDR issues by analyzing the path.
   - **NSG Flow Logs:** If the agent’s subnet has NSG flow logging to Azure Storage or Log Analytics, retrieve the logs around the time of failures to see if traffic was allowed/denied. (This is advanced; ensure you have permission to view these logs. They can show all outbound flows and their statuses[2](https://learn.microsoft.com/en-us/answers/questions/2260076/best-practices-for-preventing-and-mitigating-inter).)
   - **Azure Firewall or Proxy Logs:** If the agent’s traffic goes through an Azure Firewall or on-premises proxy, those logs should be checked for blocked requests corresponding to the ARM calls.

   *These actions are typically done through Azure Portal or Azure CLI and may be outside the scope of this lab environment.* If available, document any findings from these external diagnostics in a text file (e.g., `Network/azure_nsg_flow_logs_summary.txt` summarizing what you found). For instance, note if NSG logs show drops for the agent’s IP, or if Connection Monitor reports a specific hop as problematic.

   ✅ **Verify:** Ensure any external log data you collected is saved to the Diagnostics folder. Even if this section is optional, having a record (even “Checked NSG logs - all clear”) is valuable for completeness.

By the end of Step 3, you should have a clear picture of the network path and routing from the agents to Azure. We’ve also set the stage for identifying if network devices or policies could be intermittently interfering (e.g., a certain router dropping traffic occasionally, or a firewall applying rate limits). If the issue tends to occur at certain times or conditions, you might compare multiple traceroutes or note if, for example, DNS resolution sometimes points to different IPs (which can happen with anycast services).

### Step 4: Collect Agent Logs & Diagnostics

When network issues occur, Azure DevOps agent logs and system logs can provide hints or at least timestamps of failures. In this step, we will collect the Azure Pipelines agent logs and any relevant system event logs around networking.

- **4.1 Azure Pipelines Agent Logs:** The self-hosted agent writes diagnostic logs to the `_diag` folder in its installation directory[4](https://github.com/microsoft/azure-pipelines-agent/blob/master/docs/troubleshooting.md). These logs include the agent’s communication with Azure DevOps and can show if the agent experienced disconnects or errors (for example, the “We stopped hearing from agent...” error)[5](https://stackoverflow.com/questions/66134088/azure-devops-self-hosted-agent-error-connectivity-issues)[5](https://stackoverflow.com/questions/66134088/azure-devops-self-hosted-agent-error-connectivity-issues). We will copy the latest agent log and any recent worker log.

   **Windows (PowerShell):**
   ```powershell
   # Set the path to your agent installation directory
   $AgentDir = "C:\agent"   # (Replace with actual path if different)
   Copy-Item -Path "$AgentDir\_diag\Agent_*.log" -Destination C:\Diagnostics\NetworkLab\AgentLogs\ -Force
   Copy-Item -Path "$AgentDir\_diag\Worker_*.log" -Destination C:\Diagnostics\NetworkLab\AgentLogs\ -Force
   ```
   This assumes your agent is installed in `C:\agent`. Adjust `$AgentDir` if not (e.g., `C:\AzureDevOpsAgent\` or other custom path). We copy all Agent and Worker logs for completeness. The Agent logs cover the agent listener process (running as a service), and Worker logs cover individual pipeline job runs[4](https://github.com/microsoft/azure-pipelines-agent/blob/master/docs/troubleshooting.md).

   ✅ **Verify:** List the files in `C:\Diagnostics\NetworkLab\AgentLogs` (`Get-ChildItem C:\Diagnostics\NetworkLab\AgentLogs`). You should see files like `Agent_<timestamp>.log` (one or more) and possibly `Worker_<timestamp>.log`. Open the most recent Agent log (`Select-String "ERROR" C:\Diagnostics\NetworkLab\AgentLogs\Agent_*.log`) and see if any errors or warnings are present. Also search for keywords like "Network" or "connection" around the time of known failures. Even if you don’t analyze deeply, confirm the logs have content (not zero-byte files).

   **Linux (Bash):**
   ```bash
   # Set the path to your agent installation directory
   AGENT_DIR="$HOME/azure-pipelines-agent"   # (Replace with actual path if different)
   cp $AGENT_DIR/_diag/Agent_*.log ~/Diagnostics/NetworkLab/AgentLogs/ 2>/dev/null
   cp $AGENT_DIR/_diag/Worker_*.log ~/Diagnostics/NetworkLab/AgentLogs/ 2>/dev/null
   ls -l ~/Diagnostics/NetworkLab/AgentLogs/ > ~/Diagnostics/NetworkLab/AgentLogs/ls_agentlogs.txt
   ```
   Replace `AGENT_DIR` with the actual path where the agent is installed (for example `/mnt/agent`, `/home/<user>/myagent`, etc., depending on how you set it up). The `ls -l` command writes a directory listing to confirm which logs were copied.

   ✅ **Verify:** Check the `ls_agentlogs.txt` listing to see the copied log files. Use `grep "ERROR" ~/Diagnostics/NetworkLab/AgentLogs/Agent_*.log -C3` to see any error lines with a few lines of context. Also consider searching for the string "Job" or "Handshake" to see if there were connection attempts logged. A healthy agent log will show periodic successful communications; if there were network interruptions, you might see error entries or reconnect attempts around those times[5](https://stackoverflow.com/questions/66134088/azure-devops-self-hosted-agent-error-connectivity-issues).

   *Note:* If your agent is running as a service, ensure the user running these copy commands has permission to read the agent’s folder (you might need to `sudo` on Linux or open an Administrator PowerShell on Windows).

- **4.2 System Event Logs (Windows-specific):** Check Windows Event Viewer for any network-related errors around the times of failure. For example, look at System logs for NIC disconnects or DNS client events.

   **Windows (PowerShell):**
   ```powershell
   Get-WinEvent -FilterHashtable @{LogName="System"; StartTime=(Get-Date).AddDays(-1)} | ` 
       Where-Object {$_.Message -match "TCPIP" -or $_.Message -match "DNS" -or $_.Message -match "Network"} | `
       Export-Csv C:\Diagnostics\NetworkLab\AgentLogs\windows_system_events.csv -NoTypeInformation
   ```
   This fetches events from the System log in the last day (adjust time as needed) and filters for keywords "TCPIP", "DNS", or "Network". The output is saved as a CSV for readability.

   ✅ **Verify:** Open the CSV (it can be opened in Excel or a text editor). Look for events that coincide with your pipeline failure times. For instance, DNS client events (event ID 1014) could indicate name resolution issues; network link down/up events could indicate connectivity blips.

   **Linux:** System logs (like `/var/log/syslog` or `/var/log/messages`) might contain relevant info (e.g., DHCP renewals, DNS errors). If you suspect issues, you can search those logs similarly:
   ```bash
   sudo grep -Ei "dns|network|eth|tcp" /var/log/syslog > ~/Diagnostics/NetworkLab/AgentLogs/linux_syslog_snippet.txt
   ```
   (The exact log file and interface keywords might differ by distro.) This step is optional and for thoroughness.

   ✅ **Verify:** Check `linux_syslog_snippet.txt` for timestamps that match failures, or any recurring network error messages (like `named`/`systemd-resolved` errors for DNS, or `Link is Down/Up` for interface flaps).

- **4.3 Agent Diagnostic Mode (Optional):** Azure Pipelines agents have a diagnostic mode that can capture additional info, including environment variables and network configuration at runtime. If you set the pipeline variable `System.Debug` to true (or `Agent.Diagnostic` to true) and run a build, the agent will produce extra logs such as `environment.txt` and `capabilities.txt`[1](https://learn.microsoft.com/en-us/azure/devops/pipelines/troubleshooting/review-logs?view=azure-devops). If you have done this for a test run, include those logs in your package.

   For example, after running a pipeline with diagnostics:
   - Download the pipeline logs (from Azure DevOps pipeline results, via the UI or Azure CLI). Inside the log bundle, find `environment.txt` and `capabilities.txt` for the agent.
   - Save those files to `Diagnostics/NetworkLab/AgentLogs/` (e.g., `environment.txt` for Windows might show if the firewall was enabled, PowerShell version, etc., which we partially gathered manually[1](https://learn.microsoft.com/en-us/azure/devops/pipelines/troubleshooting/review-logs?view=azure-devops)).

   ✅ **Verify:** Ensure any such diagnostic files are added. They are very useful for support, as they systematically capture the agent’s environment at run time (for instance, confirming that environment variables like proxy settings or `VSTS_AGENT_HTTPTRACE` were in effect, which can be crucial).

By the end of Step 4, your diagnostics folder contains the agent’s own logs and possibly system events. These logs chronicle the agent’s perspective and timing. For example, if the agent lost connectivity to Azure DevOps for 2 minutes, you might see that timestamp, which you could correlate with external factors (such as a network device issue at that time). We still refrain from deep analysis, but by collecting these, we ensure that nothing will be lost if the issue needs escalation.

### Step 5: (Optional) Capture Live Network Traffic

*This step is optional and recommended only if previous steps haven’t yielded clues, or if you need to catch the intermittent failure in action.* Capturing network packets can provide the most granular detail (e.g., TLS handshake failures, DNS query timeouts, etc.), but it requires care with sensitive data and can generate large files. We will demonstrate a *targeted* capture around the ARM endpoint communication.

- **5.1 Prepare for Packet Capture:** Choose a time window when the intermittent issue is likely to occur (if known). We will capture packets only to the relevant Azure endpoints to limit data. Identify the IP address(es) from the earlier DNS lookup for `management.azure.com`. Suppose it resolved to an IP like `13.82.x.x`; we’ll filter on that.

   **Windows:** If available, use the built-in **Packet Monitor (Pktmon)** or any installed tool like Wireshark. For Pktmon (Windows 10/Server 2019 and above):
   ```powershell
   pktmon filter add -t addr -v <Azure_IP_Address>
   pktmon start --capture --file C:\Diagnostics\NetworkLab\Network\azure_capture.etl
   ```
   This sets a filter for traffic to the Azure ARM IP and starts capturing to an ETL file.

   Next, trigger some network activity to ARM (for example, rerun the connectivity test or pipeline step that calls Azure). Let it run for a short period where the issue might occur, then stop capturing:
   ```powershell
   pktmon stop
   pktmon etl2pcap C:\Diagnostics\NetworkLab\Network\azure_capture.etl -o C:\Diagnostics\NetworkLab\Network\azure_capture.pcap
   ```
   The above converts the capture to PCAP format for analysis in Wireshark or other tools.

   ✅ **Verify:** Ensure `azure_capture.pcap` is created and has a non-zero file size. You can use `Get-Item C:\Diagnostics\NetworkLab\Network\azure_capture.pcap | Select Length` to see its size. If Pktmon is not available or this is too advanced, you may skip or use an alternative like Wireshark’s GUI (not covered in this text-based lab).

   **Linux (Bash):**
   ```bash
   sudo tcpdump -w ~/Diagnostics/NetworkLab/Network/azure_capture.pcap -n host management.azure.com &
   ```
   This starts a background tcpdump capturing traffic to/from the ARM endpoint. The `-n` prevents DNS lookups (we already know the name). Keep it running only for the necessary duration.

   Now, trigger the problematic traffic or simply wait for the interval when the issue tends to happen. After that, stop the capture:
   ```bash
   sudo pkill tcpdump
   ```
   (This finds and stops the tcpdump process.)

   ✅ **Verify:** Confirm `azure_capture.pcap` exists in the `Network` folder and is not empty (`ls -lh ~/Diagnostics/NetworkLab/Network/azure_capture.pcap` to see file size). You can inspect a summary of the capture with a tool like `tcpdump -r azure_capture.pcap -c 10` (which reads the first 10 packets) to ensure it captured data. Look for packets going to or from the known Azure IP or on port 443 to confirm it contains the relevant traffic.

   > **Troubleshooting Note:** Packet captures may contain sensitive information (IP addresses, possibly JWT tokens in headers, etc.). Handle these files carefully. Do **not** post them publicly without sanitization[4](https://github.com/microsoft/azure-pipelines-agent/blob/master/docs/troubleshooting.md). In a real scenario, share them only with trusted colleagues or support engineers who need them, and over secure channels.

- **5.2 Interpret Capture (Minimal Analysis):** Without going deep into analysis, perform a quick check on the capture to see if it *recorded* an error. For instance, you might open the PCAP in Wireshark and apply a filter for `tcp.analysis.retransmission` or `dns` to see if there were failed connections or DNS retries. If analyzing isn’t feasible right now, simply note that the capture is available.

   If you do identify something obvious (e.g., repeated TCP retransmissions or a TLS handshake that never completes), you can write that observation in a note for later. For example, “Captured traffic shows 3 TCP retransmissions before success” or “DNS query sent 5 times with no response in capture at 10:05:30 UTC”.

   ✅ **Verify:** Even if not doing full analysis, ensure the capture process didn’t disrupt the agent (it shouldn’t, but high-volume captures can sometimes affect performance slightly). Everything should be running as normal, and we have the raw packet data for the record.

After Step 5, you have an optional but powerful piece of evidence: a packet-level timeline of what happened on the wire. This can definitively show if, for example, the agent sent a request and got no reply, or if there was a TCP reset from some device, etc. Such detail is typically only needed if other logs are inconclusive, but having it can drastically speed up expert analysis later.

### Step 6: Package and Organize the Findings

Now that all relevant data is collected, the final step is to organize it into a format that can be easily consumed by others (colleagues or Microsoft support). We will create a summary README and then archive the diagnostics.

- **6.1 Create a Summary README:** In the root `NetworkLab` folder, create a README file (Markdown or text) that provides an overview of the issue and lists the collected artifacts. This helps anyone receiving the bundle to quickly understand context and contents.

   **All OS (choose your preferred editor or echo commands):** Create a file `Diagnostics/NetworkLab/README.md` with content similar to:

   ```text
   # Network Diagnostics Summary - Azure DevOps Agent

   **Issue Description:** Intermittent network failures when Azure DevOps self-hosted agents connect to Azure Resource Manager (ARM) endpoints. Pipeline tasks occasionally fail with network timeouts.

   **Environment:**  
   - Windows Agent: Windows Server 2019, Azure Pipelines Agent v2.218.1  
   - Linux Agent: Ubuntu 20.04, Azure Pipelines Agent v2.218.1  
   - Both agents located in on-prem datacenter behind corporate firewall (with outbound internet via proxy).

   **Data Collected:**  
   - System info: OS version, network config (`System/windows_systeminfo.txt`, `Network/windows_ipconfig.txt`, etc.)  
   - DNS resolution outputs (`DNS/windows_dns.txt`, `DNS/linux_dns.txt`)  
   - Connectivity tests (ping, port checks, traceroute in `Network/*_connectivity.txt` and `Network/*_traceroute.txt`)  
   - Azure Pipelines agent logs (`AgentLogs/Agent_*.log`, `AgentLogs/Worker_*.log`)  
   - Windows Event logs (`AgentLogs/windows_system_events.csv`)  
   - Packet capture of ARM traffic (`Network/azure_capture.pcap`) – *contains raw network packets, handle securely*.

   **Key Observations:**  
   - DNS resolution was generally successful (both agents resolve ARM endpoint to 13.82.x.x) but the Linux agent’s first DNS query timed out once.  
   - TCP connectivity tests sometimes showed high latency (~1 sec) on first attempt, then normal (<100ms).  
   - Traceroute indicates an extra hop on the on-prem network for the Windows agent that the Linux agent (in DMZ) doesn’t have. That hop (10.0.5.1) had 30% packet loss.  
   - Agent log on Windows shows an error at 2025-07-08 10:30:45, matching a DNS resolution timeout in the system event log.  
   - Packet capture confirms three DNS queries sent from Windows with no response before succeeding on the fourth query.

   **Next Steps / Recommendations:**  
   - Investigate the networking device at 10.0.5.1 for packet loss or high latency.  
   - Ensure DNS servers (10.1.1.1 and 10.1.2.2) are responsive; consider adding a secondary or using Azure DNS as forwarder.  
   - Share this collected data with the network team or open a support case with Microsoft, including all files in this package for a comprehensive analysis.
   ```

   (The above is an **example template** – use the actual observations from your case. If some data is not collected or not applicable, adjust accordingly. The goal is to concisely summarize what's in the package and highlight anything you noticed that could be relevant.)

   ✅ **Verify:** Save the README and open it to ensure formatting is correct (if Markdown, check that headings and bullet points are properly formatted). This README will be extremely useful to anyone you hand over the diagnostics to, as it prevents them from having to guess what each file is or why it was collected.

- **6.2 Final Folder Check:** Do a final review of the `NetworkLab` directory to ensure all files are present and updated. If you missed any step’s output, you can still add it now. For example, if you didn’t save a file from a console output, you can scroll up in the console and copy-paste it into a text file.

   **Windows (PowerShell):** `Get-ChildItem -Recurse C:\Diagnostics\NetworkLab | Select FullName, Length`  
   **Linux (Bash):** `find ~/Diagnostics/NetworkLab -type f -exec ls -lh {} \;`

   ✅ **Verify:** Confirm the presence of all expected files (compare with your README’s list). Ensure none of the files are unexpectedly empty or ridiculously large. If a file (like a pcap) is very large (hundreds of MB), consider whether you can truncate it or if you captured too long – large files can be hard to share. Perhaps record a note in README that such a file is large and may need special handling.

- **6.3 Archive the Diagnostics:** Finally, package the entire `NetworkLab` folder into a single archive for easy sharing.

   **Windows (PowerShell):**
   ```powershell
   Compress-Archive -Path C:\Diagnostics\NetworkLab\* -DestinationPath C:\Diagnostics\NetworkLab.zip
   ```
   This creates `NetworkLab.zip` containing the folder and all subfolders/files.

   ✅ **Verify:** Ensure the ZIP was created (`Test-Path C:\Diagnostics\NetworkLab.zip` should return True). You can also open it in File Explorer to double-check the contents.

   **Linux (Bash):**
   ```bash
   zip -r ~/Diagnostics/NetworkLab.zip ~/Diagnostics/NetworkLab
   ```
   If the `zip` utility is not installed, you can use `tar`:  
   ```bash
   tar -czf ~/Diagnostics/NetworkLab.tgz -C ~/Diagnostics NetworkLab
   ```
   which produces a tarball `.tgz` file.

   ✅ **Verify:** List the archive file (`ls -lh ~/Diagnostics/NetworkLab.zip` or `.tgz`) to see its size. Test the archive integrity if possible (e.g., `unzip -l ~/Diagnostics/NetworkLab.zip` to list contents, or `tar -tzf NetworkLab.tgz` for tarball). This ensures the archive isn’t corrupted and includes everything.

Your diagnostic bundle is now ready! It contains all the gathered evidence and the summary README. This package can be shared with your network specialists or Azure support. With this comprehensive collection, **success** means that even if you hand off the issue, the next person has all the data needed to identify the root cause (be it a DNS misconfiguration, a firewall blocking intermittent calls, an Azure issue, etc.) without having to rerun all these steps.

---

## Troubleshooting Tips

- **Insufficient Permissions:** If some commands failed (especially on Windows) due to permissions (e.g., accessing certain logs or running `pktmon` requires Admin), rerun the specific steps in an elevated prompt. On Linux, ensure you used `sudo` where needed (for example, `tcpdump` and reading system logs).

- **Command Not Found:** If a tool like `dig` or `traceroute` wasn’t available, install the corresponding package (`nslookup` can substitute for `dig`, and `tracepath` or installing the `inetutils-traceroute` package can provide `traceroute`). On Windows, all used tools are built-in (in PowerShell 5+), but if using PowerShell Core on Linux, note that `Test-NetConnection` might not be available there – in such cases use `ping`/`nc` as we did for Linux.

- **Interpreting Partial Traceroute Results:** It’s normal for some hops in traceroute to show `* * *` for no response. What’s important is whether the trace reaches the destination or if it fails consistently at an intermediate hop. If the final hop is unreachable but earlier ones are fine, the network path is likely okay (Azure endpoints often won’t respond to traceroute). Look for drastic changes in latency in the hops or a specific hop where things start to time out frequently.

- **DNS Variability:** DNS queries might go to different servers if you have multiple configured. If you see one query fail and another succeed, it could be that one DNS server is having issues. You might repeat the `Resolve-DnsName`/`dig` step multiple times to see if the resolution is sometimes slow or failing. Use the `-Server` option in `Resolve-DnsName` or `dig @<dns-server>` to test each configured DNS server individually if needed.

- **Using Agent Diagnostic Logs:** If you enabled `System.Debug=true` for a pipeline run, remember that the agent diagnostic logs (like `environment.txt`) are included in the pipeline logs download, not left on the agent machine file system. Ensure you retrieved them from the Azure DevOps pipeline UI or CLI. These can save you from manually collecting some info. For example, `environment.txt` would have told you the firewall was enabled on Windows and its profile[1](https://learn.microsoft.com/en-us/azure/devops/pipelines/troubleshooting/review-logs?view=azure-devops), and listed all environment variables.

- **Time Synchronization:** Rarely, clock drift can cause what appear to be network issues (e.g., failing authentication if clocks differ too much). We didn’t explicitly check it, but if you suspect it, verify the system time against an internet time service. Ensure NTP is working properly on Linux and the Windows Time service is operational.

- **If Issue is Not Found:** Sometimes, after gathering all this data, everything might *look* normal in the captures (that’s good to rule things out, but frustrating). In such cases, consider factors like:
  - Intermittent proxy or firewall issues that occur only under load or specific conditions (you might need to involve the network team to monitor those devices during pipeline runs).
  - Azure side throttling or service issues: Check the Azure Service Health for your region around the failure times[2](https://learn.microsoft.com/en-us/answers/questions/2260076/best-practices-for-preventing-and-mitigating-inter). There could be an intermittent platform issue. If so, documenting it will help in the support case.
  - Agent machine resource issues: High CPU or memory on the agent could make it slow to handle network operations (the Stack Overflow discussion noted agents being starved of CPU can drop connections[5](https://stackoverflow.com/questions/66134088/azure-devops-self-hosted-agent-error-connectivity-issues)). Check if the agent machines had high load (you might see signs of this in pipeline logs if tasks took unusually long or in agent logs with heartbeat delays).

Always remember to **revert any changes** made for diagnostics in a production environment once finished (like disabling extra logging or removing packet capture filters) to avoid impacting normal operation.

## Cleanup

After completing the lab and resolving the issue (or handing off the data), perform these cleanup actions:

- **Remove Sensitive Data:** If you will share the diagnostic bundle externally, review the files for any secrets or sensitive info. Mask things like internal IP ranges (if necessary) or user account names as appropriate for your organization’s policies.

- **Delete Diagnostic Files (Optional):** On the agent machines, you may delete the `Diagnostics/NetworkLab` folder if it’s no longer needed, especially if it contains sensitive or bulky files (e.g., packet captures). Since we archived everything, you can safely remove the working directory:
  - Windows: `Remove-Item -Recurse -Force C:\Diagnostics\NetworkLab` (and the `.zip` if copied off-machine).  
  - Linux: `rm -rf ~/Diagnostics/NetworkLab` (and the archive file).

- **Reset Configurations:**  
  - If you set any environment variables for debugging (like `VSTS_AGENT_HTTPTRACE=true` or proxy settings) when running the agent, remove them or revert the agent service to normal operation[1](https://learn.microsoft.com/en-us/azure/devops/pipelines/troubleshooting/review-logs?view=azure-devops). For example, on Windows you might have to unset the variable or remove it from the machine's Environment Variables.  
  - If any special logging was enabled (such as System.Debug in pipelines or verbose logging on applications), turn those off to reduce noise and performance overhead.

- **Network Watcher Resources:** If you created any Azure Network Watcher tests (Connection Monitor, etc.) or enabled NSG flow logs to a storage account for this investigation, consider cleaning those up if they are incurring cost and are no longer needed. For instance, stop any running Connection Monitor tests and remove diagnostic settings that were added solely for troubleshooting.

- **Agent Reconfiguration (if applicable):** In extreme cases, you might have reconfigured the agent or upgraded it during troubleshooting. Ensure the agent is back to a stable state (running the latest version, in service mode if it was originally a service, etc.). If you installed additional tools on the agent (like Wireshark or traceroute), evaluate if they should be kept for future use or removed for security.

By cleaning up, we ensure that the agent machines remain in their baseline state and that no unnecessary services or files linger. This also prevents future confusion (e.g., someone else stumbling on leftover diagnostic files later).

## Reflection Questions

1. **Windows vs. Linux:** How did the troubleshooting process differ between Windows and Linux agents? Identify one advantage each OS had in diagnosing the issue (e.g., Windows Event Viewer logs vs. Linux flexibility with tools).  
2. **Preventative Measures:** Based on the data collected, what changes would you consider to prevent similar intermittent failures? (Think about DNS configurations, network infrastructure, or agent settings like proxies and keep-alive intervals.)  
3. **Automation Opportunities:** Which parts of this diagnostics process could be automated in the future? Propose at least one way to script or tool-ify the data collection so that it could run during an incident and gather info without manual steps.  
4. **Additional Data:** In hindsight, is there any other data you wish you had collected? For example, would enabling verbose logging on the pipeline tasks or collecting performance counters add value?  
5. **Collaborating with Network Teams:** How would you effectively communicate these findings to a networking team or Azure support? What key evidence would you highlight to justify that the problem lies in the network vs. the application?

Consider these questions and discuss with your team or mentor. They will help reinforce the diagnostic steps taken and encourage thinking about making network troubleshooting a proactive and smoother experience in the future.---
title: Azure DevOps Network Diagnostic Lab (Windows + Linux Agents)  
difficulty: intermediate  
duration: "2-4 hours"  
objectives:  
  - Identify potential causes of intermittent network failures in Azure DevOps pipelines  
  - Capture essential diagnostic data on Windows and Linux self-hosted agents  
  - Verify the completeness and integrity of collected network logs  
  - Package and organize diagnostics for efficient escalation  
prerequisites:  
  - Azure DevOps project with permissions to run pipelines and manage agents  
  - One Windows and one Linux machine configured as self-hosted Azure DevOps agents  
  - Internet connectivity from the agent machines to Azure services (ARM endpoints)  
  - *(Optional)* Azure subscription with Network Watcher enabled (for advanced network diagnostics)  
---

## Executive Summary

Intermittent network failures in Azure DevOps pipelines – especially when self-hosted build agents communicate with Azure Resource Manager (ARM) endpoints – can be challenging to diagnose. This hands-on lab provides a **concise, repeatable playbook** for Azure DevOps engineers to **capture, verify, and package** all data needed to troubleshoot such issues. We will systematically gather network configuration, DNS resolution data, connectivity tests, and relevant logs from both **Windows** and **Linux** agents, with immediate verification after each step. The lab also covers organizing the collected information into a sharable bundle, enabling efficient collaboration or escalation. By completing this lab, engineers will gain a structured approach to diagnosing network connectivity problems without diving into root-cause analysis, ensuring that no critical evidence is missed before handing off to others.

<!-- Copilot-Researcher-Visualization -->
```html
<style>
    :root {
        --accent: #464feb;
        --timeline-ln: linear-gradient(to bottom, transparent 0%, #b0beff 15%, #b0beff 85%, transparent 100%);
        --timeline-border: #ffffff;
        --bg-card: #f5f7fa;
        --bg-hover: #ebefff;
        --text-title: #424242;
        --text-accent: var(--accent);
        --text-sub: #424242;
        --radius: 12px;
        --border: #e0e0e0;
        --shadow: 0 2px 10px rgba(0, 0, 0, 0.06);
        --hover-shadow: 0 4px 14px rgba(39, 16, 16, 0.1);
        --font: "Segoe UI";
    }

    @media (prefers-color-scheme: dark) {
        :root {
            --accent: #7385ff;
            --timeline-ln: linear-gradient(to bottom, transparent 0%, transparent 3%, #6264a7 30%, #6264a7 50%, transparent 97%, transparent 100%);
            --timeline-border: #424242;
            --bg-card: #1a1a1a;
            --bg-hover: #2a2a2a;
            --text-title: #ffffff;
            --text-sub: #ffffff;
            --shadow: 0 2px 10px rgba(0, 0, 0, 0.3);
            --hover-shadow: 0 4px 14px rgba(0, 0, 0, 0.5);
            --border: #3d3d3d;
        }
    }

    @media (prefers-contrast: more),
    (forced-colors: active) {
        :root {
            --accent: ActiveText;
            --timeline-ln: ActiveText;
            --timeline-border: Canvas;
            --bg-card: Canvas;
            --bg-hover: Canvas;
            --text-title: CanvasText;
            --text-sub: CanvasText;
            --shadow: 0 2px 10px Canvas;
            --hover-shadow: 0 4px 14px Canvas;
            --border: ButtonBorder;
        }
    }

    .insights-container {
        display: grid;
        grid-template-columns: repeat(2,minmax(240px,1fr));
        padding: 0px 16px 0px 16px;
        gap: 16px;
        margin: 0 0;
        font-family: var(--font);
    }

    .insight-card:last-child:nth-child(odd){
        grid-column: 1 / -1;
    }

    .insight-card {
        background-color: var(--bg-card);
        border-radius: var(--radius);
        border: 1px solid var(--border);
        box-shadow: var(--shadow);
        min-width: 220px;
        padding: 16px 20px 16px 20px;
    }

    .insight-card:hover {
        background-color: var(--bg-hover);
    }

    .insight-card h4 {
        margin: 0px 0px 8px 0px;
        font-size: 1.1rem;
        color: var(--text-accent);
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .insight-card .icon {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        width: 20px;
        height: 20px;
        font-size: 1.1rem;
        color: var(--text-accent);
    }

    .insight-card p {
        font-size: 0.92rem;
        color: var(--text-sub);
        line-height: 1.5;
        margin: 0px;
    }

    .insight-card p b, .insight-card p strong {
        font-weight: 600;
    }

    .metrics-container {
        display:grid;
        grid-template-columns:repeat(2,minmax(210px,1fr));
        font-family: var(--font);
        padding: 0px 16px 0px 16px;
        gap: 16px;
    }

    .metric-card:last-child:nth-child(odd){
        grid-column:1 / -1; 
    }

    .metric-card {
        flex: 1 1 210px;
        padding: 16px;
        background-color: var(--bg-card);
        border-radius: var(--radius);
        border: 1px solid var(--border);
        text-align: center;
        display: flex;
        flex-direction: column;
        gap: 8px;
    }

    .metric-card:hover {
        background-color: var(--bg-hover);
    }

    .metric-card h4 {
        margin: 0px;
        font-size: 1rem;
        color: var(--text-title);
        font-weight: 600;
    }

    .metric-card .metric-card-value {
        margin: 0px;
        font-size: 1.4rem;
        font-weight: 600;
        color: var(--text-accent);
    }

    .metric-card p {
        font-size: 0.85rem;
        color: var(--text-sub);
        line-height: 1.45;
        margin: 0;
    }

    .timeline-container {
        position: relative;
        margin: 0 0 0 0;
        padding: 0px 16px 0px 56px;
        list-style: none;
        font-family: var(--font);
        font-size: 0.9rem;
        color: var(--text-sub);
        line-height: 1.4;
    }

    .timeline-container::before {
        content: "";
        position: absolute;
        top: 0;
        left: calc(-40px + 56px);
        width: 2px;
        height: 100%;
        background: var(--timeline-ln);
    }

    .timeline-container > li {
        position: relative;
        margin-bottom: 16px;
        padding: 16px 20px 16px 20px;
        border-radius: var(--radius);
        background: var(--bg-card);
        border: 1px solid var(--border);
    }

    .timeline-container > li:last-child {
        margin-bottom: 0px;
    }

    .timeline-container > li:hover {
        background-color: var(--bg-hover);
    }

    .timeline-container > li::before {
        content: "";
        position: absolute;
        top: 18px;
        left: -40px;
        width: 14px;
        height: 14px;
        background: var(--accent);
        border: var(--timeline-border) 2px solid;
        border-radius: 50%;
        transform: translateX(-50%);
        box-shadow: 0px 0px 2px 0px #00000012, 0px 4px 8px 0px #00000014;
    }

    .timeline-container > li h4 {
        margin: 0 0 5px;
        font-size: 1rem;
        font-weight: 600;
        color: var(--accent);
    }

    .timeline-container > li * {
        margin: 0;
        font-size: 0.9rem;
        color: var(--text-sub);
        line-height: 1.4;
    }

    .timeline-container > li * b, .timeline-container > li * strong {
        font-weight: 600;
    }

    @media (max-width:600px){
      .metrics-container,
      .insights-container{
        grid-template-columns:1fr;
      }
    }
</style>
<div class="insights-container">
  <div class="insight-card">
    <h4>Data Source Mapping</h4>
    <p>Identify each likely failure point (DNS, firewall, routing, service health, agent config) and map it to logs or commands that reveal its status.</p>
  </div>
  <div class="insight-card">
    <h4>Comprehensive Collection</h4>
    <p>Execute step-by-step instructions (Windows & Linux) to collect network info, agent logs, and Azure-side data (NSG flow logs, Connection Monitor, DNS metrics) for a full picture.</p>
  </div>
  <div class="insight-card">
    <h4>Immediate Verification</h4>
    <p>Perform quick sanity checks (file existence, log snippets, command output) after each data capture to confirm the information is complete and uncorrupted before moving on.</p>
  </div>
  <div class="insight-card">
    <h4>Packaging & Handoff</h4>
    <p>Organize all findings in a structured folder with timestamps and a README. This bundle can be zipped and attached to support tickets for seamless collaboration.</p>
  </div>
  <div class="insight-card">
    <h4>Focused Analysis</h4>
    <p>Limit analysis to confirming capture success (e.g. “DNS response received, size X bytes”) without attempting to solve the issue, keeping the investigation unbiased and data-driven.</p>
  </div>
</div>
```

**What "Success" Looks Like:**  
| Focus Area                      | Outcome                                                                                                                                                                      |
| ------------------------------  | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Discovery of data sources**   | A checklist mapping each likely failure surface (DNS, firewall, routing, service health, agent config) to the exact logs, commands, or Azure Monitor signals that reveal it.   |
| **Step-by-step collection**     | Copy-and-paste commands for Windows *and* Linux agents, plus pointers for portal-side artifacts (NSG flow logs, Connection Monitor runs, DNS resolver metrics).               |
| **Verification**                | Fast sanity checks—hash totals, sample queries, or one-line `grep`/`Select-String` commands—to confirm each capture is complete and uncorrupted *before* escalation.           |
| **Packaging for collaboration** | A ready-made folder structure & README template teams can zip and attach to tickets, including timestamps and environment metadata.                                            |
| **Minimal analysis**            | Only enough interpretation to confirm the capture succeeded (e.g., “DNS response seen, size = ... bytes”)—deep root-cause analysis is out-of-scope at this stage.             |

> **Prerequisites:** This lab assumes you have access to an **Azure DevOps organization** with a project where you can run pipelines and manage service connections. You should have one **Windows** machine and one **Linux** machine registered as **self-hosted agents** for your project. Both agents need outbound Internet connectivity to Azure (specifically, the ability to reach Azure Resource Manager endpoints). Basic familiarity with command-line operations on Windows and Linux is required. Optionally, having an **Azure subscription** with **Network Watcher** enabled is beneficial for using advanced diagnostics (like Connection Monitor and NSG flow logs), though not strictly necessary for the core lab steps.

## Lab Exercises

In this lab, you will perform a series of steps to collect and verify diagnostic information from both a Windows-based and a Linux-based Azure DevOps agent machine. Each step provides commands for both operating systems, along with a ✅ **Verify** instruction to validate the results. By the end, you will package the collected data for analysis or escalation.

### Step 1: Prepare Environment & Collect System Info

Intermittent network issues can be influenced by the agent’s environment. We start by gathering basic system and network configuration details on each agent, and setting up a folder structure to store all diagnostics.

- **1.1 Create a Diagnostics Folder:** On each agent machine, create a dedicated directory to store logs and outputs collected during this lab. For consistency, use a path like `~/Diagnostics/NetworkLab` on Linux and `C:\Diagnostics\NetworkLab` on Windows.

   **Windows (PowerShell):**
   ```powershell
   New-Item -Path C:\Diagnostics\NetworkLab -ItemType Directory -Force
   New-Item -Path C:\Diagnostics\NetworkLab\System -ItemType Directory -Force
   New-Item -Path C:\Diagnostics\NetworkLab\Network -ItemType Directory -Force
   New-Item -Path C:\Diagnostics\NetworkLab\DNS -ItemType Directory -Force
   New-Item -Path C:\Diagnostics\NetworkLab\AgentLogs -ItemType Directory -Force
   ```
   ✅ **Verify:** Ensure the `C:\Diagnostics\NetworkLab` folder now exists with `System`, `Network`, `DNS`, and `AgentLogs` subfolders (`Get-ChildItem C:\Diagnostics\NetworkLab` should list these subdirectories).

   **Linux (Bash):**
   ```bash
   mkdir -p ~/Diagnostics/NetworkLab/{System,Network,DNS,AgentLogs}
   ```
   ✅ **Verify:** Check that the `~/Diagnostics/NetworkLab` directory and the `System`, `Network`, `DNS`, `AgentLogs` subdirectories were created (run `ls ~/Diagnostics/NetworkLab` and confirm the folder names).

- **1.2 System Information:** Gather detailed system info for each agent. This helps in understanding the OS version, system architecture, and hardware resources, which can provide context (e.g., knowing if the OS is up to date or if there are resource constraints that might indirectly cause network issues).

   **Windows (PowerShell):**
   ```powershell
   systeminfo | Out-File C:\Diagnostics\NetworkLab\System\windows_systeminfo.txt
   ```
   *Alternative:* You can also use `Get-ComputerInfo > C:\Diagnostics\NetworkLab\System\windows_systeminfo.txt` on newer PowerShell versions for a more structured output[1](https://learn.microsoft.com/en-us/azure/devops/pipelines/troubleshooting/review-logs?view=azure-devops). Both commands may require a few seconds to run.

   ✅ **Verify:** Open or type the beginning of the `windows_systeminfo.txt` file (`Get-Content C:\Diagnostics\NetworkLab\System\windows_systeminfo.txt | Select-Object -First 5`) and ensure it contains system details (OS Name, Version, etc.).

   **Linux (Bash):**
   ```bash
   uname -a > ~/Diagnostics/NetworkLab/System/linux_uname.txt
   lsb_release -a >> ~/Diagnostics/NetworkLab/System/linux_uname.txt 2>/dev/null
   ```
   *Note:* The second command (`lsb_release`) captures Linux distribution details (if the system has `lsb_release` installed; it’s present on Ubuntu/Debian by default). The `2>/dev/null` part ignores errors in case `lsb_release` isn't available.

   ✅ **Verify:** View the `linux_uname.txt` file (`head -n 5 ~/Diagnostics/NetworkLab/System/linux_uname.txt`). It should show the kernel version and possibly the distribution info (e.g., Ubuntu release number). For example, you might see a line with `Linux <hostname> <kernel-version> ...` from `uname -a`, and distribution info from `lsb_release`.

- **1.3 Network Configuration:** Collect information about network interfaces, IP configuration, and DNS settings on each machine. Misconfigurations or unexpected settings here can lead to connectivity problems (e.g., wrong DNS server or IP address conflicts).

   **Windows (PowerShell):**
   ```powershell
   ipconfig /all | Out-File C:\Diagnostics\NetworkLab\Network\windows_ipconfig.txt
   ```
   This captures the IP addresses, DNS servers, gateway, and NIC details for the Windows agent.

   ✅ **Verify:** Open the first few lines of the output (`Select-String "IPv4 Address" C:\Diagnostics\NetworkLab\Network\windows_ipconfig.txt`) to ensure an IPv4 address is listed for the active adapter. Also verify the DNS Servers listed match your expected network configuration.

   **Linux (Bash):**
   ```bash
   ifconfig -a > ~/Diagnostics/NetworkLab/Network/linux_ifconfig.txt 2>/dev/null || ip addr show > ~/Diagnostics/NetworkLab/Network/linux_ifconfig.txt
   printf "\nDNS Configuration:\n" >> ~/Diagnostics/NetworkLab/Network/linux_ifconfig.txt
   cat /etc/resolv.conf >> ~/Diagnostics/NetworkLab/Network/linux_ifconfig.txt
   ```
   This command tries `ifconfig` (older tool) and falls back to `ip addr show` if needed, then appends DNS resolver settings from `/etc/resolv.conf`. (Most Linux distros list current DNS servers in that file.)

   ✅ **Verify:** Open `linux_ifconfig.txt` (`head -n 15 ~/Diagnostics/NetworkLab/Network/linux_ifconfig.txt`) and confirm it contains IP address information for the network interface(s). Scroll or search within the file for lines like `inet ` (for IPv4) or `inet6` (for IPv6) addresses. Also check that DNS nameserver entries (from `resolv.conf`) are present under a "DNS Configuration" section.

- **1.4 Firewall Status:** Determine if the local firewall is enabled and if it might be blocking outbound traffic. A host-based firewall could intermittently block connections if not configured properly.

   **Windows (PowerShell):**
   ```powershell
   Get-NetFirewallProfile -All | Select-Object Name, Enabled | Out-File C:\Diagnostics\NetworkLab\Network\windows_firewall.txt
   ```
   This will list each firewall profile (Domain, Private, Public) and whether it’s enabled (True/False).

   ✅ **Verify:** Open `windows_firewall.txt` and ensure it shows the status of each profile. For example, you might see `Domain  True/False`, etc. If the profile corresponding to your network (likely Domain or Private for enterprise networks) is enabled, outbound rules could affect connectivity. Save this info for later analysis.

   **Linux (Bash):**
   ```bash
   sudo iptables -L -v -n > ~/Diagnostics/NetworkLab/Network/linux_iptables.txt
   ```
   This lists firewall rules if the system uses iptables. On systems with `ufw` (Ubuntu’s Uncomplicated Firewall) or `firewalld` (CentOS/Fedora), you could use `sudo ufw status verbose` or `sudo firewall-cmd --list-all` respectively. Adjust as needed for your distribution.

   ✅ **Verify:** Check `linux_iptables.txt` for any rules. If the file is empty or shows default policies as ACCEPT (and no specific DROP rules for outbound traffic), the Linux firewall is likely not blocking egress. If using `ufw` or others, verify their status outputs similarly. (If unsure, note it down and proceed; the key is to document whatever firewall state exists.)

By the end of Step 1, you should have basic environment and network configuration data for both agents saved in your `NetworkLab` folder (under `System` and `Network` subfolders). This establishes a baseline and captures any obvious misconfigurations early.

### Step 2: DNS Resolution and Service Reachability

DNS issues are a common cause of intermittent connectivity problems. If an agent occasionally fails to resolve the ARM endpoint, that could explain intermittent failures. In this step, we’ll test DNS name resolution and basic network reachability to Azure Resource Manager endpoints from each agent.

- **2.1 DNS Lookup for ARM Endpoint:** Test the DNS resolution of the Azure Resource Manager endpoint (typically `management.azure.com`) from each agent.

   **Windows (PowerShell):**
   ```powershell
   Resolve-DnsName management.azure.com | Out-File C:\Diagnostics\NetworkLab\DNS\windows_dns.txt
   ```
   This uses the Windows DNS client to resolve the name. It should return one or more IP addresses for `management.azure.com`.

   ✅ **Verify:** Open `windows_dns.txt` and look for an “Answer” section with an IP address. For example, it might show a record like `management.azure.com.  -> <IP_ADDRESS>`. If the resolution fails or times out, that indicates a DNS problem. If multiple DNS servers are configured on the machine, the output will show which server responded.

   **Linux (Bash):**
   ```bash
   dig +ANSWER management.azure.com > ~/Diagnostics/NetworkLab/DNS/linux_dns.txt
   ```
   *Alternative:* If `dig` is not installed, use `nslookup management.azure.com` instead. The `+ANSWER` flag in dig outputs only the answer section for brevity.

   ✅ **Verify:** Check `linux_dns.txt` for one or more IP addresses corresponding to `management.azure.com`. For instance, you should see an `ANSWER SECTION` with A record(s). Note whether the response is quick and successful – any delays or failures here suggest DNS issues.

- **2.2 Connectivity Test (Ping/Port Check):** Now verify network connectivity to the ARM endpoint. Many Azure endpoints do not respond to ICMP (ping), but we can still check if the TCP port 443 is reachable.

   **Windows (PowerShell):**
   ```powershell
   Test-NetConnection -ComputerName management.azure.com -Port 443 | Out-File C:\Diagnostics\NetworkLab\Network\windows_connectivity.txt
   ```
   This command attempts a TCP connection on port 443 (HTTPS) to the specified host. It will report `TcpTestSucceeded: True` if the connection was established. It also outputs the resolved IP and the latency.

   ✅ **Verify:** Open `windows_connectivity.txt` and find the `TcpTestSucceeded` line. If it says `True`, the agent can reach the ARM endpoint on port 443. Also note the `PingSucceeded` (which might be false if ICMP is blocked) and the `RoundtripTime` if available. If `TcpTestSucceeded` is False, the agent couldn’t connect at that moment – this could indicate a network block or issue.

   **Linux (Bash):**
   ```bash
   ping -c 4 management.azure.com > ~/Diagnostics/NetworkLab/Network/linux_ping.txt 2>&1
   ```
   Then, to specifically test the port (since ping may not get replies):
   ```bash
   echo | timeout 5 nc -vz management.azure.com 443 > ~/Diagnostics/NetworkLab/Network/linux_port443.txt 2>&1
   ```
   Here we use `nc` (netcat) to attempt a connection to port 443. We pipe `echo` to `nc` to immediately close after connecting, and use `timeout 5` to avoid hanging too long. If the connection is successful, `nc` will report "succeeded" or show the TLS handshake. If it fails, it will report an error.

   ✅ **Verify:** Examine `linux_ping.txt`. Even if Azure dropped ping, the file will show if DNS resolved (ping will list the IP it’s trying to ping). Next, check `linux_port443.txt`. A successful connection will typically contain something like `management.azure.com [<IP>] 443 (https) open` or an SSL handshake message. If you see "open", it means the TCP connection succeeded. If it says "Connection timed out" or "Host unreachable", the agent could not reach the endpoint on that port at that time.

- **2.3 Azure Service URL Access (Optional):** As an extra verification, you can try to perform an HTTPS request to the ARM endpoint. We don’t expect to get data without proper authentication, but getting an HTTP **status code** response (even 401 Unauthorized) confirms end-to-end connectivity including TLS handshake.

   **Windows (PowerShell):**
   ```powershell
   try { Invoke-WebRequest -Uri "https://management.azure.com/subscriptions?api-version=2020-01-01" -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop } catch { $_.Exception.Response.StatusCode | Out-File C:\Diagnostics\NetworkLab\Network\windows_http_status.txt }
   ```
   This tries a simple Azure REST API call (listing subscriptions) with no auth, expecting a 401. We capture the HTTP status code from the exception. Ensure you have PowerShell 5+ for `Invoke-WebRequest -UseBasicParsing`.

   ✅ **Verify:** Open `windows_http_status.txt`. It should contain `Unauthorized` or status code `401` if the request reached Azure (which is good – it means the networking is fine, we just aren’t authorized, as expected). If it shows a different error (e.g., *Name or service not known* or *Request timed out*), that indicates a network problem rather than a successful connectivity test.

   **Linux (Bash):**
   ```bash
   curl -I https://management.azure.com/subscriptions?api-version=2020-01-01 -m 10 -o ~/Diagnostics/NetworkLab/Network/linux_http_head.txt -w "%{http_code}" 2>~/Diagnostics/NetworkLab/Network/linux_http_error.txt
   ```
   This cURL command attempts the same request, writing the headers to `linux_http_head.txt` and capturing the HTTP status code in the output. It uses a 10-second timeout.

   ✅ **Verify:** Check `linux_http_head.txt` for any HTTP response headers. If connectivity is successful, you should see response headers like `WWW-Authenticate: Bearer` (indicating Azure is asking for a token) and an HTTP/1.1 401 status line. The HTTP status code output (which was written to console by `%{http_code}`) can be seen by opening `linux_http_error.txt` to ensure no network errors were logged. A `401` or `HTTP/1.1 401 Unauthorized` confirms that the agent reached the service (expected outcome since no credentials were provided). Any other result (such as no response or an SSL error) would hint at network issues.

At this stage, you have confirmed whether **DNS resolution** and **basic network connectivity** to Azure Resource Manager are working from each agent. If these tests passed (names resolve and port 443 is reachable), the intermittent issue might lie elsewhere. If any of these tests failed or were flaky (e.g. DNS sometimes resolving slowly or certain pings failing), keep these observations as they might correlate with the pipeline failures.

### Step 3: Route & Network Path Diagnostics

Understanding the network path from the agent to Azure can reveal issues like routing loops or intermediate drops (for example, a specific hop intermittently failing). In this step, we run traceroute and examine routing configurations. We’ll also gather any network-specific logs on the agent (like Azure Network Watcher logs, if applicable).

- **3.1 Traceroute to Azure Endpoint:** Perform a traceroute from each agent to see the path taken to reach Azure’s ARM service. This can show if traffic is going through a proxy, VPN, or encountering a problematic hop.

   **Windows (Command Prompt via PowerShell):**
   ```powershell
   tracert -d management.azure.com | Out-File C:\Diagnostics\NetworkLab\Network\windows_traceroute.txt
   ```
   The `-d` flag avoids resolving intermediate hop IPs to names (faster output). Running `tracert` from PowerShell will launch the command-prompt tool and pipe output back.

   ✅ **Verify:** Open `windows_traceroute.txt`. You should see a list of hops (lines numbered 1, 2, 3, ...) showing the route. If the traceroute reaches an Azure edge, one of the last hops may mention azure or have an IP known to Azure’s range. If some hops show `* * * Request timed out` intermittently, that hop doesn’t respond to traceroute probes (common for certain network devices) – not necessarily a failure, unless it’s the final target. Ensure the trace either completes to the destination or gets close (Azure may not respond at the final endpoint but prior hops should show progress).

   **Linux (Bash):**
   ```bash
   traceroute -n management.azure.com > ~/Diagnostics/NetworkLab/Network/linux_traceroute.txt 2>&1 || tracepath management.azure.com > ~/Diagnostics/NetworkLab/Network/linux_traceroute.txt 2>&1
   ```
   This tries `traceroute` and falls back to `tracepath` if needed. The `-n` option in traceroute prevents DNS lookups for speed.

   ✅ **Verify:** View `linux_traceroute.txt`. Similar to Windows, you’ll see the hops. Ensure multiple hops are listed. If the traceroute doesn’t complete, note where it stops. Consistent failures at a certain hop might indicate an issue at or beyond that network node. Save this information for correlation (e.g., if always failing at hop 5, is that hop part of your corporate network or ISP?).

- **3.2 Check Route Tables (Optional):** If the agent is in a complex network (such as behind multiple routers or in Azure vNet with user-defined routes), it’s useful to capture the routing table.

   **Windows (PowerShell):**
   ```powershell
   route print > C:\Diagnostics\NetworkLab\Network\windows_routes.txt
   ```
   This lists the IPv4 and IPv6 routing table entries on the Windows machine.

   ✅ **Verify:** Open `windows_routes.txt`. Look for the default route (usually `0.0.0.0` in the IPv4 table) to confirm which gateway is used. If multiple default routes or unusual entries exist (like persistent routes to specific Azure IP ranges), note them as they could influence connectivity.

   **Linux (Bash):**
   ```bash
   ip route show > ~/Diagnostics/NetworkLab/Network/linux_routes.txt
   ```
   This shows the current routing table on Linux.

   ✅ **Verify:** Check `linux_routes.txt` for the default route (look for a line starting with `default via`). Ensure it points to the expected gateway (likely your local router or cloud VM gateway). If there are any routes specifically for Azure IP ranges or unusual static routes, they will be listed here.

- **3.3 Network Watcher & NSG Logs (Conditional):** If your agent VM is in Azure and you have https://learn.microsoft.com/azure/network-watcher enabled, you can leverage its tools:
   - **Connection Troubleshoot:** You could run a connectivity check from the Azure portal or via Azure CLI to test reaching `management.azure.com` from the VM’s perspective.[2](https://learn.microsoft.com/en-us/answers/questions/2260076/best-practices-for-preventing-and-mitigating-inter)[3](https://cloudopszone.com/how-to-troubleshoot-using-azure-network-watcher-connection-troubleshoot/) This can detect NSG (Network Security Group) or UDR issues by analyzing the path.
   - **NSG Flow Logs:** If the agent’s subnet has NSG flow logging to Azure Storage or Log Analytics, retrieve the logs around the time of failures to see if traffic was allowed/denied. (This is advanced; ensure you have permission to view these logs. They can show all outbound flows and their statuses[2](https://learn.microsoft.com/en-us/answers/questions/2260076/best-practices-for-preventing-and-mitigating-inter).)
   - **Azure Firewall or Proxy Logs:** If the agent’s traffic goes through an Azure Firewall or on-premises proxy, those logs should be checked for blocked requests corresponding to the ARM calls.

   *These actions are typically done through Azure Portal or Azure CLI and may be outside the scope of this lab environment.* If available, document any findings from these external diagnostics in a text file (e.g., `Network/azure_nsg_flow_logs_summary.txt` summarizing what you found). For instance, note if NSG logs show drops for the agent’s IP, or if Connection Monitor reports a specific hop as problematic.

   ✅ **Verify:** Ensure any external log data you collected is saved to the Diagnostics folder. Even if this section is optional, having a record (even “Checked NSG logs - all clear”) is valuable for completeness.

By the end of Step 3, you should have a clear picture of the network path and routing from the agents to Azure. We’ve also set the stage for identifying if network devices or policies could be intermittently interfering (e.g., a certain router dropping traffic occasionally, or a firewall applying rate limits). If the issue tends to occur at certain times or conditions, you might compare multiple traceroutes or note if, for example, DNS resolution sometimes points to different IPs (which can happen with anycast services).

### Step 4: Collect Agent Logs & Diagnostics

When network issues occur, Azure DevOps agent logs and system logs can provide hints or at least timestamps of failures. In this step, we will collect the Azure Pipelines agent logs and any relevant system event logs around networking.

- **4.1 Azure Pipelines Agent Logs:** The self-hosted agent writes diagnostic logs to the `_diag` folder in its installation directory[4](https://github.com/microsoft/azure-pipelines-agent/blob/master/docs/troubleshooting.md). These logs include the agent’s communication with Azure DevOps and can show if the agent experienced disconnects or errors (for example, the “We stopped hearing from agent...” error)[5](https://stackoverflow.com/questions/66134088/azure-devops-self-hosted-agent-error-connectivity-issues)[5](https://stackoverflow.com/questions/66134088/azure-devops-self-hosted-agent-error-connectivity-issues). We will copy the latest agent log and any recent worker log.

   **Windows (PowerShell):**
   ```powershell
   # Set the path to your agent installation directory
   $AgentDir = "C:\agent"   # (Replace with actual path if different)
   Copy-Item -Path "$AgentDir\_diag\Agent_*.log" -Destination C:\Diagnostics\NetworkLab\AgentLogs\ -Force
   Copy-Item -Path "$AgentDir\_diag\Worker_*.log" -Destination C:\Diagnostics\NetworkLab\AgentLogs\ -Force
   ```
   This assumes your agent is installed in `C:\agent`. Adjust `$AgentDir` if not (e.g., `C:\AzureDevOpsAgent\` or other custom path). We copy all Agent and Worker logs for completeness. The Agent logs cover the agent listener process (running as a service), and Worker logs cover individual pipeline job runs[4](https://github.com/microsoft/azure-pipelines-agent/blob/master/docs/troubleshooting.md).

   ✅ **Verify:** List the files in `C:\Diagnostics\NetworkLab\AgentLogs` (`Get-ChildItem C:\Diagnostics\NetworkLab\AgentLogs`). You should see files like `Agent_<timestamp>.log` (one or more) and possibly `Worker_<timestamp>.log`. Open the most recent Agent log (`Select-String "ERROR" C:\Diagnostics\NetworkLab\AgentLogs\Agent_*.log`) and see if any errors or warnings are present. Also search for keywords like "Network" or "connection" around the time of known failures. Even if you don’t analyze deeply, confirm the logs have content (not zero-byte files).

   **Linux (Bash):**
   ```bash
   # Set the path to your agent installation directory
   AGENT_DIR="$HOME/azure-pipelines-agent"   # (Replace with actual path if different)
   cp $AGENT_DIR/_diag/Agent_*.log ~/Diagnostics/NetworkLab/AgentLogs/ 2>/dev/null
   cp $AGENT_DIR/_diag/Worker_*.log ~/Diagnostics/NetworkLab/AgentLogs/ 2>/dev/null
   ls -l ~/Diagnostics/NetworkLab/AgentLogs/ > ~/Diagnostics/NetworkLab/AgentLogs/ls_agentlogs.txt
   ```
   Replace `AGENT_DIR` with the actual path where the agent is installed (for example `/mnt/agent`, `/home/<user>/myagent`, etc., depending on how you set it up). The `ls -l` command writes a directory listing to confirm which logs were copied.

   ✅ **Verify:** Check the `ls_agentlogs.txt` listing to see the copied log files. Use `grep "ERROR" ~/Diagnostics/NetworkLab/AgentLogs/Agent_*.log -C3` to see any error lines with a few lines of context. Also consider searching for the string "Job" or "Handshake" to see if there were connection attempts logged. A healthy agent log will show periodic successful communications; if there were network interruptions, you might see error entries or reconnect attempts around those times[5](https://stackoverflow.com/questions/66134088/azure-devops-self-hosted-agent-error-connectivity-issues).

   *Note:* If your agent is running as a service, ensure the user running these copy commands has permission to read the agent’s folder (you might need to `sudo` on Linux or open an Administrator PowerShell on Windows).

- **4.2 System Event Logs (Windows-specific):** Check Windows Event Viewer for any network-related errors around the times of failure. For example, look at System logs for NIC disconnects or DNS client events.

   **Windows (PowerShell):**
   ```powershell
   Get-WinEvent -FilterHashtable @{LogName="System"; StartTime=(Get-Date).AddDays(-1)} | ` 
       Where-Object {$_.Message -match "TCPIP" -or $_.Message -match "DNS" -or $_.Message -match "Network"} | `
       Export-Csv C:\Diagnostics\NetworkLab\AgentLogs\windows_system_events.csv -NoTypeInformation
   ```
   This fetches events from the System log in the last day (adjust time as needed) and filters for keywords "TCPIP", "DNS", or "Network". The output is saved as a CSV for readability.

   ✅ **Verify:** Open the CSV (it can be opened in Excel or a text editor). Look for events that coincide with your pipeline failure times. For instance, DNS client events (event ID 1014) could indicate name resolution issues; network link down/up events could indicate connectivity blips.

   **Linux:** System logs (like `/var/log/syslog` or `/var/log/messages`) might contain relevant info (e.g., DHCP renewals, DNS errors). If you suspect issues, you can search those logs similarly:
   ```bash
   sudo grep -Ei "dns|network|eth|tcp" /var/log/syslog > ~/Diagnostics/NetworkLab/AgentLogs/linux_syslog_snippet.txt
   ```
   (The exact log file and interface keywords might differ by distro.) This step is optional and for thoroughness.

   ✅ **Verify:** Check `linux_syslog_snippet.txt` for timestamps that match failures, or any recurring network error messages (like `named`/`systemd-resolved` errors for DNS, or `Link is Down/Up` for interface flaps).

- **4.3 Agent Diagnostic Mode (Optional):** Azure Pipelines agents have a diagnostic mode that can capture additional info, including environment variables and network configuration at runtime. If you set the pipeline variable `System.Debug` to true (or `Agent.Diagnostic` to true) and run a build, the agent will produce extra logs such as `environment.txt` and `capabilities.txt`[1](https://learn.microsoft.com/en-us/azure/devops/pipelines/troubleshooting/review-logs?view=azure-devops). If you have done this for a test run, include those logs in your package.

   For example, after running a pipeline with diagnostics:
   - Download the pipeline logs (from Azure DevOps pipeline results, via the UI or Azure CLI). Inside the log bundle, find `environment.txt` and `capabilities.txt` for the agent.
   - Save those files to `Diagnostics/NetworkLab/AgentLogs/` (e.g., `environment.txt` for Windows might show if the firewall was enabled, PowerShell version, etc., which we partially gathered manually[1](https://learn.microsoft.com/en-us/azure/devops/pipelines/troubleshooting/review-logs?view=azure-devops)).

   ✅ **Verify:** Ensure any such diagnostic files are added. They are very useful for support, as they systematically capture the agent’s environment at run time (for instance, confirming that environment variables like proxy settings or `VSTS_AGENT_HTTPTRACE` were in effect, which can be crucial).

By the end of Step 4, your diagnostics folder contains the agent’s own logs and possibly system events. These logs chronicle the agent’s perspective and timing. For example, if the agent lost connectivity to Azure DevOps for 2 minutes, you might see that timestamp, which you could correlate with external factors (such as a network device issue at that time). We still refrain from deep analysis, but by collecting these, we ensure that nothing will be lost if the issue needs escalation.

### Step 5: (Optional) Capture Live Network Traffic

*This step is optional and recommended only if previous steps haven’t yielded clues, or if you need to catch the intermittent failure in action.* Capturing network packets can provide the most granular detail (e.g., TLS handshake failures, DNS query timeouts, etc.), but it requires care with sensitive data and can generate large files. We will demonstrate a *targeted* capture around the ARM endpoint communication.

- **5.1 Prepare for Packet Capture:** Choose a time window when the intermittent issue is likely to occur (if known). We will capture packets only to the relevant Azure endpoints to limit data. Identify the IP address(es) from the earlier DNS lookup for `management.azure.com`. Suppose it resolved to an IP like `13.82.x.x`; we’ll filter on that.

   **Windows:** If available, use the built-in **Packet Monitor (Pktmon)** or any installed tool like Wireshark. For Pktmon (Windows 10/Server 2019 and above):
   ```powershell
   pktmon filter add -t addr -v <Azure_IP_Address>
   pktmon start --capture --file C:\Diagnostics\NetworkLab\Network\azure_capture.etl
   ```
   This sets a filter for traffic to the Azure ARM IP and starts capturing to an ETL file.

   Next, trigger some network activity to ARM (for example, rerun the connectivity test or pipeline step that calls Azure). Let it run for a short period where the issue might occur, then stop capturing:
   ```powershell
   pktmon stop
   pktmon etl2pcap C:\Diagnostics\NetworkLab\Network\azure_capture.etl -o C:\Diagnostics\NetworkLab\Network\azure_capture.pcap
   ```
   The above converts the capture to PCAP format for analysis in Wireshark or other tools.

   ✅ **Verify:** Ensure `azure_capture.pcap` is created and has a non-zero file size. You can use `Get-Item C:\Diagnostics\NetworkLab\Network\azure_capture.pcap | Select Length` to see its size. If Pktmon is not available or this is too advanced, you may skip or use an alternative like Wireshark’s GUI (not covered in this text-based lab).

   **Linux (Bash):**
   ```bash
   sudo tcpdump -w ~/Diagnostics/NetworkLab/Network/azure_capture.pcap -n host management.azure.com &
   ```
   This starts a background tcpdump capturing traffic to/from the ARM endpoint. The `-n` prevents DNS lookups (we already know the name). Keep it running only for the necessary duration.

   Now, trigger the problematic traffic or simply wait for the interval when the issue tends to happen. After that, stop the capture:
   ```bash
   sudo pkill tcpdump
   ```
   (This finds and stops the tcpdump process.)

   ✅ **Verify:** Confirm `azure_capture.pcap` exists in the `Network` folder and is not empty (`ls -lh ~/Diagnostics/NetworkLab/Network/azure_capture.pcap` to see file size). You can inspect a summary of the capture with a tool like `tcpdump -r azure_capture.pcap -c 10` (which reads the first 10 packets) to ensure it captured data. Look for packets going to or from the known Azure IP or on port 443 to confirm it contains the relevant traffic.

   > **Troubleshooting Note:** Packet captures may contain sensitive information (IP addresses, possibly JWT tokens in headers, etc.). Handle these files carefully. Do **not** post them publicly without sanitization[4](https://github.com/microsoft/azure-pipelines-agent/blob/master/docs/troubleshooting.md). In a real scenario, share them only with trusted colleagues or support engineers who need them, and over secure channels.

- **5.2 Interpret Capture (Minimal Analysis):** Without going deep into analysis, perform a quick check on the capture to see if it *recorded* an error. For instance, you might open the PCAP in Wireshark and apply a filter for `tcp.analysis.retransmission` or `dns` to see if there were failed connections or DNS retries. If analyzing isn’t feasible right now, simply note that the capture is available.

   If you do identify something obvious (e.g., repeated TCP retransmissions or a TLS handshake that never completes), you can write that observation in a note for later. For example, “Captured traffic shows 3 TCP retransmissions before success” or “DNS query sent 5 times with no response in capture at 10:05:30 UTC”.

   ✅ **Verify:** Even if not doing full analysis, ensure the capture process didn’t disrupt the agent (it shouldn’t, but high-volume captures can sometimes affect performance slightly). Everything should be running as normal, and we have the raw packet data for the record.

After Step 5, you have an optional but powerful piece of evidence: a packet-level timeline of what happened on the wire. This can definitively show if, for example, the agent sent a request and got no reply, or if there was a TCP reset from some device, etc. Such detail is typically only needed if other logs are inconclusive, but having it can drastically speed up expert analysis later.

### Step 6: Package and Organize the Findings

Now that all relevant data is collected, the final step is to organize it into a format that can be easily consumed by others (colleagues or Microsoft support). We will create a summary README and then archive the diagnostics.

- **6.1 Create a Summary README:** In the root `NetworkLab` folder, create a README file (Markdown or text) that provides an overview of the issue and lists the collected artifacts. This helps anyone receiving the bundle to quickly understand context and contents.

   **All OS (choose your preferred editor or echo commands):** Create a file `Diagnostics/NetworkLab/README.md` with content similar to:

   ```text
   # Network Diagnostics Summary - Azure DevOps Agent

   **Issue Description:** Intermittent network failures when Azure DevOps self-hosted agents connect to Azure Resource Manager (ARM) endpoints. Pipeline tasks occasionally fail with network timeouts.

   **Environment:**  
   - Windows Agent: Windows Server 2019, Azure Pipelines Agent v2.218.1  
   - Linux Agent: Ubuntu 20.04, Azure Pipelines Agent v2.218.1  
   - Both agents located in on-prem datacenter behind corporate firewall (with outbound internet via proxy).

   **Data Collected:**  
   - System info: OS version, network config (`System/windows_systeminfo.txt`, `Network/windows_ipconfig.txt`, etc.)  
   - DNS resolution outputs (`DNS/windows_dns.txt`, `DNS/linux_dns.txt`)  
   - Connectivity tests (ping, port checks, traceroute in `Network/*_connectivity.txt` and `Network/*_traceroute.txt`)  
   - Azure Pipelines agent logs (`AgentLogs/Agent_*.log`, `AgentLogs/Worker_*.log`)  
   - Windows Event logs (`AgentLogs/windows_system_events.csv`)  
   - Packet capture of ARM traffic (`Network/azure_capture.pcap`) – *contains raw network packets, handle securely*.

   **Key Observations:**  
   - DNS resolution was generally successful (both agents resolve ARM endpoint to 13.82.x.x) but the Linux agent’s first DNS query timed out once.  
   - TCP connectivity tests sometimes showed high latency (~1 sec) on first attempt, then normal (<100ms).  
   - Traceroute indicates an extra hop on the on-prem network for the Windows agent that the Linux agent (in DMZ) doesn’t have. That hop (10.0.5.1) had 30% packet loss.  
   - Agent log on Windows shows an error at 2025-07-08 10:30:45, matching a DNS resolution timeout in the system event log.  
   - Packet capture confirms three DNS queries sent from Windows with no response before succeeding on the fourth query.

   **Next Steps / Recommendations:**  
   - Investigate the networking device at 10.0.5.1 for packet loss or high latency.  
   - Ensure DNS servers (10.1.1.1 and 10.1.2.2) are responsive; consider adding a secondary or using Azure DNS as forwarder.  
   - Share this collected data with the network team or open a support case with Microsoft, including all files in this package for a comprehensive analysis.
   ```

   (The above is an **example template** – use the actual observations from your case. If some data is not collected or not applicable, adjust accordingly. The goal is to concisely summarize what's in the package and highlight anything you noticed that could be relevant.)

   ✅ **Verify:** Save the README and open it to ensure formatting is correct (if Markdown, check that headings and bullet points are properly formatted). This README will be extremely useful to anyone you hand over the diagnostics to, as it prevents them from having to guess what each file is or why it was collected.

- **6.2 Final Folder Check:** Do a final review of the `NetworkLab` directory to ensure all files are present and updated. If you missed any step’s output, you can still add it now. For example, if you didn’t save a file from a console output, you can scroll up in the console and copy-paste it into a text file.

   **Windows (PowerShell):** `Get-ChildItem -Recurse C:\Diagnostics\NetworkLab | Select FullName, Length`  
   **Linux (Bash):** `find ~/Diagnostics/NetworkLab -type f -exec ls -lh {} \;`

   ✅ **Verify:** Confirm the presence of all expected files (compare with your README’s list). Ensure none of the files are unexpectedly empty or ridiculously large. If a file (like a pcap) is very large (hundreds of MB), consider whether you can truncate it or if you captured too long – large files can be hard to share. Perhaps record a note in README that such a file is large and may need special handling.

- **6.3 Archive the Diagnostics:** Finally, package the entire `NetworkLab` folder into a single archive for easy sharing.

   **Windows (PowerShell):**
   ```powershell
   Compress-Archive -Path C:\Diagnostics\NetworkLab\* -DestinationPath C:\Diagnostics\NetworkLab.zip
   ```
   This creates `NetworkLab.zip` containing the folder and all subfolders/files.

   ✅ **Verify:** Ensure the ZIP was created (`Test-Path C:\Diagnostics\NetworkLab.zip` should return True). You can also open it in File Explorer to double-check the contents.

   **Linux (Bash):**
   ```bash
   zip -r ~/Diagnostics/NetworkLab.zip ~/Diagnostics/NetworkLab
   ```
   If the `zip` utility is not installed, you can use `tar`:  
   ```bash
   tar -czf ~/Diagnostics/NetworkLab.tgz -C ~/Diagnostics NetworkLab
   ```
   which produces a tarball `.tgz` file.

   ✅ **Verify:** List the archive file (`ls -lh ~/Diagnostics/NetworkLab.zip` or `.tgz`) to see its size. Test the archive integrity if possible (e.g., `unzip -l ~/Diagnostics/NetworkLab.zip` to list contents, or `tar -tzf NetworkLab.tgz` for tarball). This ensures the archive isn’t corrupted and includes everything.

Your diagnostic bundle is now ready! It contains all the gathered evidence and the summary README. This package can be shared with your network specialists or Azure support. With this comprehensive collection, **success** means that even if you hand off the issue, the next person has all the data needed to identify the root cause (be it a DNS misconfiguration, a firewall blocking intermittent calls, an Azure issue, etc.) without having to rerun all these steps.

---

## Troubleshooting Tips

- **Insufficient Permissions:** If some commands failed (especially on Windows) due to permissions (e.g., accessing certain logs or running `pktmon` requires Admin), rerun the specific steps in an elevated prompt. On Linux, ensure you used `sudo` where needed (for example, `tcpdump` and reading system logs).

- **Command Not Found:** If a tool like `dig` or `traceroute` wasn’t available, install the corresponding package (`nslookup` can substitute for `dig`, and `tracepath` or installing the `inetutils-traceroute` package can provide `traceroute`). On Windows, all used tools are built-in (in PowerShell 5+), but if using PowerShell Core on Linux, note that `Test-NetConnection` might not be available there – in such cases use `ping`/`nc` as we did for Linux.

- **Interpreting Partial Traceroute Results:** It’s normal for some hops in traceroute to show `* * *` for no response. What’s important is whether the trace reaches the destination or if it fails consistently at an intermediate hop. If the final hop is unreachable but earlier ones are fine, the network path is likely okay (Azure endpoints often won’t respond to traceroute). Look for drastic changes in latency in the hops or a specific hop where things start to time out frequently.

- **DNS Variability:** DNS queries might go to different servers if you have multiple configured. If you see one query fail and another succeed, it could be that one DNS server is having issues. You might repeat the `Resolve-DnsName`/`dig` step multiple times to see if the resolution is sometimes slow or failing. Use the `-Server` option in `Resolve-DnsName` or `dig @<dns-server>` to test each configured DNS server individually if needed.

- **Using Agent Diagnostic Logs:** If you enabled `System.Debug=true` for a pipeline run, remember that the agent diagnostic logs (like `environment.txt`) are included in the pipeline logs download, not left on the agent machine file system. Ensure you retrieved them from the Azure DevOps pipeline UI or CLI. These can save you from manually collecting some info. For example, `environment.txt` would have told you the firewall was enabled on Windows and its profile[1](https://learn.microsoft.com/en-us/azure/devops/pipelines/troubleshooting/review-logs?view=azure-devops), and listed all environment variables.

- **Time Synchronization:** Rarely, clock drift can cause what appear to be network issues (e.g., failing authentication if clocks differ too much). We didn’t explicitly check it, but if you suspect it, verify the system time against an internet time service. Ensure NTP is working properly on Linux and the Windows Time service is operational.

- **If Issue is Not Found:** Sometimes, after gathering all this data, everything might *look* normal in the captures (that’s good to rule things out, but frustrating). In such cases, consider factors like:
  - Intermittent proxy or firewall issues that occur only under load or specific conditions (you might need to involve the network team to monitor those devices during pipeline runs).
  - Azure side throttling or service issues: Check the Azure Service Health for your region around the failure times[2](https://learn.microsoft.com/en-us/answers/questions/2260076/best-practices-for-preventing-and-mitigating-inter). There could be an intermittent platform issue. If so, documenting it will help in the support case.
  - Agent machine resource issues: High CPU or memory on the agent could make it slow to handle network operations (the Stack Overflow discussion noted agents being starved of CPU can drop connections[5](https://stackoverflow.com/questions/66134088/azure-devops-self-hosted-agent-error-connectivity-issues)). Check if the agent machines had high load (you might see signs of this in pipeline logs if tasks took unusually long or in agent logs with heartbeat delays).

Always remember to **revert any changes** made for diagnostics in a production environment once finished (like disabling extra logging or removing packet capture filters) to avoid impacting normal operation.

## Cleanup

After completing the lab and resolving the issue (or handing off the data), perform these cleanup actions:

- **Remove Sensitive Data:** If you will share the diagnostic bundle externally, review the files for any secrets or sensitive info. Mask things like internal IP ranges (if necessary) or user account names as appropriate for your organization’s policies.

- **Delete Diagnostic Files (Optional):** On the agent machines, you may delete the `Diagnostics/NetworkLab` folder if it’s no longer needed, especially if it contains sensitive or bulky files (e.g., packet captures). Since we archived everything, you can safely remove the working directory:
  - Windows: `Remove-Item -Recurse -Force C:\Diagnostics\NetworkLab` (and the `.zip` if copied off-machine).  
  - Linux: `rm -rf ~/Diagnostics/NetworkLab` (and the archive file).

- **Reset Configurations:**  
  - If you set any environment variables for debugging (like `VSTS_AGENT_HTTPTRACE=true` or proxy settings) when running the agent, remove them or revert the agent service to normal operation[1](https://learn.microsoft.com/en-us/azure/devops/pipelines/troubleshooting/review-logs?view=azure-devops). For example, on Windows you might have to unset the variable or remove it from the machine's Environment Variables.  
  - If any special logging was enabled (such as System.Debug in pipelines or verbose logging on applications), turn those off to reduce noise and performance overhead.

- **Network Watcher Resources:** If you created any Azure Network Watcher tests (Connection Monitor, etc.) or enabled NSG flow logs to a storage account for this investigation, consider cleaning those up if they are incurring cost and are no longer needed. For instance, stop any running Connection Monitor tests and remove diagnostic settings that were added solely for troubleshooting.

- **Agent Reconfiguration (if applicable):** In extreme cases, you might have reconfigured the agent or upgraded it during troubleshooting. Ensure the agent is back to a stable state (running the latest version, in service mode if it was originally a service, etc.). If you installed additional tools on the agent (like Wireshark or traceroute), evaluate if they should be kept for future use or removed for security.

By cleaning up, we ensure that the agent machines remain in their baseline state and that no unnecessary services or files linger. This also prevents future confusion (e.g., someone else stumbling on leftover diagnostic files later).

## Reflection Questions

1. **Windows vs. Linux:** How did the troubleshooting process differ between Windows and Linux agents? Identify one advantage each OS had in diagnosing the issue (e.g., Windows Event Viewer logs vs. Linux flexibility with tools).  
2. **Preventative Measures:** Based on the data collected, what changes would you consider to prevent similar intermittent failures? (Think about DNS configurations, network infrastructure, or agent settings like proxies and keep-alive intervals.)  
3. **Automation Opportunities:** Which parts of this diagnostics process could be automated in the future? Propose at least one way to script or tool-ify the data collection so that it could run during an incident and gather info without manual steps.  
4. **Additional Data:** In hindsight, is there any other data you wish you had collected? For example, would enabling verbose logging on the pipeline tasks or collecting performance counters add value?  
5. **Collaborating with Network Teams:** How would you effectively communicate these findings to a networking team or Azure support? What key evidence would you highlight to justify that the problem lies in the network vs. the application?

Consider these questions and discuss with your team or mentor. They will help reinforce the diagnostic steps taken and encourage thinking about making network troubleshooting a proactive and smoother experience in the future.