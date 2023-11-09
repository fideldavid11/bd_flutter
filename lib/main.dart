import 'package:flutter/material.dart';
import 'package:sqlite_flutter/task_model.dart';
import 'package:sqlite_flutter/database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tareas App',
      home: TaskListScreen(),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final dbHelper = DatabaseHelper.instance;
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  void loadTasks() async {
    tasks = await dbHelper.getTasks();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Tareas'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(tasks[index].title),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Ink(
                  decoration: ShapeDecoration(
                    color: Colors.blue, // Establece el color de fondo en azul
                    shape: CircleBorder(),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.edit,
                        color: Colors
                            .white), // Establece el color del ícono en blanco
                    onPressed: () => editTask(tasks[index]),
                  ),
                ),
                Ink(
                  decoration: ShapeDecoration(
                    color: Colors.red, // Establece el color de fondo en rojo
                    shape: CircleBorder(),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.delete,
                        color: Colors
                            .white), // Establece el color del ícono de eliminación en blanco
                    onPressed: () => deleteTask(tasks[index]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addTask(),
        child: Icon(Icons.add),
      ),
    );
  }

  void editTask(Task task) {
    showDialog(
      context: context,
      builder: (context) {
        String editedTitle = task.title;

        return AlertDialog(
          title: Text('Editar Tarea'),
          content: TextField(
            controller: TextEditingController(text: editedTitle),
            onChanged: (text) {
              editedTitle = text;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Actualizar'),
              onPressed: () async {
                task.title = editedTitle;
                await dbHelper.updateTask(task);
                loadTasks();
                Navigator.pop(context);
                showSnackBar('Se han actualizado los datos');
              },
            ),
          ],
        );
      },
    );
  }

  void deleteTask(Task task) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Eliminar Tarea'),
          content: Text('¿Estás seguro de que deseas eliminar esta tarea?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Eliminar'),
              onPressed: () async {
                await dbHelper.deleteTask(task.id);
                loadTasks();
                Navigator.pop(context);
                showSnackBar('Tarea eliminada correctamente');
              },
            ),
          ],
        );
      },
    );
  }

  void addTask() {
    String newTitle = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Agregar Tarea'),
          content: TextField(
            onChanged: (text) {
              newTitle = text;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Agregar'),
              onPressed: () async {
                final newTask = Task(id: 0, title: newTitle, completed: false);
                await dbHelper.insertTask(newTask);
                loadTasks();
                Navigator.pop(context);
                showSnackBar('Tarea agregada correctamente');
              },
            ),
          ],
        );
      },
    );
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
