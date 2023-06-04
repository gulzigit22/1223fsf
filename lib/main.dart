import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:pacman/classes/box_class.dart';
import 'package:pacman/pacmanWidget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
 ClobalKey<PacmanWidgetState> gameKey GlobalKey<PacmanWidgetState>();
 ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);

@override
void initState(){
  super.initState();
}

void upDateScore(int score){
  scoreNotifier.value = scoreNotifier.value + score;
  scoreNotifier.notifyListeners();
}
 

  @override
  Widget build(BuildContext context) {
    ValueNotifier<Size> sizeNotifier = ValueNotifier<Size>(Size.zero);
    return Scaffold(
      appBar: AppBar(
       actions: [
        ElevatedButton(onPressed: ()=> gameKey.currentState?.startGame(), child:const Icon(Icons.start)),
          ElevatedButton(onPressed: ()=> gameKey.currentState?.startGame(), child:const Icon(Icons.replay)),
       ],
      ),
      body: FutureBuilder(
        future: whenNotZero(
          Stream<double>.periodic(const Direction(millisecond:50),
         (x)=> MediaQuery.of(context).size.width ),
        ),
        builder: (BuildContext context, snapshot){
          if (snapshot.hasData) {
            return Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.black,
              child: LayoutBuilder(builder: (context, constraint){
                Size size = Size(constraint.biggest.width - 16, constraint.biggest.height - 16);
                return SafeArea(child: GestureDetector(
                  onVerticalDragStart: (details) => 
                  gameKey.currentState?.updateDragDown(
                    details.localPosition,start:true,
                    ),
                    onVerticalDragUpdate:(details) => gameKey.currentState?.updateDragDown(details.localPosition),
                    onHorizontalDragStart:(details) => gameKey.currentState?.updateDragDown(details.localPosition),
                    onHorizontalDragUpdate:(details) => gameKey.currentState?.updateDragDown(details.localPosition),
                    child: Container(
                      color: Colors.transparent,
                      child:  Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: PacmanWidget(size, key: gameKey))
                        ],
                      ),
                    ),
                    ),
                    );

              },
              ),
            );
          }else{
            return Container(
              alignment: Alignment.center,
              child:const Text("loading game ..."),
            );
          }
        }
       ), 
       );
  }
  Future<double> whenNotZero(Stream<double> source)async{
    await for(double value in source){
      if(value > 0){
        return value;
      }
    }
    return 0;
  }
}
