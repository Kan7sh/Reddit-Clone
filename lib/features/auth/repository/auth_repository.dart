import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reddit_clone/core/constants/constants.dart';
import 'package:reddit_clone/core/constants/firebase_constants.dart';
import 'package:reddit_clone/core/failure.dart';
import 'package:reddit_clone/core/type_def.dart';
import 'package:reddit_clone/models/user_model.dart';
import '../../../core/provider/firebase_providers.dart';


final authRepositoryProvider = Provider((ref)=>AuthRepository(
    firestore: ref.read(firestoreProvider),
    auth: ref.read(authProvider),
    googleSignIn: ref.read(googleSignInProvider)));

class AuthRepository{
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final FirebaseAuth _auth;

  AuthRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn}):
        _auth=auth,
        _firestore=firestore,
        _googleSignIn=googleSignIn;
  Stream<User?> get authStateChange=> _auth.authStateChanges();
  CollectionReference get _users => _firestore.collection(FirebaseConstants.usersCollection);
  FutureEither<UserModel> signInWithGoogle(bool isFromLogin) async{
    try{
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print(isFromLogin);
      final googleAuth = (await googleUser?.authentication);

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      UserCredential userCredential;
      if(isFromLogin){
        userCredential = await _auth.signInWithCredential(credential);
      }else{
         userCredential = await _auth.currentUser!.linkWithCredential(credential);
      }

      UserModel userModel;
      if(userCredential.additionalUserInfo!.isNewUser){

        userModel = UserModel(
            name: userCredential.user!.displayName??'No Name',
            profilePic: userCredential.user!.photoURL??Constants.avatarDefault,
            banner: Constants.bannerDefault,
            uid: userCredential.user!.uid,
            isAuthenticated: true,
            karma: 0,
            awards: ['awesomeAns','gold','platinum','helpful','plusone','rocket','thankyou','til']);
        await _users.doc(userCredential.user!.uid).set(userModel.toMap());
      }else{
        userModel = await getUserData(userCredential.user!.uid).first;
      }
      return right(userModel);
    }on FirebaseException catch(e) {
      throw e.message!;
    }catch(e){
      return left(Failure(e.toString()));
    }
  }
  FutureEither<UserModel> signInAsGuest() async{
    try{
      var userCredential = await _auth.signInAnonymously();
      UserModel userModel = UserModel(
            name: 'Guest',
            profilePic: Constants.avatarDefault,
            banner: Constants.bannerDefault,
            uid: userCredential.user!.uid,
            isAuthenticated: false,
            karma: 0,
            awards: []);
        await _users.doc(userCredential.user!.uid).set(userModel.toMap());

      return right(userModel);
    }on FirebaseException catch(e) {
      throw e.message!;
    }catch(e){
      return left(Failure(e.toString()));
    }
  }

  Stream<UserModel> getUserData(String uid){
    return _users.doc(uid).snapshots().map((event) => UserModel.fromMap(event.data() as Map<String,dynamic>));
  }

void logOut()async{
    await _googleSignIn.signOut();
    await _auth.signOut();
}

}


