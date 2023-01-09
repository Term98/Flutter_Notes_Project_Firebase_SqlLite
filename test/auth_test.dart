import 'package:test/test.dart';
import 'package:testapp/services/auth/auth_exception.dart';
import 'package:testapp/services/auth/auth_provider.dart';
import 'package:testapp/services/auth/auth_service.dart';
import 'package:testapp/services/auth/auth_user.dart';

void main(){

group(MockAuthProvider(), () {
  final provider = MockAuthProvider();

  test("Should not be initialized to begin with ", () {
    expect(provider._isInitialized, false);
  });

  test('Cannot log out if not initialized ', (){
    expect(
      provider.logOut(),
      throwsA(const TypeMatcher<NotInitializedException>())
      );
  });

  test('User should be Initialized', () async{
    await provider.initialize;
    expect(provider.isInitialized , true);
  });

  test('User shouldnt be null after initializing ', (){
    expect(provider.currentUser, null);
  });

  test('Should be able to Initialize in less than 2 second', () async{
    await provider.initialize();
    expect(provider.isInitialized,true );
  });

  test('Logged in user should be able toh get verified', (){
    provider.sendEmailVerification();
    final user = provider.currentUser;
    expect(user, isNotNull);
    expect(user!.isEmailVerified , true );
  });

  test('User need to logout and login again', () async{
    await provider.logOut();
    await provider.login(email: 'email', password: 'password');
    final user = provider.currentUser;
    expect(user, isNotNull);
  });


});

}

class NotInitializedException {}

class MockAuthProvider implements AuthProvider {
  AuthUser ? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email, 
    required String password}) async {
      if(!_isInitialized) throw NotInitializedException();
      await Future.delayed(const Duration(seconds: 1) ); 
      return login(email: email, password: password);
  }

  @override
  // TODO: implement currentUser
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async{
    await Future.delayed(const Duration(seconds: 1) );
    _isInitialized : true ; 
  }

  @override
  Future<void> logOut() async{
    if (!isInitialized) throw NotInitializedException();
    if (_user == null ) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1) );
    _user = null;
  }

  @override
  Future<AuthUser> login({required String email, required String password}) {
    if (!isInitialized) throw NotInitializedException();
    
    const user = AuthUser(isEmailVerified: false);
    _user = user ;
    return Future.value(user);
  }

  @override
  Future<void> sendEmailVerification() async{
    if (!isInitialized) throw NotInitializedException();
    final user = _user;
    if (user == null ) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
  }

}