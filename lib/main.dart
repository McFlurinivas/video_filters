import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:video_filters/filters.dart';
import 'dart:ui' as ui;
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tapioca/tapioca.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Video Filters',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

abstract class Filters extends TapiocaBall{
  late String color;
  Filters(Filter type) {
    switch (type) {
      case Filter.vivid:
        this.color = "#0000FF";
        break;
      case Filter.noir:
        this.color = "#000";
        break;
      case Filter.dramaticWarm:
        this.color = "#EEEB8D";
        break;
      case Filter.mono:
        this.color = "#909696";
        break;
    }
  }
  Filters.color(Color colorInstance) {
    this.color = '#${colorInstance.value.toRadixString(16).substring(2)}';
  }

  Map<String, dynamic> toMap() {
    return {'type': color };
  }

  String toTypeName() {
    return 'Filter';
  }
}

enum Filter {
  vivid,
  noir,
  dramaticWarm,
  mono
}



class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey _globalKey = GlobalKey();
  final List<List<double>> filters = [
    SEPIA_MATRIX,
    GREYSCALE_MATRIX,
    VINTAGE_MATRIX,
    SWEET_MATRIX
  ];

  final tapiocaBalls = [TapiocaBall.filter(Filter.mono)];
  File? _video;
  final _picker = ImagePicker();
  VideoPlayerController? controller;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    Future<void> galleryVideoPicker() async {
      var video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video == null) return;
      setState(() {
        _video = File(video.path);
        controller = VideoPlayerController.file(_video!);
        controller!.initialize().then((_) {
          setState(() {
            controller!.setLooping(true);
            controller!.play();
          });
        });
      });
    }

    Future<void> cameraVideoPicker() async {
      var video = await _picker.pickVideo(source: ImageSource.camera);
      if (video == null) return;
      setState(() {
        _video = File(video.path);
        controller = VideoPlayerController.file(_video!);
        controller!.initialize().then((_) {
          setState(() {
            controller!.setLooping(true);
            controller!.play();
          });
        });
      });
    }


    @override
    void dispose() {
      controller!.dispose();
      super.dispose();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Video Filters",
        ),
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(icon: Icon(Icons.check), onPressed: (){
    final cup = Cup(Content(_video.path), tapiocaBalls);
    cup.suckUp(path).then((_) async {
      print("finished");
      print(path);
      GallerySaver.saveVideo(path).then((bool? success) {
        print(success.toString());
      });}/*convertWidgetToImage*/)
        ],
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.only(top: 50),
          child: Column(
            children: [
              Center(
                  child: RepaintBoundary(
                      key: _globalKey,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: size.width,
                          maxHeight: size.width,
                        ),
                        child: PageView.builder(
                            itemCount: filters.length,
                            itemBuilder: (context, index) {
                              return ColorFiltered(
                                colorFilter: TapiocaBall.filter(Filters.pink),
                                child: SizedBox(
                                    height: 200,
                                    width: double.infinity,
                                    child: (_video != null)
                                        ? FittedBox(
                                            fit: BoxFit.cover,
                                            child: SizedBox(
                                              height:
                                                  controller!.value.size.height,
                                              width:
                                                  controller!.value.size.width,
                                              child: video(),
                                            ),
                                          )
                                        : Container()),
                              );
                            }),
                      ))),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(children: [
                  Expanded(
                    child: FlatButton(
                        onPressed: () => galleryVideoPicker(),
                        child: const Text('Gallery',
                            style:
                                TextStyle(color: Colors.black, fontSize: 20)),
                        shape: const RoundedRectangleBorder(
                          side: BorderSide(
                              color: Colors.lightBlue,
                              width: 1,
                              style: BorderStyle.solid),
                        )),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: FlatButton(
                      onPressed: () => cameraVideoPicker(),
                      child: const Text('Camera',
                          style: TextStyle(color: Colors.black, fontSize: 20)),
                      shape: const RoundedRectangleBorder(
                        side: BorderSide(
                            color: Colors.lightBlue,
                            width: 1,
                            style: BorderStyle.solid),
                      ),
                    ),
                  )
                ]),
              ),
              const SizedBox(
                height: 20,
              ),
              FlatButton(
                  //height: 50,
                  minWidth: 150,
                  onPressed: () async {
                    if (_video == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Please select a video',
                              style: TextStyle(color: Colors.blue),
                              textAlign: TextAlign.center)));
                    } else {
                      //GallerySaver.saveVideo(_video.toString());
                    }
                  },
                  child: const Text('Download',
                      style: TextStyle(color: Colors.lightBlue, fontSize: 20)),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      side: const BorderSide(
                          color: Colors.lightBlue,
                          width: 1,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(10))),
            ],
          ),
        ),
      ),
    );
  }

  Widget video() {
    if (controller == null) {
      return Container();
    }

    return VideoPlayer(controller!);
  }
}
