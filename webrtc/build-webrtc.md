
---

# **Build WebRTC (libwebrtc-bin)**

## 1. Clone

```bash
git clone https://github.com/crow-misia/libwebrtc-bin.git
cd libwebrtc-bin
```

or

```bash
git clone https://github.com/CantorAI/libwebrtc-bin-build.git
cd libwebrtc-bin-build
```

---

## 2. Requirements

* **Windows:** Visual Studio with C++ workload (`vswhere.exe` in PATH)
* **macOS:** Xcode + Command Line Tools
* **Linux:** `git`, `python3`, `cmake`, `ninja-build`, `build-essential`, `pkg-config`

---

## 3. Build

### **Windows**

```cmd
build.windows.bat
```

### **macOS / Linux**

```bash
cd build
make [options] [platform]
```

Run `make` alone to show available platforms.

---

## 4. Find Built Libraries

### **Windows**

```cmd
dir C:\webrtc_build\*.lib /s
```

* x64 libs under `x64`
* x86 libs under `x86`

### **macOS / Linux**

```bash
find . -type f \( -name "*.a" -o -name "*.so" \)
```

### for Linux we need to use gcc build libwebrtc,
  so we change to use script webrtc_build.sh
  and also make diffrent include with webrtc_build_includes.bat 
  (in windows to make the include.linux from webrtc/src)
