import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';

import 'package:flutter/scheduler.dart';

void main() 
{
  runApp(const MyApp());
}

class MyApp extends StatelessWidget 
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp
    (
      title: '猜拳遊戲',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: '猜拳遊戲'),
    );
  }
}

class MyHomePage extends StatefulWidget 
{
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> 
{
  final Random _random = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();
  static const String _bgMusicAsset = 'audio/game_music.mp3';

  static const String _paperPath = 'assets/images/paper.png';
  static const String _rockPath = 'assets/images/rock.png';
  static const String _scissorsPath = 'assets/images/scissors.png';
  static const String _greatePath = 'assets/images/greate.png';
  static const String _cryPath = 'assets/images/cry.png';

  RpsMove? _playerMove;
  RpsMove? _computerMove;
  RoundOutcome? _lastOutcome;
  String _resultText = '請選擇剪刀、石頭或布開始遊戲';
  int _playerWinCount = 0;
  int _computerWinCount = 0;
  int _drawCount = 0;

  final _scissorsBtnAnimNoti = ButtonAnimNotifier(1.0);

  Widget _scissorsBtnAnimBuilder(BuildContext c, double value, Widget? child)
  {
    return Transform.scale
    (
      scale: value,
      child: IconButton
      (
        onPressed: () {_play(RpsMove.scissors); _scissorsBtnAnimNoti.startAnim();}, 
        icon: Image.asset(_scissorsPath, width: 88, height: 88, fit: BoxFit.contain,),
        iconSize: 88,
        splashRadius: 48,
      ),
    );
  }

  void _play(RpsMove playerMove) 
  {
    final RpsMove computerMove = RpsMove.values[_random.nextInt(RpsMove.values.length)];
    final RoundOutcome outcome = _judge(playerMove, computerMove);

    setState(() 
    {
      _playerMove = playerMove;
      _computerMove = computerMove;
      _lastOutcome = outcome;
      _resultText = _outcomeText(outcome);
      if (outcome == RoundOutcome.playerWin) {
        _playerWinCount++;
      } else if (outcome == RoundOutcome.computerWin) {
        _computerWinCount++;
      } else {
        _drawCount++;
      }
    });
  }

  RoundOutcome _judge(RpsMove player, RpsMove computer) 
  {
    if (player == computer) 
    {
      return RoundOutcome.draw;
    }

    final bool playerWins =
        (player == RpsMove.rock && computer == RpsMove.scissors) ||
        (player == RpsMove.scissors && computer == RpsMove.paper) ||
        (player == RpsMove.paper && computer == RpsMove.rock);

    return playerWins ? RoundOutcome.playerWin : RoundOutcome.computerWin;
  }

  String _outcomeText(RoundOutcome outcome) 
  {
    switch (outcome) 
    {
      case RoundOutcome.playerWin:
        return '你贏了！';
      case RoundOutcome.computerWin:
        return '你輸了！';
      case RoundOutcome.draw:
        return '平手！再來一局';
    }
  }

  String _moveLabel(RpsMove? move) 
  {
    switch (move) 
    {
      case RpsMove.rock:
        return '石頭';
      case RpsMove.paper:
        return '布';
      case RpsMove.scissors:
        return '剪刀';
      case null:
        return '-';
    }
  }

  String _moveImagePath(RpsMove move) 
  {
    switch (move) 
    {
      case RpsMove.rock:
        return _rockPath;
      case RpsMove.paper:
        return _paperPath;
      case RpsMove.scissors:
        return _scissorsPath;
    }
  }

  Widget _moveButton({required String imagePath, required RpsMove move}) 
  {
    if (move == RpsMove.scissors) 
    {
      return ValueListenableBuilder(valueListenable: _scissorsBtnAnimNoti, builder: _scissorsBtnAnimBuilder);
    }

    return IconButton
    (
      onPressed: () => _play(move),
      iconSize: 88,
      splashRadius: 48,
      icon: Image.asset(imagePath, width: 88, height: 88, fit: BoxFit.contain),
    );
  }

  Widget _starIcons(int count, {double size = 22}) 
  {
    return Wrap
    (
      spacing: 3,
      runSpacing: 2,
      children: List.generate
      (
        count,
        (_) => Icon
        (
          Icons.star,
          color: Colors.blue,
          size: size,
        ),
      ),
    );
  }

  void _resetGameData() 
  {
    setState(() 
    {
      _playerMove = null;
      _computerMove = null;
      _lastOutcome = null;
      _resultText = '請選擇剪刀、石頭或布開始遊戲';
      _playerWinCount = 0;
      _computerWinCount = 0;
      _drawCount = 0;
    });
  }

  @override
  void initState() 
  {
    super.initState();
    // App 啟動時播放音樂檔（assets 來源）。
    _audioPlayer.play(AssetSource(_bgMusicAsset));
  }

  @override
  void dispose() 
  {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      body: SafeArea
      (
        child: Center
        (
          child: Padding
          (
            padding: const EdgeInsets.all(20),
            child: Column
            (
              mainAxisAlignment: MainAxisAlignment.center,
              children: 
              [
                Text(widget.title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (Widget child, Animation<double> animation) 
                  {
                    return RotationTransition(turns : animation,child: child,);
                  },
                  child: _lastOutcome == RoundOutcome.playerWin
                      ? Image.asset
                      (
                          _greatePath,
                          key: ValueKey(_computerWinCount+_playerWinCount+_drawCount),
                          width: 140,
                          height: 140,
                          fit: BoxFit.contain,
                      )
                      : _lastOutcome == RoundOutcome.computerWin
                          ? Image.asset
                          (
                              _cryPath,
                              key: ValueKey(_computerWinCount+_playerWinCount+_drawCount),
                              width: 140,
                              height: 140,
                              fit: BoxFit.contain,
                          )
                          : Text
                            (
                              _resultText,
                              key: ValueKey(_computerWinCount+_playerWinCount+_drawCount),
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                ),
                const SizedBox(height: 16),
                Text('你出拳：${_moveLabel(_playerMove)}'),
                const SizedBox(height: 8),
                const Text('電腦出拳：'),
                const SizedBox(height: 8),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 1500),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (Widget child, Animation<double> animation) 
                  {
                    return RotationTransition
                    (
                      turns: animation,
                      child: ScaleTransition
                      (
                        scale: animation, 
                        child: FadeTransition
                        (
                          opacity: animation, 
                          child: child,
                        )
                      ),
                    );
                  },
                  child: _computerMove == null
                      ? const Text('-', key: ValueKey('empty'))
                      : Image.asset
                        (
                          _moveImagePath(_computerMove!),
                          key: ValueKey(_computerMove),
                          width: 88,
                          height: 88,
                          fit: BoxFit.contain,
                        ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  children: 
                  [
                    _moveButton(imagePath: _scissorsPath, move: RpsMove.scissors),
                    _moveButton(imagePath: _rockPath, move: RpsMove.rock),
                    _moveButton(imagePath: _paperPath, move: RpsMove.paper),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: 
                  [
                    const Text
                    (
                      '玩家：',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _starIcons(_playerWinCount),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '電腦：',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _starIcons(_computerWinCount),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '平手：',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _starIcons(_drawCount),
                  ],
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: _resetGameData,
                  child: const Text('清除遊戲資料'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum RpsMove { rock, paper, scissors }

enum RoundOutcome { playerWin, computerWin, draw }


class ButtonAnimNotifier extends ValueNotifier<double> implements TickerProvider
{
  Ticker? _ticker;

  late final AnimationController _animCtrlr;
  late final Animation _anim;

  ButtonAnimNotifier(super._value)
  {
    _animCtrlr = AnimationController(vsync: this, duration: Duration(milliseconds: 200))
    ..addListener(() {super.value = _anim.value;});

    _anim = TweenSequence<double>
    (
      [
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.6), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.0), weight: 50),
      ]
    ).animate(_animCtrlr);
  }

  @override
  Ticker createTicker(TickerCallback onTick) 
  {
    _ticker?.dispose();
    _ticker = Ticker(onTick);
    return _ticker!;
  }

  @override
  void dispose() 
  {
    _animCtrlr.dispose();
    _ticker?.dispose();
    super.dispose();
  }

  void startAnim() 
  {
    _animCtrlr.forward(from: 0);
  }
}