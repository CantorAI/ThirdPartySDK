# ThirdPartySDK
Put all SDKs like webrtc etc inside this repo

## for Windows webrtc debug build, need to run command to make the webrtc.lib

```cmd

cd webrtc\lib\windows\debug_x64
./split_merge.bat merge webrtc.lib 

```
it will generate webrtc.lib under the same folder
