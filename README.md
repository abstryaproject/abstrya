# abstrya
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
<title>Abstrya</title>

<style>
:root {
  --bg: #ffffff;
  --text: #1E90FF;
  --input-bg: #1E90FF;
  --input-text: #ffffff;
  --placeholder: #ccc;
  --accent: #1E90FF;
  --status-warn: #ffb400;
  --status-error: #ff4444;
  --status-ok: #1E90FF;
}

[data-theme="dark"] {
  --bg: black;
  --text: #1E90FF;
  --input-bg: #1E90FF;
  --input-text: #222;
  --placeholder: #222;
  --accent: #87CEFA;
  --status-warn: #ffd24d;
  --status-error: #ff6666;
  --status-ok: #6ab8ff;
}

/* Main Body Layout */
body {
  background: var(--bg);
  color: var(--text);
  font-family: "Segoe UI", Arial, sans-serif;
  margin: 0;
  padding: 0;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  text-align: center;
  padding: 0 12px;
}

/* Center Content Wrapper */
.main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

/* Logo responsive */
.logo {
  width: clamp(150px, 60%, 260px);
  height: auto;
  margin-bottom: 1rem;
  transition: opacity .3s ease;
}

/* Input box */
input[type=url] {
  width: 90%;
  max-width: 480px;
  padding: 14px;
  font-size: 16px;
  border: none;
  border-radius: 10px;
  text-align: center;
  background: var(--input-bg);
  color: var(--input-text);
}

input[type=url]::placeholder {
  color: var(--placeholder);
}

#addrType, #status {
  margin-top: 8px;
  font-weight: bold;
  font-size: 14px;
}

/* Footer pinned to bottom */
.footer {
  width: 100%;
  text-align: center;
  padding: 10px 0;
  font-size: 0.9rem;
  opacity: 0.85;
  position: fixed;
  bottom: 5px;
}

/* Theme toggle button */
.theme-toggle {
  position: fixed;
  top: 12px;
  right: 12px;
  background: none;
  border: 2px solid var(--text);
  border-radius: 50%;
  padding: 10px;
  font-size: 18px;
  cursor: pointer;
  color: var(--text);
  transition: 0.3s;
  z-index: 10;
}
.theme-toggle:hover {
  background: var(--text);
  color: var(--bg);
}
</style>

<script>
function setTheme(mode) {
  document.documentElement.setAttribute("data-theme", mode);
  localStorage.setItem("theme", mode);
  updateLogo();
}
function toggleTheme() {
  const cur = document.documentElement.getAttribute("data-theme");
  setTheme(cur === "dark" ? "light" : "dark");
}
function loadTheme() {
  const saved = localStorage.getItem("theme") ||
    (window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light");
  setTheme(saved);
}
function updateLogo() {
  const logo = document.querySelector(".logo");
  if (!logo) return;
  const mode = document.documentElement.getAttribute("data-theme");
  logo.style.opacity = "0";
  setTimeout(() => {
    logo.src = mode === "dark" ? "./logo1.png" : "./logo.png";
    logo.style.opacity = "1";
  }, 150);
}
async function tryConnect() {
  const input = document.getElementById('addr');
  const status = document.getElementById('status');
  const typeLabel = document.getElementById('addrType');
  let raw = input.value.trim();

  if (!raw) {
    typeLabel.textContent = 'Type: ⚠️ None';
    status.textContent = 'Please enter an address.';
    typeLabel.style.color = status.style.color = getComputedStyle(status).getPropertyValue('--status-error');
    return;
  }

  let url = raw;
  if (!/^https?:\/\//i.test(url)) url = 'https://' + url;

  let hostname;
  try { hostname = new URL(url).hostname; }
  catch {
    typeLabel.textContent = 'Type: ⚠️ Invalid Format';
    typeLabel.style.color = 'var(--status-error)';
    status.textContent = 'Invalid address format.';
    status.style.color = 'var(--status-error)';
    return;
  }

  const ipv4Pattern = /^(25[0-5]|2[0-4]\d|[0-1]?\d{1,2})(\.(25[0-5]|2[0-4]\d|[0-1]?\d{1,2})){3}$/;
  const ipv6Pattern = /^(([0-9a-fA-F]{0,4}:){1,7}[0-9a-fA-F]{0,4})$/;
  const isIPv4 = ipv4Pattern.test(hostname);
  const isIPv6 = ipv6Pattern.test(hostname);
  const isLocalhost = hostname === 'localhost' || hostname === '::1' || hostname.startsWith('127.');
  const isPrivateIP =
    isIPv4 &&
    (hostname.startsWith('10.') ||
     hostname.startsWith('192.168.') ||
     /^172\.(1[6-9]|2\d|3[0-1])\./.test(hostname));
  const isPublicIP = isIPv4 && !isLocalhost && !isPrivateIP;
  const isLocalDomain = hostname.endsWith('.local');
  const isOnion = hostname.endsWith('.onion');

  const setType = (label, color = 'var(--status-ok)') => {
    typeLabel.textContent = `Type: ${label}`;
    typeLabel.style.color = color;
  };

  const tryFetch = async (target, timeout = 200000) => {
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), timeout);
    try {
      await fetch(target, { mode: 'no-cors', cache: 'no-store', signal: controller.signal });
      clearTimeout(timer);
      return true;
    } catch {
      clearTimeout(timer);
      return false;
    }
  };

  if (isOnion) {
    setType('🕸️ Dark Web (.onion)');
    status.textContent = 'Checking...';
    status.style.color = 'var(--status-warn)';
    if (!/^http:\/\//i.test(raw)) url = 'http://' + hostname;

    try {
      await fetch(url, {mode: 'no-cors'});
      status.textContent = 'Tor Proxy detected. Opening...';
      status.style.color = 'var(--status-ok)';
      window.location.href = url;
    } catch {
      status.innerHTML = "⚠️ Onion cannot open directly.<br>Enable Tor Proxy: 127.0.0.1:8118";
      status.style.color = 'var(--status-error)';
    }
    return;
  }

  if (isLocalhost || isPrivateIP || isLocalDomain) {
    if (isLocalDomain) setType('🏠 .local Domain');
    else if (isLocalhost) setType('🖥️ Localhost');
    else setType('🏠 Private IP');

    status.textContent = 'Connecting locally…';
    status.style.color = 'var(--status-warn)';
    const ok = await tryFetch(url);
    if (ok) {
      status.textContent = 'Connected. Opening...';
      status.style.color = 'var(--status-ok)';
      window.location.href = url;
    } else {
      status.textContent = 'Local server offline.';
      status.style.color = 'var(--status-error)';
    }
    return;
  }

  if (isPublicIP || isIPv6) {
    setType('🌍 Public IP');
    status.textContent = 'Checking IP…';
    status.style.color = 'var(--status-warn)';
    const ok = await tryFetch(url);
    if (ok) {
      status.textContent = 'Connected. Opening...';
      status.style.color = 'var(--status-ok)';
      window.location.href = url;
    } else {
      status.textContent = 'Public IP not reachable.';
      status.style.color = 'var(--status-error)';
    }
    return;
  }

  setType('🌐 Domain Lookup');
  status.textContent = 'Checking DNS…';
  status.style.color = 'var(--status-warn)';

  try {
    const dnsResponse = await fetch(`https://dns.google/resolve?name=${hostname}`);
    const dnsData = await dnsResponse.json();
    if (!dnsData.Answer || dnsData.Status !== 0) {
      status.textContent = 'Invalid or unknown domain.';
      status.style.color = 'var(--status-error)';
      setType('⚠️ Unknown Domain', 'var(--status-error)');
      return;
    }
  } catch {
    status.textContent = 'DNS Check failed.';
    status.style.color = 'var(--status-error)';
    return;
  }

  status.textContent = 'Connecting…';
  status.style.color = 'var(--status-warn)';
  const ok = await tryFetch(url);

  if (ok) {
    status.textContent = 'Connected. Opening...';
    status.style.color = 'var(--status-ok)';
    window.location.href = url;
  } else {
    status.textContent = 'Server unreachable.';
    status.style.color = 'var(--status-error)';
  }
}

document.addEventListener('DOMContentLoaded', () => {
  loadTheme();
  updateLogo();
  document.getElementById('addr').addEventListener('keydown', e => {
    if (e.key === 'Enter') tryConnect();
  });
});
</script>
</head>

<body>
<button class="theme-toggle" onclick="toggleTheme()">🌓</button>

<div class="main-content">
  <img src="./logo.png" class="logo" alt="Abstrya OS">
  <input id="addr" type="url" placeholder="Enter domain or IP address">
  <div id="addrType"></div>
  <div id="status"></div>
</div>

<div class="footer"><b>Powered by Abdullahi Ibrahim Lailaba</b></div>
</body>
</html>
