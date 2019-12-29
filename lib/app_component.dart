import 'dart:async';
import 'dart:html';
import 'dart:convert';

import 'package:angular/angular.dart';
import 'package:image/image.dart';

// AngularDart info: https://webdev.dartlang.org/angular
// Components info: https://webdev.dartlang.org/components

@Component(
  selector: 'my-app',
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
)
class AppComponent implements AfterViewInit {
  @override
  void ngAfterViewInit() async {
    var colorList = [];
    Animation gifAnimation;
    InputElement input = querySelector('#loadFile');
    input.onChange.listen((changeData) {
      var file = input.files[0];
      var reader = FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoad.listen((fileEvent) {
        gifAnimation = decodeGifAnimation(reader.result);
        var image = gifAnimation[0];

        CanvasElement canvas = querySelector('#canvas');
        canvas.width = image.width;
        canvas.height = image.height;

        var index = 0;
        Timer.periodic(const Duration(milliseconds: 33), (Timer t) {
          if (0 <= index && index < gifAnimation.length) {
            var imageData = canvas.context2D.createImageData(
                gifAnimation[index].width, gifAnimation[index].height);
            imageData.data.setRange(
                0, imageData.data.length, gifAnimation[index].getBytes());
            canvas.context2D.putImageData(imageData, 0, 0);
            index = index + 1;
          } else {
            index = 0;
            var imageData = canvas.context2D.createImageData(
                gifAnimation[index].width, gifAnimation[index].height);
            imageData.data.setRange(
                0, imageData.data.length, gifAnimation[index].getBytes());
            canvas.context2D.putImageData(imageData, 0, 0);
            index = index + 1;
          }
        });
        canvas.onClick.listen((onData) {
          var x = onData.offset.x;
          var y = onData.offset.y;

          var pixsel = canvas.context2D.getImageData(x, y, 1, 1);
          print(pixsel.data);
          var color = Color.fromRgba(
              pixsel.data[0], pixsel.data[1], pixsel.data[2], pixsel.data[3]);
          var tmpAnimation = gifAnimation;
          for (var image in tmpAnimation) {
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
                    100) {
                  image.setPixelRgba(j, i, 0, 0, 0, 0);
                }
              }
            }
          }
        });

        canvas.onTouchEnd.listen((e) {
          var tmpAnimation = gifAnimation;
          for (var image in tmpAnimation) {
            for (var i = 0; i < image.height; i++) {
              for (var j = 0; j < image.width; j++) {
                for (var color in colorList) {
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
                      100) {
                    image.setPixelRgba(j, i, 0, 0, 0, 0);
                  }
                }
              }
            }
          }
        });
        canvas.onTouchMove.listen((onData) {
          int x = onData.touches[0].client.x -
              canvas.getBoundingClientRect().left.toInt();
          int y = onData.touches[0].client.y -
              canvas.getBoundingClientRect().top.toInt();

          var pixsel = canvas.context2D.getImageData(x, y, 1, 1);
          print(pixsel.data);
          var ca = Color.fromRgba(
              pixsel.data[0], pixsel.data[1], pixsel.data[2], pixsel.data[3]);
          if (!colorList.contains(ca)) colorList.add(ca);
          for (var i = 0; i < image.height; i++) {
            for (var j = 0; j < image.width; j++) {
              if (image.getPixel(j, i) == ca) {
                image.setPixelRgba(j, i, 0, 0, 0, 0);
              }
            }
          }

          var imageData =
              canvas.context2D.createImageData(image.width, image.height);
          imageData.data.setRange(0, imageData.data.length, image.getBytes());
          canvas.context2D.putImageData(imageData, 0, 0);
        });
      });
    });

    ButtonElement button = querySelector('#saveButton');
    final encoder = GifEncoder();
    encoder.repeat = 0;
    encoder.delay = 33;
    Animation transAnimation;
    button.onClick.listen((onData) {
      for (var image in gifAnimation) {
        for (var i = 0; i < image.height; i++) {
          for (var j = 0; j < image.width; j++) {
            if (colorList.contains(image.getPixel(j, i))) {
              image.setPixelRgba(j, i, 0, 0, 0, 0);
            }
          }
        }
        encoder.addFrame(image);
      }

      var bytes = encoder.finish();
      final gif64 = base64.encode(bytes);
      final gif = ImageElement()..src = 'data:image/png;base64,${gif64}';
      document.body.append(gif);
      //window.open(Url.createObjectUrl(Blob(bytes)), 'gif');
    });
  }
}
