import 'dart:js';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/material_slider/material_slider.dart';

import 'dart:async';
import 'dart:html';
import 'dart:convert';

import 'package:gif_dart/gif_dart.dart';
import 'package:image/image.dart';

// AngularDart info: https://webdev.dartlang.org/angular
// Components info: https://webdev.dartlang.org/components

@Component(
  selector: 'my-app',
  providers: [materialProviders],
  directives: [MaterialSliderComponent],
  styleUrls: ['app_component.css'],
  templateUrl: 'app_component.html',
)
class AppComponent implements AfterViewInit {
  int minDistance = 1;
  int maxDistance = 200;
  int distance = 1;
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
                    distance) {
                  image.setPixelRgba(j, i, 0, 0, 0, 0);
                }
              }
            }
          }
        });
      });
    });

    ButtonElement button = querySelector('#saveButton');
    var gif = GIF(Options(workers: 10, quality: 10, transparent: 'rgba(0,0,0,0)'));
    button.onClick.listen((onData) {
      for (var image in gifAnimation) {
        var canvas = CanvasElement();
        canvas.width = image.width;
        canvas.height = image.height;
        var imageData =
            canvas.context2D.createImageData(image.width, image.height);
        imageData.data.setRange(0, imageData.data.length, image.getBytes());
        canvas.context2D.putImageData(imageData, 0, 0);
        gif.addFrame(canvas, AddFrameOptions(delay: 33, copy: true));
      }
      gif.on('finished', allowInterop((blob, tmp) {
        window.open(Url.createObjectUrl(blob), 'gif');
      })).render();

      //var bytes = encoder.finish();
      //print(bytes.sublist(bytes.length-20, bytes.length));
      //final gif64 = base64.encode(bytes);
      //final gif = ImageElement()..src = 'data:image/gif;base64,${gif64}';
      //document.body.append(gif);

      //var png = encodePng(gifAnimation[0]);
      //final png64 = base64.encode(png);
      //final pngElement = ImageElement()..src = 'data:image/png;base64,${png64}';
      //document.body.append(pngElement);

      //window.open(Url.createObjectUrl(Blob(bytes)), 'gif');
    });
  }
}
