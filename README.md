# theta_mpeg_viewer

![Screenshot of MotionJPEG Viewer](doc/images/motion_5.gif)

Viewer for motionJPEG stream from RICOH THETA SC2

Tested with firmware 1.31

## Status
Rewrite app to isolate updating of stateful widgets.  The counter at the buttom
is likely causing white flickers to the screen.

## gaplessPlayback

Implemented 
[gaplessPlayback](https://api.flutter.dev/flutter/widgets/Image/gaplessPlayback.html) property.

## precacheImage

I used [precacheImage](https://api.flutter.dev/flutter/widgets/precacheImage.html) to eliminate a white flickering problem.  
I'm not sure when the cache is cleared or if the physical 
device will run out of memory.

```dart
Image cachedImage = Image.memory(
  Uint8List.fromList(
    buf.sublist(73, buf.length),
  ),
);
precacheImage(cachedImage.image, context);
setState(() {
  frameImage = cachedImage;
});
```


## Reference

https://gist.github.com/alexeyismirnov/ff71b4ddfd29b650b20b20dc5249619a
