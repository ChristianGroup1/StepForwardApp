import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';

class NotificationService {
  String url='https://api.onesignal.com/notifications';
  static const String oneSignalAppId = "0a35afa9-5361-43e2-9149-df923ce38aee";
  static const String oneSignalRestApiKey =
      "os_v2_app_bi227kktmfb6fekj36jdzy4k52uqvfxovrmu37nwo3rmxj6trrbh3ariqad34oeszat36ip5s6n6g7hi26i5ozk547hn7zwnemomssy";

  Future<void> sendNotification() async {
  try {
    var pushId= OneSignal.User.pushSubscription.id.toString();
    
  var response=await http.post(Uri.parse(url,),headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Basic $oneSignalRestApiKey'
  },body: jsonEncode({
    "app_id": oneSignalAppId,
    "contents": {
      "en": "يمكنك متابعة الطلب من صفحة الطلبات"
    },
    "include_player_ids": [pushId],
    "headings": {
      "en": "تم اضافة طلب جديد"
    },
    
   
  }));

  if(response.statusCode==200){
    
  }else{
    
  }
} on Exception {
 
}
  
  }

  }