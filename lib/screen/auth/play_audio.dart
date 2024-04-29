import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:ss_chat/screen/auth/play_audio2.dart';

class PlayAudioScreen extends StatefulWidget {
  const PlayAudioScreen({super.key});

  @override
  State<PlayAudioScreen> createState() => _PlayAudioScreenState();
}

class _PlayAudioScreenState extends State<PlayAudioScreen> {
  late Record audioRecord;
  late AudioPlayer audioPlayer;
  bool isRecording = false;
  String audioPath = '';

  @override
  void initState() {
    audioRecord = Record();
    audioPlayer = AudioPlayer();
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    audioRecord.dispose();
    super.dispose();
  }

  Future<void> startRecording() async {
    try {
      if (await audioRecord.hasPermission()) {
        await audioRecord.start();
        setState(() {
          isRecording = true;
        });
      }
    } catch (e) {
      print("Error Start Recording: $e");
    }
  }

  Future<void> stopRecording() async {
    try {
      String? path = await audioRecord.stop();
      setState(() {
        isRecording = false;
        audioPath = path!;
      });

      if (isRecording==false) {
        playRecording();
      }
    } catch (e) {
      print("Error Stop Recording: $e");
    }
  }

  Future<void> playRecording() async {
    try {
      Source urlSource=UrlSource(audioPath);
      await audioPlayer.play(urlSource);
    } 
    catch (e) {
      print("Error Play Recording: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isRecording) Text("Recording start"),
            ElevatedButton(
                onPressed: isRecording ? stopRecording : startRecording,
                child: isRecording ? Text("Start") : Text("Stop")),
            // if (!isRecording && audioPath != null)
            //   ElevatedButton(
            //       onPressed: () {
            //         setState(() {
            //           playRecording();
            //         });
            //       },
            //       child: Text("Play")),
          ],
        ),
      ),
    );
  }
}
