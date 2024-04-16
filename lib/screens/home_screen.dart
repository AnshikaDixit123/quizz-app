import 'package:flutter/material.dart';
import '../constant.dart';
import '../models/question_model.dart';
import '../widgets/question_widget.dart';
import '../widgets/next_button.dart';
import '../widgets/option_card.dart';
import '../widgets/result_box.dart';
import '../models/db_connect.dart';
//create home screen widget
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
// create an object for db connect
  var db = DBconnect();
 // List<Question> _questions = [
  //  Question(
  //    id: '10',
  //    title: 'what is 2+2 ?',
  //    options: {'5':false, '30': false, '4': true, '10': false},
 //   ),
 //   Question(
 //     id: '11',
 //     title: 'what is 12+2 ?',
 //     options: {'51':false, '33': false, '14': true, '17': false},
  //  )
//  ];
  late Future _questions;

  Future<List<Question>> getData()async{
    return db.fetchQuestions();
  }

  @override
  void initState() {
    _questions = getData();
    super.initState();
  }
  //create an index to loop through questions
  int index = 0;
  //create a score variable
  int score = 0;
  //create a boolean value to check if user has clicked or not
  bool isPressed = false;
  //create a function to display next question
  bool isAlreadySelected = false;
  void nextQuestion(int questionLength) {
    if(index == questionLength -1) {
      //this is the block where question end
      showDialog(
          context: context, 
          barrierDismissible: false,
          builder: (ctx) => ResultBox(
                result: score,
                questionLength: questionLength,
                onPressed: startOver,
              ));
    }else{
      if (isPressed){
        
      
        setState(() {
          index++;
          isPressed = false;
          isAlreadySelected = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select any option'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.symmetric(vertical: 20.0),
        ));
      }
    }
  }
  //create a function for changing color
  void checkAnswerAndUpdate(bool value) {
    if(isAlreadySelected){
      return;
    } else{
      if(value == true){
        score++;
      }
        setState(() {
          isPressed = true;
          isAlreadySelected = true; 
        });
      
    }
  }
  void  startOver(){
    setState(() {
      index =0;
      score =0;
      isPressed = false;
      isAlreadySelected = false;
    });
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: _questions as Future<List<Question>>,
      builder: (ctx, snapshot) {
        if(snapshot.connectionState == ConnectionState.done){
          if(snapshot.hasError){
            return Center(child: Text('${snapshot.error}'),);
          } else if(snapshot.hasData) {
            var extractedData = snapshot.data as List<Question>;
            return Scaffold(
              //change the background
              backgroundColor: background,
              appBar: AppBar(
                title: const Text('Quiz App'),
                backgroundColor: background,
                shadowColor: Colors.transparent,
                actions: [
                  Padding(padding: const EdgeInsets.all(18.0), 
                  child: Text(
                    'Score: $score',
                    style: const TextStyle(fontSize: 18.0),
                    ),
                  ),
                ],
              ),
              body: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  children: [
                    QuestionWidget(
                      indexAction: index,//currently at 0
                      question: extractedData[index]
                          .title,//first in the list
                      totalQuestions: 
                          extractedData.length,//total length of list
                    ),
                    const Divider(color: neutral),
                    for ( int i=0; i < extractedData[index].options.length; i++)
                      GestureDetector(
                        onTap: () =>checkAnswerAndUpdate(
                          extractedData[index].options.values.toList()[i]),
                        child: OptionCard(
                          option: extractedData[index].options.keys.toList()[i],
                          color: isPressed 
                              ? extractedData[index].options.values.toList()[i] == true 
                                  ? correct
                                  : incorrect 
                              : neutral,
                        ),
                      ),
                      //Card(
                    //   child: Text(_questions[index].options.keys.toList()[i]),
                    // )
                  ],
                ),
              ),
              //use the floating action button
              floatingActionButton: GestureDetector(
                onTap: () =>nextQuestion(extractedData.length),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: NextButton( 
                    ),
                ),
              ),
              floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            );
          }
        }
        else{
          return  Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20.0),
                Text('please wait while questions are loading...', 
                style: TextStyle(
                  color: neutral,
                  decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          );
        }
        return const Center(
          child: Text('No Data'),
        );
      },
      
    );
  }
}