import 'package:flutter/material.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
Widget defaultFormField({
  required TextEditingController controller,
  required TextInputType type,
   Function? onSubmit,
   required Function onTap,
  bool isPassword = false,
   required Function validate,
  required String label,
  required IconData prefix,
  IconData? suffix,
  Function? suffixPressed,
  bool isClickable = true,
}) => TextFormField(
  controller: controller,
  keyboardType: type,
  obscureText: isPassword,
  enabled: isClickable,
  onFieldSubmitted:(s){
    onSubmit!(s);
  },

  onTap: (){
    onTap();
  },
  validator: (s){ validate(s);},
  decoration: InputDecoration(
    labelText: label,
    prefixIcon: Icon(
      prefix,
    ),
    suffixIcon: suffix != null ? IconButton(
      onPressed: (){
        suffixPressed!();
      },
      icon: Icon(
        suffix,
      ),
    ) : null,
    border: OutlineInputBorder(),
  ),
);
Widget buildTaskItem(Map model , context){
  return Dismissible(
    key: Key(model['id'].toString()),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40.0,
            child: Text('${model['time']}'),
          ),
          SizedBox(
            width: 20.0,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${model['title']}',
                  style: TextStyle(
                      fontSize: 18.0,fontWeight: FontWeight.bold
                  ),),
                Text(' ${model['date']}',
                  style: TextStyle(
                      color: Colors.grey
                  ),)
              ],
            ),
          ),
          SizedBox(
            width: 20.0,
          ),
          IconButton(onPressed: ()
          {
            AppCubit.get(context).updateData(status: 'done', id: model['id']);
          }, icon: Icon(Icons.check_box,color: Colors.blueAccent,)),
          IconButton(onPressed: ()
          {
            AppCubit.get(context).updateData(status: 'archive', id: model['id']);
          }, icon: Icon(Icons.archive,color: Colors.black26,)),

        ],
      ),
    ),
    onDismissed: (direction)
    {
      AppCubit.get(context).deleteData(id: model['id']);
    },
  );
}
Widget tasksBuilder({required List<Map>tasks}){
  return  tasks.length >  0 ? ListView.separated(itemBuilder: (context,index) => buildTaskItem(tasks[index],context),
      separatorBuilder: (context,index)=>
          Container(
            margin: const EdgeInsetsDirectional.only(
                start: 20.0,
                end: 20.0
            ),
            width: double.infinity,
            height: 1.0,
            color: Colors.grey[300],
          )
      , itemCount:tasks.length):
  Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.menu,size: 90.0,color: Colors.grey,),
        Text('No Tasks yet , Add some ! ',style: TextStyle(
            fontSize: 16.0,fontWeight: FontWeight.bold,color: Colors.grey
        ),)
      ],
    ),
  );
}