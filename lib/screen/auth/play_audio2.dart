import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';

class PlayAudioSecondScreen extends StatefulWidget {
  const PlayAudioSecondScreen({super.key});

  @override
  State<PlayAudioSecondScreen> createState() => _PlayAudioSecondScreenState();
}

class _PlayAudioSecondScreenState extends State<PlayAudioSecondScreen> {
  late Record audioRecord;
  late AudioPlayer audioPlayer;
  bool isRecording = false;
  String audioPath = '';

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
  void initState() {
    playRecording();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}