# ThirdPartySDK
Put all SDKs like webrtc etc inside this repo

## for Windows webrtc debug build, need to run command to make the webrtc.lib

```cmd

cd webrtc\lib\windows\debug_x64
./split_merge.bat merge webrtc.lib 

```
it will generate webrtc.lib under the same folder


# Patch in head file

ThirdPartySDK\webrtc\include.linux\pc\session_description.h
 around line 462

   //bool operator==(const ContentGroup& o) const = default;
  bool operator==(const ContentGroup& o) const {
      return semantics_ == o.semantics_ && content_names_ == o.content_names_;
  }
  if not patch will break in linux build
