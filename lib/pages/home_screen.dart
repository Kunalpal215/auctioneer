import 'package:auctioneer/models/auction_page.dart';
import 'package:auctioneer/pages/add_item.dart';
import 'package:auctioneer/pages/bidding_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Auctioneer"),
          bottom: const TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.handshake),
                  text: "Current Auctions",
                ),
                Tab(
                  icon: Icon(Icons.shopping_bag),
                  text: "Future Auctions",
                ),
                Tab(
                  icon: Icon(Icons.door_back_door_outlined),
                  text: "Past Auctions",
                ),
              ]
          ),
        ),
        body: TabBarView(
            children: [
              StreamBuilder(
                stream: FirebaseFirestore.instance.collection('auction_items').orderBy("timestamp", descending: false).where("timestamp", isLessThan: DateTime.now(), isGreaterThan: DateTime.now().subtract(Duration(minutes: 30))).snapshots(),
                builder: (context, AsyncSnapshot snapshot){
                  List<Widget> currentAuctionItems = [];
                  if(snapshot.hasData){
                    snapshot.data!.docs.forEach((value) => {
                      currentAuctionItems.add(ListItemWidget(id: value.id ,title: value["title"], sellerEmail: value["seller"], bidPrice: value["bidPrice"] ,description: value["description"], imageURL: value["imageURL"], date: value["timestamp"].toDate().toLocal(),bidderEmail: value["bidder"],))
                    });
                    return ListView(
                      children: currentAuctionItems,
                    );
                  }
                  return Center(child: CircularProgressIndicator(),);
                },
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance.collection('auction_items').orderBy("timestamp", descending: false).where("timestamp", isGreaterThan: DateTime.now()).snapshots(),
                builder: (context, AsyncSnapshot snapshot){
                  List<Widget> currentAuctionItems = [];
                  if(snapshot.hasData){
                    snapshot.data!.docs.forEach((value) => {
                      currentAuctionItems.add(ListItemWidget(id: value.id,title: value["title"], bidPrice: value["bidPrice"] ,sellerEmail: value["seller"], description: value["description"], imageURL: value["imageURL"], date: value["timestamp"].toDate().toLocal(),bidderEmail: value["bidder"]))
                    });
                    return ListView(
                      children: currentAuctionItems,
                    );
                  }
                  return Center(child: CircularProgressIndicator(),);
                },
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance.collection('auction_items').orderBy("timestamp", descending: false).where("timestamp", isLessThan: DateTime.now().subtract(Duration(minutes: 30))).snapshots(),
                builder: (context, AsyncSnapshot snapshot){
                  List<Widget> currentAuctionItems = [];
                  if(snapshot.hasData){
                    snapshot.data!.docs.forEach((value) => {
                      currentAuctionItems.add(ListItemWidget(id: value.id,title: value["title"], bidPrice: value["bidPrice"] ,sellerEmail: value["seller"], description: value["description"], imageURL: value["imageURL"], date: value["timestamp"].toDate().toLocal(),bidderEmail: value["bidder"]))
                    });
                    return ListView(
                      children: currentAuctionItems,
                    );
                  }
                  return Center(child: CircularProgressIndicator(),);
                },
              ),
            ]
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: (){
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddAuctionItem()));
            },
          child: Icon(Icons.add),
        )
      ),
    );
  }
}

class ListItemWidget extends StatelessWidget {

  final String id;
  final String title;
  final String description;
  final String imageURL;
  final String sellerEmail;
  final DateTime date;
  final String bidderEmail;
  final bidPrice;

  const ListItemWidget({Key? key, required this.id ,required this.title,required this.sellerEmail,required this.description,required this.imageURL,required this.date, required this.bidPrice ,required this.bidderEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: (){
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => MainAuctionPage(auctionModel: AuctionPageModel(id: id, title: title, sellerEmail: sellerEmail, description: description, imageURL: imageURL, date: date, bidderEmail: bidderEmail, bidPrice: bidPrice))));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15,vertical: 4),
        decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(21)
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 194),
              child: Padding(
                padding: const EdgeInsets.only(left: 16,right: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 16),
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 105,maxWidth: 135),
              child: ClipRRect(
                borderRadius: BorderRadius.only(topRight: Radius.circular(21),bottomRight: Radius.circular(21)),
                child: Container(
                  alignment: Alignment.center,
                  width: screenWidth*0.35,
                  decoration: BoxDecoration(
                    image: DecorationImage(image: NetworkImage(imageURL),fit: BoxFit.cover)
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

