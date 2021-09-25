import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks/archived_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks/done_tasks_screen.dart';
import 'package:todo_app/modules/new_tasks/new_tasks_screen.dart';
import 'package:todo_app/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates>
{
  AppCubit() : super( AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);
  int currentIndex = 0;
  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;
  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen()
  ];
  List<String> titles = ['New Tasks', 'Done Tasks', 'Archived Tasks'];
  List<Map> newTasks=[];
  List<Map> doneTasks=[];
  List<Map> archiveTasks=[];
  void changeIndex(int index)
  {
    currentIndex=index;
    emit(AppChangeBottomNavBarState());
  }
  late Database   database ;
  void createDatabase()
  {
     openDatabase(
        "todo.db",
        version: 1,
        onCreate: (database , version){
          // id integer
          // title string
          // date string known as title
          // time string
          // status string
          // string known as text
          // ( title TEXT ) column name + data type
          print('Database created');
          database.execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY , title TEXT , date TEXT , time TEXT , status TEXT ) '
          ).then((value) => print('table Created')).catchError((error){
            print("error when creating table ${error.toString()}");
          });
        },
        onOpen: (database){
          getDataFromDatabase(database);
          print("Database Opened");
        }
    ).then((value) {
        database=value;
        emit(AppCreateDataBase());
     });
  }
   insertToDatabase({required String title, required String time, required String date}) async {
      await database.transaction((txn) async{
      txn.rawInsert(" INSERT INTO tasks( title, date, time, status) VALUES ('$title','$date','$time','new') ")
          .then((value) {
        print ('$value inserted successfully');
            emit(AppInsertToDataBaseState());
        getDataFromDatabase(database);
      }).catchError((error){
        print("error while inserting : ${error.toString()}");
      });
    }
    );
  }
  void getDataFromDatabase(database){
    newTasks=[];
    doneTasks=[];
    archiveTasks=[];
    emit(AppGetDataLoadingState());
    database.rawQuery(" SELECT * FROM tasks ").then((value) {
      value.forEach((element)
      {
        if(element['status'] == 'new'){
          newTasks.add(element);
        }
        else if (element['status'] == 'done'){
          doneTasks.add(element);
        }
        else archiveTasks.add(element);
      });
      emit(AppGetDataFromDataBaseState());
    });
  }
  void changeBottomSheetState({required bool isShow,required IconData icon})
  {
    isBottomSheetShown=isShow;
    fabIcon =icon;
    emit(AppChangeBottomSheetState());
  }
  var msg='';
  void validate(String value)
  {
    msg=value;
    emit(AppValidateState());
  }
  void updateData({required String status , required int id }){
     database.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ? ',
      ['$status' , id ]
    ).then((value) {
      getDataFromDatabase(database);
      emit(AppUpdateDataBase());
     });
  }
  void deleteData({ required int id }){
    database.rawDelete(
        'DELETE FROM tasks WHERE id = ?  ',
        [ id ]
    ).then((value) {
      getDataFromDatabase(database);
      emit(AppDeleteDataBase());
    });
  }
}
