import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:engez/features/admin/manager/admin_requests_state.dart';
import 'package:engez/features/admin/models/admin_request_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminRequestsCubit extends Cubit<AdminRequestsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdminRequestsCubit() : super(AdminRequestsInitial());

  Future<void> fetchPendingRequests() async {
    try {
      emit(AdminRequestsLoading());
      final querySnapshot = await _firestore
          .collection('ownerRequests')
          .where('status', isEqualTo: 'pending')
          .get();

      final List<AdminRequestModel> requests = [];
      
      for (var doc in querySnapshot.docs) {
        final uid = doc.id;
        final status = doc.data()['status'] as String? ?? 'pending';
        
        // Fetch user details
        final userDoc = await _firestore.collection('users').doc(uid).get();
        final userData = userDoc.data();
        final userName = userData?['userName'] ?? userData?['name'] ?? 'بدون اسم';
        final email = userData?['email'] ?? 'بدون بريد';
        
        requests.add(AdminRequestModel(
          uid: uid,
          status: status,
          userName: userName,
          email: email,
        ));
      }
      
      emit(AdminRequestsLoaded(requests));
    } catch (e) {
      emit(AdminRequestsError(e.toString()));
    }
  }

  Future<void> approveRequest(String uid) async {
    try {
      final batch = _firestore.batch();
      
      final requestRef = _firestore.collection('ownerRequests').doc(uid);
      batch.update(requestRef, {'status': 'approved'});
      
      final userRef = _firestore.collection('users').doc(uid);
      batch.update(userRef, {'role': 'owner'});
      
      await batch.commit();
      
      // Refresh list
      fetchPendingRequests();
    } catch (e) {
      emit(AdminRequestsError(e.toString()));
    }
  }

  Future<void> rejectRequest(String uid) async {
    try {
      await _firestore.collection('ownerRequests').doc(uid).update({'status': 'rejected'});
      // Refresh list
      fetchPendingRequests();
    } catch (e) {
      emit(AdminRequestsError(e.toString()));
    }
  }
}
