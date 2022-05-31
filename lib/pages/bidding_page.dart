import 'package:auctioneer/models/auction_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class MainAuctionPage extends StatefulWidget {
  AuctionPageModel auctionModel;
  MainAuctionPage({Key? key, required this.auctionModel}) : super(key: key);

  @override
  State<MainAuctionPage> createState() => _MainAuctionPageState();
}

class _MainAuctionPageState extends State<MainAuctionPage> {
  var bidIncrement = 0;

  Future<void> placeBid() async {
    final docRef = FirebaseFirestore.instance.collection("auction_items").doc(widget.auctionModel.id);
    await FirebaseFirestore.instance.runTransaction(
            (transaction) async {
          DocumentSnapshot documentSnapshot = await transaction.get(docRef);
          if(documentSnapshot["bidPrice"] > widget.auctionModel.bidPrice + bidIncrement){
            bidIncrement=0;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You missed the shot")));
            return;
          }
          await transaction.update(docRef, {"bidPrice" : widget.auctionModel.bidPrice + bidIncrement,"bidder" : FirebaseAuth.instance.currentUser!.email});
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Successfully placed bid")));
          bidIncrement=0;
        });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("auction_items").doc(widget.auctionModel.id).snapshots(),
          builder: (context,AsyncSnapshot<DocumentSnapshot> snapshot){
            if(snapshot.hasData){
              widget.auctionModel.bidPrice = snapshot.data!["bidPrice"];
              return ListView(
                children: [
                  Text(widget.auctionModel.title),
                  Text(widget.auctionModel.sellerEmail),
                  ConstrainedBox(constraints: BoxConstraints(maxHeight: 100),child: Image.network(widget.auctionModel.imageURL),),
                  Text(widget.auctionModel.bidderEmail),
                  Text("Current bid price : " + widget.auctionModel.bidPrice.toString()),
                  Text(snapshot.data!["timestamp"].toDate().toLocal().toString()),
                  Visibility(
                    visible: widget.auctionModel.date.isBefore(DateTime.now()) &&  widget.auctionModel.date.add(Duration(minutes: 30)).isAfter(DateTime.now()) ? true : false,
                      child: Text("bidder email : " + (snapshot.data!["bidder"]=="" ? "No one has bidded" : snapshot.data!["bidder"])),
                  )
                ],
              );
            }
            return Center(child: CircularProgressIndicator(),);
          },
        ),
        floatingActionButton: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("auction_items").doc(widget.auctionModel.id).snapshots(),
          builder: (context,snapshot){
            if(snapshot.hasData){
              return Visibility(
                visible: widget.auctionModel.date.isBefore(DateTime.now()) &&  widget.auctionModel.date.add(Duration(minutes: 30)).isAfter(DateTime.now()) ? true : false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            bidIncrement = 100;
                            placeBid();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16,vertical: 10),
                            color: Colors.amberAccent,
                            child: Text("Yup! +100"),
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            bidIncrement = 500;
                            placeBid();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16,vertical: 10),
                            color: Colors.amberAccent,
                            child: Text("Yup! +500"),
                          ),
                        ),
                        GestureDetector(
                          onTap: (){
                            bidIncrement = 1000;
                            placeBid();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16,vertical: 10),
                            color: Colors.amberAccent,
                            child: Text("Yup! +1000"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            return Container();
          },
        )
      ),
    );
  }
}
