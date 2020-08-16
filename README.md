# theta_mpeg_viewer

![Screenshot of MotionJPEG Viewer](doc/images/motion3.gif)

Viewer for motionJPEG stream from RICOH THETA SC2

Tested with firmware 1.31

## Status

Test above was done at 5fps due to a 200ms delay inserted for
testing.  Plan to rewrite code to eliminate the 
delay.

buffer is holding the header of the JPEG frame and I need to 
grab the sublist from element 73 of the array.  Plan to rewrite
this to look for the start of the frame at FF D8 again.

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
