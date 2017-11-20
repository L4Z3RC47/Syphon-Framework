#### Experimental

Note - this is an experimental, non production capable branch of Syphon which aims to add Metal API support for sharing textures between applications. This branch currently supports Core Profile + Legacy OpenGL, as well as Metal MTLTexture sharing (Server only as of this commit). Note you can share textures between all 3 API's. So a Metal App can serve frames to a Legacy GL application, which can share frames to a Core Profile application.

#### Metal general usage.

If you have a MKView drawable you present, and you want to share the color attachment, ensure the MKView's framebufferOnly property is set to no - this ensures that the color attachment is a valid texture to be sampled within the Syphon process

Once you schedule the presentation of your drawable you can publish via a call similar to:

```
[self.server publishFrameTexture:self.view.currentDrawable.texture imageRegion:NSMakeRect(0,0,self.view.currentDrawable.texture.width, self.view.currentDrawable.texture.height)];
```

#### Syphon

Syphon is an open source Mac OS X technology that allows applications to share video and still images with one another in realtime. 

See http://syphon.v002.info for more information.

This project hosts the Syphon.framework for developers who want to integrate Syphon in their own software. If you are looking for the Syphon plugins for Quartz Composer, Max/Jitter, FFGL, etc, the project for the Syphon Implementations currently at http://github.com/Syphon

