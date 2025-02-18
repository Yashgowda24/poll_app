import 'User.dart';
import 'socket_utils.dart';

class G {
  // Socket
  static SocketUtils? socketUtils;
  static List<User>? dummyUsers;

  // Logged In User
  static User? loggedInUser;

  // Single Chat - To Chat User
  static User? toChatUser;

  static initSocket() {
    socketUtils ??= SocketUtils();
  }

  static void initDummyUsers() {
    User userA =  User(id: 1000, name: 'A', email: 'testa@gmail.com');
    User userB =  User(id: 1001, name: 'B', email: 'testb@gmail.com');
    dummyUsers = <User>[];
    dummyUsers?.add(userA);
    dummyUsers?.add(userB);
  }

  static List<User> getUsersFor(User user) {
    if(dummyUsers == null){
      return [];
    }
    List<User> filteredUsers = dummyUsers!
        .where((u) => (!u.name.toLowerCase().contains(user.name.toLowerCase())))
        .toList();
    return filteredUsers;
  }
}
