import 'dart:html';
import 'dart:js';

import 'package:gif_dart/gif_dart.dart';
import 'package:image/image.dart';

class GifTransparentor {
  Animation gifAnimation;
  List<Image> tmpFrames;
  int delay;
  int width;
  int height;

  GifTransparentor(Object obj) {
    gifAnimation = decodeGifAnimation(obj);
    delay = GifDecoder().startDecode(obj).frames.first.duration * 10;
    width  = gifAnimation.first.width;
    height  = gifAnimation.first.height;
  }

  ImageData getImageData(int index) {
    var imageData = CanvasElement()
        .context2D
        .createImageData(gifAnimation[index].width, gifAnimation[index].height);
    imageData.data
        .setRange(0, imageData.data.length, gifAnimation[index].getBytes());

    return imageData;
  }

  void undo() {
    print('undo');
    gifAnimation.frames = tmpFrames;
  }

  void transparent(int color, int distance) {
    tmpFrames = List<Image>.from(gifAnimation.frames);
    for (var image in gifAnimation) {
      for (var i = 0; i < image.height; i++) {
        for (var j = 0; j < image.width; j++) {
          if (Color.distance([
                getRed(color),
                getGreen(color),
                getBlue(color),
                getAlpha(color),
              ], [
                getRed(image.getPixel(j, i)),
                getGreen(image.getPixel(j, i)),
                getBlue(image.getPixel(j, i)),
                getAlpha(image.getPixel(j, i)),
              ], false) <
              distance) {
            image.setPixelRgba(j, i, 0, 0, 0, 0);
          }
        }
      }
    }
  }

  void encode() {
    var gif =
        GIF(Options(workers: 10, quality: 10, transparent: 'rgba(0,0,0,0)'));
    gifAnimation.forEach((image) {
      var canvas = CanvasElement();
      canvas.width = image.width;
      canvas.height = image.height;
      var imageData =
          canvas.context2D.createImageData(image.width, image.height);
      imageData.data.setRange(0, imageData.data.length, image.getBytes());
      canvas.context2D.putImageData(imageData, 0, 0);
      gif.addFrame(canvas, AddFrameOptions(delay: delay, copy: true));
    });
    gif.on('finished', allowInterop((blob, tmp) {
      window.open(Url.createObjectUrl(blob), 'gif');
    })).render();
  }
}
