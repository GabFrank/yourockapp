import 'dart:async';

import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/subjects.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _volumeSubject = BehaviorSubject.seeded(1.0);
  final _speedSubject = BehaviorSubject.seeded(1.0);

  AudioPlayer _player;
  String url = "http://stream.zeno.fm/d77xxturz1zuv";
  bool isPlaying;
  bool isVisible = true;
  bool clickApoyo = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AudioPlayer.setIosCategory(IosCategory.playback);
    _player = AudioPlayer();
    _player.setUrl(url).catchError((error) {
      // catch audio error ex: 404 url, wrong url ...
      print(error);
    });
  }

  @override
  void dispose() {
    _volumeSubject.close();
    _speedSubject.close();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    String appId = "ca-app-pub-7939841244843491~4067024012";

    FirebaseAdMob.instance.initialize(appId: appId).then((res){
      bottomBanner..load()..show();
    });
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Icon(Icons.radio, color: Colors.black, size: 35,),
        centerTitle: true,
        backgroundColor: Colors.yellow,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.black,
            ),
            onPressed: () {
            },
          )
        ],
      ),
      body: new Center(
          child: Column(
        children: <Widget>[
          SizedBox(
            height: 300,
            child: Image.asset('img/yurocklogo.png',width: 300,)
          ),
          showButton(),
          Text("Volume"),
              StreamBuilder<double>(
                stream: _volumeSubject.stream,
                builder: (context, snapshot) => Slider(
                  activeColor: Colors.yellow,
                  divisions: 20,
                  min: 0.0,
                  max: 2.0,
                  value: snapshot.data ?? 1.0,
                  onChanged: (value) {
                    _volumeSubject.add(value);
                    _player.setVolume(value);
                  },
                ),
              ),
              Divider(height: 20,),
              !clickApoyo ? RaisedButton(color: Colors.yellow,
              child: Text('Click de apoyo'),
              onPressed: (){
                showVideoAd(clickApoyoAd);
                setState(() {
                  clickApoyo = true;
                });
              },)
              :
              Text('Muchas gracias lml', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
        ],
      )),
    );
  }

  Widget showButton() {
    return StreamBuilder<FullAudioPlaybackState>(
        stream: _player.fullPlaybackStateStream,
        builder: (context, snapshot) {
          final fullState = snapshot.data;
          final state = fullState?.state;
          final buffering = fullState?.buffering;
          return Row(mainAxisSize: MainAxisSize.min, children: [
            if (state == AudioPlaybackState.connecting || buffering == true)
              Container(
                margin: EdgeInsets.all(8.0),
                width: 64.0,
                height: 64.0,
                child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.yellow),),
              )
            else if (state == AudioPlaybackState.playing)
              IconButton(
                icon: Icon(Icons.pause, color: Colors.yellow,),
                iconSize: 64.0,
                onPressed: _player.pause,
              )
            else
              IconButton(
                icon: Icon(Icons.play_arrow, color: Colors.yellow),
                iconSize: 64.0,
                onPressed: (){
                  showVideoAd(playAd);
                  _player.play();
                },
              ),
            IconButton(
              icon: Icon(Icons.stop, color: Colors.yellow),
              iconSize: 64.0,
              onPressed: state == AudioPlaybackState.stopped ||
                      state == AudioPlaybackState.none
                  ? null
                  : _player.stop,
            )
          ]);
        });
  }
}

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final ValueChanged<Duration> onChanged;
  final ValueChanged<Duration> onChangeEnd;

  SeekBar({
    @required this.duration,
    @required this.position,
    this.onChanged,
    this.onChangeEnd,
  });

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double _dragValue;

  @override
  Widget build(BuildContext context) {
    return Slider(
      min: 0.0,
      max: widget.duration.inMilliseconds.toDouble(),
      value: _dragValue ?? widget.position.inMilliseconds.toDouble(),
      onChanged: (value) {
        setState(() {
          _dragValue = value;
        });
        if (widget.onChanged != null) {
          widget.onChanged(Duration(milliseconds: value.round()));
        }
      },
      onChangeEnd: (value) {
        _dragValue = null;
        if (widget.onChangeEnd != null) {
          widget.onChangeEnd(Duration(milliseconds: value.round()));
        }
      },
    );
  }
}

MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  keywords: <String>['musci', 'rock', 'pop', 'radio'],
  contentUrl: 'https://flutter.io',
  childDirected: false,
  testDevices: <String>[], // Android emulators are considered test devices
);

BannerAd bottomBanner = BannerAd(
  // Replace the testAdUnitId with an ad unit id from the AdMob dash.
  // https://developers.google.com/admob/android/test-ads
  // https://developers.google.com/admob/ios/test-ads
  // adUnitId: "ca-app-pub-7939841244843491/3020986911",
  adUnitId: BannerAd.testAdUnitId,
  size: AdSize.smartBanner,
  targetingInfo: targetingInfo,
  listener: (MobileAdEvent event) {
    print("BannerAd event is $event");
  },
);

InterstitialAd clickApoyoAd = InterstitialAd(
  // Replace the testAdUnitId with an ad unit id from the AdMob dash.
  // https://developers.google.com/admob/android/test-ads
  // https://developers.google.com/admob/ios/test-ads
  // adUnitId: "ca-app-pub-7939841244843491/3771510540",
  adUnitId: InterstitialAd.testAdUnitId,
  targetingInfo: targetingInfo,
  listener: (MobileAdEvent event) {
    print("InterstitialAd event is $event");
  },
);

InterstitialAd playAd = InterstitialAd(
  // Replace the testAdUnitId with an ad unit id from the AdMob dash.
  // https://developers.google.com/admob/android/test-ads
  // https://developers.google.com/admob/ios/test-ads
  // adUnitId: "ca-app-pub-7939841244843491/6597269843",
  adUnitId: InterstitialAd.testAdUnitId,
  targetingInfo: targetingInfo,
  listener: (MobileAdEvent event) {
    print("InterstitialAd event is $event");
  },
);

showVideoAd(ad) async{
  ad
  ..load()
  ..show();
}

