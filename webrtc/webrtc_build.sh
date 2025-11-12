# Install depot_tools to home directory
cd ~
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH="$HOME/depot_tools:$PATH"
echo 'export PATH="$HOME/depot_tools:$PATH"' >> ~/.bashrc

# Create WebRTC workspace (you can use any folder you want)
mkdir -p ~/webrtc_build
cd ~/webrtc_build

# Fetch WebRTC source code
fetch --nohooks webrtc
cd src

# Sync all dependencies
gclient sync

gn gen out/Release --args='
  is_debug=false
  target_os="linux"
  target_cpu="x64"
  rtc_include_tests=false
  rtc_build_examples=false
  rtc_build_tools=false
  use_rtti=true
  treat_warnings_as_errors=false
  use_custom_libcxx=false
  is_clang=false
  use_sysroot=false
  rtc_enable_protobuf=false
  rtc_use_h264=true
  proprietary_codecs=true
'

# Build WebRTC library (this takes 30-90 minutes)
ninja -C out/Release webrtc

