import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pacman/classes/boxPos_class.dart';
import 'package:pacman/classes/box_class.dart';
import 'package:pacman/classes/enemy_class.dart';
import 'package:pacman/classes/player_class.dart';
import 'package:pacman/classes/row_column.dart';
import 'package:pacman/constant.dart';
import 'package:pacman/painters/bgpainter.dart';

class PacmanWidget extends StatefulWidget {
  Size sizeFull;
   PacmanWidget(this.sizeFull,{ Key? key }) : super(key: key);

  @override
  _PacmanWidgetState createState() => _PacmanWidgetState();
}

class _PacmanWidgetState extends State<PacmanWidget> with TickerProviderStateMixin{
  RowColumn boxSize = RowColumn(1, 1);
  GlobalKey key = GlobalKey();
 ValueNotifier<List<List<Box>>> boxesNotifier =
  ValueNotifier<List<List<Box>>>([]);
  ValueNotifier<List<Enemy>> enemiesNotifier = ValueNotifier<List<Enemy>>([
Enemy(position: BoxPos(6, 13)),
Enemy(position: BoxPos(6, 14)),
Enemy(position: BoxPos(6, 15)),
Enemy(position: BoxPos(6, 16)),
  ]);
  ValueNotifier<Player> playerNotifier = ValueNotifier<Player>(Player());

  GlobalKey<MyHomePageState> mainKey = GlobalKey<MyHomePageState>();
  BGPainter bgPainter = BGPainter([]);

  Size sizeBoxOuter = Size.zero;
  Size sizePerBox =  Size.zero;
  late Timer timerEnemies;
  late Timer timerPlayer;
  Timer? timerPower;
  Offset? offsetDragState;
  Direction? direction;
  bool start = false;
  List<List<dynamic>> barriers = [];
  late Animation<double> animation;
  late AnimationController animationController;
  late Size sizeFull;

@override
void dispose(){
  animation.removeListener(() { });
  animationController.dispose();
  super.dispose();
}
@override
void initState(){
  super.initState();
  setupAnimationPlayer();
  
  sizeBoxOuter = sizeFull = widget.sizeFull;
  WidgetsBinding.instance.addPostFrameCallback((_)=> iniatiateProcess())
}

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Container(
        constraints: BoxConstraints.tight(
          boxSize.calculateMaxSizeGame(sizeBoxOuter)
        ),
        child: Stack(
          clipBehavior: Clip.antiAlias,
          fit: StackFit.loose,
          alignment: Alignment.center,
          children: [
            backgroundWidget(),
            ...foregroundWidget()
          ],
        ),
      ),
    );
  }

  setupAnimationPlayer({
    int durationPlayerSecond = 200,
    double start = 0,
    double end =1,
    bool reverse = true
  }){
    if (!reverse) {
      animationController.stop();
      animationController.reset();
    }

    animationController =  AnimationController(
      vsync: this,
      duration: Direction( millideconds:durationPlayerSecond),
      lowerBound: 0,
      upperBound: 1
    );

    animation = Tween<double>(begin: start, end: end).animate(animationController);
    if (reverse) {
      animationController.repeat(reverse: true);
    }else{
      animationController.forward();
    }
  }

  updateDragDown(Offset offset, {bool start = false}){
    if (start) {
      offsetDragState = offset;
    }else{
      playerNotifier.value.position!.setDirectionInt((offset - offsetDragState!));
      playerNotifier.notifyListeners();
    }
  }

  backgroundWidget(){
    return LayoutBuilder(builder: (context, constraint){
      return Container(
        alignment: Alignment.center,
        color: Colors.black,
        child: CustomPaint(
          painter: bgPainter,
          willChange: true,
          child: ValueListenableBuilder(
            valueListenable: boxesNotifier,
            builder:(context,List<List<Box>> boxes, child) {
              bgPainter.setBoxes(boxes.expand((element) => element).toList());
            }),
        ),
      );
    });
  }
foregroundWidget(){
  return [
    ValueListenableBuilder(
      child: ValueListenableBuilder(
         valueListenable: playerNotifier, builder: (buildContext, Player player, child){
          return AnimateaPositioned(
            duration:const Duration(mailliseconds:100),
            left:player.position!.offset!.dx,
            top: player.position!.offset!.dy,
            child: RotatedBox(quarterTurns: player.position?.getRotation(),
            child: AnimatedBuilder(
              animation: animation,
              builder: (context,child){
                return CustomPaint(
                  child: child,
                );

              },
              child: Container(
                constraints: BoxConstraints.tight(sizePerBox),
                child: Container(
                  margin: EdgeInsets.all(4.5),
                  color: Colors.yellow,
                ),
              ),
            ),)
          );
         }
      ),
      valueListenable: enemiesNotifier,
      builder: (buildContext, List<Enemy> enemies, child){
        return Stack(
          children: [
            ...enemies.asMap().entries.map((enemyMap){
              return AnimatedPositioned(duration: Duration(
                microseconds: enemyMap.value.start || enemyMap.value.roaming ? 300 : 1
              ),
              left: enemyMap.value.position?.offset?.dx,
              top: enemyMap.value.position?.offset?.dy,
              child: CustomPaint(
                child: Container(
                  constraints: BoxConstraints.tight(sizePerBox),
                  padding: EdgeInsets.all(sizePerBox.longestSide * 0.1),
                  child: Container(
                    margin: EdgeInsets.all(4.5),
                    color: enemyMap.value.getColor(enemyMap.key),
                  ),
                ),
              ),
              );
            },).toList(),
            child!,
          ],
        );
      },
     ),

  ];
}

iniatiateProcess()async{
  generateList();
  setTimerProcess();
}
generateList(){
  List<List<int>> routes = Constant.grids;

  boxSize = RowColumn(routes.length,routes[0].length );
  List<RowColumn> localRowCol = [
    RowColumn(5, 14),
      RowColumn(6, 13),
        RowColumn(6, 14),
          RowColumn(6, 15),
            RowColumn(6, 16),
  ];
  barriers= [];
  setState(() {
    sizePerBox = Size.square(boxSize,calculateMaxSize(sizeBoxOuter));
  });

  playerNotifier.value.setSize(sizePerBox);

  BoxPos? playerPos;
   
  boxesNotifier.value = List.generate(boxSize.row, (rowIndex) {
    List<int> routerInner = routes
    .asMap()
    .entries
    .firstWhere((map) => map.key == rowIndex)
    .value;
    bool noRouteOuter = routerInner.where((element) => element > 0).isEmpty;
  return List.generate(boxSize.column, (ColumnIndex){
    bool gotWall = false;
    bool gotOrange = false;
    bool gotPowerUp = false;

    if (!noRouteOuter) {
      int boxValue = routerInner
      .asMap()
    .entries
    .firstWhere((map) => map.key == rowIndex)
    .value;
    switch(boxValue){
     case 0:
     gotWall = true;
     break;
     case 1:
     gotOrange = true;
     case 2:
     gotPowerUp = true;
     break;
     case 3:
     playerPos = BoxPos(rowIndex,ColumnIndex);
     break;
     default:
     if(boxValue >= 0){
      enemiesNotifier.value[boxValue - 4].position!.setBoxPos(BoxPos(rowIndex, ColumnIndex), sizePerBox);
     }
    }
    }else{
      gotWall = true;
    }
    return Box(sizeBoxOuter, uniqueIndex: rowIndex * boxSize.column + ColumnIndex,
    position: BoxPos(rowIndex, ColumnIndex,sizePerBox: sizePerBox,),
    isWall: gotWall,
    gotOrange: gotOrange,
    powerUp: gotPowerUp,
    );
  },
  );
  },
  );
  boxesNotifier.notifyListeners();
  playerNotifier.value.position!.setBoxPos(playerPos!, sizePerBox);
  playerNotifier.value.position!.setOffsetDefault();

  playerNotifier.value.setBoxes(boxesNotifier.value.expand((element) => element).where((element) => !element.isWall).toList());
  for(var element in enemiesNotifier.value){
    element.position!.calculateOffset(sizePerBox);
    element.position!.setOffsetDefault();
  }
  updateNotifier(enemiesNotify: true,playerNotify:true);

  barriers = boxesNotifier.value
  .map((e) => e
  .where((element) => element.isWall)
  .map((e) => Offset(e.position!.columnIndex.toDouble(), e.position!.rowIndex.toDouble()))
  .toList())
  .toList();

}
void setTimerProcess(){
  List<Box> boxes = boxesNotifier.value
  .expand((element) => element)
  .where((element) => !element.isWall)
  .toList();

  timerPlayer = Timer.periodic(Duration(milliseconds: 50), (timerEnemies) {
    if (boxesNotifier.value.isNotEmpty && playerNotifier.value.flagMove()) {
      if(playerNotifier.value.position?.offset != Offset.zero){
        if ((playerNotifier.value.powerUp && timerEnemies.tick % 1 != 0)||(!playerNotifier.value.powerUp && timerEnemies.tick % 2 != 0)) {
          return;
        }
        playerNotifier.value.move(boxess);
        updateNotifier(playerNotifier:true);

        boxesNotifier.value
        .expand((element) => element)
        .where((element) => element.checkOffsetInRange(
          playerNotifier.value.position!.offset!.translate(sizePerBox.shortestSide /2, sizePerBox.shortestSide/ 2)
        ))
        .where((element) => element.gotOrange || element.powerUp)
        .forEach((element)async {
          if (element.powerUp) playerGotPower();
          element.setEatOnPath();
          mainkey.currentState?.upDateScore(1);

        });
        boxesNotifier.notifyListeners();
      }
    }
   });
   timerEnemies = Timer.periodic(Duration(microseconds:50 ), (timerEnemies) { 
    if (boxesNotifier.value.isNotEmpty) {
      List<Box> boxes = boxesNotifier.value
      .expand((element) => element)
      .where((element) => !element.isWall)
      .toList();


      enemiesNotifier.value = 
            enemiesNotifier.value.asMap().entries.map((mapKey) {
        Enemy e = mapKey.value;
        if (e.position?.offset != Offset.zero && e.FlagMove()) {
          bool hitPlayer = !e.playerPowerUp && !e.die && e.position!.positionInCenter(sizePerBox, playerNotifier.value.position!);
          if(hitPlayer && !playerNotifier.value.die){
            playerNotifier.value.die = true;
            updateNotifier(playerNotifiy: true);

            enemiesNotifier.value.forEach((element) {
              element.setPause();
            });

          updateNotifier(playerNotifiy: true);
          
          setupAnimationPlayer(
            durationPlayerSecond: 500, end: 1, start: 0, reverse: false
          );
          return e;
          }

          bool eatByPlayer = e.playerPowerUp && e.position!.positionInCenter(sizePerBox, playerNotifier.value.position!);
          if (eatByPlayer && !playerNotifier.value.die && !e.die) {
            e.setReset(dieEvent: true)
            return e;
          }else if(e.returnBase && e.position!.arriveBase(sizePerBox)){
            e.setReset(setDefaultPos: false);
            Future.delayed(Duration(seconds: 3))
            .then((value) => e.setPlay());
            return e;
          }

          if (!e.die && ((e.playerPowerUp && timerEnemies.tick $ 3 != 0)||(!e.playerPowerUp && timerEnemies.tick % 2 != 0))) {
            return e;
          }
          if (e.targetOffsets.isEmpty) {
            e.computedNewPoint(
              e.die 
              ? e.position!.defaultPos!
              : playerNotifier.value.position!.offset, 
            boxes,
             boxSize: barriers, barriers: boxSize, size: sizePerBox, index: mapKey.key);
          }else{
            e.move(sizePerBox);
          }
        }
        return e;
      }).toList();
     updateNotifier(playerNotifiy: true);
    }
   });

}

startGame(){
  playerNotifier.value.setPlay();
  for(var element in enemiesNotifier.value){
    element.setPlay();
  }
   updateNotifier(enemiesNotify: true, playerNotifiy:true);

   generateList();
   setState(() {
     
   });

}
resetGame(){
  playerNotifier.value.setPlay();
  for(var element in enemiesNotifier.value){
    element.setReset();
  }
   updateNotifier(enemiesNotify: true, playerNotifiy:true);

   generateList();
   setState(() {
     
   });

}

void playerGotPower(){
  if (timerEnemies != null && timerEnemies!.isActive) {
    timerEnemies!.cancel();
  }
  playerNotifier.value.gorPowerUp();
  for (var element in enemiesNotifier.value) {
    element.gotPowerUp();
  }
  updateNotifier(enemiesNotify: true, playerNotifiy:true);

  timerPower = Timer( Duration (seconds:6),cancelPowerUp);

}
void cancelPowerUp(){
  playerNotifier.value.cancelPowerUp();
  for (var element in enemiesNotifier.value) {
    element.cancelPowerUp();
  }
  updateNotifier(enemiesNotify: true, playerNotifiy:false);
}
updateNotifier({bool playerNotifiy = false , bool enemiesNotify = false}){
  if(playerNotifiy)playerNotifier.notifyListeners();
  if(enemiesNotify) enemiesNotifier.notifyListeners();
}
}