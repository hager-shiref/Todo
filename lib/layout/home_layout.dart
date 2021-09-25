import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/shared/components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {
// steps
// 1.create database
// 2.create tables
// 3.open database
// 4.insert to database
// 5.get from database
// 6.update in database
// 7.delete from database
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),
      child: BlocConsumer<AppCubit,AppStates>(
        listener: (context,state)
        {
          if(state is AppInsertToDataBaseState)
          {
            Navigator.pop(context);
          }
        },
        builder: (context , state){
          AppCubit cubit=AppCubit.get(context);
          return Scaffold(
            key: scaffoldKey,
            appBar: AppBar(
              title: Text(cubit.titles[cubit.currentIndex]),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: (){
                if(cubit.isBottomSheetShown){
                 if(titleController.text !="" ||timeController.text !="" || dateController.text !="" ) {
                   cubit.insertToDatabase(
                       title: titleController.text,
                       time: timeController.text,
                       date: dateController.text
                   );
                   titleController.clear();
                   timeController.clear();
                   dateController.clear();
                 }
                }
                else{
                  scaffoldKey.currentState!.showBottomSheet(
                          (context) =>  Container(
                        color: Colors.grey[100],
                        padding: EdgeInsets.all(20),
                        child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              defaultFormField
                                (controller: titleController,
                                  type: TextInputType.text,
                                  onTap: (){},
                                  validate: (String ? value){
                                    if(value!.isEmpty){
                                      cubit.validate('title must not be empty');
                                      return cubit.msg;
                                    }
                                    return null;
                                  },
                                  label: 'Task Title',
                                  prefix: Icons.title),
                              SizedBox(height: 15.0,),
                              defaultFormField
                                (controller: timeController,
                                  type: TextInputType.datetime,
                                  onTap: (){
                                    showTimePicker(context: context,
                                        initialTime: TimeOfDay.now()).then((value) {
                                      timeController.text=value!.format(context);
                                    });
                                  },
                                  validate: ( String ? value){
                                    if(value!.isEmpty){
                                      cubit.validate('time must not be empty');
                                      return cubit.msg;
                                    }

                                    return null;
                                  },
                                  label: 'Task Time',
                                  prefix: Icons.watch_later_outlined),
                              SizedBox(height: 15.0,),
                              defaultFormField
                                (controller: dateController,
                                  type: TextInputType.datetime,
                                  onTap: (){
                                    showDatePicker
                                      (context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.parse('2022-05-03')).then((value)
                                    {
                                      dateController.text=DateFormat().add_yMMMd().format(value!);
                                    });
                                  },
                                  validate: (String ? value){
                                    if(value!.isEmpty){
                                      cubit.validate('date must not be empty');
                                      return cubit.msg;
                                    }

                                    return null;
                                  },
                                  label: 'Task Date',
                                  prefix: Icons.calendar_today)
                            ],
                          ),
                        ),
                      ),
                      elevation: 20.0
                  ).closed.then((value) {
                    cubit.changeBottomSheetState(isShow: false, icon: Icons.edit);
                  });
                 cubit.changeBottomSheetState(isShow: true, icon: Icons.add);
                }
              },
              child: Icon(cubit.fabIcon),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              elevation: 15,
              currentIndex:AppCubit.get(context).currentIndex,
              onTap: (index){
                AppCubit.get(context).changeIndex(index);
              },
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.menu), label: "Tasks"),
                BottomNavigationBarItem(icon: Icon(Icons.checklist_outlined), label: "Done"),
                BottomNavigationBarItem(icon: Icon(Icons.archive_outlined), label: "Archived"),
              ],
            ),
            body:state is AppGetDataLoadingState ?Center(child: CircularProgressIndicator(),):
            cubit.screens[cubit.currentIndex],

          );
        },
      ),
    );
  }

}

