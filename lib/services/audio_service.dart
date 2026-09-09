import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  void playClick() => unawaited(_play('click.mp3'));
  void playBack() => unawaited(_play('back.mp3'));
  void playClear() => unawaited(_play('clear.mp3'));
  void playOther() => unawaited(_play('other.mp3'));

  Future<void> _play(String file) async {
    try {
      await _player.play(AssetSource('audio/$file'));
    } catch (_) {
      // Audio is optional; never interrupt Todo actions.
    }
  }

  Future<void> dispose() => _player.dispose();
}
