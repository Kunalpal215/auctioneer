import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
class AddAuctionItem extends StatefulWidget {
  const AddAuctionItem({Key? key}) : super(key: key);

  @override
  State<AddAuctionItem> createState() => _AddAuctionItemState();
}

class _AddAuctionItemState extends State<AddAuctionItem> {
  File? imageFile;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String title="";
  String description="";
  DateTime? pickedDate;
  TimeOfDay? pickedTime;
  DateTime? pickedDateTime;
  bool submitted = false;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Auctioneer"),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          children: [
            GestureDetector(
              onTap: () async {
                var xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                if(xFile!=null){
                  setState((){
                    imageFile = File(xFile.path);
                  });
                }
              },
              child: imageFile==null ? Container(
                height: 100,
                margin: EdgeInsets.symmetric(horizontal: 16,vertical: 16),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black)
                ),
                child: Text("Pick an image"),
              ) : Container(
                height: 150,
                margin: EdgeInsets.symmetric(horizontal: 16,vertical: 16),
                decoration: BoxDecoration(
                  image: DecorationImage(image: FileImage(imageFile!),fit: BoxFit.cover),
                    border: Border.all(color: Colors.black)
                ),
              )
            ),
            TextFormField(
              onChanged: (value){
                title=value;
              },
              validator: (value){
                if(value==null || value=="") return "This field cannot be null";
              },
            ),
            TextFormField(
              onChanged: (value){
                description=value;
              },
              validator: (value){
                if(value==null || value=="") return "This field cannot be null";
              },
            ),
            GestureDetector(
              onTap: () async {
                print("here");
                pickedDate = await showDatePicker(context: context, initialDate: DateTime.now().add(Duration(days: 1)), firstDate: DateTime.now(), lastDate: DateTime.now().add(Duration(days: 7)));
                if(pickedDate!=null){
                  pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                  if(pickedTime!=null){
                    setState((){
                      pickedDateTime = DateTime(pickedDate!.year,pickedDate!.month,pickedDate!.day,pickedTime!.hour,pickedTime!.minute);
                    });
                  }
                }
                print("here2");
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                color: Colors.red,
                child: Text(pickedDateTime==null ? "Pick date & time for auction" : DateFormat("dd-MM-yyyy HH:mm").format(pickedDateTime!).toString()),
              )
            ),
            ElevatedButton(
                onPressed: () async {
                  if(submitted==true) return;
                  bool validate = formKey.currentState!.validate();
                  if(!validate) return;
                  if(imageFile==null){
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Choose an image")));
                    return;
                  }
                  if(pickedDate==null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Pick date and time for start auction")));
                    return;
                  }
                  submitted=true; // setting the submission status to true now
                  var bytes = imageFile!.readAsBytesSync();
                  var headers = {
                    'Authorization': 'Client-ID 921c5d9be378e92'
                  };
                  var request = http.MultipartRequest('POST', Uri.parse('https://api.imgur.com/3/image'));
                  request.fields.addAll({
                    'image': base64Encode(bytes),
                  });

                  request.headers.addAll(headers);

                  http.StreamedResponse response = await request.send();

                  if (response.statusCode == 200) {
                    var data = await response.stream.bytesToString();
                    print(data);
                    var body = jsonDecode(data);
                    print(body);
                    var imageURL = body["data"]["link"];
                    await FirebaseFirestore.instance.collection('auction_items').add({
                      "title" : title,
                      "description" : description,
                      "imageURL" : imageURL,
                      "timestamp" : pickedDateTime,
                      "seller" : FirebaseAuth.instance.currentUser!.email,
                      "bidPrice" : 0,
                      "bidder" : "",
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Item added to future auctions")));
                    Navigator.pop(context);
                  }
                  else {
                    submitted=false;
                  print(response.reasonPhrase);
                  }
                },
                child: Text("Add this Item"))
          ],
        ),
      ),
    );
  }
}
