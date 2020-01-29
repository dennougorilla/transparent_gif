import 'dart:js';

import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_components/material_slider/material_slider.dart';

import 'dart:async';
import 'dart:html';

import 'package:gif_dart/gif_dart.dart';
import 'package:image/image.dart';

import 'src/gif_transparentor.dart';

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
  GifTransparentor gifTransparentor;
  @override
  void ngAfterViewInit() async {
    InputElement input = querySelector('#loadFile');
    input.onChange.listen((changeData) {
      var file = input.files[0];
      var reader = FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoad.listen((fileEvent) {
        var gifTransparentor = GifTransparentor(reader.result);

        CanvasElement canvas = querySelector('#canvas');
        canvas.width = gifTransparentor.width;
        canvas.height = gifTransparentor.height;

        var index = 0;
        Timer.periodic(Duration(milliseconds: gifTransparentor.delay),
            (Timer t) {
          if (0 <= index && index < gifTransparentor.gifAnimation.length) {
            canvas.context2D
                .putImageData(gifTransparentor.getImageData(index), 0, 0);
            index = index + 1;
          } else {
            index = 0;
            canvas.context2D
                .putImageData(gifTransparentor.getImageData(index), 0, 0);
            index = index + 1;
          }
        });

        canvas.onClick.listen((onData) {
          var x = onData.offset.x;
          var y = onData.offset.y;

          var pixsel = canvas.context2D.getImageData(x, y, 1, 1);
          var color = Color.fromRgba(
              pixsel.data[0], pixsel.data[1], pixsel.data[2], pixsel.data[3]);
          gifTransparentor.transparent(color, distance);
        });

        ButtonElement saveButton = querySelector('#saveButton');
        saveButton.onClick.listen((onData) {
          gifTransparentor.encode();
        });

        ButtonElement undoButton = querySelector('#undoButton');
        undoButton.onClick.listen((onData) {
          gifTransparentor.undo();
        });
      });
    });
  }
}
