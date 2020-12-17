class CurrentUser{

  final String nikeName;
  final String password;

  void display(){
    print("Name: $nikeName Age: $password");
  }

  CurrentUser(this.nikeName, this.password);
}