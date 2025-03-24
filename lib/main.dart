import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Модель данных
class UserModel {
  final String id;
  final String name;

  UserModel({required this.id, required this.name});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
    );
  }
}

// Репозиторий
abstract class UserRepository {
  Future<List<UserModel>> fetchUsers();
}

class UserRepositoryImpl implements UserRepository {
  @override
  Future<List<UserModel>> fetchUsers() async {
    // Здесь вы можете использовать HTTP-запросы для получения данных
    // Для примера, вернем статические данные
    await Future.delayed(Duration(seconds: 1)); // Имитация задержки
    return [
      UserModel(id: '1', name: 'John Doe'),
      UserModel(id: '2', name: 'Jane Smith'),
    ];
  }
}

// Сущность
class User {
  final String id;
  final String name;

  User({required this.id, required this.name});
}

// Использование случаев
class GetUsers {
  final UserRepository repository;

  GetUsers(this.repository);

  Future<List<User>> call() async {
    final userModels = await repository.fetchUsers();
    return userModels.map((model) => User(id: model.id, name: model.name)).toList();
  }
}

// ViewModel
class UserViewModel extends ChangeNotifier {
  final GetUsers getUsers;
  List<User> users = [];

  UserViewModel(this.getUsers);

  Future<void> fetchUsers() async {
    users = await getUsers.call();
    notifyListeners();
  }
}

// Представление
class UserListView extends StatelessWidget {
  const UserListView({Key? key}) : super(key: key); // Добавлен параметр key

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Users')),
      body: FutureBuilder(
        future: viewModel.fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: viewModel.users.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(viewModel.users[index].name),
              );
            },
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key); // Добавлен параметр key

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserViewModel(GetUsers(UserRepositoryImpl())),
        ),
      ],
      child: MaterialApp(
        title: 'Clean Architecture App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const UserListView(), // Добавлен const
      ),
    );
  }
}